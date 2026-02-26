// lib/core/errors/exception_mapper.dart
import 'package:dio/dio.dart';
import 'package:myapp/core/errors/exceptions.dart';
import 'package:myapp/core/errors/failures.dart';

Failure mapExceptionToFailure(Exception e) {
  // 🔹 DioException
  if (e is DioException) {
    if (e.type == DioExceptionType.connectionTimeout ||
        e.type == DioExceptionType.connectionError ||
        e.type == DioExceptionType.receiveTimeout ||
        e.type == DioExceptionType.sendTimeout) {
      return NetworkFailure();
    }

    final statusCode = e.response?.statusCode;
    switch (statusCode) {
      case 401:
        return UnauthorizedFailure('بيانات الدخول غير صحيحة');
      case 500:
        return ServerFailure('خطأ في السيرفر');

      case 403:
        return UnauthorizedFailure(
          e.response?.data['detail'] ?? 'غير مصرح لك بتنفيذ هذا الإجراء',
        );
      default:
        return ServerFailure('حدث خطأ غير متوقع');
    }
  }

  if (e is NetworkException) {
    return NetworkFailure(e.message);
  }

  if (e is UnauthorizedException) {
    return UnauthorizedFailure(e.message);
  }

  if (e is ServerException) {
    return ServerFailure(e.message, e.code);
  }

  if (e is CacheException) {
    return CacheFailure(e.message);
  }

  if (e is ValidationException) {
    return ValidationFailure(e.errors);
  }

  // 🔹 fallback
  return ServerFailure('حدث خطأ غير متوقع');
}
