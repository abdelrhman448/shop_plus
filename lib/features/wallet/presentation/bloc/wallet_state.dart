part of 'wallet_bloc.dart';

/// Base class for all wallet states.
sealed class WalletState extends Equatable {
  const WalletState();

  @override
  List<Object?> get props => [];
}

/// Nothing has been requested yet.
class WalletInitial extends WalletState {
  const WalletInitial();
}

/// The first load is in progress (full-screen loading / shimmer).
class WalletLoading extends WalletState {
  const WalletLoading();
}

/// Data is available.
///
/// [transactions] is the full, unfiltered list that has been loaded so far.
/// The UI reads [visibleTransactions], which applies [activeFilter] on top of
/// that master list. Keeping the master list intact means switching filters
/// never loses data and requires no extra network calls.
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

  /// Transactions after applying [activeFilter] (all of them when null).
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

/// Loading failed. [code] lets the UI show a localized message and [message]
/// is a sensible fallback. The screen offers a retry action.
class WalletError extends WalletState {
  const WalletError({required this.code, required this.message});

  final WalletErrorCode code;
  final String message;

  @override
  List<Object?> get props => [code, message];
}
