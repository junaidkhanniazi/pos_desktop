import 'dart:io';
import 'dart:convert';
import 'package:shelf/shelf.dart';
import 'package:shelf_router/shelf_router.dart';
import 'package:shelf/shelf_io.dart' as io;
import 'package:mysql1/mysql1.dart';

void main() async {
  final app = Router();

  // MySQL Connection Settings (XAMPP default)
  final settings = ConnectionSettings(
    host: '127.0.0.1',
    port: 3306,
    user: 'root',
    password: null, // instead of empty string
    db: 'pos_system',
  );

  try {
    final conn = await MySqlConnection.connect(settings);
    print('✅ MySQL connected successfully!');
    await conn.close();
  } catch (e) {
    print('❌ Connection failed: $e');
  }

  // -------------------------
  // Upload route
  // -------------------------
  app.post('/api/sync/<owner>/upload/<table>', (
    Request req,
    String owner,
    String table,
  ) async {
    final conn = await MySqlConnection.connect(settings);

    final body = await req.readAsString();
    final jsonBody = jsonDecode(body);
    final rows = (jsonBody['data'] as List).cast<Map<String, dynamic>>();

    if (rows.isEmpty) {
      await conn.close();
      return Response.ok(jsonEncode({'status': 'ok', 'received': 0}));
    }

    for (final row in rows) {
      final keys = row.keys.join(', ');
      final values = row.values
          .map((v) => "'${v.toString().replaceAll("'", "\\'")}'")
          .join(', ');

      final query =
          'INSERT INTO $table ($keys) VALUES ($values) '
          'ON DUPLICATE KEY UPDATE ${row.keys.map((k) => "$k=VALUES($k)").join(', ')}';

      try {
        await conn.query(query);
      } catch (e) {
        print('❌ Failed to insert row into $table: $e');
      }
    }

    print('⬆️ [$owner] uploaded ${rows.length} rows into [$table]');
    await conn.close();
    return Response.ok(jsonEncode({'status': 'ok', 'received': rows.length}));
  });

  // -------------------------
  // Download route
  // -------------------------
  app.get('/api/sync/<owner>/download/<table>', (
    Request req,
    String owner,
    String table,
  ) async {
    final conn = await MySqlConnection.connect(settings);

    List<Map<String, dynamic>> data = [];
    try {
      final results = await conn.query(
        'SELECT * FROM $table WHERE owner_name = ?',
        [owner],
      );
      for (var row in results) {
        final map = <String, dynamic>{};
        row.fields.forEach((k, v) => map[k] = v);
        data.add(map);
      }
      print('⬇️ [$owner] requested $table → ${data.length} rows');
    } catch (e) {
      print('❌ Failed to fetch $table for $owner: $e');
    }

    await conn.close();
    return Response.ok(jsonEncode({'data': data}));
  });

  // -------------------------
  // Super Admin endpoint
  // -------------------------
  app.get('/api/sync/super_admin/download/all', (Request req) async {
    final conn = await MySqlConnection.connect(settings);
    Map<String, List<Map<String, dynamic>>> allData = {};

    final tables = [
      'owners',
      'stores',
      'products',
      'customers',
      'sales',
      'suppliers',
      'expenses',
    ];
    for (final table in tables) {
      List<Map<String, dynamic>> tableData = [];
      try {
        final results = await conn.query('SELECT * FROM $table');
        for (var row in results) {
          final map = <String, dynamic>{};
          row.fields.forEach((k, v) => map[k] = v);
          tableData.add(map);
        }
        allData[table] = tableData;
        print('⬇️ Super Admin fetched $table → ${tableData.length} rows');
      } catch (e) {
        print('❌ Failed to fetch $table: $e');
      }
    }

    await conn.close();
    return Response.ok(jsonEncode({'data': allData}));
  });

  // -------------------------
  // fallback route
  // -------------------------
  app.all('/<ignored|.*>', (Request req) {
    return Response.notFound(
      jsonEncode({'error': 'Route not found: ${req.url}'}),
    );
  });

  final port = int.parse(Platform.environment['PORT'] ?? '8081');
  final handler = const Pipeline()
      .addMiddleware(logRequests())
      .addHandler(app.call);

  final server = await io.serve(handler, InternetAddress.anyIPv4, port);
  print('🚀 Server running at http://${server.address.host}:${server.port}');
}
