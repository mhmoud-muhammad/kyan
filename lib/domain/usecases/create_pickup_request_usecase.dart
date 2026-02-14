// lib/domain/usecases/create_pickup_request_usecase.dart
import 'package:dartz/dartz.dart';
import 'package:myapp/core/errors/failures.dart';
import 'package:myapp/domain/repositories/guardian_repository.dart';

class CreatePickupRequestUseCase {
  final GuardianRepository repository;

  CreatePickupRequestUseCase(this.repository);

  Future<Either<Failure, void>> call(String studentId) {
    return repository.createPickupRequest(studentId);
  }
}
