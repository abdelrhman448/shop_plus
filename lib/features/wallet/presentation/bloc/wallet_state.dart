part of 'wallet_bloc.dart';

sealed class WalletState extends Equatable {
  const WalletState();

  @override
  List<Object?> get props => [];
}

// Haven't asked for anything yet.
class WalletInitial extends WalletState {
  const WalletInitial();
}

// First load in progress (shimmer).
class WalletLoading extends WalletState {
  const WalletLoading();
}

// We have data. `transactions` is the full list we've loaded; the UI reads
// `visibleTransactions`, which applies the filter on top. Keeping the full list
// means switching filters never loses data or hits the network again.
class WalletLoaded extends WalletState {
  const WalletLoaded({
    required this.balance,
    required this.transactions,
    this.activeFilter,
    this.currentPage = 1,
    this.hasNext = false,
    this.isLoadingMore = false,
  });

  final PointsBalance balance;
  final List<Transaction> transactions;
  final TransactionType? activeFilter;
  final int currentPage;
  final bool hasNext;
  final bool isLoadingMore;

  // The list after the filter (or everything when there's no filter).
  List<Transaction> get visibleTransactions {
    final filter = activeFilter;
    if (filter == null) return transactions;
    return transactions.where((t) => t.type == filter).toList();
  }

  WalletLoaded copyWith({
    PointsBalance? balance,
    List<Transaction>? transactions,
    TransactionType? activeFilter,
    bool clearFilter = false,
    int? currentPage,
    bool? hasNext,
    bool? isLoadingMore,
  }) {
    return WalletLoaded(
      balance: balance ?? this.balance,
      transactions: transactions ?? this.transactions,
      activeFilter: clearFilter ? null : (activeFilter ?? this.activeFilter),
      currentPage: currentPage ?? this.currentPage,
      hasNext: hasNext ?? this.hasNext,
      isLoadingMore: isLoadingMore ?? this.isLoadingMore,
    );
  }

  @override
  List<Object?> get props => [
        balance,
        transactions,
        activeFilter,
        currentPage,
        hasNext,
        isLoadingMore,
      ];
}

// Something failed. `code` picks the localized message, `message` is a fallback.
// The screen shows a retry button.
class WalletError extends WalletState {
  const WalletError({required this.code, required this.message});

  final WalletErrorCode code;
  final String message;

  @override
  List<Object?> get props => [code, message];
}
