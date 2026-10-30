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
        'لا يوجد اتصال بالإنترنت\nيرجى التحقق من الشبكة وإعادة المحاولة',
  ]);
}

/// الخادم لم يرد في الوقت المحدد
class TimeoutFailure extends NetworkFailure {
  TimeoutFailure([
    super.message = 'الخادم لا يستجيب حالياً\nيرجى المحاولة مرة أخرى بعد قليل',
  ]);
}

/// فشل غير مصرح (مثل 401 أو انتهاء الجلسة)
class UnauthorizedFailure extends Failure {
  UnauthorizedFailure([
    super.message = 'انتهت الجلسة، يرجى تسجيل الدخول مرة أخرى',
  ]);
}

/// لا يملك المستخدم صلاحية تنفيذ الإجراء (403)
class ForbiddenFailure extends Failure {
  ForbiddenFailure([super.message = 'غير مصرح لك بتنفيذ هذا الإجراء']);
}

/// العنصر المطلوب غير موجود (404)
class NotFoundFailure extends Failure {
  NotFoundFailure([super.message = 'العنصر المطلوب غير موجود']);
}

/// فشل في الوصول للخادم الداخلي
class ServerFailure extends Failure {
  ServerFailure([
    super.message = 'حدث خطأ في الخادم\nيرجى المحاولة مرة أخرى لاحقاً',
    int? code,
  ]) : super(code: code);
}

/// فشل التحقق من صحة البيانات (Validation)
class ValidationFailure extends Failure {
  final Map<String, String> errors;

  ValidationFailure(this.errors)
    : super(errors.isNotEmpty ? errors.values.first : 'البيانات غير صحيحة');

  @override
  String toString() => 'ValidationFailure: $errors';
}

/// فشل التخزين المؤقت (Cache)
class CacheFailure extends Failure {
  CacheFailure([super.message = 'حدث خطأ في التخزين المؤقت']);
}

/// بيانات دخول خاطئة
class AuthFailure extends Failure {
  AuthFailure([super.message = 'رقم الهاتف أو كلمة المرور غير صحيحة']);
}

/// ولي الأمر خارج النطاق المسموح حول المدرسة
class LocationFailure extends Failure {
  LocationFailure([
    super.message =
        'أنت بعيد عن المدرسة أكثر من 100 متر.\nالرجاء الاقتراب من المدرسة ثم إعادة إرسال الطلب.',
    int? code,
  ]) : super(code: code);
}

/// صلاحية من الجهاز مرفوضة أو خدمة معطلة (الموقع مثلاً)
class PermissionFailure extends Failure {
  /// true إذا كان الحل الوحيد هو فتح إعدادات التطبيق/الجهاز
  final bool requiresSettings;

  PermissionFailure(super.message, {this.requiresSettings = false});
}

/// أي خطأ غير متوقع
class UnknownFailure extends Failure {
  UnknownFailure([super.message = 'حدث خطأ غير متوقع\nيرجى المحاولة مرة أخرى']);
}
