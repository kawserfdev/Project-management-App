import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:iconsax/iconsax.dart';
import 'package:intl/intl.dart';
import 'package:task_manager_app/core/constants/app_colors.dart';
import 'package:task_manager_app/core/routes/routes.dart';
import 'package:task_manager_app/core/themes/app_text_themes.dart';
import 'package:task_manager_app/features/task/data/models/task_model.dart';
import 'package:task_manager_app/features/task/presentation/manager/task_cubit.dart';
import 'package:task_manager_app/features/task/presentation/manager/task_state.dart';

class CalenderView extends StatefulWidget {
  const CalenderView({super.key, this.user});
  final dynamic user;

  @override
  State<CalenderView> createState() => _CalenderViewState();
}

class _CalenderViewState extends State<CalenderView> {
  DateTime _selectedDate = DateTime.now();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 960),
            child: Column(
              children: [
            // Header
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 12.h),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Calendar',
                    style: AppTextThemes.font20WhiteRegularWithStyle,
                  ),
                  TextButton.icon(
                    style: TextButton.styleFrom(
                      foregroundColor: AppColors.primaryColor,
                      backgroundColor: AppColors.textFieldBackgroundColor,
                      padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 6.h),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8.r)),
                    ),
                    icon: const Icon(Iconsax.calendar_tick, size: 16),
                    label: const Text('Today'),
                    onPressed: () {
                      setState(() => _selectedDate = DateTime.now());
                    },
                  ),
                ],
              ),
            ),

            // Date picker strip
            _buildDateStrip(),

            SizedBox(height: 12.h),

            // Tasks header for selected day
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 8.h),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      DateFormat('EEEE, MMMM d').format(_selectedDate),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 16.sp,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  SizedBox(width: 8.w),
                  BlocBuilder<TaskCubit, TaskState>(
                    builder: (context, state) {
                      final tasksForDay = _getTasksForSelectedDate(state.allTasks);
                      final completedCount = tasksForDay.where((t) => t.isCompleted).length;
                      return Text(
                        '$completedCount/${tasksForDay.length} completed',
                        style: TextStyle(color: AppColors.lightGrey, fontSize: 13.sp),
                      );
                    },
                  ),
                ],
              ),
            ),

            // Task list for day
            Expanded(
              child: BlocBuilder<TaskCubit, TaskState>(
                builder: (context, state) {
                  final tasksForDay = _getTasksForSelectedDate(state.allTasks);

                  if (tasksForDay.isEmpty) {
                    return Center(
                      child: SingleChildScrollView(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Iconsax.calendar_remove, size: 56.sp, color: AppColors.lightGrey),
                            SizedBox(height: 10.h),
                            Text(
                              'No tasks scheduled for this day',
                              style: TextStyle(color: Colors.white, fontSize: 16.sp),
                            ),
                            SizedBox(height: 6.h),
                            Text(
                              'Tap + to create a task for ${DateFormat('MMM dd').format(_selectedDate)}',
                              style: TextStyle(color: AppColors.lightGrey, fontSize: 13.sp),
                            ),
                          ],
                        ),
                      ),
                    );
                  }

                  return ListView.builder(
                    padding: EdgeInsets.only(left: 16.w, right: 16.w, bottom: 80.h),
                    itemCount: tasksForDay.length,
                    itemBuilder: (context, index) {
                      final task = tasksForDay[index];
                      return _buildCalendarTaskItem(task, context);
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    ),
  ),
);
  }

  List<TaskModel> _getTasksForSelectedDate(List<TaskModel> allTasks) {
    return allTasks.where((task) {
      if (task.dueDate == null) return false;
      return task.dueDate!.year == _selectedDate.year &&
          task.dueDate!.month == _selectedDate.month &&
          task.dueDate!.day == _selectedDate.day;
    }).toList();
  }

  Widget _buildDateStrip() {
    // Show 14 days around selected date (-3 to +10)
    final startDate = _selectedDate.subtract(const Duration(days: 3));

    return SizedBox(
      height: 90.h,
      child: Material(
        color: AppColors.textFieldBackgroundColor.withValues(alpha: 0.5),
        child: ListView.builder(
          scrollDirection: Axis.horizontal,
          padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 6.h),
          itemCount: 21,
          itemBuilder: (context, index) {
            final date = startDate.add(Duration(days: index));
            final isSelected = date.year == _selectedDate.year &&
                date.month == _selectedDate.month &&
                date.day == _selectedDate.day;
            final isToday = date.year == DateTime.now().year &&
                date.month == DateTime.now().month &&
                date.day == DateTime.now().day;

            return InkWell(
              onTap: () => setState(() => _selectedDate = date),
              borderRadius: BorderRadius.circular(10.r),
              child: Container(
                width: 56.w,
                margin: EdgeInsets.symmetric(horizontal: 4.w),
                padding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 4.h),
                decoration: BoxDecoration(
                  color: isSelected
                      ? AppColors.primaryColor
                      : (isToday ? AppColors.textFieldBackgroundColor : Colors.transparent),
                  borderRadius: BorderRadius.circular(10.r),
                  border: Border.all(
                    color: isSelected
                        ? AppColors.primaryColor
                        : (isToday ? AppColors.primaryColor.withValues(alpha: 0.5) : Colors.transparent),
                  ),
                ),
                child: FittedBox(
                  fit: BoxFit.scaleDown,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        DateFormat('E').format(date).toUpperCase(),
                        style: TextStyle(
                          color: isSelected ? Colors.white : AppColors.lightGrey,
                          fontSize: 11.sp,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      SizedBox(height: 2.h),
                      Text(
                        date.day.toString(),
                        style: TextStyle(
                          color: isSelected ? Colors.white : Colors.white70,
                          fontSize: 16.sp,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildCalendarTaskItem(TaskModel task, BuildContext context) {
    return Container(
      margin: EdgeInsets.symmetric(vertical: 6.h),
      child: Material(
        color: AppColors.textFieldBackgroundColor,
        borderRadius: BorderRadius.circular(10.r),
        child: ListTile(
          onTap: () {
            Navigator.pushNamed(context, Routes.editTaskView, arguments: task);
          },
          leading: Checkbox(
            value: task.isCompleted,
            activeColor: AppColors.primaryColor,
            onChanged: (_) {
              context.read<TaskCubit>().toggleTaskCompletion(task.id);
            },
          ),
          title: Text(
            task.title,
            style: TextStyle(
              color: task.isCompleted ? AppColors.lightGrey : Colors.white,
              decoration: task.isCompleted ? TextDecoration.lineThrough : null,
              fontWeight: FontWeight.w600,
            ),
          ),
          subtitle: Text(
            task.dueTime != null ? '${task.category} • ${task.dueTime}' : task.category,
            style: TextStyle(color: AppColors.lightGrey, fontSize: 12.sp),
          ),
          trailing: Container(
            width: 8.w,
            height: 8.h,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: task.priority == 3
                  ? Colors.redAccent
                  : task.priority == 2
                      ? Colors.orange
                      : Colors.green,
            ),
          ),
        ),
      ),
    );
  }
}
