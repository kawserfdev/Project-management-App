import 'package:firebase_auth/firebase_auth.dart';
import 'package:intl/intl.dart';
import 'package:task_manager_app/features/focus/data/datasources/focus_local_data_source.dart';
import 'package:task_manager_app/features/focus/data/datasources/focus_remote_data_source.dart';
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
  final FocusRemoteDataSource? remoteDataSource;

  FocusRepositoryImpl({
    required this.localDataSource,
    this.remoteDataSource,
  });

  String get _currentUid {
    try {
      return FirebaseAuth.instance.currentUser?.uid ?? '';
    } catch (_) {
      return '';
    }
  }

  @override
  Future<List<FocusSessionModel>> getSessions() async {
    final local = await localDataSource.getSessions();
    final uid = _currentUid;
    if (uid.isNotEmpty && remoteDataSource != null) {
      try {
        final remote = await remoteDataSource!.getSessions(uid);
        if (remote.isNotEmpty) {
          final ids = local.map((s) => s.id).toSet();
          final merged = [...local, ...remote.where((s) => !ids.contains(s.id))];
          return merged;
        }
      } catch (_) {}
    }
    return local;
  }

  @override
  Future<void> recordSession(FocusSessionModel session) async {
    await localDataSource.saveSession(session);
    final streak = await updateDailyStreak();
    final uid = _currentUid;
    if (uid.isNotEmpty && remoteDataSource != null) {
      try {
        await remoteDataSource!.saveSession(session, uid);
        final settings = await getSettings();
        await remoteDataSource!.saveSettings(settings, streak, uid);
      } catch (_) {}
    }
  }

  @override
  Future<void> clearHistory() => localDataSource.clearSessions();

  @override
  Future<FocusSettingsModel> getSettings() async {
    final local = await localDataSource.getSettings();
    final uid = _currentUid;
    if (uid.isNotEmpty && remoteDataSource != null) {
      try {
        final remoteData = await remoteDataSource!.getSettings(uid);
        if (remoteData != null) {
          return FocusSettingsModel.fromMap(remoteData);
        }
      } catch (_) {}
    }
    return local;
  }

  @override
  Future<void> updateSettings(FocusSettingsModel settings) async {
    await localDataSource.saveSettings(settings);
    final uid = _currentUid;
    if (uid.isNotEmpty && remoteDataSource != null) {
      try {
        final streak = await getStreak();
        await remoteDataSource!.saveSettings(settings, streak, uid);
      } catch (_) {}
    }
  }

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
