import 'package:task_manager_app/features/task/data/datasources/task_local_data_source.dart';
import 'package:task_manager_app/features/task/data/datasources/task_remote_data_source.dart';
import 'package:task_manager_app/features/task/data/models/category_model.dart';
import 'package:task_manager_app/features/task/data/models/task_model.dart';
import 'package:task_manager_app/features/workspace/data/models/workspace_hierarchy_models.dart';

abstract class TaskRepository {
  Future<List<TaskModel>> getTasks({String? userId});
  Future<void> addTask(TaskModel task, {String? userId});
  Future<void> updateTask(TaskModel task, {String? userId});
  Future<void> deleteTask(String id, {String? userId});

  Future<List<WorkspaceModel>> getWorkspaces({String? userId});
  Future<void> addWorkspace(WorkspaceModel workspace, {String? userId});

  Future<List<SpaceModel>> getSpaces({String? userId});
  Future<void> addSpace(SpaceModel space, {String? userId});

  Future<List<TaskListModel>> getLists({String? userId});
  Future<void> addList(TaskListModel list, {String? userId});

  Future<List<CategoryModel>> getCategories({String? userId});
  Future<void> addCategory(CategoryModel category, {String? userId});
}

class TaskRepositoryImpl implements TaskRepository {
  final TaskLocalDataSource localDataSource;
  final TaskRemoteDataSource? remoteDataSource;

  TaskRepositoryImpl({
    required this.localDataSource,
    this.remoteDataSource,
  });

  // --- TASKS ---
  @override
  Future<List<TaskModel>> getTasks({String? userId}) async {
    final localTasks = await localDataSource.getTasks(userId: userId);

    if (userId != null && userId.isNotEmpty && remoteDataSource != null) {
      try {
        final remoteTasks = await remoteDataSource!.getTasks(userId);

        // Dynamically fetch all tasks from all teams the user belongs to
        final teamIds = await remoteDataSource!.getUserTeamIds(userId);
        final allTeamTasks = <TaskModel>[];
        for (final tId in teamIds) {
          final tTasks = await remoteDataSource!.getTeamTasks(tId);
          allTeamTasks.addAll(tTasks);
        }

        final combinedRemote = [...remoteTasks, ...allTeamTasks];
        if (combinedRemote.isNotEmpty) {
          final merged = _mergeTasks(localTasks, combinedRemote);
          await localDataSource.saveTasks(merged, userId: userId);
          return merged;
        } else if (localTasks.isNotEmpty) {
          // Sync local tasks up to cloud
          for (final t in localTasks) {
            remoteDataSource!.saveTask(t, userId).catchError((_) {});
          }
        }
      } catch (_) {}
    }

    return localTasks;
  }

  List<TaskModel> _mergeTasks(List<TaskModel> local, List<TaskModel> remote) {
    final map = <String, TaskModel>{};
    for (final t in local) {
      map[t.id] = t;
    }
    for (final t in remote) {
      map[t.id] = t;
    }
    final merged = map.values.toList();
    merged.sort((a, b) => b.createdAt.compareTo(a.createdAt));
    return merged;
  }

  @override
  Future<void> addTask(TaskModel task, {String? userId}) async {
    await localDataSource.saveTask(task, userId: userId);
    if (userId != null && userId.isNotEmpty && remoteDataSource != null) {
      try {
        await remoteDataSource!.saveTask(task, userId);
        if (task.teamId != null && task.teamId!.isNotEmpty) {
          await remoteDataSource!.saveTeamTask(task.teamId!, task);
        }
      } catch (_) {}
    }
  }

  @override
  Future<void> updateTask(TaskModel task, {String? userId}) async {
    await localDataSource.updateTask(task, userId: userId);
    if (userId != null && userId.isNotEmpty && remoteDataSource != null) {
      try {
        await remoteDataSource!.updateTask(task, userId);
        if (task.teamId != null && task.teamId!.isNotEmpty) {
          await remoteDataSource!.saveTeamTask(task.teamId!, task);
        }
      } catch (_) {}
    }
  }

  @override
  Future<void> deleteTask(String id, {String? userId}) async {
    final all = await localDataSource.getTasks(userId: userId);
    final target = all.firstWhere((t) => t.id == id, orElse: () => TaskModel(id: id, title: ''));
    await localDataSource.deleteTask(id, userId: userId);
    if (userId != null && userId.isNotEmpty && remoteDataSource != null) {
      try {
        await remoteDataSource!.deleteTask(id, userId);
        if (target.teamId != null && target.teamId!.isNotEmpty) {
          await remoteDataSource!.deleteTeamTask(target.teamId!, id);
        }
      } catch (_) {}
    }
  }

  // --- WORKSPACES (PROJECTS) ---
  @override
  Future<List<WorkspaceModel>> getWorkspaces({String? userId}) async {
    final local = await localDataSource.getWorkspaces(userId: userId);

    if (userId != null && userId.isNotEmpty && remoteDataSource != null) {
      try {
        final remote = await remoteDataSource!.getWorkspaces(userId);
        if (remote.isNotEmpty) {
          final merged = _mergeWorkspaces(local, remote);
          await localDataSource.saveWorkspaces(merged, userId: userId);
          return merged;
        } else if (local.isNotEmpty) {
          for (final w in local) {
            remoteDataSource!.saveWorkspace(w, userId).catchError((_) {});
          }
        }
      } catch (_) {}
    }

    return local;
  }

  List<WorkspaceModel> _mergeWorkspaces(
      List<WorkspaceModel> local, List<WorkspaceModel> remote) {
    final map = <String, WorkspaceModel>{};
    for (final w in local) {
      map[w.id] = w;
    }
    for (final w in remote) {
      map[w.id] = w;
    }
    return map.values.toList();
  }

  @override
  Future<void> addWorkspace(WorkspaceModel workspace, {String? userId}) async {
    final current = List<WorkspaceModel>.from(await localDataSource.getWorkspaces(userId: userId));
    current.removeWhere((w) => w.id == workspace.id);
    current.add(workspace);
    await localDataSource.saveWorkspaces(current, userId: userId);

    if (userId != null && userId.isNotEmpty && remoteDataSource != null) {
      try {
        await remoteDataSource!.saveWorkspace(workspace, userId);
      } catch (_) {}
    }
  }

  // --- SPACES ---
  @override
  Future<List<SpaceModel>> getSpaces({String? userId}) async {
    final local = await localDataSource.getSpaces(userId: userId);

    if (userId != null && userId.isNotEmpty && remoteDataSource != null) {
      try {
        final remote = await remoteDataSource!.getSpaces(userId);
        if (remote.isNotEmpty) {
          final map = {for (final s in local) s.id: s};
          for (final s in remote) {
            map[s.id] = s;
          }
          final merged = map.values.toList();
          await localDataSource.saveSpaces(merged, userId: userId);
          return merged;
        }
      } catch (_) {}
    }

    return local;
  }

  @override
  Future<void> addSpace(SpaceModel space, {String? userId}) async {
    final current = List<SpaceModel>.from(await localDataSource.getSpaces(userId: userId));
    current.removeWhere((s) => s.id == space.id);
    current.add(space);
    await localDataSource.saveSpaces(current, userId: userId);

    if (userId != null && userId.isNotEmpty && remoteDataSource != null) {
      try {
        await remoteDataSource!.saveSpace(space, userId);
      } catch (_) {}
    }
  }

  // --- LISTS ---
  @override
  Future<List<TaskListModel>> getLists({String? userId}) async {
    final local = await localDataSource.getLists(userId: userId);

    if (userId != null && userId.isNotEmpty && remoteDataSource != null) {
      try {
        final remote = await remoteDataSource!.getLists(userId);
        if (remote.isNotEmpty) {
          final map = {for (final l in local) l.id: l};
          for (final l in remote) {
            map[l.id] = l;
          }
          final merged = map.values.toList();
          await localDataSource.saveLists(merged, userId: userId);
          return merged;
        }
      } catch (_) {}
    }

    return local;
  }

  @override
  Future<void> addList(TaskListModel list, {String? userId}) async {
    final current = List<TaskListModel>.from(await localDataSource.getLists(userId: userId));
    current.removeWhere((l) => l.id == list.id);
    current.add(list);
    await localDataSource.saveLists(current, userId: userId);

    if (userId != null && userId.isNotEmpty && remoteDataSource != null) {
      try {
        await remoteDataSource!.saveList(list, userId);
      } catch (_) {}
    }
  }

  // --- CATEGORIES ---
  @override
  Future<List<CategoryModel>> getCategories({String? userId}) async {
    final local = await localDataSource.getCategories(userId: userId);
    if (userId != null && userId.isNotEmpty && remoteDataSource != null) {
      try {
        final remote = await remoteDataSource!.getCategories(userId);
        if (remote.isNotEmpty) {
          final map = {for (final c in local) c.name: c};
          for (final c in remote) {
            map[c.name] = c;
          }
          return map.values.toList();
        }
      } catch (_) {}
    }
    return local;
  }

  @override
  Future<void> addCategory(CategoryModel category, {String? userId}) async {
    await localDataSource.saveCategory(category, userId: userId);
    if (userId != null && userId.isNotEmpty && remoteDataSource != null) {
      try {
        await remoteDataSource!.saveCategory(category, userId);
      } catch (_) {}
    }
  }
}
