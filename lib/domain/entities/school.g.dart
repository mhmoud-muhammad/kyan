// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'school.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

School _$SchoolFromJson(Map<String, dynamic> json) => School(
  id: School._intFromDynamic(json['id']),
  name: json['name'] as String,
  publicCode: json['public_code'] as String?,
  isActive: json['is_active'] as bool,
);

Map<String, dynamic> _$SchoolToJson(School instance) => <String, dynamic>{
  'id': instance.id,
  'name': instance.name,
  'public_code': instance.publicCode,
  'is_active': instance.isActive,
};
