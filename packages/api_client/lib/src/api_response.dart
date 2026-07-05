// A decoded response.
class ApiResponse {
  const ApiResponse({
    required this.statusCode,
    required this.data,
    this.headers = const {},
  });

  final int statusCode;

  // Decoded JSON body, or null when empty / not JSON.
  final Object? data;

  final Map<String, String> headers;

  bool get isSuccess => statusCode >= 200 && statusCode < 300;
}
