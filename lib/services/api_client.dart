import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:flutter/foundation.dart';

class ApiClient {
  ApiClient({required this.baseUrl});

  final String baseUrl;

  Uri _uri(String path) {
    final normalizedBase = baseUrl.endsWith('/')
        ? baseUrl.substring(0, baseUrl.length - 1)
        : baseUrl;
    final normalizedPath = path.startsWith('/') ? path : '/$path';
    return Uri.parse('$normalizedBase$normalizedPath');
  }

  Future<Map<String, dynamic>> postJson(
    String path, {
    Map<String, dynamic>? body,
    String? loginToken,
  }) async {
    final headers = <String, String>{
      'Content-Type': 'application/json',
      'Accept': 'application/json',
    };

    if (loginToken != null && loginToken.isNotEmpty) {
      headers['login_token'] = loginToken;
      // Keep hyphen version as fallback.
      headers['login-token'] = loginToken;
    }

    final uri = _uri(path);
    final payload = jsonEncode(body ?? const <String, dynamic>{});

    try {
      final res = await http.post(
        uri,
        headers: headers,
        body: payload,
      );

      final text = res.body;
      Map<String, dynamic> decoded;
      try {
        decoded = (text.isEmpty ? <String, dynamic>{} : jsonDecode(text))
            as Map<String, dynamic>;
      } catch (_) {
        decoded = <String, dynamic>{'raw': text};
      }

      if (res.statusCode < 200 || res.statusCode >= 300) {
        final message = decoded['message']?.toString() ??
            decoded['error']?.toString() ??
            decoded['raw']?.toString() ??
            'Request failed (${res.statusCode})';
        throw ApiException(
          message: '$message\nURL: $uri',
          statusCode: res.statusCode,
        );
      }

      return decoded;
    } on http.ClientException catch (e) {
      // Common on Flutter Web when backend blocks CORS:
      // "ClientException: XMLHttpRequest error."
      throw ApiException(
        message:
            'Network error: $e\nURL: $uri\nIf you are on Chrome/Web, this is often a CORS issue on the backend.',
      );
    } catch (e) {
      debugPrint('Request failed: $e');
      throw ApiException(message: 'Unexpected error: $e\nURL: $uri');
    }
  }
}

class ApiException implements Exception {
  ApiException({required this.message, this.statusCode});

  final String message;
  final int? statusCode;

  @override
  String toString() => statusCode == null ? message : '$message ($statusCode)';
}

