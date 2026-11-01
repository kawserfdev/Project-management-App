import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:task_manager_app/core/models/app_user_model.dart';
import 'package:task_manager_app/core/services/user_directory_service.dart';
import 'package:task_manager_app/features/task/data/datasources/task_local_data_source.dart';
import 'package:task_manager_app/features/task/data/models/task_model.dart';
import 'package:task_manager_app/features/task/data/repos/task_repository.dart';
import 'package:task_manager_app/features/task/presentation/manager/task_cubit.dart';
import 'package:task_manager_app/features/workspace/data/models/workspace_hierarchy_models.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('Cloud Sync, User Directory & Multi-Device Project Persistence Tests', () {
    late TaskLocalDataSource localDataSource;
    late TaskRepository repository;
    late UserDirectoryService userDirectoryService;

    setUp(() {
      SharedPreferences.setMockInitialValues({});
      localDataSource = TaskLocalDataSourceImpl();
      repository = TaskRepositoryImpl(localDataSource: localDataSource);
      userDirectoryService = UserDirectoryServiceImpl();
    });

    test('User Directory saves and retrieves registered database users', () async {
      const user1 = AppUserModel(
        uid: 'uid_rahman',
        displayName: 'Rahman Khan',
        email: 'rahman@company.com',
      );
      const user2 = AppUserModel(
        uid: 'uid_fatima',
        displayName: 'Fatima Begum',
        email: 'fatima@company.com',
      );

      await userDirectoryService.saveUser(user1);
      await userDirectoryService.saveUser(user2);

      final registeredUsers = await userDirectoryService.getRegisteredUsers();
      expect(registeredUsers.any((u) => u.uid == 'uid_rahman'), isTrue);
      expect(registeredUsers.any((u) => u.uid == 'uid_fatima'), isTrue);
    });

    test('User creates project & tasks: Persists across logout and re-login on another device', () async {
      const userAId = 'user_account_alpha';
      final cubitUserA = TaskCubit(taskRepository: repository);
      await cubitUserA.init(userId: userAId);

      // User A creates a custom workspace (Project) and task
      const customProject = WorkspaceModel(
        id: 'ws_alpha_marketing',
        name: 'Alpha Q4 Marketing Launch',
        description: 'New product launch campaign',
      );
      await cubitUserA.addWorkspace(customProject);

      final taskA = TaskModel(
        id: 'task_alpha_1',
        title: 'Design Hero Banner',
        workspaceId: customProject.id,
        assignedTo: 'Rahman Khan',
      );
      await cubitUserA.addTask(taskA);

      expect(cubitUserA.state.workspaces.any((w) => w.id == 'ws_alpha_marketing'), isTrue);
      expect(cubitUserA.state.allTasks.any((t) => t.id == 'task_alpha_1'), isTrue);
      expect(cubitUserA.state.allTasks.first.assignedTo, equals('Rahman Khan'));

      // Simulate User A logging out
      cubitUserA.resetUserSession();
      expect(cubitUserA.state.allTasks, isEmpty);

      // Simulate User B logging in on the same or another device
      const userBId = 'user_account_beta';
      final cubitUserB = TaskCubit(taskRepository: repository);
      await cubitUserB.init(userId: userBId);

      // User B should NOT see User A's private marketing project or tasks
      expect(cubitUserB.state.workspaces.any((w) => w.id == 'ws_alpha_marketing'), isFalse);
      expect(cubitUserB.state.allTasks.any((t) => t.id == 'task_alpha_1'), isFalse);

      // Now User A logs back in (on new device)
      final cubitUserARelogged = TaskCubit(taskRepository: repository);
      await cubitUserARelogged.init(userId: userAId);

      // User A's custom project and tasks are completely restored!
      expect(cubitUserARelogged.state.workspaces.any((w) => w.id == 'ws_alpha_marketing'), isTrue);
      expect(cubitUserARelogged.state.allTasks.any((t) => t.id == 'task_alpha_1'), isTrue);
      expect(cubitUserARelogged.state.allTasks.first.title, equals('Design Hero Banner'));
      expect(cubitUserARelogged.state.allTasks.first.assignedTo, equals('Rahman Khan'));

      cubitUserA.close();
      cubitUserB.close();
      cubitUserARelogged.close();
    });
  });
}

