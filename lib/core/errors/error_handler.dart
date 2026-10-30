// lib/core/errors/error_handler.dart
import 'package:dartz/dartz.dart';
import 'package:flutter/foundation.dart';
import 'package:myapp/core/errors/exception_mapper.dart';
import 'package:myapp/core/errors/failures.dart';
import 'package:myapp/core/network/network_info.dart';

/// ينفّذ عملية من طبقة البيانات ويحوّل أي خطأ إلى Failure.
/// تستخدمه الـ Repositories بدل تكرار try/catch في كل دالة.
Future<Either<Failure, T>> safeCall<T>(
  Future<T> Function() action, {
  NetworkInfo? networkInfo,
  String? tag,
}) async {
  if (networkInfo != null && !await networkInfo.isConnected) {
    return Left(NetworkFailure());
  }
  try {
    return Right(await action());
  } catch (e, st) {
    final failure = mapExceptionToFailure(e);
    logError(e, st, tag: tag, failure: failure);
    return Left(failure);
  }
}

/// يحوّل أي خطأ يصل للواجهة (AsyncError.error مثلاً) إلى Failure
Failure asFailure(Object? err) {
  if (err == null) return UnknownFailure();
  return mapExceptionToFailure(err);
}

/// الرسالة التي تُعرض للمستخدم لأي خطأ
String failureMessage(Object? err) {
  final f = asFailure(err);
  if (f is ValidationFailure) {
    return f.errors.isNotEmpty ? f.errors.values.first : f.message;
  }
  return f.message.trim().isNotEmpty ? f.message : UnknownFailure().message;
}

/// تسجيل الأخطاء في وضع التطوير فقط (لا نطبع بيانات حساسة في نسخة النشر)
void logError(
  Object error,
  StackTrace? stack, {
  String? tag,
  Failure? failure,
}) {
  if (!kDebugMode) return;
  debugPrint(
    '❌ ${tag != null ? '[$tag] ' : ''}$error'
    '${failure != null ? '\n   ↳ ${failure.runtimeType}: ${failure.message}' : ''}',
  );
  if (stack != null) {
    debugPrint(stack.toString().split('\n').take(6).join('\n'));
  }
}
