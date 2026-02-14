// lib/presentation/providers/teacher_provider.dart
import 'package:myapp/domain/entities/student.dart';
import 'package:myapp/presentation/providers/auth_provider.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:myapp/core/network/api_client.dart';
import 'package:myapp/core/network/network_info.dart';
import 'package:myapp/domain/entities/teacher_dashboard_stats.dart';
import 'package:myapp/domain/entities/active_request.dart';
import 'package:myapp/core/errors/failures.dart';
import 'package:dartz/dartz.dart';
import 'package:myapp/core/constants/api_constants.dart';
import 'package:myapp/core/network/dummy_data.dart';

part 'teacher_provider.g.dart';

// 1. DataSource
abstract class TeacherRemoteDataSource {
  Future<TeacherDashboardStats> getDashboardStats();
  Future<List<ActiveRequest>> getActiveRequests();
  Future<List<Student>> getStudentsByStatus(String statusType);
}

class TeacherRemoteDataSourceImpl implements TeacherRemoteDataSource {
  final ApiClient apiClient;
  TeacherRemoteDataSourceImpl(this.apiClient);

  @override
  Future<TeacherDashboardStats> getDashboardStats() async {
    if (ApiConstants.useDummyData) {
      await Future.delayed(const Duration(milliseconds: 400));
      return TeacherDashboardStats.fromJson(DummyData.dummyTeacherDashboardStats);
    }
    
    final response = await apiClient.get('/api/v1/teacher/dashboard/');
    return TeacherDashboardStats.fromJson(response.data);
  }

  @override
  Future<List<Student>> getStudentsByStatus(String statusType) async {
    if (ApiConstants.useDummyData) {
      await Future.delayed(const Duration(milliseconds: 500));
      
      final status = _mapStatusType(statusType);
      final allStudents = DummyData.getAllStudents();
      
      if (statusType == 'total') {
        return allStudents;
      }
      
      return allStudents.where((s) => s.status.toString().split('.').last == status.toLowerCase()).toList();
    }
    
    final response = await apiClient.get('/api/v1/teacher/students/?status=$statusType');
    final List<dynamic> data = response.data;
    return data.map((json) => Student.fromJson(json)).toList();
  }

  // دالة مساعدة لتحويل type إلى status
  String _mapStatusType(String statusType) {
    switch (statusType) {
      case 'present':
        return 'PRESENT';
      case 'requested':
        return 'REQUESTED';
      case 'atGate':
        return 'AT_GATE';
      case 'delivered':
        return 'DELIVERED';
      default:
        return '';
    }
  }

  @override
  Future<List<ActiveRequest>> getActiveRequests() async {
    if (ApiConstants.useDummyData) {
      await Future.delayed(const Duration(milliseconds: 600));
      final List<dynamic> data = DummyData.dummyActiveRequests['results'];
      return data.map((json) => ActiveRequest.fromJson(json)).toList();
    }
    final response = await apiClient.get('/api/v1/teacher/requests/active/');
    final List<dynamic> data = response.data['results'];
    return data.map((json) => ActiveRequest.fromJson(json)).toList();
  }
}

@riverpod
TeacherRemoteDataSource teacherRemoteDataSource(TeacherRemoteDataSourceRef ref) {
  return TeacherRemoteDataSourceImpl(ref.watch(apiClientProvider));
}

// 2. Repository
abstract class TeacherRepository {
  Future<Either<Failure, TeacherDashboardStats>> getDashboardStats();
  Future<Either<Failure, List<ActiveRequest>>> getActiveRequests();
  Future<Either<Failure, List<Student>>> getStudentsByStatus(String statusType);
}

class TeacherRepositoryImpl implements TeacherRepository {
  final TeacherRemoteDataSource remoteDataSource;
  final NetworkInfo networkInfo;
  TeacherRepositoryImpl({required this.remoteDataSource, required this.networkInfo});

  @override
  Future<Either<Failure, TeacherDashboardStats>> getDashboardStats() async {
    if (!await networkInfo.isConnected) return Left(NetworkFailure());
    try {
      final result = await remoteDataSource.getDashboardStats();
      return Right(result);
    } catch (e) {
      return Left(ServerFailure('فشل جلب الإحصائيات.'));
    }
  }

  @override
  Future<Either<Failure, List<Student>>> getStudentsByStatus(String statusType) async {
    if (!await networkInfo.isConnected) return Left(NetworkFailure());
    try {
      final result = await remoteDataSource.getStudentsByStatus(statusType);
      return Right(result);
    } catch (e) {
      return Left(ServerFailure('فشل جلب الطلاب.'));
    }
  }

  @override
  Future<Either<Failure, List<ActiveRequest>>> getActiveRequests() async {
    if (!await networkInfo.isConnected) return Left(NetworkFailure());
    try {
      final result = await remoteDataSource.getActiveRequests();
      return Right(result);
    } catch (e) {
      return Left(ServerFailure('فشل جلب الطلبات النشطة.'));
    }
  }
}

@riverpod
TeacherRepository teacherRepository(TeacherRepositoryRef ref) {
  return TeacherRepositoryImpl(
    remoteDataSource: ref.watch(teacherRemoteDataSourceProvider),
    networkInfo: ref.watch(networkInfoProvider),
  );
}

// 3. Providers لجلب البيانات
@riverpod
Future<TeacherDashboardStats> dashboardStats(DashboardStatsRef ref) {
  return ref.watch(teacherRepositoryProvider).getDashboardStats().then(
    (result) => result.fold((l) => throw l.message, (r) => r),
  );
}

@riverpod
Future<List<ActiveRequest>> activeRequests(ActiveRequestsRef ref) {
  return ref.watch(teacherRepositoryProvider).getActiveRequests().then(
    (result) => result.fold((l) => throw l.message, (r) => r),
  );
}

// =================== 🟢🟢🟢 الإضافة الجديدة - Provider لجلب الطلاب حسب الحالة 🟢🟢🟢 ===================
@riverpod
Future<List<Student>> studentsByStatus(StudentsByStatusRef ref, String statusType) {
  return ref.watch(teacherRepositoryProvider).getStudentsByStatus(statusType).then(
    (result) => result.fold((l) => throw l.message, (r) => r),
  );
}