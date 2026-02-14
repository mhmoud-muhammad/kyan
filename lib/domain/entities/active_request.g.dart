// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'active_request.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

ActiveRequest _$ActiveRequestFromJson(Map<String, dynamic> json) =>
    ActiveRequest(
      id: (json['id'] as num).toInt(),
      studentName: json['student_name'] as String,
      parentName: json['parent_name'] as String,
      status: json['status'] as String,
      requestedAt: DateTime.parse(json['requested_at'] as String),
    );

Map<String, dynamic> _$ActiveRequestToJson(ActiveRequest instance) =>
    <String, dynamic>{
      'id': instance.id,
      'student_name': instance.studentName,
      'parent_name': instance.parentName,
      'status': instance.status,
      'requested_at': instance.requestedAt.toIso8601String(),
    };
