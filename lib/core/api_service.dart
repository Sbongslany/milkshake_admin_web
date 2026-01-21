

import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../features/auth/auth_provider.dart';
import 'constants.dart';

final apiServiceProvider = Provider<ApiService>((ref) => ApiService(ref));

class ApiService {
  final Ref ref;

  ApiService(this.ref);

  Future<dynamic> get(String endpoint) async {
    final token = ref.read(authProvider)?.token;
    final response = await http.get(
      Uri.parse('$baseUrl/$endpoint'),
      headers: _headers(token),
    );
    return _handleResponse(response);
  }

  Future<dynamic> post(String endpoint, Map<String, dynamic> body) async {
    final token = ref.read(authProvider)?.token;
    final response = await http.post(
      Uri.parse('$baseUrl/$endpoint'),
      headers: _headers(token),
      body: jsonEncode(body),
    );
    return _handleResponse(response);
  }

  Future<dynamic> patch(String endpoint, Map<String, dynamic> body) async {
    final token = ref.read(authProvider)?.token;
    final response = await http.patch(
      Uri.parse('$baseUrl/$endpoint'),
      headers: _headers(token),
      body: jsonEncode(body),
    );
    return _handleResponse(response);
  }

  Future<dynamic> delete(String endpoint) async {
    final token = ref.read(authProvider)?.token;
    final response = await http.delete(
      Uri.parse('$baseUrl/$endpoint'),
      headers: _headers(token),
    );
    return _handleResponse(response);
  }

  Map<String, String> _headers(String? token) => {
    'Content-Type': 'application/json',
    if (token != null) 'Authorization': 'Bearer $token',
  };

  dynamic _handleResponse(http.Response response) {
    if (response.statusCode >= 200 && response.statusCode < 300) {
      if (response.body.isEmpty) return null;
      return jsonDecode(response.body); // Return dynamic (List or Map)
    }
    final errorMsg = response.body.isNotEmpty
        ? (jsonDecode(response.body)['message'] ?? 'Unknown error')
        : 'Server Error';
    throw Exception('$errorMsg (Status: ${response.statusCode})');
  }
}