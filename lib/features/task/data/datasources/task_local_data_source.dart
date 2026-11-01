import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:task_manager_app/features/task/data/models/category_model.dart';
import 'package:task_manager_app/features/task/data/models/task_model.dart';
import 'package:task_manager_app/features/workspace/data/models/workspace_hierarchy_models.dart';

abstract class TaskLocalDataSource {
  Future<List<TaskModel>> getTasks({String? userId});
  Future<void> saveTasks(List<TaskModel> tasks, {String? userId});
  Future<void> saveTask(TaskModel task, {String? userId});
  Future<void> updateTask(TaskModel task, {String? userId});
  Future<void> deleteTask(String id, {String? userId});

  Future<List<WorkspaceModel>> getWorkspaces({String? userId});
  Future<void> saveWorkspaces(List<WorkspaceModel> workspaces, {String? userId});

  Future<List<SpaceModel>> getSpaces({String? userId});
  Future<void> saveSpaces(List<SpaceModel> spaces, {String? userId});

  Future<List<TaskListModel>> getLists({String? userId});
  Future<void> saveLists(List<TaskListModel> lists, {String? userId});

  Future<List<CategoryModel>> getCategories({String? userId});
  Future<void> saveCategory(CategoryModel category, {String? userId});
}

class TaskLocalDataSourceImpl implements TaskLocalDataSource {
  static const String _globalTasksKey = 'cached_tasks_v1';
  static const String _globalWorkspacesKey = 'cached_workspaces_v1';
  static const String _globalSpacesKey = 'cached_spaces_v1';
  static const String _globalListsKey = 'cached_lists_v1';
  static const String _categoriesKey = 'cached_categories_v1';

  String _taskKey(String? userId) =>
      userId != null ? 'cached_tasks_v1_$userId' : _globalTasksKey;
  String _wsKey(String? userId) =>
      userId != null ? 'cached_workspaces_v1_$userId' : _globalWorkspacesKey;
  String _spKey(String? userId) =>
      userId != null ? 'cached_spaces_v1_$userId' : _globalSpacesKey;
  String _lsKey(String? userId) =>
      userId != null ? 'cached_lists_v1_$userId' : _globalListsKey;

  // --- TASKS ---
  @override
  Future<List<TaskModel>> getTasks({String? userId}) async {
    final prefs = await SharedPreferences.getInstance();
    String? jsonString;
    if (userId != null) {
      jsonString = prefs.getString(_taskKey(userId));
    } else {
      jsonString = prefs.getString(_globalTasksKey);
    }

    if (jsonString == null || jsonString.isEmpty) {
      return [];
    }
    try {
      final List decoded = jsonDecode(jsonString) as List;
      return decoded
          .map((item) => TaskModel.fromMap(item as Map<String, dynamic>))
          .toList();
    } catch (_) {
      return [];
    }
  }

  @override
  Future<void> saveTasks(List<TaskModel> tasks, {String? userId}) async {
    final prefs = await SharedPreferences.getInstance();
    final jsonStr = jsonEncode(tasks.map((t) => t.toMap()).toList());
    if (userId != null) {
      await prefs.setString(_taskKey(userId), jsonStr);
    } else {
      await prefs.setString(_globalTasksKey, jsonStr);
    }
  }

  @override
  Future<void> saveTask(TaskModel task, {String? userId}) async {
    final tasks = await getTasks(userId: userId);
    tasks.removeWhere((t) => t.id == task.id);
    tasks.insert(0, task);
    await saveTasks(tasks, userId: userId);
  }

  @override
  Future<void> updateTask(TaskModel task, {String? userId}) async {
    final tasks = await getTasks(userId: userId);
    final index = tasks.indexWhere((t) => t.id == task.id);
    if (index != -1) {
      tasks[index] = task;
    } else {
      tasks.insert(0, task);
    }
    await saveTasks(tasks, userId: userId);
  }

  @override
  Future<void> deleteTask(String id, {String? userId}) async {
    final tasks = await getTasks(userId: userId);
    tasks.removeWhere((t) => t.id == id);
    await saveTasks(tasks, userId: userId);
  }

  // --- WORKSPACES (PROJECTS) ---
  @override
  Future<List<WorkspaceModel>> getWorkspaces({String? userId}) async {
    final prefs = await SharedPreferences.getInstance();
    String? jsonString;
    if (userId != null) {
      jsonString = prefs.getString(_wsKey(userId));
    } else {
      jsonString = prefs.getString(_globalWorkspacesKey);
    }

    if (jsonString == null || jsonString.isEmpty) {
      return WorkspaceModel.defaultWorkspaces;
    }
    try {
      final List decoded = jsonDecode(jsonString) as List;
      final loaded = decoded
          .map((item) => WorkspaceModel.fromMap(item as Map<String, dynamic>))
          .toList();
      return loaded.isNotEmpty ? loaded : WorkspaceModel.defaultWorkspaces;
    } catch (_) {
      return WorkspaceModel.defaultWorkspaces;
    }
  }

  @override
  Future<void> saveWorkspaces(List<WorkspaceModel> workspaces,
      {String? userId}) async {
    final prefs = await SharedPreferences.getInstance();
    final jsonStr = jsonEncode(workspaces.map((w) => w.toMap()).toList());
    if (userId != null) {
      await prefs.setString(_wsKey(userId), jsonStr);
    } else {
      await prefs.setString(_globalWorkspacesKey, jsonStr);
    }
  }

  // --- SPACES ---
  @override
  Future<List<SpaceModel>> getSpaces({String? userId}) async {
    final prefs = await SharedPreferences.getInstance();
    String? jsonString;
    if (userId != null) {
      jsonString = prefs.getString(_spKey(userId));
    } else {
      jsonString = prefs.getString(_globalSpacesKey);
    }

    if (jsonString == null || jsonString.isEmpty) {
      return SpaceModel.defaultSpaces;
    }
    try {
      final List decoded = jsonDecode(jsonString) as List;
      final loaded = decoded
          .map((item) => SpaceModel.fromMap(item as Map<String, dynamic>))
          .toList();
      return loaded.isNotEmpty ? loaded : SpaceModel.defaultSpaces;
    } catch (_) {
      return SpaceModel.defaultSpaces;
    }
  }

  @override
  Future<void> saveSpaces(List<SpaceModel> spaces, {String? userId}) async {
    final prefs = await SharedPreferences.getInstance();
    final jsonStr = jsonEncode(spaces.map((s) => s.toMap()).toList());
    if (userId != null) {
      await prefs.setString(_spKey(userId), jsonStr);
    } else {
      await prefs.setString(_globalSpacesKey, jsonStr);
    }
  }

  // --- LISTS ---
  @override
  Future<List<TaskListModel>> getLists({String? userId}) async {
    final prefs = await SharedPreferences.getInstance();
    String? jsonString;
    if (userId != null) {
      jsonString = prefs.getString(_lsKey(userId));
    } else {
      jsonString = prefs.getString(_globalListsKey);
    }

    if (jsonString == null || jsonString.isEmpty) {
      return TaskListModel.defaultLists;
    }
    try {
      final List decoded = jsonDecode(jsonString) as List;
      final loaded = decoded
          .map((item) => TaskListModel.fromMap(item as Map<String, dynamic>))
          .toList();
      return loaded.isNotEmpty ? loaded : TaskListModel.defaultLists;
    } catch (_) {
      return TaskListModel.defaultLists;
    }
  }

  @override
  Future<void> saveLists(List<TaskListModel> lists, {String? userId}) async {
    final prefs = await SharedPreferences.getInstance();
    final jsonStr = jsonEncode(lists.map((l) => l.toMap()).toList());
    if (userId != null) {
      await prefs.setString(_lsKey(userId), jsonStr);
    } else {
      await prefs.setString(_globalListsKey, jsonStr);
    }
  }

  // --- CATEGORIES ---
  @override
  Future<List<CategoryModel>> getCategories({String? userId}) async {
    final prefs = await SharedPreferences.getInstance();
    final jsonString = prefs.getString(_categoriesKey);
    if (jsonString == null || jsonString.isEmpty) {
      return CategoryModel.defaultCategories;
    }
    try {
      final List decoded = jsonDecode(jsonString) as List;
      final customCategories = decoded
          .map((item) => CategoryModel.fromMap(item as Map<String, dynamic>))
          .toList();
      return [...CategoryModel.defaultCategories, ...customCategories];
    } catch (_) {
      return CategoryModel.defaultCategories;
    }
  }

  @override
  Future<void> saveCategory(CategoryModel category, {String? userId}) async {
    final prefs = await SharedPreferences.getInstance();
    final jsonString = prefs.getString(_categoriesKey);
    List customList = [];
    if (jsonString != null && jsonString.isNotEmpty) {
      try {
        customList = jsonDecode(jsonString) as List;
      } catch (_) {}
    }
    customList.add(category.toMap());
    await prefs.setString(_categoriesKey, jsonEncode(customList));
  }
}
