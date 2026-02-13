import 'package:dartz/dartz.dart';
import '../entities/user.dart';
import '../entities/auth_response.dart';
import '../../core/errors/failures.dart';

abstract class AuthRepository {
  Future<Either<Failure, AuthResponse>> login({
    required String email,
    required String password,
  });
  
  Future<Either<Failure, AuthResponse>> register({
    required String email,
    required String password,
    required String name,
    String? phone,
  });
  
  Future<Either<Failure, User>> getCurrentUser();
  
  Future<Either<Failure, void>> logout();
  
  Future<Either<Failure, bool>> isAuthenticated();
  
  Future<Either<Failure, String>> refreshToken();
}