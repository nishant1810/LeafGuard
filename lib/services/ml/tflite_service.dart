import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:image/image.dart' as img;
import 'package:tflite_flutter/tflite_flutter.dart';

// ================= GRADCAM OUTPUT =================
class GradCAMOutput {
  final List<List<List<double>>> featureMap;
  final List<double>             predictions;

  const GradCAMOutput({
    required this.featureMap,
    required this.predictions,
  });
}

class TFLiteService {
  // ===== CLASSIFIER =====
  static Interpreter? _interpreter;
  static bool         _loaded = false;

  // ===== GRADCAM =====
  static Interpreter? _gradCamInterpreter;
  static bool         _gradCamLoaded     = false;
  static int          _gradCamNumOutputs = 0;

  // ✅ CONFIRMED from model inspection:
  // Output[0] = predictions  [1, 3]
  // Output[1] = feature map  [1, 7, 7, 1280]
  static List<int> _predShape       = [1, 3];
  static List<int> _featureMapShape = [1, 7, 7, 1280];

  static const List<String> _labels = [
    'Blight',
    'Healthy',
    'Phyllosticta',
  ];

  // ================= LOAD CLASSIFIER =================
  static Future<void> loadModel() async {
    if (_loaded) return;
    try {
      _interpreter = await Interpreter.fromAsset(
        'assets/models/mobilenet_model.tflite',
        options: InterpreterOptions()..threads = 4,
      );
      _loaded = true;
      debugPrint('✅ MobileNet loaded');

      final inputs  = _interpreter!.getInputTensors();
      final outputs = _interpreter!.getOutputTensors();
      debugPrint('📐 MobileNet Input[0]:  ${inputs[0].shape}');
      debugPrint('📐 MobileNet Output[0]: ${outputs[0].shape}');
    } catch (e) {
      debugPrint('❌ MobileNet load error: $e');
      rethrow;
    }
  }

  // ================= LOAD GRADCAM =================
  static Future<void> loadGradCamModel() async {
    if (_gradCamLoaded) return;
    try {
      // ✅ Force reset in case old model was cached
      _gradCamInterpreter?.close();
      _gradCamInterpreter = null;

      _gradCamInterpreter = await Interpreter.fromAsset(
        'assets/models/gradcam_model.tflite',
        options: InterpreterOptions()..threads = 2,
      );

      final inputTensors  = _gradCamInterpreter!.getInputTensors();
      final outputTensors = _gradCamInterpreter!.getOutputTensors();
      _gradCamNumOutputs  = outputTensors.length;

      debugPrint('===== GRADCAM MODEL INSPECTION =====');
      for (int i = 0; i < inputTensors.length; i++) {
        debugPrint('📐 Input[$i]:  shape=${inputTensors[i].shape} '
            'type=${inputTensors[i].type}');
      }
      for (int i = 0; i < outputTensors.length; i++) {
        debugPrint('📐 Output[$i]: shape=${outputTensors[i].shape} '
            'type=${outputTensors[i].type}');
      }
      debugPrint('Total outputs: $_gradCamNumOutputs');
      debugPrint('=====================================');

      // ✅ CORRECT MAPPING based on model inspection:
      // Output[0] shape=[1,3]          → PREDICTIONS
      // Output[1] shape=[1,7,7,1280]   → FEATURE MAP
      if (_gradCamNumOutputs == 2) {
        final shape0 = outputTensors[0].shape;
        final shape1 = outputTensors[1].shape;

        if (shape0.length == 2 && shape1.length == 4) {
          // ✅ Confirmed: Output[0]=pred, Output[1]=featureMap
          _predShape       = shape0;
          _featureMapShape = shape1;
          debugPrint('✅ Output[0]=predictions$shape0 '
              'Output[1]=featureMap$shape1');
        } else if (shape0.length == 4 && shape1.length == 2) {
          // Swapped: Output[0]=featureMap, Output[1]=pred
          _featureMapShape = shape0;
          _predShape       = shape1;
          debugPrint('✅ Output[0]=featureMap$shape0 '
              'Output[1]=predictions$shape1');
        }
      } else if (_gradCamNumOutputs == 1) {
        final shape = outputTensors[0].shape;
        if (shape.length == 4) {
          _featureMapShape = shape;
        } else if (shape.length == 2) {
          _predShape = shape;
        }
        debugPrint('⚠️ Single output: $shape');
      }

      _gradCamLoaded = true;
      debugPrint('✅ GradCAM loaded — '
          'predShape=$_predShape '
          'featureMapShape=$_featureMapShape');
    } catch (e) {
      _gradCamLoaded = false;
      debugPrint('❌ GradCAM load error: $e');
    }
  }

  // ================= PREPROCESS =================
  static List _preprocessImage(img.Image image) {
    final resized = img.copyResize(image, width: 224, height: 224);
    return List.generate(
      1,
          (_) => List.generate(
        224,
            (y) => List.generate(
          224,
              (x) {
            final pixel = resized.getPixel(x, y);
            return [
              pixel.r / 255.0,
              pixel.g / 255.0,
              pixel.b / 255.0,
            ];
          },
        ),
      ),
    );
  }

  // ================= CLASSIFY =================
  static Future<Map<String, dynamic>> classify(File imageFile) async {
    await loadModel();

    final Uint8List  bytes = await imageFile.readAsBytes();
    final img.Image? image = img.decodeImage(bytes);
    if (image == null) throw Exception('Unable to decode image');

    final input  = _preprocessImage(image);
    final output = List.generate(1, (_) => List.filled(3, 0.0));

    _interpreter!.run(input, output);

    final List<double> probs = (output[0] as List)
        .map((e) => (e as num).toDouble())
        .toList();

    final maxIdx =
    probs.indexOf(probs.reduce((a, b) => a > b ? a : b));

    debugPrint('✅ Classification: ${_labels[maxIdx]} '
        '(${(probs[maxIdx] * 100).toStringAsFixed(1)}%)');
    debugPrint('✅ All probs: ${probs.map(
            (p) => '${(p * 100).toStringAsFixed(1)}%').toList()}');

    return {
      'label':      _labels[maxIdx],
      'disease':    _labels[maxIdx],
      'confidence': probs[maxIdx],
      'probs':      probs,
    };
  }

  // ================= GRADCAM =================
  static Future<GradCAMOutput?> runGradCam(File imageFile) async {
    await loadGradCamModel();

    if (!_gradCamLoaded || _gradCamInterpreter == null) {
      debugPrint('⚠️ GradCAM not available — will use fallback');
      return null;
    }

    try {
      final Uint8List  bytes = await imageFile.readAsBytes();
      final img.Image? image = img.decodeImage(bytes);
      if (image == null) return null;

      final input = _preprocessImage(image);

      // ===== EXTRACT DIMENSIONS =====
      final int fH = _featureMapShape.length > 1
          ? _featureMapShape[1] : 7;
      final int fW = _featureMapShape.length > 2
          ? _featureMapShape[2] : 7;
      final int fC = _featureMapShape.length > 3
          ? _featureMapShape[3] : 1280;
      final int nClasses = _predShape.length > 1
          ? _predShape[1] : 3;

      debugPrint('📐 Running GradCAM: '
          'featureMap=[$fH,$fW,$fC] classes=$nClasses');

      if (_gradCamNumOutputs == 1) {
        return await _runSingleOutput(input, fH, fW, fC);
      } else {
        return await _runDualOutput(input, fH, fW, fC, nClasses);
      }
    } catch (e) {
      debugPrint('❌ GradCAM run error: $e');
      return null;
    }
  }

  // ===== SINGLE OUTPUT =====
  static Future<GradCAMOutput?> _runSingleOutput(
      List input, int fH, int fW, int fC) async {
    try {
      final featureMapOutput = List.generate(
        1,
            (_) => List.generate(
          fH,
              (_) => List.generate(
            fW,
                (_) => List.filled(fC, 0.0),
          ),
        ),
      );

      _gradCamInterpreter!.run(input, featureMapOutput);

      final featureMap = List.generate(
        fH,
            (h) => List.generate(
          fW,
              (w) => List.generate(
            fC,
                (c) => (featureMapOutput[0][h][w][c] as num).toDouble(),
          ),
        ),
      );

      debugPrint('✅ Single output GradCAM success');
      return GradCAMOutput(
        featureMap:  featureMap,
        predictions: [0.0, 0.0, 0.0],
      );
    } catch (e) {
      debugPrint('❌ Single output error: $e');
      return null;
    }
  }

  // ===== DUAL OUTPUT =====
  static Future<GradCAMOutput?> _runDualOutput(
      List input, int fH, int fW, int fC, int nClasses) async {
    try {
      // ✅ CONFIRMED OUTPUT ORDER:
      // Output[0] = predictions  [1, 3]
      // Output[1] = feature map  [1, 7, 7, 1280]
      final predOutput = List.generate(
          1, (_) => List.filled(nClasses, 0.0));
      final featureMapOutput = List.generate(
        1,
            (_) => List.generate(
          fH,
              (_) => List.generate(
            fW,
                (_) => List.filled(fC, 0.0),
          ),
        ),
      );

      // ✅ CORRECT MAPPING:
      // key 0 → predOutput       (Output[0] = predictions)
      // key 1 → featureMapOutput (Output[1] = feature map)
      final outputs = {
        0: predOutput,
        1: featureMapOutput,
      };

      _gradCamInterpreter!.runForMultipleInputs([input], outputs);

      // ===== CONVERT FEATURE MAP =====
      final List<List<List<double>>> featureMap = List.generate(
        fH,
            (h) => List.generate(
          fW,
              (w) => List.generate(
            fC,
                (c) =>
                (featureMapOutput[0][h][w][c] as num).toDouble(),
          ),
        ),
      );

      // ===== CONVERT PREDICTIONS =====
      final List<double> predictions = List.generate(
        nClasses,
            (i) => (predOutput[0][i] as num).toDouble(),
      );

      debugPrint('✅ Dual output GradCAM success');
      debugPrint('✅ Predictions: $predictions');
      debugPrint('📊 Feature map range: '
          'checking first channel...');

      return GradCAMOutput(
        featureMap:  featureMap,
        predictions: predictions,
      );
    } catch (e) {
      debugPrint('❌ Dual output error: $e');
      return null;
    }
  }

  // ================= INSPECT =================
  static Future<void> inspectGradCamModel() async {
    await loadGradCamModel();
    if (!_gradCamLoaded || _gradCamInterpreter == null) {
      debugPrint('❌ GradCAM model NOT loaded');
      return;
    }
    debugPrint('===== GRADCAM MODEL INSPECTION =====');
    final inputs  = _gradCamInterpreter!.getInputTensors();
    final outputs = _gradCamInterpreter!.getOutputTensors();
    for (int i = 0; i < inputs.length; i++) {
      debugPrint('Input[$i]:  shape=${inputs[i].shape} '
          'type=${inputs[i].type}');
    }
    for (int i = 0; i < outputs.length; i++) {
      debugPrint('Output[$i]: shape=${outputs[i].shape} '
          'type=${outputs[i].type}');
    }
    debugPrint('Total outputs: ${outputs.length}');
    debugPrint('pred shape:       $_predShape');
    debugPrint('featureMap shape: $_featureMapShape');
    debugPrint('=====================================');
  }

  // ================= DISPOSE =================
  static void dispose() {
    _interpreter?.close();
    _gradCamInterpreter?.close();
    _interpreter        = null;
    _gradCamInterpreter = null;
    _loaded             = false;
    _gradCamLoaded      = false;
    debugPrint('✅ TFLiteService disposed');
  }
}