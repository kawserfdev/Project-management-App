import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:task_manager_app/core/constants/app_colors.dart';
import 'package:task_manager_app/features/team/data/models/team_member_model.dart';
import 'package:task_manager_app/features/team/data/models/team_model.dart';

class MemberTile extends StatelessWidget {
  final TeamMemberModel member;
  final bool isCurrentUserOwner;
  final VoidCallback? onRemove;
  final ValueChanged<TeamRole>? onChangeRole;

  const MemberTile({
    super.key,
    required this.member,
    this.isCurrentUserOwner = false,
    this.onRemove,
    this.onChangeRole,
  });

  Color get _roleColor {
    switch (member.role) {
      case TeamRole.owner:
        return AppColors.primaryColor;
      case TeamRole.admin:
        return AppColors.warning;
      case TeamRole.member:
        return AppColors.lightGrey;
    }
  }

  @override
  Widget build(BuildContext context) {
    final isMe = member.uid == FirebaseAuth.instance.currentUser?.uid;

    return Container(
      margin: EdgeInsets.symmetric(horizontal: 16.w, vertical: 4.h),
      decoration: BoxDecoration(
        color: AppColors.textFieldBackgroundColor,
        borderRadius: BorderRadius.circular(10.r),
      ),
      child: ListTile(
        leading: CircleAvatar(
          radius: 20.r,
          backgroundColor: AppColors.primaryColor.withValues(alpha: 0.2),
          backgroundImage: member.photoUrl != null
              ? NetworkImage(member.photoUrl!)
              : null,
          child: member.photoUrl == null
              ? Text(
                  member.displayName.isNotEmpty
                      ? member.displayName[0].toUpperCase()
                      : '?',
                  style: TextStyle(
                      color: AppColors.primaryColor,
                      fontWeight: FontWeight.bold,
                      fontSize: 14.sp),
                )
              : null,
        ),
        title: Text(
          member.displayName + (isMe ? ' (You)' : ''),
          style: TextStyle(
              color: Colors.white,
              fontSize: 14.sp,
              fontWeight: FontWeight.w500),
          overflow: TextOverflow.ellipsis,
        ),
        subtitle: Text(
          member.email,
          style: TextStyle(color: AppColors.lightGrey, fontSize: 11.sp),
          overflow: TextOverflow.ellipsis,
        ),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 3.h),
              decoration: BoxDecoration(
                color: _roleColor.withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(20.r),
                border: Border.all(color: _roleColor.withValues(alpha: 0.4)),
              ),
              child: Text(
                member.roleLabel,
                style: TextStyle(
                    color: _roleColor,
                    fontSize: 10.sp,
                    fontWeight: FontWeight.bold),
              ),
            ),
            if (isCurrentUserOwner &&
                member.role != TeamRole.owner &&
                !isMe) ...[
              SizedBox(width: 4.w),
              PopupMenuButton<String>(
                icon: Icon(Icons.more_vert,
                    color: AppColors.lightGrey, size: 18.r),
                color: AppColors.textFieldBackgroundColor,
                onSelected: (val) {
                  if (val == 'remove') onRemove?.call();
                  if (val == 'admin') onChangeRole?.call(TeamRole.admin);
                  if (val == 'member') onChangeRole?.call(TeamRole.member);
                },
                itemBuilder: (_) => [
                  if (member.role != TeamRole.admin)
                    const PopupMenuItem(
                      value: 'admin',
                      child: Row(
                        children: [
                          Icon(Icons.shield_outlined,
                              color: Colors.orange, size: 16),
                          SizedBox(width: 8),
                          Text('Make Admin',
                              style: TextStyle(color: Colors.white)),
                        ],
                      ),
                    ),
                  if (member.role == TeamRole.admin)
                    const PopupMenuItem(
                      value: 'member',
                      child: Row(
                        children: [
                          Icon(Icons.person_outline,
                              color: Colors.blue, size: 16),
                          SizedBox(width: 8),
                          Text('Demote to Member',
                              style: TextStyle(color: Colors.white)),
                        ],
                      ),
                    ),
                  const PopupMenuItem(
                    value: 'remove',
                    child: Row(
                      children: [
                        Icon(Icons.person_remove_outlined,
                            color: Colors.red, size: 16),
                        SizedBox(width: 8),
                        Text('Remove', style: TextStyle(color: Colors.red)),
                      ],
                    ),
                  ),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }
}

