import 'package:intl/intl.dart';
import 'package:task_manager_app/features/focus/data/datasources/focus_local_data_source.dart';
import 'package:task_manager_app/features/focus/data/models/active_focus_timer_session.dart';
import 'package:task_manager_app/features/focus/data/models/focus_session_model.dart';
import 'package:task_manager_app/features/focus/data/models/focus_settings_model.dart';

abstract class FocusRepository {
  Future<List<FocusSessionModel>> getSessions();
  Future<void> recordSession(FocusSessionModel session);
  Future<void> clearHistory();
  Future<FocusSettingsModel> getSettings();
  Future<void> updateSettings(FocusSettingsModel settings);
  Future<int> getStreak();
  Future<int> updateDailyStreak();
  Future<ActiveFocusTimerSession?> getActiveSession({String? userId});
  Future<void> saveActiveSession(ActiveFocusTimerSession session, {String? userId});
  Future<void> clearActiveSession({String? userId});
}

class FocusRepositoryImpl implements FocusRepository {
  final FocusLocalDataSource localDataSource;

  FocusRepositoryImpl({required this.localDataSource});

  @override
  Future<List<FocusSessionModel>> getSessions() => localDataSource.getSessions();

  @override
  Future<void> recordSession(FocusSessionModel session) async {
    await localDataSource.saveSession(session);
    await updateDailyStreak();
  }

  @override
  Future<void> clearHistory() => localDataSource.clearSessions();

  @override
  Future<FocusSettingsModel> getSettings() => localDataSource.getSettings();

  @override
  Future<void> updateSettings(FocusSettingsModel settings) =>
      localDataSource.saveSettings(settings);

  @override
  Future<int> getStreak() => localDataSource.getStreakDays();

  @override
  Future<int> updateDailyStreak() async {
    final now = DateTime.now();
    final todayStr = DateFormat('yyyy-MM-dd').format(now);
    final lastActiveStr = await localDataSource.getLastActiveDate();

    if (lastActiveStr == todayStr) {
      return await localDataSource.getStreakDays();
    }

    final currentStreak = await localDataSource.getStreakDays();
    final yesterdayStr = DateFormat('yyyy-MM-dd').format(now.subtract(const Duration(days: 1)));

    int newStreak = 1;
    if (lastActiveStr == yesterdayStr) {
      newStreak = currentStreak + 1;
    }

    await localDataSource.saveStreakDays(newStreak);
    await localDataSource.saveLastActiveDate(todayStr);
    return newStreak;
  }

  @override
  Future<ActiveFocusTimerSession?> getActiveSession({String? userId}) =>
      localDataSource.getActiveSession(userId: userId);

  @override
  Future<void> saveActiveSession(ActiveFocusTimerSession session, {String? userId}) =>
      localDataSource.saveActiveSession(session, userId: userId);

  @override
  Future<void> clearActiveSession({String? userId}) =>
      localDataSource.clearActiveSession(userId: userId);
}
