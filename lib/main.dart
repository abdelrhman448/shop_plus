import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'app.dart';
import 'core/locale/locale_cubit.dart';
import 'features/wallet/data/repositories/mock_wallet_repository.dart';
import 'features/wallet/data/repositories/wallet_repository.dart';

void main() {
  runApp(const ShopPlusBootstrap());
}

/// Provides app-wide dependencies (the repository and the locale controller)
/// above the router so every route can read them.
///
/// Swapping [MockWalletRepository] for a real HTTP implementation later is a
/// one-line change here — nothing else in the app needs to know.
class ShopPlusBootstrap extends StatelessWidget {
  const ShopPlusBootstrap({super.key});

  @override
  Widget build(BuildContext context) {
    return RepositoryProvider<WalletRepository>(
      create: (_) => MockWalletRepository(),
      child: BlocProvider(
        create: (_) => LocaleCubit(),
        child: const ShopPlusApp(),
      ),
    );
  }
}
