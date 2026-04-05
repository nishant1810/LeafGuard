import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:image/image.dart' as img;

import '../core/models/scan_result.dart';
import '../core/utils/image_quality.dart';
import '../core/utils/image_validator.dart';
import '../core/utils/image_resize.dart';
import '../core/utils/leaf_validator.dart';

import 'ml/tflite_service.dart';
import 'ml/gradcam_helper.dart';
import 'ml/stage_classifier.dart';
import 'ml/spot_counter.dart';
import 'ml/sam_service.dart'; // 🔥 IMPORTANT

class ModelService {

  static Future<ScanResult> runPipeline(File imageFile) async {

    // ===== 1. VALIDATE =====
    final bool isValid = await ImageValidator.isValidImage(imageFile);
    if (!isValid) throw Exception("Invalid image.");

    // ===== 2. BLUR CHECK =====
    if (ImageQuality.isBlurred(imageFile)) {
      throw Exception("Image is blurry.");
    }

    // ===== 3. LEAF CHECK =====
    final decoded = img.decodeImage(await imageFile.readAsBytes());
    if (decoded == null || !LeafValidator.isLikelyLeaf(decoded)) {
      throw Exception("Not a leaf image.");
    }

    // ===== 4. RESIZE =====
    final File resizedFile = await ImageResize.to224(imageFile);
    final img.Image resizedImage =
    img.decodeImage(await resizedFile.readAsBytes())!;

    // ===== 5. CLASSIFICATION =====
    final prediction = await TFLiteService.classify(resizedFile);

    final String label      = prediction['label'];
    final String disease    = prediction['disease'];
    final double confidence =
    (prediction['confidence'] as num).toDouble();

    if (confidence < 0.35) {
      throw Exception("Invalid leaf image.");
    }

    final bool isUncertain = confidence < 0.60;

    // ===== 6. GRADCAM + SAM =====
    Uint8List? heatmapBytes;
    double affectedArea = 0.0;
    bool usedRealGradCAM = false;

    try {
      final int classIndex = _classIndex(disease);

      // ===== REAL GRADCAM =====
      final GradCAMOutput? realOutput =
      await TFLiteService.runGradCam(resizedFile);

      final GradCAMOutput gradcamOutput = realOutput ??
          _buildGradCAMOutput(resizedImage, classIndex);

      usedRealGradCAM = realOutput != null;

      // 🔥 ===== SAM MASK =====
      final img.Image mask =
      await SamService.getLeafMask(resizedFile);

      // 🔥 ===== FINAL HEATMAP =====
      final List<int> heatmap = GradCAMHelper.generateHeatmap(
        output:        gradcamOutput,
        classIndex:    classIndex,
        originalImage: resizedImage,
        leafMask:      mask,
      );

      heatmapBytes = Uint8List.fromList(heatmap);

      affectedArea =
          StageClassifier.hotAreaFromBytes(heatmapBytes);

      debugPrint("✅ GradCAM: ${usedRealGradCAM ? "REAL" : "APPROX"}");

    } catch (e) {
      debugPrint("❌ GradCAM error: $e");
    }

    // ===== 7. STAGE =====
    final diseaseClass = _toDiseaseClass(disease);

    final stageResult = StageClassifier.classify(
      diseaseClass:  diseaseClass,
      heatmapBytes:  heatmapBytes ?? Uint8List(0),
      originalImage: resizedImage,
      confidence:    confidence,
    );

    int? spotCount;
    if (diseaseClass == DiseaseClass.phyllosticta) {
      spotCount = stageResult.spotCount;
    }

    // ===== FINAL RESULT =====
    return ScanResult(
      imagePath:    imageFile.path,
      label:        label,
      disease:      disease,
      confidence:   confidence,
      source:       'Camera/Gallery',
      timestamp:    DateTime.now(),
      isUncertain:  isUncertain,
      stage:        _stageLabel(stageResult.stage),
      affectedArea: stageResult.affectedAreaPercent,
      spotCount:    spotCount,
      heatmapBytes: heatmapBytes,
    );
  }

  // ================= HELPERS =================

  static int _classIndex(String disease) {
    final d = disease.toLowerCase();
    if (d.contains('blight'))       return 0;
    if (d.contains('healthy'))      return 1;
    if (d.contains('phyllosticta')) return 2;
    return 0;
  }

  static DiseaseClass _toDiseaseClass(String disease) {
    final d = disease.toLowerCase();
    if (d.contains('healthy'))      return DiseaseClass.healthy;
    if (d.contains('blight'))       return DiseaseClass.blight;
    if (d.contains('phyllosticta')) return DiseaseClass.phyllosticta;
    return DiseaseClass.blight;
  }

  static String _stageLabel(DiseaseStage stage) {
    switch (stage) {
      case DiseaseStage.initial:
        return 'Initial Stage';
      case DiseaseStage.advanced:
        return 'Advanced Stage';
      case DiseaseStage.none:
        return 'N/A';
    }
  }

  // ===== FALLBACK GRADCAM =====
  static GradCAMOutput _buildGradCAMOutput(
      img.Image image, int classIndex) {

    const int H = 7, W = 7, C = 1280;

    final featureMap = List.generate(
      H,
          (h) => List.generate(
        W,
            (w) => List.generate(
          C,
              (c) {
            final px = (w * image.width ~/ W)
                .clamp(0, image.width - 1);
            final py = (h * image.height ~/ H)
                .clamp(0, image.height - 1);

            final p = image.getPixel(px, py);

            final r = p.r / 255.0;
            final g = p.g / 255.0;
            final b = p.b / 255.0;

            switch (classIndex) {
              case 0: return (r - g).abs(); // blight
              case 1: return g;             // healthy
              case 2: return (r - b).abs(); // spots
              default: return (r + g + b) / 3;
            }
          },
        ),
      ),
    );

    return GradCAMOutput(
      featureMap: featureMap,
      predictions: [
        classIndex == 0 ? 1.0 : 0.0,
        classIndex == 1 ? 1.0 : 0.0,
        classIndex == 2 ? 1.0 : 0.0,
      ],
    );
  }
}