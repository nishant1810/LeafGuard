import 'dart:io';
import 'package:crypto/crypto.dart';

class PredictionCache {
  static final Map<String, Map> _cache = {};

  static String hash(File file) {
    final bytes = file.readAsBytesSync();
    return md5.convert(bytes).toString();
  }

  static Map? get(File file) {
    return _cache[hash(file)];
  }

  static void save(File file, Map result) {
    _cache[hash(file)] = result;
  }
}
