/// Pure, reusable input validation helpers.
///
/// These return booleans only; the UI layer maps a failure to a localized
/// message. Keeping them pure makes them trivial to unit-test.
abstract final class Validators {
  const Validators._();

  /// Egyptian mobile in international format: `+20` followed by a valid
  /// operator prefix (10/11/12/15) and 8 more digits, e.g. `+201012345678`.
  static final RegExp _egyptianPhone = RegExp(r'^\+20(10|11|12|15)\d{8}$');

  /// Pragmatic email pattern (not full RFC 5322, but rejects obvious garbage).
  static final RegExp _email =
      RegExp(r'^[\w.+-]+@[\w-]+\.[\w.-]+$');

  static bool isValidEgyptianPhone(String value) =>
      _egyptianPhone.hasMatch(value.trim());

  static bool isValidEmail(String value) => _email.hasMatch(value.trim());

  /// A recipient is valid if it is either a phone number or an email.
  static bool isValidRecipient(String value) =>
      isValidEgyptianPhone(value) || isValidEmail(value);
}
