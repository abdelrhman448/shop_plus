import 'package:equatable/equatable.dart';

// Error codes coming from the wallet API. An enum keeps things type-safe and
// lets the UI map each code to a proper (localized) message.
enum WalletErrorCode {
  insufficientBalance,
  recipientNotFound,
  network,
  unknown;

  static WalletErrorCode fromCode(String raw) {
    switch (raw) {
      case 'INSUFFICIENT_BALANCE':
        return WalletErrorCode.insufficientBalance;
      case 'RECIPIENT_NOT_FOUND':
        return WalletErrorCode.recipientNotFound;
      case 'NETWORK':
        return WalletErrorCode.network;
      default:
        // Anything we don't recognize shouldn't crash the app.
        return WalletErrorCode.unknown;
    }
  }
}

// Thrown by the repository when something goes wrong. We keep the raw server
// code around and expose a typed [code] for the rest of the app to switch on.
class WalletException extends Equatable implements Exception {
  const WalletException(this.rawCode, this.message);

  final String rawCode;
  final String message;

  WalletErrorCode get code => WalletErrorCode.fromCode(rawCode);

  @override
  List<Object?> get props => [rawCode, message];

  @override
  String toString() => 'WalletException($rawCode): $message';
}
