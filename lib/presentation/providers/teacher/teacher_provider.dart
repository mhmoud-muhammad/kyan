    // lib/presentation/providers/teacher/teacher_provider.dart
    import 'package:dio/dio.dart';
    import 'package:flutter/material.dart';
    import 'package:flutter_riverpod/flutter_riverpod.dart';
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
    String normalizeStatusKey(String statusType) {
      final raw = statusType.trim();

      // 1) قيم قادمة من UI / routes (غالباً lowerCamel)
      final lower = raw.toLowerCase();
      switch (lower) {
        case 'total':
        case 'all':
          return 'total';

        case 'present':
          return 'present';

        case 'requested':
          return 'requested';

        case 'atgate':
        case 'at_gate':
          return 'atGate';

        case 'delivered':
          return 'delivered';
      }

      // 2) قيم قادمة من السيرفر (غالباً UPPER_SNAKE)
      switch (raw.toUpperCase()) {
        case 'PRESENT':
          return 'present';
        case 'REQUESTED':
          return 'requested';
        case 'AT_GATE':
          return 'atGate';
        case 'DELIVERED':
          return 'delivered';
      }

      // fallback (لو أرسلت الشاشة نفس المفتاح أصلاً)
      return raw;
    }

    List<Student> studentsFromMapByType(
      Map<String, List<Student>> map,
      String statusType,
    ) {
      final key = normalizeStatusKey(statusType);

      if (key == 'total') {
        // دمج كل القوائم + إزالة التكرار (احتياطاً)
        final unique = <int, Student>{};
        for (final s in map.values.expand((l) => l)) {
          unique[s.id] = s;
        }
        return unique.values.toList();
      }

      return map[key] ?? const <Student>[];
    }
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
      final Ref ref;
      TeacherRemoteDataSourceImpl(this.apiClient, this.ref);
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

      // @override
      // Future<List<Student>> getStudentsByStatus(String statusType) async {
      //   try {
      //     // 1. تحويل الـ type إلى القيمة المناسبة لـ Query Parameter
      //     final String apiStatus = _mapStatusTypeToApi(statusType);

      //     // 2. إذا كان النوع 'total'، قد لا نحتاج لفلتر status
      //     final Map<String, dynamic> queryParams = statusType == 'total'
      //         ? <String, dynamic>{}
      //         : <String, dynamic>{'status': apiStatus};

      //     final response = await apiClient.get(
      //       ApiConstants
      //           .updateStudentStatusEndpoint, // تأكد من المسار الصحيح من ApiConstants
      //       queryParameters: queryParams,
      //     );

      //     final List<dynamic> data = response.data is List
      //         ? response.data
      //         : (response.data['results'] as List? ?? []);

      //     return data.map((json) => Student.fromJson(json)).toList();
      //   } catch (e) {
      //     throw ServerException('فشل تحميل قائمة الطلاب: $e');
      //   }
      // }
      @override
    Future<List<Student>> getStudentsByStatus(String statusType) async {
      try {
        final studentsMap = ref.read(webSocketStudentsProvider);
        return studentsFromMapByType(studentsMap, statusType);
      } catch (e) {
        throw ServerException('فشل تحميل قائمة الطلاب من WebSocket: $e');
      }
    }

    // 🔹 أضف هذا المتغير داخل TeacherRemoteDataSourceImpl لتخزين بيانات WebSocket
    Map<String, List<Student>>? _studentsMap;

    // 🔹 وأضف Setter لتحديثه من WebSocket
    void updateStudentsFromWebSocket(Map<String, List<Student>> map) {
      _studentsMap = map;
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
      return TeacherRemoteDataSourceImpl(ref.watch(apiClientProvider), ref);
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
      final action = data['action']?.toString();
      debugPrint('🟣 [WS Listener] action=$action');

      if (action == 'NEW_NOTIFICATION') {
        ref.read(webSocketNotificationsProvider.notifier).addNotification(data);
        return;
      }

      final studentsData = data['students'];
      if (studentsData is List) {
        ref.read(webSocketStudentsProvider.notifier).updateFromWebSocket(studentsData);

        final requests = studentsData
            .map((e) => ActiveRequest.fromWebSocket(e))
            .toList();

        ref.read(webSocketActiveRequestsProvider.notifier).updateRequests(requests);

        ref.invalidate(dashboardStatsProvider);
      }
    });

    ref.onDispose(subscription.cancel);
  }
    @riverpod
    class WebSocketActiveRequests extends _$WebSocketActiveRequests {
      @override
      List<ActiveRequest> build() => [];

      void updateRequests(List<ActiveRequest> requests) {
        state = requests;
      }
    }

    // مزخزن لقوائم الطلاب المستلمة عبر WebSocket
    // مزود لتخزين قوائم الطلاب المستلمة عبر WebSocket حسب الحالة
    @riverpod
    class WebSocketStudents extends _$WebSocketStudents {
      @override
      Map<String, List<Student>> build() => {};

      // داخل WebSocketStudents.updateFromWebSocket:
      void updateFromWebSocket(List<dynamic> studentsData) {
        debugPrint(
          '🟡 [WebSocketStudents] updateFromWebSocket called with ${studentsData.length} items',
        );

        final newMap = <String, List<Student>>{};

        for (var item in studentsData) {
          final statusStr = item['status']?.toString().toUpperCase() ?? '';
          final student = Student(
            id: item['id'] ?? 0,
            name: item['full_name'] ?? '',
            status: _parseStatus(statusStr),
            schoolName: null,
            avatarUrl: null,
          );

          // تصنيف حسب الحالة
          String key;
          switch (statusStr) {
            case 'PRESENT':
              key = 'present';
              break;
            case 'REQUESTED':
              key = 'requested';
              break;
            case 'AT_GATE':
              key = 'atGate';
              break;
            case 'DELIVERED':
              key = 'delivered';
              break;
            default:
              debugPrint('⚠️ [WebSocketStudents] Unknown status: $statusStr');
              continue;
          }

          newMap.putIfAbsent(key, () => []).add(student);
          debugPrint('   ✅ Added student ${student.name} with key "$key"');
        }

        state = newMap;
        debugPrint('🟢 [WebSocketStudents] state updated.');
      }

      AttendanceStatus _parseStatus(String status) {
        switch (status) {
          case 'PRESENT':
            return AttendanceStatus.present;
          case 'REQUESTED':
            return AttendanceStatus.requested;
          case 'AT_GATE':
            return AttendanceStatus.atGate;
          case 'DELIVERED':
            return AttendanceStatus.delivered;
          default:
            return AttendanceStatus.unknown;
        }
      }
    }
