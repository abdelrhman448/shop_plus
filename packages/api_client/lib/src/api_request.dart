enum HttpMethod { get, post, put, patch, delete }

// An outgoing request, immutable. Interceptors take one and hand back a copy,
// usually with an extra header (like an auth token) via copyWith.
class ApiRequest {
  const ApiRequest({
    required this.method,
    required this.path,
    this.headers = const {},
    this.query = const {},
    this.body,
  });

  final HttpMethod method;

  // Relative to the base URL, e.g. "/wallet/balance".
  final String path;
  final Map<String, String> headers;
  final Map<String, String> query;

  // JSON-encodable body (Map/List/primitive), or null for none.
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

  // Copy with `extra` merged into the headers.
  ApiRequest withHeaders(Map<String, String> extra) =>
      copyWith(headers: {...headers, ...extra});
}
