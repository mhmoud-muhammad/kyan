// lib/domain/usecases/get_my_students_usecase.dart
import 'package:dartz/dartz.dart';
import 'package:myapp/core/errors/failures.dart';
import 'package:myapp/domain/entities/student.dart';
import 'package:myapp/domain/repositories/guardian_repository.dart';

class GetStudentsBySchoolUseCase {
  final GuardianRepository repository;

  GetStudentsBySchoolUseCase(this.repository);

  Future<Either<Failure, List<Student>>> call(int schoolId) {
    return repository.getStudentsBySchool(schoolId);
  }
}

