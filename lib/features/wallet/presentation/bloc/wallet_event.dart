part of 'wallet_bloc.dart';

/// Base class for all wallet events.
sealed class WalletEvent extends Equatable {
  const WalletEvent();

  @override
  List<Object?> get props => [];
}

/// Loads the balance and the first page of transactions.
class LoadWallet extends WalletEvent {
  const LoadWallet();
}

/// Reloads everything from scratch (used by pull-to-refresh).
class RefreshWallet extends WalletEvent {
  const RefreshWallet();
}

/// Changes the active transaction-type filter.
///
/// A `null` [type] means "All". Filtering preserves the already-loaded data so
/// switching back to "All" restores the full list without a new request.
class FilterTransactions extends WalletEvent {
  const FilterTransactions(this.type);

  final TransactionType? type;

  @override
  List<Object?> get props => [type];
}

/// Loads the next page of transactions and appends it to the current list.
class LoadMoreTransactions extends WalletEvent {
  const LoadMoreTransactions();
}
