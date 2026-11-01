import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:task_manager_app/core/routes/routes.dart';
import 'package:task_manager_app/core/services/session_manager.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('SessionManager Session Persistence Tests', () {
    setUp(() {
      SharedPreferences.setMockInitialValues({});
    });

    test('Fresh install opens OnboardingView', () async {
      final route = await SessionManager.determineInitialRoute();
      expect(route, equals(Routes.onboarding));
    });

    test('User login saves session and opens HomeView on restart', () async {
      await SessionManager.saveUserSession(
        id: 'user_123',
        email: 'developer@test.com',
        displayName: 'Flutter Dev',
      );

      final loggedIn = await SessionManager.isLoggedIn();
      expect(loggedIn, isTrue);

      // Simulating App Restart
      final restartRoute = await SessionManager.determineInitialRoute();
      expect(restartRoute, equals(Routes.homeView));

      final session = await SessionManager.getUserSession();
      expect(session['email'], equals('developer@test.com'));
      expect(session['displayName'], equals('Flutter Dev'));
    });

    test('Guest session also persists across app restart', () async {
      await SessionManager.saveGuestSession();

      final loggedIn = await SessionManager.isLoggedIn();
      expect(loggedIn, isTrue);

      final restartRoute = await SessionManager.determineInitialRoute();
      expect(restartRoute, equals(Routes.homeView));
    });

    test('Session is ONLY cleared when explicit clearSession() is called', () async {
      await SessionManager.saveUserSession(
        id: 'user_456',
        email: 'team@taskmanager.app',
      );
      expect(await SessionManager.isLoggedIn(), isTrue);

      // Explicit Logout
      await SessionManager.clearSession();

      expect(await SessionManager.isLoggedIn(), isFalse);

      // Since onboarding was completed, next restart opens LoginView (not onboarding)
      final afterLogoutRoute = await SessionManager.determineInitialRoute();
      expect(afterLogoutRoute, equals(Routes.loginView));
    });
  });
}

