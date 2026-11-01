import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:iconsax/iconsax.dart';
import 'package:intl/intl.dart';
import 'package:task_manager_app/core/constants/app_colors.dart';
import 'package:task_manager_app/core/routes/routes.dart';
import 'package:task_manager_app/core/utils/responsive.dart';
import 'package:task_manager_app/features/home/presentation/widgets/add_note_bottom_sheet.dart';
import 'package:task_manager_app/features/task/data/models/task_model.dart';
import 'package:task_manager_app/features/task/presentation/manager/task_cubit.dart';
import 'package:task_manager_app/features/task/presentation/manager/task_state.dart';

class BoardView extends StatefulWidget {
  const BoardView({super.key});

  @override
  State<BoardView> createState() => _BoardViewState();
}

class _BoardViewState extends State<BoardView> {
  final _boardScrollController = ScrollController();

  @override
  void dispose() {
    _boardScrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<TaskCubit, TaskState>(
      builder: (context, state) {
        final pendingTasks = state.filteredTasks
            .where((t) =>
                t.status == 'pending' ||
                t.status == 'started' ||
                t.status == 'todo' ||
                (!t.isCompleted &&
                    t.status != 'in_progress' &&
                    t.status != 'active' &&
                    t.status != 'on_hold' &&
                    t.status != 'blocked' &&
                    t.status != 'in_review' &&
                    t.status != 'completed' &&
                    t.status != 'done'))
            .toList();

        final inProgressTasks = state.filteredTasks
            .where((t) => t.status == 'in_progress' || t.status == 'active')
            .toList();

        final onHoldTasks = state.filteredTasks
            .where((t) => t.status == 'on_hold' || t.status == 'blocked')
            .toList();

        final inReviewTasks = state.filteredTasks
            .where((t) => t.status == 'in_review')
            .toList();

        final completedTasks = state.filteredTasks
            .where((t) => t.status == 'completed' || t.status == 'done' || t.isCompleted)
            .toList();

        return Scrollbar(
          controller: _boardScrollController,
          thumbVisibility: true,
          child: ListView(
            controller: _boardScrollController,
            scrollDirection: Axis.horizontal,
            physics: const AlwaysScrollableScrollPhysics(parent: BouncingScrollPhysics()),
            padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
            children: [
              _buildKanbanColumn(
                context: context,
                title: 'Started / Pending',
                statusKey: 'pending',
                color: Colors.blueAccent,
                tasks: pendingTasks,
              ),
              _buildKanbanColumn(
                context: context,
                title: 'In Progress / Active',
                statusKey: 'in_progress',
                color: Colors.amber,
                tasks: inProgressTasks,
              ),
              _buildKanbanColumn(
                context: context,
                title: 'On Hold / Blocked',
                statusKey: 'on_hold',
                color: Colors.deepOrangeAccent,
                tasks: onHoldTasks,
              ),
              _buildKanbanColumn(
                context: context,
                title: 'In Review',
                statusKey: 'in_review',
                color: Colors.purpleAccent,
                tasks: inReviewTasks,
              ),
              _buildKanbanColumn(
                context: context,
                title: 'Completed',
                statusKey: 'completed',
                color: Colors.greenAccent,
                tasks: completedTasks,
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildKanbanColumn({
    required BuildContext context,
    required String title,
    required String statusKey,
    required Color color,
    required List<TaskModel> tasks,
  }) {
    final isDesktop = Responsive.isDesktop(context);
    final isTablet = Responsive.isTablet(context);
    final isMobile = Responsive.isMobile(context);
    final columnWidth = isDesktop ? 320.0 : (isTablet ? 290.0 : 270.w);
    final bottomMargin = isMobile ? 70.h : 20.h;

    return DragTarget<TaskModel>(
      onWillAcceptWithDetails: (details) => details.data.status != statusKey,
      onAcceptWithDetails: (details) {
        context.read<TaskCubit>().updateTaskStatus(details.data.id, statusKey);
      },
      builder: (context, candidateData, rejectedData) {
        final isHovered = candidateData.isNotEmpty;

        return Container(
          width: columnWidth,
          margin: EdgeInsets.only(right: 14.w, bottom: bottomMargin),
          decoration: BoxDecoration(
            color: isHovered
                ? color.withValues(alpha: 0.12)
                : AppColors.textFieldBackgroundColor,
            borderRadius: BorderRadius.circular(14.r),
            border: Border.all(
              color: isHovered ? color : Colors.transparent,
              width: 1.5,
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Column Header
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 12.h),
                child: Row(
                  children: [
                    CircleAvatar(backgroundColor: color, radius: 5.r),
                    SizedBox(width: 8.w),
                    Flexible(
                      child: Text(
                        title,
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 14.sp,
                          fontWeight: FontWeight.bold,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    SizedBox(width: 8.w),
                    Container(
                      padding: EdgeInsets.symmetric(horizontal: 7.w, vertical: 2.h),
                      decoration: BoxDecoration(
                        color: color.withValues(alpha: 0.2),
                        borderRadius: BorderRadius.circular(10.r),
                      ),
                      child: Text(
                        tasks.length.toString(),
                        style: TextStyle(
                          color: color,
                          fontSize: 11.sp,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    const Spacer(),
                    IconButton(
                      icon: const Icon(Icons.add, color: AppColors.lightGrey, size: 20),
                      padding: EdgeInsets.zero,
                      constraints: const BoxConstraints(),
                      tooltip: 'Add $title Task',
                      onPressed: () {
                        showModalBottomSheet(
                          isScrollControlled: true,
                          backgroundColor: Colors.transparent,
                          context: context,
                          builder: (context) => const AddTaskBottomSheet(),
                        );
                      },
                    ),
                  ],
                ),
              ),

              const Divider(color: AppColors.darkBlue, height: 1, thickness: 1),

              // Task Cards in Column
              Expanded(
                child: tasks.isEmpty
                    ? Center(
                        child: Padding(
                          padding: EdgeInsets.symmetric(horizontal: 16.w),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Iconsax.folder_open, size: 36.sp, color: AppColors.lightGrey.withValues(alpha: 0.4)),
                              SizedBox(height: 8.h),
                              Text(
                                isHovered ? 'Drop here to move' : 'No tasks in $title',
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  color: isHovered ? color : AppColors.lightGrey,
                                  fontSize: 12.sp,
                                ),
                              ),
                            ],
                          ),
                        ),
                      )
                    : ListView.builder(
                        physics: const AlwaysScrollableScrollPhysics(parent: BouncingScrollPhysics()),
                        padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 8.h),
                        itemCount: tasks.length,
                        itemBuilder: (context, index) {
                          final task = tasks[index];
                          return _buildDraggableCard(task, context, columnWidth - 24);
                        },
                      ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildDraggableCard(TaskModel task, BuildContext context, double cardWidth) {
    final isMobile = Responsive.isMobile(context);

    final feedbackWidget = Material(
      color: Colors.transparent,
      child: SizedBox(
        width: cardWidth,
        child: Transform.rotate(
          angle: 0.04,
          child: Opacity(
            opacity: 0.92,
            child: _buildCardContent(task, isDragging: true),
          ),
        ),
      ),
    );

    final childContent = InkWell(
      onTap: () {
        Navigator.pushNamed(context, Routes.editTaskView, arguments: task);
      },
      borderRadius: BorderRadius.circular(10.r),
      child: _buildCardContent(task),
    );

    final childWhenDragging = Opacity(
      opacity: 0.35,
      child: _buildCardContent(task),
    );

    if (isMobile) {
      return LongPressDraggable<TaskModel>(
        data: task,
        feedback: feedbackWidget,
        childWhenDragging: childWhenDragging,
        child: childContent,
      );
    } else {
      return Draggable<TaskModel>(
        data: task,
        feedback: feedbackWidget,
        childWhenDragging: childWhenDragging,
        child: childContent,
      );
    }
  }

  Widget _buildCardContent(TaskModel task, {bool isDragging = false}) {
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

    return Container(
      margin: EdgeInsets.only(bottom: 8.h),
      padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 10.h),
      decoration: BoxDecoration(
        color: AppColors.darkBlue,
        borderRadius: BorderRadius.circular(10.r),
        boxShadow: isDragging
            ? [BoxShadow(color: AppColors.primaryColor.withValues(alpha: 0.4), blurRadius: 10, spreadRadius: 2)]
            : null,
        border: Border.all(
          color: isDragging
              ? AppColors.primaryColor
              : Colors.white.withValues(alpha: 0.06),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header: Category & Priority
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                padding: EdgeInsets.symmetric(horizontal: 6.w, vertical: 2.h),
                decoration: BoxDecoration(
                  color: AppColors.primaryColor.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(4.r),
                ),
                child: Text(
                  task.category,
                  style: TextStyle(
                    color: AppColors.primaryColor,
                    fontSize: 10.sp,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              Row(
                children: [
                  Icon(Iconsax.flag, size: 12, color: priorityColor),
                  SizedBox(width: 3.w),
                  Text(
                    priorityLabel,
                    style: TextStyle(
                      color: priorityColor,
                      fontSize: 10.sp,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ],
          ),
          SizedBox(height: 6.h),

          // Title
          Text(
            task.title,
            style: TextStyle(
              color: Colors.white,
              fontSize: 14.sp,
              fontWeight: FontWeight.w600,
              decoration: task.isCompleted ? TextDecoration.lineThrough : null,
            ),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),

          if (task.description.isNotEmpty) ...[
            SizedBox(height: 4.h),
            Text(
              task.description,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(color: AppColors.lightGrey, fontSize: 11.sp),
            ),
          ],

          SizedBox(height: 8.h),

          // Footer: Due Date, Subtasks, Comments, Assignee - Scrollable Row
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            physics: const BouncingScrollPhysics(),
            child: Row(
              children: [
                if (task.dueDate != null) ...[
                  Builder(
                    builder: (_) {
                      final now = DateTime.now();
                      final isOverdue = !task.isCompleted && now.isAfter(task.dueDate!);
                      final isDeadlineMet = task.isCompleted;
                      final deadlineColor = isDeadlineMet
                          ? const Color(0xFF22C55E) // Green: deadline met
                          : (isOverdue
                              ? const Color(0xFFEF4444) // Red: deadline surpassed
                              : AppColors.lightGrey);
                      return Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            isDeadlineMet
                                ? Icons.check_circle_outline_rounded
                                : (isOverdue ? Icons.warning_amber_rounded : Iconsax.calendar_1),
                            size: 12,
                            color: deadlineColor,
                          ),
                          SizedBox(width: 4.w),
                          Text(
                            DateFormat('MMM d').format(task.dueDate!),
                            style: TextStyle(
                              color: deadlineColor,
                              fontSize: 10.sp,
                              fontWeight: isOverdue || isDeadlineMet ? FontWeight.bold : FontWeight.normal,
                            ),
                          ),
                        ],
                      );
                    },
                  ),
                  SizedBox(width: 8.w),
                ],
                if (task.subtasks.isNotEmpty) ...[
                  const Icon(Iconsax.task, size: 12, color: AppColors.lightGrey),
                  SizedBox(width: 2.w),
                  Text(
                    '${task.subtasks.where((s) => s.isCompleted).length}/${task.subtasks.length}',
                    style: TextStyle(color: AppColors.lightGrey, fontSize: 10.sp),
                  ),
                  SizedBox(width: 8.w),
                ],
                if (task.comments.isNotEmpty) ...[
                  const Icon(Iconsax.message, size: 12, color: AppColors.lightGrey),
                  SizedBox(width: 2.w),
                  Text(
                    task.comments.length.toString(),
                    style: TextStyle(color: AppColors.lightGrey, fontSize: 10.sp),
                  ),
                  SizedBox(width: 8.w),
                ],
                if (task.assignedTo != null && task.assignedTo!.isNotEmpty) ...[
                  CircleAvatar(
                    radius: 9.r,
                    backgroundColor: AppColors.primaryColor,
                    child: Text(
                      task.assignedTo![0].toUpperCase(),
                      style: TextStyle(color: Colors.white, fontSize: 9.sp, fontWeight: FontWeight.bold),
                    ),
                  ),
                  SizedBox(width: 4.w),
                  Text(
                    task.assignedTo!,
                    style: TextStyle(color: AppColors.primaryColor, fontSize: 10.sp),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}
