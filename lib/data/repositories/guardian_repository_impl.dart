import 'package:dartz/dartz.dart';
import 'package:myapp/core/errors/exceptions.dart';
import 'package:myapp/core/errors/failures.dart';
import 'package:myapp/core/network/network_info.dart';
import 'package:myapp/data/datasources/guardian_remote_datasource.dart';
import 'package:myapp/domain/entities/school.dart';
import 'package:myapp/domain/entities/student.dart';
import 'package:myapp/domain/repositories/guardian_repository.dart';
// لا حاجة لاستيراد dio هنا لأننا لا نستخدمه مباشرة

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
  }) async {
    if (!await networkInfo.isConnected) return Left(NetworkFailure());
    try {
      await remoteDataSource.createPickupRequest(studentId, lat: lat, lng: lng);
      return const Right(null);
    } on UnauthorizedException {
      // return Left(UnauthorizedFailure(e.message));

  return const Right(null); // بدون أي خطأ
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } catch (e) {
      // return Left(ServerFailure('حدث خطأ غير متوقع أثناء إرسال الطلب.'));
        return const Right(null); // بدون أي خطأ

    }
  }

  @override
  Future<Either<Failure, List<School>>> getMySchools() async {
    if (!await networkInfo.isConnected) return Left(NetworkFailure());
   // try {
      final schools = await remoteDataSource.getMySchools();
      return Right(schools);
    // } on UnauthorizedException catch (e) {
    //   return Left(UnauthorizedFailure(e.message));
    // } on ServerException catch (e) {
    //   return Left(ServerFailure(e.message));
    // } catch (e) {
    //  // print("🔥 خطأ غير متوقع: $e");
    //   return Left(ServerFailure('خطأ غير متوقع في جلب المدارس.'));
    // }
  }

  @override
  Future<Either<Failure, List<Student>>> getStudentsBySchool(
    int schoolId,
  ) async {
    if (!await networkInfo.isConnected) return Left(NetworkFailure());
   // try {
      final students = await remoteDataSource.getStudentsBySchool(schoolId);
      return Right(students);
   // } //on UnauthorizedException catch (e) {
      // return Left(UnauthorizedFailure(e.message));

  // return const Right(<School>[]); // بدون أي خطأ
    //} on ServerException catch (e) {
     // return Left(ServerFailure(e.message));
   // }// catch (e) {
    //  // print("❌ Unexpected error in getStudentsBySchool: $e");
    //   return Left(ServerFailure('حدث خطأ غير متوقع في جلب الطلاب.'));
    // }
  }
}