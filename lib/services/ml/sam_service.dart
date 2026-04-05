import 'dart:io';
import 'package:image/image.dart' as img;

class SamService {

  /// 🔥 Generate leaf mask locally (NO backend needed)
  static Future<img.Image> getLeafMask(File imageFile) async {
    final bytes = await imageFile.readAsBytes();
    final img.Image? original = img.decodeImage(bytes);

    if (original == null) {
      throw Exception("Image decode failed");
    }

    final img.Image resized = img.copyResize(
      original,
      width: 224,
      height: 224,
    );

    final img.Image mask =
    img.Image(width: 224, height: 224);

    for (int y = 0; y < 224; y++) {
      for (int x = 0; x < 224; x++) {

        final pixel = resized.getPixel(x, y);

        final r = pixel.r;
        final g = pixel.g;
        final b = pixel.b;

        // ===== LEAF DETECTION =====
        // green OR yellow OR brown (disease)
        final isLeaf =
            (g > 40) &&                 // not dark
                (g >= r * 0.6) &&           // green/yellow
                (g >= b * 0.6);

        if (isLeaf) {
          mask.setPixelRgb(x, y, 255, 255, 255); // white
        } else {
          mask.setPixelRgb(x, y, 0, 0, 0); // black
        }
      }
    }

    return mask;
  }
}