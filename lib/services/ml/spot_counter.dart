import 'dart:math' as math;
import 'package:image/image.dart' as img;

class SpotCounter {

  // ===== THRESHOLD FROM NOTEBOOK =====
  // notebook used THRESHOLD = 35 for Initial/Advanced
  static const int stageThreshold = 35;

  /// Count Phyllosticta spots on a leaf image.
  /// Matches the Python notebook algorithm:
  /// 1. Convert to HSV
  /// 2. Mask white/pale/yellow pixels (low saturation, high value)
  /// 3. Morphological close + open to remove noise
  /// 4. Find contours
  /// 5. Count contours with area 8–1000 px
  static int countSpots(img.Image image) {
    try {
      // ===== RESIZE TO MATCH NOTEBOOK INPUT =====
      final img.Image resized = (image.width == 224 && image.height == 224)
          ? image
          : img.copyResize(image, width: 224, height: 224);

      final int w = resized.width;
      final int h = resized.height;

      // ===== STEP 1: BUILD HSV MASK =====
      // Python: lower=[0,0,140], upper=[180,140,255]
      // White/pale/yellow spots have:
      //   H: any (0-180)
      //   S: low saturation (0-140) — white/pale
      //   V: high brightness (140-255)
      final List<List<bool>> mask = List.generate(
          h, (_) => List.filled(w, false));

      for (int y = 0; y < h; y++) {
        for (int x = 0; x < w; x++) {
          final pixel = resized.getPixel(x, y);
          final double r = pixel.r.toDouble();
          final double g = pixel.g.toDouble();
          final double b = pixel.b.toDouble();

          // ===== RGB → HSV conversion =====
          final double rN = r / 255.0;
          final double gN = g / 255.0;
          final double bN = b / 255.0;

          final double maxC = math.max(rN, math.max(gN, bN));
          final double minC = math.min(rN, math.min(gN, bN));
          final double delta = maxC - minC;

          // H (0-180 OpenCV scale)
          double hue = 0;
          if (delta > 0) {
            if (maxC == rN) {
              hue = 60 * (((gN - bN) / delta) % 6);
            } else if (maxC == gN) {
              hue = 60 * (((bN - rN) / delta) + 2);
            } else {
              hue = 60 * (((rN - gN) / delta) + 4);
            }
          }
          if (hue < 0) hue += 360;
          final double hOcv = hue / 2; // OpenCV: H in [0,180]

          // S (0-255 OpenCV scale)
          final double sat = maxC > 0 ? (delta / maxC) * 255.0 : 0;

          // V (0-255 OpenCV scale)
          final double val = maxC * 255.0;

          // ===== APPLY MASK: matches Python lower/upper =====
          // H: 0-180, S: 0-140, V: 140-255
          if (hOcv >= 0 && hOcv <= 180 &&
              sat >= 0 && sat <= 140 &&
              val >= 140 && val <= 255) {
            mask[y][x] = true;
          }
        }
      }

      // ===== STEP 2: MORPHOLOGICAL CLOSE (3x3 kernel) =====
      // Fills small gaps inside spots
      final List<List<bool>> closed = _morphClose(mask, w, h, 3);

      // ===== STEP 3: MORPHOLOGICAL OPEN (3x3 kernel) =====
      // Removes noise/small isolated pixels
      final List<List<bool>> opened = _morphOpen(closed, w, h, 3);

      // ===== STEP 4: FIND CONTOURS (connected components) =====
      final List<int> areas = _findContourAreas(opened, w, h);

      // ===== STEP 5: COUNT SPOTS with area 8–1000 =====
      // Matches Python: if 8 < area < 1000
      int spotCount = 0;
      for (final area in areas) {
        if (area > 8 && area < 1000) {
          spotCount++;
        }
      }

      return spotCount;
    } catch (e) {
      return 0;
    }
  }

  // ===== MORPHOLOGICAL EROSION =====
  static List<List<bool>> _erode(
      List<List<bool>> src, int w, int h, int kSize) {
    final int r = kSize ~/ 2;
    final result = List.generate(h, (_) => List.filled(w, false));
    for (int y = 0; y < h; y++) {
      for (int x = 0; x < w; x++) {
        bool allTrue = true;
        outer:
        for (int ky = -r; ky <= r; ky++) {
          for (int kx = -r; kx <= r; kx++) {
            final ny = y + ky;
            final nx = x + kx;
            if (ny < 0 || ny >= h || nx < 0 || nx >= w ||
                !src[ny][nx]) {
              allTrue = false;
              break outer;
            }
          }
        }
        result[y][x] = allTrue;
      }
    }
    return result;
  }

  // ===== MORPHOLOGICAL DILATION =====
  static List<List<bool>> _dilate(
      List<List<bool>> src, int w, int h, int kSize) {
    final int r = kSize ~/ 2;
    final result = List.generate(h, (_) => List.filled(w, false));
    for (int y = 0; y < h; y++) {
      for (int x = 0; x < w; x++) {
        bool anyTrue = false;
        outer:
        for (int ky = -r; ky <= r; ky++) {
          for (int kx = -r; kx <= r; kx++) {
            final ny = y + ky;
            final nx = x + kx;
            if (ny >= 0 && ny < h && nx >= 0 && nx < w &&
                src[ny][nx]) {
              anyTrue = true;
              break outer;
            }
          }
        }
        result[y][x] = anyTrue;
      }
    }
    return result;
  }

  // ===== MORPHOLOGICAL CLOSE = dilate → erode =====
  static List<List<bool>> _morphClose(
      List<List<bool>> src, int w, int h, int kSize) {
    return _erode(_dilate(src, w, h, kSize), w, h, kSize);
  }

  // ===== MORPHOLOGICAL OPEN = erode → dilate =====
  static List<List<bool>> _morphOpen(
      List<List<bool>> src, int w, int h, int kSize) {
    return _dilate(_erode(src, w, h, kSize), w, h, kSize);
  }

  // ===== CONNECTED COMPONENTS → AREA LIST =====
  // Equivalent to cv2.findContours areas
  static List<int> _findContourAreas(
      List<List<bool>> mask, int w, int h) {
    final List<List<bool>> visited =
    List.generate(h, (_) => List.filled(w, false));
    final List<int> areas = [];

    for (int y = 0; y < h; y++) {
      for (int x = 0; x < w; x++) {
        if (mask[y][x] && !visited[y][x]) {
          // BFS flood fill to find component size
          int area = 0;
          final queue = <List<int>>[[y, x]];
          visited[y][x] = true;

          while (queue.isNotEmpty) {
            final cur = queue.removeAt(0);
            final cy = cur[0];
            final cx = cur[1];
            area++;

            // 4-connected neighbors
            for (final d in [
              [-1, 0], [1, 0], [0, -1], [0, 1]
            ]) {
              final ny = cy + d[0];
              final nx = cx + d[1];
              if (ny >= 0 && ny < h &&
                  nx >= 0 && nx < w &&
                  mask[ny][nx] &&
                  !visited[ny][nx]) {
                visited[ny][nx] = true;
                queue.add([ny, nx]);
              }
            }
          }
          areas.add(area);
        }
      }
    }
    return areas;
  }
}