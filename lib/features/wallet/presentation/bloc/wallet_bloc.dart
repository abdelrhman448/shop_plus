import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';

import '../../../../core/error/wallet_exception.dart';
import '../../data/models/models.dart';
import '../../data/repositories/wallet_repository.dart';

part 'wallet_event.dart';
part 'wallet_state.dart';

/// Manages the state of the Wallet screen.
///
/// Depends on the [WalletRepository] abstraction only, so it can be unit-tested
/// against a fake and works unchanged with the future real API.
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
    // Keep whatever is on screen while refreshing to avoid a jarring flash;
    // if we have nothing yet, fall back to a full loading state.
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

  /// Filtering happens in-memory over the already-loaded master list, so the
  /// original data is preserved and switching filters is instant.
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
      // Keep the existing list; surface the failure but don't wipe data.
      emit(current.copyWith(isLoadingMore: false));
      emit(WalletError(code: e.code, message: e.message));
    } catch (_) {
      emit(current.copyWith(isLoadingMore: false));
    }
  }
}
