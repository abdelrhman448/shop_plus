/// Configures automatic retries with exponential backoff.
///
/// The delay before attempt _n_ (0-based) is
/// `baseDelay * 2^n`, capped at [maxDelay].
class RetryPolicy {
  const RetryPolicy({
    this.maxRetries = 2,
    this.baseDelay = const Duration(milliseconds: 300),
    this.maxDelay = const Duration(seconds: 5),
  });

  /// A policy that performs no retries.
  static const none = RetryPolicy(maxRetries: 0);

  final int maxRetries;
  final Duration baseDelay;
  final Duration maxDelay;

  /// Backoff delay before the given 0-based [attempt].
  Duration delayFor(int attempt) {
    final millis = baseDelay.inMilliseconds * (1 << attempt);
    final capped = millis.clamp(0, maxDelay.inMilliseconds);
    return Duration(milliseconds: capped);
  }
}
