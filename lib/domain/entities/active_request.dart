import 'package:json_annotation/json_annotation.dart';

part 'active_request.g.dart';

@JsonSerializable()
class ActiveRequest {
  @JsonKey(defaultValue: 0)
  final int id;

  // لن نستخدم name هنا لأننا سنقوم بتعيينه يدويًا في fromJson
  @JsonKey(defaultValue: 0)
  final int studentId;

  @JsonKey(name: 'student_name', defaultValue: '')
  final String studentName;

  @JsonKey(name: 'parent_name', defaultValue: '')
  final String parentName;

  @JsonKey(defaultValue: '')
  final String status;

  @JsonKey(name: 'requested_at')
  final DateTime requestedAt;

  ActiveRequest({
    required this.id,
    required this.studentId,
    required this.studentName,
    required this.parentName,
    required this.status,
    required this.requestedAt,
  });

  // دالة fromJson يدوية لمعالجة حالة عدم وجود student_id
  factory ActiveRequest.fromJson(Map<String, dynamic> json) {
    // نستخدم id كـ studentId إذا لم يوجد student_id
    final int actualStudentId = json['student_id'] ?? json['id'] ?? 0;
    //print('🔄 ActiveRequest.fromJson: id=${json['id']}, studentId=$actualStudentId, status=${json['status']}');

    return ActiveRequest(
      id: json['id'] ?? 0,
      studentId: actualStudentId,
      studentName: json['student_name'] ?? '',
      parentName: json['parent_name'] ?? '',
      status: json['status'] ?? '',
      requestedAt: json['requested_at'] != null
          ? DateTime.parse(json['requested_at'])
          : DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() => _$ActiveRequestToJson(this);

  /// 🔥 مهم للـ WebSocket
  factory ActiveRequest.fromWebSocket(Map<String, dynamic> json) {
    //print('📦 fromWebSocket called with: $json');

    return ActiveRequest(
      id: json['student_id'] ?? 0, // نستخدم student_id كـ id مؤقت
      studentId: json['student_id'] ?? json['id'] ?? 0,
      studentName: json['full_name'] ?? '',
      parentName: '',
      status: json['status'] ?? '',
      requestedAt: DateTime.now(),
    );
  }

  ActiveRequest copyWith({String? status}) {
    return ActiveRequest(
      id: id,
      studentId: studentId,
      studentName: studentName,
      parentName: parentName,
      status: status ?? this.status,
      requestedAt: requestedAt,
    );
  }
}