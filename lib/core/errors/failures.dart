// lib/core/errors/failures.dart
class Failure {
  final String message;
  final int? code;

  Failure(this.message, {this.code});

  @override
  String toString() => 'Failure: $message (Code: $code)';
}

/// فشل الشبكة (الاتصال بالإنترنت)
class NetworkFailure extends Failure {
  NetworkFailure([
    super.message =
        '❌ لا يوجد اتصال بالإنترنت\nيرجى التحقق من الشبكة وإعادة المحاولة',
  ]);
}

/// فشل غير مصرح (مثل 401 أو انتهاء الجلسة)
class UnauthorizedFailure extends Failure {
  UnauthorizedFailure([super.message = 'Session expired']);
}

/// فشل في الوصول للخادم الداخلي
class ServerFailure extends Failure {
  ServerFailure([super.message = 'خطأ داخلي في الخادم', int? code])
    : super(code: code);
}

/// فشل التحقق من صحة البيانات (Validation)
class ValidationFailure extends Failure {
  final Map<String, String> errors;

  ValidationFailure(this.errors) : super('فشل التحقق من البيانات');

  @override
  String toString() => 'ValidationFailure: $errors';
}

/// فشل التخزين المؤقت (Cache)
class CacheFailure extends Failure {
  CacheFailure([super.message = 'حدث خطأ في التخزين المؤقت']);
}

class AuthFailure extends Failure {
  AuthFailure([super.message = 'خطأ في بيانات الدخول']);
}
