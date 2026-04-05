import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:image/image.dart' as img;

import '../../core/models/scan_result.dart';
import '../../services/scan_storage.dart';
import '../../services/ml/tflite_service.dart';
import '../../services/ml/sam_service.dart';
import '../../services/ml/gradcam_helper.dart';
import '../../core/localization/app_language.dart';
import '../../core/localization/app_strings.dart';
import '../camera/camera_screen.dart';
import '../camera/full_image_viewer.dart';
import '../../widgets/agri_helpline_button.dart';
import '../../widgets/confidence_bar.dart';

class ResultScreen extends StatefulWidget {
  final ScanResult result;
  const ResultScreen({super.key, required this.result});

  @override
  State<ResultScreen> createState() => _ResultScreenState();
}

class _ResultScreenState extends State<ResultScreen> {
  bool       _saved             = false;
  bool       _showHeatmap       = false;
  Uint8List? _heatmapBytes;
  bool       _generatingHeatmap = false;

  static const double reliableThreshold  = 0.75;
  static const double uncertainThreshold = 0.60;

  bool get isUncertain => widget.result.confidence < uncertainThreshold;
  bool get isReliable  => widget.result.confidence >= reliableThreshold;
  bool get isHealthy   =>
      isReliable && widget.result.disease.toLowerCase().contains('healthy');
  bool get isPhyllo    =>
      widget.result.disease.toLowerCase().contains('phyllosticta');

  // ===== CHECK BOTH SOURCES =====
  bool get hasHeatmap =>
      (_heatmapBytes != null && _heatmapBytes!.length > 100) ||
          (widget.result.heatmapBytes != null &&
              widget.result.heatmapBytes!.length > 100);

  // ===== USE LOCAL OR RESULT HEATMAP =====
  Uint8List? get _activeHeatmap =>
      _heatmapBytes ?? widget.result.heatmapBytes;

  @override
  void initState() {
    super.initState();
    _saveResult();
    // ✅ Regenerate heatmap if not available (history scan)
    if (!hasHeatmap) {
      _regenerateHeatmap();
    }
  }

  Future<void> _saveResult() async {
    if (_saved) return;
    await ScanStorage.saveScan(widget.result);
    _saved = true;
  }


  // ================= REGENERATE HEATMAP =================
  Future<void> _regenerateHeatmap() async {
    if (_generatingHeatmap) return;
    if (mounted) setState(() => _generatingHeatmap = true);

    try {
      final File imageFile = File(widget.result.imagePath);
      if (!imageFile.existsSync()) return;

      final img.Image? decoded =
      img.decodeImage(await imageFile.readAsBytes());
      if (decoded == null) return;

      final img.Image resized =
      img.copyResize(decoded, width: 224, height: 224);

      // Try real GradCAM model first
      final GradCAMOutput? realOutput =
      await TFLiteService.runGradCam(imageFile);

      GradCAMOutput gradcamOutput;
      if (realOutput != null) {
        gradcamOutput = realOutput;
      } else {
        // Fallback pixel approximation
        const int H = 7, W = 7, C = 1280;
        final featureMap = List.generate(
          H,
              (h) => List.generate(
            W,
                (w) => List.generate(
              C,
                  (c) {
                final px = (w * resized.width ~/ W)
                    .clamp(0, resized.width - 1);
                final py = (h * resized.height ~/ H)
                    .clamp(0, resized.height - 1);
                final pixel  = resized.getPixel(px, py);
                final base   =
                    (pixel.r * 0.299 +
                        pixel.g * 0.587 +
                        pixel.b * 0.114) /
                        255.0;
                return base * (1.0 + (c % 10) * 0.01);
              },
            ),
          ),
        );
        gradcamOutput = GradCAMOutput(
          featureMap:  featureMap,
          predictions: [0.0, 0.0, 0.0],
        );
      }

      final disease    = widget.result.disease.toLowerCase();
      final classIndex = disease.contains('blight')
          ? 0
          : disease.contains('healthy')
          ? 1
          : 2;

      // ===== GET MASK (FIX) =====
      final img.Image mask =
      await SamService.getLeafMask(imageFile);

      final List<int> heatmap = GradCAMHelper.generateHeatmap(
        output: gradcamOutput,
        classIndex: classIndex,
        originalImage: resized,
        leafMask: mask,
      );

      if (mounted) {
        setState(() {
          _heatmapBytes      = Uint8List.fromList(heatmap);
          _generatingHeatmap = false;
        });
      }
    } catch (e) {
      if (mounted) setState(() => _generatingHeatmap = false);
    }
  }

  String _localizedDiseaseName(String disease, AppStrings strings) {
    final d = disease.toLowerCase();
    if (d.contains('blight'))       return strings.blight;
    if (d.contains('phyllosticta')) return strings.phyllosticta;
    if (d.contains('healthy'))      return strings.healthyLeaf;
    return disease;
  }

  void _onHeatmapTap() {
    if (hasHeatmap) {
      setState(() => _showHeatmap = !_showHeatmap);
    } else if (_generatingHeatmap) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Row(
            children: [
              SizedBox(
                width: 14, height: 14,
                child: CircularProgressIndicator(
                    strokeWidth: 2, color: Colors.white),
              ),
              SizedBox(width: 8),
              Text('Generating heatmap...'),
            ],
          ),
          backgroundColor: Colors.grey.shade800,
          duration: const Duration(seconds: 2),
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10)),
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Row(
            children: [
              Icon(Icons.info_outline, color: Colors.white, size: 16),
              SizedBox(width: 8),
              Text('Heatmap not available for this scan'),
            ],
          ),
          backgroundColor: Colors.grey.shade800,
          duration: const Duration(seconds: 2),
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10)),
        ),
      );
    }
  }

  Color get _statusColor => isUncertain
      ? const Color(0xFFFF9800)
      : isHealthy
      ? const Color(0xFF4CAF50)
      : const Color(0xFFE53935);

  IconData get _statusIcon => isUncertain
      ? Icons.help_outline_rounded
      : isHealthy
      ? Icons.verified_rounded
      : Icons.warning_amber_rounded;

  String _formatDate(DateTime t) =>
      '${t.day}/${t.month}/${t.year}  '
          '${t.hour.toString().padLeft(2, '0')}:'
          '${t.minute.toString().padLeft(2, '0')}';

  @override
  Widget build(BuildContext context) {
    final File imageFile = File(widget.result.imagePath);

    return ValueListenableBuilder<AppLanguage>(
      valueListenable: appLanguage,
      builder: (_, lang, __) {
        final strings     = AppStrings.of(lang);
        final statusColor = _statusColor;

        final String diseaseLabel = isUncertain
            ? strings.uncertain
            : _localizedDiseaseName(widget.result.disease, strings);

        final List<String> recommendations =
        strings.recommendations(widget.result.disease, isUncertain);

        return Scaffold(
          backgroundColor: const Color(0xFF0A1A0D),
          appBar: AppBar(
            backgroundColor: Colors.green.shade800,
            elevation: 0,
            title: Text(
              strings.leafHealthReport,
              style: const TextStyle(
                fontWeight: FontWeight.w700,
                fontSize: 17,
                color: Colors.white,
              ),
            ),
            leading: IconButton(
              icon: const Icon(Icons.arrow_back, color: Colors.white),
              onPressed: () => Navigator.pop(context),
            ),
            actions: [
              IconButton(
                icon: const Icon(Icons.camera_alt_outlined,
                    color: Colors.white, size: 22),
                tooltip: 'New Scan',
                onPressed: () => Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(
                      builder: (_) => const CameraScreen()),
                ),
              ),
            ],
          ),

          body: SafeArea(
            top: false,
            child: SingleChildScrollView(
              padding: EdgeInsets.fromLTRB(
                  16, 16, 16,
                  MediaQuery.of(context).padding.bottom + 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [

                  // ===== IMAGE / HEATMAP =====
                  Stack(
                    children: [
                      GestureDetector(
                        onTap: () => Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => FullImageViewer(
                                imagePath: imageFile.path,
                              heatmapBytes: _activeHeatmap, // ✅ pass heatmap
                            ),
                          ),
                        ),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(20),
                          child: _showHeatmap && hasHeatmap
                              ? Image.memory(
                            _activeHeatmap!,
                            height: 230,
                            width: double.infinity,
                            fit: BoxFit.cover,
                          )
                              : Image.file(
                            imageFile,
                            height: 230,
                            width: double.infinity,
                            fit: BoxFit.cover,
                          ),
                        ),
                      ),

                      // ===== HEATMAP TOGGLE =====
                      Positioned(
                        top: 10, right: 10,
                        child: GestureDetector(
                          onTap: _onHeatmapTap,
                          child: AnimatedContainer(
                            duration: const Duration(milliseconds: 200),
                            padding: const EdgeInsets.symmetric(
                                horizontal: 10, vertical: 6),
                            decoration: BoxDecoration(
                              color: Colors.black.withValues(alpha: 0.6),
                              borderRadius: BorderRadius.circular(20),
                              border: Border.all(
                                color: hasHeatmap
                                    ? Colors.white30
                                    : _generatingHeatmap
                                    ? Colors.orange.withValues(alpha: 0.4)
                                    : Colors.white12,
                                width: 0.5,
                              ),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                // ===== ICON =====
                                _generatingHeatmap
                                    ? const SizedBox(
                                  width: 14, height: 14,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 1.5,
                                    color: Colors.orange,
                                  ),
                                )
                                    : Icon(
                                  _showHeatmap
                                      ? Icons.image_outlined
                                      : Icons.thermostat_outlined,
                                  color: hasHeatmap
                                      ? Colors.white
                                      : Colors.white38,
                                  size: 14,
                                ),
                                const SizedBox(width: 5),
                                // ===== LABEL =====
                                Text(
                                  _showHeatmap
                                      ? 'Original'
                                      : _generatingHeatmap
                                      ? 'Generating...'
                                      : hasHeatmap
                                      ? 'Heatmap'
                                      : 'No heatmap',
                                  style: TextStyle(
                                    color: _generatingHeatmap
                                        ? Colors.orange
                                        : hasHeatmap
                                        ? Colors.white
                                        : Colors.white38,
                                    fontSize: 11,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),

                      // ===== TIMESTAMP BADGE =====
                      Positioned(
                        bottom: 10, left: 10,
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            color: Colors.black.withValues(alpha: 0.6),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Icon(Icons.access_time,
                                  color: Colors.white54, size: 11),
                              const SizedBox(width: 4),
                              Text(
                                _formatDate(widget.result.timestamp),
                                style: const TextStyle(
                                  color: Colors.white60,
                                  fontSize: 10,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 16),

                  // ===== STATUS CARD =====
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: statusColor.withValues(alpha: 0.08),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: statusColor.withValues(alpha: 0.35),
                        width: 1,
                      ),
                    ),
                    child: Row(
                      children: [
                        Container(
                          width: 48, height: 48,
                          decoration: BoxDecoration(
                            color: statusColor.withValues(alpha: 0.15),
                            shape: BoxShape.circle,
                            border: Border.all(
                              color: statusColor.withValues(alpha: 0.4),
                              width: 1,
                            ),
                          ),
                          child: Icon(
                            _statusIcon,
                            color: statusColor,
                            size: 24,
                          ),
                        ),
                        const SizedBox(width: 14),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Container(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 8, vertical: 2),
                                decoration: BoxDecoration(
                                  color: statusColor.withValues(alpha: 0.15),
                                  borderRadius: BorderRadius.circular(20),
                                ),
                                child: Text(
                                  isUncertain
                                      ? 'UNCERTAIN'
                                      : isHealthy
                                      ? 'HEALTHY'
                                      : 'DISEASE DETECTED',
                                  style: TextStyle(
                                    fontSize: 9,
                                    fontWeight: FontWeight.w800,
                                    color: statusColor,
                                    letterSpacing: 1.0,
                                  ),
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                isUncertain
                                    ? strings.uncertainMessage
                                    : diseaseLabel,
                                style: const TextStyle(
                                  fontSize: 15,
                                  fontWeight: FontWeight.w700,
                                  color: Colors.white,
                                  height: 1.2,
                                ),
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 12),

                  // ===== STAGE + AREA + SPOTS =====
                  if (!isUncertain && !isHealthy)
                    Container(
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        color: const Color(0xFF132218),
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(
                          color: Colors.white.withValues(alpha: 0.08),
                        ),
                      ),
                      child: Column(
                        children: [
                          _InfoRow(
                            icon: Icons.flag_outlined,
                            label: 'Stage',
                            value: widget.result.stage,
                            valueColor:
                            widget.result.stage == 'Initial Stage'
                                ? const Color(0xFFFF9800)
                                : const Color(0xFFE53935),
                          ),
                          _Divider(),
                          _InfoRow(
                            icon: Icons.area_chart_outlined,
                            label: 'Affected area',
                            value:
                            '${(widget.result.affectedArea * 100).toStringAsFixed(1)}%',
                            valueColor: Colors.white70,
                          ),
                          if (isPhyllo &&
                              widget.result.spotCount != null) ...[
                            _Divider(),
                            _InfoRow(
                              icon: Icons.blur_on,
                              label: 'Spot count',
                              value: '${widget.result.spotCount} spots',
                              valueColor: Colors.redAccent.shade100,
                            ),
                          ],
                        ],
                      ),
                    ),

                  const SizedBox(height: 12),

                  // ===== CONFIDENCE BAR =====
                  ConfidenceBar(confidence: widget.result.confidence),

                  const SizedBox(height: 12),

                  // ===== RECOMMENDATIONS =====
                  if (recommendations.isNotEmpty)
                    Container(
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        color: const Color(0xFF132218),
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(
                          color: statusColor.withValues(alpha: 0.25),
                        ),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Container(
                                width: 28, height: 28,
                                decoration: BoxDecoration(
                                  color: statusColor.withValues(alpha: 0.15),
                                  shape: BoxShape.circle,
                                ),
                                child: Icon(
                                  isHealthy
                                      ? Icons.spa_outlined
                                      : Icons.medical_services_outlined,
                                  color: statusColor,
                                  size: 14,
                                ),
                              ),
                              const SizedBox(width: 10),
                              Text(
                                isHealthy
                                    ? strings.careTips
                                    : isUncertain
                                    ? strings.suggestions
                                    : strings.recommendedActions,
                                style: TextStyle(
                                  fontSize: 13,
                                  fontWeight: FontWeight.w700,
                                  color: statusColor,
                                  letterSpacing: 0.3,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 12),
                          ...recommendations.asMap().entries.map(
                                (entry) => Padding(
                              padding: const EdgeInsets.only(bottom: 8),
                              child: Row(
                                crossAxisAlignment:
                                CrossAxisAlignment.start,
                                children: [
                                  Container(
                                    width: 20, height: 20,
                                    margin: const EdgeInsets.only(
                                        top: 1, right: 8),
                                    decoration: BoxDecoration(
                                      color: statusColor
                                          .withValues(alpha: 0.15),
                                      shape: BoxShape.circle,
                                    ),
                                    child: Center(
                                      child: Text(
                                        '${entry.key + 1}',
                                        style: TextStyle(
                                          color: statusColor,
                                          fontSize: 9,
                                          fontWeight: FontWeight.w700,
                                        ),
                                      ),
                                    ),
                                  ),
                                  Expanded(
                                    child: Text(
                                      entry.value,
                                      style: const TextStyle(
                                        color: Colors.white70,
                                        fontSize: 12,
                                        height: 1.4,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),

                  const SizedBox(height: 12),

                  // ===== AGRI HELPLINE =====
                  const AgriHelplineButton(),

                  const SizedBox(height: 8),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}

// ================= DIVIDER =================
class _Divider extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      height: 1,
      margin: const EdgeInsets.symmetric(vertical: 10),
      color: Colors.white.withValues(alpha: 0.06),
    );
  }
}

// ================= INFO ROW =================
class _InfoRow extends StatelessWidget {
  final IconData icon;
  final String   label;
  final String   value;
  final Color    valueColor;

  const _InfoRow({
    required this.icon,
    required this.label,
    required this.value,
    required this.valueColor,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 28, height: 28,
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.05),
            shape: BoxShape.circle,
          ),
          child: Icon(icon, color: Colors.white38, size: 14),
        ),
        const SizedBox(width: 10),
        Text(label,
            style: const TextStyle(
                color: Colors.white54, fontSize: 13)),
        const Spacer(),
        Container(
          padding: const EdgeInsets.symmetric(
              horizontal: 10, vertical: 3),
          decoration: BoxDecoration(
            color: valueColor.withValues(alpha: 0.12),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: valueColor.withValues(alpha: 0.3),
              width: 0.5,
            ),
          ),
          child: Text(
            value,
            style: TextStyle(
              color: valueColor,
              fontSize: 12,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ],
    );
  }
}