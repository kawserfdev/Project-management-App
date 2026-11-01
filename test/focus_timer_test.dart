import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:task_manager_app/core/routes/routes.dart';
import 'package:task_manager_app/features/focus/data/datasources/focus_local_data_source.dart';
import 'package:task_manager_app/features/focus/data/models/active_focus_timer_session.dart';
import 'package:task_manager_app/features/focus/data/models/focus_session_model.dart';
import 'package:task_manager_app/features/focus/data/models/focus_settings_model.dart';
import 'package:task_manager_app/features/focus/data/repos/focus_repository.dart';
import 'package:task_manager_app/features/focus/presentation/manager/focus_cubit.dart';
import 'package:task_manager_app/features/focus/presentation/manager/focus_state.dart';
import 'package:task_manager_app/features/task/data/models/task_model.dart';
import 'package:task_manager_app/task_manager_app.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('Focus Timer Architecture & Repository Tests', () {
    late FocusLocalDataSource dataSource;
    late FocusRepository repository;
    late FocusCubit cubit;

    setUp(() async {
      SharedPreferences.setMockInitialValues({});
      dataSource = FocusLocalDataSourceImpl();
      repository = FocusRepositoryImpl(localDataSource: dataSource);
      cubit = FocusCubit(focusRepository: repository);
      await cubit.init();
    });

    tearDown(() {
      cubit.close();
    });

    test('Initial state loads defaults (25m Focus, 0 Streak, 0 Sessions)', () {
      expect(cubit.state.currentMode, equals(PomodoroMode.focus));
      expect(cubit.state.remainingSeconds, equals(25 * 60));
      expect(cubit.state.formattedTime, equals('25:00'));
      expect(cubit.state.isRunning, isFalse);
      expect(cubit.state.streakDays, equals(0));
      expect(cubit.state.completedFocusSessionsToday, equals(0));
    });

    test('Switching modes updates remainingSeconds and formattedTime', () {
      cubit.switchMode(PomodoroMode.shortBreak);
      expect(cubit.state.currentMode, equals(PomodoroMode.shortBreak));
      expect(cubit.state.remainingSeconds, equals(5 * 60));
      expect(cubit.state.formattedTime, equals('05:00'));

      cubit.switchMode(PomodoroMode.longBreak);
      expect(cubit.state.currentMode, equals(PomodoroMode.longBreak));
      expect(cubit.state.remainingSeconds, equals(15 * 60));
      expect(cubit.state.formattedTime, equals('15:00'));

      cubit.switchMode(PomodoroMode.focus);
      expect(cubit.state.currentMode, equals(PomodoroMode.focus));
      expect(cubit.state.remainingSeconds, equals(25 * 60));
      expect(cubit.state.formattedTime, equals('25:00'));
    });

    test('Attaching and detaching a focused task updates state', () {
      final task = TaskModel(id: 't_focus_1', title: 'Write unit tests');
      cubit.setFocusedTask(task);
      expect(cubit.state.focusedTask?.id, equals('t_focus_1'));

      cubit.setFocusedTask(null);
      expect(cubit.state.focusedTask, isNull);
    });

    test('Updating focus settings persists and updates durations', () async {
      const customSettings = FocusSettingsModel(
        focusDurationMinutes: 45,
        shortBreakMinutes: 10,
        longBreakMinutes: 30,
        longBreakInterval: 3,
        autoStartBreaks: true,
      );

      await cubit.updateSettings(customSettings);
      expect(cubit.state.settings.focusDurationMinutes, equals(45));
      expect(cubit.state.remainingSeconds, equals(45 * 60));
      expect(cubit.state.formattedTime, equals('45:00'));

      cubit.switchMode(PomodoroMode.shortBreak);
      expect(cubit.state.remainingSeconds, equals(10 * 60));
      expect(cubit.state.formattedTime, equals('10:00'));
    });

    test('Recording focus session increases streak and history', () async {
      final session = FocusSessionModel(
        id: 's_1',
        mode: 'focus',
        durationMinutes: 25,
        completedAt: DateTime.now(),
      );

      await repository.recordSession(session);
      final sessions = await repository.getSessions();
      final streak = await repository.getStreak();

      expect(sessions.length, equals(1));
      expect(sessions.first.durationMinutes, equals(25));
      expect(streak, equals(1));
    });

    test('Starting timer persists active session and survives app reload/restart without resetting', () async {
      // 1. User starts the timer
      await cubit.toggleTimer();
      expect(cubit.state.isRunning, isTrue);

      // Verify active session was persisted to storage
      final savedActive = await repository.getActiveSession();
      expect(savedActive, isNotNull);
      expect(savedActive!.isRunning, isTrue);
      expect(savedActive.totalSeconds, equals(25 * 60));

      // 2. Simulate leaving the app / page change / app reload with a new Cubit instance
      final reloadedCubit = FocusCubit(focusRepository: repository);
      await reloadedCubit.init();

      // The reloaded timer MUST NOT reset to 25:00 or stop! It must still be running!
      expect(reloadedCubit.state.isRunning, isTrue);
      expect(reloadedCubit.state.remainingSeconds, lessThanOrEqualTo(25 * 60));
      expect(reloadedCubit.state.remainingSeconds, greaterThan(24 * 60));

      reloadedCubit.close();
    });

    test('Session completed while user was away auto-completes and updates stats on resume', () async {
      // Create an active session that expired 2 minutes ago
      final pastSession = ActiveFocusTimerSession(
        mode: 'focus',
        startTime: DateTime.now().subtract(const Duration(minutes: 27)),
        targetEndTime: DateTime.now().subtract(const Duration(minutes: 2)),
        totalSeconds: 25 * 60,
        isRunning: true,
        focusedTaskId: 't_away',
        focusedTaskTitle: 'Away Task',
      );
      await repository.saveActiveSession(pastSession);

      // User returns / opens app
      final awayCubit = FocusCubit(focusRepository: repository);
      await awayCubit.init();

      // Should have automatically recognized completion
      expect(awayCubit.state.isRunning, isFalse);
      expect(awayCubit.state.completedFocusSessionsToday, equals(1));
      expect(awayCubit.state.todayFocusMinutes, equals(25));
      expect(awayCubit.state.streakDays, equals(1));

      awayCubit.close();
    });
  });

  group('Focus View Widget Integration Tests', () {
    setUp(() {
      SharedPreferences.setMockInitialValues({});
    });

    testWidgets('FocusView renders timer countdown and controls', (WidgetTester tester) async {
      await tester.pumpWidget(const TaskManagerApp(initialRoute: Routes.homeView));
      await tester.pumpAndSettle();

      // Switch to Focus tab
      await tester.tap(find.text('Focus'));
      await tester.pumpAndSettle();

      // Verify Focus Mode title and digital timer
      expect(find.text('Focus Mode'), findsOneWidget);
      expect(find.text('25:00'), findsOneWidget);
      expect(find.text('Today\'s Focus'), findsOneWidget);

      // Verify Start/Play button and Reset button
      expect(find.byIcon(Icons.play_arrow), findsOneWidget);
      expect(find.byTooltip('Reset Timer'), findsOneWidget);
      expect(find.byTooltip('Timer Settings'), findsOneWidget);
      expect(find.byTooltip('Focus History'), findsOneWidget);
    });
  });
}
