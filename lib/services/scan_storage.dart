import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../core/models/scan_result.dart';

class ScanStorage {
  static const String _key = 'scan_results';

  /// Save a single scan result
  static Future<void> saveScan(ScanResult result) async {
    final prefs = await SharedPreferences.getInstance();
    final List<String> existing =
        prefs.getStringList(_key) ?? [];

    existing.add(jsonEncode(result.toJson()));

    await prefs.setStringList(_key, existing);
  }

  /// Load all saved scan results
  static Future<List<ScanResult>> loadScans() async {
    final prefs = await SharedPreferences.getInstance();
    final List<String> data =
        prefs.getStringList(_key) ?? [];

    final List<ScanResult> results = [];

    for (final item in data) {
      try {
        final decoded = jsonDecode(item);
        results.add(ScanResult.fromJson(decoded));
      } catch (e) {
        // Skip corrupted entry instead of crashing
        continue;
      }
    }

    return results;
  }

  /// Delete one scan by index
  static Future<void> deleteScan(int index) async {
    final prefs = await SharedPreferences.getInstance();
    final List<String> data =
        prefs.getStringList(_key) ?? [];

    if (index < 0 || index >= data.length) return;

    data.removeAt(index);
    await prefs.setStringList(_key, data);
  }

  /// Clear entire scan history
  static Future<void> clearAll() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_key);
  }
}
