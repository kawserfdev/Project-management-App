import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:task_manager_app/core/routes/routes.dart';
import 'package:task_manager_app/task_manager_app.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  testWidgets('TaskManagerApp loads HomeView successfully and switches tabs',
      (WidgetTester tester) async {
    await tester.pumpWidget(const TaskManagerApp(initialRoute: Routes.homeView));
    await tester.pumpAndSettle();

    // Verify Home View is loaded with navigation items
    expect(find.text('Index'), findsWidgets);
    expect(find.text('Calendar'), findsOneWidget);
    expect(find.text('Focus'), findsOneWidget);
    expect(find.text('Profile'), findsOneWidget);

    // Switch to Calendar tab
    await tester.tap(find.text('Calendar'));
    await tester.pumpAndSettle();
    expect(find.text('Today'), findsOneWidget);

    // Switch to Focus tab
    await tester.tap(find.text('Focus'));
    await tester.pumpAndSettle();
    expect(find.text('25:00'), findsOneWidget);

    // Switch to Profile tab
    await tester.tap(find.text('Profile'));
    await tester.pumpAndSettle();
    expect(find.text('App Settings'), findsOneWidget);
  });

  testWidgets('Can open Add Task bottom sheet and create a task',
      (WidgetTester tester) async {
    await tester.pumpWidget(const TaskManagerApp(initialRoute: Routes.homeView));
    await tester.pumpAndSettle();

    // Tap FAB
    await tester.tap(find.byType(FloatingActionButton));
    await tester.pumpAndSettle();

    // Verify Add Task bottom sheet opened
    expect(find.text('Add Task'), findsOneWidget);

    // Enter title
    await tester.enterText(find.byType(TextField).first, 'Test Flutter Task');
    await tester.pumpAndSettle();

    // Tap Save Task
    await tester.tap(find.byTooltip('Save Task'));
    await tester.pumpAndSettle();

    // Verify task is now visible on the Index page
    expect(find.text('Test Flutter Task'), findsOneWidget);
  });
}
