import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:iconsax/iconsax.dart';
import 'package:intl/intl.dart';
import 'package:task_manager_app/core/constants/app_colors.dart';
import 'package:task_manager_app/core/themes/app_text_themes.dart';
import 'package:task_manager_app/features/task/data/models/task_model.dart';
import 'package:task_manager_app/features/task/presentation/manager/task_cubit.dart';
import 'package:task_manager_app/features/task/presentation/manager/task_state.dart';
import 'package:task_manager_app/features/task/presentation/widgets/assignee_picker_dialog.dart';

class EditTaskView extends StatefulWidget {
  final TaskModel task;
  const EditTaskView({super.key, required this.task});

  @override
  State<EditTaskView> createState() => _EditTaskViewState();
}

class _EditTaskViewState extends State<EditTaskView> {
  late TextEditingController _titleController;
  late TextEditingController _descController;
  late TextEditingController _assigneeController;
  late String _selectedCategory;
  late int _selectedPriority;
  late String _selectedStatus;
  DateTime? _selectedDate;
  String? _selectedTime;
  late List<SubTask> _subtasks;
  late List<TaskComment> _comments;
  final _subtaskController = TextEditingController();
  final _commentController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController(text: widget.task.title);
    _descController = TextEditingController(text: widget.task.description);
    _assigneeController = TextEditingController(text: widget.task.assignedTo ?? '');
    _selectedCategory = widget.task.category;
    _selectedPriority = widget.task.priority;
    _selectedStatus = TaskStatus.fromKey(widget.task.status).key;
    _selectedDate = widget.task.dueDate;
    _selectedTime = widget.task.dueTime;
    _subtasks = List.from(widget.task.subtasks);
    _comments = List.from(widget.task.comments);
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descController.dispose();
    _assigneeController.dispose();
    _subtaskController.dispose();
    _commentController.dispose();
    super.dispose();
  }

  void _saveTask() {
    final title = _titleController.text.trim();
    if (title.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter task title')),
      );
      return;
    }

    final isDone = _selectedStatus == 'completed' || _selectedStatus == 'done';
    final updated = widget.task.copyWith(
      title: title,
      description: _descController.text.trim(),
      category: _selectedCategory,
      priority: _selectedPriority,
      status: _selectedStatus,
      isCompleted: isDone,
      dueDate: _selectedDate,
      dueTime: _selectedTime,
      subtasks: _subtasks,
      comments: _comments,
      assignedTo: _assigneeController.text.trim().isEmpty ? null : _assigneeController.text.trim(),
    );

    context.read<TaskCubit>().updateTask(updated);
    Navigator.pop(context);
  }

  void _deleteTask() {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppColors.textFieldBackgroundColor,
        title: const Text('Delete Task', style: TextStyle(color: Colors.white)),
        content: const Text(
          'Are you sure you want to delete this task?',
          style: TextStyle(color: AppColors.lightGrey),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel', style: TextStyle(color: AppColors.lightGrey)),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.error),
            onPressed: () {
              Navigator.pop(ctx);
              context.read<TaskCubit>().deleteTask(widget.task.id);
              Navigator.pop(context);
            },
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }

  void _addSubtask() {
    final text = _subtaskController.text.trim();
    if (text.isEmpty) return;
    setState(() {
      _subtasks.add(
        SubTask(
          id: DateTime.now().millisecondsSinceEpoch.toString(),
          title: text,
        ),
      );
      _subtaskController.clear();
    });
  }

  void _addComment() {
    final text = _commentController.text.trim();
    if (text.isEmpty) return;
    setState(() {
      _comments.add(
        TaskComment(
          id: DateTime.now().millisecondsSinceEpoch.toString(),
          author: 'Me',
          message: text,
          createdAt: DateTime.now(),
        ),
      );
      _commentController.clear();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Edit Task', style: AppTextThemes.font20WhiteRegularWithStyle),
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, size: 18),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          IconButton(
            icon: const Icon(Iconsax.trash, color: AppColors.error),
            onPressed: _deleteTask,
          ),
        ],
      ),
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 760),
            child: SingleChildScrollView(
              padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 16.h),
              child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Title Field
              Text('Title', style: AppTextThemes.font16WhiteRegular),
              SizedBox(height: 8.h),
              TextField(
                controller: _titleController,
                style: const TextStyle(color: Colors.white),
                decoration: InputDecoration(
                  filled: true,
                  fillColor: AppColors.textFieldBackgroundColor,
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(8.r)),
                ),
              ),
              SizedBox(height: 16.h),

              // Description Field
              Text('Description', style: AppTextThemes.font16WhiteRegular),
              SizedBox(height: 8.h),
              TextField(
                controller: _descController,
                maxLines: 3,
                style: const TextStyle(color: Colors.white),
                decoration: InputDecoration(
                  filled: true,
                  fillColor: AppColors.textFieldBackgroundColor,
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(8.r)),
                ),
              ),
              SizedBox(height: 16.h),

              // Status Selector (Started / Pending, In Progress / Active, On Hold / Blocked, In Review, Completed)
              Text('Status', style: AppTextThemes.font16WhiteRegular),
              SizedBox(height: 8.h),
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: [
                    _statusOption('pending', 'Started / Pending', Colors.blueAccent),
                    SizedBox(width: 8.w),
                    _statusOption('in_progress', 'In Progress / Active', Colors.amber),
                    SizedBox(width: 8.w),
                    _statusOption('on_hold', 'On Hold / Blocked', Colors.deepOrangeAccent),
                    SizedBox(width: 8.w),
                    _statusOption('in_review', 'In Review', Colors.purpleAccent),
                    SizedBox(width: 8.w),
                    _statusOption('completed', 'Completed', Colors.greenAccent),
                  ],
                ),
              ),
              SizedBox(height: 16.h),

              // Priority Selector (Urgent, High, Medium, Low)
              Text('Priority', style: AppTextThemes.font16WhiteRegular),
              SizedBox(height: 8.h),
              Row(
                children: [
                  _priorityChip(4, 'Urgent', Colors.red),
                  SizedBox(width: 6.w),
                  _priorityChip(3, 'High', Colors.orange),
                  SizedBox(width: 6.w),
                  _priorityChip(2, 'Medium', Colors.amber),
                  SizedBox(width: 6.w),
                  _priorityChip(1, 'Low', Colors.green),
                ],
              ),
              SizedBox(height: 16.h),

              // Category Selector
              Text('Category', style: AppTextThemes.font16WhiteRegular),
              SizedBox(height: 8.h),
              BlocBuilder<TaskCubit, TaskState>(
                builder: (context, state) {
                  return Container(
                    padding: EdgeInsets.symmetric(horizontal: 12.w),
                    decoration: BoxDecoration(
                      color: AppColors.textFieldBackgroundColor,
                      borderRadius: BorderRadius.circular(8.r),
                    ),
                    child: DropdownButtonHideUnderline(
                      child: DropdownButton<String>(
                        value: state.categories.any((c) => c.name == _selectedCategory)
                            ? _selectedCategory
                            : state.categories.first.name,
                        dropdownColor: AppColors.textFieldBackgroundColor,
                        isExpanded: true,
                        items: state.categories.map((cat) {
                          return DropdownMenuItem<String>(
                            value: cat.name,
                            child: Row(
                              children: [
                                Icon(cat.icon, color: cat.color, size: 18),
                                SizedBox(width: 10.w),
                                Text(cat.name, style: const TextStyle(color: Colors.white)),
                              ],
                            ),
                          );
                        }).toList(),
                        onChanged: (val) {
                          if (val != null) setState(() => _selectedCategory = val);
                        },
                      ),
                    ),
                  );
                },
              ),
              SizedBox(height: 16.h),

              // Due Date & Time
              Text('Due Date & Time', style: AppTextThemes.font16WhiteRegular),
              SizedBox(height: 8.h),
              Row(
                children: [
                  Expanded(
                    child: InkWell(
                      onTap: () async {
                        final picked = await showDatePicker(
                          context: context,
                          initialDate: _selectedDate ?? DateTime.now(),
                          firstDate: DateTime(2000),
                          lastDate: DateTime(2050),
                        );
                        if (picked != null) {
                          setState(() => _selectedDate = picked);
                        }
                      },
                      child: Container(
                        padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 12.h),
                        decoration: BoxDecoration(
                          color: AppColors.textFieldBackgroundColor,
                          borderRadius: BorderRadius.circular(8.r),
                        ),
                        child: Row(
                          children: [
                            const Icon(Iconsax.calendar_1, size: 18, color: AppColors.primaryColor),
                            SizedBox(width: 8.w),
                            Expanded(
                              child: Text(
                                _selectedDate != null
                                    ? DateFormat('MMM dd, yyyy').format(_selectedDate!)
                                    : 'Select Date',
                                style: TextStyle(color: Colors.white, fontSize: 13.sp),
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  SizedBox(width: 12.w),
                  Expanded(
                    child: InkWell(
                      onTap: () async {
                        final picked = await showTimePicker(
                          context: context,
                          initialTime: TimeOfDay.now(),
                        );
                        if (picked != null) {
                          setState(() => _selectedTime = picked.format(context));
                        }
                      },
                      child: Container(
                        padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 12.h),
                        decoration: BoxDecoration(
                          color: AppColors.textFieldBackgroundColor,
                          borderRadius: BorderRadius.circular(8.r),
                        ),
                        child: Row(
                          children: [
                            const Icon(Iconsax.timer_1, size: 18, color: AppColors.primaryColor),
                            SizedBox(width: 8.w),
                            Expanded(
                              child: Text(
                                _selectedTime ?? 'Select Time',
                                style: TextStyle(color: Colors.white, fontSize: 13.sp),
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              SizedBox(height: 16.h),

              // Assignee Field (Database Collaboration)
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('Assignee / Team Member', style: AppTextThemes.font16WhiteRegular),
                  TextButton.icon(
                    onPressed: () async {
                      final selected = await AssigneePickerDialog.show(
                        context,
                        currentAssignee: _assigneeController.text,
                      );
                      if (selected != null) {
                        setState(() => _assigneeController.text = selected);
                      }
                    },
                    icon: const Icon(Iconsax.user_search, size: 16, color: AppColors.primaryColor),
                    label: const Text('Pick from DB', style: TextStyle(color: AppColors.primaryColor, fontSize: 12)),
                  ),
                ],
              ),
              SizedBox(height: 6.h),
              InkWell(
                onTap: () async {
                  final selected = await AssigneePickerDialog.show(
                    context,
                    currentAssignee: _assigneeController.text,
                  );
                  if (selected != null) {
                    setState(() => _assigneeController.text = selected);
                  }
                },
                borderRadius: BorderRadius.circular(8.r),
                child: Container(
                  padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 12.h),
                  decoration: BoxDecoration(
                    color: AppColors.textFieldBackgroundColor,
                    borderRadius: BorderRadius.circular(8.r),
                    border: Border.all(
                      color: _assigneeController.text.isNotEmpty
                          ? AppColors.primaryColor.withValues(alpha: 0.4)
                          : Colors.transparent,
                    ),
                  ),
                  child: Row(
                    children: [
                      CircleAvatar(
                        radius: 14.r,
                        backgroundColor: _assigneeController.text.isNotEmpty
                            ? AppColors.primaryColor.withValues(alpha: 0.25)
                            : AppColors.darkBlue,
                        child: Icon(
                          _assigneeController.text.isNotEmpty ? Iconsax.user : Iconsax.user_add,
                          size: 14,
                          color: _assigneeController.text.isNotEmpty
                              ? AppColors.primaryColor
                              : AppColors.lightGrey,
                        ),
                      ),
                      SizedBox(width: 12.w),
                      Expanded(
                        child: Text(
                          _assigneeController.text.isNotEmpty
                              ? _assigneeController.text
                              : 'Tap to assign team member from database',
                          style: TextStyle(
                            color: _assigneeController.text.isNotEmpty ? Colors.white : AppColors.lightGrey,
                            fontWeight: _assigneeController.text.isNotEmpty ? FontWeight.w600 : FontWeight.normal,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      if (_assigneeController.text.isNotEmpty)
                        IconButton(
                          padding: EdgeInsets.zero,
                          constraints: const BoxConstraints(),
                          icon: const Icon(Icons.close, size: 16, color: AppColors.lightGrey),
                          onPressed: () => setState(() => _assigneeController.clear()),
                        )
                      else
                        const Icon(Icons.arrow_forward_ios, size: 14, color: AppColors.lightGrey),
                    ],
                  ),
                ),
              ),
              SizedBox(height: 20.h),

              // Subtasks Section
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('Subtasks (${_subtasks.length})', style: AppTextThemes.font16WhiteRegular),
                ],
              ),
              SizedBox(height: 8.h),
              Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _subtaskController,
                      style: const TextStyle(color: Colors.white),
                      decoration: InputDecoration(
                        hintText: 'Add a subtask...',
                        hintStyle: const TextStyle(color: AppColors.lightGrey),
                        filled: true,
                        fillColor: AppColors.textFieldBackgroundColor,
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(8.r)),
                        contentPadding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 10.h),
                      ),
                      onSubmitted: (_) => _addSubtask(),
                    ),
                  ),
                  SizedBox(width: 8.w),
                  IconButton(
                    style: IconButton.styleFrom(
                      backgroundColor: AppColors.primaryColor,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8.r)),
                    ),
                    icon: const Icon(Icons.add, color: Colors.white),
                    onPressed: _addSubtask,
                  ),
                ],
              ),
              SizedBox(height: 10.h),
              ..._subtasks.asMap().entries.map((entry) {
                final idx = entry.key;
                final sub = entry.value;
                return Container(
                  margin: EdgeInsets.only(bottom: 6.h),
                  child: Material(
                    color: AppColors.textFieldBackgroundColor,
                    borderRadius: BorderRadius.circular(8.r),
                    child: ListTile(
                      dense: true,
                      leading: Checkbox(
                        value: sub.isCompleted,
                        activeColor: AppColors.primaryColor,
                        onChanged: (val) {
                          setState(() {
                            _subtasks[idx] = sub.copyWith(isCompleted: val ?? false);
                          });
                        },
                      ),
                      title: Text(
                        sub.title,
                        style: TextStyle(
                          color: sub.isCompleted ? AppColors.lightGrey : Colors.white,
                          decoration: sub.isCompleted ? TextDecoration.lineThrough : null,
                        ),
                      ),
                      trailing: IconButton(
                        icon: const Icon(Icons.close, size: 16, color: AppColors.lightGrey),
                        onPressed: () {
                          setState(() => _subtasks.removeAt(idx));
                        },
                      ),
                    ),
                  ),
                );
              }),
              SizedBox(height: 20.h),

              // Discussion / Comments Section (Real-Time Collaboration)
              Text('Comments & Discussion (${_comments.length})', style: AppTextThemes.font16WhiteRegular),
              SizedBox(height: 8.h),
              Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _commentController,
                      style: const TextStyle(color: Colors.white),
                      decoration: InputDecoration(
                        hintText: 'Add a comment or note...',
                        hintStyle: const TextStyle(color: AppColors.lightGrey),
                        filled: true,
                        fillColor: AppColors.textFieldBackgroundColor,
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(8.r)),
                        contentPadding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 10.h),
                      ),
                      onSubmitted: (_) => _addComment(),
                    ),
                  ),
                  SizedBox(width: 8.w),
                  IconButton(
                    style: IconButton.styleFrom(
                      backgroundColor: AppColors.primaryColor,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8.r)),
                    ),
                    icon: const Icon(Iconsax.send_1, color: Colors.white, size: 18),
                    onPressed: _addComment,
                  ),
                ],
              ),
              SizedBox(height: 10.h),
              if (_comments.isEmpty)
                Padding(
                  padding: EdgeInsets.symmetric(vertical: 8.h),
                  child: const Text('No comments yet. Start the conversation!', style: TextStyle(color: AppColors.lightGrey, fontSize: 12)),
                )
              else
                ..._comments.map((comm) {
                  return Container(
                    margin: EdgeInsets.only(bottom: 8.h),
                    padding: EdgeInsets.all(12.w),
                    decoration: BoxDecoration(
                      color: AppColors.textFieldBackgroundColor,
                      borderRadius: BorderRadius.circular(8.r),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Row(
                              children: [
                                CircleAvatar(
                                  radius: 9.r,
                                  backgroundColor: AppColors.primaryColor,
                                  child: Text(
                                    comm.author.isNotEmpty ? comm.author[0].toUpperCase() : 'U',
                                    style: TextStyle(color: Colors.white, fontSize: 9.sp, fontWeight: FontWeight.bold),
                                  ),
                                ),
                                SizedBox(width: 6.w),
                                Text(
                                  comm.author,
                                  style: const TextStyle(
                                    color: AppColors.primaryColor,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 12,
                                  ),
                                ),
                              ],
                            ),
                            Text(
                              DateFormat('MMM dd, hh:mm a').format(comm.createdAt),
                              style: const TextStyle(color: AppColors.lightGrey, fontSize: 10),
                            ),
                          ],
                        ),
                        SizedBox(height: 6.h),
                        Text(
                          comm.message,
                          style: const TextStyle(color: Colors.white, fontSize: 13),
                        ),
                      ],
                    ),
                  );
                }),

              SizedBox(height: 36.h),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primaryColor,
                    padding: EdgeInsets.symmetric(vertical: 14.h),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8.r)),
                  ),
                  onPressed: _saveTask,
                  child: Text('Save Changes', style: TextStyle(color: Colors.white, fontSize: 16.sp)),
                ),
              ),
            ],
          ),
        ),
      ),
    ),
  ),
);
  }

  Widget _statusOption(String statusKey, String label, Color color) {
    final isSelected = _selectedStatus == statusKey;
    return InkWell(
      onTap: () => setState(() => _selectedStatus = statusKey),
      borderRadius: BorderRadius.circular(8.r),
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 10.h),
        decoration: BoxDecoration(
          color: isSelected ? color.withValues(alpha: 0.2) : AppColors.textFieldBackgroundColor,
          border: Border.all(color: isSelected ? color : Colors.transparent, width: 1.5),
          borderRadius: BorderRadius.circular(8.r),
        ),
        alignment: Alignment.center,
        child: Text(
          label,
          style: TextStyle(
            color: isSelected ? color : AppColors.lightGrey,
            fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
            fontSize: 12.sp,
          ),
        ),
      ),
    );
  }

  Widget _priorityChip(int level, String label, Color color) {
    final isSelected = _selectedPriority == level;
    return Expanded(
      child: InkWell(
        onTap: () => setState(() => _selectedPriority = level),
        borderRadius: BorderRadius.circular(8.r),
        child: Container(
          padding: EdgeInsets.symmetric(vertical: 10.h),
          decoration: BoxDecoration(
            color: isSelected ? color.withValues(alpha: 0.2) : AppColors.textFieldBackgroundColor,
            border: Border.all(color: isSelected ? color : Colors.transparent, width: 1.5),
            borderRadius: BorderRadius.circular(8.r),
          ),
          alignment: Alignment.center,
          child: Text(
            label,
            style: TextStyle(
              color: isSelected ? color : AppColors.lightGrey,
              fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
              fontSize: 12.sp,
            ),
          ),
        ),
      ),
    );
  }
}
