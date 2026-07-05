import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'app.dart';
import 'core/locale/locale_cubit.dart';
import 'features/wallet/data/repositories/mock_wallet_repository.dart';
import 'features/wallet/data/repositories/wallet_repository.dart';

void main() {
  runApp(const ShopPlusBootstrap());
}

// Puts the app-wide stuff (repository + locale) above the router so every
// route can reach it. Going from the mock to a real repo is a one-liner here.
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
