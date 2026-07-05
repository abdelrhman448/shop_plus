import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

/// Holds the app's active [Locale] and lets the UI toggle between the two
/// supported languages (English / Arabic).
///
/// A `null` locale would mean "follow the system", but we keep an explicit
/// locale so the in-app language switch is predictable.
class LocaleCubit extends Cubit<Locale> {
  LocaleCubit([super.initial = const Locale('en')]);

  static const supportedLocales = [Locale('en'), Locale('ar')];

  void toggle() {
    emit(state.languageCode == 'ar' ? const Locale('en') : const Locale('ar'));
  }

  void setLocale(Locale locale) => emit(locale);
}
