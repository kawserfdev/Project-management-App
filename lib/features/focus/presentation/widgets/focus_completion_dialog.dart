import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:iconsax/iconsax.dart';
import 'package:task_manager_app/core/constants/app_colors.dart';
import 'package:task_manager_app/core/themes/app_text_themes.dart';
import 'package:task_manager_app/features/focus/data/models/focus_session_model.dart';
import 'package:task_manager_app/features/focus/presentation/manager/focus_cubit.dart';
import 'package:task_manager_app/features/focus/presentation/manager/focus_state.dart';
import 'package:task_manager_app/features/task/data/models/task_model.dart';
import 'package:task_manager_app/features/task/presentation/manager/task_cubit.dart';

class FocusCompletionDialog extends StatelessWidget {
  const FocusCompletionDialog({
    super.key,
    required this.session,
    this.focusedTask,
  });

  final FocusSessionModel session;
  final TaskModel? focusedTask;

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: AppColors.darkBlue,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16.r)),
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 440),
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 24.h),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Celebration Badge
              Container(
                width: 64.w,
                height: 64.h,
                decoration: BoxDecoration(
                  color: Colors.amber.withValues(alpha: 0.15),
                  shape: BoxShape.circle,
                  border: Border.all(color: Colors.amber.withValues(alpha: 0.4), width: 2),
                ),
                child: const Icon(Icons.emoji_events, color: Colors.amber, size: 36),
              ),
              SizedBox(height: 16.h),

              Text('Focus Session Completed!', style: AppTextThemes.font20WhiteRegularWithStyle),
              SizedBox(height: 6.h),
              Text(
                'You stayed focused for ${session.durationMinutes} minutes. Keep up the great momentum!',
                textAlign: TextAlign.center,
                style: const TextStyle(color: AppColors.lightGrey, fontSize: 13),
              ),
              SizedBox(height: 16.h),

              // Attached Task Card (if any)
              if (focusedTask != null) ...[
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 10.h),
                  decoration: BoxDecoration(
                    color: AppColors.textFieldBackgroundColor,
                    borderRadius: BorderRadius.circular(10.r),
                    border: Border.all(color: AppColors.primaryColor.withValues(alpha: 0.3)),
                  ),
                  child: Row(
                    children: [
                      const Icon(Iconsax.task, size: 18, color: AppColors.primaryColor),
                      SizedBox(width: 10.w),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text('Focused Task', style: TextStyle(color: AppColors.lightGrey, fontSize: 10)),
                            Text(
                              focusedTask!.title,
                              style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w600, fontSize: 13),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                SizedBox(height: 12.h),

                // Button: Mark Task as Completed
                SizedBox(
                  width: double.infinity,
                  height: 44.h,
                  child: ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8.r)),
                    ),
                    icon: const Icon(Icons.check_circle_outline, color: Colors.white, size: 18),
                    label: const Text('Mark Task as Completed', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                    onPressed: () {
                      context.read<TaskCubit>().toggleTaskCompletion(focusedTask!.id);
                      context.read<FocusCubit>().dismissFinishedDialog();
                      Navigator.pop(context);
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text('Task "${focusedTask!.title}" marked completed!'),
                          backgroundColor: Colors.green,
                        ),
                      );
                    },
                  ),
                ),
                SizedBox(height: 8.h),
              ],

              // Button: Take Break
              SizedBox(
                width: double.infinity,
                height: 44.h,
                child: ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.teal,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8.r)),
                  ),
                  icon: const Icon(Iconsax.coffee, color: Colors.white, size: 18),
                  label: const Text('Take a Short Break', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                  onPressed: () {
                    context.read<FocusCubit>().switchMode(PomodoroMode.shortBreak);
                    context.read<FocusCubit>().toggleTimer();
                    context.read<FocusCubit>().dismissFinishedDialog();
                    Navigator.pop(context);
                  },
                ),
              ),
              SizedBox(height: 8.h),

              // Button: Start Next Focus
              SizedBox(
                width: double.infinity,
                height: 44.h,
                child: OutlinedButton.icon(
                  style: OutlinedButton.styleFrom(
                    foregroundColor: AppColors.primaryColor,
                    side: const BorderSide(color: AppColors.primaryColor),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8.r)),
                  ),
                  icon: const Icon(Iconsax.play, size: 18),
                  label: const Text('Start Another Focus Block'),
                  onPressed: () {
                    context.read<FocusCubit>().switchMode(PomodoroMode.focus);
                    context.read<FocusCubit>().toggleTimer();
                    context.read<FocusCubit>().dismissFinishedDialog();
                    Navigator.pop(context);
                  },
                ),
              ),
              SizedBox(height: 6.h),

              TextButton(
                onPressed: () {
                  context.read<FocusCubit>().dismissFinishedDialog();
                  Navigator.pop(context);
                },
                child: const Text('Dismiss', style: TextStyle(color: AppColors.lightGrey)),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

