import 'package:firebase_auth/firebase_auth.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:task_manager_app/core/routes/routes.dart';

class SessionManager {
  static const String _keyIsLoggedIn = 'app_session_is_logged_in';
  static const String _keyUserId = 'app_session_user_id';
  static const String _keyUserEmail = 'app_session_user_email';
  static const String _keyUserDisplayName = 'app_session_user_display_name';
  static const String _keyOnboardingDone = 'app_session_onboarding_completed';

  /// Save logged in user session
  static Future<void> saveUserSession({
    required String? id,
    required String? email,
    String? displayName,
  }) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_keyIsLoggedIn, true);
    await prefs.setBool(_keyOnboardingDone, true);
    if (id != null) await prefs.setString(_keyUserId, id);
    if (email != null) await prefs.setString(_keyUserEmail, email);
    if (displayName != null) await prefs.setString(_keyUserDisplayName, displayName);
  }

  /// Save guest session
  static Future<void> saveGuestSession() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_keyIsLoggedIn, true);
    await prefs.setBool(_keyOnboardingDone, true);
    await prefs.setString(_keyUserId, 'guest_${DateTime.now().millisecondsSinceEpoch}');
    await prefs.setString(_keyUserEmail, 'guest@taskmanager.app');
    await prefs.setString(_keyUserDisplayName, 'Guest User');
  }

  /// Mark onboarding as completed
  static Future<void> setOnboardingCompleted([bool completed = true]) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_keyOnboardingDone, completed);
  }

  /// Check if user is currently logged in
  static Future<bool> isLoggedIn() async {
    try {
      // 1. Check Firebase Auth session
      final firebaseUser = FirebaseAuth.instance.currentUser;
      if (firebaseUser != null) {
        return true;
      }
    } catch (_) {}

    // 2. Check persistent SharedPreferences session
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_keyIsLoggedIn) ?? false;
  }

  /// Check if onboarding was already shown
  static Future<bool> isOnboardingCompleted() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_keyOnboardingDone) ?? false;
  }

  /// Get current cached user details
  static Future<Map<String, String?>> getUserSession() async {
    final prefs = await SharedPreferences.getInstance();
    return {
      'id': prefs.getString(_keyUserId),
      'email': prefs.getString(_keyUserEmail),
      'displayName': prefs.getString(_keyUserDisplayName),
    };
  }

  /// Clear user session on explicit LOGOUT ONLY
  static Future<void> clearSession() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_keyIsLoggedIn, false);
    await prefs.remove(_keyUserId);
    await prefs.remove(_keyUserEmail);
    await prefs.remove(_keyUserDisplayName);
    // Note: Do NOT clear onboarding completed so returning user goes directly to Login
  }

  /// Determines the route on app restart based on persistent session
  static Future<String> determineInitialRoute() async {
    final loggedIn = await isLoggedIn();
    if (loggedIn) {
      return Routes.homeView;
    }

    final onboardingDone = await isOnboardingCompleted();
    if (onboardingDone) {
      return Routes.loginView;
    }

    return Routes.onboarding;
  }
}

