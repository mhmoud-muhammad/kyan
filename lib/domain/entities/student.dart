// lib/domain/entities/student.dart
import 'package:json_annotation/json_annotation.dart';

part 'student.g.dart';

enum AttendanceStatus {
  @JsonValue('PRESENT') 
  present,
  @JsonValue('ABSENT')
  absent,
  @JsonValue('LATE')
  late,
  @JsonValue('EXCUSED')
  excused,
  // الحالات الجديدة من API المعلم
  @JsonValue('REQUESTED')
  requested,
  @JsonValue('AT_GATE')
  atGate,
  @JsonValue('DELIVERED')
  delivered,
  @JsonValue('COMPLETED')
  completed,
  @JsonValue('unknown')
  unknown,
}


@JsonSerializable()
class Student {

  final int id;

  @JsonKey(name: 'full_name')
  final String name;

  final String? schoolName;
  final String? avatarUrl;

  @JsonKey(unknownEnumValue: AttendanceStatus.unknown)
  final AttendanceStatus status;

  Student({
    required this.id,
    required this.name,
    this.schoolName,
    this.avatarUrl,
    required this.status,
  });

  factory Student.fromJson(Map<String, dynamic> json)
      => _$StudentFromJson(json);

  Map<String, dynamic> toJson() => _$StudentToJson(this);
}

