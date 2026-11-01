import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:iconsax/iconsax.dart';
import 'package:intl/intl.dart';
import 'package:task_manager_app/core/constants/app_colors.dart';
import 'package:task_manager_app/core/themes/app_text_themes.dart';
import 'package:task_manager_app/features/focus/presentation/manager/focus_cubit.dart';
import 'package:task_manager_app/features/focus/presentation/manager/focus_state.dart';

class FocusHistorySheet extends StatelessWidget {
  const FocusHistorySheet({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<FocusCubit, FocusState>(
      builder: (context, state) {
        final sessions = state.recentSessions;
        final totalMinutes = sessions.fold<int>(0, (sum, s) => sum + s.durationMinutes);

        return Container(
          padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 20.h),
          decoration: BoxDecoration(
            color: AppColors.darkBlue,
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
                  Text('Focus History', style: AppTextThemes.font20WhiteRegularWithStyle),
                  if (sessions.isNotEmpty)
                    TextButton.icon(
                      onPressed: () {
                        showDialog(
                          context: context,
                          builder: (ctx) => AlertDialog(
                            backgroundColor: AppColors.textFieldBackgroundColor,
                            title: const Text('Clear History?', style: TextStyle(color: Colors.white)),
                            content: const Text(
                              'Are you sure you want to delete all recorded focus sessions?',
                              style: TextStyle(color: AppColors.lightGrey),
                            ),
                            actions: [
                              TextButton(
                                onPressed: () => Navigator.pop(ctx),
                                child: const Text('Cancel', style: TextStyle(color: AppColors.lightGrey)),
                              ),
                              TextButton(
                                onPressed: () {
                                  context.read<FocusCubit>().clearSessionHistory();
                                  Navigator.pop(ctx);
                                },
                                child: const Text('Clear', style: TextStyle(color: Colors.redAccent)),
                              ),
                            ],
                          ),
                        );
                      },
                      icon: const Icon(Iconsax.trash, size: 16, color: Colors.redAccent),
                      label: const Text('Clear', style: TextStyle(color: Colors.redAccent)),
                    ),
                ],
              ),
              const Divider(color: AppColors.textFieldBackgroundColor),
              SizedBox(height: 10.h),

              // Summary Stats Row
              Row(
                children: [
                  Expanded(
                    child: Container(
                      padding: EdgeInsets.symmetric(vertical: 12.h, horizontal: 14.w),
                      decoration: BoxDecoration(
                        color: AppColors.textFieldBackgroundColor,
                        borderRadius: BorderRadius.circular(10.r),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text('Total Sessions', style: TextStyle(color: AppColors.lightGrey, fontSize: 11)),
                          SizedBox(height: 4.h),
                          Text(
                            sessions.length.toString(),
                            style: TextStyle(color: Colors.white, fontSize: 20.sp, fontWeight: FontWeight.bold),
                          ),
                        ],
                      ),
                    ),
                  ),
                  SizedBox(width: 12.w),
                  Expanded(
                    child: Container(
                      padding: EdgeInsets.symmetric(vertical: 12.h, horizontal: 14.w),
                      decoration: BoxDecoration(
                        color: AppColors.textFieldBackgroundColor,
                        borderRadius: BorderRadius.circular(10.r),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text('Total Focus Time', style: TextStyle(color: AppColors.lightGrey, fontSize: 11)),
                          SizedBox(height: 4.h),
                          Text(
                            '${totalMinutes}m',
                            style: TextStyle(color: AppColors.primaryColor, fontSize: 20.sp, fontWeight: FontWeight.bold),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
              SizedBox(height: 16.h),

              // Sessions list
              if (sessions.isEmpty)
                Padding(
                  padding: EdgeInsets.symmetric(vertical: 40.h),
                  child: const Center(
                    child: Column(
                      children: [
                        Icon(Iconsax.timer_pause, size: 48, color: AppColors.lightGrey),
                        SizedBox(height: 12),
                        Text('No completed sessions yet', style: TextStyle(color: Colors.white70)),
                        SizedBox(height: 4),
                        Text('Complete your first focus block to see it here!', style: TextStyle(color: AppColors.lightGrey, fontSize: 12)),
                      ],
                    ),
                  ),
                )
              else
                ConstrainedBox(
                  constraints: BoxConstraints(maxHeight: 380.h),
                  child: ListView.separated(
                    shrinkWrap: true,
                    itemCount: sessions.length,
                    separatorBuilder: (_, __) => const Divider(color: AppColors.textFieldBackgroundColor, height: 1),
                    itemBuilder: (context, index) {
                      final item = sessions[index];
                      final formattedDate = DateFormat('MMM dd, hh:mm a').format(item.completedAt);

                      return ListTile(
                        contentPadding: EdgeInsets.symmetric(vertical: 4.h),
                        leading: CircleAvatar(
                          radius: 18.r,
                          backgroundColor: AppColors.primaryColor.withValues(alpha: 0.15),
                          child: const Icon(Iconsax.timer_1, size: 18, color: AppColors.primaryColor),
                        ),
                        title: Text(
                          item.taskTitle ?? 'General Focus',
                          style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w600),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        subtitle: Text(
                          formattedDate,
                          style: const TextStyle(color: AppColors.lightGrey, fontSize: 11),
                        ),
                        trailing: Container(
                          padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 3.h),
                          decoration: BoxDecoration(
                            color: AppColors.textFieldBackgroundColor,
                            borderRadius: BorderRadius.circular(6.r),
                          ),
                          child: Text(
                            '+${item.durationMinutes}m',
                            style: const TextStyle(color: Colors.greenAccent, fontWeight: FontWeight.bold, fontSize: 12),
                          ),
                        ),
                      );
                    },
                  ),
                ),
            ],
          ),
        );
      },
    );
  }
}

