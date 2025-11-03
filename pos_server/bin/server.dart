import 'dart:io';
import 'dart:convert';
import 'package:shelf/shelf.dart';
import 'package:shelf/shelf_io.dart' as io;
import 'package:shelf_router/shelf_router.dart';

void main() async {
  final app = Router();

  // 🧠 Multi-owner in-memory data store
  final Map<String, Map<String, List<Map<String, dynamic>>>> ownerStore = {};

  // ✅ Upload route (Flutter -> Server)
  app.post('/api/sync/<owner>/upload/<table>', (
    Request req,
    String owner,
    String table,
  ) async {
    ownerStore.putIfAbsent(
      owner,
      () => {
        'customers': <Map<String, dynamic>>[],
        'products': <Map<String, dynamic>>[],
      },
    );

    final body = await req.readAsString();
    final jsonBody = jsonDecode(body);
    final rows = (jsonBody['data'] as List).cast<Map<String, dynamic>>();

    ownerStore[owner]![table] ??= [];
    ownerStore[owner]![table]!.addAll(rows);

    print('⬆️ [$owner] uploaded ${rows.length} record(s) into [$table]');
    return Response.ok(jsonEncode({'status': 'ok', 'received': rows.length}));
  });

  // ✅ Download route (Server -> Flutter)
  app.get('/api/sync/<owner>/download/<table>', (
    Request req,
    String owner,
    String table,
  ) {
    if (!ownerStore.containsKey(owner)) {
      print('⚠️ No data yet for owner: $owner');
      return Response.ok(jsonEncode({'data': []}));
    }

    final data = ownerStore[owner]![table] ?? [];
    print('⬇️ [$owner] requested $table → ${data.length} record(s)');
    return Response.ok(jsonEncode({'data': data}));
  });

  // fallback route
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
