/// Security configuration constants
class SecurityConstants {
  // Password requirements
  static const int minPasswordLength = 8;
  static const int maxPasswordLength = 128;
  static const bool requireUppercase = true;
  static const bool requireLowercase = true;
  static const bool requireDigit = true;
  static const bool requireSpecialChar = false; // Optional for now

  // Rate limiting (local)
  static const int maxLoginAttempts = 5;
  static const Duration loginAttemptWindow = Duration(minutes: 15);
  static const Duration loginLockoutDuration = Duration(minutes: 30);

  // Session management
  static const Duration sessionTimeout = Duration(hours: 24);
  static const Duration inactivityTimeout = Duration(hours: 2);

  // Input constraints
  static const int maxInputLength = 255;
  static const int maxTextLength = 1000;
  static const int maxNameLength = 100;

  // Firestore security
  static const int maxBatchSize = 500;
  static const int maxQueryLimit = 100;

  // File upload (if implemented)
  static const int maxFileSize = 5 * 1024 * 1024; // 5MB
  static const List<String> allowedImageTypes = ['jpg', 'jpeg', 'png', 'webp'];

  // API rate limiting
  static const int maxRequestsPerMinute = 60;
  static const Duration requestWindow = Duration(minutes: 1);
}

/// Environment-specific configuration
class AppConfig {
  static const String appName = 'Manage Your Logistic';
  static const String appVersion = '1.0.0';

  // Environment flags
  static const bool isProduction = bool.fromEnvironment(
    'dart.vm.product',
    defaultValue: false,
  );
  static const bool enableLogging = !isProduction;
  static const bool enableCrashReporting = isProduction;

  // Feature flags
  static const bool enableBiometric = false; // Disabled for now
  static const bool enableOfflineMode = false; // Future feature
  static const bool enableAnalytics = false; // Future feature

  // Firebase config (these should ideally come from environment variables)
  static const String firestoreMaxRetries = '3';
  static const String firestoreTimeout = '30000'; // ms
}

/// Common error messages
class ErrorMessages {
  // Authentication errors
  static const String emailRequired = 'Email wajib diisi';
  static const String emailInvalid = 'Format email tidak valid';
  static const String passwordRequired = 'Password wajib diisi';
  static const String passwordTooShort = 'Password minimal 8 karakter';
  static const String passwordTooWeak =
      'Password harus mengandung huruf besar, kecil, dan angka';
  static const String loginFailed = 'Login gagal, periksa email dan password';
  static const String accountLocked =
      'Akun terkunci karena terlalu banyak percobaan login. Coba lagi nanti.';

  // Network errors
  static const String noInternet = 'Tidak ada koneksi internet';
  static const String serverError = 'Terjadi kesalahan pada server';
  static const String timeoutError = 'Koneksi timeout, coba lagi';

  // Validation errors
  static const String fieldRequired = 'Field ini wajib diisi';
  static const String invalidNumber = 'Harus berupa angka';
  static const String invalidFormat = 'Format tidak valid';

  // Stock errors
  static const String insufficientStock = 'Stok tidak mencukupi';
  static const String invalidQuantity = 'Jumlah tidak valid';

  // Generic errors
  static const String unknownError = 'Terjadi kesalahan yang tidak diketahui';
  static const String permissionDenied = 'Akses ditolak';
}

/// Success messages
class SuccessMessages {
  static const String loginSuccess = 'Login berhasil';
  static const String logoutSuccess = 'Logout berhasil';
  static const String registrationSuccess = 'Registrasi berhasil';
  static const String updateSuccess = 'Data berhasil diupdate';
  static const String createSuccess = 'Data berhasil dibuat';
  static const String deleteSuccess = 'Data berhasil dihapus';
  static const String stockUpdateSuccess = 'Stok berhasil diupdate';
}
