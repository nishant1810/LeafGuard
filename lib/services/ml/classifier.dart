import 'dart:io';
import 'dart:typed_data';
import 'dart:math' as math;
import 'package:flutter/services.dart';
import 'package:flutter/foundation.dart';
import 'package:tflite_flutter/tflite_flutter.dart';
import 'package:image/image.dart' as img;

class Classifier {
  static const int inputSize = 224;
  static const String modelPath =
      'assets/models/mobilenet_model.tflite';
  static const String labelsPath = 'assets/labels.txt';

  Interpreter? _interpreter;
  late List<String> _labels;
  late bool _isQuantizedInput;
  late bool _isQuantizedOutput;

  // =========================
  // LOAD MODEL
  // =========================
  Future<void> loadModel() async {
    _interpreter = await Interpreter.fromAsset(modelPath);
    _labels = await _loadLabels();

    _isQuantizedInput =
        _interpreter!.getInputTensor(0).type.toString().contains('uint8');
    _isQuantizedOutput =
        _interpreter!.getOutputTensor(0).type.toString().contains('uint8');

    debugPrint('Model loaded');
    debugPrint('Quantized input: $_isQuantizedInput');
    debugPrint('Quantized output: $_isQuantizedOutput');
    debugPrint(
        'Input shape: ${_interpreter!.getInputTensor(0).shape}');
    debugPrint(
        'Output shape: ${_interpreter!.getOutputTensor(0).shape}');
    debugPrint('Labels: $_labels');
  }

  Future<List<String>> _loadLabels() async {
    final raw = await rootBundle.loadString(labelsPath);
    return raw
        .replaceAll('\r', '')
        .replaceAll('\uFEFF', '')
        .split('\n')
        .map((e) => e.trim())
        .where((e) => e.isNotEmpty)
        .toList();
  }

  // =========================
  // PREDICT
  // =========================
  Future<Map<String, dynamic>> predict(File imageFile) async {
    if (_interpreter == null) {
      throw Exception('Interpreter not initialized');
    }

    final bytes = await imageFile.readAsBytes();
    final image = img.decodeImage(bytes);
    if (image == null) {
      throw Exception('Invalid image');
    }

    final resized =
    img.copyResize(image, width: inputSize, height: inputSize);

    // ---------- INPUT ----------
    final Object input = _isQuantizedInput
        ? _imageToUint8(resized).reshape([1, inputSize, inputSize, 3])
        : _imageToFloat32(resized).reshape([1, inputSize, inputSize, 3]);

    // ---------- OUTPUT ----------
    final outputTensor = _interpreter!.getOutputTensor(0);
    final outputShape = outputTensor.shape;
    final outputSize = outputShape.reduce((a, b) => a * b);

    final Object output = _isQuantizedOutput
        ? Uint8List(outputSize).reshape(outputShape)
        : List.filled(outputSize, 0.0).reshape(outputShape);

    _interpreter!.run(input, output);

    // ---------- POST PROCESS ----------
    List<double> scores;

    if (_isQuantizedOutput) {
      final scale = outputTensor.params.scale;
      final zeroPoint = outputTensor.params.zeroPoint;

      scores = (output as List)[0]
          .map<double>((e) => (e - zeroPoint) * scale)
          .toList();
    } else {
      scores = List<double>.from((output as List)[0]);
    }

    if (scores.length != _labels.length) {
      throw Exception(
        'Model outputs ${scores.length} values but labels.txt has ${_labels.length}',
      );
    }

    if (!_isProbability(scores)) {
      scores = _softmax(scores);
    }

    // ---------- TOP-2 LOGIC ----------
    final indexed = scores.asMap().entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));

    final top2 = indexed.take(2).map((e) {
      return {
        'label': _labels[e.key],
        'confidence': e.value,
        'index': e.key, // 🔥 add index here
      };
    }).toList();

    final best = top2.first;

    return {
      'label': best['label'],
      'confidence': best['confidence'],
      'index': best['index'], // 🔥 REQUIRED FOR GRADCAM
      'top2': top2,
      'all_results': Map.fromIterables(_labels, scores),
    };
  }

  // =========================
  // HELPERS
  // =========================
  Float32List _imageToFloat32(img.Image image) {
    final buffer = Float32List(inputSize * inputSize * 3);
    int index = 0;
    for (int y = 0; y < inputSize; y++) {
      for (int x = 0; x < inputSize; x++) {
        final p = image.getPixel(x, y);
        buffer[index++] = p.r / 255.0;
        buffer[index++] = p.g / 255.0;
        buffer[index++] = p.b / 255.0;
      }
    }
    return buffer;
  }

  Uint8List _imageToUint8(img.Image image) {
    final buffer = Uint8List(inputSize * inputSize * 3);
    int index = 0;
    for (int y = 0; y < inputSize; y++) {
      for (int x = 0; x < inputSize; x++) {
        final p = image.getPixel(x, y);
        buffer[index++] = p.r.toInt();
        buffer[index++] = p.g.toInt();
        buffer[index++] = p.b.toInt();
      }
    }
    return buffer;
  }

  bool _isProbability(List<double> values) {
    final sum = values.reduce((a, b) => a + b);
    return sum > 0.99 && sum < 1.01;
  }

  List<double> _softmax(List<double> x) {
    final maxVal = x.reduce(math.max);
    final exp = x.map((e) => math.exp(e - maxVal)).toList();
    final sum = exp.reduce((a, b) => a + b);
    return exp.map((e) => e / sum).toList();
  }

  void dispose() {
    _interpreter?.close();
  }
}
