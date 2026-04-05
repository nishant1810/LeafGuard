import 'dart:isolate';
import 'dart:io';
import 'dart:typed_data';

import 'package:image/image.dart' as img;

import 'classifier.dart';
import 'tflite_service.dart';
import 'gradcam_helper.dart';
import 'sam_service.dart';

Future<Map<String, dynamic>> runInference(File image) async {
  final receivePort = ReceivePort();

  await Isolate.spawn(_entry, receivePort.sendPort);

  final sendPort = await receivePort.first as SendPort;
  final response = ReceivePort();

  sendPort.send([image.path, response.sendPort]);
  return await response.first;
}

void _entry(SendPort mainSendPort) async {
  final port = ReceivePort();
  mainSendPort.send(port.sendPort);

  final classifier = Classifier();
  await classifier.loadModel();

  await for (var msg in port) {
    final path = msg[0] as String;
    final SendPort reply = msg[1];

    try {
      final file = File(path);

      // ===== STEP 1: CLASSIFICATION =====
      final classification = await classifier.predict(file);

      final int classIndex = classification['index'] ?? 0;

      // ===== STEP 2: DECODE IMAGE =====
      final bytes = await file.readAsBytes();
      final img.Image? image = img.decodeImage(bytes);

      if (image == null) {
        throw Exception("Image decode failed");
      }

      // ===== STEP 3: GRADCAM OUTPUT =====
      final gradCamOutput = await TFLiteService.runGradCam(file);

      Uint8List? heatmapBytes;

      if (gradCamOutput != null) {
        // ===== STEP 4: SAM MASK =====
        final mask = await SamService.getLeafMask(file);

        // ===== STEP 5: HEATMAP =====
        heatmapBytes = Uint8List.fromList(
          GradCAMHelper.generateHeatmap(
            output: gradCamOutput,
            classIndex: classIndex,
            originalImage: image,
            leafMask: mask,
          ),
        );
      }

      // ===== FINAL RESPONSE =====
      reply.send({
        ...classification,
        'heatmap': heatmapBytes, // 🔥 send to UI
      });

    } catch (e) {
      reply.send({
        'error': e.toString(),
      });
    }
  }
}