import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/material.dart';

class FullImageViewer extends StatefulWidget {
  final String    imagePath;
  final Uint8List? heatmapBytes; // ✅ optional heatmap

  const FullImageViewer({
    super.key,
    required this.imagePath,
    this.heatmapBytes,
  });

  @override
  State<FullImageViewer> createState() => _FullImageViewerState();
}

class _FullImageViewerState extends State<FullImageViewer> {
  bool _showHeatmap = false;

  bool get hasHeatmap =>
      widget.heatmapBytes != null &&
          widget.heatmapBytes!.length > 100;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,

      // ===== APPBAR =====
      appBar: AppBar(
        backgroundColor: Colors.black,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.white),
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Image Preview',
              style: TextStyle(
                color: Colors.white,
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
            if (hasHeatmap)
              Text(
                _showHeatmap ? 'GradCAM Heatmap' : 'Original Image',
                style: const TextStyle(
                  color: Colors.white54,
                  fontSize: 11,
                ),
              ),
          ],
        ),
        actions: [
          // ===== HEATMAP TOGGLE BUTTON =====
          if (hasHeatmap)
            Padding(
              padding: const EdgeInsets.only(right: 8),
              child: GestureDetector(
                onTap: () => setState(
                        () => _showHeatmap = !_showHeatmap),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  padding: const EdgeInsets.symmetric(
                      horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: _showHeatmap
                        ? Colors.orange.withValues(alpha: 0.25)
                        : Colors.white.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: _showHeatmap
                          ? Colors.orange.withValues(alpha: 0.6)
                          : Colors.white24,
                      width: 1,
                    ),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        _showHeatmap
                            ? Icons.image_outlined
                            : Icons.thermostat_outlined,
                        color: _showHeatmap
                            ? Colors.orange
                            : Colors.white70,
                        size: 14,
                      ),
                      const SizedBox(width: 5),
                      Text(
                        _showHeatmap ? 'Original' : 'Heatmap',
                        style: TextStyle(
                          color: _showHeatmap
                              ? Colors.orange
                              : Colors.white70,
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
        ],
      ),

      // ===== BODY =====
      body: Stack(
        children: [

          // ===== MAIN IMAGE =====
          Center(
            child: InteractiveViewer(
              minScale: 0.5,
              maxScale: 6.0,
              panEnabled: true,
              child: AnimatedSwitcher(
                duration: const Duration(milliseconds: 300),
                child: _showHeatmap && hasHeatmap
                    ? Image.memory(
                  widget.heatmapBytes!,
                  key: const ValueKey('heatmap'),
                  width: MediaQuery.of(context).size.width,
                  fit: BoxFit.fitWidth,
                )
                    : Image.file(
                  File(widget.imagePath),
                  key: const ValueKey('original'),
                  width: MediaQuery.of(context).size.width,
                  fit: BoxFit.fitWidth,
                ),
              ),
            ),
          ),

          // ===== BOTTOM BADGE =====
          Positioned(
            bottom: 20, left: 0, right: 0,
            child: Center(
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                padding: const EdgeInsets.symmetric(
                    horizontal: 16, vertical: 6),
                decoration: BoxDecoration(
                  color: Colors.black.withValues(alpha: 0.7),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: _showHeatmap
                        ? Colors.orange.withValues(alpha: 0.4)
                        : Colors.white12,
                    width: 0.8,
                  ),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      _showHeatmap
                          ? Icons.thermostat_outlined
                          : Icons.image_outlined,
                      color: _showHeatmap
                          ? Colors.orange
                          : Colors.white54,
                      size: 13,
                    ),
                    const SizedBox(width: 6),
                    Text(
                      _showHeatmap
                          ? 'GradCAM Heatmap — Pinch to zoom'
                          : 'Original Image — Pinch to zoom',
                      style: TextStyle(
                        color: _showHeatmap
                            ? Colors.orange.withValues(alpha: 0.9)
                            : Colors.white54,
                        fontSize: 11,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),

          // ===== NO HEATMAP LABEL =====
          if (!hasHeatmap)
            Positioned(
              bottom: 20, left: 0, right: 0,
              child: Center(
                child: Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 16, vertical: 6),
                  decoration: BoxDecoration(
                    color: Colors.black.withValues(alpha: 0.7),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: const Text(
                    'Pinch to zoom • Tap & drag to pan',
                    style: TextStyle(
                      color: Colors.white38,
                      fontSize: 11,
                    ),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}