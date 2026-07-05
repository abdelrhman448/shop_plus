part of 'transfer_cubit.dart';

/// Base class for the transfer submission states.
sealed class TransferState extends Equatable {
  const TransferState();

  @override
  List<Object?> get props => [];
}

/// No submission has started (or the form is being edited).
class TransferInitial extends TransferState {
  const TransferInitial();
}

/// A transfer request is in flight.
class TransferSubmitting extends TransferState {
  const TransferSubmitting();
}

/// The transfer completed successfully.
class TransferSuccess extends TransferState {
  const TransferSuccess(this.result);

  final TransferResult result;

  @override
  List<Object?> get props => [result];
}

/// The transfer failed with a typed error code.
class TransferFailure extends TransferState {
  const TransferFailure({required this.code, required this.message});

  final WalletErrorCode code;
  final String message;

  @override
  List<Object?> get props => [code, message];
}
