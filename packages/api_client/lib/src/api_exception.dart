// What ApiClient throws for non-2xx responses, timeouts and network failures.
class ApiException implements Exception {
  const ApiException({
    required this.message,
    this.statusCode,
    this.code,
    this.data,
  });

  final String message;

  // Status code, or null for transport/timeout errors.
  final int? statusCode;

  // Machine-readable code from the server body, if any.
  final String? code;

  // The decoded error body, if any.
  final Object? data;

  // Worth retrying? (network errors, plus 5xx / 408 / 429).
  bool get isRetryable {
    final s = statusCode;
    if (s == null) return true; // transport / timeout
    return s >= 500 || s == 408 || s == 429;
  }

  @override
  String toString() =>
      'ApiException(status: $statusCode, code: $code, message: $message)';
}
