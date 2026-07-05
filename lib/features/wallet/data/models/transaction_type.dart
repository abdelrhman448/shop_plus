/// The kind of a wallet [Transaction].
///
/// Serialized to/from the SCREAMING_SNAKE_CASE strings used by the API so the
/// enum stays the single source of truth on the client.
enum TransactionType {
  earn('EARN'),
  redeem('REDEEM'),
  transferIn('TRANSFER_IN'),
  transferOut('TRANSFER_OUT'),
  purchase('PURCHASE');

  const TransactionType(this.wireValue);

  /// The value used on the wire (JSON).
  final String wireValue;

  static TransactionType fromWire(String value) {
    return TransactionType.values.firstWhere(
      (t) => t.wireValue == value,
      orElse: () => throw ArgumentError('Unknown TransactionType: $value'),
    );
  }
}

/// Whether a [Transaction] has settled yet.
enum TransactionStatus {
  completed('COMPLETED'),
  pending('PENDING'),
  failed('FAILED');

  const TransactionStatus(this.wireValue);

  final String wireValue;

  static TransactionStatus fromWire(String value) {
    return TransactionStatus.values.firstWhere(
      (s) => s.wireValue == value,
      orElse: () => throw ArgumentError('Unknown TransactionStatus: $value'),
    );
  }
}
