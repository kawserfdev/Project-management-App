import 'package:flutter_test/flutter_test.dart';
import 'package:task_manager_app/core/services/task_backup_service.dart';
import 'package:task_manager_app/features/task/data/models/task_model.dart';

void main() {
  group('TaskBackupService Tests', () {
    final sampleTasks = [
      TaskModel(
        id: '101',
        title: 'Review pull request',
        description: 'Check architecture and unit tests',
        category: 'Work',
        priority: 3,
        dueDate: DateTime(2026, 11, 1),
        dueTime: '10:00 AM',
        isCompleted: false,
        subtasks: [
          SubTask(id: 's1', title: 'Check linter', isCompleted: true),
          SubTask(id: 's2', title: 'Verify gradle build', isCompleted: false),
        ],
        comments: [
          TaskComment(id: 'c1', author: 'Team Lead', message: 'High priority for release'),
        ],
        assignedTo: 'engineer@company.com',
      ),
      TaskModel(
        id: '102',
        title: 'Buy groceries',
        description: 'Milk, eggs, coffee beans',
        category: 'Grocery',
        priority: 1,
        dueDate: DateTime(2026, 11, 2),
        dueTime: '06:00 PM',
        isCompleted: true,
      ),
    ];

    test('Export and Import JSON preserves task data fidelity', () {
      final jsonPayload = TaskBackupService.exportToJson(sampleTasks);
      expect(jsonPayload.contains('Review pull request'), isTrue);
      expect(jsonPayload.contains('Buy groceries'), isTrue);

      final imported = TaskBackupService.importFromJson(jsonPayload);
      expect(imported.length, equals(2));
      expect(imported[0].title, equals('Review pull request'));
      expect(imported[0].subtasks.length, equals(2));
      expect(imported[0].comments.length, equals(1));
      expect(imported[0].assignedTo, equals('engineer@company.com'));
      expect(imported[1].title, equals('Buy groceries'));
      expect(imported[1].isCompleted, isTrue);
    });

    test('Export and Import CSV preserves task data correctly', () {
      final csvPayload = TaskBackupService.exportToCsv(sampleTasks);
      expect(csvPayload.contains('Review pull request'), isTrue);
      expect(csvPayload.contains('Buy groceries'), isTrue);

      final imported = TaskBackupService.importFromCsv(csvPayload);
      expect(imported.length, equals(2));
      expect(imported[0].title, equals('Review pull request'));
      expect(imported[0].priority, equals(3));
      expect(imported[1].title, equals('Buy groceries'));
      expect(imported[1].isCompleted, isTrue);
    });
  });
}

