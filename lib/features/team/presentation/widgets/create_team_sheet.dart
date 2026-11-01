import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:task_manager_app/core/constants/app_colors.dart';
import 'package:task_manager_app/features/team/data/models/team_model.dart';
import 'package:task_manager_app/features/team/presentation/manager/team_cubit.dart';
import 'package:task_manager_app/features/team/presentation/manager/team_state.dart';
import 'package:task_manager_app/features/team/presentation/widgets/invite_code_card.dart';

class CreateTeamSheet extends StatefulWidget {
  const CreateTeamSheet({super.key});

  @override
  State<CreateTeamSheet> createState() => _CreateTeamSheetState();
}

class _CreateTeamSheetState extends State<CreateTeamSheet> {
  final _formKey = GlobalKey<FormState>();
  final _nameCtrl = TextEditingController();
  final _descCtrl = TextEditingController();
  int _selectedIcon = 0xe3ae;
  int _selectedColor = 0xFF8687E7;

  @override
  void dispose() {
    _nameCtrl.dispose();
    _descCtrl.dispose();
    super.dispose();
  }

  void _submit() {
    if (_formKey.currentState?.validate() != true) return;
    final name = _nameCtrl.text.trim();
    final desc = _descCtrl.text.trim();
    debugPrint('📝 [CreateTeamSheet] User submitted create team: name="$name", desc="$desc", icon=$_selectedIcon, color=$_selectedColor');
    context.read<TeamCubit>().createTeam(
          name: name,
          description: desc,
          iconCode: _selectedIcon,
          colorValue: _selectedColor,
        );
  }

  void _showCreatedDialog(TeamModel team) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppColors.textFieldBackgroundColor,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16.r)),
        title: Row(
          children: [
            const Icon(Icons.celebration_rounded,
                color: AppColors.primaryColor),
            SizedBox(width: 8.w),
            const Text('Team Created!',
                style: TextStyle(color: Colors.white)),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              '"${team.name}" is ready. Share the invite code below:',
              style: TextStyle(color: AppColors.lightGrey, fontSize: 13.sp),
            ),
            SizedBox(height: 12.h),
            InviteCodeCard(inviteCode: team.inviteCode),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(ctx);
              Navigator.pop(context, team);
            },
            child: const Text('Done',
                style: TextStyle(color: AppColors.primaryColor)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<TeamCubit, TeamState>(
      listener: (context, state) {
        if (state is TeamActionSuccess && state.team != null) {
          _showCreatedDialog(state.team!);
        }
        if (state is TeamError) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(state.message),
              backgroundColor: AppColors.error,
            ),
          );
        }
      },
      builder: (context, state) {
        final isLoading = state is TeamLoading;
        return Container(
          decoration: BoxDecoration(
            color: AppColors.textFieldBackgroundColor,
            borderRadius: BorderRadius.vertical(top: Radius.circular(20.r)),
          ),
          padding: EdgeInsets.fromLTRB(
              20.w, 16.h, 20.w, MediaQuery.of(context).viewInsets.bottom + 20.h),
          child: Form(
            key: _formKey,
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Center(
                    child: Container(
                      width: 40.w,
                      height: 4.h,
                      decoration: BoxDecoration(
                        color: AppColors.lightGrey.withValues(alpha: 0.4),
                        borderRadius: BorderRadius.circular(2.r),
                      ),
                    ),
                  ),
                  SizedBox(height: 16.h),
                  Text('Create New Team',
                      style: TextStyle(
                          color: Colors.white,
                          fontSize: 18.sp,
                          fontWeight: FontWeight.bold)),
                  SizedBox(height: 20.h),

                  // Name
                  Text('Team Name',
                      style:
                          TextStyle(color: AppColors.lightGrey, fontSize: 13.sp)),
                  SizedBox(height: 6.h),
                  TextFormField(
                    controller: _nameCtrl,
                    style: const TextStyle(color: Colors.white),
                    decoration: InputDecoration(
                      hintText: 'e.g. Engineering Team',
                      hintStyle:
                          TextStyle(color: AppColors.lightGrey, fontSize: 14.sp),
                      filled: true,
                      fillColor: AppColors.darkBlue,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10.r),
                        borderSide:
                            const BorderSide(color: AppColors.dividerColor),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10.r),
                        borderSide: BorderSide(
                            color: AppColors.dividerColor.withValues(alpha: 0.5)),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10.r),
                        borderSide:
                            const BorderSide(color: AppColors.primaryColor),
                      ),
                    ),
                    validator: (v) => (v == null || v.trim().isEmpty)
                        ? 'Team name is required'
                        : null,
                  ),
                  SizedBox(height: 14.h),

                  // Description
                  Text('Description (optional)',
                      style:
                          TextStyle(color: AppColors.lightGrey, fontSize: 13.sp)),
                  SizedBox(height: 6.h),
                  TextFormField(
                    controller: _descCtrl,
                    style: const TextStyle(color: Colors.white),
                    maxLines: 2,
                    decoration: InputDecoration(
                      hintText: 'What is this team about?',
                      hintStyle:
                          TextStyle(color: AppColors.lightGrey, fontSize: 14.sp),
                      filled: true,
                      fillColor: AppColors.darkBlue,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10.r),
                        borderSide:
                            const BorderSide(color: AppColors.dividerColor),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10.r),
                        borderSide: BorderSide(
                            color: AppColors.dividerColor.withValues(alpha: 0.5)),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10.r),
                        borderSide:
                            const BorderSide(color: AppColors.primaryColor),
                      ),
                    ),
                  ),
                  SizedBox(height: 16.h),

                  // Icon picker
                  Text('Team Icon',
                      style:
                          TextStyle(color: AppColors.lightGrey, fontSize: 13.sp)),
                  SizedBox(height: 8.h),
                  SizedBox(
                    height: 52.h,
                    child: ListView(
                      scrollDirection: Axis.horizontal,
                      children: TeamModel.availableIcons.map((item) {
                        final code = item['code'] as int;
                        final icon = item['icon'] as IconData;
                        final selected = _selectedIcon == code;
                        return GestureDetector(
                          onTap: () => setState(() => _selectedIcon = code),
                          child: AnimatedContainer(
                            duration: const Duration(milliseconds: 150),
                            margin: EdgeInsets.only(right: 8.w),
                            width: 48.w,
                            height: 48.h,
                            decoration: BoxDecoration(
                              color: selected
                                  ? AppColors.primaryColor.withValues(alpha: 0.2)
                                  : AppColors.darkBlue,
                              borderRadius: BorderRadius.circular(10.r),
                              border: Border.all(
                                color: selected
                                    ? AppColors.primaryColor
                                    : AppColors.dividerColor.withValues(alpha: 0.4),
                                width: selected ? 2 : 1,
                              ),
                            ),
                            child: Icon(
                              icon,
                              color: selected
                                  ? AppColors.primaryColor
                                  : AppColors.lightGrey,
                              size: 22.r,
                            ),
                          ),
                        );
                      }).toList(),
                    ),
                  ),
                  SizedBox(height: 16.h),

                  // Color picker
                  Text('Team Color',
                      style:
                          TextStyle(color: AppColors.lightGrey, fontSize: 13.sp)),
                  SizedBox(height: 8.h),
                  Row(
                    children: TeamModel.availableColors.map((c) {
                      final val = c.toARGB32();
                      final selected = _selectedColor == val;
                      return GestureDetector(
                        onTap: () => setState(() => _selectedColor = val),
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 150),
                          margin: EdgeInsets.only(right: 10.w),
                          width: 30.w,
                          height: 30.w,
                          decoration: BoxDecoration(
                            color: c,
                            shape: BoxShape.circle,
                            border: Border.all(
                              color: selected ? Colors.white : Colors.transparent,
                              width: 2.5,
                            ),
                          ),
                          child: selected
                              ? const Icon(Icons.check,
                                  color: Colors.white, size: 16)
                              : null,
                        ),
                      );
                    }).toList(),
                  ),
                  SizedBox(height: 24.h),

                  // Submit button
                  SizedBox(
                    width: double.infinity,
                    height: 50.h,
                    child: ElevatedButton(
                      onPressed: isLoading ? null : _submit,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primaryColor,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12.r),
                        ),
                      ),
                      child: isLoading
                          ? const SizedBox(
                              width: 22,
                              height: 22,
                              child: CircularProgressIndicator(
                                  color: Colors.white, strokeWidth: 2.5),
                            )
                          : Text('Create Team',
                              style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 16.sp,
                                  fontWeight: FontWeight.bold)),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}

