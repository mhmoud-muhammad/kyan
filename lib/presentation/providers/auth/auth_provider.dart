// lib/presentation/providers/auth_provider.dart

import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:myapp/domain/entities/reset_password_usecase.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:dio/dio.dart';

import '../../../core/network/api_client.dart';
import '../../../core/network/network_info.dart';
import '../../../core/network/token_manager.dart';

import '../../../data/datasources/auth_local_datasource.dart';
import '../../../data/datasources/auth_remote_datasource.dart';
import '../../../data/repositories/auth_repository_impl.dart';

import '../../../core/errors/failures.dart';
import '../../../domain/entities/user.dart';
import '../../../domain/usecases/login_usecase.dart';

part 'auth_provider.g.dart';

/// =====================
/// Secure Storage
/// =====================
@riverpod
FlutterSecureStorage secureStorage(SecureStorageRef ref) {
  return const FlutterSecureStorage();
}


@riverpod
ResetPasswordUseCase resetPasswordUseCase(ResetPasswordUseCaseRef ref) {
  return ResetPasswordUseCase(ref.watch(authRepositoryProvider));
}
/// =====================
/// Network Info
/// =====================
@riverpod
NetworkInfo networkInfo(NetworkInfoRef ref) {
  return NetworkInfoImpl();
}

/// =====================
/// API Client
/// =====================
@riverpod
ApiClient apiClient(ApiClientRef ref) {
  final dio = Dio();
  final storage = ref.watch(secureStorageProvider);
  return ApiClient(dio, storage);
}

/// =====================
/// Token Manager
/// =====================
@riverpod
TokenManager tokenManager(TokenManagerRef ref) {
  final storage = ref.watch(secureStorageProvider);
  return TokenManager(storage);
}

/// =====================
/// Remote DataSource
/// =====================
@riverpod
AuthRemoteDataSource authRemoteDataSource(AuthRemoteDataSourceRef ref) {
  return AuthRemoteDataSource(
    ref.watch(apiClientProvider),
    ref.watch(tokenManagerProvider),
  );
}

/// =====================
/// Local DataSource
/// =====================
@riverpod
AuthLocalDataSource authLocalDataSource(AuthLocalDataSourceRef ref) {
  return AuthLocalDataSourceImpl(ref.watch(secureStorageProvider));
}

/// =====================
/// Repository
/// =====================
@riverpod
AuthRepositoryImpl authRepository(AuthRepositoryRef ref) {
  return AuthRepositoryImpl(
    remoteDataSource: ref.watch(authRemoteDataSourceProvider),
    localDataSource: ref.watch(authLocalDataSourceProvider),
    networkInfo: ref.watch(networkInfoProvider),
    tokenManager: ref.watch(tokenManagerProvider),
  );
}

/// =====================
/// UseCases
/// =====================
@riverpod
LoginUseCase loginUseCase(LoginUseCaseRef ref) {
  return LoginUseCase(ref.watch(authRepositoryProvider));
}

/// =====================
/// Auth State
/// =====================
@riverpod
class AuthState extends _$AuthState {
  @override
  AsyncValue<User?> build() {
    return const AsyncData(null);
  }

  /// =====================
  /// Login (FIXED)
  /// =====================
  Future<void> login(String phone, String password) async {
    state = const AsyncLoading();

    final useCase = ref.read(loginUseCaseProvider);
    final result = await useCase(LoginParams(phone: phone, password: password));

    state = await result.fold(
      (failure) async => AsyncError(failure, StackTrace.current),
      (_) async {
        final user = await ref
            .read(authLocalDataSourceProvider)
            .getCachedUser();

        if (user == null) {
          return AsyncError(
            CacheFailure('تعذر حفظ بيانات الدخول، حاول مرة أخرى'),
            StackTrace.current,
          );
        }
        return AsyncData(user);
      },
    );
  }

  /// =====================
  /// Restore Session (Splash)
  /// =====================
  Future<void> restoreSession() async {
    final repo = ref.read(authRepositoryProvider);
    final result = await repo.isAuthenticated();

    await result.fold((_) async => state = const AsyncData(null), (
      isAuth,
    ) async {
      if (!isAuth) {
        state = const AsyncData(null);
        return;
      }

      final userResult = await repo.getCurrentUser();
      state = userResult.fold(
        (failure) => AsyncError(failure, StackTrace.current),
        (user) => AsyncData(user),
      );
    });
  }

  /// =====================
  /// Logout
  /// =====================
  Future<void> logout() async {
    // logout في الـ Repository يمسح البيانات محلياً دائماً حتى لو فشل السيرفر
    await ref.read(authRepositoryProvider).logout();
    state = const AsyncData(null);
  }

  /// انتهت الجلسة ولم ينجح تجديد التوكن (يستدعيها ApiClient)
  Future<void> sessionExpired() async {
    await ref.read(authLocalDataSourceProvider).clearAuthData();
    state = const AsyncData(null);
  }
}
