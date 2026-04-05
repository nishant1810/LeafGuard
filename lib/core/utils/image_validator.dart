import 'dart:io';
import 'dart:typed_data';
import 'package:image/image.dart' as img;

/// Validates whether an image file is usable for ML processing
class ImageValidator {
  /// If [relaxed] = true → allows small cropped images (SAM / manual selection)
  static Future<bool> isValidImage(
      File image, {
        bool relaxed = false,
      }) async {
    try {
      // 1️⃣ File existence
      if (!await image.exists()) return false;

      // 2️⃣ File size
      final int bytes = await image.length();

      if (!relaxed) {
        // Strict check (camera / gallery)
        if (bytes < 5 * 1024 || bytes > 10 * 1024 * 1024) {
          return false;
        }
      } else {
        // Relaxed check (cropped leaf)
        if (bytes < 500) return false;
      }

      // 3️⃣ Supported formats
      final String path = image.path.toLowerCase();
      if (!(path.endsWith('.jpg') ||
          path.endsWith('.jpeg') ||
          path.endsWith('.png'))) {
        return false;
      }

      // 4️⃣ Decode image
      final Uint8List data = await image.readAsBytes();
      final img.Image? decoded = img.decodeImage(data);
      if (decoded == null) return false;

      // 5️⃣ Dimension check
      if (!relaxed) {
        if (decoded.width < 128 || decoded.height < 128) return false;
      } else {
        // Allow small crops
        if (decoded.width < 32 || decoded.height < 32) return false;
      }

      return true;
    } catch (_) {
      return false;
    }
  }
}