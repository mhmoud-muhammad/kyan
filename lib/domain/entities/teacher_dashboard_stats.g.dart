// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'teacher_dashboard_stats.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

TeacherDashboardStats _$TeacherDashboardStatsFromJson(
  Map<String, dynamic> json,
) => TeacherDashboardStats(
  total: (json['total'] as num).toInt(),
  present: (json['present'] as num).toInt(),
  requested: (json['requested'] as num).toInt(),
  atGate: (json['at_gate'] as num).toInt(),
  delivered: (json['delivered'] as num).toInt(),
);

Map<String, dynamic> _$TeacherDashboardStatsToJson(
  TeacherDashboardStats instance,
) => <String, dynamic>{
  'total': instance.total,
  'present': instance.present,
  'requested': instance.requested,
  'at_gate': instance.atGate,
  'delivered': instance.delivered,
};
