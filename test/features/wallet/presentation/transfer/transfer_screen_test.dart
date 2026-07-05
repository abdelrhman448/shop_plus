import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:shop_plus/core/locale/locale_cubit.dart';
import 'package:shop_plus/features/wallet/data/repositories/wallet_repository.dart';
import 'package:shop_plus/features/wallet/presentation/transfer/transfer_cubit.dart';
import 'package:shop_plus/features/wallet/presentation/transfer/transfer_screen.dart';
import 'package:shop_plus/l10n/app_localizations.dart';

class MockWalletRepository extends Mock implements WalletRepository {}

Widget _wrap() {
  final repo = MockWalletRepository();
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
        create: (_) => TransferCubit(repo),
        child: const TransferScreen(availableBalance: 15750),
      ),
    ),
  );
}

bool _submitEnabled(WidgetTester tester) {
  final button = tester.widget<FilledButton>(
    find.widgetWithText(FilledButton, 'Send Points'),
  );
  return button.onPressed != null;
}

void main() {
  testWidgets('submit is disabled until the form is valid', (tester) async {
    await tester.pumpWidget(_wrap());
    await tester.pumpAndSettle();

    expect(_submitEnabled(tester), isFalse);

    // Fill a valid recipient and a valid amount.
    await tester.enterText(
      find.widgetWithText(TextFormField, 'Recipient'),
      'user@test.com',
    );
    await tester.enterText(
      find.widgetWithText(TextFormField, 'Points amount'),
      '500',
    );
    await tester.pumpAndSettle();

    expect(_submitEnabled(tester), isTrue);
  });

  testWidgets('shows a validation error for an invalid amount below the min',
      (tester) async {
    await tester.pumpWidget(_wrap());
    await tester.pumpAndSettle();

    await tester.enterText(
      find.widgetWithText(TextFormField, 'Recipient'),
      'user@test.com',
    );
    await tester.enterText(
      find.widgetWithText(TextFormField, 'Points amount'),
      '50',
    );
    await tester.pumpAndSettle();

    expect(find.text('Minimum is 100 points'), findsOneWidget);
    expect(_submitEnabled(tester), isFalse);
  });

  testWidgets('shows an error when recipient is invalid', (tester) async {
    await tester.pumpWidget(_wrap());
    await tester.pumpAndSettle();

    await tester.enterText(
      find.widgetWithText(TextFormField, 'Recipient'),
      'not-valid',
    );
    await tester.pumpAndSettle();

    expect(
      find.text('Enter a valid Egyptian phone (+20...) or email'),
      findsOneWidget,
    );
  });
}
