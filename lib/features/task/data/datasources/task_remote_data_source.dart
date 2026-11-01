import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:task_manager_app/features/task/data/models/category_model.dart';
import 'package:task_manager_app/features/task/data/models/task_model.dart';
import 'package:task_manager_app/features/workspace/data/models/workspace_hierarchy_models.dart';

abstract class TaskRemoteDataSource {
  Future<List<TaskModel>> getTasks(String userId);
  Future<void> saveTask(TaskModel task, String userId);
  Future<void> updateTask(TaskModel task, String userId);
  Future<void> deleteTask(String taskId, String userId);

  // --- TEAM TASKS ---
  Future<List<TaskModel>> getTeamTasks(String teamId);
  Future<void> saveTeamTask(String teamId, TaskModel task);
  Future<void> deleteTeamTask(String teamId, String taskId);
  Future<List<String>> getUserTeamIds(String userId);

  Future<List<WorkspaceModel>> getWorkspaces(String userId);
  Future<void> saveWorkspace(WorkspaceModel workspace, String userId);

  Future<List<SpaceModel>> getSpaces(String userId);
  Future<void> saveSpace(SpaceModel space, String userId);

  Future<List<TaskListModel>> getLists(String userId);
  Future<void> saveList(TaskListModel list, String userId);

  Future<List<CategoryModel>> getCategories(String userId);
  Future<void> saveCategory(CategoryModel category, String userId);
}

class TaskRemoteDataSourceImpl implements TaskRemoteDataSource {
  final FirebaseFirestore? _firestore;

  TaskRemoteDataSourceImpl({FirebaseFirestore? firestore})
      : _firestore = firestore;

  FirebaseFirestore? get _safeFirestore {
    try {
      return _firestore ?? FirebaseFirestore.instance;
    } catch (_) {
      return null;
    }
  }

  // --- TASKS ---
  @override
  Future<List<TaskModel>> getTasks(String userId) async {
    final fs = _safeFirestore;
    if (fs == null || userId.isEmpty) return [];

    try {
      final snapshot = await fs
          .collection('users')
          .doc(userId)
          .collection('tasks')
          .orderBy('createdAt', descending: true)
          .get();

      return snapshot.docs.map((doc) => TaskModel.fromMap(doc.data())).toList();
    } catch (_) {
      return [];
    }
  }

  @override
  Future<void> saveTask(TaskModel task, String userId) async {
    final fs = _safeFirestore;
    if (fs == null || userId.isEmpty) return;

    try {
      await fs
          .collection('users')
          .doc(userId)
          .collection('tasks')
          .doc(task.id)
          .set(task.toMap(), SetOptions(merge: true));
    } catch (_) {}
  }

  @override
  Future<void> updateTask(TaskModel task, String userId) async {
    final fs = _safeFirestore;
    if (fs == null || userId.isEmpty) return;

    try {
      await fs
          .collection('users')
          .doc(userId)
          .collection('tasks')
          .doc(task.id)
          .set(task.toMap(), SetOptions(merge: true));
    } catch (_) {}
  }

  @override
  Future<void> deleteTask(String taskId, String userId) async {
    final fs = _safeFirestore;
    if (fs == null || userId.isEmpty) return;

    try {
      await fs
          .collection('users')
          .doc(userId)
          .collection('tasks')
          .doc(taskId)
          .delete();
    } catch (_) {}
  }

  // --- TEAM TASKS ---
  @override
  Future<List<String>> getUserTeamIds(String userId) async {
    final fs = _safeFirestore;
    if (fs == null || userId.isEmpty) return [];
    try {
      final snap = await fs
          .collection('teams')
          .where('memberUids', arrayContains: userId)
          .get();
      return snap.docs.map((d) => d.id).toList();
    } catch (_) {
      return [];
    }
  }

  @override
  Future<List<TaskModel>> getTeamTasks(String teamId) async {
    final fs = _safeFirestore;
    if (fs == null || teamId.isEmpty) return [];
    try {
      final snap = await fs
          .collection('teams')
          .doc(teamId)
          .collection('tasks')
          .get();
      return snap.docs.map((d) => TaskModel.fromMap(d.data())).toList();
    } catch (_) {
      return [];
    }
  }

  @override
  Future<void> saveTeamTask(String teamId, TaskModel task) async {
    final fs = _safeFirestore;
    if (fs == null || teamId.isEmpty) return;
    try {
      await fs
          .collection('teams')
          .doc(teamId)
          .collection('tasks')
          .doc(task.id)
          .set(task.toMap(), SetOptions(merge: true));
    } catch (_) {}
  }

  @override
  Future<void> deleteTeamTask(String teamId, String taskId) async {
    final fs = _safeFirestore;
    if (fs == null || teamId.isEmpty) return;
    try {
      await fs
          .collection('teams')
          .doc(teamId)
          .collection('tasks')
          .doc(taskId)
          .delete();
    } catch (_) {}
  }

  // --- WORKSPACES (PROJECTS) ---
  @override
  Future<List<WorkspaceModel>> getWorkspaces(String userId) async {
    final fs = _safeFirestore;
    if (fs == null || userId.isEmpty) return [];

    try {
      final snapshot = await fs
          .collection('users')
          .doc(userId)
          .collection('workspaces')
          .get();

      return snapshot.docs
          .map((doc) => WorkspaceModel.fromMap(doc.data()))
          .toList();
    } catch (_) {
      return [];
    }
  }

  @override
  Future<void> saveWorkspace(WorkspaceModel workspace, String userId) async {
    final fs = _safeFirestore;
    if (fs == null || userId.isEmpty) return;

    try {
      await fs
          .collection('users')
          .doc(userId)
          .collection('workspaces')
          .doc(workspace.id)
          .set(workspace.toMap(), SetOptions(merge: true));
    } catch (_) {}
  }

  // --- SPACES ---
  @override
  Future<List<SpaceModel>> getSpaces(String userId) async {
    final fs = _safeFirestore;
    if (fs == null || userId.isEmpty) return [];

    try {
      final snapshot = await fs
          .collection('users')
          .doc(userId)
          .collection('spaces')
          .get();

      return snapshot.docs.map((doc) => SpaceModel.fromMap(doc.data())).toList();
    } catch (_) {
      return [];
    }
  }

  @override
  Future<void> saveSpace(SpaceModel space, String userId) async {
    final fs = _safeFirestore;
    if (fs == null || userId.isEmpty) return;

    try {
      await fs
          .collection('users')
          .doc(userId)
          .collection('spaces')
          .doc(space.id)
          .set(space.toMap(), SetOptions(merge: true));
    } catch (_) {}
  }

  // --- LISTS ---
  @override
  Future<List<TaskListModel>> getLists(String userId) async {
    final fs = _safeFirestore;
    if (fs == null || userId.isEmpty) return [];

    try {
      final snapshot = await fs
          .collection('users')
          .doc(userId)
          .collection('lists')
          .get();

      return snapshot.docs
          .map((doc) => TaskListModel.fromMap(doc.data()))
          .toList();
    } catch (_) {
      return [];
    }
  }

  @override
  Future<void> saveList(TaskListModel list, String userId) async {
    final fs = _safeFirestore;
    if (fs == null || userId.isEmpty) return;

    try {
      await fs
          .collection('users')
          .doc(userId)
          .collection('lists')
          .doc(list.id)
          .set(list.toMap(), SetOptions(merge: true));
    } catch (_) {}
  }

  // --- CATEGORIES ---
  @override
  Future<List<CategoryModel>> getCategories(String userId) async {
    final fs = _safeFirestore;
    if (fs == null || userId.isEmpty) return [];

    try {
      final snapshot = await fs
          .collection('users')
          .doc(userId)
          .collection('categories')
          .get();

      return snapshot.docs
          .map((doc) => CategoryModel.fromMap(doc.data()))
          .toList();
    } catch (_) {
      return [];
    }
  }

  @override
  Future<void> saveCategory(CategoryModel category, String userId) async {
    final fs = _safeFirestore;
    if (fs == null || userId.isEmpty) return;

    try {
      await fs
          .collection('users')
          .doc(userId)
          .collection('categories')
          .doc(category.name)
          .set(category.toMap(), SetOptions(merge: true));
    } catch (_) {}
  }
}

