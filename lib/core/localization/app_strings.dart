import 'app_language.dart';

class AppStrings {
  final AppLanguage lang;

  AppStrings(this.lang);

  static AppStrings of(AppLanguage lang) => AppStrings(lang);

  // ================= APP =================
  String get appName =>
      lang == AppLanguage.ml
          ? "കാർഡോഡിസ്‌ഡിറ്റക്ട്"
          : lang == AppLanguage.ta
          ? "கார்டோடிஸ்டெக்ட்"
          : "CardoDisDetect";

  String get selectLanguage =>
      lang == AppLanguage.ml
          ? "ഭാഷ തിരഞ്ഞെടുക്കുക"
          : lang == AppLanguage.ta
          ? "மொழியைத் தேர்ந்தெடுக்கவும்"
          : "Select Language";

  String get changeLanguage =>
      lang == AppLanguage.ml
          ? "ഭാഷ മാറ്റുക"
          : lang == AppLanguage.ta
          ? "மொழியை மாற்றவும்"
          : "Change Language";

  // ================= CAMERA =================
  String get heroTitle =>
      lang == AppLanguage.ml
          ? "നിങ്ങൾ വളർത്തുന്നത് സംരക്ഷിക്കൂ.രോഗം പടരുന്നതിന് മുൻപ് കണ്ടെത്തൂ."
          : lang == AppLanguage.ta
          ? "நீங்கள் வளர்ப்பதை பாதுகாக்கவும்.பரவுவதற்கு முன்பே கண்டறியவும்."
          : "Protect What You Grow. Detect Before It Spreads.";

  String get detectableTitle =>
      lang == AppLanguage.ml
          ? "കണ്ടെത്താവുന്ന ഇല രോഗങ്ങൾ"
          : lang == AppLanguage.ta
          ? "கண்டறியக்கூடிய இலை நோய்கள்"
          : "Detectable Leaf Conditions";

  // ================= GUIDELINES =================
  String get guidelinesTitle =>
      lang == AppLanguage.ml
          ? "ചിത്രം എടുക്കാനുള്ള നിർദ്ദേശങ്ങൾ"
          : lang == AppLanguage.ta
          ? "புகைப்படம் எடுக்கும் வழிமுறைகள்"
          : "Quick Capture Tips";

  String get guidelineNaturalLight =>
      lang == AppLanguage.ml
          ? "സ്വാഭാവിക വെളിച്ചം ഉപയോഗിക്കുക"
          : lang == AppLanguage.ta
          ? "இயற்கை வெளிச்சம் பயன்படுத்தவும்"
          : "Use natural light";

  String get guidelineFocus =>
      lang == AppLanguage.ml
          ? "ഇല വ്യക്തമായി ഫോക്കസ് ചെയ്യുക"
          : lang == AppLanguage.ta
          ? "இலை தெளிவாக இருக்க வேண்டும்"
          : "Keep leaf clearly focused";

  String get guidelineAvoidBlur =>
      lang == AppLanguage.ml
          ? "മങ്ങിയ അല്ലെങ്കിൽ ഇരുണ്ട ചിത്രങ്ങൾ ഒഴിവാക്കുക"
          : lang == AppLanguage.ta
          ? "மங்கலான அல்லது இருண்ட படங்களை தவிர்க்கவும்"
          : "Avoid blurry or dark images";

  String get guidelineSingleLeaf =>
      lang == AppLanguage.ml
          ? "ഒരു ഇല മാത്രം ചിത്രീകരിക്കുക"
          : lang == AppLanguage.ta
          ? "ஒரு இலை மட்டுமே படமெடுக்கவும்"
          : "Capture only one leaf";

  String get guidelineDistance =>
      lang == AppLanguage.ml
          ? "ഫോൺ 30–40 സെ.മീ അകലെ പിടിക്കുക"
          : lang == AppLanguage.ta
          ? "போனை 30–40 செ.மீ தூரத்தில் வைக்கவும்"
          : "Keep phone 30–40 cm away";

  String get guidelineDryLeaf =>
      lang == AppLanguage.ml
          ? "നനഞ്ഞ അല്ലെങ്കിൽ പൊടിയുള്ള ഇലകൾ ഒഴിവാക്കുക"
          : lang == AppLanguage.ta
          ? "நனைந்த அல்லது தூசியான இலைகளை தவிர்க்கவும்"
          : "Avoid wet or dusty leaves";


  String get startDetection =>
      lang == AppLanguage.ml
          ? "ക്യാമറ ഉപയോഗിച്ച് കണ്ടെത്തൽ ആരംഭിക്കുക"
          : lang == AppLanguage.ta
          ? "கேமராவுடன் கண்டறிதலை தொடங்கு"
          : "Capture Disease Detection";

  String get uploadFromGallery =>
      lang == AppLanguage.ml
          ? "ഗാലറിയിൽ നിന്ന് അപ്‌ലോഡ് ചെയ്യുക"
          : lang == AppLanguage.ta
          ? "கேலரியில் இருந்து பதிவேற்றவும்"
          : "Upload from Gallery";

  // ================= HOME / ERROR =================
  String get invalidImageTitle =>
      lang == AppLanguage.ml
          ? "അസാധുവായ ചിത്രം"
          : lang == AppLanguage.ta
          ? "தவறான படம்"
          : "Invalid Image";

  String get invalidImageMessage =>
      lang == AppLanguage.ml
          ? "ഈ ചിത്രം വ്യക്തമായ ഏലക്ക ഇലയല്ല അല്ലെങ്കിൽ വിശ്വാസ്യത കുറവാണ്.\n\nദയവായി വ്യക്തമായ ഏലക്ക ഇലയുടെ ചിത്രം അപ്‌ലോഡ് ചെയ്യുക."
          : lang == AppLanguage.ta
          ? "இந்த படம் தெளிவான ஏலக்காய் இலை அல்ல அல்லது நம்பகத்தன்மை குறைவாக உள்ளது.\n\nதயவுசெய்து தெளிவான ஏலக்காய் இலை படத்தை பதிவேற்றவும்."
          : "This image does not appear to be a clear cardamom leaf or the prediction confidence is too low.\n\nPlease upload a clear cardamom leaf image.";

  String get uploadLeaf =>
      lang == AppLanguage.ml
          ? "ഇല ചിത്രം അപ്‌ലോഡ് ചെയ്യുക"
          : lang == AppLanguage.ta
          ? "இலை படத்தை பதிவேற்றவும்"
          : "Upload Leaf Image";

  String get analyzingImage =>
      lang == AppLanguage.ml
          ? "ഇല ചിത്രം വിശകലനം ചെയ്യുന്നു…"
          : lang == AppLanguage.ta
          ? "இலை படம் பகுப்பாய்வு செய்யப்படுகிறது…"
          : "Analyzing leaf image…";

  String get analysisFailed =>
      lang == AppLanguage.ml
          ? "വിശകലനം പരാജയപ്പെട്ടു"
          : lang == AppLanguage.ta
          ? "பகுப்பாய்வு தோல்வியடைந்தது"
          : "Analysis Failed";

  String get retry =>
      lang == AppLanguage.ml
          ? "വീണ്ടും ശ്രമിക്കുക"
          : lang == AppLanguage.ta
          ? "மீண்டும் முயற்சிக்கவும்"
          : "Retry";

  String errorMessage(String key) {
    switch (key) {
      case "timeout":
        return lang == AppLanguage.ml
            ? "സമയം കഴിഞ്ഞു. വീണ്ടും ശ്രമിക്കുക."
            : lang == AppLanguage.ta
            ? "நேரம் முடிந்தது. மீண்டும் முயற்சிக்கவும்."
            : "Prediction timed out. Please try again.";
      default:
        return lang == AppLanguage.ml
            ? "ദയവായി ഏലക്ക ഇല അപ്‌ലോഡ് ചെയ്യുക."
            : lang == AppLanguage.ta
            ? "தயவுசெய்து ஏலக்காய் இலை பதிவேற்றவும்."
            : "Please upload a cardamom leaf.";
    }
  }

  String get previewImage =>
      lang == AppLanguage.ml
          ? "ചിത്രം മുൻകാഴ്ച"
          : lang == AppLanguage.ta
          ? "பட முன்னோட்டம்"
          : "Preview Image";

  String get retake =>
      lang == AppLanguage.ml
          ? "വീണ്ടും എടുക്കുക"
          : lang == AppLanguage.ta
          ? "மீண்டும் எடுக்கவும்"
          : "Retake";

  String get selectLeafRegion =>
      lang == AppLanguage.ml
          ? "ഇലയുടെ ഭാഗം തിരഞ്ഞെടുക്കുക"
          : lang == AppLanguage.ta
          ? "இலை பகுதியை தேர்வு செய்யவும்"
          : "Select Leaf Region";


  String get leafSegmentation =>
      lang == AppLanguage.ml
          ? "ഇല സെഗ്മെന്റേഷൻ (SAM)"
          : lang == AppLanguage.ta
          ? "இலை பகுப்பாக்கம் (SAM)"
          : "Leaf Segmentation (SAM)";

  String get autoSegmentation =>
      lang == AppLanguage.ml
          ? "ഓട്ടോ സെഗ്മെന്റേഷൻ"
          : lang == AppLanguage.ta
          ? "தானியங்கி பகுப்பாக்கம்"
          : "Auto Segmentation";

  String get applySegmentation =>
      lang == AppLanguage.ml
          ? "SAM സെഗ്മെന്റേഷൻ പ്രയോഗിക്കുക"
          : lang == AppLanguage.ta
          ? "SAM பகுப்பாக்கத்தை பயன்படுத்து"
          : "Apply SAM Segmentation";

  String get selectRegionWarning =>
      lang == AppLanguage.ml
          ? "ദയവായി ഒരു ഭാഗം തിരഞ്ഞെടുക്കുക"
          : lang == AppLanguage.ta
          ? "தயவுசெய்து ஒரு பகுதியை தேர்ந்தெடுக்கவும்"
          : "Please select a region";


  // ================= HISTORY / PDF =================

  String get history =>
      lang == AppLanguage.ml
          ? "സ്കാൻ ചരിത്രം"
          : lang == AppLanguage.ta
          ? "ஸ்கேன் வரலாறு"
          : "Scan History";

  String get noHistory =>
      lang == AppLanguage.ml
          ? "സ്കാൻ ചരിത്രം ലഭ്യമല്ല"
          : lang == AppLanguage.ta
          ? "எந்த ஸ்கேன் வரலாறும் இல்லை"
          : "No scan history found";

  String get downloadPdf =>
      lang == AppLanguage.ml
          ? "PDF ഡൗൺലോഡ് ചെയ്യുക"
          : lang == AppLanguage.ta
          ? "PDF பதிவிறக்கம்"
          : "Download PDF";

  String get generatingPdf =>
      lang == AppLanguage.ml
          ? "PDF സൃഷ്ടിക്കുന്നു…"
          : lang == AppLanguage.ta
          ? "PDF உருவாக்கப்படுகிறது…"
          : "Generating PDF…";

  String get pdfDownloaded =>
      lang == AppLanguage.ml
          ? "PDF വിജയകരമായി ഡൗൺലോഡ് ചെയ്തു"
          : lang == AppLanguage.ta
          ? "PDF வெற்றிகரமாக பதிவிறக்கப்பட்டது"
          : "PDF downloaded successfully";

  String get pdfFailed =>
      lang == AppLanguage.ml
          ? "PDF സൃഷ്ടിക്കാൻ പരാജയപ്പെട്ടു"
          : lang == AppLanguage.ta
          ? "PDF உருவாக்க முடியவில்லை"
          : "Failed to generate PDF";

  String get historyPdfSubtitle =>
      lang == AppLanguage.ml
          ? "കാർഡമം ഇല സ്കാൻ റിപ്പോർട്ട്"
          : lang == AppLanguage.ta
          ? "ஏலக்காய் இலை ஸ்கேன் அறிக்கை"
          : "Cardamom Leaf Scan Report";

  String get page =>
      lang == AppLanguage.ml
          ? "പേജ്"
          : lang == AppLanguage.ta
          ? "பக்கம்"
          : "Page";

  String get image =>
      lang == AppLanguage.ml
          ? "ചിത്രം"
          : lang == AppLanguage.ta
          ? "படம்"
          : "Image";

  String get disease =>
      lang == AppLanguage.ml
          ? "രോഗം"
          : lang == AppLanguage.ta
          ? "நோய்"
          : "Disease";

  String get confidence =>
      lang == AppLanguage.ml
          ? "വിശ്വാസ്യത"
          : lang == AppLanguage.ta
          ? "நம்பகத்தன்மை"
          : "Confidence";

  String get date =>
      lang == AppLanguage.ml
          ? "തീയതി"
          : lang == AppLanguage.ta
          ? "தேதி"
          : "Date";


  // ================= DISEASE NAMES =================
  String get healthyLeaf =>
      lang == AppLanguage.ml
          ? "ആരോഗ്യകരമായ ഇല"
          : lang == AppLanguage.ta
          ? "ஆரோக்கியமான இலை"
          : "Healthy Leaf";

  String get blight =>
      lang == AppLanguage.ml
          ? "ബ്ലൈറ്റ് രോഗം"
          : lang == AppLanguage.ta
          ? "இலை கருகல் நோய்"
          : "Blight";

  String get phyllosticta =>
      lang == AppLanguage.ml
          ? "ഫില്ലോസ്റ്റിക്റ്റ ലീഫ് സ്‌പോട്ട്"
          : lang == AppLanguage.ta
          ? "பில்லோஸ்டிக்டா இலை புள்ளி"
          : "Phyllosticta Leaf Spot";

  // ================= RESULT =================
  String get leafHealthReport =>
      lang == AppLanguage.ml
          ? "ഇല ആരോഗ്യ റിപ്പോർട്ട്"
          : lang == AppLanguage.ta
          ? "இலை ஆரோக்கிய அறிக்கை"
          : "Leaf Health Report";

  String get uncertain =>
      lang == AppLanguage.ml
          ? "അനിശ്ചിതം"
          : lang == AppLanguage.ta
          ? "நிச்சயமற்றது"
          : "Uncertain";

  String get uncertainMessage =>
      lang == AppLanguage.ml
          ? "ഫലം വ്യക്തമായിട്ടില്ല – നല്ല വെളിച്ചത്തിൽ വീണ്ടും സ്കാൻ ചെയ്യുക"
          : lang == AppLanguage.ta
          ? "முடிவு தெளிவில்லை – நல்ல வெளிச்சத்தில் மீண்டும் ஸ்கேன் செய்யவும்"
          : "Uncertain Result – Please re-scan in good lighting";

  String diseaseDetected(String d) =>
      lang == AppLanguage.ml
          ? "രോഗം കണ്ടെത്തി ($d)"
          : lang == AppLanguage.ta
          ? "நோய் கண்டறியப்பட்டது ($d)"
          : "Disease Detected ($d)";

  String get careTips =>
      lang == AppLanguage.ml
          ? "പരിചരണ നിർദ്ദേശങ്ങൾ"
          : lang == AppLanguage.ta
          ? "பராமரிப்பு குறிப்புகள்"
          : "Care Tips";

  String get suggestions =>
      lang == AppLanguage.ml
          ? "സൂചനകൾ"
          : lang == AppLanguage.ta
          ? "பரிந்துரைகள்"
          : "Suggestions";

  String get recommendedActions =>
      lang == AppLanguage.ml
          ? "ശുപാർശ ചെയ്യുന്ന നടപടികൾ"
          : lang == AppLanguage.ta
          ? "பரிந்துரைக்கப்பட்ட நடவடிக்கைகள்"
          : "Recommended Actions";

  // ================= RECOMMENDATIONS =================
  List<String> recommendations(String disease, bool isUncertain) {
    final d = disease.toLowerCase();

    if (isUncertain) {
      return [
        lang == AppLanguage.ml
            ? "നല്ല സ്വാഭാവിക വെളിച്ചത്തിൽ വീണ്ടും സ്കാൻ ചെയ്യുക"
            : lang == AppLanguage.ta
            ? "நல்ல இயற்கை வெளிச்சத்தில் மீண்டும் ஸ்கேன் செய்யவும்"
            : "Re-scan the leaf in good natural lighting",
        lang == AppLanguage.ml
            ? "ഇല വ്യക്തമായി ഫോക്കസ് ചെയ്യുക"
            : lang == AppLanguage.ta
            ? "இலை தெளிவாக கவனம் செலுத்தவும்"
            : "Ensure the leaf is clearly visible",
      ];
    }

    // ================= RECOMMENDATIONS =================

    if (d.contains("healthy")) {
      return [
        lang == AppLanguage.ml
            ? "ചെടി നിരന്തരം നിരീക്ഷിക്കുക"
            : lang == AppLanguage.ta
            ? "தாவரத்தை தொடர்ந்து கண்காணிக்கவும்"
            : "Monitor the plant regularly",

        lang == AppLanguage.ml
            ? "ശരിയായ ജലസേചനക്രമം പാലിക്കുക"
            : lang == AppLanguage.ta
            ? "சரியான பாசன அட்டவணையை பின்பற்றவும்"
            : "Maintain proper irrigation schedule",

        lang == AppLanguage.ml
            ? "വളങ്ങൾ സമതുലിതമായി നൽകുക"
            : lang == AppLanguage.ta
            ? "சமநிலை ஊட்டச்சத்துகளை வழங்கவும்"
            : "Apply balanced nutrients",

        lang == AppLanguage.ml
            ? "പഴയതോ കേടായതോ ആയ ഇലകൾ നീക്കം ചെയ്യുക"
            : lang == AppLanguage.ta
            ? "பழைய அல்லது சேதமடைந்த இலைகளை அகற்றவும்"
            : "Remove old or damaged leaves",
      ];
    }

    if (d.contains("blight")) {
      return [
        lang == AppLanguage.ml
            ? "ബാധിച്ച ഇലകൾ ഉടൻ നീക്കം ചെയ്യുക"
            : lang == AppLanguage.ta
            ? "பாதிக்கப்பட்ட இலைகளை உடனடியாக அகற்றவும்"
            : "Remove infected leaves immediately",

        lang == AppLanguage.ml
            ? "കോപ്പർ അടിസ്ഥിത ഫംഗിസൈഡ് പ്രയോഗിക്കുക"
            : lang == AppLanguage.ta
            ? "காப்பர் அடிப்படையிலான பூஞ்சை மருந்தை பயன்படுத்தவும்"
            : "Apply copper-based fungicide",

        lang == AppLanguage.ml
            ? "മുകളിൽ നിന്നുള്ള ജലസേചനം ഒഴിവാക്കുക"
            : lang == AppLanguage.ta
            ? "மேல்நோக்கி பாசனத்தை தவிர்க்கவும்"
            : "Avoid overhead irrigation",

        lang == AppLanguage.ml
            ? "കൃഷിസ്ഥലത്തിൽ ശരിയായ ഡ്രെയിനേജ് ഉറപ്പാക്കുക"
            : lang == AppLanguage.ta
            ? "வயலில் சரியான வடிகாலமைப்பை உறுதி செய்யவும்"
            : "Ensure proper field drainage",
      ];
    }

    if (d.contains("phyllosticta")) {
      return [
        lang == AppLanguage.ml
            ? "ചെടികൾക്കിടയിൽ വായുസഞ്ചാരം മെച്ചപ്പെടുത്തുക"
            : lang == AppLanguage.ta
            ? "தாவரங்களுக்கு இடையே காற்றோட்டத்தை மேம்படுத்தவும்"
            : "Improve air circulation",

        lang == AppLanguage.ml
            ? "വെള്ളം നിൽക്കുന്നത് ഒഴിവാക്കുക"
            : lang == AppLanguage.ta
            ? "நீர் தேங்குவதை தவிர்க்கவும்"
            : "Avoid water stagnation",

        lang == AppLanguage.ml
            ? "ശുപാർശ ചെയ്യുന്ന ഫംഗിസൈഡ് പ്രയോഗിക്കുക"
            : lang == AppLanguage.ta
            ? "பரிந்துரைக்கப்பட்ட பூஞ்சை மருந்தை பயன்படுத்தவும்"
            : "Apply recommended fungicide",

        lang == AppLanguage.ml
            ? "തീവ്രമായി ബാധിച്ച ഇലകൾ നീക്കം ചെയ്യുക"
            : lang == AppLanguage.ta
            ? "கடுமையாக பாதிக்கப்பட்ட இலைகளை அகற்றவும்"
            : "Remove severely affected leaves",
      ];
    }


    return [
      lang == AppLanguage.ml
          ? "കൃഷി വിദഗ്ധനുമായി ബന്ധപ്പെടുക"
          : lang == AppLanguage.ta
          ? "வேளாண் நிபுணரை அணுகவும்"
          : "Consult an agricultural expert",
    ];
  }

  // ================= UTIL =================
  String localizedDisease(String disease) {
    final d = disease.toLowerCase();
    if (d.contains("healthy")) return healthyLeaf;
    if (d.contains("blight")) return blight;
    if (d.contains("phyllosticta")) return phyllosticta;
    return disease;
  }
}
