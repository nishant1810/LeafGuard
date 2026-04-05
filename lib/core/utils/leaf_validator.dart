import 'package:image/image.dart' as img;

/// Leaf validation using green-dominance + texture heuristic
///
/// Purpose:
/// 1) Reject non-leaf objects (hands, devices, soil, paper, etc.)
/// 2) Allow leaf-like regions to proceed to ML model
///
/// NOTE:
/// This does NOT guarantee the leaf is cardamom.
/// Final confirmation is done by the ML classifier.
class LeafValidator {
  /// Returns true if image is likely a leaf
  static bool isLikelyLeaf(img.Image image) {
    int greenPixels = 0;
    int texturePixels = 0;
    int totalSamples = 0;

    // Sample pixels (performance-friendly)
    for (int y = 0; y < image.height; y += 4) {
      for (int x = 0; x < image.width; x += 4) {
        final pixel = image.getPixel(x, y);

        final int r = pixel.r.toInt();
        final int g = pixel.g.toInt();
        final int b = pixel.b.toInt();

        // 1️⃣ Green dominance check
        if (g > r + 20 && g > b + 20) {
          greenPixels++;
        }

        // 2️⃣ Texture / vein presence (reject flat green objects)
        if ((r - g).abs() + (g - b).abs() > 30) {
          texturePixels++;
        }

        totalSamples++;
      }
    }

    // Safety check
    if (totalSamples == 0) return false;

    final double greenRatio = greenPixels / totalSamples;
    final double textureRatio = texturePixels / totalSamples;

    // ✅ Tuned thresholds for leaf-like images
    return greenRatio > 0.30 && textureRatio > 0.12;
  }
}