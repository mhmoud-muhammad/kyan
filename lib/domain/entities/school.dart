import 'package:json_annotation/json_annotation.dart';

part 'school.g.dart';

@JsonSerializable()
class School {
  @JsonKey(fromJson: _stringFromInt)
  final String id;
  
  final String name;
  
  // ✅✅✅ التعديل هنا: السماح بأن يكون الحقل null ✅✅✅
  @JsonKey(name: 'public_code')
  final String? publicCode; 
  
  @JsonKey(name: 'is_active')
  final bool isActive;

  School({
    required this.id,
    required this.name,
    this.publicCode, // تم جعله اختياريًا هنا أيضًا
    required this.isActive,
  });

  static String _stringFromInt(dynamic id) => id.toString();

  factory School.fromJson(Map<String, dynamic> json) => _$SchoolFromJson(json);

  Map<String, dynamic> toJson() => _$SchoolToJson(this);
}
