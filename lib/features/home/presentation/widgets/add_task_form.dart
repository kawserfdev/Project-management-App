import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:iconsax/iconsax.dart';
import 'package:intl/intl.dart';
import 'package:task_manager_app/core/constants/app_colors.dart';
import 'package:task_manager_app/core/helpers/spacing.dart';
import 'package:task_manager_app/core/routes/routes.dart';
import 'package:task_manager_app/core/themes/app_text_themes.dart';
import 'package:task_manager_app/features/task/data/models/category_model.dart';
import 'package:task_manager_app/features/task/data/models/task_model.dart';
import 'package:task_manager_app/features/task/presentation/manager/task_cubit.dart';
import 'package:task_manager_app/features/task/presentation/manager/task_state.dart';
import 'package:task_manager_app/features/task/presentation/widgets/assignee_picker_dialog.dart';

class AddTaskForm extends StatefulWidget {
  const AddTaskForm({super.key});

  @override
  State<AddTaskForm> createState() => _AddTaskFormState();
}

class _AddTaskFormState extends State<AddTaskForm> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();

  DateTime? _selectedDate;
  String? _selectedTime;
  String _selectedCategory = 'Work';
  int _selectedPriority = 2; // Default Medium
  String _selectedStatus = 'pending'; // Default Started / Pending
  String? _selectedAssignee;

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  void _submitTask() {
    final title = _titleController.text.trim();
    if (title.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter task title')),
      );
      return;
    }

    final newTask = TaskModel(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      title: title,
      description: _descriptionController.text.trim(),
      category: _selectedCategory,
      priority: _selectedPriority,
      dueDate: _selectedDate ?? DateTime.now(),
      dueTime: _selectedTime ?? DateFormat('hh:mm a').format(DateTime.now()),
      assignedTo: _selectedAssignee,
      status: _selectedStatus,
      isCompleted: _selectedStatus == 'completed',
      createdAt: DateTime.now(),
    );

    context.read<TaskCubit>().addTask(newTask);
    Navigator.pop(context);
  }

  void _showCategoryDialog() {
    showDialog(
      context: context,
      builder: (ctx) {
        return BlocBuilder<TaskCubit, TaskState>(
          builder: (context, state) {
            return AlertDialog(
              backgroundColor: AppColors.textFieldBackgroundColor,
              title: const Text('Choose Category', style: TextStyle(color: Colors.white)),
              content: SizedBox(
                width: double.maxFinite,
                child: SingleChildScrollView(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Wrap(
                        spacing: 12.w,
                        runSpacing: 12.h,
                        children: state.categories.map((cat) {
                          final isSelected = _selectedCategory == cat.name;
                          return InkWell(
                            onTap: () {
                              setState(() => _selectedCategory = cat.name);
                              Navigator.pop(ctx);
                            },
                            borderRadius: BorderRadius.circular(8.r),
                            child: Container(
                              width: 70.w,
                              padding: EdgeInsets.symmetric(vertical: 8.h),
                              decoration: BoxDecoration(
                                color: isSelected
                                    ? AppColors.primaryColor
                                    : AppColors.darkBlue,
                                borderRadius: BorderRadius.circular(8.r),
                              ),
                              child: Column(
                                children: [
                                  Icon(cat.icon, color: cat.color, size: 24),
                                  SizedBox(height: 4.h),
                                  Text(
                                    cat.name,
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 11.sp,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          );
                        }).toList(),
                      ),
                      SizedBox(height: 16.h),
                      TextButton.icon(
                        icon: const Icon(Icons.add, color: AppColors.primaryColor),
                        label: const Text(
                          'Create New Category',
                          style: TextStyle(color: AppColors.primaryColor),
                        ),
                        onPressed: () async {
                          Navigator.pop(ctx);
                          final created = await Navigator.pushNamed(
                            context,
                            Routes.addTaskCategoryView,
                          );
                          if (created is CategoryModel) {
                            setState(() => _selectedCategory = created.name);
                          }
                        },
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        );
      },
    );
  }

  void _showPriorityDialog() {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppColors.textFieldBackgroundColor,
        title: const Text('Task Priority', style: TextStyle(color: Colors.white)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _priorityOption(4, 'Urgent Priority', Colors.red, ctx),
            _priorityOption(3, 'High Priority', Colors.orange, ctx),
            _priorityOption(2, 'Medium Priority', Colors.amber, ctx),
            _priorityOption(1, 'Low Priority', Colors.green, ctx),
          ],
        ),
      ),
    );
  }

  Widget _priorityOption(int level, String label, Color color, BuildContext ctx) {
    return ListTile(
      leading: Icon(Iconsax.flag, color: color),
      title: Text(label, style: const TextStyle(color: Colors.white)),
      trailing: _selectedPriority == level
          ? const Icon(Icons.check, color: AppColors.primaryColor)
          : null,
      onTap: () {
        setState(() => _selectedPriority = level);
        Navigator.pop(ctx);
      },
    );
  }

  void _showStatusDialog() {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppColors.textFieldBackgroundColor,
        title: const Text('Task Status', style: TextStyle(color: Colors.white)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _statusDialogOption('pending', 'Started / Pending', Colors.blueAccent, ctx),
            _statusDialogOption('in_progress', 'In Progress / Active', Colors.amber, ctx),
            _statusDialogOption('on_hold', 'On Hold / Blocked', Colors.deepOrangeAccent, ctx),
            _statusDialogOption('in_review', 'In Review', Colors.purpleAccent, ctx),
            _statusDialogOption('completed', 'Completed', Colors.greenAccent, ctx),
          ],
        ),
      ),
    );
  }

  Widget _statusDialogOption(String statusKey, String label, Color color, BuildContext ctx) {
    return ListTile(
      leading: CircleAvatar(backgroundColor: color, radius: 6.r),
      title: Text(label, style: const TextStyle(color: Colors.white)),
      trailing: _selectedStatus == statusKey
          ? const Icon(Icons.check, color: AppColors.primaryColor)
          : null,
      onTap: () {
        setState(() => _selectedStatus = statusKey);
        Navigator.pop(ctx);
      },
    );
  }

  Future<void> _showAssigneeDialog() async {
    final selected = await AssigneePickerDialog.show(
      context,
      currentAssignee: _selectedAssignee,
    );
    if (selected != null) {
      setState(() => _selectedAssignee = selected.isEmpty ? null : selected);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(vertical: 20.h, horizontal: 24.w),
      decoration: BoxDecoration(
        color: AppColors.textFieldBackgroundColor,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20.r)),
      ),
      child: Form(
        key: _formKey,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            verticalSpace(8),
            Text(
              'Add Task',
              style: AppTextThemes.font20WhiteRegularWithStyle,
            ),
            verticalSpace(14),
            TextField(
              controller: _titleController,
              autofocus: true,
              style: const TextStyle(color: Colors.white),
              decoration: InputDecoration(
                hintText: 'Enter task title',
                hintStyle: const TextStyle(color: AppColors.lightGrey),
                filled: true,
                fillColor: AppColors.darkBlue,
                contentPadding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 12.h),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8.r),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
            verticalSpace(12),
            TextField(
              controller: _descriptionController,
              maxLines: 2,
              style: const TextStyle(color: Colors.white),
              decoration: InputDecoration(
                hintText: 'Description (optional)',
                hintStyle: const TextStyle(color: AppColors.lightGrey),
                filled: true,
                fillColor: AppColors.darkBlue,
                contentPadding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 12.h),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8.r),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
            verticalSpace(12),

            // Active selections badges
            Wrap(
              spacing: 8.w,
              runSpacing: 6.h,
              children: [
                if (_selectedDate != null)
                  _badgeChip(
                    icon: Iconsax.calendar_1,
                    text: DateFormat('MMM dd').format(_selectedDate!),
                    onDeleted: () => setState(() => _selectedDate = null),
                  ),
                if (_selectedTime != null)
                  _badgeChip(
                    icon: Iconsax.timer_1,
                    text: _selectedTime!,
                    onDeleted: () => setState(() => _selectedTime = null),
                  ),
                _badgeChip(
                  icon: Iconsax.tag,
                  text: _selectedCategory,
                  color: AppColors.primaryColor,
                ),
                _badgeChip(
                  icon: Iconsax.task,
                  text: TaskStatus.getLabel(_selectedStatus),
                  color: switch (_selectedStatus) {
                    'in_progress' => Colors.amber,
                    'on_hold' => Colors.deepOrangeAccent,
                    'in_review' => Colors.purpleAccent,
                    'completed' => Colors.greenAccent,
                    _ => Colors.blueAccent,
                  },
                ),
                _badgeChip(
                  icon: Iconsax.flag,
                  text: switch (_selectedPriority) {
                    4 => 'Urgent',
                    3 => 'High',
                    2 => 'Medium',
                    _ => 'Low',
                  },
                  color: switch (_selectedPriority) {
                    4 => Colors.red,
                    3 => Colors.orange,
                    2 => Colors.amber,
                    _ => Colors.green,
                  },
                ),
                if (_selectedAssignee != null)
                  _badgeChip(
                    icon: Iconsax.user,
                    text: _selectedAssignee!,
                    color: AppColors.primaryColor,
                    onDeleted: () => setState(() => _selectedAssignee = null),
                  ),
              ],
            ),

            verticalSpace(16),
            Row(
              children: [
                Expanded(
                  flex: 6,
                  child: Row(
                    children: [
                      IconButton(
                        tooltip: 'Due Date',
                        onPressed: () async {
                          final now = DateTime.now();
                          final picked = await showDatePicker(
                            context: context,
                            initialDate: _selectedDate ?? now,
                            firstDate: DateTime(now.year - 1),
                            lastDate: DateTime(2050, 12, 31),
                          );
                          if (picked != null) {
                            setState(() => _selectedDate = picked);
                          }
                        },
                        icon: const Icon(Iconsax.calendar_1,
                            color: AppColors.white),
                      ),
                      IconButton(
                        tooltip: 'Due Time',
                        onPressed: () async {
                          final picked = await showTimePicker(
                            context: context,
                            initialTime: TimeOfDay.now(),
                          );
                          if (picked != null) {
                            setState(() => _selectedTime = picked.format(context));
                          }
                        },
                        icon: const Icon(Iconsax.timer_1,
                            color: AppColors.white),
                      ),
                      IconButton(
                        tooltip: 'Category',
                        onPressed: _showCategoryDialog,
                        icon: const Icon(Iconsax.tag,
                            color: AppColors.white),
                      ),
                      IconButton(
                        tooltip: 'Priority',
                        onPressed: _showPriorityDialog,
                        icon: const Icon(Iconsax.flag,
                            color: AppColors.white),
                      ),
                      IconButton(
                        tooltip: 'Status',
                        onPressed: _showStatusDialog,
                        icon: const Icon(Iconsax.task_square,
                            color: AppColors.white),
                      ),
                      IconButton(
                        tooltip: 'Assignee',
                        onPressed: _showAssigneeDialog,
                        icon: const Icon(Iconsax.user,
                            color: AppColors.white),
                      ),
                    ],
                  ),
                ),
                const Spacer(),
                IconButton(
                  tooltip: 'Save Task',
                  onPressed: _submitTask,
                  icon: const Icon(Iconsax.send_14,
                      color: AppColors.primaryColor, size: 28),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _badgeChip({
    required IconData icon,
    required String text,
    Color color = Colors.white70,
    VoidCallback? onDeleted,
  }) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 4.h),
      decoration: BoxDecoration(
        color: AppColors.darkBlue,
        borderRadius: BorderRadius.circular(6.r),
        border: Border.all(color: color.withValues(alpha: 0.4)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 12, color: color),
          const SizedBox(width: 4),
          ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 160),
            child: Text(
              text,
              style: TextStyle(color: color, fontSize: 11.sp),
              overflow: TextOverflow.ellipsis,
            ),
          ),
          if (onDeleted != null) ...[
            SizedBox(width: 4.w),
            GestureDetector(
              onTap: onDeleted,
              child: const Icon(Icons.close, size: 12, color: AppColors.lightGrey),
            ),
          ],
        ],
      ),
    );
  }
}
