// lib/domain/entities/school.dart
import 'package:json_annotation/json_annotation.dart';

part 'school.g.dart';

@JsonSerializable()
class School {
  @JsonKey(fromJson: _intFromDynamic)
  final int id;

  final String name;

  @JsonKey(name: 'public_code')
  final String? publicCode;

  @JsonKey(name: 'is_active')
  final bool isActive;

  School({
    required this.id,
    required this.name,
    this.publicCode,
    required this.isActive,
  });

static int _intFromDynamic(dynamic value) => value is int ? value : int.parse(value.toString());
  factory School.fromJson(Map<String, dynamic> json) => _$SchoolFromJson(json);

  Map<String, dynamic> toJson() => _$SchoolToJson(this);
}
