import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:logger/logger.dart';

class SyncAPI {
  final _logger = Logger();

  /// your base API endpoint (replace with your actual backend later)
  final String baseUrl = 'https://example.com/api'; // 👈 change later

  /// Upload unsynced rows to cloud
  Future<bool> pushData({
    required String tableName,
    required List<Map<String, dynamic>> records,
  }) async {
    try {
      if (records.isEmpty) return true;

      final url = Uri.parse('$baseUrl/sync/upload/$tableName');
      final res = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'data': records}),
      );

      if (res.statusCode == 200) {
        _logger.i('☁️ Uploaded ${records.length} → $tableName');
        return true;
      } else {
        _logger.e('❌ Upload failed for $tableName → ${res.statusCode}');
        return false;
      }
    } catch (e) {
      _logger.e('⚠️ pushData error: $e');
      return false;
    }
  }

  /// Download new/updated records from server
  Future<List<Map<String, dynamic>>> pullData({
    required String tableName,
    required DateTime lastSync,
  }) async {
    try {
      final url = Uri.parse(
        '$baseUrl/sync/download/$tableName?since=${lastSync.toIso8601String()}',
      );
      final res = await http.get(url);

      if (res.statusCode == 200) {
        final json = jsonDecode(res.body);
        final list = (json['data'] as List).cast<Map<String, dynamic>>();
        _logger.i('⬇️ Pulled ${list.length} records for $tableName');
        return list;
      } else {
        _logger.e('❌ Pull failed for $tableName → ${res.statusCode}');
        return [];
      }
    } catch (e) {
      _logger.e('⚠️ pullData error: $e');
      return [];
    }
  }
}
