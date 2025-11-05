import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:logger/logger.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'package:sqflite_common/sqlite_api.dart';

class SyncService {
  final _logger = Logger();
  final String ownerName;
  late final String serverBaseUrl;

  SyncService({required this.ownerName}) {
    sqfliteFfiInit();
    databaseFactory = databaseFactoryFfi;
    serverBaseUrl = 'http://127.0.0.1:8081/api/sync/$ownerName';
  }

  /// Push all unsynced rows from all tables in local DB
  Future<void> pushDatabase(String dbPath) async {
    final db = await databaseFactoryFfi.openDatabase(dbPath);
    _logger.i('🚀 Starting push for DB: $dbPath');

    final tablesQuery = await db.rawQuery(
      "SELECT name FROM sqlite_master WHERE type='table'",
    );

    for (final t in tablesQuery) {
      final table = t['name'] as String;
      if (table == 'sqlite_sequence') continue;

      final info = await db.rawQuery('PRAGMA table_info($table)');
      final hasSync = info.any(
        (c) => (c['name'] as String).toLowerCase() == 'is_synced',
      );
      if (!hasSync) {
        _logger.w('⚠️ Skipping table $table (no is_synced column)');
        continue;
      }

      final rows = await db.rawQuery(
        'SELECT * FROM $table WHERE is_synced = 0',
      );
      if (rows.isEmpty) {
        _logger.i('✅ No unsynced rows for $table');
        continue;
      }

      _logger.w('⬆️ Sending ${rows.length} rows for [$table]');

      try {
        final uri = Uri.parse('$serverBaseUrl/upload/$table');
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
      } catch (e) {
        _logger.e('❌ Exception uploading $table: $e');
      }
    }

    await db.close();
    _logger.i('🎉 Push complete!');
  }

  /// Pull data from server for specified tables
  Future<void> pullDatabase(String dbPath, [List<String>? tables]) async {
    final db = await databaseFactoryFfi.openDatabase(dbPath);
    _logger.i('⬇️ Pulling tables from server into DB: $dbPath');

    // Auto-detect tables if not provided
    if (tables == null) {
      final tablesQuery = await db.rawQuery(
        "SELECT name FROM sqlite_master WHERE type='table'",
      );
      tables = tablesQuery
          .map((t) => t['name'] as String)
          .where((t) => t != 'sqlite_sequence')
          .toList();
    }

    for (final table in tables) {
      try {
        final url = Uri.parse('$serverBaseUrl/download/$table');
        final res = await http.get(url);

        if (res.statusCode == 200) {
          final jsonData = jsonDecode(res.body);
          final List<dynamic> data = jsonData['data'];
          if (data.isEmpty) {
            _logger.i('ℹ️ No new data for $table');
            continue;
          }

          _logger.w('⬇️ Received ${data.length} rows for $table');
          for (final row in data) {
            await db.insert(
              table,
              Map<String, dynamic>.from(row),
              conflictAlgorithm: ConflictAlgorithm.replace,
            );
          }

          _logger.i('✅ Imported ${data.length} rows into $table');
        } else {
          _logger.e('❌ Failed to pull $table: ${res.body}');
        }
      } catch (e) {
        _logger.e('❌ Exception pulling $table: $e');
      }
    }

    await db.close();
    _logger.i('🎉 Pull complete!');
  }
}
