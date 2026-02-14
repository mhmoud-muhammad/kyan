import 'package:dartz/dartz.dart';
import 'package:myapp/core/errors/exceptions.dart';
import 'package:myapp/core/network/token_manager.dart';
import 'package:myapp/domain/entities/auth_response.dart';
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
  final TokenManager tokenManager;

  AuthRepositoryImpl({
    required this.remoteDataSource,
    required this.localDataSource,
    required this.networkInfo,
    required this.tokenManager,
  });

  /// 🔹 تسجيل الدخول
  @override
  Future<Either<Failure, AuthResponse>> login({
    required String email,
    required String password,
  }) async {
    if (!await networkInfo.isConnected) return Left(NetworkFailure());

    try {
      final authResponse = await remoteDataSource.login(email, password);

      // حفظ التوكن ووقت الإصدار
      await localDataSource.cacheTokens(
        authResponse.accessToken,
        authResponse.refreshToken,
      );

      // حفظ بيانات المستخدم
      await localDataSource.cacheUser(authResponse.user);

      // تحديث TokenManager
      await tokenManager.markTokenRefreshed();

      return Right(authResponse);
    } on UnauthorizedException catch (e) {
      return Left(UnauthorizedFailure(e.message));
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  /// 🔹 تسجيل مستخدم جديد
  @override
  Future<Either<Failure, AuthResponse>> register({
    required String email,
    required String password,
    required String name,
    String? phone,
  }) async {
    if (!await networkInfo.isConnected) return Left(NetworkFailure());

    try {
      final authResponse = await remoteDataSource.register(
        email: email,
        password: password,
        name: name,
        phone: phone,
      );

      await localDataSource.cacheTokens(
        authResponse.accessToken,
        authResponse.refreshToken,
      );
      await localDataSource.cacheUser(authResponse.user);
      await tokenManager.markTokenRefreshed();

      return Right(authResponse);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  /// 🔹 استرجاع بيانات المستخدم الحالي مع Proactive refresh
  @override
  Future<Either<Failure, User>> getCurrentUser() async {
    try {
      final cachedUser = await localDataSource.getCachedUser();
      if (cachedUser != null) return Right(cachedUser);

      if (!await networkInfo.isConnected) return Left(CacheFailure());

      // Proactive refresh
      if (await tokenManager.shouldRefresh()) {
        await tokenManager.runRefresh(() async {
          final refreshToken = await localDataSource.getRefreshToken();
          if (refreshToken != null) {
            final newAccessToken =
                await remoteDataSource.refreshToken(refreshToken);
            await localDataSource.cacheTokens(newAccessToken, refreshToken);
            await tokenManager.markTokenRefreshed();
          }
        });
      }

      // جلب بيانات المستخدم من API
      final userData = await remoteDataSource.getCurrentUser();
      final user = User.fromJson(userData);

      await localDataSource.cacheUser(user);
      return Right(user);
    } on UnauthorizedException catch (e) {
      return Left(UnauthorizedFailure(e.message));
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } catch (_) {
      return Left(CacheFailure());
    }
  }

  /// 🔹 تسجيل الخروج
  @override
  Future<Either<Failure, void>> logout() async {
    try {
      if (await networkInfo.isConnected) {
        await remoteDataSource.logout();
      }
      await localDataSource.clearAuthData();
      return const Right(null);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  /// 🔹 تحقق من وجود توكن صالح
  @override
  Future<Either<Failure, bool>> isAuthenticated() async {
    try {
      final hasToken = await localDataSource.hasValidToken();
      return Right(hasToken);
    } catch (_) {
      return const Right(false);
    }
  }

  /// 🔹 تحديث التوكن
  @override
  Future<Either<Failure, String>> refreshToken() async {
    try {
      final refreshToken = await localDataSource.getRefreshToken();
      if (refreshToken == null) {
        return Left(UnauthorizedFailure('No refresh token found'));
      }

      final newAccessToken =
          await remoteDataSource.refreshToken(refreshToken);

      await localDataSource.cacheTokens(newAccessToken, refreshToken);
      await tokenManager.markTokenRefreshed();

      return Right(newAccessToken);
    } on UnauthorizedException catch (e) {
      return Left(UnauthorizedFailure(e.message));
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }
}
