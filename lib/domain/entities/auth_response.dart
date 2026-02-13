import 'package:json_annotation/json_annotation.dart';
import 'package:myapp/domain/entities/user.dart';

part 'auth_response.g.dart';

@JsonSerializable()
class AuthResponse {
  final String accessToken;
  final String refreshToken;
  final User user; // أضف هذا الحقل


  AuthResponse({
    required this.accessToken,
    required this.refreshToken,
    required this.user, // وتأكد من التهيئة

  });

  factory AuthResponse.fromJson(Map<String, dynamic> json) =>
      _$AuthResponseFromJson(json);

  Map<String, dynamic> toJson() => _$AuthResponseToJson(this);
}
