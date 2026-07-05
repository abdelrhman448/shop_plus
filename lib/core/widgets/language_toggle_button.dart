import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../locale/locale_cubit.dart';

// Little AppBar button to switch between English and Arabic.
class LanguageToggleButton extends StatelessWidget {
  const LanguageToggleButton({super.key});

  @override
  Widget build(BuildContext context) {
    final isArabic = context.watch<LocaleCubit>().state.languageCode == 'ar';
    return IconButton(
      // Tooltip shows the language we'll switch to.
      tooltip: isArabic ? 'English' : 'العربية',
      icon: const Icon(Icons.translate),
      onPressed: () => context.read<LocaleCubit>().toggle(),
    );
  }
}
