import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:task_manager_app/core/constants/app_colors.dart';
import 'package:task_manager_app/features/team/data/models/team_model.dart';

class TeamCard extends StatelessWidget {
  final TeamModel team;
  final TeamRole myRole;
  final VoidCallback onTap;

  const TeamCard({
    super.key,
    required this.team,
    required this.myRole,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final teamColor = team.color;
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: EdgeInsets.symmetric(horizontal: 16.w, vertical: 6.h),
        padding: EdgeInsets.all(16.r),
        decoration: BoxDecoration(
          color: AppColors.textFieldBackgroundColor,
          borderRadius: BorderRadius.circular(14.r),
          border:
              Border.all(color: teamColor.withValues(alpha: 0.35), width: 1.2),
        ),
        child: Row(
          children: [
            Container(
              width: 48.w,
              height: 48.w,
              decoration: BoxDecoration(
                color: teamColor.withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(12.r),
              ),
              child: Icon(team.icon, color: teamColor, size: 26.r),
            ),
            SizedBox(width: 14.w),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    team.name,
                    style: TextStyle(
                        color: Colors.white,
                        fontSize: 15.sp,
                        fontWeight: FontWeight.w600),
                    overflow: TextOverflow.ellipsis,
                  ),
                  if (team.description.isNotEmpty) ...[
                    SizedBox(height: 2.h),
                    Text(
                      team.description,
                      style: TextStyle(
                          color: AppColors.lightGrey, fontSize: 12.sp),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                  SizedBox(height: 6.h),
                  Row(
                    children: [
                      Icon(Icons.people_outline,
                          color: AppColors.lightGrey, size: 13.r),
                      SizedBox(width: 4.w),
                      Text(
                        '${team.memberUids.length} member${team.memberUids.length != 1 ? 's' : ''}',
                        style: TextStyle(
                            color: AppColors.lightGrey, fontSize: 11.sp),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 3.h),
                  decoration: BoxDecoration(
                    color: teamColor.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(20.r),
                  ),
                  child: Text(
                    _roleLabel(myRole),
                    style: TextStyle(
                        color: teamColor,
                        fontSize: 10.sp,
                        fontWeight: FontWeight.bold),
                  ),
                ),
                SizedBox(height: 8.h),
                Icon(Icons.arrow_forward_ios,
                    size: 12.r, color: AppColors.lightGrey),
              ],
            ),
          ],
        ),
      ),
    );
  }

  String _roleLabel(TeamRole r) {
    switch (r) {
      case TeamRole.owner:
        return 'Owner';
      case TeamRole.admin:
        return 'Admin';
      case TeamRole.member:
        return 'Member';
    }
  }
}

