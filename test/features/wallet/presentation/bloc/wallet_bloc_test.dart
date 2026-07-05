import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:shop_plus/core/error/wallet_exception.dart';
import 'package:shop_plus/features/wallet/data/models/models.dart';
import 'package:shop_plus/features/wallet/data/repositories/wallet_repository.dart';
import 'package:shop_plus/features/wallet/presentation/bloc/wallet_bloc.dart';

class MockWalletRepository extends Mock implements WalletRepository {}

void main() {
  late WalletRepository repository;

  final balance = PointsBalance(
    totalPoints: 15750,
    pendingPoints: 500,
    expiringPoints: 1200,
    expiringDate: DateTime.parse('2024-03-31T23:59:59Z'),
    lastUpdated: DateTime.parse('2024-02-15T10:30:00Z'),
    balancesByMerchant: const [],
  );

  final transactions = [
    Transaction(
      id: 'txn_001',
      type: TransactionType.earn,
      points: 500,
      description: 'Purchase at TechMart',
      merchantName: 'TechMart',
      merchantLogo: null,
      createdAt: DateTime.parse('2024-02-15T14:30:00Z'),
      status: TransactionStatus.completed,
    ),
    Transaction(
      id: 'txn_002',
      type: TransactionType.redeem,
      points: -1000,
      description: 'Discount redemption',
      merchantName: 'FoodMart',
      merchantLogo: null,
      createdAt: DateTime.parse('2024-02-14T11:20:00Z'),
      status: TransactionStatus.completed,
    ),
  ];

  PaginatedTransactions page() => PaginatedTransactions(
        transactions: transactions,
        page: 1,
        totalItems: transactions.length,
        hasNext: false,
      );

  setUp(() {
    repository = MockWalletRepository();
  });

  test('initial state is WalletInitial', () {
    expect(WalletBloc(repository).state, const WalletInitial());
  });

  group('LoadWallet', () {
    blocTest<WalletBloc, WalletState>(
      'emits [WalletLoading, WalletLoaded] when data loads successfully',
      setUp: () {
        when(() => repository.getBalance()).thenAnswer((_) async => balance);
        when(() => repository.getTransactions(
              page: any(named: 'page'),
              limit: any(named: 'limit'),
              type: any(named: 'type'),
            )).thenAnswer((_) async => page());
      },
      build: () => WalletBloc(repository),
      act: (bloc) => bloc.add(const LoadWallet()),
      expect: () => [
        const WalletLoading(),
        WalletLoaded(balance: balance, transactions: transactions),
      ],
    );

    blocTest<WalletBloc, WalletState>(
      'emits [WalletLoading, WalletError] when the repository throws',
      setUp: () {
        when(() => repository.getBalance()).thenThrow(
          const WalletException('NETWORK', 'No connection'),
        );
      },
      build: () => WalletBloc(repository),
      act: (bloc) => bloc.add(const LoadWallet()),
      expect: () => [
        const WalletLoading(),
        const WalletError(code: WalletErrorCode.network, message: 'No connection'),
      ],
    );

    blocTest<WalletBloc, WalletState>(
      'maps an unexpected error to WalletErrorCode.unknown',
      setUp: () {
        when(() => repository.getBalance()).thenThrow(Exception('boom'));
      },
      build: () => WalletBloc(repository),
      act: (bloc) => bloc.add(const LoadWallet()),
      expect: () => [
        const WalletLoading(),
        isA<WalletError>().having(
          (s) => s.code,
          'code',
          WalletErrorCode.unknown,
        ),
      ],
    );
  });

  group('FilterTransactions', () {
    blocTest<WalletBloc, WalletState>(
      'filters the visible list while preserving the original data',
      setUp: () {
        when(() => repository.getBalance()).thenAnswer((_) async => balance);
        when(() => repository.getTransactions(
              page: any(named: 'page'),
              limit: any(named: 'limit'),
              type: any(named: 'type'),
            )).thenAnswer((_) async => page());
      },
      build: () => WalletBloc(repository),
      act: (bloc) async {
        bloc.add(const LoadWallet());
        await Future<void>.delayed(Duration.zero);
        bloc.add(const FilterTransactions(TransactionType.earn));
        await Future<void>.delayed(Duration.zero);
        bloc.add(const FilterTransactions(null));
      },
      verify: (bloc) {
        final state = bloc.state as WalletLoaded;
        // The master list is never mutated.
        expect(state.transactions, transactions);
      },
      expect: () => [
        const WalletLoading(),
        WalletLoaded(balance: balance, transactions: transactions),
        WalletLoaded(
          balance: balance,
          transactions: transactions,
          activeFilter: TransactionType.earn,
        ),
        WalletLoaded(balance: balance, transactions: transactions),
      ],
    );

    test('visibleTransactions applies the active filter', () {
      final state = WalletLoaded(
        balance: balance,
        transactions: transactions,
        activeFilter: TransactionType.earn,
      );

      expect(state.visibleTransactions, hasLength(1));
      expect(state.visibleTransactions.single.type, TransactionType.earn);
      // Original data untouched.
      expect(state.transactions, hasLength(2));
    });
  });

  group('RefreshWallet', () {
    blocTest<WalletBloc, WalletState>(
      'reloads the balance and transactions',
      setUp: () {
        when(() => repository.getBalance()).thenAnswer((_) async => balance);
        when(() => repository.getTransactions(
              page: any(named: 'page'),
              limit: any(named: 'limit'),
              type: any(named: 'type'),
            )).thenAnswer((_) async => page());
      },
      build: () => WalletBloc(repository),
      seed: () => WalletLoaded(balance: balance, transactions: const []),
      act: (bloc) => bloc.add(const RefreshWallet()),
      expect: () => [
        WalletLoaded(balance: balance, transactions: transactions),
      ],
      verify: (_) {
        verify(() => repository.getBalance()).called(1);
      },
    );
  });
}
