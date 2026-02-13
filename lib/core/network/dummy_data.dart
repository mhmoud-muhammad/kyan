
class DummyData {
  // بيانات تسجيل دخول وهمية للتجربة
  static const Map<String, dynamic> dummyUser = {
    'id': 'kyan_001',
    'email': 'user@kyan.com',
    'name': 'Ahmed Hassan',
    'avatar': 'https://i.pravatar.cc/150?img=7',
    'phone': '+966500000000',
    'role': 'user',
    'createdAt': '2024-01-01T00:00:00.000Z',
  };
  
  static const Map<String, dynamic> dummyAdmin = {
    'id': 'kyan_admin_001',
    'email': 'admin@kyan.com',
    'name': 'Mohammed Ali',
    'avatar': 'https://i.pravatar.cc/150?img=8',
    'phone': '+966511111111',
    'role': 'admin',
    'createdAt': '2024-01-01T00:00:00.000Z',
  };
  
  static Map<String, dynamic> dummyLoginResponse = {
    'accessToken': 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.kyan_dummy_token_2024',
    'refreshToken': 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.kyan_dummy_refresh_2024',
    'user': dummyUser,
  };
  
  static Map<String, dynamic> dummyAdminLoginResponse = {
    'accessToken': 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.kyan_dummy_admin_token_2024',
    'refreshToken': 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.kyan_dummy_admin_refresh_2024',
    'user': dummyAdmin,
  };
  
  // قائمة المستخدمين الوهميين
  static List<Map<String, dynamic>> dummyUsers = [
    dummyUser,
    dummyAdmin,
    {
      'id': 'kyan_002',
      'email': 'sara@kyan.com',
      'name': 'Sara Ahmed',
      'avatar': 'https://i.pravatar.cc/150?img=1',
      'phone': '+966522222222',
      'role': 'user',
      'createdAt': '2024-01-15T00:00:00.000Z',
    },
    {
      'id': 'kyan_003',
      'email': 'omar@kyan.com',
      'name': 'Omar Khalid',
      'avatar': 'https://i.pravatar.cc/150?img=3',
      'phone': '+966533333333',
      'role': 'user',
      'createdAt': '2024-02-01T00:00:00.000Z',
    },
  ];
  
  // التحقق من بيانات الدخول الوهمية
  static Map<String, dynamic>? authenticate(String email, String password) {
    // كلمة المرور الافتراضية لجميع الحسابات الوهمية
    if (password == 'Kyan@2024') {
      if (email == 'user@kyan.com') {
        return dummyLoginResponse;
      } else if (email == 'admin@kyan.com') {
        return dummyAdminLoginResponse;
      }
    }
    return null;
  }
  
  // إنشاء حساب وهمي جديد
  static Map<String, dynamic> createDummyUser({
    required String email,
    required String name,
    String? phone,
  }) {
    final newUser = {
      'id': 'kyan_${DateTime.now().millisecondsSinceEpoch}',
      'email': email,
      'name': name,
      'avatar': 'https://i.pravatar.cc/150?img=${dummyUsers.length + 1}',
      'phone': phone ?? '+9665xxxxxxx',
      'role': 'user',
      'createdAt': DateTime.now().toIso8601String(),
    };
    
    dummyUsers.add(newUser);
    
    return {
      'accessToken': 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.kyan_dummy_token_${DateTime.now().millisecondsSinceEpoch}',
      'refreshToken': 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.kyan_dummy_refresh_${DateTime.now().millisecondsSinceEpoch}',
      'user': newUser,
    };
  }
}