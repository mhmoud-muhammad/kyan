// lib/data/repositories/auth_repository_impl.dart

import 'package:dartz/dartz.dart';
import 'package:myapp/core/errors/exception_mapper.dart';
import 'package:myapp/core/errors/exceptions.dart';
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
  Future<Either<Failure, String>> resetPassword(ResetPasswordParams params) async {
    if (!await networkInfo.isConnected) return Left(NetworkFailure());
    try {
      final msg = await remoteDataSource.resetPassword(params);
      return Right(msg);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } catch (_) {
      return Left(ServerFailure('حدث خطأ غير متوقع'));
    }
  }

  

  /// 🔹 تسجيل الدخول
  @override
  Future<Either<Failure, AuthResponse>> login({
    required String phone,
    required String password,
  }) async {
    if (!await networkInfo.isConnected) {
      return Left(NetworkFailure());
    }

    try {
      // 1️⃣ Login (يحفظ access + refresh داخليًا)
      final authResponse = await remoteDataSource.login(phone, password);
     
      // 2️⃣ بناء User من البيانات المتاحة (role)
      final user = User(role: authResponse.role, id: '', name: '', phone: '');

      // 3️⃣ تخزين User محليًا
      await localDataSource.cacheUser(user);

      return Right(authResponse);
      
    }on Exception catch (e) {
  return Left(mapExceptionToFailure(e));
}
  }

  /// 🔹 استرجاع بيانات المستخدم الحالي (مع Proactive Refresh)
  @override
  Future<Either<Failure, User>> getCurrentUser() async {
    try {
      // 1️⃣ أولوية للكاش
      final cachedUser = await localDataSource.getCachedUser();
      if (cachedUser != null) {
        return Right(cachedUser);
      }

      // 2️⃣ تحقق من الاتصال
      if (!await networkInfo.isConnected) {
        return Left(NetworkFailure());
      }

      // 3️⃣ جلب المستخدم من الـ API
      final userData = await remoteDataSource.getCurrentUser();
      final user = User.fromJson(userData);

      await localDataSource.cacheUser(user);
      return Right(user);
    } on Exception catch (e) {
  return Left(mapExceptionToFailure(e));
}
  }

  /// 🔹 تسجيل الخروج
  @override
  Future<Either<Failure, void>> logout() async {
    try {
      if (await networkInfo.isConnected) {
        final refreshToken = await localDataSource.getRefreshToken();
        await remoteDataSource.logout(refreshToken!);
      }

      await localDataSource.clearAuthData();
      return const Right(null);
    } on Exception catch (e) {
  return Left(mapExceptionToFailure(e));
}
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
    try {
      final refreshToken = await localDataSource.getRefreshToken();
      if (refreshToken == null) {
        return Left(UnauthorizedFailure('No refresh token found'));
      }

      final newAccessToken = await remoteDataSource.refreshToken(refreshToken);

      await localDataSource.cacheTokens(newAccessToken as String, refreshToken);

      return Right(newAccessToken as String);
    } on Exception catch (e) {
  return Left(mapExceptionToFailure(e));
}
  }
}
