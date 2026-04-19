import 'dart:convert';
import 'dart:io' show Platform;
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;

class ApiService {
  static String get baseUrl {
    if (kIsWeb) return 'http://localhost:8000';
    if (Platform.isAndroid) return 'http://10.0.2.2:8000';
    return 'http://localhost:8000';
  }

  String? _token;
  int? _patientId;

  int? get patientId => _patientId;
  bool get isAuthed => _token != null;

  void setAuth(String token, int pid) {
    _token = token;
    _patientId = pid;
  }

  void clearAuth() {
    _token = null;
    _patientId = null;
  }

  Map<String, String> _headers({bool json = false}) {
    final h = <String, String>{};
    if (json) h['Content-Type'] = 'application/json';
    if (_token != null) h['Authorization'] = 'Bearer $_token';
    return h;
  }

  Future<dynamic> getJson(String path) async {
    final res = await http.get(Uri.parse('$baseUrl$path'), headers: _headers());
    debugPrint('GET $path -> ${res.statusCode}');
    if (res.statusCode >= 400) {
      throw ApiException(res.statusCode, res.body);
    }
    return jsonDecode(res.body);
  }

  Future<dynamic> postJson(String path, Map<String, dynamic> body) async {
    final res = await http.post(
      Uri.parse('$baseUrl$path'),
      headers: _headers(json: true),
      body: jsonEncode(body),
    );
    debugPrint('POST $path -> ${res.statusCode}');
    if (res.statusCode >= 400) {
      throw ApiException(res.statusCode, res.body);
    }
    return jsonDecode(res.body);
  }

  Future<dynamic> deleteJson(String path) async {
    final res = await http.delete(Uri.parse('$baseUrl$path'), headers: _headers());
    debugPrint('DELETE $path -> ${res.statusCode}');
    if (res.statusCode >= 400) {
      throw ApiException(res.statusCode, res.body);
    }
    return jsonDecode(res.body);
  }
}

class ApiException implements Exception {
  final int status;
  final String body;
  ApiException(this.status, this.body);
  @override
  String toString() => 'ApiException($status): $body';
}
