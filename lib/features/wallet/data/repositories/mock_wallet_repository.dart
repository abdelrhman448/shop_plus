import 'dart:math';

import '../../../../core/error/wallet_exception.dart';
import '../models/models.dart';
import 'wallet_repository.dart';

// In-memory repo we use until there's a real API. It fakes the real thing:
// a bit of network delay, server-style paging/filtering, and the same typed
// errors. Because it hides behind WalletRepository, going live won't touch the
// BLoC, UI or tests.
class MockWalletRepository implements WalletRepository {
  MockWalletRepository({
    Duration balanceDelay = const Duration(milliseconds: 800),
    Duration transactionsDelay = const Duration(milliseconds: 600),
    Duration transferDelay = const Duration(seconds: 1),
  })  : _balanceDelay = balanceDelay,
        _transactionsDelay = transactionsDelay,
        _transferDelay = transferDelay;

  final Duration _balanceDelay;
  final Duration _transactionsDelay;
  final Duration _transferDelay;

  static const int _maxTransferable = 15750;

  @override
  Future<PointsBalance> getBalance() async {
    await Future<void>.delayed(_balanceDelay);
    return _balance;
  }

  @override
  Future<PaginatedTransactions> getTransactions({
    int page = 1,
    int limit = 20,
    TransactionType? type,
  }) async {
    await Future<void>.delayed(_transactionsDelay);

    var filtered = _transactions;
    if (type != null) {
      filtered = filtered.where((t) => t.type == type).toList();
    }

    final startIndex = (page - 1) * limit;
    // Don't blow up if someone asks for a page past the end.
    if (startIndex >= filtered.length) {
      return PaginatedTransactions(
        transactions: const [],
        page: page,
        totalItems: filtered.length,
        hasNext: false,
      );
    }

    final endIndex = min(startIndex + limit, filtered.length);
    final pageData = filtered.sublist(startIndex, endIndex);

    return PaginatedTransactions(
      transactions: pageData,
      page: page,
      totalItems: filtered.length,
      hasNext: endIndex < filtered.length,
    );
  }

  @override
  Future<TransferResult> transferPoints(TransferRequest request) async {
    await Future<void>.delayed(_transferDelay);

    if (request.points > _maxTransferable) {
      throw const WalletException(
        'INSUFFICIENT_BALANCE',
        "You don't have enough points",
      );
    }
    if (request.recipient == 'notfound@test.com') {
      throw const WalletException(
        'RECIPIENT_NOT_FOUND',
        'Recipient not found',
      );
    }

    return TransferResult(
      transactionId: 'txn_${DateTime.now().millisecondsSinceEpoch}',
      points: request.points,
      newBalance: _maxTransferable - request.points,
      status: 'COMPLETED',
    );
  }

  // Sample data (straight from the assessment brief).

  final PointsBalance _balance = PointsBalance(
    totalPoints: 15750,
    pendingPoints: 500,
    expiringPoints: 1200,
    expiringDate: DateTime.parse('2024-03-31T23:59:59Z'),
    lastUpdated: DateTime.parse('2024-02-15T10:30:00Z'),
    balancesByMerchant: const [
      MerchantBalance(
        merchantId: 'm_123',
        merchantName: 'TechMart',
        merchantLogo: 'https://picsum.photos/seed/techmart/100',
        points: 8500,
        tier: 'Gold',
      ),
      MerchantBalance(
        merchantId: 'm_456',
        merchantName: 'FoodMart',
        merchantLogo: 'https://picsum.photos/seed/foodmart/100',
        points: 4250,
        tier: 'Silver',
      ),
      MerchantBalance(
        merchantId: 'm_789',
        merchantName: 'StyleHub',
        merchantLogo: 'https://picsum.photos/seed/stylehub/100',
        points: 3000,
        tier: 'Bronze',
      ),
    ],
  );

  final List<Transaction> _transactions = [
    Transaction(
      id: 'txn_001',
      type: TransactionType.earn,
      points: 500,
      description: 'Purchase at TechMart',
      merchantName: 'TechMart',
      merchantLogo: 'https://picsum.photos/seed/techmart/100',
      createdAt: DateTime.parse('2024-02-15T14:30:00Z'),
      status: TransactionStatus.completed,
    ),
    Transaction(
      id: 'txn_002',
      type: TransactionType.redeem,
      points: -1000,
      description: 'Discount redemption',
      merchantName: 'FoodMart',
      merchantLogo: 'https://picsum.photos/seed/foodmart/100',
      createdAt: DateTime.parse('2024-02-14T11:20:00Z'),
      status: TransactionStatus.completed,
    ),
    Transaction(
      id: 'txn_003',
      type: TransactionType.transferOut,
      points: -250,
      description: 'Transfer to Ahmed M.',
      merchantName: null,
      merchantLogo: null,
      createdAt: DateTime.parse('2024-02-13T09:15:00Z'),
      status: TransactionStatus.completed,
    ),
    Transaction(
      id: 'txn_004',
      type: TransactionType.purchase,
      points: 750,
      description: 'Online order #ORD-2024-089',
      merchantName: 'StyleHub',
      merchantLogo: 'https://picsum.photos/seed/stylehub/100',
      createdAt: DateTime.parse('2024-02-12T16:45:00Z'),
      status: TransactionStatus.completed,
    ),
    Transaction(
      id: 'txn_005',
      type: TransactionType.transferIn,
      points: 300,
      description: 'Received from Sara K.',
      merchantName: null,
      merchantLogo: null,
      createdAt: DateTime.parse('2024-02-08T13:30:00Z'),
      status: TransactionStatus.pending,
    ),
  ];
}
