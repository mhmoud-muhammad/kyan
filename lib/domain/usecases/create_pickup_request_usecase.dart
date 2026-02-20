import 'package:dartz/dartz.dart';
import 'package:myapp/core/errors/failures.dart';
import 'package:myapp/domain/repositories/guardian_repository.dart';
// lib/domain/usecases/create_pickup_request_usecase.dart

class CreatePickupRequestUseCase {
  final GuardianRepository repository;

  CreatePickupRequestUseCase(this.repository);

  Future<Either<Failure, void>> call(String studentId, {double? lat, double? lng}) {
    print('CreatePickupRequestUseCase: Sending pickup request for studentId: $studentId');
    return repository.createPickupRequest(studentId, lat: lat, lng: lng);
  }
}