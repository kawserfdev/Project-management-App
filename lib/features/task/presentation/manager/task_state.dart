import 'package:equatable/equatable.dart';
import 'package:task_manager_app/core/services/collaboration_service.dart';
import 'package:task_manager_app/features/task/data/models/category_model.dart';
import 'package:task_manager_app/features/task/data/models/task_model.dart';
import 'package:task_manager_app/features/workspace/data/models/workspace_hierarchy_models.dart';

enum TaskFilterStatus {
  all,
  pending,      // Started / Pending
  inProgress,   // In Progress / Active
  onHold,       // On Hold / Blocked
  inReview,     // In Review
  completed,    // Completed
}
enum TaskViewMode { list, board }

class TaskState extends Equatable {
  final bool isLoading;
  final List<TaskModel> allTasks;
  final List<TaskModel> filteredTasks;
  final List<CategoryModel> categories;
  final String searchQuery;
  final String? selectedCategory;
  final TaskFilterStatus filterStatus;
  final TaskViewMode viewMode;

  // Hierarchy
  final List<WorkspaceModel> workspaces;
  final WorkspaceModel selectedWorkspace;
  final List<SpaceModel> spaces;
  final SpaceModel? selectedSpace;
  final List<TaskListModel> lists;
  final TaskListModel? selectedList;

  // Real-time collaboration
  final CollaborationEvent? latestEvent;
  final String? errorMessage;

  const TaskState({
    this.isLoading = false,
    this.allTasks = const [],
    this.filteredTasks = const [],
    this.categories = const [],
    this.searchQuery = '',
    this.selectedCategory,
    this.filterStatus = TaskFilterStatus.all,
    this.viewMode = TaskViewMode.list,
    this.workspaces = const [],
    this.selectedWorkspace = const WorkspaceModel(
      id: 'ws_default',
      name: 'Personal Workspace',
    ),
    this.spaces = const [],
    this.selectedSpace,
    this.lists = const [],
    this.selectedList,
    this.latestEvent,
    this.errorMessage,
  });

  TaskState copyWith({
    bool? isLoading,
    List<TaskModel>? allTasks,
    List<TaskModel>? filteredTasks,
    List<CategoryModel>? categories,
    String? searchQuery,
    String? selectedCategory,
    bool clearSelectedCategory = false,
    TaskFilterStatus? filterStatus,
    TaskViewMode? viewMode,
    List<WorkspaceModel>? workspaces,
    WorkspaceModel? selectedWorkspace,
    List<SpaceModel>? spaces,
    SpaceModel? selectedSpace,
    bool clearSelectedSpace = false,
    List<TaskListModel>? lists,
    TaskListModel? selectedList,
    bool clearSelectedList = false,
    CollaborationEvent? latestEvent,
    String? errorMessage,
  }) {
    return TaskState(
      isLoading: isLoading ?? this.isLoading,
      allTasks: allTasks ?? this.allTasks,
      filteredTasks: filteredTasks ?? this.filteredTasks,
      categories: categories ?? this.categories,
      searchQuery: searchQuery ?? this.searchQuery,
      selectedCategory: clearSelectedCategory
          ? null
          : (selectedCategory ?? this.selectedCategory),
      filterStatus: filterStatus ?? this.filterStatus,
      viewMode: viewMode ?? this.viewMode,
      workspaces: workspaces ?? this.workspaces,
      selectedWorkspace: selectedWorkspace ?? this.selectedWorkspace,
      spaces: spaces ?? this.spaces,
      selectedSpace: clearSelectedSpace
          ? null
          : (selectedSpace ?? this.selectedSpace),
      lists: lists ?? this.lists,
      selectedList: clearSelectedList
          ? null
          : (selectedList ?? this.selectedList),
      latestEvent: latestEvent ?? this.latestEvent,
      errorMessage: errorMessage,
    );
  }

  @override
  List<Object?> get props => [
        isLoading,
        allTasks,
        filteredTasks,
        categories,
        searchQuery,
        selectedCategory,
        filterStatus,
        viewMode,
        workspaces,
        selectedWorkspace,
        spaces,
        selectedSpace,
        lists,
        selectedList,
        latestEvent,
        errorMessage,
      ];
}
