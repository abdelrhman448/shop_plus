part of 'transfer_cubit.dart';

sealed class TransferState extends Equatable {
  const TransferState();

  @override
  List<Object?> get props => [];
}

// Nothing sent yet (form still being filled in).
class TransferInitial extends TransferState {
  const TransferInitial();
}

// Request is in flight.
class TransferSubmitting extends TransferState {
  const TransferSubmitting();
}

// Went through.
class TransferSuccess extends TransferState {
  const TransferSuccess(this.result);

  final TransferResult result;

  @override
  List<Object?> get props => [result];
}

// Didn't go through, with a typed code we can show a message for.
class TransferFailure extends TransferState {
  const TransferFailure({required this.code, required this.message});

  final WalletErrorCode code;
  final String message;

  @override
  List<Object?> get props => [code, message];
}
