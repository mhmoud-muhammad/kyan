// lib/domain/usecases/get_my_schools_usecase.dart
import 'package:dartz/dartz.dart';
import 'package:myapp/core/errors/failures.dart';
import 'package:myapp/domain/entities/school.dart';
import 'package:myapp/domain/repositories/guardian_repository.dart';

class GetMySchoolsUseCase {
  final GuardianRepository repository;

  GetMySchoolsUseCase(this.repository);

  Future<Either<Failure, List<School>>> call() {
    return repository.getMySchools();
  }
}
