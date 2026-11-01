import 'dart:convert';

class FocusSettingsModel {
  final int focusDurationMinutes;
  final int shortBreakMinutes;
  final int longBreakMinutes;
  final int longBreakInterval;
  final bool autoStartBreaks;
  final bool autoStartFocus;
  final bool soundEnabled;
  final bool logCommentToTask;

  const FocusSettingsModel({
    this.focusDurationMinutes = 25,
    this.shortBreakMinutes = 5,
    this.longBreakMinutes = 15,
    this.longBreakInterval = 4,
    this.autoStartBreaks = false,
    this.autoStartFocus = false,
    this.soundEnabled = true,
    this.logCommentToTask = true,
  });

  FocusSettingsModel copyWith({
    int? focusDurationMinutes,
    int? shortBreakMinutes,
    int? longBreakMinutes,
    int? longBreakInterval,
    bool? autoStartBreaks,
    bool? autoStartFocus,
    bool? soundEnabled,
    bool? logCommentToTask,
  }) {
    return FocusSettingsModel(
      focusDurationMinutes: focusDurationMinutes ?? this.focusDurationMinutes,
      shortBreakMinutes: shortBreakMinutes ?? this.shortBreakMinutes,
      longBreakMinutes: longBreakMinutes ?? this.longBreakMinutes,
      longBreakInterval: longBreakInterval ?? this.longBreakInterval,
      autoStartBreaks: autoStartBreaks ?? this.autoStartBreaks,
      autoStartFocus: autoStartFocus ?? this.autoStartFocus,
      soundEnabled: soundEnabled ?? this.soundEnabled,
      logCommentToTask: logCommentToTask ?? this.logCommentToTask,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'focusDurationMinutes': focusDurationMinutes,
      'shortBreakMinutes': shortBreakMinutes,
      'longBreakMinutes': longBreakMinutes,
      'longBreakInterval': longBreakInterval,
      'autoStartBreaks': autoStartBreaks,
      'autoStartFocus': autoStartFocus,
      'soundEnabled': soundEnabled,
      'logCommentToTask': logCommentToTask,
    };
  }

  factory FocusSettingsModel.fromMap(Map<String, dynamic> map) {
    return FocusSettingsModel(
      focusDurationMinutes: (map['focusDurationMinutes'] as num?)?.toInt() ?? 25,
      shortBreakMinutes: (map['shortBreakMinutes'] as num?)?.toInt() ?? 5,
      longBreakMinutes: (map['longBreakMinutes'] as num?)?.toInt() ?? 15,
      longBreakInterval: (map['longBreakInterval'] as num?)?.toInt() ?? 4,
      autoStartBreaks: map['autoStartBreaks'] as bool? ?? false,
      autoStartFocus: map['autoStartFocus'] as bool? ?? false,
      soundEnabled: map['soundEnabled'] as bool? ?? true,
      logCommentToTask: map['logCommentToTask'] as bool? ?? true,
    );
  }

  String toJson() => json.encode(toMap());

  factory FocusSettingsModel.fromJson(String source) =>
      FocusSettingsModel.fromMap(json.decode(source) as Map<String, dynamic>);
}

