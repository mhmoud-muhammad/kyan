// lib/data/repositories/auth_repository_impl.dart

import 'package:dartz/dartz.dart';
import 'package:myapp/core/errors/error_handler.dart';
import 'package:myapp/core/network/token_manager.dart';
import 'package:myapp/domain/entities/auth_response.dart';
import 'package:myapp/domain/entities/reset_password_usecase.dart';
import 'package:myapp/domain/entities/user.dart';
import 'package:myapp/domain/repositories/auth_repository.dart';
import '../../core/errors/failures.dart';
import '../../core/network/network_info.dart';
import '../datasources/auth_local_datasource.dart';
import '../datasources/auth_remote_datasource.dart';

class AuthRepositoryImpl implements AuthRepository {
  final AuthRemoteDataSource remoteDataSource;
  final AuthLocalDataSource localDataSource;
  final NetworkInfo networkInfo;

  AuthRepositoryImpl({
    required this.remoteDataSource,
    required this.localDataSource,
    required this.networkInfo,
    required TokenManager tokenManager,
  });


  @override
  Future<Either<Failure, String>> resetPassword(
    ResetPasswordParams params,
  ) async {
    final result = await safeCall(
      () => remoteDataSource.resetPassword(params),
      networkInfo: networkInfo,
      tag: 'resetPassword',
    );
    // في إعادة تعيين كلمة المرور 401/403 معناها بيانات غير مطابقة وليس انتهاء الجلسة
    return result.leftMap(
      (f) => f is UnauthorizedFailure || f is ForbiddenFailure
          ? AuthFailure('رقم الهاتف أو رقم الهوية غير صحيح')
          : f,
    );
  }

  /// 🔹 تسجيل الدخول
  @override
  Future<Either<Failure, AuthResponse>> login({
    required String phone,
    required String password,
  }) async {
    final result = await safeCall(() async {
      // 1️⃣ Login (يحفظ access + refresh داخليًا)
      final authResponse = await remoteDataSource.login(phone, password);

      // 2️⃣ بناء User من البيانات المتاحة (role) وتخزينه محليًا
      final user = User(
        role: authResponse.role,
        id: null,
        name: null,
        phone: phone,
      );
      await localDataSource.cacheUser(user);

      return authResponse;
    }, networkInfo: networkInfo, tag: 'login');

    // 401 في تسجيل الدخول = رقم الهاتف أو كلمة المرور غير صحيحة
    return result.leftMap((f) => f is UnauthorizedFailure ? AuthFailure() : f);
  }

  /// 🔹 استرجاع بيانات المستخدم الحالي
  @override
  Future<Either<Failure, User>> getCurrentUser() async {
    // 1️⃣ أولوية للكاش
    final cachedUser = await localDataSource.getCachedUser();
    if (cachedUser != null) return Right(cachedUser);

    // 2️⃣ جلب المستخدم من الـ API
    return safeCall(() async {
      final userData = await remoteDataSource.getCurrentUser();
      final user = User.fromJson(userData);
      await localDataSource.cacheUser(user);
      return user;
    }, networkInfo: networkInfo, tag: 'getCurrentUser');
  }

  /// 🔹 تسجيل الخروج
  /// يتم مسح بيانات الجلسة محلياً دائماً، حتى لو فشل إبلاغ السيرفر
  /// (مثلاً بدون إنترنت) حتى لا يبقى المستخدم عالقاً.
  @override
  Future<Either<Failure, void>> logout() async {
    try {
      final refreshToken = await localDataSource.getRefreshToken();
      if (refreshToken != null && await networkInfo.isConnected) {
        await remoteDataSource.logout(refreshToken);
      }
    } catch (e, st) {
      logError(e, st, tag: 'logout (remote)');
    }

    return safeCall(localDataSource.clearAuthData, tag: 'logout (local)');
  }

  /// 🔹 تحقق من وجود توكن صالح
  @override
  Future<Either<Failure, bool>> isAuthenticated() async {
    try {
      final hasValidToken = await localDataSource.hasValidToken();
      return Right(hasValidToken);
    } catch (_) {
      return const Right(false);
    }
  }

  /// 🔹 تحديث التوكن باستخدام Refresh Token
  @override
  Future<Either<Failure, String>> refreshToken() async {
    final refreshToken = await localDataSource.getRefreshToken();
    if (refreshToken == null) return Left(UnauthorizedFailure());

    return safeCall(() async {
      final auth = await remoteDataSource.refreshToken(refreshToken);
      await localDataSource.cacheTokens(auth.accessToken, auth.refreshToken);
      return auth.accessToken;
    }, tag: 'refreshToken');
  }
}
