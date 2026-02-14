import 'package:dartz/dartz.dart';
import '../repositories/auth_repository.dart';
import '../entities/auth_response.dart';
import '../../core/errors/failures.dart';

class RegisterUseCase {
  final AuthRepository repository;
  
  RegisterUseCase(this.repository);
  
  Future<Either<Failure, AuthResponse>> call(RegisterParams params) async {
    return await repository.register(
      password: params.password,
      name: params.name,
      phone: params.phone,
    );
  }
}

class RegisterParams {
  final String password;
  final String name;
  final String? phone;
  
  RegisterParams({
    required this.password,
    required this.name,
    this.phone,
  });
}