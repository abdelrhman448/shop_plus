import '../models/models.dart';

// The wallet data contract. The BLoC only ever talks to this interface, not a
// concrete class, so we can drop in a fake for tests or swap the mock for a
// real HTTP repo later without touching any UI or state code.
abstract interface class WalletRepository {
  Future<PointsBalance> getBalance();

  // page is 1-based, limit caps items per page, type filters (optional).
  Future<PaginatedTransactions> getTransactions({
    int page = 1,
    int limit = 20,
    TransactionType? type,
  });

  // Throws WalletException on insufficient balance or unknown recipient.
  Future<TransferResult> transferPoints(TransferRequest request);
}
