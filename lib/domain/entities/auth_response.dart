// lib/domain/entities/auth_response.dart
import 'package:json_annotation/json_annotation.dart';
import 'package:myapp/domain/entities/user.dart';

part 'auth_response.g.dart';

@JsonSerializable()
class AuthResponse {
  @JsonKey(name: 'access')
  final String accessToken;

  @JsonKey(name: 'refresh')
  final String refreshToken;

  final String role;

  AuthResponse({
    required this.accessToken,
    required this.refreshToken,
    required this.role,
  });

  factory AuthResponse.fromJson(Map<String, dynamic> json) =>
      _$AuthResponseFromJson(json);
User get user => User(role: role, id: '', name: '', phone: '');
  Map<String, dynamic> toJson() => _$AuthResponseToJson(this);
}