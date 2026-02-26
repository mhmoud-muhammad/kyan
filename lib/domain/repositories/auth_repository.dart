//lib/domain/repositories/auth_repository.dart
import 'package:dartz/dartz.dart';
import 'package:myapp/domain/entities/reset_password_usecase.dart';
import '../entities/user.dart';
import '../entities/auth_response.dart';
import '../../core/errors/failures.dart';

abstract class AuthRepository {
  Future<Either<Failure, AuthResponse>> login({
    required String phone,
    required String password,
  });
  
  Future<Either<Failure, User>> getCurrentUser();
    Future<Either<Failure, String>> resetPassword(ResetPasswordParams params);

  
  Future<Either<Failure, void>> logout();
  
  Future<Either<Failure, bool>> isAuthenticated();
  
  Future<Either<Failure, String>> refreshToken();
}