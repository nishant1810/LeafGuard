import 'dart:ui';
import 'package:flutter/foundation.dart';

/// ================= SUPPORTED LANGUAGES =================
enum AppLanguage {
  en,
  ml,
  ta,
}

/// ================= GLOBAL LANGUAGE NOTIFIER =================
final ValueNotifier<AppLanguage> appLanguage =
ValueNotifier<AppLanguage>(AppLanguage.en);

/// ================= AUTO LANGUAGE DETECTION =================
void detectDeviceLanguage() {
  try {
    final locale = PlatformDispatcher.instance.locale;
    switch (locale.languageCode) {
      case 'ml':
        appLanguage.value = AppLanguage.ml;
        break;
      case 'ta':
        appLanguage.value = AppLanguage.ta;
        break;
      default:
        appLanguage.value = AppLanguage.en;
    }
  } catch (_) {
    appLanguage.value = AppLanguage.en;
  }
}
