import 'package:json_annotation/json_annotation.dart';

part 'active_request.g.dart';

@JsonSerializable()
class ActiveRequest {
  final int id;
  @JsonKey(name: 'student_name')
  final String studentName;
  @JsonKey(name: 'parent_name')
  final String parentName;
  final String status;
  @JsonKey(name: 'requested_at')
  final DateTime requestedAt;

  ActiveRequest({
    required this.id,
    required this.studentName,
    required this.parentName,
    required this.status,
    required this.requestedAt,
  });

  factory ActiveRequest.fromJson(Map<String, dynamic> json) => _$ActiveRequestFromJson(json);
  Map<String, dynamic> toJson() => _$ActiveRequestToJson(this);
}
