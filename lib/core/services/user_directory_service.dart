import 'dart:convert';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:task_manager_app/core/models/app_user_model.dart';

abstract class UserDirectoryService {
  Future<void> saveUser(AppUserModel user);
  Future<List<AppUserModel>> getRegisteredUsers();
}

class UserDirectoryServiceImpl implements UserDirectoryService {
  static const String _localUsersCacheKey = 'cached_directory_users_v1';

  final FirebaseFirestore? _firestore;

  UserDirectoryServiceImpl({FirebaseFirestore? firestore})
      : _firestore = firestore;

  FirebaseFirestore? get _safeFirestore {
    try {
      return _firestore ?? FirebaseFirestore.instance;
    } catch (_) {
      return null;
    }
  }

  @override
  Future<void> saveUser(AppUserModel user) async {
    // 1. Save to local SharedPreferences cache
    await _cacheUserLocally(user);

    // 2. Sync to Cloud Firestore if available
    try {
      final fs = _safeFirestore;
      if (fs != null && user.uid.isNotEmpty) {
        await fs.collection('users').doc(user.uid).set(
              user.toMap(),
              SetOptions(merge: true),
            );
      }
    } catch (_) {}
  }

  @override
  Future<List<AppUserModel>> getRegisteredUsers() async {
    final localUsers = await _getCachedUsersLocally();

    try {
      final fs = _safeFirestore;
      if (fs != null) {
        final snapshot = await fs
            .collection('users')
            .orderBy('lastActive', descending: true)
            .limit(50)
            .get();

        if (snapshot.docs.isNotEmpty) {
          final cloudUsers = snapshot.docs.map((doc) {
            return AppUserModel.fromMap(doc.data(), doc.id);
          }).toList();

          // Update local cache with latest from cloud
          final merged = _mergeUsers(localUsers, cloudUsers);
          await _saveAllUsersLocally(merged);
          return merged;
        }
      }
    } catch (_) {}

    return localUsers.isNotEmpty ? localUsers : _defaultFallbackUsers();
  }

  List<AppUserModel> _mergeUsers(
      List<AppUserModel> local, List<AppUserModel> cloud) {
    final map = <String, AppUserModel>{};
    for (final u in local) {
      if (u.uid.isNotEmpty) map[u.uid] = u;
    }
    for (final u in cloud) {
      if (u.uid.isNotEmpty) map[u.uid] = u;
    }
    return map.values.toList();
  }

  Future<List<AppUserModel>> _getCachedUsersLocally() async {
    final prefs = await SharedPreferences.getInstance();
    final jsonStr = prefs.getString(_localUsersCacheKey);
    if (jsonStr == null || jsonStr.isEmpty) return [];

    try {
      final List decoded = json.decode(jsonStr) as List;
      return decoded
          .map((item) => AppUserModel.fromMap(item as Map<String, dynamic>))
          .toList();
    } catch (_) {
      return [];
    }
  }

  Future<void> _cacheUserLocally(AppUserModel user) async {
    final current = await _getCachedUsersLocally();
    final updated = _mergeUsers(current, [user]);
    await _saveAllUsersLocally(updated);
  }

  Future<void> _saveAllUsersLocally(List<AppUserModel> users) async {
    final prefs = await SharedPreferences.getInstance();
    final list = users.map((u) => u.toMap()).toList();
    await prefs.setString(_localUsersCacheKey, json.encode(list));
  }

  List<AppUserModel> _defaultFallbackUsers() {
    return const [
      AppUserModel(
        uid: 'user_alex',
        displayName: 'Alex Rivera',
        email: 'alex.rivera@company.com',
      ),
      AppUserModel(
        uid: 'user_sarah',
        displayName: 'Sarah Jenkins',
        email: 'sarah.j@company.com',
      ),
      AppUserModel(
        uid: 'user_david',
        displayName: 'David Chen',
        email: 'david.chen@company.com',
      ),
    ];
  }
}

