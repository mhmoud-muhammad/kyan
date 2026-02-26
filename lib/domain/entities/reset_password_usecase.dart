import 'package:dartz/dartz.dart';
import 'package:myapp/core/errors/failures.dart';
import 'package:myapp/domain/repositories/auth_repository.dart';

class ResetPasswordParams {
  final String phone;
  final String nationalId;
  final String newPassword;
  final String confirmPassword;

  ResetPasswordParams({
    required this.phone,
    required this.nationalId,
    required this.newPassword,
    required this.confirmPassword,
  });
}

class ResetPasswordUseCase {
  final AuthRepository repo;
  ResetPasswordUseCase(this.repo);

  Future<Either<Failure, String>> call(ResetPasswordParams params) {
    return repo.resetPassword(params);
  }
}