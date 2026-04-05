import 'dart:io';
import 'dart:typed_data';
import 'package:image/image.dart' as img;

class ImageCropper {
  static Future<File> cropWithBox(
      File imageFile,
      double x1,
      double y1,
      double x2,
      double y2,
      ) async {
    final bytes = await imageFile.readAsBytes();
    final image = img.decodeImage(bytes)!;

    final left = x1.clamp(0, image.width - 1).toInt();
    final top = y1.clamp(0, image.height - 1).toInt();
    final right = x2.clamp(0, image.width).toInt();
    final bottom = y2.clamp(0, image.height).toInt();

    final cropped = img.copyCrop(
      image,
      x: left,
      y: top,
      width: (right - left).abs(),
      height: (bottom - top).abs(),
    );

    final outFile = File(
      '${imageFile.parent.path}/cropped_leaf_${DateTime.now().millisecondsSinceEpoch}.png',
    );

    await outFile.writeAsBytes(img.encodePng(cropped));
    return outFile;
  }
}