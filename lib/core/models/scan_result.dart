import 'dart:typed_data';

class ScanResult {
  final String     imagePath;
  final String     label;
  final String     disease;
  final double     confidence;
  final String     source;
  final DateTime   timestamp;
  final bool       isUncertain;

  // ===== NEW FIELDS =====
  final String     stage;          // 'Initial Stage', 'Advanced Stage', 'N/A'
  final double     affectedArea;   // 0.0 - 1.0
  final int?       spotCount;      // Phyllosticta only
  final Uint8List? heatmapBytes;   // GradCAM PNG bytes

  const ScanResult({
    required this.imagePath,
    required this.label,
    required this.disease,
    required this.confidence,
    required this.source,
    required this.timestamp,
    required this.isUncertain,
    this.stage          = 'N/A',
    this.affectedArea   = 0.0,
    this.spotCount      = null,
    this.heatmapBytes   = null,
  });

  Map<String, dynamic> toJson() => {
    'imagePath':    imagePath,
    'label':        label,
    'disease':      disease,
    'confidence':   confidence,
    'source':       source,
    'timestamp':    timestamp.toIso8601String(),
    'isUncertain':  isUncertain,
    'stage':        stage,
    'affectedArea': affectedArea,
    'spotCount':    spotCount,
  };

  factory ScanResult.fromJson(Map<String, dynamic> j) => ScanResult(
    imagePath:    j['imagePath']   as String,
    label:        j['label']       as String,
    disease:      j['disease']     as String,
    confidence:   (j['confidence'] as num).toDouble(),
    source:       j['source']      as String,
    timestamp:    DateTime.parse(j['timestamp'] as String),
    isUncertain:  j['isUncertain'] as bool,
    stage:        j['stage']       as String? ?? 'N/A',
    affectedArea: (j['affectedArea'] as num?)?.toDouble() ?? 0.0,
    spotCount:    j['spotCount']   as int?,
  );
}