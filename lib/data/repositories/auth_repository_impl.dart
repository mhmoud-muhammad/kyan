import 'package:dartz/dartz.dart';
import 'package:myapp/core/errors/exceptions.dart';
import '../../domain/repositories/auth_repository.dart';
import '../../domain/entities/user.dart';
import '../../domain/entities/auth_response.dart';
import '../datasources/auth_remote_datasource.dart';
import '../datasources/auth_local_datasource.dart';
import '../../core/errors/failures.dart';
import '../../core/network/network_info.dart';

class AuthRepositoryImpl implements AuthRepository {
  final AuthRemoteDataSource remoteDataSource;
  final AuthLocalDataSource localDataSource;
  final NetworkInfo networkInfo;
  
  AuthRepositoryImpl({
    required this.remoteDataSource,
    required this.localDataSource,
    required this.networkInfo,
  });
  
  @override
  Future<Either<Failure, AuthResponse>> login({
    required String email,
    required String password,
  }) async {
    if (await networkInfo.isConnected) {
      try {
        final authResponse = await remoteDataSource.login(email, password);
        await localDataSource.cacheAuthResponse(
          accessToken: authResponse.accessToken,
          refreshToken: authResponse.refreshToken
        );
        return Right(authResponse);
      } on ServerException catch (e) {
        return Left(ServerFailure(e.message));
      } on UnauthorizedException catch (e) {
        return Left(UnauthorizedFailure(e.message));
      } catch (e) {
        return Left(ServerFailure(e.toString()));
      }
    } else {
      return Left(NetworkFailure());
    }
  }
  
  @override
  Future<Either<Failure, AuthResponse>> register({
    required String email,
    required String password,
    required String name,
    String? phone,
  }) async {
    if (await networkInfo.isConnected) {
      try {
        final authResponse = await remoteDataSource.register(
          email: email,
          password: password,
          name: name,
          phone: phone,
        );
        await localDataSource.cacheAuthResponse(
          accessToken: authResponse.accessToken,
          refreshToken: authResponse.refreshToken,
        );
        return Right(authResponse);
      } on ServerException catch (e) {
        return Left(ServerFailure(e.message));
      } catch (e) {
        return Left(ServerFailure(e.toString()));
      }
    } else {
      return Left(NetworkFailure());
    }
  }
  
  @override
  Future<Either<Failure, User>> getCurrentUser() async {
    try {
      final cachedUser = await localDataSource.getCachedUser();
      if (cachedUser != null) {
        return Right(cachedUser);
      }
      
      if (await networkInfo.isConnected) {
        final userData = await remoteDataSource.getCurrentUser();
        final user = User.fromJson(userData);
        return Right(user);
      } else {
        return Left(CacheFailure());
      }
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } catch (e) {
      return Left(CacheFailure());
    }
  }
  
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
  
  @override
  Future<Either<Failure, bool>> isAuthenticated() async {
    try {
      final hasToken = await localDataSource.hasValidToken();
      return Right(hasToken);
    } catch (e) {
      return Right(false);
    }
  }
  
  @override
  Future<Either<Failure, String>> refreshToken() async {
    try {
      final refreshToken = await localDataSource.getRefreshToken();
      if (refreshToken == null) {
        return Left(UnauthorizedFailure('No refresh token found'));
      }
      
      final newToken = await remoteDataSource.refreshToken(refreshToken);
      return Right(newToken);
    } on UnauthorizedException catch (e) {
      return Left(UnauthorizedFailure(e.message));
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }
}