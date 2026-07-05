part of 'wallet_bloc.dart';

sealed class WalletEvent extends Equatable {
  const WalletEvent();

  @override
  List<Object?> get props => [];
}

// First load: balance + first page of transactions.
class LoadWallet extends WalletEvent {
  const LoadWallet();
}

// Pull-to-refresh.
class RefreshWallet extends WalletEvent {
  const RefreshWallet();
}

// Change the type filter. null == "All". We keep the loaded data around, so
// going back to "All" doesn't need another request.
class FilterTransactions extends WalletEvent {
  const FilterTransactions(this.type);

  final TransactionType? type;

  @override
  List<Object?> get props => [type];
}

// Grab the next page and append it.
class LoadMoreTransactions extends WalletEvent {
  const LoadMoreTransactions();
}
