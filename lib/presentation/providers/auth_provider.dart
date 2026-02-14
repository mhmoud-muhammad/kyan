//lib/presentation/providers/auth_provider.dart
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:myapp/data/datasources/auth_local_datasource.dart';
import 'package:myapp/data/datasources/auth_remote_datasource.dart';
import 'package:myapp/data/repositories/auth_repository_impl.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:dio/dio.dart';

import '../../core/network/api_client.dart';
import '../../core/network/network_info.dart';
import '../../core/network/token_manager.dart';

import '../../domain/entities/user.dart';
import '../../domain/usecases/login_usecase.dart';
import '../../domain/usecases/register_usecase.dart';

part 'auth_provider.g.dart';

/// =====================
/// Secure Storage
/// =====================
@riverpod
FlutterSecureStorage secureStorage(SecureStorageRef ref) {
  return const FlutterSecureStorage();
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
  final client = ref.watch(apiClientProvider);
  final tm = ref.watch(tokenManagerProvider);
  return AuthRemoteDataSource(client, tm);
}

/// =====================
/// Local DataSource
/// =====================
@riverpod
AuthLocalDataSource authLocalDataSource(AuthLocalDataSourceRef ref) {
  final storage = ref.watch(secureStorageProvider);
  return AuthLocalDataSourceImpl(storage);
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

@riverpod
RegisterUseCase registerUseCase(RegisterUseCaseRef ref) {
  return RegisterUseCase(ref.watch(authRepositoryProvider));
}

/// =====================
/// Auth State (Notifier)
/// =====================
@riverpod
class AuthState extends _$AuthState {
  @override
  AsyncValue<User?> build() {
    _init();
    return const AsyncLoading();
  }

  Future<void> _init() async {
    final repo = ref.read(authRepositoryProvider);
    final authResult = await repo.isAuthenticated();

    authResult.fold(
      (_) => state = const AsyncData(null),
      (isAuth) async {
        if (!isAuth) {
          state = const AsyncData(null);
          return;
        }

        final userResult = await repo.getCurrentUser();
        state = userResult.fold(
          (failure) => AsyncError(failure.message, StackTrace.current),
          (user) => AsyncData(user),
        );
      },
    );
  }

  /// =====================
  /// Login
  /// =====================
  Future<void> login(String phone, String password) async {
    state = const AsyncLoading();

    final useCase = ref.read(loginUseCaseProvider);
    final result = await useCase(
      LoginParams(phone: phone, password: password),
    );

    state = result.fold(
      (failure) => AsyncError(failure.message, StackTrace.current),
      (response) => AsyncData(response.user),
    );
  }

  /// =====================
  /// Register
  /// =====================
  Future<void> register({
    required String password,
    required String name,
    String? phone,
  }) async {
    state = const AsyncLoading();

    final useCase = ref.read(registerUseCaseProvider);
    final result = await useCase(
      RegisterParams(
        password: password,
        name: name,
        phone: phone,
      ),
    );

    state = result.fold(
      (failure) => AsyncError(failure.message, StackTrace.current),
      (response) => AsyncData(response.user),
    );
  }

  /// =====================
  /// Logout
  /// =====================
  Future<void> logout() async {
    final repo = ref.read(authRepositoryProvider);
    await repo.logout();
    state = const AsyncData(null);
  }

  Future<void> signOut() async {
     final repo = ref.read(authRepositoryProvider);
    await repo.logout();
    state = const AsyncData(null);
  }
}
