import 'package:flutter_test/flutter_test.dart';
import 'package:stockflow/core/security/rate_limiter.dart';

void main() {
  group('LoginRateLimiter', () {
    late LoginRateLimiter rateLimiter;

    setUp(() {
      rateLimiter = LoginRateLimiter();
      rateLimiter.clear(); // Clear any previous state
    });

    test('should allow login initially', () {
      expect(rateLimiter.isLoginAllowed('test@example.com'), true);
    });

    test('should track failed attempts', () {
      const email = 'test@example.com';
      
      rateLimiter.recordAttempt(email, success: false);
      
      expect(rateLimiter.getRemainingAttempts(email), 4);
    });

    test('should lock account after max attempts', () {
      const email = 'test@example.com';
      
      // Record 5 failed attempts
      for (int i = 0; i < 5; i++) {
        rateLimiter.recordAttempt(email, success: false);
      }
      
      expect(rateLimiter.isLoginAllowed(email), false);
      expect(rateLimiter.getLockoutEnd(email), isNotNull);
    });

    test('should clear attempts on successful login', () {
      const email = 'test@example.com';
      
      // Record some failed attempts
      rateLimiter.recordAttempt(email, success: false);
      rateLimiter.recordAttempt(email, success: false);
      
      // Successful login should clear
      rateLimiter.recordAttempt(email, success: true);
      
      expect(rateLimiter.getRemainingAttempts(email), 5);
    });

    test('should normalize email to lowercase', () {
      const email1 = 'Test@Example.com';
      const email2 = 'test@example.com';
      
      rateLimiter.recordAttempt(email1, success: false);
      
      expect(rateLimiter.getRemainingAttempts(email2), 4);
    });
  });
}
