// lib/presentation/providers/teacher/teacher_provider.dart
import 'package:dio/dio.dart';
import 'package:myapp/core/errors/exception_mapper.dart';
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
  Future<void> updateStudentStatus(int studentId, String newStatus);
}

final updateStudentStatusProvider =
    FutureProvider.family<Either<Failure, void>, UpdateStatusParams>((
      ref,
      params,
    ) async {
      final repo = ref.watch(teacherRepositoryProvider);

      return await repo.updateStudentStatus(params.studentId, params.newStatus);
    });

class UpdateStatusParams {
  final int studentId;
  final String newStatus;
  UpdateStatusParams({required this.studentId, required this.newStatus});
}

class TeacherRemoteDataSourceImpl implements TeacherRemoteDataSource {
  final ApiClient apiClient;

  TeacherRemoteDataSourceImpl(this.apiClient);
  @override
  Future<void> updateStudentStatus(int studentId, String newStatus) async {
    //print('📦 Data: $newStatus');
    try {
      // print(
      //   '📤 Sending PATCH to /teacher/student/$studentId/update-status/ with status=$newStatus',
      // );

      await apiClient.post(
        '/teacher/student/$studentId/update-status/', // تحقق من المسار الصحيح
        data: {'status': newStatus},
      );
    } on DioException catch (_) {
      // print('❌ DioException full: ${e.toString()}');
      // print('❌ Response status: ${e.response?.statusCode}');
      // print('❌ Response data: ${e.response?.data}');
        rethrow; // 🔥 هذا السطر هو الفارق
 // 🔥 مهم جدًا

      // ... باقي المعالجة
    } catch (e) {
      throw ServerException('فشل تحديث حالة الطالب: $e');
    }
  }
  // ==================== تحديث حالة الطالب ====================

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
     // print('📥 ActiveRequests raw response: ${response.data}'); // <-- أضف هذا

      // تأكد من بنية الاستجابة: قد تكون مصفوفة مباشرة أو كائن يحوي 'results'
      final List<dynamic> data;
      if (response.data is List) {
        data = response.data;
      } else if (response.data is Map && response.data['results'] != null) {
        data = response.data['results'] as List;
      } else {
        throw ServerException('بنية استجابة غير متوقعة');
      }
      // for (var item in data) {
      //   print('🔍 Item keys: ${item.keys}');
      //   print('🔍 Item: $item');
      // }
      return data.map((json) => ActiveRequest.fromJson(json)).toList();
    } catch (e) {
      throw ServerException('فشل تحميل الطلبات النشطة: $e');
    }
  }

  // داخل TeacherRemoteDataSourceImpl في ملف teacher_provider.dart

  @override
  Future<List<Student>> getStudentsByStatus(String statusType) async {
    try {
      // 1. تحويل الـ type إلى القيمة المناسبة لـ Query Parameter
      final String apiStatus = _mapStatusTypeToApi(statusType);

      // 2. إذا كان النوع 'total'، قد لا نحتاج لفلتر status
      final Map<String, dynamic> queryParams = statusType == 'total'
          ? <String, dynamic>{}
          : <String, dynamic>{'status': apiStatus};

      final response = await apiClient.get(
        ApiConstants
            .updateStudentStatusEndpoint, // تأكد من المسار الصحيح من ApiConstants
        queryParameters: queryParams,
      );

      final List<dynamic> data = response.data is List
          ? response.data
          : (response.data['results'] as List? ?? []);

      return data.map((json) => Student.fromJson(json)).toList();
    } catch (e) {
      throw ServerException('فشل تحميل قائمة الطلاب: $e');
    }
  }

  // دالة مساعدة للتحويل
  String _mapStatusTypeToApi(String type) {
    switch (type) {
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

  // دالة مساعدة لتحويل type إلى status
}

@riverpod
TeacherRemoteDataSource teacherRemoteDataSource(
  TeacherRemoteDataSourceRef ref,
) {
  return TeacherRemoteDataSourceImpl(ref.watch(apiClientProvider));
}

// ==================== Repository ====================
abstract class TeacherRepository {
  Future<Either<Failure, TeacherDashboardStats>> getDashboardStats();
  Future<Either<Failure, List<ActiveRequest>>> getActiveRequests();
  Future<Either<Failure, List<Student>>> getStudentsByStatus(String statusType);
  Future<Either<Failure, void>> updateStudentStatus(
    int studentId,
    String newStatus,
  );
}

class TeacherRepositoryImpl implements TeacherRepository {
  final TeacherRemoteDataSource remoteDataSource;
  final NetworkInfo networkInfo;

  TeacherRepositoryImpl({
    required this.remoteDataSource,
    required this.networkInfo,
  });
  @override
  Future<Either<Failure, void>> updateStudentStatus(
    int studentId,
    String newStatus,
  ) async {
    if (!await networkInfo.isConnected) return Left(NetworkFailure());
    try {
      await remoteDataSource.updateStudentStatus(studentId, newStatus);
      return const Right(null);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } catch (e) {
      return Left(mapExceptionToFailure(e as Exception));
    }
  }

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
  Future<Either<Failure, List<Student>>> getStudentsByStatus(
    String statusType,
  ) async {
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
  return ref
      .watch(teacherRepositoryProvider)
      .getDashboardStats()
      .then(
        (result) =>
            result.fold((failure) => throw failure.message, (stats) => stats),
      );
}

@riverpod
Future<List<ActiveRequest>> activeRequests(ActiveRequestsRef ref) {
  return ref
      .watch(teacherRepositoryProvider)
      .getActiveRequests()
      .then(
        (result) => result.fold(
          (failure) => throw failure.message,
          (requests) => requests,
        ),
      );
}

@riverpod
Future<List<Student>> studentsByStatus(
  StudentsByStatusRef ref,
  String statusType,
) {
  return ref
      .watch(teacherRepositoryProvider)
      .getStudentsByStatus(statusType)
      .then(
        (result) => result.fold((failure) {
          // print('❌ studentsByStatus error: $failure');
          throw failure.message;
        }, (students) => students),
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
      //print('Received initial sync with ${data['students']?.length} students');
    }
  });
  ref.onDispose(() => subscription.cancel());
}
