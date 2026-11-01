import 'package:equatable/equatable.dart';
import 'package:task_manager_app/features/focus/data/models/focus_session_model.dart';
import 'package:task_manager_app/features/focus/data/models/focus_settings_model.dart';
import 'package:task_manager_app/features/task/data/models/task_model.dart';

enum PomodoroMode {
  focus('Focus', 'Work session'),
  shortBreak('Short Break', 'Rest session'),
  longBreak('Long Break', 'Deep recharge');

  final String label;
  final String description;
  const PomodoroMode(this.label, this.description);
}

class FocusState extends Equatable {
  final PomodoroMode currentMode;
  final int remainingSeconds;
  final int totalSeconds;
  final bool isRunning;
  final int completedFocusSessionsToday;
  final int todayFocusMinutes;
  final int streakDays;
  final TaskModel? focusedTask;
  final FocusSettingsModel settings;
  final List<FocusSessionModel> recentSessions;
  final FocusSessionModel? justFinishedSession;

  const FocusState({
    this.currentMode = PomodoroMode.focus,
    this.remainingSeconds = 25 * 60,
    this.totalSeconds = 25 * 60,
    this.isRunning = false,
    this.completedFocusSessionsToday = 0,
    this.todayFocusMinutes = 0,
    this.streakDays = 0,
    this.focusedTask,
    this.settings = const FocusSettingsModel(),
    this.recentSessions = const [],
    this.justFinishedSession,
  });

  String get formattedTime {
    final minutes = (remainingSeconds ~/ 60).toString().padLeft(2, '0');
    final seconds = (remainingSeconds % 60).toString().padLeft(2, '0');
    return '$minutes:$seconds';
  }

  double get progress {
    if (totalSeconds <= 0) return 0.0;
    return (remainingSeconds / totalSeconds).clamp(0.0, 1.0);
  }

  FocusState copyWith({
    PomodoroMode? currentMode,
    int? remainingSeconds,
    int? totalSeconds,
    bool? isRunning,
    int? completedFocusSessionsToday,
    int? todayFocusMinutes,
    int? streakDays,
    TaskModel? focusedTask,
    bool clearFocusedTask = false,
    FocusSettingsModel? settings,
    List<FocusSessionModel>? recentSessions,
    FocusSessionModel? justFinishedSession,
    bool clearFinishedSession = false,
  }) {
    return FocusState(
      currentMode: currentMode ?? this.currentMode,
      remainingSeconds: remainingSeconds ?? this.remainingSeconds,
      totalSeconds: totalSeconds ?? this.totalSeconds,
      isRunning: isRunning ?? this.isRunning,
      completedFocusSessionsToday:
          completedFocusSessionsToday ?? this.completedFocusSessionsToday,
      todayFocusMinutes: todayFocusMinutes ?? this.todayFocusMinutes,
      streakDays: streakDays ?? this.streakDays,
      focusedTask: clearFocusedTask ? null : (focusedTask ?? this.focusedTask),
      settings: settings ?? this.settings,
      recentSessions: recentSessions ?? this.recentSessions,
      justFinishedSession: clearFinishedSession
          ? null
          : (justFinishedSession ?? this.justFinishedSession),
    );
  }

  @override
  List<Object?> get props => [
        currentMode,
        remainingSeconds,
        totalSeconds,
        isRunning,
        completedFocusSessionsToday,
        todayFocusMinutes,
        streakDays,
        focusedTask,
        settings,
        recentSessions,
        justFinishedSession,
      ];
}

