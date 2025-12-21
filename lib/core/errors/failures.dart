/// Base class for all application failures
abstract class Failure {
  final String message;
  final String? code;
  final dynamic originalError;

  const Failure({
    required this.message,
    this.code,
    this.originalError,
  });

  @override
  String toString() => message;
}

/// Server/Firebase related failures
class ServerFailure extends Failure {
  const ServerFailure({
    required super.message,
    super.code,
    super.originalError,
  });

  factory ServerFailure.fromException(dynamic e) {
    if (e.toString().contains('network')) {
      return const ServerFailure(
        message: 'Koneksi internet bermasalah',
        code: 'network-error',
      );
    }
    return ServerFailure(
      message: 'Terjadi kesalahan pada server',
      code: 'server-error',
      originalError: e,
    );
  }
}

/// Cache/Local storage failures
class CacheFailure extends Failure {
  const CacheFailure({
    required super.message,
    super.code,
    super.originalError,
  });

  factory CacheFailure.fromException(dynamic e) {
    return CacheFailure(
      message: 'Gagal mengakses penyimpanan lokal',
      code: 'cache-error',
      originalError: e,
    );
  }
}

/// Input validation failures
class ValidationFailure extends Failure {
  final Map<String, String>? fieldErrors;

  const ValidationFailure({
    required super.message,
    super.code,
    this.fieldErrors,
  });

  factory ValidationFailure.single(String field, String error) {
    return ValidationFailure(
      message: error,
      code: 'validation-error',
      fieldErrors: {field: error},
    );
  }

  factory ValidationFailure.multiple(Map<String, String> errors) {
    return ValidationFailure(
      message: 'Terdapat kesalahan pada input',
      code: 'validation-error',
      fieldErrors: errors,
    );
  }
}

/// Network/connectivity failures
class NetworkFailure extends Failure {
  const NetworkFailure({
    super.message = 'Tidak ada koneksi internet',
    super.code = 'network-failure',
    super.originalError,
  });
}

/// Authentication failures
class AuthFailure extends Failure {
  const AuthFailure({
    required super.message,
    super.code,
    super.originalError,
  });

  factory AuthFailure.invalidCredentials() {
    return const AuthFailure(
      message: 'Email atau password salah',
      code: 'invalid-credentials',
    );
  }

  factory AuthFailure.userNotFound() {
    return const AuthFailure(
      message: 'Email tidak terdaftar',
      code: 'user-not-found',
    );
  }

  factory AuthFailure.emailAlreadyInUse() {
    return const AuthFailure(
      message: 'Email sudah terdaftar',
      code: 'email-already-in-use',
    );
  }

  factory AuthFailure.weakPassword() {
    return const AuthFailure(
      message: 'Password terlalu lemah',
      code: 'weak-password',
    );
  }

  factory AuthFailure.accountLocked(int minutesRemaining) {
    return AuthFailure(
      message: 'Akun terkunci. Coba lagi dalam $minutesRemaining menit',
      code: 'account-locked',
    );
  }
}

/// Permission/Authorization failures
class PermissionFailure extends Failure {
  const PermissionFailure({
    super.message = 'Anda tidak memiliki akses',
    super.code = 'permission-denied',
    super.originalError,
  });
}

/// Not found failures
class NotFoundFailure extends Failure {
  const NotFoundFailure({
    required super.message,
    super.code = 'not-found',
    super.originalError,
  });

  factory NotFoundFailure.item(String itemName) {
    return NotFoundFailure(
      message: '$itemName tidak ditemukan',
    );
  }
}

/// Business logic failures
class BusinessFailure extends Failure {
  const BusinessFailure({
    required super.message,
    super.code = 'business-logic-error',
    super.originalError,
  });

  factory BusinessFailure.insufficientStock(double available, double requested) {
    return BusinessFailure(
      message: 'Stok tidak mencukupi. Tersedia: $available, Diminta: $requested',
      code: 'insufficient-stock',
    );
  }

  factory BusinessFailure.invalidQuantity() {
    return const BusinessFailure(
      message: 'Jumlah tidak valid',
      code: 'invalid-quantity',
    );
  }
}

/// Unknown/unexpected failures
class UnknownFailure extends Failure {
  const UnknownFailure({
    super.message = 'Terjadi kesalahan yang tidak diketahui',
    super.code = 'unknown-error',
    super.originalError,
  });

  factory UnknownFailure.fromException(dynamic e) {
    return UnknownFailure(
      message: 'Terjadi kesalahan: ${e.toString()}',
      originalError: e,
    );
  }
}
