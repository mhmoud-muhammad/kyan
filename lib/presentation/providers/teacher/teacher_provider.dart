// lib/presentation/providers/teacher/teacher_provider.dart
import 'package:myapp/core/errors/exceptions.dart';
import 'package:myapp/core/services/websocket_service.dart';
import 'package:myapp/domain/entities/student.dart';
import 'package:myapp/presentation/providers/auth/auth_provider.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:myapp/core/network/api_client.dart';
import 'package:myapp/core/network/network_info.dart';
import 'package:myapp/domain/entities/teacher_dashboard_stats.dart';
import 'package:myapp/domain/entities/active_request.dart';
import 'package:myapp/core/errors/failures.dart';
import 'package:dartz/dartz.dart';
import 'package:myapp/core/constants/api_constants.dart';

part 'teacher_provider.g.dart';

// ==================== Data Source ====================
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
    try {
      final response = await apiClient.get(
        ApiConstants.teacherDashboardEndpoint,
      );
      return TeacherDashboardStats.fromJson(response.data);
    } catch (e) {
      throw ServerException('فشل تحميل الإحصائيات: $e');
    }
  }

  @override
  Future<List<ActiveRequest>> getActiveRequests() async {
    try {
      final response = await apiClient.get(
        ApiConstants.teacherActiveRequestsEndpoint,
      );
      // تأكد من بنية الاستجابة: قد تكون مصفوفة مباشرة أو كائن يحوي 'results'
      final List<dynamic> data;
      if (response.data is List) {
        data = response.data;
      } else if (response.data is Map && response.data['results'] != null) {
        data = response.data['results'] as List;
      } else {
        throw ServerException('بنية استجابة غير متوقعة');
      }
      return data.map((json) => ActiveRequest.fromJson(json)).toList();
    } catch (e) {
      throw ServerException('فشل تحميل الطلبات النشطة: $e');
    }
  }

  @override
  Future<List<Student>> getStudentsByStatus(String statusType) async {
    // ⚠️ هذا الـ endpoint غير موثق بعد، نعيد قائمة فارغة مؤقتاً
    // TODO: استبدال هذا بتنفيذ حقيقي عند توفير الـ endpoint
    print('⚠️ getStudentsByStatus غير مدعوم بعد، يعيد قائمة فارغة');
    return [];
    
    // عند توفير الـ endpoint، يمكن استخدام الكود التالي:
    /*
    final status = _mapStatusType(statusType);
    if (status.isEmpty) return [];
    
    final response = await apiClient.get(
      '/teacher/students/',
      queryParameters: {'status': status},
    );
    final List<dynamic> data = response.data is List 
        ? response.data 
        : (response.data['results'] as List? ?? []);
    return data.map((json) => Student.fromJson(json)).toList();
    */
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
}

@riverpod
TeacherRemoteDataSource teacherRemoteDataSource(TeacherRemoteDataSourceRef ref) {
  return TeacherRemoteDataSourceImpl(ref.watch(apiClientProvider));
}

// ==================== Repository ====================
abstract class TeacherRepository {
  Future<Either<Failure, TeacherDashboardStats>> getDashboardStats();
  Future<Either<Failure, List<ActiveRequest>>> getActiveRequests();
  Future<Either<Failure, List<Student>>> getStudentsByStatus(String statusType);
}

class TeacherRepositoryImpl implements TeacherRepository {
  final TeacherRemoteDataSource remoteDataSource;
  final NetworkInfo networkInfo;

  TeacherRepositoryImpl({
    required this.remoteDataSource,
    required this.networkInfo,
  });

  @override
  Future<Either<Failure, TeacherDashboardStats>> getDashboardStats() async {
    if (!await networkInfo.isConnected) return Left(NetworkFailure());
    try {
      final result = await remoteDataSource.getDashboardStats();
      return Right(result);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } catch (e) {
      return Left(ServerFailure('حدث خطأ غير متوقع في الإحصائيات'));
    }
  }

  @override
  Future<Either<Failure, List<ActiveRequest>>> getActiveRequests() async {
    if (!await networkInfo.isConnected) return Left(NetworkFailure());
    try {
      final result = await remoteDataSource.getActiveRequests();
      return Right(result);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } catch (e) {
      return Left(ServerFailure('حدث خطأ غير متوقع في الطلبات النشطة'));
    }
  }

  @override
  Future<Either<Failure, List<Student>>> getStudentsByStatus(String statusType) async {
    if (!await networkInfo.isConnected) return Left(NetworkFailure());
    try {
      final result = await remoteDataSource.getStudentsByStatus(statusType);
      return Right(result);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } catch (e) {
      return Left(ServerFailure('حدث خطأ غير متوقع في جلب الطلاب'));
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

// ==================== Providers للبيانات ====================
@riverpod
Future<TeacherDashboardStats> dashboardStats(DashboardStatsRef ref) {
  return ref.watch(teacherRepositoryProvider).getDashboardStats().then(
    (result) => result.fold(
      (failure) => throw failure.message,
      (stats) => stats,
    ),
  );
}

@riverpod
Future<List<ActiveRequest>> activeRequests(ActiveRequestsRef ref) {
  return ref.watch(teacherRepositoryProvider).getActiveRequests().then(
    (result) => result.fold(
      (failure) => throw failure.message,
      (requests) => requests,
    ),
  );
}

@riverpod
Future<List<Student>> studentsByStatus(StudentsByStatusRef ref, String statusType) {
  return ref.watch(teacherRepositoryProvider).getStudentsByStatus(statusType).then(
    (result) => result.fold(
      (failure) {
        print('❌ studentsByStatus error: $failure');
        throw failure.message;
      },
      (students) => students,
    ),
  );
}

// ==================== WebSocket والإشعارات ====================

// قائمة الإشعارات المستلمة عبر WebSocket
@riverpod
class WebSocketNotifications extends _$WebSocketNotifications {
  @override
  List<Map<String, dynamic>> build() => [];

  void addNotification(Map<String, dynamic> notification) {
    state = [notification, ...state];
  }

  void clearAll() {
    state = [];
  }
}

// Provider للتحكم باتصال WebSocket وتوفير الخدمة
final websocketConnectionProvider = Provider((ref) {
  final service = ref.watch(websocketServiceProvider);
  ref.onDispose(() => service.dispose());
  return service;
});

// مستمع WebSocket (يبدأ التشغيل تلقائياً عند استخدامه)
@riverpod
void webSocketListener(WebSocketListenerRef ref) {
  final service = ref.watch(websocketConnectionProvider);
  final subscription = service.messages.listen((data) {
    if (data['action'] == 'NEW_NOTIFICATION') {
      ref.read(webSocketNotificationsProvider.notifier).addNotification(data);
    } else if (data['action'] == 'INITIAL_SYNC') {
      print('Received initial sync with ${data['students']?.length} students');
    }
  });
  ref.onDispose(() => subscription.cancel());
}