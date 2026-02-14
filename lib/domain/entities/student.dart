import 'package:json_annotation/json_annotation.dart';

part 'student.g.dart';

// ... (enum AttendanceStatus يبقى كما هو) ...
enum AttendanceStatus {
  @JsonValue('PRESENT') // API يستخدم حروف كبيرة
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
  at_gate,
  @JsonValue('DELIVERED')
  delivered,
  @JsonValue('COMPLETED')
  completed,
  @JsonValue('unknown')
  unknown,
}


@JsonSerializable()
class Student {
  // تحويل id إلى String لضمان التوافق
  @JsonKey(fromJson: _stringFromInt)
  final String id;

  @JsonKey(name: 'full_name')
  final String name;
  
  // الحقول التالية اختيارية لأنها لا تأتي من كل الـ Endpoints
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

  // دالة مساعدة لتحويل الـ id إذا كان int
  static String _stringFromInt(dynamic id) => id.toString();

  factory Student.fromJson(Map<String, dynamic> json) => _$StudentFromJson(json);

  Map<String, dynamic> toJson() => _$StudentToJson(this);
}
