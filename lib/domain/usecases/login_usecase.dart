//lib/domain/usecases/login_usecase.dart
import 'package:dartz/dartz.dart';
import '../repositories/auth_repository.dart';
import '../entities/auth_response.dart';
import '../../core/errors/failures.dart';

class LoginUseCase {
  final AuthRepository repository;
  
  LoginUseCase(this.repository);
  
  Future<Either<Failure, AuthResponse>> call(LoginParams params) async {
    return await repository.login(
      email: params.email,
      password: params.password,
    );
  }
}

class LoginParams {
  final String email;
  final String password;
  
  LoginParams({
    required this.email,
    required this.password,
  });
}