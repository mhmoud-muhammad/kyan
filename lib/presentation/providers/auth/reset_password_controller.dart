import 'package:myapp/domain/entities/reset_password_usecase.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:myapp/presentation/providers/auth/auth_provider.dart';

part 'reset_password_controller.g.dart';

@riverpod
class ResetPasswordController extends _$ResetPasswordController {
  @override
  AsyncValue<String?> build() => const AsyncData(null);

  Future<void> resetPassword(ResetPasswordParams params) async {
    state = const AsyncLoading();

    final useCase = ref.read(resetPasswordUseCaseProvider);
    final result = await useCase(params);

    state = result.fold(
      (failure) => AsyncError(failure.message, StackTrace.current),
      (message) => AsyncData(message),
    );
  }

  void clear() => state = const AsyncData(null);
}