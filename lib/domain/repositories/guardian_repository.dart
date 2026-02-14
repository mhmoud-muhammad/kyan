//lib/domain/repositories/guardian_repository.dart
import 'package:dartz/dartz.dart';
import 'package:myapp/core/errors/failures.dart';
import 'package:myapp/domain/entities/school.dart';
import 'package:myapp/domain/entities/student.dart';

abstract class GuardianRepository {
  Future<Either<Failure, List<School>>> getMySchools();
  Future<Either<Failure, List<Student>>> getStudentsBySchool(String schoolId);
  Future<Either<Failure, void>> createPickupRequest(String studentId);

}
