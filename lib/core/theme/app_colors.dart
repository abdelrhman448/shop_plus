import 'package:flutter/material.dart';

// All app colors live here so we don't scatter hex codes everywhere.
// Brand colors come from the design spec.
abstract final class AppColors {
  const AppColors._();

  static const Color primary = Color(0xFF6C5CE7); // Purple
  static const Color secondary = Color(0xFF00D9A5); // Teal
  static const Color success = Color(0xFF00B894);
  static const Color error = Color(0xFFE74C3C);

  // Neutrals
  static const Color white = Color(0xFFFFFFFF);
  static const Color scaffoldLight = Color(0xFFF7F7FB);
  static const Color scaffoldDark = Color(0xFF121018);
  static const Color textPrimary = Color(0xFF1A1A2E);
  static const Color textSecondary = Color(0xFF6E6E80);
  static const Color divider = Color(0xFFE7E7EF);

  // One color per transaction type
  static const Color earn = success;
  static const Color redeem = error;
  static const Color transferIn = secondary;
  static const Color transferOut = Color(0xFFF39C12);
  static const Color purchase = primary;
  static const Color pending = Color(0xFFF39C12);
}
