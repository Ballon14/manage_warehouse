import 'package:flutter_test/flutter_test.dart';
import 'package:stockflow/core/utils/validators.dart';

void main() {
  group('Validators', () {
    group('validateEmail', () {
      test('should return null for valid email', () {
        expect(Validators.validateEmail('test@example.com'), null);
        expect(Validators.validateEmail('user.name@domain.co.id'), null);
      });

      test('should return error for invalid email', () {
        expect(Validators.validateEmail('invalid'), isNotNull);
        expect(Validators.validateEmail('test@'), isNotNull);
        expect(Validators.validateEmail('@example.com'), isNotNull);
      });

      test('should return error for empty email', () {
        expect(Validators.validateEmail(''), isNotNull);
        expect(Validators.validateEmail(null), isNotNull);
      });
    });

    group('validatePassword', () {
      test('should return null for strong password', () {
        expect(
          Validators.validatePassword('Abc123456', requireStrong: true),
          null,
        );
      });

      test('should return error for weak password', () {
        expect(
          Validators.validatePassword('abc123', requireStrong: true),
          isNotNull,
        );
        expect(
          Validators.validatePassword('ABCDEF', requireStrong: true),
          isNotNull,
        );
      });

      test('should return error for short password', () {
        expect(
          Validators.validatePassword('Abc1', requireStrong: true),
          isNotNull,
        );
      });
    });

    group('getPasswordStrength', () {
      test('should return 0 for empty password', () {
        expect(Validators.getPasswordStrength(''), 0);
      });

      test('should return low strength for weak password', () {
        final strength = Validators.getPasswordStrength('abc');
        expect(strength, lessThanOrEqualTo(2));
      });

      test('should return high strength for strong password', () {
        final strength = Validators.getPasswordStrength('Abc123!@#');
        expect(strength, greaterThanOrEqualTo(3));
      });
    });

    group('validatePositiveNumber', () {
      test('should return null for positive number', () {
        expect(Validators.validatePositiveNumber('123'), null);
        expect(Validators.validatePositiveNumber('0.5'), null);
      });

      test('should return error for negative or zero', () {
        expect(Validators.validatePositiveNumber('-1'), isNotNull);
        expect(Validators.validatePositiveNumber('0'), isNotNull);
      });

      test('should return error for non-numeric', () {
        expect(Validators.validatePositiveNumber('abc'), isNotNull);
      });
    });

    group('sanitizeInput', () {
      test('should remove dangerous characters', () {
        final result = Validators.sanitizeInput('<script>alert("xss")</script>');
        expect(result.contains('<'), false);
        expect(result.contains('>'), false);
      });

      test('should trim whitespace', () {
        expect(Validators.sanitizeInput('  test  '), 'test');
      });

      test('should remove null bytes', () {
        final result = Validators.sanitizeInput('test\u0000null');
        expect(result.contains('\u0000'), false);
      });
    });
  });
}
