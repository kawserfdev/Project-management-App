import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:task_manager_app/features/focus/data/models/focus_session_model.dart';
import 'package:task_manager_app/features/focus/data/models/focus_settings_model.dart';

abstract class FocusRemoteDataSource {
  Future<List<FocusSessionModel>> getSessions(String userId);
  Future<void> saveSession(FocusSessionModel session, String userId);
  Future<void> saveSettings(FocusSettingsModel settings, int streak, String userId);
  Future<Map<String, dynamic>?> getSettings(String userId);
}

class FocusRemoteDataSourceImpl implements FocusRemoteDataSource {
  final FirebaseFirestore? _firestore;

  FocusRemoteDataSourceImpl({FirebaseFirestore? firestore})
      : _firestore = firestore;

  FirebaseFirestore? get _safeFirestore {
    try {
      return _firestore ?? FirebaseFirestore.instance;
    } catch (_) {
      return null;
    }
  }

  @override
  Future<List<FocusSessionModel>> getSessions(String userId) async {
    final fs = _safeFirestore;
    if (fs == null || userId.isEmpty) return [];

    try {
      final snap = await fs
          .collection('users')
          .doc(userId)
          .collection('focus_sessions')
          .orderBy('startTime', descending: true)
          .limit(100)
          .get();

      return snap.docs.map((d) => FocusSessionModel.fromMap(d.data())).toList();
    } catch (e) {
      debugPrint('⚠️ [FocusRemote] getSessions failed: $e');
      return [];
    }
  }

  @override
  Future<void> saveSession(FocusSessionModel session, String userId) async {
    final fs = _safeFirestore;
    if (fs == null || userId.isEmpty) return;

    try {
      await fs
          .collection('users')
          .doc(userId)
          .collection('focus_sessions')
          .doc(session.id)
          .set(session.toMap(), SetOptions(merge: true));
      debugPrint('✅ [FocusRemote] Saved focus session: ${session.id}');
    } catch (e) {
      debugPrint('⚠️ [FocusRemote] saveSession error: $e');
    }
  }

  @override
  Future<void> saveSettings(
      FocusSettingsModel settings, int streak, String userId) async {
    final fs = _safeFirestore;
    if (fs == null || userId.isEmpty) return;

    try {
      final map = settings.toMap();
      map['streakDays'] = streak;
      map['updatedAt'] = DateTime.now().toIso8601String();

      await fs
          .collection('users')
          .doc(userId)
          .collection('focus_settings')
          .doc('current')
          .set(map, SetOptions(merge: true));
    } catch (e) {
      debugPrint('⚠️ [FocusRemote] saveSettings error: $e');
    }
  }

  @override
  Future<Map<String, dynamic>?> getSettings(String userId) async {
    final fs = _safeFirestore;
    if (fs == null || userId.isEmpty) return null;

    try {
      final doc = await fs
          .collection('users')
          .doc(userId)
          .collection('focus_settings')
          .doc('current')
          .get();

      return doc.data();
    } catch (e) {
      debugPrint('⚠️ [FocusRemote] getSettings error: $e');
      return null;
    }
  }
}

