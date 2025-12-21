/// Custom exceptions for the application
/// These are thrown in the data layer and caught/converted to Failures in the repository layer

class ServerException implements Exception {
  final String message;
  final String? code;

  const ServerException({
    required this.message,
    this.code,
  });

  @override
  String toString() => 'ServerException: $message';
}

class CacheException implements Exception {
  final String message;

  const CacheException({required this.message});

  @override
  String toString() => 'CacheException: $message';
}

class NetworkException implements Exception {
  final String message;

  const NetworkException({this.message = 'No internet connection'});

  @override
  String toString() => 'NetworkException: $message';
}

class ValidationException implements Exception {
  final Map<String, String> errors;

  const ValidationException({required this.errors});

  @override
  String toString() => 'ValidationException: ${errors.toString()}';
}

class AuthException implements Exception {
  final String message;
  final String code;

  const AuthException({
    required this.message,
    required this.code,
  });

  @override
  String toString() => 'AuthException($code): $message';
}

class NotFoundException implements Exception {
  final String message;

  const NotFoundException({required this.message});

  @override
  String toString() => 'NotFoundException: $message';
}

class BusinessException implements Exception {
  final String message;
  final String? code;

  const BusinessException({
    required this.message,
    this.code,
  });

  @override
  String toString() => 'BusinessException: $message';
}
