import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/svg.dart';
import 'package:iconsax/iconsax.dart';
import 'package:intl/intl.dart';
import 'package:task_manager_app/core/constants/app_colors.dart';
import 'package:task_manager_app/core/constants/app_images.dart';
import 'package:task_manager_app/core/routes/routes.dart';
import 'package:task_manager_app/core/themes/app_text_themes.dart';
import 'package:task_manager_app/features/home/presentation/manager/logic/navigation/navigation_cubit.dart';
import 'package:task_manager_app/features/index/presentation/views/board_view.dart';
import 'package:task_manager_app/features/task/data/models/task_model.dart';
import 'package:task_manager_app/features/task/presentation/manager/task_cubit.dart';
import 'package:task_manager_app/features/task/presentation/manager/task_state.dart';
import 'package:task_manager_app/features/workspace/presentation/widgets/hierarchy_selector_sheet.dart';

class IndexView extends StatefulWidget {
  const IndexView({super.key});

  @override
  State<IndexView> createState() => _IndexViewState();
}

class _IndexViewState extends State<IndexView> {
  final _searchController = TextEditingController();
  final _tabScrollController = ScrollController();
  final _listScrollController = ScrollController();
  bool _isSearching = false;

  @override
  void dispose() {
    _searchController.dispose();
    _tabScrollController.dispose();
    _listScrollController.dispose();
    super.dispose();
  }

  void _showSortDialog() {
    showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.textFieldBackgroundColor,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16.r)),
      ),
      builder: (ctx) {
        return Padding(
          padding: EdgeInsets.symmetric(vertical: 20.h, horizontal: 16.w),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Sort By', style: AppTextThemes.font20WhiteRegularWithStyle),
              SizedBox(height: 12.h),
              ListTile(
                leading: const Icon(Iconsax.calendar, color: AppColors.primaryColor),
                title: const Text('Due Date', style: TextStyle(color: Colors.white)),
                onTap: () {
                  context.read<TaskCubit>().sortByDate();
                  Navigator.pop(ctx);
                },
              ),
              ListTile(
                leading: const Icon(Iconsax.flag, color: Colors.redAccent),
                title: const Text('Priority (Urgent/High first)', style: TextStyle(color: Colors.white)),
                onTap: () {
                  context.read<TaskCubit>().sortByPriority();
                  Navigator.pop(ctx);
                },
              ),
              ListTile(
                leading: const Icon(Iconsax.text, color: Colors.blueAccent),
                title: const Text('Task Title (A-Z)', style: TextStyle(color: Colors.white)),
                onTap: () {
                  context.read<TaskCubit>().sortByTitle();
                  Navigator.pop(ctx);
                },
              ),
            ],
          ),
        );
      },
    );
  }

  int _getCountForStatus(TaskState state, TaskFilterStatus status) {
    final baseTasks = state.allTasks.where((task) {
      final matchesWorkspace = state.selectedWorkspace.id.isEmpty ||
          state.selectedWorkspace.id == 'ws_default' ||
          task.workspaceId == state.selectedWorkspace.id ||
          task.workspaceId.isEmpty ||
          task.workspaceId == 'ws_default';

      final matchesSpace = state.selectedSpace == null ||
          task.spaceId == state.selectedSpace!.id ||
          task.spaceId.isEmpty;

      final matchesList = state.selectedList == null ||
          task.listId == state.selectedList!.id ||
          task.listId.isEmpty;

      final matchesCategory = state.selectedCategory == null ||
          task.category == state.selectedCategory;

      final matchesQuery = state.searchQuery.isEmpty ||
          task.title.toLowerCase().contains(state.searchQuery.toLowerCase()) ||
          task.description.toLowerCase().contains(state.searchQuery.toLowerCase());

      return matchesWorkspace && matchesSpace && matchesList && matchesCategory && matchesQuery;
    }).toList();

    if (status == TaskFilterStatus.all) return baseTasks.length;

    return baseTasks.where((task) {
      return switch (status) {
        TaskFilterStatus.all => true,
        TaskFilterStatus.pending => !task.isCompleted && TaskStatus.fromKey(task.status) == TaskStatus.pending,
        TaskFilterStatus.inProgress => !task.isCompleted && TaskStatus.fromKey(task.status) == TaskStatus.inProgress,
        TaskFilterStatus.onHold => !task.isCompleted && TaskStatus.fromKey(task.status) == TaskStatus.onHold,
        TaskFilterStatus.inReview => !task.isCompleted && TaskStatus.fromKey(task.status) == TaskStatus.inReview,
        TaskFilterStatus.completed => task.isCompleted || TaskStatus.fromKey(task.status) == TaskStatus.completed,
      };
    }).length;
  }

  int _getCountForCategory(TaskState state, String categoryName) {
    return state.allTasks.where((task) {
      final matchesWorkspace = state.selectedWorkspace.id.isEmpty ||
          state.selectedWorkspace.id == 'ws_default' ||
          task.workspaceId == state.selectedWorkspace.id ||
          task.workspaceId.isEmpty ||
          task.workspaceId == 'ws_default';

      final matchesSpace = state.selectedSpace == null ||
          task.spaceId == state.selectedSpace!.id ||
          task.spaceId.isEmpty;

      final matchesList = state.selectedList == null ||
          task.listId == state.selectedList!.id ||
          task.listId.isEmpty;

      return matchesWorkspace && matchesSpace && matchesList && task.category == categoryName;
    }).length;
  }

  Widget _statusTab({
    required String label,
    required TaskFilterStatus status,
    required TaskFilterStatus current,
    required int count,
    required Color color,
  }) {
    final isSelected = status == current;
    return InkWell(
      onTap: () {
        context.read<TaskCubit>().filterByStatus(status);
      },
      borderRadius: BorderRadius.circular(20.r),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 6.h),
        decoration: BoxDecoration(
          color: isSelected
              ? AppColors.primaryColor
              : AppColors.textFieldBackgroundColor,
          borderRadius: BorderRadius.circular(20.r),
          border: Border.all(
            color: isSelected
                ? AppColors.primaryColor
                : Colors.white.withValues(alpha: 0.08),
            width: 1,
          ),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: AppColors.primaryColor.withValues(alpha: 0.35),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ]
              : null,
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            CircleAvatar(
              radius: 3.5.r,
              backgroundColor: isSelected ? Colors.white : color,
            ),
            SizedBox(width: 6.w),
            Text(
              label,
              style: TextStyle(
                color: isSelected ? Colors.white : AppColors.lightGrey,
                fontSize: 12.sp,
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
              ),
            ),
            SizedBox(width: 6.w),
            Container(
              padding: EdgeInsets.symmetric(horizontal: 6.w, vertical: 1.5.h),
              decoration: BoxDecoration(
                color: isSelected
                    ? Colors.white.withValues(alpha: 0.25)
                    : AppColors.darkBlue,
                borderRadius: BorderRadius.circular(10.r),
              ),
              child: Text(
                count.toString(),
                style: TextStyle(
                  color: isSelected ? Colors.white : AppColors.lightGrey,
                  fontSize: 10.sp,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _categoryTab({
    required String name,
    required bool isSelected,
    required int count,
  }) {
    return InkWell(
      onTap: () {
        context.read<TaskCubit>().filterByCategory(name);
      },
      borderRadius: BorderRadius.circular(20.r),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 6.h),
        decoration: BoxDecoration(
          color: isSelected
              ? AppColors.primaryColor.withValues(alpha: 0.8)
              : AppColors.textFieldBackgroundColor,
          borderRadius: BorderRadius.circular(20.r),
          border: Border.all(
            color: isSelected
                ? AppColors.primaryColor
                : Colors.white.withValues(alpha: 0.08),
            width: 1,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Iconsax.tag, size: 12, color: AppColors.lightGrey),
            SizedBox(width: 5.w),
            Text(
              name,
              style: TextStyle(
                color: isSelected ? Colors.white : AppColors.lightGrey,
                fontSize: 12.sp,
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
              ),
            ),
            SizedBox(width: 5.w),
            Container(
              padding: EdgeInsets.symmetric(horizontal: 5.w, vertical: 1.h),
              decoration: BoxDecoration(
                color: isSelected
                    ? Colors.white.withValues(alpha: 0.2)
                    : AppColors.darkBlue,
                borderRadius: BorderRadius.circular(8.r),
              ),
              child: Text(
                count.toString(),
                style: TextStyle(
                  color: isSelected ? Colors.white : AppColors.lightGrey,
                  fontSize: 10.sp,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildScrollableTabBar(TaskState state) {
    return Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 960),
        child: SizedBox(
          height: 42.h,
          child: ListView(
            controller: _tabScrollController,
            scrollDirection: Axis.horizontal,
            physics: const BouncingScrollPhysics(),
            padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 2.h),
            children: [
              _statusTab(
                label: 'All',
                status: TaskFilterStatus.all,
                current: state.filterStatus,
                count: _getCountForStatus(state, TaskFilterStatus.all),
                color: Colors.white70,
              ),
              SizedBox(width: 8.w),
              _statusTab(
                label: 'Started / Pending',
                status: TaskFilterStatus.pending,
                current: state.filterStatus,
                count: _getCountForStatus(state, TaskFilterStatus.pending),
                color: Colors.blueAccent,
              ),
              SizedBox(width: 8.w),
              _statusTab(
                label: 'In Progress / Active',
                status: TaskFilterStatus.inProgress,
                current: state.filterStatus,
                count: _getCountForStatus(state, TaskFilterStatus.inProgress),
                color: Colors.amber,
              ),
              SizedBox(width: 8.w),
              _statusTab(
                label: 'On Hold / Blocked',
                status: TaskFilterStatus.onHold,
                current: state.filterStatus,
                count: _getCountForStatus(state, TaskFilterStatus.onHold),
                color: Colors.deepOrangeAccent,
              ),
              SizedBox(width: 8.w),
              _statusTab(
                label: 'In Review',
                status: TaskFilterStatus.inReview,
                current: state.filterStatus,
                count: _getCountForStatus(state, TaskFilterStatus.inReview),
                color: Colors.purpleAccent,
              ),
              SizedBox(width: 8.w),
              _statusTab(
                label: 'Completed',
                status: TaskFilterStatus.completed,
                current: state.filterStatus,
                count: _getCountForStatus(state, TaskFilterStatus.completed),
                color: Colors.greenAccent,
              ),
              if (state.categories.isNotEmpty) ...[
                Container(
                  width: 1,
                  height: 20.h,
                  margin: EdgeInsets.symmetric(horizontal: 10.w),
                  color: AppColors.dividerColor,
                ),
                ...state.categories.map((cat) {
                  final isSelected = state.selectedCategory == cat.name;
                  return Padding(
                    padding: EdgeInsets.only(right: 8.w),
                    child: _categoryTab(
                      name: cat.name,
                      isSelected: isSelected,
                      count: _getCountForCategory(state, cat.name),
                    ),
                  );
                }),
              ],
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: BlocBuilder<TaskCubit, TaskState>(
          builder: (context, state) {
            return Column(
              children: [
                // Top Navigation & Hierarchy Bar (Constrained on Desktop Web)
                Center(
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 960),
                    child: Padding(
                      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          // Hierarchy Navigator Pill (Workspace > Space > List)
                          Flexible(
                            child: InkWell(
                              onTap: () {
                                showModalBottomSheet(
                                  context: context,
                                  isScrollControlled: true,
                                  backgroundColor: Colors.transparent,
                                  builder: (_) => const HierarchySelectorSheet(),
                                );
                              },
                              borderRadius: BorderRadius.circular(20.r),
                              child: Container(
                                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                                decoration: BoxDecoration(
                                  color: AppColors.textFieldBackgroundColor,
                                  borderRadius: BorderRadius.circular(20.r),
                                  border: Border.all(
                                    color: AppColors.primaryColor.withValues(alpha: 0.3),
                                  ),
                                ),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Icon(state.selectedWorkspace.icon, size: 14, color: AppColors.primaryColor),
                                    const SizedBox(width: 6),
                                    Flexible(
                                      child: Text(
                                        state.selectedSpace != null
                                            ? '${state.selectedWorkspace.name} > ${state.selectedSpace!.name}'
                                            : state.selectedWorkspace.name,
                                        style: TextStyle(
                                          color: Colors.white,
                                          fontSize: 12.sp,
                                          fontWeight: FontWeight.w600,
                                        ),
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ),
                                    const SizedBox(width: 4),
                                    const Icon(Icons.keyboard_arrow_down, size: 16, color: AppColors.lightGrey),
                                  ],
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(width: 8),

                          // Actions: View Switcher (List vs Board) & Profile
                          Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Container(
                                decoration: BoxDecoration(
                                  color: AppColors.textFieldBackgroundColor,
                                  borderRadius: BorderRadius.circular(8.r),
                                ),
                                child: IconButton(
                                  iconSize: 18,
                                  tooltip: state.viewMode == TaskViewMode.list
                                      ? 'Switch to Kanban Board View'
                                      : 'Switch to List View',
                                  icon: Icon(
                                    state.viewMode == TaskViewMode.list ? Iconsax.kanban : Iconsax.row_vertical,
                                    color: AppColors.primaryColor,
                                  ),
                                  onPressed: () => context.read<TaskCubit>().toggleViewMode(),
                                ),
                              ),
                              SizedBox(width: 8.w),
                              InkWell(
                                onTap: () {
                                  try {
                                    context.read<NavigationCubit>().navigateTo(3);
                                  } catch (_) {}
                                },
                                borderRadius: BorderRadius.circular(20.r),
                                child: CircleAvatar(
                                  backgroundColor: AppColors.primaryColor,
                                  radius: 15.r,
                                  child: const Icon(Iconsax.user, color: Colors.white, size: 16),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                ),

                // Search Bar or Title Bar (Constrained on Desktop Web)
                Center(
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 960),
                    child: Padding(
                      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 4.h),
                      child: _isSearching
                          ? TextField(
                              controller: _searchController,
                              autofocus: true,
                              style: const TextStyle(color: Colors.white),
                              decoration: InputDecoration(
                                hintText: 'Search tasks...',
                                hintStyle: const TextStyle(color: AppColors.lightGrey),
                                filled: true,
                                fillColor: AppColors.textFieldBackgroundColor,
                                prefixIcon: const Icon(Iconsax.search_normal, color: AppColors.lightGrey),
                                suffixIcon: IconButton(
                                  icon: const Icon(Icons.close, color: AppColors.lightGrey),
                                  onPressed: () {
                                    _searchController.clear();
                                    context.read<TaskCubit>().searchTasks('');
                                    setState(() => _isSearching = false);
                                  },
                                ),
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(10.r),
                                  borderSide: BorderSide.none,
                                ),
                              ),
                              onChanged: (val) {
                                context.read<TaskCubit>().searchTasks(val);
                              },
                            )
                          : Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  state.viewMode == TaskViewMode.list ? 'Tasks List' : 'Board View (Kanban)',
                                  style: AppTextThemes.font20WhiteRegularWithStyle,
                                ),
                                Row(
                                  children: [
                                    IconButton(
                                      onPressed: () => setState(() => _isSearching = true),
                                      icon: const Icon(Iconsax.search_normal, color: Colors.white),
                                    ),
                                    IconButton(
                                      onPressed: _showSortDialog,
                                      icon: const Icon(Iconsax.sort, color: Colors.white),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                    ),
                  ),
                ),

                // Real-time Collaboration Notification Pill
                if (state.latestEvent != null)
                  Center(
                    child: ConstrainedBox(
                      constraints: const BoxConstraints(maxWidth: 960),
                      child: Container(
                        margin: EdgeInsets.symmetric(horizontal: 16.w, vertical: 4.h),
                        padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 6.h),
                        decoration: BoxDecoration(
                          color: AppColors.primaryColor.withValues(alpha: 0.15),
                          borderRadius: BorderRadius.circular(8.r),
                          border: Border.all(color: AppColors.primaryColor.withValues(alpha: 0.3)),
                        ),
                        child: Row(
                          children: [
                            const Icon(Icons.circle, size: 8, color: Colors.greenAccent),
                            SizedBox(width: 8.w),
                            Expanded(
                              child: Text(
                                state.latestEvent!.message,
                                style: TextStyle(color: Colors.white70, fontSize: 11.sp),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                            SizedBox(width: 4.w),
                            Text('Live', style: TextStyle(color: Colors.greenAccent, fontSize: 10.sp, fontWeight: FontWeight.bold)),
                          ],
                        ),
                      ),
                    ),
                  ),

                // Horizontally Scrollable Status TabBar with Real-time Count Badges
                _buildScrollableTabBar(state),

                SizedBox(height: 6.h),

                // Content: Either Kanban Board View or List View
                Expanded(
                  child: state.isLoading
                      ? const Center(child: CircularProgressIndicator())
                      : state.viewMode == TaskViewMode.board
                          ? const BoardView()
                          : _buildListView(state),
                ),
              ],
            );
          },
        ),
      ),
    );
  }

  Widget _buildListView(TaskState state) {
    if (state.filteredTasks.isEmpty) {
      return Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 500),
          child: SingleChildScrollView(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                SvgPicture.asset(
                  AppImages.noTasks,
                  height: 180.h,
                ),
                SizedBox(height: 20.h),
                const Text(
                  'What do you want to do today?',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                SizedBox(height: 8.h),
                const Text(
                  'Tap + below to add your tasks',
                  style: TextStyle(fontSize: 14, color: AppColors.lightGrey),
                ),
              ],
            ),
          ),
        ),
      );
    }

    return Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 960),
        child: ListView.builder(
          controller: _listScrollController,
          physics: const AlwaysScrollableScrollPhysics(parent: BouncingScrollPhysics()),
          padding: EdgeInsets.only(left: 16.w, right: 16.w, bottom: 80.h),
          itemCount: state.filteredTasks.length,
          itemBuilder: (context, index) {
            final task = state.filteredTasks[index];
            return _buildTaskItem(task, context);
          },
        ),
      ),
    );
  }

  Widget _buildTaskItem(TaskModel task, BuildContext context) {
    final priorityColor = switch (task.priority) {
      4 => Colors.red,
      3 => Colors.orange,
      2 => Colors.amber,
      _ => Colors.green,
    };

    final priorityLabel = switch (task.priority) {
      4 => 'Urgent',
      3 => 'High',
      2 => 'Medium',
      _ => 'Low',
    };

    final statusColor = switch (task.status) {
      'in_progress' || 'active' => Colors.amber,
      'on_hold' || 'blocked' => Colors.deepOrangeAccent,
      'in_review' => Colors.purpleAccent,
      'completed' || 'done' => Colors.greenAccent,
      _ => Colors.blueAccent,
    };
    final statusText = TaskStatus.getLabel(task.status);

    return Dismissible(
      key: Key(task.id),
      direction: DismissDirection.endToStart,
      background: Container(
        margin: EdgeInsets.symmetric(vertical: 6.h),
        padding: EdgeInsets.symmetric(horizontal: 20.w),
        decoration: BoxDecoration(
          color: AppColors.error,
          borderRadius: BorderRadius.circular(10.r),
        ),
        alignment: Alignment.centerRight,
        child: const Icon(Iconsax.trash, color: Colors.white),
      ),
      onDismissed: (_) {
        context.read<TaskCubit>().deleteTask(task.id);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Task "${task.title}" deleted'),
            action: SnackBarAction(
              label: 'Undo',
              textColor: AppColors.primaryColor,
              onPressed: () {
                context.read<TaskCubit>().addTask(task);
              },
            ),
          ),
        );
      },
      child: Container(
        margin: EdgeInsets.symmetric(vertical: 6.h),
        decoration: BoxDecoration(
          color: AppColors.textFieldBackgroundColor,
          borderRadius: BorderRadius.circular(10.r),
          border: Border.all(
            color: task.isCompleted
                ? Colors.transparent
                : AppColors.primaryColor.withValues(alpha: 0.2),
          ),
        ),
        child: InkWell(
          onTap: () {
            Navigator.pushNamed(context, Routes.editTaskView, arguments: task);
          },
          borderRadius: BorderRadius.circular(10.r),
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 12.h),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                // Completion Checkbox
                InkWell(
                  onTap: () {
                    context.read<TaskCubit>().toggleTaskCompletion(task.id);
                  },
                  customBorder: const CircleBorder(),
                  child: Container(
                    width: 24.w,
                    height: 24.h,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: task.isCompleted
                            ? AppColors.primaryColor
                            : AppColors.lightGrey,
                        width: 1.5,
                      ),
                      color: task.isCompleted
                          ? AppColors.primaryColor
                          : Colors.transparent,
                    ),
                    child: task.isCompleted
                        ? const Icon(Icons.check, size: 16, color: Colors.white)
                        : null,
                  ),
                ),
                SizedBox(width: 14.w),

                // Task details
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        task.title,
                        style: TextStyle(
                          color: task.isCompleted ? AppColors.lightGrey : Colors.white,
                          fontSize: 16.sp,
                          fontWeight: FontWeight.w600,
                          decoration: task.isCompleted ? TextDecoration.lineThrough : null,
                        ),
                      ),
                      if (task.description.isNotEmpty) ...[
                        SizedBox(height: 4.h),
                        Text(
                          task.description,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            color: AppColors.lightGrey,
                            fontSize: 13.sp,
                            decoration: task.isCompleted ? TextDecoration.lineThrough : null,
                          ),
                        ),
                      ],
                      SizedBox(height: 8.h),

                      // Horizontally Scrollable Status & Metadata Badges Row
                      SingleChildScrollView(
                        scrollDirection: Axis.horizontal,
                        physics: const BouncingScrollPhysics(),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            // 1. Status badge card
                            Container(
                              padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 3.h),
                              decoration: BoxDecoration(
                                color: statusColor.withValues(alpha: 0.15),
                                borderRadius: BorderRadius.circular(6.r),
                                border: Border.all(color: statusColor.withValues(alpha: 0.4), width: 0.8),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  CircleAvatar(backgroundColor: statusColor, radius: 3.r),
                                  SizedBox(width: 5.w),
                                  Text(
                                    statusText,
                                    style: TextStyle(
                                      color: statusColor,
                                      fontSize: 11.sp,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            SizedBox(width: 6.w),

                            // 2. Category badge
                            Container(
                              padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 3.h),
                              decoration: BoxDecoration(
                                color: AppColors.primaryColor.withValues(alpha: 0.15),
                                borderRadius: BorderRadius.circular(6.r),
                                border: Border.all(color: AppColors.primaryColor.withValues(alpha: 0.3), width: 0.8),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  const Icon(Iconsax.tag, size: 11, color: AppColors.primaryColor),
                                  SizedBox(width: 4.w),
                                  Text(
                                    task.category,
                                    style: TextStyle(
                                      color: AppColors.primaryColor,
                                      fontSize: 11.sp,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            SizedBox(width: 6.w),

                            // 3. Priority badge
                            Container(
                              padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 3.h),
                              decoration: BoxDecoration(
                                color: priorityColor.withValues(alpha: 0.12),
                                borderRadius: BorderRadius.circular(6.r),
                                border: Border.all(color: priorityColor.withValues(alpha: 0.3), width: 0.8),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(Iconsax.flag, size: 11, color: priorityColor),
                                  SizedBox(width: 3.w),
                                  Text(
                                    priorityLabel,
                                    style: TextStyle(
                                      color: priorityColor,
                                      fontSize: 11.sp,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            SizedBox(width: 6.w),

                            // 4. Due Date badge
                            if (task.dueDate != null) ...[
                              Container(
                                padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 3.h),
                                decoration: BoxDecoration(
                                  color: AppColors.darkBlue,
                                  borderRadius: BorderRadius.circular(6.r),
                                  border: Border.all(color: Colors.white.withValues(alpha: 0.08), width: 0.8),
                                ),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    const Icon(Iconsax.calendar_1, size: 11, color: AppColors.lightGrey),
                                    SizedBox(width: 4.w),
                                    Text(
                                      task.dueTime != null
                                          ? '${DateFormat('MMM dd').format(task.dueDate!)}, ${task.dueTime}'
                                          : DateFormat('MMM dd').format(task.dueDate!),
                                      style: TextStyle(color: AppColors.lightGrey, fontSize: 11.sp),
                                    ),
                                  ],
                                ),
                              ),
                              SizedBox(width: 6.w),
                            ],

                            // 5. Subtasks count badge
                            if (task.subtasks.isNotEmpty) ...[
                              Container(
                                padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 3.h),
                                decoration: BoxDecoration(
                                  color: AppColors.darkBlue,
                                  borderRadius: BorderRadius.circular(6.r),
                                  border: Border.all(color: Colors.white.withValues(alpha: 0.08), width: 0.8),
                                ),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    const Icon(Iconsax.task, size: 11, color: AppColors.lightGrey),
                                    SizedBox(width: 4.w),
                                    Text(
                                      '${task.subtasks.where((s) => s.isCompleted).length}/${task.subtasks.length}',
                                      style: TextStyle(color: AppColors.lightGrey, fontSize: 11.sp),
                                    ),
                                  ],
                                ),
                              ),
                              SizedBox(width: 6.w),
                            ],

                            // 6. Comments badge
                            if (task.comments.isNotEmpty) ...[
                              Container(
                                padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 3.h),
                                decoration: BoxDecoration(
                                  color: AppColors.darkBlue,
                                  borderRadius: BorderRadius.circular(6.r),
                                  border: Border.all(color: Colors.white.withValues(alpha: 0.08), width: 0.8),
                                ),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    const Icon(Iconsax.message, size: 11, color: AppColors.lightGrey),
                                    SizedBox(width: 4.w),
                                    Text(
                                      '${task.comments.length}',
                                      style: TextStyle(color: AppColors.lightGrey, fontSize: 11.sp),
                                    ),
                                  ],
                                ),
                              ),
                              SizedBox(width: 6.w),
                            ],

                            // 7. Assignee badge
                            if (task.assignedTo != null && task.assignedTo!.isNotEmpty)
                              Container(
                                padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 3.h),
                                decoration: BoxDecoration(
                                  color: AppColors.primaryColor.withValues(alpha: 0.12),
                                  borderRadius: BorderRadius.circular(6.r),
                                  border: Border.all(color: AppColors.primaryColor.withValues(alpha: 0.3), width: 0.8),
                                ),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    const Icon(Iconsax.user, size: 11, color: AppColors.primaryColor),
                                    SizedBox(width: 4.w),
                                    Text(
                                      task.assignedTo!,
                                      style: TextStyle(color: AppColors.primaryColor, fontSize: 11.sp),
                                    ),
                                  ],
                                ),
                              ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
