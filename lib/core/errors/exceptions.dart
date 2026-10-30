// lib/core/errors/exceptions.dart
class KyanException implements Exception {
  final String message;
  final int? code;

  KyanException(this.message, {this.code});

  @override
  String toString() => 'KyanException: $message (Code: $code)';
}

class ServerException extends KyanException {
  ServerException(super.message, {super.code});
}

class NetworkException extends KyanException {
  /// true إذا كان السبب انتهاء مهلة الاتصال وليس انقطاع الإنترنت
  final bool isTimeout;

  NetworkException([
    super.message = 'لا يوجد اتصال بالإنترنت',
    this.isTimeout = false,
  ]);
}

class UnauthorizedException extends KyanException {
  UnauthorizedException([
    super.message = 'انتهت الجلسة، يرجى تسجيل الدخول مرة أخرى',
  ]);
}

class CacheException extends KyanException {
  CacheException([super.message = 'حدث خطأ في التخزين المؤقت']);
}

class ValidationException extends KyanException {
  final Map<String, String> errors;

  ValidationException(this.errors) : super('البيانات غير صحيحة');
}
