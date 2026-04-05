import 'dart:io';
import 'package:image/image.dart' as img;

/// Utility to resize image to 224x224 (for ML models)
class ImageResize {
  static Future<File> to224(File imageFile) async {
    try {
      final bytes = await imageFile.readAsBytes();

      final img.Image? decoded = img.decodeImage(bytes);
      if (decoded == null) {
        throw Exception('Unable to decode image');
      }

      // Resize with interpolation (better quality)
      final img.Image resized = img.copyResize(
        decoded,
        width: 224,
        height: 224,
        interpolation: img.Interpolation.linear,
      );

      // Preserve original name with suffix
      final String newPath =
          '${imageFile.parent.path}/${imageFile.uri.pathSegments.last.split('.').first}_224.png';

      final File outFile = File(newPath);

      await outFile.writeAsBytes(
        img.encodePng(resized),
        flush: true,
      );

      return outFile;
    } catch (e) {
      // Fail-safe: return original image if resizing fails
      return imageFile;
    }
  }
}