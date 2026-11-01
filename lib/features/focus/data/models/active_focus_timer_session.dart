import 'dart:convert';

class ActiveFocusTimerSession {
  final String mode; // 'focus', 'shortBreak', 'longBreak'
  final DateTime startTime;
  final DateTime targetEndTime;
  final int totalSeconds;
  final int remainingSecondsWhenPaused;
  final bool isRunning;
  final String? focusedTaskId;
  final String? focusedTaskTitle;

  const ActiveFocusTimerSession({
    required this.mode,
    required this.startTime,
    required this.targetEndTime,
    required this.totalSeconds,
    this.remainingSecondsWhenPaused = 0,
    required this.isRunning,
    this.focusedTaskId,
    this.focusedTaskTitle,
  });

  ActiveFocusTimerSession copyWith({
    String? mode,
    DateTime? startTime,
    DateTime? targetEndTime,
    int? totalSeconds,
    int? remainingSecondsWhenPaused,
    bool? isRunning,
    String? focusedTaskId,
    String? focusedTaskTitle,
  }) {
    return ActiveFocusTimerSession(
      mode: mode ?? this.mode,
      startTime: startTime ?? this.startTime,
      targetEndTime: targetEndTime ?? this.targetEndTime,
      totalSeconds: totalSeconds ?? this.totalSeconds,
      remainingSecondsWhenPaused:
          remainingSecondsWhenPaused ?? this.remainingSecondsWhenPaused,
      isRunning: isRunning ?? this.isRunning,
      focusedTaskId: focusedTaskId ?? this.focusedTaskId,
      focusedTaskTitle: focusedTaskTitle ?? this.focusedTaskTitle,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'mode': mode,
      'startTime': startTime.toIso8601String(),
      'targetEndTime': targetEndTime.toIso8601String(),
      'totalSeconds': totalSeconds,
      'remainingSecondsWhenPaused': remainingSecondsWhenPaused,
      'isRunning': isRunning,
      'focusedTaskId': focusedTaskId,
      'focusedTaskTitle': focusedTaskTitle,
    };
  }

  factory ActiveFocusTimerSession.fromMap(Map<String, dynamic> map) {
    return ActiveFocusTimerSession(
      mode: (map['mode'] as String?) ?? 'focus',
      startTime: map['startTime'] != null
          ? DateTime.tryParse(map['startTime'] as String) ?? DateTime.now()
          : DateTime.now(),
      targetEndTime: map['targetEndTime'] != null
          ? DateTime.tryParse(map['targetEndTime'] as String) ?? DateTime.now()
          : DateTime.now(),
      totalSeconds: (map['totalSeconds'] as num?)?.toInt() ?? 25 * 60,
      remainingSecondsWhenPaused:
          (map['remainingSecondsWhenPaused'] as num?)?.toInt() ?? 0,
      isRunning: map['isRunning'] as bool? ?? false,
      focusedTaskId: map['focusedTaskId'] as String?,
      focusedTaskTitle: map['focusedTaskTitle'] as String?,
    );
  }

  String toJson() => json.encode(toMap());

  factory ActiveFocusTimerSession.fromJson(String source) =>
      ActiveFocusTimerSession.fromMap(json.decode(source) as Map<String, dynamic>);
}

