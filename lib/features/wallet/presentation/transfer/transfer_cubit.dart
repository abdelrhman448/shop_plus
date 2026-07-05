import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/error/wallet_exception.dart';
import '../../data/models/models.dart';
import '../../data/repositories/wallet_repository.dart';

part 'transfer_state.dart';

/// Drives the points-transfer submission.
///
/// A Cubit (not a full Bloc) fits here because the screen has a single action —
/// "submit the form". Form-field validation lives in the widget layer via
/// `TextFormField` validators; this Cubit owns only the async submit lifecycle.
class TransferCubit extends Cubit<TransferState> {
  TransferCubit(this._repository) : super(const TransferInitial());

  final WalletRepository _repository;

  Future<void> submit(TransferRequest request) async {
    emit(const TransferSubmitting());
    try {
      final result = await _repository.transferPoints(request);
      emit(TransferSuccess(result));
    } on WalletException catch (e) {
      emit(TransferFailure(code: e.code, message: e.message));
    } catch (_) {
      emit(
        const TransferFailure(
          code: WalletErrorCode.unknown,
          message: 'Something went wrong. Please try again.',
        ),
      );
    }
  }
}
