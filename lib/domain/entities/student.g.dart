// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'student.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Student _$StudentFromJson(Map<String, dynamic> json) => Student(
  id: Student._stringFromInt(json['id']),
  name: json['full_name'] as String,
  schoolName: json['schoolName'] as String?,
  avatarUrl: json['avatarUrl'] as String?,
  status: $enumDecode(
    _$AttendanceStatusEnumMap,
    json['status'],
    unknownValue: AttendanceStatus.unknown,
  ),
);

Map<String, dynamic> _$StudentToJson(Student instance) => <String, dynamic>{
  'id': instance.id,
  'full_name': instance.name,
  'schoolName': instance.schoolName,
  'avatarUrl': instance.avatarUrl,
  'status': _$AttendanceStatusEnumMap[instance.status]!,
};

const _$AttendanceStatusEnumMap = {
  AttendanceStatus.present: 'PRESENT',
  AttendanceStatus.absent: 'ABSENT',
  AttendanceStatus.late: 'LATE',
  AttendanceStatus.excused: 'EXCUSED',
  AttendanceStatus.requested: 'REQUESTED',
  AttendanceStatus.at_gate: 'AT_GATE',
  AttendanceStatus.delivered: 'DELIVERED',
  AttendanceStatus.completed: 'COMPLETED',
  AttendanceStatus.unknown: 'unknown',
};
