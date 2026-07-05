import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/error/wallet_exception.dart';
import '../../data/models/models.dart';
import '../../data/repositories/wallet_repository.dart';

part 'wallet_event.dart';
part 'wallet_state.dart';

// Drives the Wallet screen. Only knows about the WalletRepository interface,
// so it's easy to test with a fake and works as-is with the real API later.
class WalletBloc extends Bloc<WalletEvent, WalletState> {
  WalletBloc(this._repository) : super(const WalletInitial()) {
    on<LoadWallet>(_onLoad);
    on<RefreshWallet>(_onRefresh);
    on<FilterTransactions>(_onFilter);
    on<LoadMoreTransactions>(_onLoadMore);
  }

  final WalletRepository _repository;

  /// Page size for transaction pagination.
  static const int _pageSize = 20;

  Future<void> _onLoad(LoadWallet event, Emitter<WalletState> emit) async {
    emit(const WalletLoading());
    await _fetchInitial(emit);
  }

  Future<void> _onRefresh(
    RefreshWallet event,
    Emitter<WalletState> emit,
  ) async {
    // If we already have data, keep it on screen while refreshing (no flash).
    // Otherwise show the full loading state.
    if (state is! WalletLoaded) emit(const WalletLoading());
    await _fetchInitial(emit);
  }

  Future<void> _fetchInitial(Emitter<WalletState> emit) async {
    try {
      final balance = await _repository.getBalance();
      final page = await _repository.getTransactions(
        page: 1,
        limit: _pageSize,
      );

      emit(
        WalletLoaded(
          balance: balance,
          transactions: page.transactions,
          currentPage: page.page,
          hasNext: page.hasNext,
        ),
      );
    } on WalletException catch (e) {
      emit(WalletError(code: e.code, message: e.message));
    } catch (_) {
      emit(
        const WalletError(
          code: WalletErrorCode.unknown,
          message: 'Something went wrong. Please try again.',
        ),
      );
    }
  }

  // Filter in memory over the list we already have. The full list stays intact
  // so flipping filters is instant and never loses data.
  void _onFilter(FilterTransactions event, Emitter<WalletState> emit) {
    final current = state;
    if (current is! WalletLoaded) return;

    emit(
      current.copyWith(
        activeFilter: event.type,
        clearFilter: event.type == null,
      ),
    );
  }

  Future<void> _onLoadMore(
    LoadMoreTransactions event,
    Emitter<WalletState> emit,
  ) async {
    final current = state;
    if (current is! WalletLoaded) return;
    if (!current.hasNext || current.isLoadingMore) return;

    emit(current.copyWith(isLoadingMore: true));

    try {
      final nextPage = await _repository.getTransactions(
        page: current.currentPage + 1,
        limit: _pageSize,
      );

      emit(
        current.copyWith(
          transactions: [...current.transactions, ...nextPage.transactions],
          currentPage: nextPage.page,
          hasNext: nextPage.hasNext,
          isLoadingMore: false,
        ),
      );
    } on WalletException catch (e) {
      // Show the error but keep the list we already have.
      emit(current.copyWith(isLoadingMore: false));
      emit(WalletError(code: e.code, message: e.message));
    } catch (_) {
      emit(current.copyWith(isLoadingMore: false));
    }
  }
}
