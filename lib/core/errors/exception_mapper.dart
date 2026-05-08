// lib/core/errors/exception_mapper.dart
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

Failure mapExceptionToFailure(Object e) {
  // ✅ Kyan Exceptions
  if (e is NetworkException) return NetworkFailure(e.message);
  if (e is UnauthorizedException) return UnauthorizedFailure(e.message);
  if (e is ServerException) return ServerFailure(e.message, e.code);
  if (e is CacheException) return CacheFailure(e.message);
  if (e is ValidationException) return ValidationFailure(e.errors);
  if (e is DioException && e.error is NetworkException) {
    return NetworkFailure((e.error as NetworkException).message);
  }

  // ✅ DioException
  if (e is DioException) {
    // 1) انقطاع شبكة / SocketException
    final isSocket = e.error is SocketException;
    final isNetworkType =
        e.type == DioExceptionType.connectionError ||
        e.type == DioExceptionType.connectionTimeout ||
        e.type == DioExceptionType.receiveTimeout ||
        e.type == DioExceptionType.sendTimeout;

    if (isSocket || isNetworkType) {
      return NetworkFailure();
    }

    // 2) رد من السيرفر
    final status = e.response?.statusCode;
    final data = e.response?.data;

    String? serverMsg = _extractServerMessage(data);

    if (status == 401) {
      return UnauthorizedFailure(
        serverMsg ?? 'انتهت الجلسة، يرجى تسجيل الدخول مرة أخرى',
      );
    }
    if (status == 400 && _isOutOfSchoolRangeMessage(serverMsg)) {
      return LocationFailure(
        'أنت بعيد عن المدرسة أكثر من 100 متر.\n'
        'الرجاء الاقتراب من المدرسة ثم إعادة إرسال الطلب.',
        status,
      );
    }
    if (status == 403) {
      return UnauthorizedFailure(serverMsg ?? 'غير مصرح لك بتنفيذ هذا الإجراء');
    }
    if (status == 422 || status == 400) {
      final errors = _extractValidationErrors(data);
      if (errors != null && errors.isNotEmpty) {
        return ValidationFailure(errors);
      }
      return ValidationFailure({'error': serverMsg ?? 'بيانات غير صحيحة'});
    }
    if (status != null && status >= 500) {
      return ServerFailure(
        serverMsg ??
            'أنت بعيد عن المدرسة أكثر من 100 متر.\n'
                'الرجاء الاقتراب من المدرسة ثم إعادة إرسال الطلب.',
        status,
      );
    }

    return ServerFailure(
      serverMsg ??
          'أنت بعيد عن المدرسة أكثر من 100 متر.\n'
              'الرجاء الاقتراب من المدرسة ثم إعادة إرسال الطلب.',
      status,
    );
  }

  // ✅ أي Exception عام
  return ServerFailure( 'أنت بعيد عن المدرسة أكثر من 100 متر.\n'
              'الرجاء الاقتراب من المدرسة ثم إعادة إرسال الطلب.');
}

String? _extractServerMessage(dynamic data) {
  if (data == null) return null;

  if (data is String) return data;

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
    if (v is String) out[k.toString()] = v;
  });

  return out;
}
