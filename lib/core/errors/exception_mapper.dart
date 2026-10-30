// lib/core/errors/exception_mapper.dart
import 'dart:async';
import 'dart:io';
import 'package:dio/dio.dart';
import 'package:myapp/core/errors/exceptions.dart';
import 'package:myapp/core/errors/failures.dart';

String _normalize(String s) {
  // يشيل المسافات + علامات شائعة لتفادي مشاكل "التحققمنالموقعفشل"
  return s
      .replaceAll(RegExp(r'\s+'), '')
      .replaceAll('.', '')
      .replaceAll('،', '')
      .replaceAll(':', '')
      .trim();
}

bool _isOutOfSchoolRangeMessage(String? msg) {
  if (msg == null || msg.trim().isEmpty) return false;
  final m = _normalize(msg);

  // كلمات مفتاحية محتملة من السيرفر
  return m.contains('التحققمنالموقعفشل') ||
      m.contains('لستفيالنطاقالمسموح') ||
      m.contains('خارجالنطاق') ||
      m.contains('بعيد') ||
      m.contains('distance') ||
      m.contains('range');
}

/// يحوّل أي خطأ (Exception / DioException / Failure) إلى Failure واحد
/// برسالة عربية مناسبة للمستخدم.
Failure mapExceptionToFailure(Object e) {
  // ✅ Failure جاهز
  if (e is Failure) return e;

  // ✅ Kyan Exceptions
  if (e is NetworkException) {
    return e.isTimeout ? TimeoutFailure() : NetworkFailure();
  }
  if (e is UnauthorizedException) return UnauthorizedFailure();
  if (e is ValidationException) return ValidationFailure(e.errors);
  if (e is CacheException) return CacheFailure(e.message);
  if (e is ServerException) return ServerFailure(e.message, e.code);

  // ✅ DioException
  if (e is DioException) return _mapDioException(e);

  // ✅ انقطاع شبكة خارج Dio (WebSocket مثلاً)
  if (e is SocketException) return NetworkFailure();
  if (e is TimeoutException) return TimeoutFailure();
  if (e is HandshakeException || e is TlsException) {
    return NetworkFailure('تعذر إنشاء اتصال آمن بالخادم\nتحقق من الشبكة');
  }

  // ✅ رد غير متوقع من السيرفر (JSON ناقص أو بنية مختلفة)
  if (e is FormatException || e is TypeError) {
    return ServerFailure('استجابة غير متوقعة من الخادم\nيرجى المحاولة لاحقاً');
  }

  // ✅ أي Exception عام
  return UnknownFailure();
}

Failure _mapDioException(DioException e) {
  // 1) أخطاء حوّلها ApiClient مسبقاً
  final inner = e.error;
  if (inner is NetworkException || inner is UnauthorizedException) {
    return mapExceptionToFailure(inner!);
  }

  // 2) انقطاع شبكة / مهلة
  switch (e.type) {
    case DioExceptionType.connectionTimeout:
    case DioExceptionType.sendTimeout:
    case DioExceptionType.receiveTimeout:
      return TimeoutFailure();
    case DioExceptionType.connectionError:
      return NetworkFailure();
    case DioExceptionType.badCertificate:
      return NetworkFailure('تعذر إنشاء اتصال آمن بالخادم\nتحقق من الشبكة');
    case DioExceptionType.cancel:
      return UnknownFailure('تم إلغاء الطلب');
    case DioExceptionType.badResponse:
    case DioExceptionType.unknown:
      break;
  }
  if (inner is SocketException) return NetworkFailure();

  // 3) رد من السيرفر
  final status = e.response?.statusCode;
  if (status == null) return UnknownFailure();

  final data = e.response?.data;
  final serverMsg = _extractServerMessage(data);

  if (status == 400 && _isOutOfSchoolRangeMessage(serverMsg)) {
    return LocationFailure(LocationFailure().message, status);
  }
  if (status == 400 || status == 422) {
    final errors = _extractValidationErrors(data);
    if (errors != null && errors.isNotEmpty) return ValidationFailure(errors);
    return ValidationFailure({'error': serverMsg ?? 'البيانات غير صحيحة'});
  }
  if (status == 401) return UnauthorizedFailure();
  if (status == 403) {
    return serverMsg != null ? ForbiddenFailure(serverMsg) : ForbiddenFailure();
  }
  if (status == 404) {
    return serverMsg != null ? NotFoundFailure(serverMsg) : NotFoundFailure();
  }
  if (status == 429) {
    return ServerFailure(
      'طلبات كثيرة خلال وقت قصير\nانتظر قليلاً ثم حاول مرة أخرى',
      status,
    );
  }
  if (status >= 500) {
    // رسائل 5xx غالباً تقنية (HTML/stack trace) فلا نعرضها للمستخدم
    return ServerFailure(ServerFailure().message, status);
  }

  return ServerFailure(serverMsg ?? ServerFailure().message, status);
}

String? _extractServerMessage(dynamic data) {
  if (data == null) return null;

  if (data is String) {
    final s = data.trim();
    // تجاهل صفحات HTML والنصوص الطويلة (أخطاء تقنية)
    if (s.isEmpty || s.startsWith('<') || s.length > 300) return null;
    return s;
  }

  if (data is Map) {
    // أشهر مفاتيح للرسائل
    final keys = ['detail', 'message', 'error', 'msg', 'non_field_errors'];
    for (final k in keys) {
      final v = data[k];
      if (v == null) continue;
      if (v is String && v.trim().isNotEmpty) return v;
      if (v is List && v.isNotEmpty) return v.first.toString();
    }
  }

  return null;
}

Map<String, String>? _extractValidationErrors(dynamic data) {
  if (data is! Map) return null;

  final out = <String, String>{};
  data.forEach((k, v) {
    if (v is List && v.isNotEmpty) out[k.toString()] = v.first.toString();
    if (v is String && v.trim().isNotEmpty) out[k.toString()] = v;
  });

  return out;
}
