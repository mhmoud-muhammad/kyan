import 'package:myapp/core/constants/api_constants.dart';
import 'package:myapp/core/errors/exceptions.dart';
import 'package:myapp/core/network/api_client.dart';
import 'package:myapp/domain/entities/school.dart';
import 'package:myapp/domain/entities/student.dart';
import 'package:dio/dio.dart';

abstract class GuardianRemoteDataSource {
  Future<List<School>> getMySchools();
  Future<List<Student>> getStudentsBySchool(String schoolId);
  Future<void> createPickupRequest(
    String studentId, {
    double? lat,
    double? lng,
  });
}

class GuardianRemoteDataSourceImpl implements GuardianRemoteDataSource {
  final ApiClient apiClient;

  GuardianRemoteDataSourceImpl(this.apiClient);

void _handleDioError(DioError e) {
  if (e.response?.statusCode == 401) {
    throw UnauthorizedException(
      e.response?.data?['message'] ?? 'انتهت الجلسة، يرجى تسجيل الدخول مجدداً',
    );
  } else {
    throw ServerException(
      e.message ?? 'حدث خطأ في الخادم',
      code: e.response?.statusCode,
    );
  }
}

  @override
  Future<List<School>> getMySchools() async {
    try {
      final response = await apiClient.get(
        ApiConstants.parentSchoolsEndpoint,
        queryParameters: {},
      );

      if (response.statusCode != 200) {
        throw ServerException('فشل تحميل المدارس: ${response.statusCode}');
      }

      final List<dynamic> data = response.data;
      return data.map((json) => School.fromJson(json)).toList();
    } on DioException catch (e) {
      _handleDioError(e);
      throw ServerException(
        'فشل تحميل المدارس بسبب خطأ في الاتصال: ${e.toString()}',
      );
    } catch (e) {
      throw ServerException(e.toString());
    }
  }

  @override
  Future<void> createPickupRequest(
    String studentId, {
    double? lat,
    double? lng,
  }) async {
    final Map<String, dynamic> body = {'student': int.parse(studentId)};
    if (lat != null && lng != null) {
      body['lat'] = lat;
      body['lng'] = lng;
      // جرب أيضاً باستخدام latitude/longitude
      // body['latitude'] = lat;
      // body['longitude'] = lng;
    }
    print('📡 Sending pickup request with location: $body');
    final response = await apiClient.post(
      ApiConstants.createPickupRequestEndpoint,
      data: body,
    );
    print('📡 Response status: ${response.statusCode}');
    print('📡 Response data: ${response.data}');

    if (response.statusCode != 200 && response.statusCode != 201) {
      throw ServerException(
        'فشل إنشاء الطلب: ${response.statusCode} - ${response.data}',
      );
    }
  }

  @override
  Future<List<Student>> getStudentsBySchool(String schoolId) async {
    try {
      final response = await apiClient.get(
        ApiConstants.parentStudentsEndpoint,
        queryParameters: {'school_id': schoolId},
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = response.data;
        return data.map((json) => Student.fromJson(json)).toList();
      } else {
        print(
          '❌ getStudentsBySchool failed: status=${response.statusCode}, data=${response.data}',
        );
        throw ServerException('فشل تحميل الطلاب: ${response.statusCode}');
      }
    } catch (e) {
      print('❌ getStudentsBySchool exception: $e');
      throw ServerException(e.toString());
    }
  }
}
