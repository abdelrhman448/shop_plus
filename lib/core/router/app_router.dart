import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../features/wallet/data/repositories/wallet_repository.dart';
import '../../features/wallet/presentation/bloc/wallet_bloc.dart';
import '../../features/wallet/presentation/screens/wallet_screen.dart';
import '../../features/wallet/presentation/transfer/transfer_cubit.dart';
import '../../features/wallet/presentation/transfer/transfer_screen.dart';

// All routes in one place.
//   /                -> /wallet
//   /wallet          -> wallet screen (has its own WalletBloc)
//   /wallet/transfer -> transfer screen (has its own TransferCubit)
// Each screen creates its Bloc/Cubit here so it's disposed when we leave the
// route. Both grab the shared WalletRepository from the tree (see main.dart).
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
                // We pass the current balance through as `extra`.
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
