import 'dart:io';
import 'package:flutter/material.dart';

import '../../core/localization/app_language.dart';
import '../../core/localization/app_strings.dart';
import '../../core/models/scan_result.dart';
import '../../services/model_service.dart';
import '../result/result_screen.dart';
import '../../widgets/loading_overlay.dart';
import 'sam_interaction_screen.dart';

class ImagePreviewScreen extends StatefulWidget {
  final File imageFile;

  const ImagePreviewScreen({
    super.key,
    required this.imageFile,
  });

  @override
  State<ImagePreviewScreen> createState() => _ImagePreviewScreenState();
}

class _ImagePreviewScreenState extends State<ImagePreviewScreen> {
  bool _isProcessing = false;

  Future<void> _analyzeImage(File imageToAnalyze) async {
    if (_isProcessing) return;
    setState(() => _isProcessing = true);

    try {
      final ScanResult result =
      await ModelService.runPipeline(imageToAnalyze);

      if (!mounted) return;

      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (_) => ResultScreen(result: result),
        ),
      );
    } catch (e) {
      if (!mounted) return;

      final strings = AppStrings.of(appLanguage.value);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: [
              const Icon(Icons.error_outline,
                  color: Colors.white, size: 16),
              const SizedBox(width: 8),
              Expanded(
                child: Text(strings.errorMessage("default")),
              ),
            ],
          ),
          backgroundColor: Colors.red.shade700,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10)),
        ),
      );
    } finally {
      if (mounted) setState(() => _isProcessing = false);
    }
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
            backgroundColor: Colors.transparent,
            elevation: 0,
            iconTheme: const IconThemeData(color: Colors.white),
            title: Text(
              strings.previewImage,
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w600,
                fontSize: 17,
              ),
            ),
          ),

          // ===== BODY WITH OVERLAY =====
          body: Stack(
            children: [

              // ===== MAIN CONTENT =====
              Column(
                children: [

                  // ===== IMAGE =====
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 8),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(20),
                        child: Image.file(
                          widget.imageFile,
                          fit: BoxFit.contain,
                          width: double.infinity,
                        ),
                      ),
                    ),
                  ),

                  // ===== GUIDANCE TEXT =====
                  Padding(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 20, vertical: 6),
                    child: Row(
                      children: [
                        const Icon(
                          Icons.info_outline,
                          color: Colors.white38,
                          size: 14,
                        ),
                        const SizedBox(width: 6),
                        Expanded(
                          child: Text(
                            'Make sure the leaf is clearly visible before analyzing',
                            style: TextStyle(
                              color: Colors.white
                                  .withValues(alpha: 0.45),
                              fontSize: 12,
                              height: 1.3,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),

                  // ===== BUTTONS =====
                  SafeArea(
                    top: false,
                    child: Padding(
                      padding:
                      const EdgeInsets.fromLTRB(16, 8, 16, 16),
                      child: Row(
                        children: [

                          // ===== RETAKE BUTTON =====
                          Expanded(
                            flex: 2,
                            child: Container(
                              height: 52,
                              decoration: BoxDecoration(
                                borderRadius:
                                BorderRadius.circular(14),
                                border: Border.all(
                                  color: Colors.white
                                      .withValues(alpha: 0.3),
                                  width: 1.5,
                                ),
                              ),
                              child: Material(
                                color: Colors.transparent,
                                child: InkWell(
                                  borderRadius:
                                  BorderRadius.circular(14),
                                  onTap: _isProcessing
                                      ? null
                                      : () => Navigator.pop(context),
                                  child: Row(
                                    mainAxisAlignment:
                                    MainAxisAlignment.center,
                                    children: [
                                      Icon(
                                        Icons.arrow_back,
                                        color: Colors.white
                                            .withValues(alpha: 0.8),
                                        size: 18,
                                      ),
                                      const SizedBox(width: 6),
                                      Text(
                                        strings.retake,
                                        style: TextStyle(
                                          color: Colors.white
                                              .withValues(alpha: 0.8),
                                          fontWeight: FontWeight.w500,
                                          fontSize: 14,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          ),

                          const SizedBox(width: 12),

                          // ===== SELECT LEAF REGION BUTTON =====
                          Expanded(
                            flex: 3,
                            child: Container(
                              height: 52,
                              decoration: BoxDecoration(
                                gradient: LinearGradient(
                                  colors: [
                                    Colors.orange.shade500,
                                    Colors.orange.shade800,
                                  ],
                                  begin: Alignment.centerLeft,
                                  end: Alignment.centerRight,
                                ),
                                borderRadius:
                                BorderRadius.circular(14),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.orange.shade900
                                        .withValues(alpha: 0.4),
                                    blurRadius: 10,
                                    offset: const Offset(0, 4),
                                  ),
                                ],
                              ),
                              child: Material(
                                color: Colors.transparent,
                                child: InkWell(
                                  borderRadius:
                                  BorderRadius.circular(14),
                                  onTap: _isProcessing
                                      ? null
                                      : () async {
                                    final File? segmented =
                                    await Navigator.push<File?>(
                                      context,
                                      MaterialPageRoute(
                                        builder: (_) => SamInteractionScreen(
                                          imageFile: widget.imageFile,
                                        ),
                                      ),
                                    );
                                    if (segmented != null) {
                                      await _analyzeImage(segmented);
                                    }
                                  },
                                  child: Row(
                                    mainAxisAlignment:
                                    MainAxisAlignment.center,
                                    children: [
                                      Container(
                                        padding:
                                        const EdgeInsets.all(4),
                                        decoration: BoxDecoration(
                                          color: Colors.white
                                              .withValues(alpha: 0.2),
                                          shape: BoxShape.circle,
                                        ),
                                        child: const Icon(
                                          Icons.crop_free,
                                          color: Colors.white,
                                          size: 16,
                                        ),
                                      ),
                                      const SizedBox(width: 8),
                                      Flexible(
                                        child: Text(
                                          strings.selectLeafRegion,
                                          style: const TextStyle(
                                            color: Colors.white,
                                            fontWeight: FontWeight.w700,
                                            fontSize: 13,
                                          ),
                                          overflow:
                                          TextOverflow.ellipsis,
                                          maxLines: 1,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),

              // ===== LOADING OVERLAY =====
              if (_isProcessing)
                LoadingOverlay(
                  message: AppStrings.of(
                      appLanguage.value)
                      .analyzingImage,
                ),
            ],
          ),
        );
      },
    );
  }
}