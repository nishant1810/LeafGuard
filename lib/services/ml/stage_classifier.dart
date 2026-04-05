import 'dart:typed_data';
import 'package:image/image.dart' as img;

import 'spot_counter.dart';

enum DiseaseClass { healthy, blight, phyllosticta }
enum DiseaseStage  { none, initial, advanced }

class StageClassifier {

  // ===== THRESHOLDS =====
  // Blight: area-based
  static const double _blightInitialMax = 0.30;

  // Phyllosticta: spot-based (from notebook THRESHOLD = 35)
  // notebook mean=27.9, 50th percentile=25, 75th=40
  // THRESHOLD=35 gave: Initial=121, Advanced=70 on val set
  static const int    _phylloStageThreshold = 35; // ✅ from notebook

  static StageResult classify({
    required DiseaseClass diseaseClass,
    required Uint8List    heatmapBytes,
    required img.Image    originalImage,
    required double       confidence,
  }) {
    // ===== HEALTHY — no stage =====
    if (diseaseClass == DiseaseClass.healthy) {
      return const StageResult(
        stage:              DiseaseStage.none,
        affectedAreaPercent: 0.0,
        spotCount:          null,
      );
    }

    // ===== AFFECTED AREA from heatmap =====
    final double area = heatmapBytes.isEmpty
        ? classifySimpleArea(confidence)
        : hotAreaFromBytes(heatmapBytes);

    // ===== BLIGHT — area based =====
    if (diseaseClass == DiseaseClass.blight) {
      return StageResult(
        stage: area <= _blightInitialMax
            ? DiseaseStage.initial
            : DiseaseStage.advanced,
        affectedAreaPercent: area,
        spotCount: null,
      );
    }

    // ===== PHYLLOSTICTA — spot count based =====
    // Uses exact algorithm from notebook:
    // HSV mask → morphClose → morphOpen → contours → area 8–1000
    // Stage: Initial if spots < 35, Advanced if spots >= 35
    final int spots = SpotCounter.countSpots(originalImage);

    return StageResult(
      // ✅ notebook threshold: THRESHOLD = 35
      stage: spots < _phylloStageThreshold
          ? DiseaseStage.initial
          : DiseaseStage.advanced,
      affectedAreaPercent: area,
      spotCount: spots,
    );
  }

  // ===== SIMPLE CLASSIFY (no heatmap) =====
  static String classifySimple({
    required String disease,
    required double confidence,
  }) {
    if (disease.toLowerCase() == 'healthy') return 'N/A';
    return confidence < 0.75 ? 'Initial Stage' : 'Advanced Stage';
  }

  // ===== SIMPLE AREA (fallback) =====
  static double classifySimpleArea(double confidence) =>
      (confidence * 0.5).clamp(0.0, 1.0);

  // ===== HOT AREA FROM HEATMAP BYTES =====
  // Counts red/warm pixels in GradCAM heatmap
  // Red pixels = high activation = disease area
  static double hotAreaFromBytes(Uint8List bytes) {
    final img.Image? heatmap = img.decodeImage(bytes);
    if (heatmap == null) return 0.0;

    int hot   = 0;
    int total = 0;

    for (int y = 0; y < heatmap.height; y += 2) {
      for (int x = 0; x < heatmap.width; x += 2) {
        final p = heatmap.getPixel(x, y);
        final int r = p.r.toInt();
        final int g = p.g.toInt();
        final int b = p.b.toInt();

        // ===== HOT PIXEL: red/orange dominant in jet colormap =====
        // Jet colormap hot zone: high R, low B
        if (r > 150 && r > g * 1.2 && r > b * 1.5) hot++;
        total++;
      }
    }

    return total > 0 ? (hot / total).clamp(0.0, 1.0) : 0.0;
  }
}

// ===== STAGE RESULT =====
class StageResult {
  final DiseaseStage stage;
  final double       affectedAreaPercent;
  final int?         spotCount;

  const StageResult({
    required this.stage,
    required this.affectedAreaPercent,
    required this.spotCount,
  });
}