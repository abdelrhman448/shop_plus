/// Error thrown by [ApiClient] for non-2xx responses, timeouts and transport
/// failures.
///
/// Interceptors can transform raw transport errors into domain-specific
/// [ApiException]s (e.g. mapping a `401` to an auth error).
class ApiException implements Exception {
  const ApiException({
    required this.message,
    this.statusCode,
    this.code,
    this.data,
  });

  final String message;

  /// HTTP status code, or `null` for transport/timeout errors.
  final int? statusCode;

  /// Optional machine-readable error code from the server body.
  final String? code;

  /// The decoded error body, if any.
  final Object? data;

  /// Whether retrying might help (network errors and 5xx / 408 / 429).
  bool get isRetryable {
    final s = statusCode;
    if (s == null) return true; // transport / timeout
    return s >= 500 || s == 408 || s == 429;
  }

  @override
  String toString() =>
      'ApiException(status: $statusCode, code: $code, message: $message)';
}
