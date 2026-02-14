import 'package:json_annotation/json_annotation.dart';

part 'teacher_dashboard_stats.g.dart';

@JsonSerializable()
class TeacherDashboardStats {
  final int total;
  final int present;
  final int requested;
  @JsonKey(name: 'at_gate')
  final int atGate;
  final int delivered;

  TeacherDashboardStats({
    required this.total,
    required this.present,
    required this.requested,
    required this.atGate,
    required this.delivered,
  });

  factory TeacherDashboardStats.fromJson(Map<String, dynamic> json) => _$TeacherDashboardStatsFromJson(json);
  Map<String, dynamic> toJson() => _$TeacherDashboardStatsToJson(this);
}
