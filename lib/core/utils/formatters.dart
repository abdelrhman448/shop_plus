import 'package:intl/intl.dart';

// Number/date formatting in one place so it looks the same everywhere.
abstract final class Formatters {
  const Formatters._();

  // 15750 -> "15,750"
  static String points(int value, {String? locale}) {
    return NumberFormat.decimalPattern(locale).format(value);
  }

  // Keeps the sign: 500 -> "+500", -1000 -> "-1,000"
  static String signedPoints(int value, {String? locale}) {
    final formatted = NumberFormat.decimalPattern(locale).format(value.abs());
    final sign = value >= 0 ? '+' : '-';
    return '$sign$formatted';
  }

  // e.g. "Feb 15, 2024"
  static String shortDate(DateTime date, {String? locale}) {
    return DateFormat.yMMMd(locale).format(date.toLocal());
  }

  // e.g. "Feb 15, 2024, 2:30 PM"
  static String dateTime(DateTime date, {String? locale}) {
    return DateFormat.yMMMd(locale).add_jm().format(date.toLocal());
  }
}
