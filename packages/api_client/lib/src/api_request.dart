/// Supported HTTP methods.
enum HttpMethod { get, post, put, patch, delete }

/// An immutable description of an outgoing HTTP request.
///
/// Interceptors receive and return an [ApiRequest], typically producing a copy
/// with extra headers (e.g. an auth token) via [copyWith].
class ApiRequest {
  const ApiRequest({
    required this.method,
    required this.path,
    this.headers = const {},
    this.query = const {},
    this.body,
  });

  final HttpMethod method;

  /// Path relative to the client's base URL, e.g. `/wallet/balance`.
  final String path;
  final Map<String, String> headers;
  final Map<String, String> query;

  /// A JSON-encodable body (Map/List/primitive), or `null` for no body.
  final Object? body;

  ApiRequest copyWith({
    HttpMethod? method,
    String? path,
    Map<String, String>? headers,
    Map<String, String>? query,
    Object? body,
  }) {
    return ApiRequest(
      method: method ?? this.method,
      path: path ?? this.path,
      headers: headers ?? this.headers,
      query: query ?? this.query,
      body: body ?? this.body,
    );
  }

  /// Returns a copy with [extra] merged into the existing headers.
  ApiRequest withHeaders(Map<String, String> extra) =>
      copyWith(headers: {...headers, ...extra});
}
