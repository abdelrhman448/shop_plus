import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../features/wallet/data/repositories/wallet_repository.dart';
import '../../features/wallet/presentation/bloc/wallet_bloc.dart';
import '../../features/wallet/presentation/screens/wallet_screen.dart';
import '../../features/wallet/presentation/transfer/transfer_cubit.dart';
import '../../features/wallet/presentation/transfer/transfer_screen.dart';

/// Central [GoRouter] configuration.
///
/// Routes:
/// - `/`                 -> redirects to `/wallet`
/// - `/wallet`           -> Wallet screen (owns a [WalletBloc])
/// - `/wallet/transfer`  -> Transfer screen (owns a [TransferCubit])
///
/// Each screen's Bloc/Cubit is scoped to its route via a [BlocProvider] so it
/// is created on entry and disposed on exit. Both read the shared
/// [WalletRepository] from the widget tree (provided in `main`).
abstract final class AppRouter {
  const AppRouter._();

  static GoRouter create() {
    return GoRouter(
      initialLocation: WalletScreen.routePath,
      routes: [
        GoRoute(
          path: '/',
          redirect: (_, _) => WalletScreen.routePath,
        ),
        GoRoute(
          path: WalletScreen.routePath,
          name: WalletScreen.routeName,
          builder: (context, state) => BlocProvider(
            create: (context) =>
                WalletBloc(context.read<WalletRepository>())
                  ..add(const LoadWallet()),
            child: const WalletScreen(),
          ),
          routes: [
            GoRoute(
              path: TransferScreen.routePath,
              name: TransferScreen.routeName,
              builder: (context, state) {
                // Available balance is passed as a route `extra`.
                final availableBalance = (state.extra as int?) ?? 0;
                return BlocProvider(
                  create: (context) =>
                      TransferCubit(context.read<WalletRepository>()),
                  child: TransferScreen(availableBalance: availableBalance),
                );
              },
            ),
          ],
        ),
      ],
    );
  }
}
