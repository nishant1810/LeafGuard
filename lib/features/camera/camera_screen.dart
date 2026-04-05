import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

import '../../core/localization/app_language.dart';
import '../../core/localization/app_strings.dart';
import '../../widgets/language_option_tile.dart';
import '../../widgets/agri_helpline_button.dart';
import '../../widgets/weather_warning_card.dart';
import '../history/history_screen.dart';
import 'image_preview_screen.dart';

class CameraScreen extends StatefulWidget {
  const CameraScreen({super.key});

  @override
  State<CameraScreen> createState() => _CameraScreenState();
}

class _CameraScreenState extends State<CameraScreen> {
  final ImagePicker _picker = ImagePicker();

  Future<void> _pickImage(ImageSource source) async {
    final pickedFile = await _picker.pickImage(source: source);
    if (pickedFile != null && mounted) {
      Navigator.push(context,
          MaterialPageRoute(
              builder: (_) =>
                  ImagePreviewScreen(imageFile: File(pickedFile.path))));
    }
  }

  void _showLanguageSelector(BuildContext context, AppStrings strings) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (sheetContext) {
        return SafeArea(
          top: false,
          child: Container(
            decoration: const BoxDecoration(
              color: Colors.white,
              borderRadius:
              BorderRadius.vertical(top: Radius.circular(20)),
            ),
            padding: EdgeInsets.only(
              bottom: MediaQuery.of(sheetContext).padding.bottom + 12,
              top: 16,
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // ===== DRAG HANDLE =====
                Container(
                  width: 36, height: 4,
                  margin: const EdgeInsets.only(bottom: 12),
                  decoration: BoxDecoration(
                    color: Colors.grey.shade300,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
                Text(
                  strings.selectLanguage,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                ),
                const SizedBox(height: 8),
                LanguageOptionTile(
                  language: AppLanguage.en,
                  isSelected: appLanguage.value == AppLanguage.en,
                  onTap: () {
                    appLanguage.value = AppLanguage.en;
                    Navigator.pop(sheetContext);
                  },
                ),
                LanguageOptionTile(
                  language: AppLanguage.ml,
                  isSelected: appLanguage.value == AppLanguage.ml,
                  onTap: () {
                    appLanguage.value = AppLanguage.ml;
                    Navigator.pop(sheetContext);
                  },
                ),
                LanguageOptionTile(
                  language: AppLanguage.ta,
                  isSelected: appLanguage.value == AppLanguage.ta,
                  onTap: () {
                    appLanguage.value = AppLanguage.ta;
                    Navigator.pop(sheetContext);
                  },
                ),
                const SizedBox(height: 8),
              ],
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final bottomPadding = MediaQuery.of(context).padding.bottom;
    final screenHeight  = MediaQuery.of(context).size.height;

    return ValueListenableBuilder<AppLanguage>(
      valueListenable: appLanguage,
      builder: (_, lang, __) {
        final strings = AppStrings.of(lang);
        final bool isEn = lang == AppLanguage.en;

        return Scaffold(
          resizeToAvoidBottomInset: false,

          // ===== APPBAR WITH LOGO =====
          appBar: AppBar(
            backgroundColor: Colors.green.shade800,
            centerTitle: false,
            elevation: 0,
            toolbarHeight: 54,
            iconTheme: const IconThemeData(color: Colors.white),
            leadingWidth: 56,
            leading: Padding(
              padding: const EdgeInsets.only(left: 12),
              child: Container(
                width: 36, height: 36,
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.15),
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: Colors.white.withValues(alpha: 0.3),
                    width: 1,
                  ),
                ),
                child: ClipOval(
                  child: Image.asset(
                    'assets/images/logo.png',
                    fit: BoxFit.contain,
                  ),
                ),
              ),
            ),
            title: Text(
              strings.appName,
              style: TextStyle(
                fontWeight: FontWeight.w700,
                fontSize: isEn ? 17 : 14,
                color: Colors.white,
                letterSpacing: 0.2,
              ),
              overflow: TextOverflow.ellipsis,
              maxLines: 1,
            ),
            actions: [
              IconButton(
                icon: const Icon(Icons.language, size: 22),
                tooltip: strings.changeLanguage,
                onPressed: () => _showLanguageSelector(context, strings),
              ),
              IconButton(
                icon: const Icon(Icons.history, size: 22),
                onPressed: () => Navigator.push(context,
                    MaterialPageRoute(
                        builder: (_) => const HistoryScreen())),
              ),
            ],
          ),

          body: Stack(
            children: [
              // ===== BACKGROUND =====
              Positioned.fill(
                child: Image.asset('assets/images/bg_image.png',
                    fit: BoxFit.cover),
              ),
              Positioned.fill(
                child: Container(
                    color: Colors.black.withValues(alpha: 0.45)),
              ),

              // ===== CONTENT =====
              SafeArea(
                child: Column(
                  children: [
                    Expanded(
                      child: SingleChildScrollView(
                        padding:
                        const EdgeInsets.fromLTRB(14, 10, 14, 0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [

                            // ===== HERO TITLE =====
                            Container(
                              width: double.infinity,
                              padding: const EdgeInsets.symmetric(
                                  vertical: 8, horizontal: 6),
                              color: Colors.transparent,
                              child: Text(
                                strings.heroTitle,
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  fontSize: isEn
                                      ? (screenHeight < 700 ? 17 : 20)
                                      : (screenHeight < 700 ? 13 : 15),
                                  fontWeight: FontWeight.w400,
                                  color: Colors.white,
                                  height: 1.4,
                                  letterSpacing: isEn ? 0.3 : 0.1,
                                  shadows: const [
                                    Shadow(
                                      color: Colors.black54,
                                      blurRadius: 8,
                                      offset: Offset(0, 2),
                                    ),
                                  ],
                                ),
                              ),
                            ),

                            const SizedBox(height: 6),

                            // ===== DETECTABLE CLASSES =====
                            Container(
                              width: double.infinity,
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 12, vertical: 14),
                              decoration: BoxDecoration(
                                color: Colors.transparent,
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(
                                  color: Colors.white
                                      .withValues(alpha: 0.3),
                                  width: 1,
                                ),
                              ),
                              child: Column(
                                crossAxisAlignment:
                                CrossAxisAlignment.center,
                                children: [
                                  Text(
                                    strings.detectableTitle,
                                    textAlign: TextAlign.center,
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontWeight: FontWeight.w800,
                                      fontSize: isEn ? 13 : 11,
                                      letterSpacing: 0.3,
                                    ),
                                  ),

                                  // // ===== TAP HINT =====
                                  // const SizedBox(height: 4),
                                  // Row(
                                  //   mainAxisAlignment:
                                  //   MainAxisAlignment.center,
                                  //   children: [
                                  //     Icon(
                                  //       Icons.touch_app_outlined,
                                  //       color: Colors.white38,
                                  //       size: 11,
                                  //     ),
                                  //     const SizedBox(width: 4),
                                  //     Text(
                                  //       'Tap to learn more',
                                  //       style: TextStyle(
                                  //         color: Colors.white38,
                                  //         fontSize: 10,
                                  //         fontStyle: FontStyle.italic,
                                  //       ),
                                  //     ),
                                  //   ],
                                  // ),

                                  const SizedBox(height: 12),

                                  // ===== DISEASE CHIPS =====
                                  Row(
                                    mainAxisAlignment:
                                    MainAxisAlignment.spaceEvenly,
                                    children: [
                                      Expanded(
                                        child: _DiseaseChip(
                                          label: strings.blight,
                                          color: Colors.orange,
                                          icon: Icons.warning_amber_rounded,
                                          isEn: isEn,
                                        ),
                                      ),
                                      const SizedBox(width: 6),
                                      Expanded(
                                        child: _DiseaseChip(
                                          label: strings.phyllosticta,
                                          color: Colors.redAccent,
                                          icon: Icons.blur_on,
                                          isEn: isEn,
                                        ),
                                      ),
                                      const SizedBox(width: 6),
                                      Expanded(
                                        child: _DiseaseChip(
                                          label: strings.healthyLeaf,
                                          color: Colors.greenAccent,
                                          icon: Icons.check_circle_outline,
                                          isEn: isEn,
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),

                            const SizedBox(height: 8),

                            // ===== GUIDELINES =====
                            Container(
                              width: double.infinity,
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 12, vertical: 10),
                              decoration: BoxDecoration(
                                color: Colors.transparent,
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(
                                  color: Colors.white
                                      .withValues(alpha: 0.3),
                                  width: 1,
                                ),
                              ),
                              child: Column(
                                crossAxisAlignment:
                                CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    strings.guidelinesTitle,
                                    style: TextStyle(
                                      fontSize: isEn ? 13 : 11,
                                      fontWeight: FontWeight.w700,
                                      color: Colors.white,
                                      letterSpacing: 0.3,
                                    ),
                                  ),
                                  const SizedBox(height: 8),
                                  _GuidelineTile(
                                    icon: Icons.wb_sunny,
                                    text: strings.guidelineNaturalLight,
                                    isEn: isEn,
                                  ),
                                  _GuidelineTile(
                                    icon: Icons.center_focus_strong,
                                    text: strings.guidelineFocus,
                                    isEn: isEn,
                                  ),
                                  _GuidelineTile(
                                    icon: Icons.block,
                                    text: strings.guidelineAvoidBlur,
                                    isEn: isEn,
                                  ),
                                  _GuidelineTile(
                                    icon: Icons.eco,
                                    text: strings.guidelineSingleLeaf,
                                    isEn: isEn,
                                  ),
                                  _GuidelineTile(
                                    icon: Icons.straighten,
                                    text: strings.guidelineDistance,
                                    isEn: isEn,
                                  ),
                                  _GuidelineTile(
                                    icon: Icons.water_drop_outlined,
                                    text: strings.guidelineDryLeaf,
                                    isEn: isEn,
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),

                    // ===== BUTTONS PINNED TO BOTTOM =====
                    Container(
                      padding: EdgeInsets.fromLTRB(
                          16, 12, 16, bottomPadding + 12),
                      color: Colors.transparent,
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [

                          // ===== CAPTURE BUTTON =====
                          Container(
                            width: double.infinity,
                            height: 52,
                            decoration: BoxDecoration(
                              color: Colors.green.shade800
                                  .withValues(alpha: 0.85),
                              borderRadius: BorderRadius.circular(50),
                            ),
                            child: Material(
                              color: Colors.transparent,
                              child: InkWell(
                                borderRadius: BorderRadius.circular(50),
                                onTap: () =>
                                    _pickImage(ImageSource.camera),
                                child: Row(
                                  mainAxisAlignment:
                                  MainAxisAlignment.center,
                                  children: [
                                    const Icon(Icons.camera_alt,
                                        color: Colors.white, size: 18),
                                    const SizedBox(width: 8),
                                    Flexible(
                                      child: Text(
                                        strings.startDetection,
                                        style: TextStyle(
                                          color: Colors.white,
                                          fontSize: isEn ? 15 : 12,
                                          fontWeight: FontWeight.w600,
                                          letterSpacing: 0.1,
                                        ),
                                        overflow: TextOverflow.ellipsis,
                                        maxLines: 1,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),

                          const SizedBox(height: 10),

                          // ===== GALLERY BUTTON =====
                          Container(
                            width: double.infinity,
                            height: 50,
                            decoration: BoxDecoration(
                              color: Colors.transparent,
                              borderRadius: BorderRadius.circular(50),
                              border: Border.all(
                                color: Colors.white
                                    .withValues(alpha: 0.7),
                                width: 1.5,
                              ),
                            ),
                            child: Material(
                              color: Colors.transparent,
                              child: InkWell(
                                borderRadius: BorderRadius.circular(50),
                                onTap: () =>
                                    _pickImage(ImageSource.gallery),
                                child: Row(
                                  mainAxisAlignment:
                                  MainAxisAlignment.center,
                                  children: [
                                    Icon(Icons.photo_library_outlined,
                                        color: Colors.white
                                            .withValues(alpha: 0.9),
                                        size: 18),
                                    const SizedBox(width: 8),
                                    Flexible(
                                      child: Text(
                                        strings.uploadFromGallery,
                                        style: TextStyle(
                                          color: Colors.white
                                              .withValues(alpha: 0.9),
                                          fontSize: isEn ? 14 : 12,
                                          fontWeight: FontWeight.w500,
                                          letterSpacing: 0.1,
                                        ),
                                        overflow: TextOverflow.ellipsis,
                                        maxLines: 1,
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
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

// ================= DISEASE CHIP =================
class _DiseaseChip extends StatelessWidget {
  final String   label;
  final Color    color;
  final IconData icon;
  final bool     isEn;

  const _DiseaseChip({
    required this.label,
    required this.color,
    required this.icon,
    required this.isEn,
  });

  // ===== SHOW DISEASE INFO DIALOG =====
  void _showDiseaseInfo(BuildContext context) {
    final info = _getDiseaseInfo();
    showDialog(
      context: context,
      barrierColor: Colors.black.withValues(alpha: 0.75),
      builder: (_) => Dialog(
        backgroundColor: Colors.transparent,
        insetPadding: const EdgeInsets.symmetric(
            horizontal: 20, vertical: 40),
        child: Container(
          decoration: BoxDecoration(
            color: const Color(0xFF0F2A12),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: color.withValues(alpha: 0.4),
              width: 1,
            ),
          ),
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [

                // ===== HEADER =====
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(18),
                  decoration: BoxDecoration(
                    color: color.withValues(alpha: 0.1),
                    borderRadius: const BorderRadius.vertical(
                        top: Radius.circular(20)),
                    border: Border(
                      bottom: BorderSide(
                        color: color.withValues(alpha: 0.2),
                        width: 1,
                      ),
                    ),
                  ),
                  child: Row(
                    children: [
                      // ===== ICON =====
                      Container(
                        width: 48, height: 48,
                        decoration: BoxDecoration(
                          color: color.withValues(alpha: 0.15),
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: color.withValues(alpha: 0.5),
                            width: 1.5,
                          ),
                        ),
                        child: Icon(icon, color: color, size: 22),
                      ),
                      const SizedBox(width: 14),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // ===== TYPE PILL =====
                            Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 8, vertical: 2),
                              decoration: BoxDecoration(
                                color: color.withValues(alpha: 0.15),
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: Text(
                                info['type']!,
                                style: TextStyle(
                                  fontSize: 9,
                                  fontWeight: FontWeight.w800,
                                  color: color,
                                  letterSpacing: 1.0,
                                ),
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              label,
                              style: const TextStyle(
                                fontSize: 15,
                                fontWeight: FontWeight.w700,
                                color: Colors.white,
                              ),
                            ),
                          ],
                        ),
                      ),
                      // ===== CLOSE =====
                      GestureDetector(
                        onTap: () => Navigator.pop(context),
                        child: Container(
                          width: 28, height: 28,
                          decoration: BoxDecoration(
                            color: Colors.white.withValues(alpha: 0.08),
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(
                            Icons.close,
                            color: Colors.white54,
                            size: 16,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                // ===== BODY =====
                Padding(
                  padding: const EdgeInsets.all(18),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [

                      // ===== DESCRIPTION =====
                      Text(
                        info['description']!,
                        style: const TextStyle(
                          color: Colors.white70,
                          fontSize: 13,
                          height: 1.6,
                        ),
                      ),

                      const SizedBox(height: 14),

                      // ===== INFO CARDS =====
                      _InfoCard(
                        icon: Icons.coronavirus_outlined,
                        title: 'Cause',
                        value: info['cause']!,
                        color: color,
                      ),
                      const SizedBox(height: 8),
                      _InfoCard(
                        icon: Icons.visibility_outlined,
                        title: 'Symptoms',
                        value: info['symptoms']!,
                        color: color,
                      ),
                      const SizedBox(height: 8),
                      _InfoCard(
                        icon: Icons.thermostat_outlined,
                        title: 'Favorable Conditions',
                        value: info['conditions']!,
                        color: color,
                      ),
                      const SizedBox(height: 8),
                      _InfoCard(
                        icon: Icons.medical_services_outlined,
                        title: 'Treatment',
                        value: info['treatment']!,
                        color: color,
                      ),

                      const SizedBox(height: 14),

                      // ===== SEVERITY METER =====
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.symmetric(
                            horizontal: 14, vertical: 10),
                        decoration: BoxDecoration(
                          color: color.withValues(alpha: 0.08),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: color.withValues(alpha: 0.25),
                            width: 1,
                          ),
                        ),
                        child: Row(
                          children: [
                            Icon(Icons.bar_chart,
                                color: color, size: 16),
                            const SizedBox(width: 8),
                            const Text(
                              'Severity: ',
                              style: TextStyle(
                                color: Colors.white54,
                                fontSize: 12,
                              ),
                            ),
                            Text(
                              info['severity']!,
                              style: TextStyle(
                                color: color,
                                fontSize: 12,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                            const Spacer(),
                            // ===== SEVERITY DOTS =====
                            Row(
                              children: List.generate(5, (i) {
                                final int level = int.parse(
                                    info['severityLevel']!);
                                return Container(
                                  width: 8, height: 8,
                                  margin:
                                  const EdgeInsets.only(left: 4),
                                  decoration: BoxDecoration(
                                    color: i < level
                                        ? color
                                        : color.withValues(alpha: 0.2),
                                    shape: BoxShape.circle,
                                  ),
                                );
                              }),
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(height: 14),

                      // ===== CLOSE BUTTON =====
                      SizedBox(
                        width: double.infinity,
                        child: TextButton(
                          onPressed: () => Navigator.pop(context),
                          style: TextButton.styleFrom(
                            backgroundColor:
                            color.withValues(alpha: 0.15),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                              side: BorderSide(
                                color: color.withValues(alpha: 0.3),
                              ),
                            ),
                            padding: const EdgeInsets.symmetric(
                                vertical: 12),
                          ),
                          child: Text(
                            'Close',
                            style: TextStyle(
                              color: color,
                              fontWeight: FontWeight.w600,
                              fontSize: 14,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // ===== DISEASE DATA =====
  Map<String, String> _getDiseaseInfo() {
    final String labelLower = label.toLowerCase();

    if (labelLower.contains('blight') ||
        labelLower.contains('ബ്ലൈറ്റ്') ||
        labelLower.contains('கருகல்') ||
        labelLower.contains('കരിച്ചിൽ')) {
      return {
        'type':          'FUNGAL DISEASE',
        'description':
        'Cardamom Blight is a serious fungal disease caused by Phytophthora meadii. It rapidly spreads in humid conditions and can devastate entire cardamom plantations if left untreated.',
        'cause':         'Phytophthora meadii fungus',
        'symptoms':
        'Dark brown water-soaked lesions on leaves, wilting of shoots, rotting of capsules and collar region, foul smell from infected parts',
        'conditions':
        'High humidity (>80%), heavy rainfall, waterlogged soil, temperature 20–25°C',
        'treatment':
        'Spray Copper Oxychloride 3g/L, remove and burn infected parts, improve field drainage, avoid overhead irrigation',
        'severity':      'High',
        'severityLevel': '4',
      };
    }

    if (labelLower.contains('phyllosticta') ||
        labelLower.contains('ഫൈലോ') ||
        labelLower.contains('பைலோ') ||
        labelLower.contains('പുള്ളി')) {
      return {
        'type':          'FUNGAL DISEASE',
        'description':
        'Phyllosticta Leaf Spot is a fungal disease caused by Phyllosticta elettariae. It appears as small white or pale brown circular spots on leaves, reducing photosynthesis and plant vigor.',
        'cause':         'Phyllosticta elettariae fungus',
        'symptoms':
        'Small circular white/pale brown spots with dark borders, yellowing around spots, premature leaf drop in severe cases',
        'conditions':
        'Humid conditions, poor air circulation, wet foliage, temperature 25–30°C',
        'treatment':
        'Spray Mancozeb 2.5g/L, improve air circulation between plants, remove affected leaves, avoid water stagnation',
        'severity':      'Moderate',
        'severityLevel': '3',
      };
    }

    // ===== HEALTHY =====
    return {
      'type':          'HEALTHY LEAF',
      'description':
      'A healthy cardamom leaf shows vibrant green color with no spots, lesions or discoloration. Maintaining plant health through proper care prevents disease outbreaks.',
      'cause':         'No pathogen detected',
      'symptoms':
      'Vibrant green color, smooth texture, no spots or lesions, normal leaf size and shape',
      'conditions':
      'Proper irrigation, good drainage, balanced nutrients, adequate sunlight and air circulation',
      'treatment':
      'Continue regular care — proper watering, balanced fertilization, periodic monitoring and preventive fungicide sprays',
      'severity':      'None',
      'severityLevel': '0',
    };
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => _showDiseaseInfo(context),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // ===== ICON CIRCLE WITH INFO BADGE =====
          Stack(
            clipBehavior: Clip.none,
            children: [
              Container(
                width: 44, height: 44,
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.1),
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: color.withValues(alpha: 0.5),
                    width: 1.5,
                  ),
                ),
                child: Icon(icon, color: color, size: 20),
              ),
              // ===== INFO BADGE =====
              Positioned(
                bottom: -2, right: -2,
                child: Container(
                  width: 16, height: 16,
                  decoration: BoxDecoration(
                    color: const Color(0xFF0F2A12),
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: color.withValues(alpha: 0.6),
                      width: 1,
                    ),
                  ),
                  child: Icon(
                    Icons.info_outline,
                    size: 10,
                    color: color,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          // ===== LABEL =====
          Text(
            label,
            textAlign: TextAlign.center,
            style: TextStyle(
              color: color,
              fontWeight: FontWeight.w700,
              fontSize: isEn ? 11 : 9,
              height: 1.3,
            ),
            overflow: TextOverflow.ellipsis,
            maxLines: 2,
          ),
        ],
      ),
    );
  }
}

// ================= GUIDELINE TILE =================
class _GuidelineTile extends StatelessWidget {
  final IconData icon;
  final String   text;
  final bool     isEn;

  const _GuidelineTile({
    required this.icon,
    required this.text,
    required this.isEn,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Container(
            width: 28, height: 28,
            decoration: BoxDecoration(
              color: Colors.greenAccent.withValues(alpha: 0.12),
              shape: BoxShape.circle,
              border: Border.all(
                color: Colors.greenAccent.withValues(alpha: 0.3),
                width: 0.8,
              ),
            ),
            child: Icon(
              icon,
              color: Colors.greenAccent,
              size: 14,
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              text,
              style: TextStyle(
                color: Colors.white,
                fontSize: isEn ? 12 : 10,
                height: 1.4,
                fontWeight: FontWeight.w500,
              ),
              maxLines: isEn ? 1 : 2,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }
}

// ================= INFO CARD =================
class _InfoCard extends StatelessWidget {
  final IconData icon;
  final String   title;
  final String   value;
  final Color    color;

  const _InfoCard({
    required this.icon,
    required this.title,
    required this.value,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.04),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(
          color: Colors.white.withValues(alpha: 0.08),
          width: 0.8,
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 26, height: 26,
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.12),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: color, size: 13),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title.toUpperCase(),
                  style: TextStyle(
                    color: color,
                    fontSize: 9,
                    fontWeight: FontWeight.w800,
                    letterSpacing: 0.8,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  value,
                  style: const TextStyle(
                    color: Colors.white70,
                    fontSize: 12,
                    height: 1.4,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}