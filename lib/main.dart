import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';

import 'core/localization/app_language.dart';
import 'features/navigation/main_navigation.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  detectDeviceLanguage();
  runApp(const CardoDisDetectApp());
}

class CardoDisDetectApp extends StatelessWidget {
  const CardoDisDetectApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<AppLanguage>(
      valueListenable: appLanguage,
      builder: (_, lang, __) {
        return MaterialApp(
          debugShowCheckedModeBanner: false,
          locale: Locale(
            lang == AppLanguage.ml
                ? 'ml'
                : lang == AppLanguage.ta
                ? 'ta'
                : 'en',
          ),
          supportedLocales: const [
            Locale('en'),
            Locale('ml'),
            Locale('ta'),
          ],
          localizationsDelegates: const [
            GlobalMaterialLocalizations.delegate,
            GlobalWidgetsLocalizations.delegate,
            GlobalCupertinoLocalizations.delegate,
          ],
          home: const MainNavigation(),
        );
      },
    );
  }
}