import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:iconsax/iconsax.dart';
import 'package:task_manager_app/core/constants/app_colors.dart';
import 'package:task_manager_app/core/themes/app_text_themes.dart';
import 'package:task_manager_app/features/task/presentation/manager/task_cubit.dart';
import 'package:task_manager_app/features/task/presentation/manager/task_state.dart';
import 'package:task_manager_app/features/workspace/data/models/workspace_hierarchy_models.dart';

class HierarchySelectorSheet extends StatelessWidget {
  const HierarchySelectorSheet({super.key});

  void _showCreateDialog(
    BuildContext context, {
    required String title,
    required String hint,
    required Function(String name) onCreated,
  }) {
    final controller = TextEditingController();
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppColors.textFieldBackgroundColor,
        title: Text(title, style: const TextStyle(color: Colors.white)),
        content: TextField(
          controller: controller,
          autofocus: true,
          style: const TextStyle(color: Colors.white),
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: const TextStyle(color: AppColors.lightGrey),
            filled: true,
            fillColor: AppColors.darkBlue,
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(8.r)),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel', style: TextStyle(color: AppColors.lightGrey)),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.primaryColor),
            onPressed: () {
              final text = controller.text.trim();
              if (text.isNotEmpty) {
                onCreated(text);
                Navigator.pop(ctx);
              }
            },
            child: const Text('Create'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<TaskCubit, TaskState>(
      builder: (context, state) {
        final cubit = context.read<TaskCubit>();
        final currentWorkspace = state.selectedWorkspace;
        final spacesInWorkspace = state.spaces
            .where((s) => s.workspaceId == currentWorkspace.id)
            .toList();
        final currentSpace = state.selectedSpace ??
            (spacesInWorkspace.isNotEmpty ? spacesInWorkspace.first : null);
        final listsInSpace = currentSpace != null
            ? state.lists.where((l) => l.spaceId == currentSpace.id).toList()
            : <TaskListModel>[];

        return Container(
          padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 20.h),
          decoration: BoxDecoration(
            color: AppColors.textFieldBackgroundColor,
            borderRadius: BorderRadius.vertical(top: Radius.circular(20.r)),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      const Icon(Iconsax.hierarchy_2, color: AppColors.primaryColor),
                      SizedBox(width: 8.w),
                      Text('Hierarchy Navigator', style: AppTextThemes.font20WhiteRegularWithStyle),
                    ],
                  ),
                  IconButton(
                    icon: const Icon(Icons.close, color: AppColors.lightGrey),
                    onPressed: () => Navigator.pop(context),
                  ),
                ],
              ),
              SizedBox(height: 16.h),

              // 1. Workspace Level
              _sectionHeader(
                title: '1. WORKSPACE',
                onAdd: () {
                  _showCreateDialog(
                    context,
                    title: 'New Workspace',
                    hint: 'Workspace Name (e.g. Acme Corp)',
                    onCreated: (name) {
                      cubit.addWorkspace(
                        WorkspaceModel(
                          id: 'ws_${DateTime.now().millisecondsSinceEpoch}',
                          name: name,
                        ),
                      );
                    },
                  );
                },
              ),
              SizedBox(height: 8.h),
              Container(
                padding: EdgeInsets.symmetric(horizontal: 12.w),
                decoration: BoxDecoration(
                  color: AppColors.darkBlue,
                  borderRadius: BorderRadius.circular(10.r),
                ),
                child: DropdownButtonHideUnderline(
                  child: DropdownButton<String>(
                    value: currentWorkspace.id,
                    dropdownColor: AppColors.textFieldBackgroundColor,
                    isExpanded: true,
                    items: state.workspaces.map((ws) {
                      return DropdownMenuItem<String>(
                        value: ws.id,
                        child: Row(
                          children: [
                            Icon(ws.icon, color: AppColors.primaryColor, size: 18),
                            SizedBox(width: 10.w),
                            Text(ws.name, style: const TextStyle(color: Colors.white)),
                          ],
                        ),
                      );
                    }).toList(),
                    onChanged: (id) {
                      final selected = state.workspaces.firstWhere((w) => w.id == id);
                      cubit.selectWorkspace(selected);
                    },
                  ),
                ),
              ),
              SizedBox(height: 18.h),

              // 2. Spaces Level
              _sectionHeader(
                title: '2. SPACES (IN ${currentWorkspace.name.toUpperCase()})',
                onAdd: () {
                  _showCreateDialog(
                    context,
                    title: 'New Space',
                    hint: 'Space Name (e.g. Frontend)',
                    onCreated: (name) {
                      cubit.addSpace(
                        SpaceModel(
                          id: 'space_${DateTime.now().millisecondsSinceEpoch}',
                          workspaceId: currentWorkspace.id,
                          name: name,
                        ),
                      );
                    },
                  );
                },
              ),
              SizedBox(height: 8.h),
              if (spacesInWorkspace.isEmpty)
                const Text('No spaces created yet.', style: TextStyle(color: AppColors.lightGrey, fontSize: 12))
              else
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: [
                      // "All Spaces" chip
                      Padding(
                        padding: EdgeInsets.only(right: 8.w),
                        child: ChoiceChip(
                          label: const Text('All Spaces'),
                          selected: state.selectedSpace == null,
                          selectedColor: AppColors.primaryColor,
                          backgroundColor: AppColors.darkBlue,
                          labelStyle: TextStyle(
                            color: state.selectedSpace == null ? Colors.white : AppColors.lightGrey,
                            fontSize: 12.sp,
                          ),
                          onSelected: (_) => cubit.selectSpace(null),
                        ),
                      ),
                      ...spacesInWorkspace.map((sp) {
                        final isSelected = state.selectedSpace?.id == sp.id;
                        return Padding(
                          padding: EdgeInsets.only(right: 8.w),
                          child: ChoiceChip(
                            avatar: Icon(sp.icon, size: 14, color: isSelected ? Colors.white : AppColors.primaryColor),
                            label: Text(sp.name),
                            selected: isSelected,
                            selectedColor: AppColors.primaryColor,
                            backgroundColor: AppColors.darkBlue,
                            labelStyle: TextStyle(
                              color: isSelected ? Colors.white : AppColors.lightGrey,
                              fontSize: 12.sp,
                            ),
                            onSelected: (_) => cubit.selectSpace(sp),
                          ),
                        );
                      }),
                    ],
                  ),
                ),
              SizedBox(height: 18.h),

              // 3. Lists Level
              _sectionHeader(
                title: '3. LISTS / PROJECTS',
                onAdd: currentSpace != null
                    ? () {
                        _showCreateDialog(
                          context,
                          title: 'New Task List',
                          hint: 'List Name (e.g. Backlog)',
                          onCreated: (name) {
                            cubit.addList(
                              TaskListModel(
                                id: 'list_${DateTime.now().millisecondsSinceEpoch}',
                                spaceId: currentSpace.id,
                                name: name,
                              ),
                            );
                          },
                        );
                      }
                    : null,
              ),
              SizedBox(height: 8.h),
              if (listsInSpace.isEmpty)
                const Text('Select or create a space to view lists.', style: TextStyle(color: AppColors.lightGrey, fontSize: 12))
              else
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: [
                      Padding(
                        padding: EdgeInsets.only(right: 8.w),
                        child: ChoiceChip(
                          label: const Text('All Lists'),
                          selected: state.selectedList == null,
                          selectedColor: AppColors.primaryColor,
                          backgroundColor: AppColors.darkBlue,
                          labelStyle: TextStyle(
                            color: state.selectedList == null ? Colors.white : AppColors.lightGrey,
                            fontSize: 12.sp,
                          ),
                          onSelected: (_) => cubit.selectList(null),
                        ),
                      ),
                      ...listsInSpace.map((lst) {
                        final isSelected = state.selectedList?.id == lst.id;
                        return Padding(
                          padding: EdgeInsets.only(right: 8.w),
                          child: ChoiceChip(
                            avatar: CircleAvatar(backgroundColor: lst.color, radius: 4.r),
                            label: Text(lst.name),
                            selected: isSelected,
                            selectedColor: AppColors.primaryColor,
                            backgroundColor: AppColors.darkBlue,
                            labelStyle: TextStyle(
                              color: isSelected ? Colors.white : AppColors.lightGrey,
                              fontSize: 12.sp,
                            ),
                            onSelected: (_) => cubit.selectList(lst),
                          ),
                        );
                      }),
                    ],
                  ),
                ),
              SizedBox(height: 20.h),
            ],
          ),
        );
      },
    );
  }

  Widget _sectionHeader({required String title, VoidCallback? onAdd}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          title,
          style: TextStyle(
            color: AppColors.primaryColor,
            fontSize: 11.sp,
            fontWeight: FontWeight.bold,
            letterSpacing: 0.8,
          ),
        ),
        if (onAdd != null)
          InkWell(
            onTap: onAdd,
            borderRadius: BorderRadius.circular(4.r),
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 2.h),
              child: Row(
                children: [
                  const Icon(Icons.add_circle_outline, size: 14, color: AppColors.primaryColor),
                  SizedBox(width: 4.w),
                  Text('Add', style: TextStyle(color: AppColors.primaryColor, fontSize: 11.sp)),
                ],
              ),
            ),
          ),
      ],
    );
  }
}

