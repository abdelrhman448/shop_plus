import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_localizations/flutter_localizations.dart';

import 'core/locale/locale_cubit.dart';
import 'core/router/app_router.dart';
import 'core/theme/app_theme.dart';
import 'l10n/app_localizations.dart';

/// Root application widget.
///
/// Wires up the router, theming and localization. The active locale comes from
/// [LocaleCubit] so the in-app language switch rebuilds the whole app (and flips
/// the layout direction for Arabic automatically).
class ShopPlusApp extends StatefulWidget {
  const ShopPlusApp({super.key});

  @override
  State<ShopPlusApp> createState() => _ShopPlusAppState();
}

class _ShopPlusAppState extends State<ShopPlusApp> {
  // The router is created once and kept alive for the app's lifetime.
  final _router = AppRouter.create();

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<LocaleCubit, Locale>(
      builder: (context, locale) {
        return MaterialApp.router(
          onGenerateTitle: (context) => AppLocalizations.of(context).appTitle,
          debugShowCheckedModeBanner: false,
          theme: AppTheme.light,
          darkTheme: AppTheme.dark,
          routerConfig: _router,
          locale: locale,
          supportedLocales: LocaleCubit.supportedLocales,
          localizationsDelegates: const [
            AppLocalizations.delegate,
            GlobalMaterialLocalizations.delegate,
            GlobalWidgetsLocalizations.delegate,
            GlobalCupertinoLocalizations.delegate,
          ],
        );
      },
    );
  }
}
