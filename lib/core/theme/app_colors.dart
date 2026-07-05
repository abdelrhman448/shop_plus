import 'package:flutter/material.dart';

/// Central palette for the app.
///
/// The base brand colors are taken from the design spec. Everything else in
/// the app should reference these values instead of hard-coding hex codes so
/// that theming stays consistent and easy to change in one place.
abstract final class AppColors {
  const AppColors._();

  // Brand colors (from the design spec).
  static const Color primary = Color(0xFF6C5CE7); // Purple
  static const Color secondary = Color(0xFF00D9A5); // Teal
  static const Color success = Color(0xFF00B894);
  static const Color error = Color(0xFFE74C3C);

  // Neutrals.
  static const Color white = Color(0xFFFFFFFF);
  static const Color scaffoldLight = Color(0xFFF7F7FB);
  static const Color scaffoldDark = Color(0xFF121018);
  static const Color textPrimary = Color(0xFF1A1A2E);
  static const Color textSecondary = Color(0xFF6E6E80);
  static const Color divider = Color(0xFFE7E7EF);

  // Semantic transaction colors.
  static const Color earn = success;
  static const Color redeem = error;
  static const Color transferIn = secondary;
  static const Color transferOut = Color(0xFFF39C12);
  static const Color purchase = primary;
  static const Color pending = Color(0xFFF39C12);
}
