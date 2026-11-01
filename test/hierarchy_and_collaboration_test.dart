import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:task_manager_app/core/services/collaboration_service.dart';
import 'package:task_manager_app/features/task/data/datasources/task_local_data_source.dart';
import 'package:task_manager_app/features/task/data/models/task_model.dart';
import 'package:task_manager_app/features/task/data/repos/task_repository.dart';
import 'package:task_manager_app/features/task/presentation/manager/task_cubit.dart';
import 'package:task_manager_app/features/task/presentation/manager/task_state.dart';
import 'package:task_manager_app/features/workspace/data/models/workspace_hierarchy_models.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('Hierarchy, Multiple Views & Collaboration Tests', () {
    late TaskCubit cubit;
    late TaskLocalDataSource dataSource;
    late TaskRepository repository;

    setUp(() async {
      SharedPreferences.setMockInitialValues({});
      dataSource = TaskLocalDataSourceImpl();
      repository = TaskRepositoryImpl(localDataSource: dataSource);
      cubit = TaskCubit(taskRepository: repository);
      await cubit.init();
    });

    tearDown(() {
      cubit.close();
    });

    test('Hierarchy navigation: Workspace -> Space -> List creation and filtering', () async {
      const newWorkspace = WorkspaceModel(id: 'ws_corp', name: 'Corporate Org');
      cubit.addWorkspace(newWorkspace);
      expect(cubit.state.workspaces.contains(newWorkspace), isTrue);
      expect(cubit.state.selectedWorkspace.id, equals('ws_corp'));

      const newSpace = SpaceModel(id: 'sp_design', workspaceId: 'ws_corp', name: 'Product Design');
      cubit.addSpace(newSpace);
      expect(cubit.state.spaces.contains(newSpace), isTrue);
      expect(cubit.state.selectedSpace?.id, equals('sp_design'));

      const newList = TaskListModel(id: 'lst_wireframes', spaceId: 'sp_design', name: 'Wireframes & UI');
      cubit.addList(newList);
      expect(cubit.state.lists.contains(newList), isTrue);
      expect(cubit.state.selectedList?.id, equals('lst_wireframes'));
    });

    test('Multiple Views toggle: List View to Board View (Kanban)', () {
      expect(cubit.state.viewMode, equals(TaskViewMode.list));

      cubit.toggleViewMode();
      expect(cubit.state.viewMode, equals(TaskViewMode.board));

      cubit.toggleViewMode();
      expect(cubit.state.viewMode, equals(TaskViewMode.list));
    });

    test('Kanban status updates & Drag-and-Drop state transition across all 5 project statuses', () async {
      final task = TaskModel(
        id: 't_kanban',
        title: 'Build drag and drop',
        status: 'pending',
        priority: 4, // Urgent
      );
      await cubit.addTask(task);
      expect(cubit.state.allTasks.first.status, equals('pending'));

      // Move to In Progress / Active
      await cubit.updateTaskStatus('t_kanban', 'in_progress');
      expect(cubit.state.allTasks.first.status, equals('in_progress'));
      expect(cubit.state.allTasks.first.isCompleted, isFalse);

      // Move to On Hold / Blocked
      await cubit.updateTaskStatus('t_kanban', 'on_hold');
      expect(cubit.state.allTasks.first.status, equals('on_hold'));
      expect(cubit.state.allTasks.first.isCompleted, isFalse);

      // Move to In Review
      await cubit.updateTaskStatus('t_kanban', 'in_review');
      expect(cubit.state.allTasks.first.status, equals('in_review'));
      expect(cubit.state.allTasks.first.isCompleted, isFalse);

      // Move to Completed
      await cubit.updateTaskStatus('t_kanban', 'completed');
      expect(cubit.state.allTasks.first.status, equals('completed'));
      expect(cubit.state.allTasks.first.isCompleted, isTrue);
    });

    test('Real-time collaboration: comments & event broadcast', () async {
      final task = TaskModel(
        id: 't_collab',
        title: 'API Security review',
        assignedTo: 'Alex Rivera',
      );
      await cubit.addTask(task);

      await cubit.addCommentToTask('t_collab', 'Reviewed auth tokens and rate limits.', author: 'Alex Rivera');
      await Future.delayed(Duration.zero);

      final updatedTask = cubit.state.allTasks.firstWhere((t) => t.id == 't_collab');
      expect(updatedTask.comments.length, equals(1));
      expect(updatedTask.comments.first.author, equals('Alex Rivera'));
      expect(updatedTask.comments.first.message, equals('Reviewed auth tokens and rate limits.'));

      // Check real-time collaboration event
      expect(cubit.state.latestEvent, isNotNull);
      expect(cubit.state.latestEvent?.type, equals(CollaborationEventType.commentAdded));
    });
  });
}
