import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:iconsax/iconsax.dart';
import 'package:task_manager_app/core/constants/app_colors.dart';
import 'package:task_manager_app/core/themes/app_text_themes.dart';
import 'package:task_manager_app/features/focus/presentation/manager/focus_cubit.dart';
import 'package:task_manager_app/features/focus/presentation/manager/focus_state.dart';
import 'package:task_manager_app/features/focus/presentation/widgets/focus_completion_dialog.dart';
import 'package:task_manager_app/features/focus/presentation/widgets/focus_history_sheet.dart';
import 'package:task_manager_app/features/focus/presentation/widgets/focus_settings_sheet.dart';
import 'package:task_manager_app/features/task/presentation/manager/task_cubit.dart';
import 'package:task_manager_app/features/task/presentation/manager/task_state.dart';

class FocusView extends StatefulWidget {
  const FocusView({super.key, this.user});
  final dynamic user;

  @override
  State<FocusView> createState() => _FocusViewState();
}

class _FocusViewState extends State<FocusView> with WidgetsBindingObserver {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        context.read<FocusCubit>().syncWithWallClock();
      }
    });
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      context.read<FocusCubit>().syncWithWallClock();
    }
  }

  void _openSettings(BuildContext context, FocusState state) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => FocusSettingsSheet(initialSettings: state.settings),
    );
  }

  void _openHistory(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => const FocusHistorySheet(),
    );
  }

  void _selectTaskToFocus(BuildContext context, FocusState focusState) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppColors.textFieldBackgroundColor,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16.r)),
      ),
      builder: (ctx) {
        return BlocBuilder<TaskCubit, TaskState>(
          builder: (context, taskState) {
            final pendingTasks = taskState.allTasks.where((t) => !t.isCompleted).toList();
            return Padding(
              padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 20.h),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('Select Task to Focus On', style: AppTextThemes.font20WhiteRegularWithStyle),
                      if (focusState.focusedTask != null)
                        TextButton(
                          onPressed: () {
                            context.read<FocusCubit>().setFocusedTask(null);
                            Navigator.pop(ctx);
                          },
                          child: const Text('Clear', style: TextStyle(color: Colors.redAccent)),
                        ),
                    ],
                  ),
                  SizedBox(height: 12.h),
                  if (pendingTasks.isEmpty)
                    Padding(
                      padding: EdgeInsets.symmetric(vertical: 24.h),
                      child: const Center(
                        child: Text(
                          'No pending tasks available',
                          style: TextStyle(color: AppColors.lightGrey),
                        ),
                      ),
                    )
                  else
                    ConstrainedBox(
                      constraints: BoxConstraints(maxHeight: 360.h),
                      child: ListView.builder(
                        shrinkWrap: true,
                        itemCount: pendingTasks.length,
                        itemBuilder: (context, index) {
                          final t = pendingTasks[index];
                          final isSelected = focusState.focusedTask?.id == t.id;

                          return ListTile(
                            leading: Icon(
                              Iconsax.task,
                              color: isSelected ? AppColors.primaryColor : AppColors.lightGrey,
                            ),
                            title: Text(
                              t.title,
                              style: TextStyle(
                                color: isSelected ? AppColors.primaryColor : Colors.white,
                                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                              ),
                            ),
                            subtitle: Text(
                              t.category,
                              style: const TextStyle(color: AppColors.lightGrey, fontSize: 11),
                            ),
                            trailing: isSelected
                                ? const Icon(Icons.check_circle, color: AppColors.primaryColor)
                                : null,
                            onTap: () {
                              context.read<FocusCubit>().setFocusedTask(t);
                              Navigator.pop(ctx);
                            },
                          );
                        },
                      ),
                    ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: BlocConsumer<FocusCubit, FocusState>(
          listener: (context, state) {
            if (state.justFinishedSession != null) {
              if (state.settings.logCommentToTask && state.focusedTask != null) {
                final message =
                    'Completed ${state.justFinishedSession!.durationMinutes}m Pomodoro Focus Session.';
                context.read<TaskCubit>().addCommentToTask(
                      state.focusedTask!.id,
                      message,
                      author: 'Focus Timer',
                    );
              }

              showDialog(
                context: context,
                barrierDismissible: false,
                builder: (_) => FocusCompletionDialog(
                  session: state.justFinishedSession!,
                  focusedTask: state.focusedTask,
                ),
              );
            }
          },
          builder: (context, state) {
            final modeColor = switch (state.currentMode) {
              PomodoroMode.focus => AppColors.primaryColor,
              PomodoroMode.shortBreak => Colors.tealAccent,
              PomodoroMode.longBreak => Colors.lightBlueAccent,
            };

            return Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 640),
                child: SingleChildScrollView(
                  padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 12.h),
                  child: Column(
                    children: [
                      // Header with Action Buttons
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text('Focus Mode', style: AppTextThemes.font20WhiteRegularWithStyle),
                          Row(
                            children: [
                              IconButton(
                                tooltip: 'Focus History',
                                icon: const Icon(Iconsax.clock, color: Colors.white),
                                onPressed: () => _openHistory(context),
                              ),
                              IconButton(
                                tooltip: 'Timer Settings',
                                icon: const Icon(Iconsax.setting_2, color: Colors.white),
                                onPressed: () => _openSettings(context, state),
                              ),
                            ],
                          ),
                        ],
                      ),
                      SizedBox(height: 12.h),

                      // Productivity & Streak Metrics Card
                      _buildProductivityCard(state),
                      SizedBox(height: 20.h),

                      // Mode Switcher Tabs
                      Container(
                        padding: EdgeInsets.all(4.w),
                        decoration: BoxDecoration(
                          color: AppColors.textFieldBackgroundColor,
                          borderRadius: BorderRadius.circular(12.r),
                        ),
                        child: Row(
                          children: [
                            _modeButton(
                              context,
                              title: 'Focus (${state.settings.focusDurationMinutes}m)',
                              mode: PomodoroMode.focus,
                              current: state.currentMode,
                            ),
                            _modeButton(
                              context,
                              title: 'Short Break (${state.settings.shortBreakMinutes}m)',
                              mode: PomodoroMode.shortBreak,
                              current: state.currentMode,
                            ),
                            _modeButton(
                              context,
                              title: 'Long Break (${state.settings.longBreakMinutes}m)',
                              mode: PomodoroMode.longBreak,
                              current: state.currentMode,
                            ),
                          ],
                        ),
                      ),
                      SizedBox(height: 32.h),

                      // Circular Countdown Timer
                      Stack(
                        alignment: Alignment.center,
                        children: [
                          SizedBox(
                            width: 230.w,
                            height: 230.h,
                            child: CircularProgressIndicator(
                              value: state.progress,
                              strokeWidth: 10.w,
                              backgroundColor: AppColors.textFieldBackgroundColor,
                              valueColor: AlwaysStoppedAnimation<Color>(modeColor),
                            ),
                          ),
                          Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                state.formattedTime,
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 46.sp,
                                  fontWeight: FontWeight.bold,
                                  letterSpacing: 2,
                                ),
                              ),
                              SizedBox(height: 6.h),
                              Container(
                                padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 3.h),
                                decoration: BoxDecoration(
                                  color: modeColor.withValues(alpha: 0.15),
                                  borderRadius: BorderRadius.circular(12.r),
                                ),
                                child: Text(
                                  state.isRunning
                                      ? 'In Progress'
                                      : (state.remainingSeconds == state.totalSeconds
                                          ? 'Ready'
                                          : 'Paused'),
                                  style: TextStyle(
                                    color: modeColor,
                                    fontSize: 12.sp,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                      SizedBox(height: 30.h),

                      // Currently Focused Target Task Card
                      InkWell(
                        onTap: () => _selectTaskToFocus(context, state),
                        borderRadius: BorderRadius.circular(10.r),
                        child: Container(
                          padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
                          decoration: BoxDecoration(
                            color: AppColors.textFieldBackgroundColor,
                            borderRadius: BorderRadius.circular(10.r),
                            border: Border.all(
                              color: state.focusedTask != null
                                  ? AppColors.primaryColor.withValues(alpha: 0.4)
                                  : Colors.transparent,
                            ),
                          ),
                          child: Row(
                            children: [
                              Icon(Iconsax.task, color: modeColor),
                              SizedBox(width: 12.w),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      'Target Task',
                                      style: TextStyle(color: AppColors.lightGrey, fontSize: 11.sp),
                                    ),
                                    Text(
                                      state.focusedTask?.title ?? 'Tap to select task',
                                      style: const TextStyle(
                                        color: Colors.white,
                                        fontWeight: FontWeight.w600,
                                      ),
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ],
                                ),
                              ),
                              if (state.focusedTask != null)
                                IconButton(
                                  icon: const Icon(Icons.close, size: 16, color: AppColors.lightGrey),
                                  onPressed: () => context.read<FocusCubit>().setFocusedTask(null),
                                )
                              else
                                const Icon(Icons.arrow_forward_ios, size: 14, color: AppColors.lightGrey),
                            ],
                          ),
                        ),
                      ),
                      SizedBox(height: 28.h),

                      // Control Buttons
                      Wrap(
                        alignment: WrapAlignment.center,
                        crossAxisAlignment: WrapCrossAlignment.center,
                        spacing: 20,
                        runSpacing: 12,
                        children: [
                          IconButton(
                            tooltip: 'Reset Timer',
                            onPressed: () => context.read<FocusCubit>().resetTimer(),
                            iconSize: 28,
                            icon: const Icon(Iconsax.refresh, color: AppColors.lightGrey),
                          ),
                          ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: modeColor,
                              shape: const CircleBorder(),
                              padding: const EdgeInsets.all(22),
                              elevation: 4,
                            ),
                            onPressed: () => context.read<FocusCubit>().toggleTimer(),
                            child: Icon(
                              state.isRunning ? Icons.pause : Icons.play_arrow,
                              size: 34,
                              color: Colors.white,
                            ),
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                            decoration: BoxDecoration(
                              color: AppColors.textFieldBackgroundColor,
                              borderRadius: BorderRadius.circular(8.r),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                const Icon(Icons.local_fire_department, color: Colors.orange, size: 18),
                                const SizedBox(width: 4),
                                Text(
                                  '${state.completedFocusSessionsToday} today',
                                  style: TextStyle(color: Colors.white, fontSize: 12.sp),
                                ),
                              ],
                            ),
                          ),
                        ],
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

  Widget _buildProductivityCard(FocusState state) {
    final interval = state.settings.longBreakInterval;
    final currentCycleSession = state.completedFocusSessionsToday % interval;

    return Container(
      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
      decoration: BoxDecoration(
        color: AppColors.textFieldBackgroundColor,
        borderRadius: BorderRadius.circular(12.r),
        border: Border.all(color: Colors.white.withValues(alpha: 0.06)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // Focus time today
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('Today\'s Focus', style: TextStyle(color: AppColors.lightGrey, fontSize: 11)),
              SizedBox(height: 2.h),
              Text(
                '${state.todayFocusMinutes} min',
                style: TextStyle(color: Colors.white, fontSize: 16.sp, fontWeight: FontWeight.bold),
              ),
            ],
          ),

          // Cycle Dots (towards long break)
          Column(
            children: [
              Text(
                'Cycle ($currentCycleSession/$interval)',
                style: const TextStyle(color: AppColors.lightGrey, fontSize: 10),
              ),
              SizedBox(height: 4.h),
              Row(
                mainAxisSize: MainAxisSize.min,
                children: List.generate(interval, (index) {
                  final isFilled = index < currentCycleSession;
                  return Container(
                    margin: const EdgeInsets.symmetric(horizontal: 2),
                    width: 8,
                    height: 8,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: isFilled ? AppColors.primaryColor : Colors.white24,
                    ),
                  );
                }),
              ),
            ],
          ),

          // Streak
          Container(
            padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 4.h),
            decoration: BoxDecoration(
              color: Colors.orange.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(14.r),
              border: Border.all(color: Colors.orange.withValues(alpha: 0.3)),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.local_fire_department, color: Colors.orange, size: 14),
                const SizedBox(width: 4),
                Text(
                  '${state.streakDays} Day${state.streakDays == 1 ? '' : 's'}',
                  style: TextStyle(color: Colors.orange, fontSize: 11.sp, fontWeight: FontWeight.bold),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _modeButton(
    BuildContext context, {
    required String title,
    required PomodoroMode mode,
    required PomodoroMode current,
  }) {
    final isSelected = mode == current;
    return Expanded(
      child: GestureDetector(
        onTap: () => context.read<FocusCubit>().switchMode(mode),
        child: Container(
          padding: EdgeInsets.symmetric(vertical: 8.h),
          decoration: BoxDecoration(
            color: isSelected ? AppColors.primaryColor : Colors.transparent,
            borderRadius: BorderRadius.circular(10.r),
          ),
          alignment: Alignment.center,
          child: Text(
            title,
            style: TextStyle(
              color: isSelected ? Colors.white : AppColors.lightGrey,
              fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
              fontSize: 11.sp,
            ),
          ),
        ),
      ),
    );
  }
}
