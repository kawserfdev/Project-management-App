import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:task_manager_app/core/services/collaboration_service.dart';
import 'package:task_manager_app/features/task/data/models/category_model.dart';
import 'package:task_manager_app/features/task/data/models/task_model.dart';
import 'package:task_manager_app/features/task/data/repos/task_repository.dart';
import 'package:task_manager_app/features/task/presentation/manager/task_state.dart';
import 'package:task_manager_app/features/workspace/data/models/workspace_hierarchy_models.dart';

class TaskCubit extends Cubit<TaskState> {
  final TaskRepository taskRepository;
  final CollaborationService collaborationService;
  StreamSubscription<CollaborationEvent>? _collabSubscription;
  String? _currentUserId;

  TaskCubit({
    required this.taskRepository,
    CollaborationService? collaborationService,
  })  : collaborationService = collaborationService ?? CollaborationService(),
        super(const TaskState()) {
    _listenToCollaborationEvents();
  }

  void _listenToCollaborationEvents() {
    _collabSubscription = collaborationService.eventStream.listen((event) {
      emit(state.copyWith(latestEvent: event));
    });
  }

  @override
  Future<void> close() {
    _collabSubscription?.cancel();
    return super.close();
  }

  Future<void> init({String? userId}) async {
    _currentUserId = userId ?? _currentUserId;
    await loadCategories();
    await loadWorkspaces();
    await loadTasks();
  }

  Future<void> loadCategories() async {
    try {
      final categories =
          await taskRepository.getCategories(userId: _currentUserId);
      emit(state.copyWith(categories: categories));
    } catch (_) {}
  }

  Future<void> loadWorkspaces() async {
    try {
      final workspaces =
          await taskRepository.getWorkspaces(userId: _currentUserId);
      final spaces = await taskRepository.getSpaces(userId: _currentUserId);
      final lists = await taskRepository.getLists(userId: _currentUserId);

      final selectedWs = workspaces.firstWhere(
        (w) => w.id == state.selectedWorkspace.id,
        orElse: () => workspaces.isNotEmpty
            ? workspaces.first
            : WorkspaceModel.defaultWorkspaces.first,
      );

      emit(state.copyWith(
        workspaces: workspaces,
        spaces: spaces,
        lists: lists,
        selectedWorkspace: selectedWs,
      ));
    } catch (_) {}
  }

  Future<void> loadTasks() async {
    emit(state.copyWith(isLoading: true));
    try {
      final tasks = await taskRepository.getTasks(userId: _currentUserId);
      final filtered = _applyFilters(
        tasks: tasks,
        query: state.searchQuery,
        category: state.selectedCategory,
        status: state.filterStatus,
        workspaceId: state.selectedWorkspace.id,
        spaceId: state.selectedSpace?.id,
        listId: state.selectedList?.id,
      );
      emit(state.copyWith(
        isLoading: false,
        allTasks: tasks,
        filteredTasks: filtered,
      ));
    } catch (e) {
      emit(state.copyWith(
        isLoading: false,
        errorMessage: 'Failed to load tasks: $e',
      ));
    }
  }

  void toggleViewMode() {
    final next = state.viewMode == TaskViewMode.list
        ? TaskViewMode.board
        : TaskViewMode.list;
    emit(state.copyWith(viewMode: next));
  }

  void setViewMode(TaskViewMode mode) {
    emit(state.copyWith(viewMode: mode));
  }

  // --- Hierarchy Controls ---
  void selectWorkspace(WorkspaceModel workspace) {
    final filtered = _applyFilters(
      tasks: state.allTasks,
      query: state.searchQuery,
      category: state.selectedCategory,
      status: state.filterStatus,
      workspaceId: workspace.id,
      spaceId: null,
      listId: null,
    );
    emit(state.copyWith(
      selectedWorkspace: workspace,
      clearSelectedSpace: true,
      clearSelectedList: true,
      filteredTasks: filtered,
    ));
  }

  Future<void> addWorkspace(WorkspaceModel workspace) async {
    final updated = [...state.workspaces, workspace];
    emit(state.copyWith(workspaces: updated, selectedWorkspace: workspace));
    await taskRepository.addWorkspace(workspace, userId: _currentUserId);
  }

  void selectSpace(SpaceModel? space) {
    final filtered = _applyFilters(
      tasks: state.allTasks,
      query: state.searchQuery,
      category: state.selectedCategory,
      status: state.filterStatus,
      workspaceId: state.selectedWorkspace.id,
      spaceId: space?.id,
      listId: null,
    );
    emit(state.copyWith(
      selectedSpace: space,
      clearSelectedSpace: space == null,
      clearSelectedList: true,
      filteredTasks: filtered,
    ));
  }

  Future<void> addSpace(SpaceModel space) async {
    final updated = [...state.spaces, space];
    emit(state.copyWith(spaces: updated, selectedSpace: space));
    await taskRepository.addSpace(space, userId: _currentUserId);
  }

  void selectList(TaskListModel? list) {
    final filtered = _applyFilters(
      tasks: state.allTasks,
      query: state.searchQuery,
      category: state.selectedCategory,
      status: state.filterStatus,
      workspaceId: state.selectedWorkspace.id,
      spaceId: state.selectedSpace?.id,
      listId: list?.id,
    );
    emit(state.copyWith(
      selectedList: list,
      clearSelectedList: list == null,
      filteredTasks: filtered,
    ));
  }

  Future<void> addList(TaskListModel list) async {
    final updated = [...state.lists, list];
    emit(state.copyWith(lists: updated, selectedList: list));
    await taskRepository.addList(list, userId: _currentUserId);
  }

  // --- Task CRUD & Collaboration ---
  Future<void> addTask(TaskModel task) async {
    try {
      // Auto-assign active hierarchy if not set
      final assignedTask = task.copyWith(
        workspaceId: task.workspaceId.isNotEmpty ? task.workspaceId : state.selectedWorkspace.id,
        spaceId: task.spaceId.isNotEmpty ? task.spaceId : (state.selectedSpace?.id ?? 'space_personal'),
        listId: task.listId.isNotEmpty ? task.listId : (state.selectedList?.id ?? 'list_daily'),
      );

      await taskRepository.addTask(assignedTask, userId: _currentUserId);
      final updatedAll = [assignedTask, ...state.allTasks];
      final filtered = _applyFilters(
        tasks: updatedAll,
        query: state.searchQuery,
        category: state.selectedCategory,
        status: state.filterStatus,
        workspaceId: state.selectedWorkspace.id,
        spaceId: state.selectedSpace?.id,
        listId: state.selectedList?.id,
      );

      emit(state.copyWith(
        allTasks: updatedAll,
        filteredTasks: filtered,
      ));

      collaborationService.broadcastTaskCreated(assignedTask);
    } catch (e) {
      emit(state.copyWith(errorMessage: 'Failed to add task: $e'));
    }
  }

  Future<void> updateTask(TaskModel task) async {
    try {
      await taskRepository.updateTask(task, userId: _currentUserId);
      final updatedAll = state.allTasks.map((t) => t.id == task.id ? task : t).toList();
      final filtered = _applyFilters(
        tasks: updatedAll,
        query: state.searchQuery,
        category: state.selectedCategory,
        status: state.filterStatus,
        workspaceId: state.selectedWorkspace.id,
        spaceId: state.selectedSpace?.id,
        listId: state.selectedList?.id,
      );

      emit(state.copyWith(
        allTasks: updatedAll,
        filteredTasks: filtered,
      ));

      collaborationService.broadcastTaskUpdated(task);
    } catch (e) {
      emit(state.copyWith(errorMessage: 'Failed to update task: $e'));
    }
  }

  /// Kanban Drag-and-drop: moves a task to a target status column
  Future<void> updateTaskStatus(String taskId, String newStatus) async {
    final idx = state.allTasks.indexWhere((t) => t.id == taskId);
    if (idx == -1) return;

    final target = state.allTasks[idx];
    final normalized = TaskStatus.fromKey(newStatus).key;
    if (target.status == normalized) return;

    final isCompleted = (normalized == 'completed');
    final updated = target.copyWith(
      status: normalized,
      isCompleted: isCompleted,
    );

    await updateTask(updated);
    collaborationService.broadcastStatusMoved(updated, normalized);
  }

  Future<void> addCommentToTask(String taskId, String message, {String author = 'You'}) async {
    final idx = state.allTasks.indexWhere((t) => t.id == taskId);
    if (idx == -1) return;

    final target = state.allTasks[idx];
    final newComment = TaskComment(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      author: author,
      message: message,
    );

    final updated = target.copyWith(
      comments: [...target.comments, newComment],
    );

    await updateTask(updated);
    collaborationService.broadcastCommentAdded(updated, newComment);
  }

  Future<void> deleteTask(String id) async {
    try {
      final task = state.allTasks.firstWhere((t) => t.id == id, orElse: () => TaskModel(id: id, title: 'Task'));
      await taskRepository.deleteTask(id, userId: _currentUserId);
      final updatedAll = state.allTasks.where((t) => t.id != id).toList();
      final filtered = _applyFilters(
        tasks: updatedAll,
        query: state.searchQuery,
        category: state.selectedCategory,
        status: state.filterStatus,
        workspaceId: state.selectedWorkspace.id,
        spaceId: state.selectedSpace?.id,
        listId: state.selectedList?.id,
      );

      emit(state.copyWith(
        allTasks: updatedAll,
        filteredTasks: filtered,
      ));

      collaborationService.broadcastTaskDeleted(id, task.title);
    } catch (e) {
      emit(state.copyWith(errorMessage: 'Failed to delete task: $e'));
    }
  }

  Future<void> toggleTaskCompletion(String id) async {
    final task = state.allTasks.firstWhere((t) => t.id == id);
    final isDone = !task.isCompleted;
    final updated = task.copyWith(
      isCompleted: isDone,
      status: isDone ? 'completed' : 'pending',
    );
    await updateTask(updated);
  }

  void searchTasks(String query) {
    final filtered = _applyFilters(
      tasks: state.allTasks,
      query: query,
      category: state.selectedCategory,
      status: state.filterStatus,
      workspaceId: state.selectedWorkspace.id,
      spaceId: state.selectedSpace?.id,
      listId: state.selectedList?.id,
    );
    emit(state.copyWith(
      searchQuery: query,
      filteredTasks: filtered,
    ));
  }

  void filterByCategory(String? category) {
    final newCategory = state.selectedCategory == category ? null : category;
    final filtered = _applyFilters(
      tasks: state.allTasks,
      query: state.searchQuery,
      category: newCategory,
      status: state.filterStatus,
      workspaceId: state.selectedWorkspace.id,
      spaceId: state.selectedSpace?.id,
      listId: state.selectedList?.id,
    );
    emit(state.copyWith(
      selectedCategory: newCategory,
      clearSelectedCategory: newCategory == null,
      filteredTasks: filtered,
    ));
  }

  void filterByStatus(TaskFilterStatus status) {
    final filtered = _applyFilters(
      tasks: state.allTasks,
      query: state.searchQuery,
      category: state.selectedCategory,
      status: status,
      workspaceId: state.selectedWorkspace.id,
      spaceId: state.selectedSpace?.id,
      listId: state.selectedList?.id,
    );
    emit(state.copyWith(
      filterStatus: status,
      filteredTasks: filtered,
    ));
  }

  void sortByDate() {
    final sorted = List<TaskModel>.from(state.filteredTasks)
      ..sort((a, b) => (a.dueDate ?? DateTime(2099))
          .compareTo(b.dueDate ?? DateTime(2099)));
    emit(state.copyWith(filteredTasks: sorted));
  }

  void sortByPriority() {
    final sorted = List<TaskModel>.from(state.filteredTasks)
      ..sort((a, b) => b.priority.compareTo(a.priority));
    emit(state.copyWith(filteredTasks: sorted));
  }

  void sortByTitle() {
    final sorted = List<TaskModel>.from(state.filteredTasks)
      ..sort((a, b) => a.title.toLowerCase().compareTo(b.title.toLowerCase()));
    emit(state.copyWith(filteredTasks: sorted));
  }

  Future<void> addCategory(CategoryModel category) async {
    try {
      await taskRepository.addCategory(category, userId: _currentUserId);
      final updatedCategories = [...state.categories, category];
      emit(state.copyWith(categories: updatedCategories));
    } catch (_) {}
  }

  void resetUserSession() {
    _currentUserId = null;
    emit(const TaskState());
  }

  List<TaskModel> _applyFilters({
    required List<TaskModel> tasks,
    required String query,
    required String? category,
    required TaskFilterStatus status,
    String? workspaceId,
    String? spaceId,
    String? listId,
  }) {
    return tasks.where((task) {
      final matchesQuery = query.isEmpty ||
          task.title.toLowerCase().contains(query.toLowerCase()) ||
          task.description.toLowerCase().contains(query.toLowerCase());

      final matchesCategory = category == null || task.category == category;

      final matchesStatus = switch (status) {
        TaskFilterStatus.all => true,
        TaskFilterStatus.pending => !task.isCompleted && TaskStatus.fromKey(task.status) == TaskStatus.pending,
        TaskFilterStatus.inProgress => !task.isCompleted && TaskStatus.fromKey(task.status) == TaskStatus.inProgress,
        TaskFilterStatus.onHold => !task.isCompleted && TaskStatus.fromKey(task.status) == TaskStatus.onHold,
        TaskFilterStatus.inReview => !task.isCompleted && TaskStatus.fromKey(task.status) == TaskStatus.inReview,
        TaskFilterStatus.completed => task.isCompleted || TaskStatus.fromKey(task.status) == TaskStatus.completed,
      };

      final matchesWorkspace = workspaceId == null ||
          task.workspaceId == workspaceId ||
          task.workspaceId.isEmpty ||
          task.workspaceId == 'ws_default';

      final matchesSpace = spaceId == null ||
          task.spaceId == spaceId ||
          task.spaceId.isEmpty;

      final matchesList = listId == null ||
          task.listId == listId ||
          task.listId.isEmpty;

      return matchesQuery &&
          matchesCategory &&
          matchesStatus &&
          matchesWorkspace &&
          matchesSpace &&
          matchesList;
    }).toList();
  }
}
