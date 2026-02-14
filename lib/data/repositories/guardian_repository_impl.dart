import 'package:dartz/dartz.dart';
import 'package:myapp/core/errors/exceptions.dart';
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
  Future<Either<Failure, void>> createPickupRequest(String studentId) async {
    if (!await networkInfo.isConnected) return Left(NetworkFailure());
    try {
      await remoteDataSource.createPickupRequest(studentId);
      return const Right(null); // نجاح
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } catch (e) {
      return Left(ServerFailure('حدث خطأ غير متوقع أثناء إرسال الطلب.'));
    }
  }

  @override
  Future<Either<Failure, List<School>>> getMySchools() async {
    if (!await networkInfo.isConnected) return Left(NetworkFailure());
    try {
      final schools = await remoteDataSource.getMySchools();
       print("✅ [DataSource] تم استلام الرد من السيرفر. البيانات الخام:");
  print(schools); 
      return Right(schools);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } catch (e, stackTrace) {
       // ✅✅✅ التعديل هنا: لطباعة أي خطأ آخر غير متوقع ✅✅✅
      print("🔥🔥🔥 خطأ غير متوقع في getMySchools Repository: $e");
      print("🔥🔥🔥 StackTrace: $stackTrace");
      return Left(ServerFailure('خطأ غير متوقع في جلب المدارس.'));
    }
  }

  @override
  Future<Either<Failure, List<Student>>> getStudentsBySchool(String schoolId) async {
    if (!await networkInfo.isConnected) return Left(NetworkFailure());
    try {
      final students = await remoteDataSource.getStudentsBySchool(schoolId);
      return Right(students);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } catch (e) {
      return Left(ServerFailure('حدث خطأ غير متوقع.'));
    }
  }
}
