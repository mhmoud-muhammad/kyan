import 'package:myapp/core/constants/api_constants.dart';
import 'package:myapp/core/errors/exceptions.dart';
import 'package:myapp/core/network/api_client.dart';
import 'package:myapp/domain/entities/school.dart';
import 'package:myapp/domain/entities/student.dart';
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart'; // لـ kDebugMode

abstract class GuardianRemoteDataSource {
  Future<List<School>> getMySchools();
  Future<List<Student>> getStudentsBySchool(int schoolId);
  Future<void> createPickupRequest(int studentId, {double? lat, double? lng});
}

class GuardianRemoteDataSourceImpl implements GuardianRemoteDataSource {
  final ApiClient apiClient;

  GuardianRemoteDataSourceImpl(this.apiClient);

  /// يتحقق أن الرد قائمة، وإلا يرمي ServerException
  List<dynamic> _asList(dynamic data) {
    if (data is List) return data;
    if (data is Map && data['results'] is List) return data['results'] as List;
    throw ServerException('استجابة غير متوقعة من الخادم');
  }

  @override
  Future<List<School>> getMySchools() async {
    try {
      final response = await apiClient.get(
        ApiConstants.parentSchoolsEndpoint,
        queryParameters: {},
      );

      // apiClient يرمي DioException لأي non-2xx، والـ Repository يحوّله لـ Failure
      return _asList(response.data).map((json) => School.fromJson(json)).toList();
    } on DioException {
      rethrow;
    } on ServerException {
      rethrow;
    } catch (e) {
      // خطأ في تحويل البيانات (JSON)
      throw ServerException('تعذر قراءة بيانات المدارس');
    }
  }

  @override
  Future<void> createPickupRequest(
    int studentId, {
    double? lat,
    double? lng,
  }) async {
    try {
      final body = {
        'student': studentId,
        if (lat != null && lng != null) ...{'lat': lat, 'lng': lng},
      };

      if (kDebugMode) {
        debugPrint(
          '📡 [PickupRequest] Endpoint: '
          '${ApiConstants.createPickupRequestEndpoint}',
        );
        debugPrint('📡 [PickupRequest] Body: $body');
      }

      final response = await apiClient.post(
        ApiConstants.createPickupRequestEndpoint,
        data: body,
      );

      if (kDebugMode) {
        debugPrint('✅ [PickupRequest] Status: ${response.statusCode}');
        debugPrint('✅ [PickupRequest] Response: ${response.data}');
      }
    } on DioException catch (e) {
      if (kDebugMode) {
        debugPrint('❌ [PickupRequest] Dio Error: ${e.response?.statusCode}');
        debugPrint('❌ [PickupRequest] Error Body: ${e.response?.data}');
      }
      // نمرر الخطأ كما هو حتى يتعرف الـ mapper على رسالة السيرفر
      // (مثل: خارج نطاق المدرسة) وعلى انقطاع الشبكة
      rethrow;
    }
  }

  @override
  Future<List<Student>> getStudentsBySchool(int schoolId) async {
    try {
      final response = await apiClient.get(
        ApiConstants.parentStudentsEndpoint,
        queryParameters: {'school_id': schoolId},
      );

      return _asList(response.data).map((json) => Student.fromJson(json)).toList();
    } on DioException {
      rethrow;
    } on ServerException {
      rethrow;
    } catch (e) {
      // خطأ في تحويل البيانات (JSON)
      throw ServerException('تعذر قراءة بيانات الطلاب');
    }
  }
}
