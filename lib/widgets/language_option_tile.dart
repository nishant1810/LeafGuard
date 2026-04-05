import 'package:flutter/material.dart';

import '../core/localization/app_language.dart';

class LanguageOptionTile extends StatelessWidget {
  final AppLanguage  language;
  final bool         isSelected;
  final VoidCallback onTap;

  // ✅ added darkMode param — true for dark sheets, false for white sheets
  final bool darkMode;

  const LanguageOptionTile({
    super.key,
    required this.language,
    required this.isSelected,
    required this.onTap,
    this.darkMode = false,
  });

  String get _flag {
    switch (language) {
      case AppLanguage.en: return '🇬🇧';
      case AppLanguage.ta: return '🌺';
      case AppLanguage.ml: return '🌴';
    }
  }

  String _getLanguageName() {
    switch (language) {
      case AppLanguage.en: return "English";
      case AppLanguage.ta: return "Tamil";
      case AppLanguage.ml: return "Malayalam";
    }
  }

  String _getLanguageCode() {
    switch (language) {
      case AppLanguage.en: return "EN";
      case AppLanguage.ta: return "TA";
      case AppLanguage.ml: return "ML";
    }
  }

  @override
  Widget build(BuildContext context) {
    final Color activeColor    = const Color(0xFF2E7D32);
    final Color activeLighter  = const Color(0xFF4CAF50);
    final Color titleColor     = darkMode
        ? (isSelected ? activeLighter : Colors.white)
        : (isSelected ? activeColor   : Colors.black87);
    final Color subtitleColor  = darkMode
        ? Colors.white38
        : Colors.grey.shade500;
    final Color borderColor    = isSelected
        ? activeColor
        : (darkMode ? Colors.white12 : Colors.grey.shade300);
    final Color bgColor        = isSelected
        ? activeColor.withValues(alpha: darkMode ? 0.15 : 0.08)
        : Colors.transparent;

    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        margin: const EdgeInsets.symmetric(
            horizontal: 16, vertical: 4),
        padding: const EdgeInsets.symmetric(
            horizontal: 14, vertical: 12),
        decoration: BoxDecoration(
          color: bgColor,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: borderColor,
            width: isSelected ? 1.5 : 0.8,
          ),
        ),
        child: Row(
          children: [
            // ===== FLAG =====
            Container(
              width: 40, height: 40,
              decoration: BoxDecoration(
                color: isSelected
                    ? activeColor.withValues(alpha: 0.1)
                    : (darkMode
                    ? Colors.white.withValues(alpha: 0.05)
                    : Colors.grey.shade100),
                shape: BoxShape.circle,
              ),
              child: Center(
                child: Text(
                  _flag,
                  style: const TextStyle(fontSize: 20),
                ),
              ),
            ),

            const SizedBox(width: 12),

            // ===== NAME + CODE =====
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    _getLanguageName(),
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                      color: titleColor,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    _getLanguageCode(),
                    style: TextStyle(
                      fontSize: 10,
                      color: subtitleColor,
                      letterSpacing: 1.2,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),

            // ===== CHECK ICON =====
            AnimatedSwitcher(
              duration: const Duration(milliseconds: 200),
              child: isSelected
                  ? Icon(
                Icons.check_circle,
                key: const ValueKey('checked'),
                color: activeLighter,
                size: 22,
              )
                  : Icon(
                Icons.radio_button_unchecked,
                key: const ValueKey('unchecked'),
                color: darkMode
                    ? Colors.white24
                    : Colors.grey.shade400,
                size: 22,
              ),
            ),
          ],
        ),
      ),
    );
  }
}