import 'package:intl/intl.dart';

/// Small, locale-aware formatting helpers shared across the UI.
///
/// Centralizing formatting keeps number/date rendering consistent and makes it
/// trivial to adjust styles in one place.
abstract final class Formatters {
  const Formatters._();

  /// Formats an integer with thousands separators, e.g. `15750` -> `15,750`.
  static String points(int value, {String? locale}) {
    return NumberFormat.decimalPattern(locale).format(value);
  }

  /// Formats a signed points delta, e.g. `500` -> `+500`, `-1000` -> `-1,000`.
  static String signedPoints(int value, {String? locale}) {
    final formatted = NumberFormat.decimalPattern(locale).format(value.abs());
    final sign = value >= 0 ? '+' : '-';
    return '$sign$formatted';
  }

  /// A short, human-friendly date like `Feb 15, 2024`.
  static String shortDate(DateTime date, {String? locale}) {
    return DateFormat.yMMMd(locale).format(date.toLocal());
  }

  /// Date and time like `Feb 15, 2024, 2:30 PM`.
  static String dateTime(DateTime date, {String? locale}) {
    return DateFormat.yMMMd(locale).add_jm().format(date.toLocal());
  }
}
