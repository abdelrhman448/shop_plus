// Type of a transaction. We (de)serialize to the SCREAMING_SNAKE_CASE strings
// the API uses, so this enum is the one source of truth on the client.
enum TransactionType {
  earn('EARN'),
  redeem('REDEEM'),
  transferIn('TRANSFER_IN'),
  transferOut('TRANSFER_OUT'),
  purchase('PURCHASE');

  const TransactionType(this.wireValue);

  // What the JSON uses.
  final String wireValue;

  static TransactionType fromWire(String value) {
    return TransactionType.values.firstWhere(
      (t) => t.wireValue == value,
      orElse: () => throw ArgumentError('Unknown TransactionType: $value'),
    );
  }
}

// Has the transaction settled yet?
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
