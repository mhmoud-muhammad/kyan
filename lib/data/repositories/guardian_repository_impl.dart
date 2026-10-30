import 'package:dartz/dartz.dart';
import 'package:myapp/core/errors/error_handler.dart';
import 'package:myapp/core/errors/failures.dart';
import 'package:myapp/core/network/network_info.dart';
import 'package:myapp/data/datasources/guardian_remote_datasource.dart';
import 'package:myapp/domain/entities/school.dart';
import 'package:myapp/domain/entities/student.dart';
import 'package:myapp/domain/repositories/guardian_repository.dart';

class GuardianRepositoryImpl implements GuardianRepository {
  final GuardianRemoteDataSource remoteDataSource;
  final NetworkInfo networkInfo;

  GuardianRepositoryImpl({
    required this.remoteDataSource,
    required this.networkInfo,
  });

  @override
  Future<Either<Failure, void>> createPickupRequest(
    int studentId, {
    double? lat,
    double? lng,
  }) {
    return safeCall(
      () => remoteDataSource.createPickupRequest(
        studentId,
        lat: lat,
        lng: lng,
      ),
      networkInfo: networkInfo,
      tag: 'createPickupRequest',
    );
  }

  @override
  Future<Either<Failure, List<School>>> getMySchools() {
    return safeCall(
      remoteDataSource.getMySchools,
      networkInfo: networkInfo,
      tag: 'getMySchools',
    );
  }

  @override
  Future<Either<Failure, List<Student>>> getStudentsBySchool(int schoolId) {
    return safeCall(
      () => remoteDataSource.getStudentsBySchool(schoolId),
      networkInfo: networkInfo,
      tag: 'getStudentsBySchool',
    );
  }
}
