import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:iconsax/iconsax.dart';
import 'package:task_manager_app/core/constants/app_colors.dart';
import 'package:task_manager_app/core/di/service_locator.dart';
import 'package:task_manager_app/core/models/app_user_model.dart';
import 'package:task_manager_app/core/services/user_directory_service.dart';
import 'package:task_manager_app/features/team/data/repos/team_repository.dart';

class AssigneePickerDialog extends StatefulWidget {
  const AssigneePickerDialog({super.key, this.currentAssignee});
  final String? currentAssignee;

  static Future<String?> show(BuildContext context, {String? currentAssignee}) {
    return showDialog<String?>(
      context: context,
      builder: (ctx) => AssigneePickerDialog(currentAssignee: currentAssignee),
    );
  }

  @override
  State<AssigneePickerDialog> createState() => _AssigneePickerDialogState();
}

class _AssigneePickerDialogState extends State<AssigneePickerDialog> {
  final _searchController = TextEditingController();
  List<AppUserModel> _allUsers = [];
  List<AppUserModel> _filteredUsers = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadUsers();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _loadUsers() async {
    final service = getIt<UserDirectoryService>();
    final users = await service.getRegisteredUsers();

    // Dynamically fetch all teammates from the user's teams in Firestore
    final List<AppUserModel> teammates = [];
    try {
      final teamRepo = getIt<TeamRepository>();
      final myTeams = await teamRepo.getMyTeams();
      for (final t in myTeams) {
        final members = await teamRepo.getTeamMembers(t.id);
        for (final m in members) {
          teammates.add(AppUserModel(
            uid: m.uid,
            displayName: m.displayName.isNotEmpty ? m.displayName : 'Teammate',
            email: '${t.name} • ${m.role.name.toUpperCase()} • ${m.email}',
            photoUrl: m.photoUrl,
          ));
        }
      }
    } catch (_) {}

    final combinedMap = <String, AppUserModel>{};
    // Add teammates first so they appear at the top
    for (final u in teammates) {
      combinedMap[u.uid] = u;
    }
    // Add directory users
    for (final u in users) {
      combinedMap.putIfAbsent(u.uid, () => u);
    }

    final combined = combinedMap.values.toList();

    if (mounted) {
      setState(() {
        _allUsers = combined;
        _filteredUsers = combined;
        _isLoading = false;
      });
    }
  }

  void _filter(String query) {
    if (query.isEmpty) {
      setState(() => _filteredUsers = _allUsers);
    } else {
      final q = query.toLowerCase();
      setState(() {
        _filteredUsers = _allUsers.where((u) {
          return u.displayName.toLowerCase().contains(q) ||
              u.email.toLowerCase().contains(q);
        }).toList();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      backgroundColor: AppColors.textFieldBackgroundColor,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16.r)),
      title: Row(
        children: [
          const Icon(Iconsax.user_add, color: AppColors.primaryColor, size: 22),
          SizedBox(width: 8.w),
          const Text('Assign Task To', style: TextStyle(color: Colors.white, fontSize: 18)),
        ],
      ),
      content: SizedBox(
        width: 360.w,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Search Input
            TextField(
              controller: _searchController,
              onChanged: _filter,
              style: const TextStyle(color: Colors.white),
              decoration: InputDecoration(
                hintText: 'Search members from database...',
                hintStyle: const TextStyle(color: AppColors.lightGrey, fontSize: 13),
                prefixIcon: const Icon(Iconsax.search_normal, color: AppColors.lightGrey, size: 16),
                filled: true,
                fillColor: AppColors.darkBlue,
                contentPadding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 8.h),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8.r),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
            SizedBox(height: 12.h),

            // Option: Unassigned
            ListTile(
              dense: true,
              leading: CircleAvatar(
                radius: 14.r,
                backgroundColor: AppColors.darkBlue,
                child: const Icon(Icons.close, size: 14, color: AppColors.lightGrey),
              ),
              title: const Text('Unassigned', style: TextStyle(color: AppColors.lightGrey)),
              trailing: widget.currentAssignee == null || widget.currentAssignee!.isEmpty
                  ? const Icon(Icons.check, color: AppColors.primaryColor, size: 18)
                  : null,
              onTap: () => Navigator.pop(context, ''),
            ),
            const Divider(color: AppColors.darkBlue, height: 1),

            // Users List
            if (_isLoading)
              Padding(
                padding: EdgeInsets.symmetric(vertical: 30.h),
                child: const Center(
                  child: CircularProgressIndicator(color: AppColors.primaryColor),
                ),
              )
            else if (_filteredUsers.isEmpty)
              Padding(
                padding: EdgeInsets.symmetric(vertical: 24.h),
                child: const Text('No users found in database', style: TextStyle(color: AppColors.lightGrey)),
              )
            else
              ConstrainedBox(
                constraints: BoxConstraints(maxHeight: 280.h),
                child: ListView.separated(
                  shrinkWrap: true,
                  itemCount: _filteredUsers.length,
                  separatorBuilder: (_, __) => const Divider(color: AppColors.darkBlue, height: 1),
                  itemBuilder: (context, index) {
                    final user = _filteredUsers[index];
                    final isSelected = widget.currentAssignee == user.displayName ||
                        widget.currentAssignee == user.email;

                    return ListTile(
                      dense: true,
                      contentPadding: EdgeInsets.symmetric(horizontal: 4.w),
                      leading: CircleAvatar(
                        radius: 16.r,
                        backgroundColor: AppColors.primaryColor.withValues(alpha: 0.25),
                        child: Text(
                          user.displayName.isNotEmpty
                              ? user.displayName[0].toUpperCase()
                              : 'U',
                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 12,
                          ),
                        ),
                      ),
                      title: Text(
                        user.displayName,
                        style: TextStyle(
                          color: isSelected ? AppColors.primaryColor : Colors.white,
                          fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                          fontSize: 13.sp,
                        ),
                      ),
                      subtitle: Text(
                        user.email,
                        style: const TextStyle(color: AppColors.lightGrey, fontSize: 11),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      trailing: isSelected
                          ? const Icon(Icons.check_circle, color: AppColors.primaryColor, size: 18)
                          : null,
                      onTap: () => Navigator.pop(context, user.displayName),
                    );
                  },
                ),
              ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancel', style: TextStyle(color: AppColors.lightGrey)),
        ),
      ],
    );
  }
}

