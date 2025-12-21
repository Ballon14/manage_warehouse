/// Input validators for form fields and data validation
class Validators {
  /// Validate email address
  /// Returns null if valid, error message if invalid
  static String? validateEmail(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Email wajib diisi';
    }

    // Email regex pattern
    final emailRegex = RegExp(
      r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$',
    );

    if (!emailRegex.hasMatch(value.trim())) {
      return 'Format email tidak valid';
    }

    return null;
  }

  /// Validate password with strength requirements
  /// Returns null if valid, error message if invalid
  static String? validatePassword(String? value, {bool requireStrong = true}) {
    if (value == null || value.isEmpty) {
      return 'Password wajib diisi';
    }

    if (value.length < 8) {
      return 'Password minimal 8 karakter';
    }

    if (requireStrong) {
      // Check for uppercase
      if (!value.contains(RegExp(r'[A-Z]'))) {
        return 'Password harus mengandung huruf besar';
      }

      // Check for lowercase
      if (!value.contains(RegExp(r'[a-z]'))) {
        return 'Password harus mengandung huruf kecil';
      }

      // Check for digit
      if (!value.contains(RegExp(r'[0-9]'))) {
        return 'Password harus mengandung angka';
      }
    }

    return null;
  }

  /// Get password strength level (0-4)
  /// 0 = Very Weak, 1 = Weak, 2 = Fair, 3 = Good, 4 = Strong
  static int getPasswordStrength(String password) {
    if (password.isEmpty) return 0;

    int strength = 0;

    // Length check
    if (password.length >= 8) strength++;
    if (password.length >= 12) strength++;

    // Character variety checks
    if (password.contains(RegExp(r'[a-z]'))) strength++;
    if (password.contains(RegExp(r'[A-Z]'))) strength++;
    if (password.contains(RegExp(r'[0-9]'))) strength++;
    if (password.contains(RegExp(r'[!@#$%^&*(),.?":{}|<>]'))) strength++;

    // Cap at 4
    return strength > 4 ? 4 : strength;
  }

  /// Validate required field
  static String? validateRequired(String? value, String fieldName) {
    if (value == null || value.trim().isEmpty) {
      return '$fieldName wajib diisi';
    }
    return null;
  }

  /// Validate numeric string
  static String? validateNumeric(String? value, {String? fieldName}) {
    if (value == null || value.trim().isEmpty) {
      return '${fieldName ?? 'Nilai'} wajib diisi';
    }

    if (double.tryParse(value) == null) {
      return '${fieldName ?? 'Nilai'} harus berupa angka';
    }

    return null;
  }

  /// Validate positive number
  static String? validatePositiveNumber(String? value, {String? fieldName}) {
    final numericError = validateNumeric(value, fieldName: fieldName);
    if (numericError != null) return numericError;

    final number = double.parse(value!);
    if (number <= 0) {
      return '${fieldName ?? 'Nilai'} harus lebih besar dari 0';
    }

    return null;
  }

  /// Validate barcode format (example: alphanumeric)
  static String? validateBarcode(String? value) {
    if (value == null || value.trim().isEmpty) {
      return null; // Barcode is optional
    }

    // Allow alphanumeric and hyphens
    if (!RegExp(r'^[a-zA-Z0-9-]+$').hasMatch(value)) {
      return 'Barcode hanya boleh mengandung huruf, angka, dan tanda strip';
    }

    if (value.length < 3) {
      return 'Barcode minimal 3 karakter';
    }

    return null;
  }

  /// Validate SKU format
  static String? validateSKU(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'SKU wajib diisi';
    }

    // Allow alphanumeric and hyphens/underscores
    if (!RegExp(r'^[a-zA-Z0-9-_]+$').hasMatch(value)) {
      return 'SKU hanya boleh mengandung huruf, angka, strip, dan underscore';
    }

    if (value.length < 2) {
      return 'SKU minimal 2 karakter';
    }

    return null;
  }

  /// Sanitize string input (remove potentially harmful characters)
  static String sanitizeInput(String input) {
    // Remove leading/trailing whitespace
    String sanitized = input.trim();

    // Remove null bytes
    sanitized = sanitized.replaceAll('\u0000', '');

    // Remove or escape potentially dangerous characters for Firestore
    // (Firestore is generally safe, but good practice)
    sanitized = sanitized.replaceAll(RegExp(r'[<>]'), '');

    return sanitized;
  }

  /// Validate phone number (Indonesian format)
  static String? validatePhone(String? value) {
    if (value == null || value.trim().isEmpty) {
      return null; // Phone is optional
    }

    // Remove spaces and hyphens for validation
    final cleaned = value.replaceAll(RegExp(r'[\s-]'), '');

    // Indonesian phone numbers: 08xx or +628xx (10-13 digits)
    if (!RegExp(r'^(\+62|62|0)[0-9]{9,12}$').hasMatch(cleaned)) {
      return 'Format nomor telepon tidak valid';
    }

    return null;
  }
}
