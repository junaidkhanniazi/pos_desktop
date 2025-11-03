import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:logger/logger.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

class SyncService {
  final _logger = Logger();
  final String ownerName = "junaid";
  late final String serverBaseUrl = "http://127.0.0.1:8081/api/sync/$ownerName";

  Future<void> pushUnsyncedData(String storeDbPath) async {
    sqfliteFfiInit();
    databaseFactory = databaseFactoryFfi;

    final db = await databaseFactoryFfi.openDatabase(storeDbPath);
    _logger.i('🚀 Starting push for → $storeDbPath');

    // TEMP: Insert fake unsynced record for testing

    const baseUrl = 'http://127.0.0.1:8081/api/sync/junaid/upload';

    final tables = await db.rawQuery(
      "SELECT name FROM sqlite_master WHERE type='table'",
    );

    for (final t in tables) {
      final table = t['name'] as String;
      if (table == 'sqlite_sequence' || table == 'sync_metadata') continue;

      // Check if table has sync support
      final info = await db.rawQuery('PRAGMA table_info($table)');
      final hasSync = info.any((c) => c['name'] == 'is_synced');
      if (!hasSync) continue;

      // Get unsynced rows
      final rows = await db.rawQuery(
        'SELECT * FROM $table WHERE is_synced = 0',
      );
      if (rows.isEmpty) continue;

      _logger.w('⬆️ Sending ${rows.length} unsynced row(s) from [$table]...');

      // Send POST to your local server
      final uri = Uri.parse('$baseUrl/$table');
      final response = await http.post(
        uri,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'data': rows}),
      );

      if (response.statusCode == 200) {
        _logger.i('✅ Server accepted data for [$table]');
        await db.update(table, {'is_synced': 1}, where: 'is_synced = 0');
      } else {
        _logger.e('❌ Failed to upload [$table]: ${response.body}');
      }
    }

    _logger.i('🎉 Push sync complete!');
    await db.close();
  }

  Future<void> pullFromServer(String storeDbPath) async {
    sqfliteFfiInit();
    final db = await databaseFactoryFfi.openDatabase(storeDbPath);

    _logger.i("⬇️ Pulling data into $storeDbPath");

    final tables = ['customers', 'products'];

    for (final table in tables) {
      final url = Uri.parse("$serverBaseUrl/download/$table");
      final res = await http.get(url);

      if (res.statusCode == 200) {
        final jsonData = jsonDecode(res.body);
        final List<dynamic> data = jsonData['data'];
        if (data.isEmpty) continue;

        _logger.w("⬇️ Received ${data.length} record(s) for $table");

        for (final record in data) {
          await db.insert(
            table,
            Map<String, dynamic>.from(record),
            conflictAlgorithm: ConflictAlgorithm.replace,
          );
        }

        _logger.i("✅ Imported ${data.length} into $table");
      } else {
        _logger.e("❌ Failed to pull $table: ${res.body}");
      }
    }

    await db.close();
  }
}
