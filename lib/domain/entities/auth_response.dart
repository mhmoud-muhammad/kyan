//lib/domain/entities/auth_response.dart
import 'package:json_annotation/json_annotation.dart';
import 'package:myapp/domain/entities/user.dart';

part 'auth_response.g.dart';

@JsonSerializable()
class AuthResponse {
  @JsonKey(name: 'access')
  final String accessToken; 
  
  @JsonKey(name: 'refresh')
  final String refreshToken;
  final User user;

 AuthResponse({
    required this.accessToken,
    required this.refreshToken,
    required this.user,
  });
// (داخل كلاس AuthResponse)

  factory AuthResponse.fromJson(Map<String, dynamic> json) {
    // ✅ الحل: إنشاء نسخة جديدة قابلة للتعديل من الخريطة
    final userJson = Map<String, dynamic>.from(json['user'] as Map? ?? {});

    if (json.containsKey('role')) {
      // الآن نحن نعدل على النسخة الجديدة، وليس الأصلية المقفلة
      userJson['role'] = json['role'];
    }
    
    // إعادة بناء الـ JSON النهائي مع النسخة المعدلة من user
    final modifiedJson = {
      ...json,
      'user': userJson,
    };
    
    return _$AuthResponseFromJson(modifiedJson);
  }


  Map<String, dynamic> toJson() => _$AuthResponseToJson(this);

}
