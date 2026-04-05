import 'dart:io';
import 'package:image/image.dart' as img;

/// Utility to check image sharpness / blur
/// Uses variance of luminance (focus measure)
class ImageQuality {
  /// Returns true if image is considered blurred
  static bool isBlurred(File file) {
    try {
      final bytes = file.readAsBytesSync();
      final img.Image? image = img.decodeImage(bytes);

      if (image == null) return true;

      double sum = 0.0;
      double sumSq = 0.0;
      int count = 0;

      // Skip borders for stability
      for (int y = 1; y < image.height - 1; y++) {
        for (int x = 1; x < image.width - 1; x++) {
          final pixel = image.getPixel(x, y);

          // Convert to luminance (0–255)
          final luminance = img.getLuminance(pixel).toDouble();

          sum += luminance;
          sumSq += luminance * luminance;
          count++;
        }
      }

      if (count == 0) return true;

      final mean = sum / count;
      final variance = (sumSq / count) - (mean * mean);

      // Tuned threshold for mobile leaf images
      // Lower variance = more blur
      return variance < 150;
    } catch (e) {
      // Any decoding/IO error → treat as bad image
      return true;
    }
  }
}