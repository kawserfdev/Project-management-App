import 'dart:convert';

class FocusSessionModel {
  final String id;
  final String? taskId;
  final String? taskTitle;
  final String mode; // 'focus', 'shortBreak', 'longBreak'
  final int durationMinutes;
  final DateTime completedAt;

  const FocusSessionModel({
    required this.id,
    this.taskId,
    this.taskTitle,
    required this.mode,
    required this.durationMinutes,
    required this.completedAt,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'taskId': taskId,
      'taskTitle': taskTitle,
      'mode': mode,
      'durationMinutes': durationMinutes,
      'completedAt': completedAt.toIso8601String(),
    };
  }

  factory FocusSessionModel.fromMap(Map<String, dynamic> map) {
    return FocusSessionModel(
      id: map['id'] as String,
      taskId: map['taskId'] as String?,
      taskTitle: map['taskTitle'] as String?,
      mode: (map['mode'] as String?) ?? 'focus',
      durationMinutes: (map['durationMinutes'] as num?)?.toInt() ?? 25,
      completedAt: map['completedAt'] != null
          ? DateTime.tryParse(map['completedAt'] as String) ?? DateTime.now()
          : DateTime.now(),
    );
  }

  String toJson() => json.encode(toMap());

  factory FocusSessionModel.fromJson(String source) =>
      FocusSessionModel.fromMap(json.decode(source) as Map<String, dynamic>);
}

