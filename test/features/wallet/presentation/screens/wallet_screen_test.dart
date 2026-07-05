import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shop_plus/core/locale/locale_cubit.dart';
import 'package:shop_plus/features/wallet/data/models/models.dart';
import 'package:shop_plus/features/wallet/data/repositories/wallet_repository.dart';
import 'package:shop_plus/features/wallet/presentation/bloc/wallet_bloc.dart';
import 'package:shop_plus/features/wallet/presentation/screens/wallet_screen.dart';
import 'package:shop_plus/features/wallet/presentation/widgets/transaction_tile.dart';
import 'package:shop_plus/l10n/app_localizations.dart';

/// Deterministic in-memory repository (no network logos, no delays) so widget
/// tests stay fast and stable.
class FakeWalletRepository implements WalletRepository {
  final _balance = PointsBalance(
    totalPoints: 15750,
    pendingPoints: 500,
    expiringPoints: 1200,
    expiringDate: DateTime(2024, 3, 31),
    lastUpdated: DateTime(2024, 2, 15),
    balancesByMerchant: const [],
  );

  final _transactions = [
    Transaction(
      id: 'txn_001',
      type: TransactionType.earn,
      points: 500,
      description: 'Purchase at TechMart',
      merchantName: null,
      merchantLogo: null,
      createdAt: DateTime(2024, 2, 15, 14, 30),
      status: TransactionStatus.completed,
    ),
    Transaction(
      id: 'txn_002',
      type: TransactionType.redeem,
      points: -1000,
      description: 'Discount redemption',
      merchantName: null,
      merchantLogo: null,
      createdAt: DateTime(2024, 2, 14, 11, 20),
      status: TransactionStatus.completed,
    ),
  ];

  @override
  Future<PointsBalance> getBalance() async => _balance;

  @override
  Future<PaginatedTransactions> getTransactions({
    int page = 1,
    int limit = 20,
    TransactionType? type,
  }) async {
    return PaginatedTransactions(
      transactions: _transactions,
      page: page,
      totalItems: _transactions.length,
      hasNext: false,
    );
  }

  @override
  Future<TransferResult> transferPoints(TransferRequest request) async {
    throw UnimplementedError();
  }
}

Widget _wrap(WalletRepository repo) {
  return BlocProvider(
    create: (_) => LocaleCubit(),
    child: MaterialApp(
      locale: const Locale('en'),
      localizationsDelegates: const [
        AppLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: LocaleCubit.supportedLocales,
      home: BlocProvider(
        create: (_) => WalletBloc(repo)..add(const LoadWallet()),
        child: const WalletScreen(),
      ),
    ),
  );
}

void main() {
  testWidgets('shows the balance and transactions after loading',
      (tester) async {
    await tester.pumpWidget(_wrap(FakeWalletRepository()));

    // Initial frame shows the shimmer skeleton (no data yet).
    expect(find.byType(TransactionTile), findsNothing);

    await tester.pumpAndSettle();

    // Balance formatted with thousands separator.
    expect(find.text('15,750'), findsOneWidget);
    expect(find.byType(TransactionTile), findsNWidgets(2));
    expect(find.text('Purchase at TechMart'), findsOneWidget);
  });

  testWidgets('filtering by Earn hides non-matching transactions',
      (tester) async {
    await tester.pumpWidget(_wrap(FakeWalletRepository()));
    await tester.pumpAndSettle();

    expect(find.byType(TransactionTile), findsNWidgets(2));

    await tester.tap(find.text('Earn'));
    await tester.pumpAndSettle();

    // Only the single EARN transaction remains visible.
    expect(find.byType(TransactionTile), findsOneWidget);
    expect(find.text('Purchase at TechMart'), findsOneWidget);
    expect(find.text('Discount redemption'), findsNothing);
  });
}
