import 'package:flutter_test/flutter_test.dart';
import 'package:shop_plus/core/utils/validators.dart';

void main() {
  group('isValidEgyptianPhone', () {
    test('accepts valid +20 mobile numbers', () {
      expect(Validators.isValidEgyptianPhone('+201012345678'), isTrue);
      expect(Validators.isValidEgyptianPhone('+201112345678'), isTrue);
      expect(Validators.isValidEgyptianPhone('+201234567890'), isTrue);
      expect(Validators.isValidEgyptianPhone('+201512345678'), isTrue);
    });

    test('rejects invalid phone numbers', () {
      expect(Validators.isValidEgyptianPhone('01012345678'), isFalse);
      expect(Validators.isValidEgyptianPhone('+2010123456'), isFalse);
      expect(Validators.isValidEgyptianPhone('+201312345678'), isFalse);
      expect(Validators.isValidEgyptianPhone('+11012345678'), isFalse);
      expect(Validators.isValidEgyptianPhone(''), isFalse);
    });
  });

  group('isValidEmail', () {
    test('accepts well-formed emails', () {
      expect(Validators.isValidEmail('user@test.com'), isTrue);
      expect(Validators.isValidEmail('a.b+c@sub.domain.io'), isTrue);
    });

    test('rejects malformed emails', () {
      expect(Validators.isValidEmail('user@'), isFalse);
      expect(Validators.isValidEmail('user'), isFalse);
      expect(Validators.isValidEmail('user @test.com'), isFalse);
      expect(Validators.isValidEmail(''), isFalse);
    });
  });

  group('isValidRecipient', () {
    test('is true for either a valid phone or email', () {
      expect(Validators.isValidRecipient('+201012345678'), isTrue);
      expect(Validators.isValidRecipient('user@test.com'), isTrue);
    });

    test('is false for garbage input', () {
      expect(Validators.isValidRecipient('not-a-recipient'), isFalse);
    });
  });
}
