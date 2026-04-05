import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image/image.dart' as img;

import '../../core/localization/app_language.dart';
import '../../core/localization/app_strings.dart';

class SamInteractionScreen extends StatefulWidget {
  final File imageFile;

  const SamInteractionScreen({
    super.key,
    required this.imageFile,
  });

  @override
  State<SamInteractionScreen> createState() =>
      _SamInteractionScreenState();
}

class _SamInteractionScreenState extends State<SamInteractionScreen> {
  Offset? tapPoint;
  Offset? boxStart;
  Offset? boxEnd;
  bool autoSegmentation = true;

  late img.Image decodedImage;

  @override
  void initState() {
    super.initState();
    decodedImage =
    img.decodeImage(widget.imageFile.readAsBytesSync())!;
  }

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<AppLanguage>(
      valueListenable: appLanguage,
      builder: (_, lang, __) {
        final strings = AppStrings.of(lang);

        return Scaffold(
          backgroundColor: const Color(0xFF0A0A0A),
          appBar: AppBar(
            backgroundColor: Colors.green.shade700,
            elevation: 0,
            iconTheme: const IconThemeData(color: Colors.white),
            title: Text(
              strings.leafSegmentation,
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),

          body: Column(
            children: [

              // ===== MODE BANNER =====
              AnimatedContainer(
                duration: const Duration(milliseconds: 300),
                width: double.infinity,
                padding: const EdgeInsets.symmetric(
                    horizontal: 16, vertical: 10),
                color: autoSegmentation
                    ? Colors.green.shade900.withValues(alpha: 0.6)
                    : Colors.orange.shade900.withValues(alpha: 0.6),
                child: Row(
                  children: [
                    Icon(
                      autoSegmentation
                          ? Icons.auto_fix_high
                          : Icons.touch_app,
                      color: Colors.white70,
                      size: 16,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      autoSegmentation
                          ? 'Auto mode — tap Apply to proceed'
                          : 'Manual mode — tap or draw a box on the leaf',
                      style: const TextStyle(
                        color: Colors.white70,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),

              // ===== IMAGE AREA =====
              Expanded(child: _buildImageArea()),

              // ===== CONTROLS =====
              _buildControls(strings),
            ],
          ),
        );
      },
    );
  }

  // ================= IMAGE + GESTURE =================
  Widget _buildImageArea() {
    return LayoutBuilder(
      builder: (context, constraints) {
        return GestureDetector(
          onTapDown: (d) {
            if (!autoSegmentation) {
              setState(() {
                tapPoint = d.localPosition;
                boxStart = null;
                boxEnd   = null;
              });
            }
          },
          onPanStart: (d) {
            if (!autoSegmentation) {
              setState(() {
                boxStart = d.localPosition;
                boxEnd   = null;
                tapPoint = null;
              });
            }
          },
          onPanUpdate: (d) {
            if (!autoSegmentation && boxStart != null) {
              setState(() => boxEnd = d.localPosition);
            }
          },
          child: Stack(
            children: [

              // ===== IMAGE =====
              Positioned.fill(
                child: Padding(
                  padding: const EdgeInsets.all(12),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(16),
                    child: Image.file(
                      widget.imageFile,
                      fit: BoxFit.contain,
                      width: constraints.maxWidth,
                      height: constraints.maxHeight,
                    ),
                  ),
                ),
              ),

              // ===== TAP POINT INDICATOR =====
              if (tapPoint != null)
                Positioned(
                  left: tapPoint!.dx - 16,
                  top:  tapPoint!.dy - 16,
                  child: Container(
                    width: 32, height: 32,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(
                          color: Colors.orange, width: 2),
                      color: Colors.orange.withValues(alpha: 0.3),
                    ),
                    child: const Icon(
                      Icons.add,
                      color: Colors.orange,
                      size: 16,
                    ),
                  ),
                ),

              // ===== BOUNDING BOX =====
              if (boxStart != null && boxEnd != null)
                Positioned.fromRect(
                  rect: Rect.fromPoints(boxStart!, boxEnd!),
                  child: Container(
                    decoration: BoxDecoration(
                      border: Border.all(
                        color: Colors.orange,
                        width: 2,
                      ),
                      color: Colors.orange.withValues(alpha: 0.08),
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ),
                ),

              // ===== MANUAL MODE HINT =====
              if (!autoSegmentation &&
                  tapPoint == null &&
                  boxStart == null)
                Positioned(
                  bottom: 24,
                  left: 0, right: 0,
                  child: Center(
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 14, vertical: 8),
                      decoration: BoxDecoration(
                        color: Colors.black54,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: const Text(
                        'Tap to select a point  •  Drag to draw a box',
                        style: TextStyle(
                          color: Colors.white70,
                          fontSize: 12,
                        ),
                      ),
                    ),
                  ),
                ),
            ],
          ),
        );
      },
    );
  }

  // ================= CONTROLS =================
  Widget _buildControls(AppStrings strings) {
    return SafeArea(
      top: false,
      child: Container(
        padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
        decoration: BoxDecoration(
          color: const Color(0xFF1A1A1A),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.3),
              blurRadius: 10,
              offset: const Offset(0, -2),
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [

            // ===== AUTO SEGMENTATION TOGGLE =====
            Container(
              padding: const EdgeInsets.symmetric(
                  horizontal: 14, vertical: 4),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.05),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.white12),
              ),
              child: Row(
                children: [
                  Icon(
                    autoSegmentation
                        ? Icons.auto_fix_high
                        : Icons.touch_app_outlined,
                    color: autoSegmentation
                        ? Colors.greenAccent
                        : Colors.orange,
                    size: 20,
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          strings.autoSegmentation,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        Text(
                          autoSegmentation
                              ? 'Full image will be analyzed'
                              : 'Tap or drag to select region',
                          style: const TextStyle(
                            color: Colors.white38,
                            fontSize: 11,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Switch(
                    value: autoSegmentation,
                    activeColor: Colors.greenAccent,
                    activeTrackColor:
                    Colors.green.withValues(alpha: 0.4),
                    inactiveThumbColor: Colors.orange,
                    inactiveTrackColor:
                    Colors.orange.withValues(alpha: 0.3),
                    onChanged: (v) {
                      setState(() {
                        autoSegmentation = v;
                        tapPoint  = null;
                        boxStart  = null;
                        boxEnd    = null;
                      });
                    },
                  ),
                ],
              ),
            ),

            const SizedBox(height: 12),

            // ===== APPLY BUTTON =====
            Container(
              width: double.infinity,
              height: 52,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    Colors.green.shade500,
                    Colors.green.shade800,
                  ],
                  begin: Alignment.centerLeft,
                  end: Alignment.centerRight,
                ),
                borderRadius: BorderRadius.circular(14),
                boxShadow: [
                  BoxShadow(
                    color: Colors.green.shade900
                        .withValues(alpha: 0.4),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Material(
                color: Colors.transparent,
                child: InkWell(
                  borderRadius: BorderRadius.circular(14),
                  onTap: _applySegmentation,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Container(
                        padding: const EdgeInsets.all(5),
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.2),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.check,
                          color: Colors.white,
                          size: 16,
                        ),
                      ),
                      const SizedBox(width: 10),
                      Text(
                        strings.applySegmentation,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 15,
                          fontWeight: FontWeight.w700,
                          letterSpacing: 0.3,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ================= APPLY =================
  void _applySegmentation() {
    if (autoSegmentation) {
      Navigator.pop(context, widget.imageFile);
      return;
    }

    if (tapPoint != null) {
      final cropped = _cropAroundPoint(tapPoint!, 120);
      Navigator.pop(context, cropped);
      return;
    }

    if (boxStart != null && boxEnd != null) {
      final cropped = _cropWithBox(boxStart!, boxEnd!);
      Navigator.pop(context, cropped);
      return;
    }

    final strings = AppStrings.of(appLanguage.value);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(strings.selectRegionWarning),
        backgroundColor: Colors.orange.shade700,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  // ================= IMAGE CROP =================
  File _cropWithBox(Offset p1, Offset p2) {
    final left   = p1.dx.clamp(0, decodedImage.width.toDouble()).toInt();
    final top    = p1.dy.clamp(0, decodedImage.height.toDouble()).toInt();
    final right  = p2.dx.clamp(0, decodedImage.width.toDouble()).toInt();
    final bottom = p2.dy.clamp(0, decodedImage.height.toDouble()).toInt();

    final width  = (right - left).abs().clamp(1, decodedImage.width);
    final height = (bottom - top).abs().clamp(1, decodedImage.height);

    final cropped = img.copyCrop(
      decodedImage,
      x: left, y: top,
      width: width, height: height,
    );

    final file = File(
      '${widget.imageFile.parent.path}/sam_crop_'
          '${DateTime.now().millisecondsSinceEpoch}.png',
    );
    file.writeAsBytesSync(img.encodePng(cropped));
    return file;
  }

  File _cropAroundPoint(Offset p, double radius) {
    return _cropWithBox(
      Offset(p.dx - radius, p.dy - radius),
      Offset(p.dx + radius, p.dy + radius),
    );
  }
}