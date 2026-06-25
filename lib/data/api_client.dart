import 'dart:convert';
import 'dart:io';

class ApiException implements Exception {
  final int statusCode;
  final String message;

  const ApiException(this.statusCode, this.message);

  @override
  String toString() => 'ApiException($statusCode): $message';
}

class ApiClient {
  ApiClient._();
  static final ApiClient instance = ApiClient._();

  static const String baseUrl = String.fromEnvironment(
    'API_BASE_URL',
    defaultValue: 'http://10.0.2.2:5090',
  );

  final HttpClient _client = HttpClient()
    ..connectionTimeout = const Duration(seconds: 5);

  Future<dynamic> get(String path) {
    return _send('GET', path);
  }

  Future<dynamic> post(String path, Map<String, dynamic> body) {
    return _send('POST', path, body: body);
  }

  Future<dynamic> put(String path, Map<String, dynamic> body) {
    return _send('PUT', path, body: body);
  }

  Future<void> delete(String path) async {
    await _send('DELETE', path);
  }

  Future<dynamic> _send(
    String method,
    String path, {
    Map<String, dynamic>? body,
  }) async {
    final uri = Uri.parse('$baseUrl$path');
    final request = await _client.openUrl(method, uri);
    request.headers.contentType = ContentType.json;
    request.headers.set(HttpHeaders.acceptHeader, ContentType.json.mimeType);

    if (body != null) {
      request.write(jsonEncode(_withoutNullValues(body)));
    }

    final response = await request.close();
    final responseBody = await response.transform(utf8.decoder).join();

    if (response.statusCode >= 200 && response.statusCode < 300) {
      if (responseBody.trim().isEmpty) return null;
      return jsonDecode(responseBody);
    }

    final message = responseBody.trim().isEmpty
        ? response.reasonPhrase
        : responseBody;
    throw ApiException(response.statusCode, message);
  }

  Map<String, dynamic> _withoutNullValues(Map<String, dynamic> body) {
    return Map.fromEntries(body.entries.where((entry) => entry.value != null));
  }
}
