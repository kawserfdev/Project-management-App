import 'dart:async';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:task_manager_app/features/focus/data/models/active_focus_timer_session.dart';
import 'package:task_manager_app/features/focus/data/models/focus_session_model.dart';
import 'package:task_manager_app/features/focus/data/models/focus_settings_model.dart';
import 'package:task_manager_app/features/focus/data/repos/focus_repository.dart';
import 'package:task_manager_app/features/focus/presentation/manager/focus_state.dart';
import 'package:task_manager_app/features/task/data/models/task_model.dart';

class FocusCubit extends Cubit<FocusState> {
  final FocusRepository focusRepository;
  Timer? _ticker;
  DateTime? _targetEndTime;
  String? _currentUserId;

  FocusCubit({required this.focusRepository}) : super(const FocusState());

  static PomodoroMode _modeFromString(String modeStr) {
    switch (modeStr) {
      case 'shortBreak':
        return PomodoroMode.shortBreak;
      case 'longBreak':
        return PomodoroMode.longBreak;
      case 'focus':
      default:
        return PomodoroMode.focus;
    }
  }

  Future<void> init({String? userId}) async {
    _currentUserId = userId ?? _currentUserId;
    final settings = await focusRepository.getSettings();
    final sessions = await focusRepository.getSessions();
    final streak = await focusRepository.getStreak();
    final todayStats = _calculateTodayStats(sessions);

    // 1. Check for persistent active running or paused session
    final activeSession =
        await focusRepository.getActiveSession(userId: _currentUserId);

    if (activeSession != null) {
      final activeMode = _modeFromString(activeSession.mode);
      TaskModel? targetTask;
      if (activeSession.focusedTaskId != null) {
        targetTask = TaskModel(
          id: activeSession.focusedTaskId!,
          title: activeSession.focusedTaskTitle ?? 'Focused Task',
        );
      }

      if (activeSession.isRunning) {
        final now = DateTime.now();
        final diff = activeSession.targetEndTime.difference(now).inSeconds;

        if (diff > 0) {
          // Timer is actively running
          _targetEndTime = activeSession.targetEndTime;
          emit(state.copyWith(
            settings: settings,
            recentSessions: sessions,
            streakDays: streak,
            completedFocusSessionsToday: todayStats.sessionCount,
            todayFocusMinutes: todayStats.totalMinutes,
            currentMode: activeMode,
            totalSeconds: activeSession.totalSeconds,
            remainingSeconds: diff,
            isRunning: true,
            focusedTask: targetTask,
          ));
          _startTicker();
          return;
        } else {
          // Timer finished while app was closed or backgrounded
          _targetEndTime = null;
          emit(state.copyWith(
            settings: settings,
            recentSessions: sessions,
            streakDays: streak,
            completedFocusSessionsToday: todayStats.sessionCount,
            todayFocusMinutes: todayStats.totalMinutes,
            currentMode: activeMode,
            totalSeconds: activeSession.totalSeconds,
            remainingSeconds: 0,
            isRunning: false,
            focusedTask: targetTask,
          ));
          await _onTimerCompleted();
          return;
        }
      } else {
        // Timer was paused by user
        _targetEndTime = null;
        emit(state.copyWith(
          settings: settings,
          recentSessions: sessions,
          streakDays: streak,
          completedFocusSessionsToday: todayStats.sessionCount,
          todayFocusMinutes: todayStats.totalMinutes,
          currentMode: activeMode,
          totalSeconds: activeSession.totalSeconds,
          remainingSeconds: activeSession.remainingSecondsWhenPaused,
          isRunning: false,
          focusedTask: targetTask,
        ));
        return;
      }
    }

    // Default clean initial state
    final focusSeconds = settings.focusDurationMinutes * 60;
    emit(state.copyWith(
      settings: settings,
      recentSessions: sessions,
      streakDays: streak,
      completedFocusSessionsToday: todayStats.sessionCount,
      todayFocusMinutes: todayStats.totalMinutes,
      totalSeconds: focusSeconds,
      remainingSeconds: focusSeconds,
      isRunning: false,
    ));
  }

  void switchMode(PomodoroMode mode) {
    _ticker?.cancel();
    _targetEndTime = null;
    focusRepository.clearActiveSession(userId: _currentUserId);

    final durationMinutes = switch (mode) {
      PomodoroMode.focus => state.settings.focusDurationMinutes,
      PomodoroMode.shortBreak => state.settings.shortBreakMinutes,
      PomodoroMode.longBreak => state.settings.longBreakMinutes,
    };
    final seconds = durationMinutes * 60;

    emit(state.copyWith(
      currentMode: mode,
      isRunning: false,
      totalSeconds: seconds,
      remainingSeconds: seconds,
    ));
  }

  Future<void> toggleTimer() async {
    if (state.isRunning) {
      await _pauseTimer();
    } else {
      await _startTimer();
    }
  }

  Future<void> _startTimer() async {
    if (state.remainingSeconds <= 0) {
      resetTimer();
    }

    final now = DateTime.now();
    _targetEndTime = now.add(Duration(seconds: state.remainingSeconds));

    final active = ActiveFocusTimerSession(
      mode: state.currentMode.name,
      startTime: now,
      targetEndTime: _targetEndTime!,
      totalSeconds: state.totalSeconds,
      remainingSecondsWhenPaused: state.remainingSeconds,
      isRunning: true,
      focusedTaskId: state.focusedTask?.id,
      focusedTaskTitle: state.focusedTask?.title,
    );
    await focusRepository.saveActiveSession(active, userId: _currentUserId);

    emit(state.copyWith(isRunning: true));
    _startTicker();
  }

  void _startTicker() {
    _ticker?.cancel();
    _ticker = Timer.periodic(const Duration(milliseconds: 500), (timer) {
      if (_targetEndTime == null) return;

      final diff = _targetEndTime!.difference(DateTime.now()).inSeconds;
      if (diff <= 0) {
        _onTimerCompleted();
      } else {
        emit(state.copyWith(remainingSeconds: diff));
      }
    });
  }

  Future<void> _pauseTimer() async {
    _ticker?.cancel();
    _targetEndTime = null;

    final active = ActiveFocusTimerSession(
      mode: state.currentMode.name,
      startTime: DateTime.now(),
      targetEndTime: DateTime.now().add(Duration(seconds: state.remainingSeconds)),
      totalSeconds: state.totalSeconds,
      remainingSecondsWhenPaused: state.remainingSeconds,
      isRunning: false,
      focusedTaskId: state.focusedTask?.id,
      focusedTaskTitle: state.focusedTask?.title,
    );
    await focusRepository.saveActiveSession(active, userId: _currentUserId);

    emit(state.copyWith(isRunning: false));
  }

  Future<void> resetTimer() async {
    _ticker?.cancel();
    _targetEndTime = null;
    await focusRepository.clearActiveSession(userId: _currentUserId);

    final durationMinutes = switch (state.currentMode) {
      PomodoroMode.focus => state.settings.focusDurationMinutes,
      PomodoroMode.shortBreak => state.settings.shortBreakMinutes,
      PomodoroMode.longBreak => state.settings.longBreakMinutes,
    };
    final seconds = durationMinutes * 60;

    emit(state.copyWith(
      isRunning: false,
      totalSeconds: seconds,
      remainingSeconds: seconds,
    ));
  }

  Future<void> _onTimerCompleted() async {
    _ticker?.cancel();
    _targetEndTime = null;
    await focusRepository.clearActiveSession(userId: _currentUserId);

    if (state.settings.soundEnabled) {
      try {
        HapticFeedback.heavyImpact();
      } catch (_) {}
    }

    if (state.currentMode == PomodoroMode.focus) {
      final session = FocusSessionModel(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        taskId: state.focusedTask?.id,
        taskTitle: state.focusedTask?.title,
        mode: 'focus',
        durationMinutes: state.settings.focusDurationMinutes,
        completedAt: DateTime.now(),
      );

      await focusRepository.recordSession(session);
      final updatedSessions = await focusRepository.getSessions();
      final streak = await focusRepository.getStreak();
      final todayStats = _calculateTodayStats(updatedSessions);

      emit(state.copyWith(
        isRunning: false,
        remainingSeconds: 0,
        recentSessions: updatedSessions,
        streakDays: streak,
        completedFocusSessionsToday: todayStats.sessionCount,
        todayFocusMinutes: todayStats.totalMinutes,
        justFinishedSession: session,
      ));

      if (state.settings.autoStartBreaks) {
        final isLongBreak =
            todayStats.sessionCount % state.settings.longBreakInterval == 0;
        switchMode(isLongBreak ? PomodoroMode.longBreak : PomodoroMode.shortBreak);
        await _startTimer();
      }
    } else {
      emit(state.copyWith(
        isRunning: false,
        remainingSeconds: 0,
      ));

      if (state.settings.autoStartFocus) {
        switchMode(PomodoroMode.focus);
        await _startTimer();
      }
    }
  }

  /// Sync timer when app returns from background, changes browser tab or route
  Future<void> syncWithWallClock() async {
    if (_targetEndTime != null && state.isRunning) {
      final now = DateTime.now();
      final diff = _targetEndTime!.difference(now).inSeconds;
      if (diff <= 0) {
        await _onTimerCompleted();
      } else {
        emit(state.copyWith(remainingSeconds: diff));
      }
      return;
    }

    // Check persistent active session
    final active =
        await focusRepository.getActiveSession(userId: _currentUserId);
    if (active != null && active.isRunning) {
      final now = DateTime.now();
      final diff = active.targetEndTime.difference(now).inSeconds;
      if (diff <= 0) {
        await _onTimerCompleted();
      } else {
        _targetEndTime = active.targetEndTime;
        emit(state.copyWith(
          isRunning: true,
          remainingSeconds: diff,
          totalSeconds: active.totalSeconds,
          currentMode: _modeFromString(active.mode),
        ));
        _startTicker();
      }
    }
  }

  void dismissFinishedDialog() {
    emit(state.copyWith(clearFinishedSession: true));
  }

  void setFocusedTask(TaskModel? task) {
    emit(state.copyWith(focusedTask: task, clearFocusedTask: task == null));
    // Also update active session if running
    if (state.isRunning && _targetEndTime != null) {
      final active = ActiveFocusTimerSession(
        mode: state.currentMode.name,
        startTime: DateTime.now(),
        targetEndTime: _targetEndTime!,
        totalSeconds: state.totalSeconds,
        remainingSecondsWhenPaused: state.remainingSeconds,
        isRunning: true,
        focusedTaskId: task?.id,
        focusedTaskTitle: task?.title,
      );
      focusRepository.saveActiveSession(active, userId: _currentUserId);
    }
  }

  Future<void> updateSettings(FocusSettingsModel newSettings) async {
    await focusRepository.updateSettings(newSettings);

    final durationMinutes = switch (state.currentMode) {
      PomodoroMode.focus => newSettings.focusDurationMinutes,
      PomodoroMode.shortBreak => newSettings.shortBreakMinutes,
      PomodoroMode.longBreak => newSettings.longBreakMinutes,
    };
    final seconds = durationMinutes * 60;

    emit(state.copyWith(
      settings: newSettings,
      totalSeconds: state.isRunning ? state.totalSeconds : seconds,
      remainingSeconds: state.isRunning ? state.remainingSeconds : seconds,
    ));
  }

  Future<void> clearSessionHistory() async {
    await focusRepository.clearHistory();
    emit(state.copyWith(
      recentSessions: [],
      completedFocusSessionsToday: 0,
      todayFocusMinutes: 0,
    ));
  }

  ({int sessionCount, int totalMinutes}) _calculateTodayStats(
      List<FocusSessionModel> sessions) {
    final todayStr = DateFormat('yyyy-MM-dd').format(DateTime.now());
    final todayFocusSessions = sessions.where((s) {
      final sessionDate = DateFormat('yyyy-MM-dd').format(s.completedAt);
      return s.mode == 'focus' && sessionDate == todayStr;
    }).toList();

    final totalMinutes = todayFocusSessions.fold<int>(
      0,
      (sum, s) => sum + s.durationMinutes,
    );
    return (
      sessionCount: todayFocusSessions.length,
      totalMinutes: totalMinutes,
    );
  }

  @override
  Future<void> close() {
    _ticker?.cancel();
    return super.close();
  }
}
