/// A decoded HTTP response.
class ApiResponse {
  const ApiResponse({
    required this.statusCode,
    required this.data,
    this.headers = const {},
  });

  final int statusCode;

  /// The decoded JSON body (Map/List/primitive), or `null` if the body was
  /// empty or not JSON.
  final Object? data;

  final Map<String, String> headers;

  bool get isSuccess => statusCode >= 200 && statusCode < 300;
}
