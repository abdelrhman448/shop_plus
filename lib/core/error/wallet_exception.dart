import 'package:equatable/equatable.dart';

/// Domain-level error codes the wallet feature can produce.
///
/// Using an enum (instead of raw strings scattered around the code) keeps error
/// handling type-safe and makes it trivial to map an error to a localized,
/// user-facing message in the UI layer.
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
        return WalletErrorCode.unknown;
    }
  }
}

/// A typed exception thrown by the wallet repository.
///
/// Carries a machine-readable [code] and a human-readable [message]. The BLoC
/// catches this and surfaces the [code] so the UI can show the right message.
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
