import 'package:flutter_test/flutter_test.dart';
import 'package:shop_plus/core/error/wallet_exception.dart';
import 'package:shop_plus/features/wallet/data/models/models.dart';
import 'package:shop_plus/features/wallet/data/repositories/mock_wallet_repository.dart';

void main() {
  // Use zero delays so the suite runs fast and deterministically.
  late MockWalletRepository repository;

  setUp(() {
    repository = MockWalletRepository(
      balanceDelay: Duration.zero,
      transactionsDelay: Duration.zero,
      transferDelay: Duration.zero,
    );
  });

  group('getBalance', () {
    test('returns the expected balance data', () async {
      final balance = await repository.getBalance();

      expect(balance.totalPoints, 15750);
      expect(balance.pendingPoints, 500);
      expect(balance.expiringPoints, 1200);
      expect(balance.balancesByMerchant, hasLength(3));
      expect(balance.balancesByMerchant.first.merchantName, 'TechMart');
    });
  });

  group('getTransactions', () {
    test('returns the first page with all items by default', () async {
      final result = await repository.getTransactions();

      expect(result.page, 1);
      expect(result.totalItems, 5);
      expect(result.transactions, hasLength(5));
      expect(result.hasNext, isFalse);
    });

    test('respects pagination parameters (page/limit)', () async {
      final firstPage = await repository.getTransactions(page: 1, limit: 2);
      expect(firstPage.transactions, hasLength(2));
      expect(firstPage.hasNext, isTrue);
      expect(firstPage.transactions.first.id, 'txn_001');

      final secondPage = await repository.getTransactions(page: 2, limit: 2);
      expect(secondPage.transactions, hasLength(2));
      expect(secondPage.hasNext, isTrue);
      expect(secondPage.transactions.first.id, 'txn_003');

      final lastPage = await repository.getTransactions(page: 3, limit: 2);
      expect(lastPage.transactions, hasLength(1));
      expect(lastPage.hasNext, isFalse);
    });

    test('returns an empty page when the page is out of range', () async {
      final result = await repository.getTransactions(page: 99, limit: 20);

      expect(result.transactions, isEmpty);
      expect(result.hasNext, isFalse);
      expect(result.totalItems, 5);
    });

    test('filters transactions by type', () async {
      final result = await repository.getTransactions(
        type: TransactionType.earn,
      );

      expect(result.transactions, hasLength(1));
      expect(result.transactions.single.type, TransactionType.earn);
      expect(result.totalItems, 1);
    });
  });

  group('transferPoints', () {
    test('returns a completed result on success', () async {
      const request = TransferRequest(recipient: 'friend@test.com', points: 500);

      final result = await repository.transferPoints(request);

      expect(result.points, 500);
      expect(result.status, 'COMPLETED');
      expect(result.newBalance, 15750 - 500);
      expect(result.transactionId, startsWith('txn_'));
    });

    test('throws INSUFFICIENT_BALANCE when points exceed balance', () async {
      const request =
          TransferRequest(recipient: 'friend@test.com', points: 20000);

      expect(
        () => repository.transferPoints(request),
        throwsA(
          isA<WalletException>().having(
            (e) => e.code,
            'code',
            WalletErrorCode.insufficientBalance,
          ),
        ),
      );
    });

    test('throws RECIPIENT_NOT_FOUND for an unknown recipient', () async {
      const request =
          TransferRequest(recipient: 'notfound@test.com', points: 100);

      expect(
        () => repository.transferPoints(request),
        throwsA(
          isA<WalletException>().having(
            (e) => e.code,
            'code',
            WalletErrorCode.recipientNotFound,
          ),
        ),
      );
    });
  });
}
