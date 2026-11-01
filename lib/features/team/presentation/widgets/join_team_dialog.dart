import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:task_manager_app/core/constants/app_colors.dart';
import 'package:task_manager_app/features/team/presentation/manager/team_cubit.dart';
import 'package:task_manager_app/features/team/presentation/manager/team_state.dart';

class JoinTeamDialog extends StatefulWidget {
  const JoinTeamDialog({super.key});

  @override
  State<JoinTeamDialog> createState() => _JoinTeamDialogState();
}

class _JoinTeamDialogState extends State<JoinTeamDialog> {
  final _codeCtrl = TextEditingController();

  @override
  void dispose() {
    _codeCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<TeamCubit, TeamState>(
      listener: (context, state) {
        if (state is TeamActionSuccess) {
          Navigator.pop(context, state.team);
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
        return AlertDialog(
          backgroundColor: AppColors.textFieldBackgroundColor,
          shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16.r)),
          title: const Text('Join a Team',
              style: TextStyle(color: Colors.white)),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Enter the 6-character invite code shared by your team admin.',
                style: TextStyle(color: AppColors.lightGrey, fontSize: 13.sp),
              ),
              SizedBox(height: 16.h),
              TextField(
                controller: _codeCtrl,
                textCapitalization: TextCapitalization.characters,
                maxLength: 6,
                style: TextStyle(
                  color: AppColors.primaryColor,
                  fontSize: 22.sp,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 4,
                ),
                textAlign: TextAlign.center,
                decoration: InputDecoration(
                  counterText: '',
                  hintText: 'ABC123',
                  hintStyle: TextStyle(
                      color: AppColors.lightGrey.withValues(alpha: 0.4),
                      fontSize: 22.sp,
                      letterSpacing: 4),
                  filled: true,
                  fillColor: AppColors.darkBlue,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10.r),
                    borderSide:
                        const BorderSide(color: AppColors.primaryColor),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10.r),
                    borderSide:
                        const BorderSide(color: AppColors.primaryColor, width: 2),
                  ),
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel',
                  style: TextStyle(color: AppColors.lightGrey)),
            ),
            ElevatedButton(
              onPressed: isLoading
                  ? null
                  : () {
                      final code = _codeCtrl.text.trim().toUpperCase();
                      if (code.length != 6) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Please enter a 6-character code'),
                            backgroundColor: AppColors.error,
                          ),
                        );
                        return;
                      }
                      debugPrint('🔑 [JoinTeamDialog] User submitted join with code: "$code"');
                      context.read<TeamCubit>().joinTeamByCode(code);
                    },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primaryColor,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8.r)),
              ),
              child: isLoading
                  ? const SizedBox(
                      width: 18,
                      height: 18,
                      child: CircularProgressIndicator(
                          color: Colors.white, strokeWidth: 2),
                    )
                  : const Text('Join', style: TextStyle(color: Colors.white)),
            ),
          ],
        );
      },
    );
  }
}

