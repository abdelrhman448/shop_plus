import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../locale/locale_cubit.dart';

/// AppBar action that switches the app language between English and Arabic.
class LanguageToggleButton extends StatelessWidget {
  const LanguageToggleButton({super.key});

  @override
  Widget build(BuildContext context) {
    final isArabic = context.watch<LocaleCubit>().state.languageCode == 'ar';
    return IconButton(
      tooltip: isArabic ? 'English' : 'العربية',
      icon: const Icon(Icons.translate),
      // Show the language the user will switch *to*.
      onPressed: () => context.read<LocaleCubit>().toggle(),
    );
  }
}
