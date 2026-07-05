import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

// Keeps the current language and lets us flip between English and Arabic.
// We use an explicit locale (not "follow system") so the toggle is predictable.
class LocaleCubit extends Cubit<Locale> {
  LocaleCubit([super.initial = const Locale('en')]);

  static const supportedLocales = [Locale('en'), Locale('ar')];

  void toggle() {
    emit(state.languageCode == 'ar' ? const Locale('en') : const Locale('ar'));
  }

  void setLocale(Locale locale) => emit(locale);
}
