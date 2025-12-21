import '../config/security_constants.dart';
import '../../utils/app_logger.dart';

/// Rate limiter for login attempts to prevent brute force attacks
class LoginRateLimiter {
  static final LoginRateLimiter _instance = LoginRateLimiter._internal();
  factory LoginRateLimiter() => _instance;
  LoginRateLimiter._internal();

  final Map<String, List<DateTime>> _attemptHistory = {};
  final Map<String, DateTime> _lockouts = {};

  /// Check if login is allowed for given email
  /// Returns true if allowed, false if rate limited
  bool isLoginAllowed(String email) {
    final normalizedEmail = email.toLowerCase().trim();

    // Check if currently locked out
    if (_lockouts.containsKey(normalizedEmail)) {
      final lockoutEnd = _lockouts[normalizedEmail]!;
      if (DateTime.now().isBefore(lockoutEnd)) {
        final remainingMinutes =
            lockoutEnd.difference(DateTime.now()).inMinutes;
        AppLogger.warning(
          'Login blocked for $normalizedEmail. $remainingMinutes minutes remaining',
          'RateLimiter',
        );
        return false;
      } else {
        // Lockout expired
        _lockouts.remove(normalizedEmail);
        _attemptHistory.remove(normalizedEmail);
      }
    }

    return true;
  }

  /// Record a login attempt
  void recordAttempt(String email, {bool success = false}) {
    final normalizedEmail = email.toLowerCase().trim();

    if (success) {
      // Clear history on successful login
      _attemptHistory.remove(normalizedEmail);
      _lockouts.remove(normalizedEmail);
      AppLogger.info('Login attempt history cleared for $normalizedEmail', 'RateLimiter');
      return;
    }

    // Record failed attempt
    if (!_attemptHistory.containsKey(normalizedEmail)) {
      _attemptHistory[normalizedEmail] = [];
    }

    final now = DateTime.now();
    _attemptHistory[normalizedEmail]!.add(now);

    // Clean up old attempts outside the window
    _attemptHistory[normalizedEmail]!.removeWhere(
      (attempt) => now.difference(attempt) > SecurityConstants.loginAttemptWindow,
    );

    // Check if max attempts exceeded
    if (_attemptHistory[normalizedEmail]!.length >=
        SecurityConstants.maxLoginAttempts) {
      final lockoutEnd = now.add(SecurityConstants.loginLockoutDuration);
      _lockouts[normalizedEmail] = lockoutEnd;
      
      AppLogger.warning(
        'Max login attempts exceeded for $normalizedEmail. Locked until $lockoutEnd',
        'RateLimiter',
      );
    }
  }

  /// Get remaining login attempts for email
  int getRemainingAttempts(String email) {
    final normalizedEmail = email.toLowerCase().trim();

    if (_lockouts.containsKey(normalizedEmail)) {
      final lockoutEnd = _lockouts[normalizedEmail]!;
      if (DateTime.now().isBefore(lockoutEnd)) {
        return 0;
      }
    }

    final attempts = _attemptHistory[normalizedEmail]?.length ?? 0;
    final remaining = SecurityConstants.maxLoginAttempts - attempts;
    return remaining > 0 ? remaining : 0;
  }

  /// Get lockout end time for email (null if not locked)
  DateTime? getLockoutEnd(String email) {
    final normalizedEmail = email.toLowerCase().trim();
    if (_lockouts.containsKey(normalizedEmail)) {
      final lockoutEnd = _lockouts[normalizedEmail]!;
      if (DateTime.now().isBefore(lockoutEnd)) {
        return lockoutEnd;
      }
    }
    return null;
  }

  /// Clear all rate limit data (for testing)
  void clear() {
    _attemptHistory.clear();
    _lockouts.clear();
  }
}
