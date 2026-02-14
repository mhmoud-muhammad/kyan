import 'package:myapp/core/constants/api_constants.dart';
import 'package:myapp/core/network/api_client.dart';
import 'package:myapp/core/network/dummy_data.dart';
import 'package:myapp/domain/entities/school.dart';
import 'package:myapp/domain/entities/student.dart';

abstract class GuardianRemoteDataSource {
  Future<List<School>> getMySchools();
  Future<List<Student>> getStudentsBySchool(String schoolId);
    Future<void> createPickupRequest(String studentId); 

}

class GuardianRemoteDataSourceImpl implements GuardianRemoteDataSource {
  final ApiClient apiClient;

  GuardianRemoteDataSourceImpl(this.apiClient);
// (داخل كلاس GuardianRemoteDataSourceImpl)

@override
Future<List<School>> getMySchools() async {
  // 💡 استخدام البيانات الوهمية إذا كان الخيار مفعلًا
  if (ApiConstants.useDummyData) {
    await Future.delayed(const Duration(milliseconds: 500));
    return DummyData.dummySchools.map((json) => School.fromJson(json)).toList();
  }

  final response = await apiClient.get(ApiConstants.parentSchoolsEndpoint);
  final List<dynamic> data = response.data;
  return data.map((json) => School.fromJson(json)).toList();
}

 @override
  Future<void> createPickupRequest(String studentId) async {
    // ملاحظة: حاليًا سنرسل فقط ID الطالب.
    // لاحقًا، يمكن إضافة الإحداثيات أو الباركود هنا إذا لزم الأمر.
    final body = {
      'student': int.parse(studentId), // الـ API يتوقع int حسب الوثائق
    };

    // لا نحتاج للتعامل مع الرد لأن الـ API يرجع 201 Created بدون جسم مهم
    await apiClient.post(ApiConstants.createPickupRequestEndpoint, data: body);
  }

@override
Future<List<Student>> getStudentsBySchool(String schoolId) async {
  // 💡 استخدام البيانات الوهمية إذا كان الخيار مفعلًا
  if (ApiConstants.useDummyData) {
    await Future.delayed(const Duration(milliseconds: 800));
    // إرجاع قائمة فارغة إذا لم يتم العثور على المدرسة في البيانات الوهمية
    final studentsData = DummyData.dummyStudentsBySchool[schoolId] ?? [];
    return studentsData.map((json) => Student.fromJson(json)).toList();
  }

  final response = await apiClient.get(
    ApiConstants.parentStudentsEndpoint,
    queryParameters: {'school_id': schoolId},
  );
  final List<dynamic> data = response.data;
  return data.map((json) => Student.fromJson(json)).toList();
}

}
