import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:iconsax/iconsax.dart';
import 'package:task_manager_app/core/constants/app_colors.dart';
import 'package:task_manager_app/core/di/service_locator.dart';
import 'package:task_manager_app/core/models/app_user_model.dart';
import 'package:task_manager_app/core/routes/routes.dart';
import 'package:task_manager_app/core/services/session_manager.dart';
import 'package:task_manager_app/core/services/user_directory_service.dart';
import 'package:task_manager_app/core/themes/app_text_themes.dart';
import 'package:task_manager_app/features/authentication/data/repos/auth_repo.dart';
import 'package:task_manager_app/features/task/presentation/manager/task_cubit.dart';
import 'package:task_manager_app/features/task/presentation/manager/task_state.dart';

class ProfileView extends StatelessWidget {
  const ProfileView({super.key, this.user});
  final dynamic user;

  User? get _currentUser {
    if (user is User) return user as User;
    try {
      return FirebaseAuth.instance.currentUser;
    } catch (_) {
      return null;
    }
  }

  void _confirmLogout(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppColors.textFieldBackgroundColor,
        title: const Text('Log Out', style: TextStyle(color: Colors.white)),
        content: const Text(
          'Are you sure you want to log out of Task Manager?',
          style: TextStyle(color: AppColors.lightGrey),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel', style: TextStyle(color: AppColors.lightGrey)),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.error),
            onPressed: () async {
              Navigator.pop(ctx);
              try {
                await SessionManager.clearSession();
                await getIt<AuthRepo>().logOut();
                if (context.mounted) {
                  context.read<TaskCubit>().resetUserSession();
                }
              } catch (_) {}
              if (context.mounted) {
                Navigator.pushNamedAndRemoveUntil(
                  context,
                  Routes.loginView,
                  (route) => false,
                );
              }
            },
            child: const Text('Log Out'),
          ),
        ],
      ),
    );
  }

  void _showEditProfileDialog(
      BuildContext context, User? user, String currentName, String currentEmail) {
    final nameCtrl = TextEditingController(text: currentName);
    String selectedRole = 'Programmer / Developer';

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (dialogCtx, setDialogState) => AlertDialog(
          backgroundColor: AppColors.textFieldBackgroundColor,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16.r)),
          title: const Text('Edit Profile & Role', style: TextStyle(color: Colors.white)),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Display Name', style: TextStyle(color: AppColors.lightGrey, fontSize: 13.sp)),
              SizedBox(height: 6.h),
              TextField(
                controller: nameCtrl,
                style: const TextStyle(color: Colors.white),
                decoration: InputDecoration(
                  filled: true,
                  fillColor: AppColors.darkBlue,
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(8.r), borderSide: BorderSide.none),
                ),
              ),
              SizedBox(height: 16.h),
              Text('Workspace Role', style: TextStyle(color: AppColors.lightGrey, fontSize: 13.sp)),
              SizedBox(height: 6.h),
              Container(
                padding: EdgeInsets.symmetric(horizontal: 12.w),
                decoration: BoxDecoration(
                  color: AppColors.darkBlue,
                  borderRadius: BorderRadius.circular(8.r),
                ),
                child: DropdownButtonHideUnderline(
                  child: DropdownButton<String>(
                    value: selectedRole,
                    dropdownColor: AppColors.textFieldBackgroundColor,
                    isExpanded: true,
                    items: const [
                      DropdownMenuItem(
                        value: 'Project Manager',
                        child: Text('Project Manager', style: TextStyle(color: Colors.white)),
                      ),
                      DropdownMenuItem(
                        value: 'Programmer / Developer',
                        child: Text('Programmer / Developer', style: TextStyle(color: Colors.white)),
                      ),
                    ],
                    onChanged: (val) {
                      if (val != null) {
                        setDialogState(() => selectedRole = val);
                      }
                    },
                  ),
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text('Cancel', style: TextStyle(color: AppColors.lightGrey)),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(backgroundColor: AppColors.primaryColor),
              onPressed: () async {
                final newName = nameCtrl.text.trim();
                if (newName.isNotEmpty) {
                  try {
                    await user?.updateDisplayName(newName);
                    await SessionManager.saveUserSession(
                      id: user?.uid ?? '',
                      email: currentEmail,
                      displayName: newName,
                    );
                    if (user != null) {
                      await getIt<UserDirectoryService>().saveUser(AppUserModel(
                        uid: user.uid,
                        displayName: newName,
                        email: currentEmail,
                        role: selectedRole,
                        photoUrl: user.photoURL,
                      ));
                    }
                  } catch (_) {}
                }
                if (context.mounted) Navigator.pop(ctx);
              },
              child: const Text('Save'),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final activeUser = _currentUser;

    return FutureBuilder<Map<String, String?>>(
      future: SessionManager.getUserSession(),
      builder: (context, snapshot) {
        final cached = snapshot.data;
        final displayName = activeUser?.displayName ??
            (cached?['displayName'] != null && cached!['displayName']!.isNotEmpty
                ? cached['displayName']!
                : 'Task Manager User');
        final email = activeUser?.email ??
            (cached?['email'] != null && cached!['email']!.isNotEmpty
                ? cached['email']!
                : 'user@example.com');
        final photoUrl = activeUser?.photoURL;

        return Scaffold(
          body: SafeArea(
            child: Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 700),
                child: SingleChildScrollView(
                  padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 16.h),
                  child: Column(
                children: [
                  Text('Profile', style: AppTextThemes.font20WhiteRegularWithStyle),
                  SizedBox(height: 20.h),

                  // Avatar & User Info
                  CircleAvatar(
                    radius: 45.r,
                    backgroundColor: AppColors.primaryColor,
                    backgroundImage: photoUrl != null ? NetworkImage(photoUrl) : null,
                    child: photoUrl == null
                        ? Text(
                            displayName.isNotEmpty ? displayName[0].toUpperCase() : 'U',
                            style: TextStyle(fontSize: 32.sp, color: Colors.white, fontWeight: FontWeight.bold),
                          )
                        : null,
                  ),
                  SizedBox(height: 12.h),
                  Text(
                    displayName,
                    style: TextStyle(color: Colors.white, fontSize: 18.sp, fontWeight: FontWeight.bold),
                  ),
                  SizedBox(height: 4.h),
                  Text(
                    email,
                    style: TextStyle(color: AppColors.lightGrey, fontSize: 13.sp),
                  ),
                  SizedBox(height: 10.h),
                  OutlinedButton.icon(
                    style: OutlinedButton.styleFrom(
                      foregroundColor: AppColors.primaryColor,
                      side: const BorderSide(color: AppColors.primaryColor),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20.r)),
                      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 6.h),
                    ),
                    icon: const Icon(Iconsax.edit, size: 14),
                    label: const Text('Edit Profile & Role', style: TextStyle(fontSize: 12)),
                    onPressed: () => _showEditProfileDialog(context, activeUser, displayName, email),
                  ),
                  SizedBox(height: 24.h),

                  // Task statistics cards
                  BlocBuilder<TaskCubit, TaskState>(
                    builder: (context, state) {
                      final total = state.allTasks.length;
                      final completed = state.allTasks.where((t) => t.isCompleted).length;
                      final pending = total - completed;

                      return Row(
                        children: [
                          _statCard('Total', total.toString(), AppColors.primaryColor),
                          SizedBox(width: 10.w),
                          _statCard('Pending', pending.toString(), Colors.orange),
                          SizedBox(width: 10.w),
                          _statCard('Completed', completed.toString(), Colors.green),
                        ],
                      );
                    },
                  ),
                  SizedBox(height: 28.h),

                  // Action list
                  _menuItem(
                    icon: Iconsax.people,
                    title: 'My Teams',
                    onTap: () {
                      Navigator.pushNamed(context, Routes.teamsHub);
                    },
                  ),
                  _menuItem(
                    icon: Iconsax.setting_2,
                    title: 'App Settings',
                    onTap: () {
                      Navigator.pushNamed(context, Routes.settingsView);
                    },
                  ),
                  _menuItem(
                    icon: Iconsax.category,
                    title: 'Task Categories',
                    onTap: () {
                      Navigator.pushNamed(context, Routes.addTaskCategoryView);
                    },
                  ),
                  _menuItem(
                    icon: Iconsax.info_circle,
                    title: 'Help & FAQ',
                    onTap: () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Help & documentation available at github.com')),
                      );
                    },
                  ),
                  _menuItem(
                    icon: Iconsax.logout,
                    title: 'Log Out',
                    color: AppColors.error,
                    onTap: () => _confirmLogout(context),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  },
    );
  }

  Widget _statCard(String label, String value, Color color) {
    return Expanded(
      child: Container(
        padding: EdgeInsets.symmetric(vertical: 14.h),
        decoration: BoxDecoration(
          color: AppColors.textFieldBackgroundColor,
          borderRadius: BorderRadius.circular(10.r),
          border: Border.all(color: color.withValues(alpha: 0.3)),
        ),
        child: Column(
          children: [
            Text(
              value,
              style: TextStyle(
                color: color,
                fontSize: 22.sp,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 4.h),
            Text(
              label,
              style: TextStyle(color: AppColors.lightGrey, fontSize: 12.sp),
            ),
          ],
        ),
      ),
    );
  }

  Widget _menuItem({
    required IconData icon,
    required String title,
    required VoidCallback onTap,
    Color? color,
  }) {
    return Container(
      margin: EdgeInsets.only(bottom: 10.h),
      child: Material(
        color: AppColors.textFieldBackgroundColor,
        borderRadius: BorderRadius.circular(10.r),
        child: ListTile(
          leading: Icon(icon, color: color ?? AppColors.primaryColor),
          title: Text(
            title,
            style: TextStyle(color: color ?? Colors.white, fontSize: 15.sp),
          ),
          trailing: const Icon(Icons.arrow_forward_ios, size: 14, color: AppColors.lightGrey),
          onTap: onTap,
        ),
      ),
    );
  }
}
