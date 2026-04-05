import 'dart:io';
import 'dart:async';
import 'package:flutter/material.dart';

import '../../services/model_service.dart';
import '../../services/scan_storage.dart';
import '../../core/models/scan_result.dart';
import '../../core/localization/app_strings.dart';
import '../../core/localization/app_language.dart';

import '../result/result_screen.dart';
import '../camera/camera_screen.dart';

class HomeScreen extends StatefulWidget {
  final File? imageFile;

  const HomeScreen({
    super.key,
    this.imageFile,
  });

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  bool _hasError = false;
  String _errorMessage = "";

  @override
  void initState() {
    super.initState();

    if (widget.imageFile != null) {
      _runPredictionFlow();
    }
  }

  Future<void> _runPredictionFlow() async {
    setState(() {
      _hasError = false;
      _errorMessage = "";
    });

    try {
      final File image = widget.imageFile!;

      final ScanResult result = await ModelService.runPipeline(image)
          .timeout(const Duration(seconds: 8));

      if (result.isUncertain) {
        _showInvalidImageDialog();
        return;
      }

      await ScanStorage.saveScan(result);

      if (!mounted) return;

      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (_) => ResultScreen(result: result),
        ),
      );
    } on TimeoutException {
      _showError("timeout");
    } catch (e) {
      debugPrint("Prediction error: $e");
      _showError("prediction_failed");
    }
  }

  // ================= INVALID IMAGE POPUP =================
  void _showInvalidImageDialog() {
    if (!mounted) return;

    final lang = appLanguage.value;
    final strings = AppStrings.of(lang);

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        title: Text(strings.invalidImageTitle),
        content: Text(strings.invalidImageMessage),
        actions: [
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.green,
            ),
            onPressed: () {
              Navigator.pop(context);
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(
                  builder: (_) => const CameraScreen(),
                ),
              );
            },
            child: Text(strings.uploadLeaf),
          ),
        ],
      ),
    );
  }

  void _showError(String key) {
    if (!mounted) return;
    setState(() {
      _hasError = true;
      _errorMessage = key;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (widget.imageFile == null) {
      return const CameraScreen();
    }

    return ValueListenableBuilder<AppLanguage>(
      valueListenable: appLanguage,
      builder: (_, lang, __) {
        final strings = AppStrings.of(lang);

        return Scaffold(
          body: _hasError
              ? _FallbackUI(
            message: strings.errorMessage(_errorMessage),
            onRetry: _runPredictionFlow,
          )
              : Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const CircularProgressIndicator(),
                const SizedBox(height: 12),
                Text(
                  strings.analyzingImage,
                  style: const TextStyle(fontWeight: FontWeight.w500),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

/* =========================
   ERROR / FALLBACK UI
   ========================= */

class _FallbackUI extends StatelessWidget {
  final String message;
  final VoidCallback onRetry;

  const _FallbackUI({
    required this.message,
    required this.onRetry,
  });

  @override
  Widget build(BuildContext context) {
    final lang = appLanguage.value;
    final strings = AppStrings.of(lang);

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.green,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(
                builder: (_) => const CameraScreen(),
              ),
            );
          },
        ),
        title: Text(
          strings.analysisFailed,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(
                Icons.error_outline,
                size: 72,
                color: Colors.red,
              ),
              const SizedBox(height: 16),
              Text(
                message,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 24),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 32,
                    vertical: 12,
                  ),
                ),
                onPressed: onRetry,
                child: Text(
                  strings.retry,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: Colors.white,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
