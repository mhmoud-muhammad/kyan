// test/widget_test.dart
import 'dart:io';

import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:myapp/core/errors/error_handler.dart';
import 'package:myapp/core/errors/exception_mapper.dart';
import 'package:myapp/core/errors/exceptions.dart';
import 'package:myapp/core/errors/failures.dart';

DioException _response(int status, dynamic data) {
  final options = RequestOptions(path: '/x');
  return DioException(
    requestOptions: options,
    type: DioExceptionType.badResponse,
    response: Response(requestOptions: options, statusCode: status, data: data),
  );
}

void main() {
  group('mapExceptionToFailure', () {
    test('connection error → NetworkFailure', () {
      final e = DioException(
        requestOptions: RequestOptions(path: '/x'),
        type: DioExceptionType.connectionError,
      );
      expect(mapExceptionToFailure(e), isA<NetworkFailure>());
    });

    test('timeout → TimeoutFailure', () {
      final e = DioException(
        requestOptions: RequestOptions(path: '/x'),
        type: DioExceptionType.receiveTimeout,
      );
      expect(mapExceptionToFailure(e), isA<TimeoutFailure>());
    });

    test('NetworkException wrapped by ApiClient', () {
      final e = DioException(
        requestOptions: RequestOptions(path: '/x'),
        error: NetworkException(),
      );
      expect(mapExceptionToFailure(e), isA<NetworkFailure>());
    });

    test('SocketException → NetworkFailure', () {
      expect(
        mapExceptionToFailure(const SocketException('x')),
        isA<NetworkFailure>(),
      );
    });

    test('400 out of school range → LocationFailure', () {
      final f = mapExceptionToFailure(
        _response(400, {
          'detail': 'التحقق من الموقع فشل: لست في النطاق المسموح',
        }),
      );
      expect(f, isA<LocationFailure>());
    });

    test('400 field errors → ValidationFailure with first message', () {
      final f = mapExceptionToFailure(
        _response(400, {
          'phone': ['رقم الهاتف غير صحيح'],
        }),
      );
      expect(f, isA<ValidationFailure>());
      expect(failureMessage(f), 'رقم الهاتف غير صحيح');
    });

    test('401 → UnauthorizedFailure', () {
      expect(
        mapExceptionToFailure(_response(401, null)),
        isA<UnauthorizedFailure>(),
      );
    });

    test('500 never shows the out-of-range message', () {
      final f = mapExceptionToFailure(
        _response(500, '<html>Server Error</html>'),
      );
      expect(f, isA<ServerFailure>());
      expect(f.message.contains('بعيد'), isFalse);
      expect(f.message.contains('<html>'), isFalse);
    });

    test('unknown error never shows the out-of-range message', () {
      final f = mapExceptionToFailure(Exception('boom'));
      expect(f, isA<UnknownFailure>());
      expect(f.message.contains('بعيد'), isFalse);
    });

    test('bad JSON → ServerFailure', () {
      expect(
        mapExceptionToFailure(const FormatException('bad')),
        isA<ServerFailure>(),
      );
    });

    test('Failure passes through unchanged', () {
      final f = AuthFailure();
      expect(mapExceptionToFailure(f), same(f));
    });
  });

  group('safeCall', () {
    test('returns Right on success', () async {
      final r = await safeCall(() async => 42);
      expect(r.getOrElse(() => 0), 42);
    });

    test('returns Left(Failure) on error', () async {
      final r = await safeCall<int>(() async => throw NetworkException());
      expect(r.isLeft(), isTrue);
      r.fold((f) => expect(f, isA<NetworkFailure>()), (_) => fail('Right'));
    });
  });
}
