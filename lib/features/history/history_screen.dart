import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:path_provider/path_provider.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:pdf/pdf.dart';
import 'package:open_file/open_file.dart';
import 'package:printing/printing.dart';

import '../../core/localization/app_language.dart';
import '../../core/localization/app_strings.dart';
import '../../services/scan_storage.dart';
import '../../core/models/scan_result.dart';
import '../result/result_screen.dart';

class HistoryScreen extends StatefulWidget {
  const HistoryScreen({super.key});

  @override
  State<HistoryScreen> createState() => _HistoryScreenState();
}

class _HistoryScreenState extends State<HistoryScreen> {
  List<ScanResult> _allScans  = [];
  bool             _loading    = true;
  bool             _downloading = false;

  @override
  void initState() {
    super.initState();
    _loadHistory();
  }

  Future<void> _loadHistory() async {
    final scans = await ScanStorage.loadScans();
    if (!mounted) return;
    setState(() {
      _allScans = scans.reversed.toList();
      _loading  = false;
    });
  }

  Color _resultColor(String disease) {
    final d = disease.toLowerCase();
    if (d.contains('healthy'))      return Colors.green.shade700;
    if (d.contains('blight'))       return Colors.orange.shade700;
    if (d.contains('phyllosticta')) return Colors.red.shade700;
    return Colors.black;
  }

  // ================= PDF DOWNLOAD =================
  Future<void> _downloadPdf(AppStrings strings) async {
    if (_allScans.isEmpty || _downloading) return;
    setState(() => _downloading = true);

    // ===== SHOW LOADING SNACKBAR =====
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const SizedBox(
              width: 16, height: 16,
              child: CircularProgressIndicator(
                  strokeWidth: 2, color: Colors.white),
            ),
            const SizedBox(width: 10),
            Text(strings.generatingPdf),
          ],
        ),
        backgroundColor: Colors.green.shade700,
        duration: const Duration(seconds: 60),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10)),
      ),
    );

    try {
      final pdf = pw.Document();

      // ===== LOAD LOGO =====
      pw.MemoryImage? logo;
      try {
        final data = await rootBundle.load('assets/images/logo.png');
        logo = pw.MemoryImage(data.buffer.asUint8List());
      } catch (_) {}

      // ===== STATS =====
      final int total    = _allScans.length;
      final int diseases = _allScans
          .where((s) => !s.disease.toLowerCase().contains('healthy'))
          .length;
      final int healthy  = total - diseases;

      pdf.addPage(
        pw.MultiPage(
          pageFormat: PdfPageFormat.a4,
          margin: const pw.EdgeInsets.all(24),

          // ===== HEADER =====
          header: (_) => pw.Container(
            padding: const pw.EdgeInsets.only(bottom: 12),
            decoration: const pw.BoxDecoration(
              border: pw.Border(
                bottom: pw.BorderSide(
                    color: PdfColors.green800, width: 2),
              ),
            ),
            child: pw.Row(
              children: [
                if (logo != null)
                  pw.Image(logo, width: 40, height: 40),
                pw.SizedBox(width: 12),
                pw.Expanded(
                  child: pw.Column(
                    crossAxisAlignment: pw.CrossAxisAlignment.start,
                    children: [
                      pw.Text(
                        strings.appName,
                        style: pw.TextStyle(
                          fontSize: 18,
                          fontWeight: pw.FontWeight.bold,
                          color: PdfColors.green800,
                        ),
                      ),
                      pw.Text(
                        strings.historyPdfSubtitle,
                        style: const pw.TextStyle(
                          fontSize: 10,
                          color: PdfColors.grey700,
                        ),
                      ),
                    ],
                  ),
                ),
                pw.Text(
                  'Generated: ${_formatDate(DateTime.now())}',
                  style: const pw.TextStyle(
                    fontSize: 9,
                    color: PdfColors.grey600,
                  ),
                ),
              ],
            ),
          ),

          // ===== FOOTER =====
          footer: (ctx) => pw.Container(
            padding: const pw.EdgeInsets.only(top: 8),
            decoration: const pw.BoxDecoration(
              border: pw.Border(
                top: pw.BorderSide(
                    color: PdfColors.grey300, width: 0.5),
              ),
            ),
            child: pw.Row(
              mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
              children: [
                pw.Text(
                  strings.appName,
                  style: const pw.TextStyle(
                      fontSize: 8, color: PdfColors.grey500),
                ),
                pw.Text(
                  '${strings.page} ${ctx.pageNumber}/${ctx.pagesCount}',
                  style: const pw.TextStyle(
                      fontSize: 8, color: PdfColors.grey500),
                ),
              ],
            ),
          ),

          build: (_) => [
            pw.SizedBox(height: 12),

            // ===== SUMMARY CARDS =====
            pw.Row(
              children: [
                _pdfStatBox('Total Scans', '$total',
                    PdfColors.blue800),
                pw.SizedBox(width: 8),
                _pdfStatBox('Diseases', '$diseases',
                    PdfColors.red800),
                pw.SizedBox(width: 8),
                _pdfStatBox('Healthy', '$healthy',
                    PdfColors.green800),
              ],
            ),

            pw.SizedBox(height: 16),

            // ===== TABLE =====
            pw.Table(
              border: pw.TableBorder.all(
                  color: PdfColors.grey400, width: 0.5),
              columnWidths: {
                0: const pw.FixedColumnWidth(55),  // image
                1: const pw.FlexColumnWidth(2.5),  // disease
                2: const pw.FlexColumnWidth(1.8),  // stage
                3: const pw.FlexColumnWidth(1.5),  // confidence
                4: const pw.FlexColumnWidth(1.2),  // area
                5: const pw.FlexColumnWidth(1.2),  // spots
                6: const pw.FlexColumnWidth(2.0),  // date
              },
              children: [
                // ===== HEADER ROW =====
                pw.TableRow(
                  decoration: const pw.BoxDecoration(
                      color: PdfColors.green800),
                  children: [
                    _pdfHeader(strings.image),
                    _pdfHeader(strings.disease),
                    _pdfHeader('Stage'),
                    _pdfHeader(strings.confidence),
                    _pdfHeader('Area %'),
                    _pdfHeader('Spots'),
                    _pdfHeader(strings.date),
                  ],
                ),

                // ===== DATA ROWS =====
                ..._allScans.asMap().entries.map((entry) {
                  final i    = entry.key;
                  final scan = entry.value;
                  final bg   = i.isEven
                      ? PdfColors.grey100
                      : PdfColors.white;
                  final isHealthy = scan.disease
                      .toLowerCase()
                      .contains('healthy');

                  // Image cell
                  pw.Widget imageCell = pw.Center(
                      child: pw.Text('N/A',
                          style: const pw.TextStyle(fontSize: 8)));
                  try {
                    final f = File(scan.imagePath);
                    if (f.existsSync()) {
                      imageCell = pw.Image(
                        pw.MemoryImage(f.readAsBytesSync()),
                        width: 50, height: 50,
                        fit: pw.BoxFit.cover,
                      );
                    }
                  } catch (_) {}

                  return pw.TableRow(
                    decoration:
                    pw.BoxDecoration(color: bg),
                    children: [
                      // Image
                      pw.Padding(
                        padding: const pw.EdgeInsets.all(4),
                        child: imageCell,
                      ),
                      // Disease
                      pw.Padding(
                        padding: const pw.EdgeInsets.all(6),
                        child: pw.Text(
                          strings.localizedDisease(scan.disease),
                          style: pw.TextStyle(
                            fontSize: 9,
                            fontWeight: pw.FontWeight.bold,
                            color: isHealthy
                                ? PdfColors.green800
                                : PdfColors.red800,
                          ),
                        ),
                      ),
                      // Stage
                      pw.Padding(
                        padding: const pw.EdgeInsets.all(6),
                        child: pw.Text(
                          scan.stage,
                          style: pw.TextStyle(
                            fontSize: 9,
                            color: scan.stage == 'Initial Stage'
                                ? PdfColors.orange800
                                : scan.stage == 'Advanced Stage'
                                ? PdfColors.red800
                                : PdfColors.grey700,
                          ),
                        ),
                      ),
                      // Confidence
                      _pdfCell(
                          '${(scan.confidence * 100).toStringAsFixed(1)}%'),
                      // Area
                      _pdfCell(
                          '${(scan.affectedArea * 100).toStringAsFixed(1)}%'),
                      // Spots
                      _pdfCell(scan.spotCount != null
                          ? '${scan.spotCount}'
                          : '-'),
                      // Date
                      _pdfCell(_formatDate(scan.timestamp)),
                    ],
                  );
                }),
              ],
            ),
          ],
        ),
      );

      // ===== SAVE TO APP DOCUMENTS DIR (always writable) =====
      final Uint8List pdfBytes = await pdf.save();
      final Directory dir =
      await getApplicationDocumentsDirectory();
      final String fileName =
          'CardoDisDetect_${DateTime.now().millisecondsSinceEpoch}.pdf';
      final String filePath = '${dir.path}/$fileName';
      final File pdfFile = File(filePath);
      await pdfFile.writeAsBytes(pdfBytes);

      if (!mounted) return;
      ScaffoldMessenger.of(context).hideCurrentSnackBar();
      setState(() => _downloading = false);

      // ===== TRY OPEN FILE =====
      final result = await OpenFile.open(filePath);
      if (result.type != ResultType.done) {
        // ===== FALLBACK: printing package share dialog =====
        await Printing.layoutPdf(
          onLayout: (_) async => pdfBytes,
          name: fileName,
        );
      }

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: [
              const Icon(Icons.check_circle,
                  color: Colors.white, size: 16),
              const SizedBox(width: 8),
              Text(strings.pdfDownloaded),
            ],
          ),
          backgroundColor: Colors.green.shade700,
          duration: const Duration(seconds: 3),
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10)),
        ),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).hideCurrentSnackBar();
      setState(() => _downloading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: [
              const Icon(Icons.error_outline,
                  color: Colors.white, size: 16),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  '${strings.pdfFailed}: $e',
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
          backgroundColor: Colors.red.shade700,
          duration: const Duration(seconds: 4),
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10)),
        ),
      );
    }
  }

  // ================= LIST UI =================
  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<AppLanguage>(
      valueListenable: appLanguage,
      builder: (_, lang, __) {
        final strings = AppStrings.of(lang);

        return Scaffold(
          backgroundColor: const Color(0xFF0F1F12),
          appBar: AppBar(
            backgroundColor: Colors.green.shade700,
            elevation: 0,
            title: Text(
              strings.history,
              style: const TextStyle(
                fontWeight: FontWeight.w700,
                color: Colors.white,
              ),
            ),
            iconTheme: const IconThemeData(color: Colors.white),
            actions: [
              if (!_loading && _allScans.isNotEmpty)
                IconButton(
                  icon: _downloading
                      ? const SizedBox(
                    width: 20, height: 20,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: Colors.white,
                    ),
                  )
                      : const Icon(Icons.download,
                      color: Colors.white),
                  tooltip: strings.downloadPdf,
                  onPressed: _downloading
                      ? null
                      : () => _downloadPdf(strings),
                ),
            ],
          ),

          body: SafeArea(
            top: false,
            child: _loading
                ? const Center(
                child: CircularProgressIndicator(
                    color: Colors.green))
                : _allScans.isEmpty
                ? Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(
                    Icons.history_outlined,
                    color: Colors.white24,
                    size: 64,
                  ),
                  const SizedBox(height: 12),
                  Text(
                    strings.noHistory,
                    style: const TextStyle(
                      color: Colors.white54,
                      fontSize: 16,
                    ),
                  ),
                ],
              ),
            )
                : ListView.builder(
              padding: EdgeInsets.fromLTRB(
                14, 14, 14,
                MediaQuery.of(context).padding.bottom + 14,
              ),
              itemCount: _allScans.length,
              itemBuilder: (_, i) {
                final scan = _allScans[i];
                return _HistoryCard(
                  scan:    scan,
                  strings: strings,
                  color:   _resultColor(scan.disease),
                  onTap:   () => Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) =>
                          ResultScreen(result: scan),
                    ),
                  ),
                );
              },
            ),
          ),
        );
      },
    );
  }

  String _formatDate(DateTime t) =>
      '${t.day}/${t.month}/${t.year} '
          '${t.hour.toString().padLeft(2, '0')}:'
          '${t.minute.toString().padLeft(2, '0')}';
}

// ================= HISTORY CARD =================
class _HistoryCard extends StatelessWidget {
  final ScanResult   scan;
  final AppStrings   strings;
  final Color        color;
  final VoidCallback onTap;

  const _HistoryCard({
    required this.scan,
    required this.strings,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 10),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: const Color(0xFF132218),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: color.withValues(alpha: 0.3),
            width: 1,
          ),
        ),
        child: Row(
          children: [
            // ===== IMAGE =====
            ClipRRect(
              borderRadius: BorderRadius.circular(10),
              child: Image.file(
                File(scan.imagePath),
                width: 64, height: 64,
                fit: BoxFit.cover,
                errorBuilder: (_, __, ___) => Container(
                  width: 64, height: 64,
                  decoration: BoxDecoration(
                    color: Colors.white10,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Icon(Icons.broken_image,
                      color: Colors.white38, size: 28),
                ),
              ),
            ),

            const SizedBox(width: 12),

            // ===== INFO =====
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Disease name
                  Text(
                    strings.localizedDisease(scan.disease),
                    style: TextStyle(
                      fontWeight: FontWeight.w700,
                      fontSize: 14,
                      color: color,
                    ),
                  ),
                  const SizedBox(height: 4),
                  // Confidence + Stage
                  Text(
                    '${strings.confidence}: '
                        '${(scan.confidence * 100).toStringAsFixed(1)}%'
                        '  •  ${scan.stage}',
                    style: const TextStyle(
                      fontSize: 11,
                      color: Colors.white60,
                    ),
                  ),
                  // Spots + Area
                  if (scan.spotCount != null)
                    Text(
                      'Spots: ${scan.spotCount}'
                          '  •  Area: '
                          '${(scan.affectedArea * 100).toStringAsFixed(1)}%',
                      style: TextStyle(
                        fontSize: 11,
                        color: Colors.redAccent.shade100,
                      ),
                    ),
                  const SizedBox(height: 2),
                  // Date
                  Text(
                    _formatDate(scan.timestamp),
                    style: const TextStyle(
                      fontSize: 10,
                      color: Colors.white38,
                    ),
                  ),
                ],
              ),
            ),

            // ===== CHEVRON =====
            const Icon(
              Icons.chevron_right,
              color: Colors.white24,
              size: 20,
            ),
          ],
        ),
      ),
    );
  }

  String _formatDate(DateTime t) =>
      '${t.day}/${t.month}/${t.year} '
          '${t.hour.toString().padLeft(2, '0')}:'
          '${t.minute.toString().padLeft(2, '0')}';
}

// ================= PDF HELPERS =================
pw.Widget _pdfHeader(String text) => pw.Padding(
  padding: const pw.EdgeInsets.symmetric(
      horizontal: 6, vertical: 6),
  child: pw.Text(
    text,
    style: pw.TextStyle(
      fontWeight: pw.FontWeight.bold,
      fontSize: 9,
      color: PdfColors.white,
    ),
  ),
);

pw.Widget _pdfCell(String text) => pw.Padding(
  padding: const pw.EdgeInsets.symmetric(
      horizontal: 6, vertical: 6),
  child: pw.Text(
    text,
    style: const pw.TextStyle(fontSize: 9),
  ),
);

pw.Widget _pdfStatBox(
    String label, String value, PdfColor color) {
  return pw.Expanded(
    child: pw.Container(
      padding: const pw.EdgeInsets.symmetric(
          vertical: 10, horizontal: 8),
      decoration: pw.BoxDecoration(
        color: color,
        borderRadius: pw.BorderRadius.circular(6),
      ),
      child: pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.center,
        children: [
          pw.Text(
            value,
            style: pw.TextStyle(
              fontSize: 20,
              fontWeight: pw.FontWeight.bold,
              color: PdfColors.white,
            ),
          ),
          pw.SizedBox(height: 2),
          pw.Text(
            label,
            style: const pw.TextStyle(
              fontSize: 9,
              color: PdfColors.white,
            ),
          ),
        ],
      ),
    ),
  );
}