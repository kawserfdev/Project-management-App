import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:task_manager_app/core/constants/app_colors.dart';

class InviteCodeCard extends StatelessWidget {
  final String inviteCode;
  final bool isOwner;
  final VoidCallback? onRegenerate;

  const InviteCodeCard({
    super.key,
    required this.inviteCode,
    this.isOwner = false,
    this.onRegenerate,
  });

  void _copyCode(BuildContext context) {
    debugPrint('📋 [InviteCodeCard] Copied invite code to clipboard: "$inviteCode"');
    Clipboard.setData(ClipboardData(text: inviteCode));
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Invite code copied to clipboard!'),
        backgroundColor: AppColors.success,
        behavior: SnackBarBehavior.floating,
        duration: Duration(seconds: 2),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
      padding: EdgeInsets.all(16.r),
      decoration: BoxDecoration(
        color: AppColors.textFieldBackgroundColor,
        borderRadius: BorderRadius.circular(12.r),
        border: Border.all(color: AppColors.primaryColor.withValues(alpha: 0.4)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Team Invite Code',
            style: TextStyle(
              color: AppColors.lightGrey,
              fontSize: 12.sp,
              fontWeight: FontWeight.w500,
            ),
          ),
          SizedBox(height: 10.h),
          Row(
            children: [
              Expanded(
                child: GestureDetector(
                  onTap: () => _copyCode(context),
                  child: Container(
                    padding:
                        EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
                    decoration: BoxDecoration(
                      color: AppColors.darkBlue,
                      borderRadius: BorderRadius.circular(8.r),
                      border: Border.all(
                          color: AppColors.primaryColor.withValues(alpha: 0.3)),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          inviteCode,
                          style: TextStyle(
                            color: AppColors.primaryColor,
                            fontSize: 22.sp,
                            fontWeight: FontWeight.bold,
                            letterSpacing: 4,
                          ),
                        ),
                        Icon(Icons.copy_rounded,
                            color: AppColors.primaryColor, size: 20.r),
                      ],
                    ),
                  ),
                ),
              ),
              if (isOwner && onRegenerate != null) ...[
                SizedBox(width: 8.w),
                IconButton(
                  tooltip: 'Generate new code',
                  onPressed: onRegenerate,
                  icon: const Icon(Icons.refresh_rounded,
                      color: AppColors.lightGrey),
                ),
              ],
            ],
          ),
          SizedBox(height: 8.h),
          Text(
            'Share this code so team members can join your workspace.',
            style: TextStyle(color: AppColors.lightGrey, fontSize: 11.sp),
          ),
        ],
      ),
    );
  }
}

