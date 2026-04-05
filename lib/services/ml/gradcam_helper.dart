import 'dart:math' as math;
import 'package:image/image.dart' as img;
import 'tflite_service.dart';

class GradCAMHelper {

  static List<int> generateHeatmap({
    required GradCAMOutput output,
    required int classIndex,
    required img.Image originalImage,
    required img.Image leafMask,
  }) {

    final int width = originalImage.width;
    final int height = originalImage.height;

    final img.Image source = img.copyResize(
      originalImage,
      width: width,
      height: height,
    );

    final img.Image mask = img.copyResize(
      leafMask,
      width: width,
      height: height,
    );

    final img.Image result =
    img.Image(width: width, height: height);

    const double alpha = 0.55; // smoother blending

    for (int y = 1; y < height - 1; y++) {
      for (int x = 1; x < width - 1; x++) {

        final maskPixel = mask.getPixel(x, y);
        final p = source.getPixel(x, y);

        // ===== REMOVE BACKGROUND =====
        if (maskPixel.r < 128) {
          result.setPixelRgb(x, y, 0, 0, 0);
          continue;
        }

        final r = p.r.toDouble();
        final g = p.g.toDouble();
        final b = p.b.toDouble();

        // ===== MAIN SCORE =====
        final brightness = (r + g + b) / 3.0;

        // reduce green dominance
        final greenFactor = 1.0 - (g / (r + g + b + 1));

        double score =
            (brightness / 255.0) * greenFactor;

        // 🔥 strong contrast
        score = math.pow(score, 2.2).toDouble();

        // 🔥 boost values
        score = (score * 3.5).clamp(0.0, 1.0);

        // ===== NATURAL HEATMAP COLOR =====
        final heat = _naturalHeat(score);

        final rr = ((1 - alpha) * p.r + alpha * heat.r).round();
        final gg = ((1 - alpha) * p.g + alpha * heat.g).round();
        final bb = ((1 - alpha) * p.b + alpha * heat.b).round();

        result.setPixelRgb(x, y, rr, gg, bb);
      }
    }

    return img.encodePng(result);
  }

  // ===== NATURAL COLORMAP (GREEN → YELLOW → ORANGE → RED) =====
  static _RGB _naturalHeat(double t) {
    final v = t.clamp(0.0, 1.0);

    double r, g, b;

    if (v < 0.4) {
      // green → yellow
      r = v / 0.4;
      g = 1.0;
      b = 0.0;
    } else if (v < 0.7) {
      // yellow → orange
      r = 1.0;
      g = 1.0 - (v - 0.4) / 0.3 * 0.5;
      b = 0.0;
    } else {
      // orange → red
      r = 1.0;
      g = 0.5 - (v - 0.7) / 0.3 * 0.5;
      b = 0.0;
    }

    return _RGB(
      (r * 255).round(),
      (g * 255).round(),
      (b * 255).round(),
    );
  }
}

class _RGB {
  final int r, g, b;
  const _RGB(this.r, this.g, this.b);
}