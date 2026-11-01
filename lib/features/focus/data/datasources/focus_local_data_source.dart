import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:task_manager_app/features/focus/data/models/active_focus_timer_session.dart';
import 'package:task_manager_app/features/focus/data/models/focus_session_model.dart';
import 'package:task_manager_app/features/focus/data/models/focus_settings_model.dart';

abstract class FocusLocalDataSource {
  Future<List<FocusSessionModel>> getSessions();
  Future<void> saveSession(FocusSessionModel session);
  Future<void> clearSessions();
  Future<FocusSettingsModel> getSettings();
  Future<void> saveSettings(FocusSettingsModel settings);
  Future<int> getStreakDays();
  Future<void> saveStreakDays(int days);
  Future<String?> getLastActiveDate();
  Future<void> saveLastActiveDate(String dateStr);
  Future<ActiveFocusTimerSession?> getActiveSession({String? userId});
  Future<void> saveActiveSession(ActiveFocusTimerSession session, {String? userId});
  Future<void> clearActiveSession({String? userId});
}

class FocusLocalDataSourceImpl implements FocusLocalDataSource {
  static const String _sessionsKey = 'focus_sessions_history';
  static const String _settingsKey = 'focus_settings_data';
  static const String _streakKey = 'focus_streak_days';
  static const String _lastActiveKey = 'focus_last_active_date';
  static const String _globalActiveKey = 'focus_active_timer_session_global';

  String _userActiveKey(String? userId) =>
      userId != null ? 'focus_active_timer_session_$userId' : _globalActiveKey;

  @override
  Future<List<FocusSessionModel>> getSessions() async {
    final prefs = await SharedPreferences.getInstance();
    final jsonString = prefs.getString(_sessionsKey);
    if (jsonString == null || jsonString.isEmpty) return [];

    try {
      final List<dynamic> decoded = json.decode(jsonString);
      return decoded.map((e) => FocusSessionModel.fromMap(e as Map<String, dynamic>)).toList();
    } catch (_) {
      return [];
    }
  }

  @override
  Future<void> saveSession(FocusSessionModel session) async {
    final prefs = await SharedPreferences.getInstance();
    final current = await getSessions();
    final updated = [session, ...current];
    final encoded = json.encode(updated.map((s) => s.toMap()).toList());
    await prefs.setString(_sessionsKey, encoded);
  }

  @override
  Future<void> clearSessions() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_sessionsKey);
  }

  @override
  Future<FocusSettingsModel> getSettings() async {
    final prefs = await SharedPreferences.getInstance();
    final jsonString = prefs.getString(_settingsKey);
    if (jsonString == null || jsonString.isEmpty) {
      return const FocusSettingsModel();
    }
    try {
      return FocusSettingsModel.fromJson(jsonString);
    } catch (_) {
      return const FocusSettingsModel();
    }
  }

  @override
  Future<void> saveSettings(FocusSettingsModel settings) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_settingsKey, settings.toJson());
  }

  @override
  Future<int> getStreakDays() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getInt(_streakKey) ?? 0;
  }

  @override
  Future<void> saveStreakDays(int days) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_streakKey, days);
  }

  @override
  Future<String?> getLastActiveDate() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_lastActiveKey);
  }

  @override
  Future<void> saveLastActiveDate(String dateStr) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_lastActiveKey, dateStr);
  }

  @override
  Future<ActiveFocusTimerSession?> getActiveSession({String? userId}) async {
    final prefs = await SharedPreferences.getInstance();
    String? jsonStr;
    if (userId != null) {
      jsonStr = prefs.getString(_userActiveKey(userId));
    }
    jsonStr ??= prefs.getString(_globalActiveKey);

    if (jsonStr == null || jsonStr.isEmpty) return null;
    try {
      return ActiveFocusTimerSession.fromJson(jsonStr);
    } catch (_) {
      return null;
    }
  }

  @override
  Future<void> saveActiveSession(ActiveFocusTimerSession session, {String? userId}) async {
    final prefs = await SharedPreferences.getInstance();
    final jsonStr = session.toJson();
    await prefs.setString(_globalActiveKey, jsonStr);
    if (userId != null) {
      await prefs.setString(_userActiveKey(userId), jsonStr);
    }
  }

  @override
  Future<void> clearActiveSession({String? userId}) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_globalActiveKey);
    if (userId != null) {
      await prefs.remove(_userActiveKey(userId));
    }
  }
}
