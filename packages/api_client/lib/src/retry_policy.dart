// Retry settings with exponential backoff: the wait before attempt n (0-based)
// is baseDelay * 2^n, capped at maxDelay.
class RetryPolicy {
  const RetryPolicy({
    this.maxRetries = 2,
    this.baseDelay = const Duration(milliseconds: 300),
    this.maxDelay = const Duration(seconds: 5),
  });

  // Don't retry at all.
  static const none = RetryPolicy(maxRetries: 0);

  final int maxRetries;
  final Duration baseDelay;
  final Duration maxDelay;

  // How long to wait before the given attempt.
  Duration delayFor(int attempt) {
    final millis = baseDelay.inMilliseconds * (1 << attempt);
    final capped = millis.clamp(0, maxDelay.inMilliseconds);
    return Duration(milliseconds: capped);
  }
}
