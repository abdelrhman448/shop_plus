// Plain input checks. They return bools only; the UI turns a failure into a
// localized message. Being pure functions makes them easy to test.
abstract final class Validators {
  const Validators._();

  // Egyptian mobile like +201012345678 (+20, then 10/11/12/15, then 8 digits).
  static final RegExp _egyptianPhone = RegExp(r'^\+20(10|11|12|15)\d{8}$');

  // Not full RFC 5322, just enough to reject obvious junk.
  static final RegExp _email = RegExp(r'^[\w.+-]+@[\w-]+\.[\w.-]+$');

  static bool isValidEgyptianPhone(String value) =>
      _egyptianPhone.hasMatch(value.trim());

  static bool isValidEmail(String value) => _email.hasMatch(value.trim());

  // Recipient can be either a phone or an email.
  static bool isValidRecipient(String value) =>
      isValidEgyptianPhone(value) || isValidEmail(value);
}
