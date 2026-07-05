import 'dart:async';
import 'dart:convert';

import 'package:http/http.dart' as http;

import 'api_exception.dart';
import 'api_request.dart';
import 'api_response.dart';
import 'interceptor.dart';
import 'retry_policy.dart';

// Small HTTP client on top of package:http:
//   - configurable base URL + timeout
//   - ordered interceptors (auth, logging, ...)
//   - retry with exponential backoff for flaky calls
//   - JSON encode/decode and a typed ApiException
// The http.Client is injectable, so it's easy to test with MockClient.
class ApiClient {
  ApiClient({
    required this.baseUrl,
    http.Client? httpClient,
    this.interceptors = const [],
    this.retryPolicy = const RetryPolicy(),
    this.timeout = const Duration(seconds: 15),
    this.defaultHeaders = const {'Accept': 'application/json'},
  }) : _http = httpClient ?? http.Client();

  final String baseUrl;
  final List<ApiInterceptor> interceptors;
  final RetryPolicy retryPolicy;
  final Duration timeout;
  final Map<String, String> defaultHeaders;

  final http.Client _http;

  Future<ApiResponse> get(String path, {Map<String, String>? query}) =>
      send(ApiRequest(method: HttpMethod.get, path: path, query: query ?? {}));

  Future<ApiResponse> post(String path, {Object? body}) =>
      send(ApiRequest(method: HttpMethod.post, path: path, body: body));

  Future<ApiResponse> put(String path, {Object? body}) =>
      send(ApiRequest(method: HttpMethod.put, path: path, body: body));

  Future<ApiResponse> patch(String path, {Object? body}) =>
      send(ApiRequest(method: HttpMethod.patch, path: path, body: body));

  Future<ApiResponse> delete(String path, {Object? body}) =>
      send(ApiRequest(method: HttpMethod.delete, path: path, body: body));

  // Runs the request through the interceptors, retrying on flaky failures.
  Future<ApiResponse> send(ApiRequest request) async {
    var attempt = 0;
    while (true) {
      try {
        return await _sendOnce(request);
      } on ApiException catch (e) {
        if (!e.isRetryable || attempt >= retryPolicy.maxRetries) rethrow;
        await Future<void>.delayed(retryPolicy.delayFor(attempt));
        attempt++;
      }
    }
  }

  Future<ApiResponse> _sendOnce(ApiRequest original) async {
    // Request interceptors, in order.
    var request = original.withHeaders(defaultHeaders);
    for (final interceptor in interceptors) {
      request = await interceptor.onRequest(request);
    }

    final uri = _resolve(request);
    final headers = {...request.headers};
    Object? encodedBody;
    if (request.body != null) {
      headers.putIfAbsent('Content-Type', () => 'application/json');
      encodedBody = jsonEncode(request.body);
    }

    late final http.Response raw;
    try {
      raw = await _dispatch(request.method, uri, headers, encodedBody)
          .timeout(timeout);
    } on TimeoutException {
      throw const ApiException(message: 'Request timed out');
    } catch (e) {
      throw ApiException(message: 'Network error: $e');
    }

    final decoded = _decode(raw.body);
    final response = ApiResponse(
      statusCode: raw.statusCode,
      data: decoded,
      headers: raw.headers,
    );

    if (!response.isSuccess) {
      throw _errorFrom(response);
    }

    // Response interceptors, reverse order.
    for (final interceptor in interceptors.reversed) {
      await interceptor.onResponse(request, response);
    }
    return response;
  }

  Future<http.Response> _dispatch(
    HttpMethod method,
    Uri uri,
    Map<String, String> headers,
    Object? body,
  ) {
    switch (method) {
      case HttpMethod.get:
        return _http.get(uri, headers: headers);
      case HttpMethod.post:
        return _http.post(uri, headers: headers, body: body);
      case HttpMethod.put:
        return _http.put(uri, headers: headers, body: body);
      case HttpMethod.patch:
        return _http.patch(uri, headers: headers, body: body);
      case HttpMethod.delete:
        return _http.delete(uri, headers: headers, body: body);
    }
  }

  Uri _resolve(ApiRequest request) {
    final base = Uri.parse('$baseUrl${request.path}');
    if (request.query.isEmpty) return base;
    return base.replace(queryParameters: {...base.queryParameters, ...request.query});
  }

  Object? _decode(String body) {
    if (body.isEmpty) return null;
    try {
      return jsonDecode(body);
    } on FormatException {
      return body; // Not JSON, just hand back the raw text.
    }
  }

  ApiException _errorFrom(ApiResponse response) {
    final data = response.data;
    String? code;
    String message = 'Request failed (${response.statusCode})';
    if (data is Map<String, dynamic>) {
      code = data['code'] as String?;
      message = (data['message'] as String?) ?? message;
    }
    return ApiException(
      statusCode: response.statusCode,
      code: code,
      message: message,
      data: data,
    );
  }

  // Close the underlying http client.
  void close() => _http.close();
}
