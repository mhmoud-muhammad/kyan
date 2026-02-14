//lib/core/network/dummy_data.dart
import 'package:myapp/domain/entities/student.dart';

class DummyData {


  // 🆕 بيانات وهمية لإحصائيات المعلم (لـ /teacher/dashboard/)
  static final Map<String, dynamic> dummyTeacherDashboardStats = {
    "total": 10,
    "present": 10,
    "requested": 3,
    "at_gate": 10,
    "delivered": 10,
  };

  // 🆕 بيانات وهمية للطلبات النشطة (لـ /teacher/requests/active/)
  static final Map<String, dynamic> dummyActiveRequests = {
    "count": 3,
    "next": null,
    "previous": null,
    "results": [
      {
        "id": 101,
        "student_name": "سالم أحمد حسن",
        "parent_name": "أحمد حسن",
        "status": "REQUESTED",
        "requested_at": "2024-05-21T13:00:00Z",
      },
      {
        "id": 205,
        "student_name": "نورة خالد",
        "parent_name": "خالد عبد الله",
        "status": "REQUESTED",
        "requested_at": "2024-05-21T13:02:00Z",
      },
      {
        "id": 301,
        "student_name": "بدر إبراهيم",
        "parent_name": "إبراهيم محمد",
        "status": "AT_GATE",
        "requested_at": "2024-05-21T12:55:00Z",
      },
    ],
  };

  static const Map<String, dynamic> dummyParentUser = {
    'id': 'user_001',
    'name': 'أحمد حسن',
    'avatar': 'https://i.pravatar.cc/150?img=7',
    'phone': '0501234567',
    'national_id': '1234567890',
    'email': 'parent@example.com',
  };

  static const Map<String, dynamic> dummyTeacherUser = {
    'id': 'user_002',
    'name': 'الأستاذ محمد علي',
    'avatar': 'https://i.pravatar.cc/150?img=8',
    'phone': '0555555555',
    'national_id': '1098765432',
    'email': 'teacher@example.com',
  };

  // ===================================================================
  //                           ردود تسجيل الدخول
  // ===================================================================

  static Map<String, dynamic> dummyParentLoginResponse = {
    // ✅ تم التعديل: 'accessToken' -> 'access'
    'access':
        'DUMMY_ACCESS_TOKEN_FOR_PARENT_eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9',
    'refresh':
        'DUMMY_REFRESH_TOKEN_FOR_PARENT_eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9',
    // ✅ تم التعديل: فصل 'role' عن 'user'
    'user': dummyParentUser,
    'role': 'PARENT', // أو 'MANAGER' حسب الـ API
  };

  static Map<String, dynamic> dummyTeacherLoginResponse = {
    'access':
        'DUMMY_ACCESS_TOKEN_FOR_TEACHER_eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9',
    'refresh':
        'DUMMY_REFRESH_TOKEN_FOR_TEACHER_eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9',
    'user': dummyTeacherUser,
    'role': 'TEACHER',
  };

  // ===================================================================
  //                           بيانات المدارس والأبناء
  // ===================================================================

  // 🆕 بيانات وهمية للمدارس (لـ /parent/schools/ )
  static final List<Map<String, dynamic>> dummySchools = [
    {
      "id": 1,
      "name": "مدرسة الأمل الدولية",
      "public_code": "SCH-001",
      "location_method": "GPS",
      "is_active": true,
    },
    {
      "id": 2,
      "name": "أكاديمية النور الخاصة",
      "public_code": "SCH-002",
      "location_method": "BARCODE",
      "is_active": true,
    },
  ];

  // 🆕 بيانات وهمية للطلاب (لـ /parent/students/?school_id=X)
  static final Map<String, List<Map<String, dynamic>>> dummyStudentsBySchool = {
    // الطلاب في مدرسة رقم 1
    '1': [
      {
        'id': 101,
        // ✅ تم التعديل: 'name' -> 'full_name'
        'full_name': 'سالم أحمد حسن',
        // ✅ تم التعديل: Status بحروف كبيرة
        'status': 'PRESENT',
        'avatarUrl': 'https://i.pravatar.cc/150?img=12', // حقل إضافي للواجهة
      },
      {
        'id': 102,
        'full_name': 'فاطمة أحمد حسن',
        'status': 'ABSENT',
        'avatarUrl': 'https://i.pravatar.cc/150?img=5',
      },
    ],
    // الطلاب في مدرسة رقم 2
    '2': [
      {
        'id': 201,
        'full_name': 'علي أحمد حسن',
        'status': 'LATE',
        'avatarUrl': 'https://i.pravatar.cc/150?img=3',
      },
    ],
  };

  // ===================================================================
  //                           الدوال المساعدة
  // ===================================================================

  /// ✅ تم التحديث: دالة المصادقة الوهمية
  static Map<String, dynamic>? authenticate(String phone, String password) {
    // كلمة المرور الافتراضية لجميع الحسابات الوهمية هي '123456'
    if (password == '1') {
      // حساب ولي الأمر
      if (phone == '0123456789') {
        return dummyParentLoginResponse;
      }
      // حساب المعلم
      else if (phone == '0987654321') {
        return dummyTeacherLoginResponse;
      }
    }
    return null;
  }

  // يمكن ترك هذه الدالة كما هي أو تحديثها لتتوافق مع الهيكل الجديد إذا احتجت
  static Map<String, dynamic> createDummyUser({
    required String name,
    String? phone,
  }) {
    final newUser = {
      'id': 'kyan_${DateTime.now().millisecondsSinceEpoch}',
      'name': name,
      'avatar': 'https://i.pravatar.cc/150?img=10',
      'phone': phone ?? '+9665xxxxxxx',
    };

    return {
      'access': 'DUMMY_ACCESS_TOKEN_FOR_NEW_USER',
      'refresh': 'DUMMY_REFRESH_TOKEN_FOR_NEW_USER',
      'user': newUser,
      'role': 'PARENT',
    };
  }

  // دالة لجلب جميع الطلاب من جميع المدارس
static List<Student> getAllStudents() {
  final List<Student> allStudents = [];
  
  dummyStudentsBySchool.forEach((schoolId, studentsList) {
    allStudents.addAll(
      studentsList.map((json) => Student.fromJson(json)).toList()
    );
  });
  
  return allStudents;
}
}
