import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:logger/logger.dart';

class SyncApi {
  static final Logger _logger = Logger();

  // ⚙️ Base URL (your Node.js server)
  // 🔹 Use LAN IP if testing from physical device (e.g. 192.168.x.x)
  static const String baseUrl = "http://localhost:5000/api";

  // 🟢 Generic GET Request
  static Future<List<dynamic>> get(String endpoint) async {
    final url = Uri.parse("$baseUrl/$endpoint");
    _logger.i("🌐 GET → $url");

    try {
      final response = await http.get(
        url,
        headers: {"Content-Type": "application/json"},
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data is List) return data;
        if (data is Map && data['data'] is List) return data['data'];
        return [data];
      } else {
        _logger.e("❌ GET failed (${response.statusCode}): ${response.body}");
        throw Exception("GET failed (${response.statusCode})");
      }
    } catch (e) {
      _logger.e("❌ GET error: $e");
      rethrow;
    }
  }

  // 🔵 Generic POST Request
  static Future<dynamic> post(
    String endpoint,
    Map<String, dynamic> body,
  ) async {
    final url = Uri.parse("$baseUrl/$endpoint");
    _logger.i("⬆️ POST → $url \n📦 Body: $body");

    try {
      final response = await http.post(
        url,
        headers: {"Content-Type": "application/json"},
        body: jsonEncode(body),
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        final data = jsonDecode(response.body);
        _logger.i("✅ POST success: $data");
        return data;
      } else {
        _logger.e("❌ POST failed (${response.statusCode}): ${response.body}");
        throw Exception("POST failed (${response.statusCode})");
      }
    } catch (e) {
      _logger.e("❌ POST error: $e");
      rethrow;
    }
  }

  // 🟡 Generic PUT Request (for updates)
  static Future<dynamic> put(String endpoint, Map<String, dynamic> body) async {
    final url = Uri.parse("$baseUrl/$endpoint");
    _logger.i("🔄 PUT → $url \n📦 Body: $body");

    try {
      final response = await http.put(
        url,
        headers: {"Content-Type": "application/json"},
        body: jsonEncode(body),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        _logger.i("✅ PUT success: $data");
        return data;
      } else {
        _logger.e("❌ PUT failed (${response.statusCode}): ${response.body}");
        throw Exception("PUT failed (${response.statusCode})");
      }
    } catch (e) {
      _logger.e("❌ PUT error: $e");
      rethrow;
    }
  }

  // 🔴 Generic DELETE Request
  static Future<void> delete(String endpoint) async {
    final url = Uri.parse("$baseUrl/$endpoint");
    _logger.w("🗑️ DELETE → $url");

    try {
      final response = await http.delete(
        url,
        headers: {"Content-Type": "application/json"},
      );

      if (response.statusCode == 200) {
        _logger.i("✅ DELETE success");
      } else {
        _logger.e("❌ DELETE failed (${response.statusCode}): ${response.body}");
        throw Exception("DELETE failed (${response.statusCode})");
      }
    } catch (e) {
      _logger.e("❌ DELETE error: $e");
      rethrow;
    }
  }

  // 🟣 MULTIPART POST (File Upload)
  static Future<dynamic> postMultipart(
    String endpoint,
    Map<String, String> fields, {
    required String fileField,
    required String filePath,
  }) async {
    final url = Uri.parse("$baseUrl/$endpoint");
    _logger.i(
      "📤 POST Multipart → $url \n🗂 Fields: $fields \n📎 File: $filePath",
    );

    final request = http.MultipartRequest('POST', url)
      ..fields.addAll(fields)
      ..files.add(await http.MultipartFile.fromPath(fileField, filePath));

    try {
      final streamedResponse = await request.send();
      final response = await http.Response.fromStream(streamedResponse);

      _logger.i("📥 Response ${response.statusCode}: ${response.body}");

      if (response.statusCode == 200 || response.statusCode == 201) {
        final data = jsonDecode(response.body);
        _logger.i("✅ Multipart POST success: $data");
        return data;
      } else {
        _logger.e(
          "❌ Multipart POST failed (${response.statusCode}): ${response.body}",
        );
        throw Exception("Multipart POST failed (${response.statusCode})");
      }
    } catch (e) {
      _logger.e("❌ Multipart POST error: $e");
      rethrow;
    }
  }

  // ⚙️ Health Check (Optional)
  static Future<bool> checkServerHealth() async {
    try {
      final response = await http.get(Uri.parse("$baseUrl/../"));
      if (response.statusCode == 200) {
        _logger.i("✅ Server is online");
        return true;
      } else {
        _logger.w("⚠️ Server responded but not OK (${response.statusCode})");
        return false;
      }
    } catch (e) {
      _logger.w("🌐 Server not reachable: $e");
      return false;
    }
  }

  // 🟣 Generic GET Request for Single Object / Map Responses
  static Future<Map<String, dynamic>?> getSingle(String endpoint) async {
    final url = Uri.parse("$baseUrl/$endpoint");
    _logger.i("🌐 GET (single) → $url");

    try {
      final response = await http.get(
        url,
        headers: {"Content-Type": "application/json"},
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data is Map<String, dynamic>) return data;
        _logger.w("⚠️ Expected Map, got ${data.runtimeType}");
        return null;
      } else {
        _logger.e(
          "❌ GET (single) failed (${response.statusCode}): ${response.body}",
        );
        return null;
      }
    } catch (e) {
      _logger.e("❌ GET (single) error: $e");
      return null;
    }
  }
}
