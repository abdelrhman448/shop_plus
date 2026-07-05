import '../models/models.dart';

/// Contract for wallet data access.
///
/// The presentation layer (BLoC) depends only on this abstraction, never on a
/// concrete implementation. That keeps the app testable (swap in a fake) and
/// lets us replace [MockWalletRepository] with a real HTTP-backed one later
/// without touching any UI or state-management code (Dependency Inversion).
abstract interface class WalletRepository {
  /// Returns the user's current points balance and per-merchant breakdown.
  Future<PointsBalance> getBalance();

  /// Returns a page of transactions, optionally filtered by [type].
  ///
  /// [page] is 1-based. [limit] caps the number of items per page.
  Future<PaginatedTransactions> getTransactions({
    int page = 1,
    int limit = 20,
    TransactionType? type,
  });

  /// Transfers points to another user.
  ///
  /// Throws a `WalletException` when the balance is insufficient or the
  /// recipient cannot be found.
  Future<TransferResult> transferPoints(TransferRequest request);
}
