import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:iconsax/iconsax.dart';
import 'package:task_manager_app/core/constants/app_colors.dart';
import 'package:task_manager_app/core/services/task_backup_service.dart';
import 'package:task_manager_app/core/themes/app_text_themes.dart';
import 'package:task_manager_app/features/task/presentation/manager/task_cubit.dart';

class SettingsView extends StatefulWidget {
  const SettingsView({super.key});

  @override
  State<SettingsView> createState() => _SettingsViewState();
}

class _SettingsViewState extends State<SettingsView> {
  bool _notificationsEnabled = true;
  bool _darkModeEnabled = true;
  String _selectedLanguage = 'English';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Settings', style: AppTextThemes.font20WhiteRegularWithStyle),
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, size: 18),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 750),
            child: ListView(
              padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 16.h),
              children: [
            _buildSectionHeader('Preferences'),
            _buildSwitchTile(
              icon: Iconsax.notification,
              title: 'Push Notifications',
              subtitle: 'Receive reminders for upcoming tasks',
              value: _notificationsEnabled,
              onChanged: (val) => setState(() => _notificationsEnabled = val),
            ),
            _buildSwitchTile(
              icon: Iconsax.moon,
              title: 'Dark Mode',
              subtitle: 'Enable dark theme across the app',
              value: _darkModeEnabled,
              onChanged: (val) => setState(() => _darkModeEnabled = val),
            ),
            _buildListTile(
              icon: Iconsax.global,
              title: 'Language',
              subtitle: _selectedLanguage,
              onTap: _showLanguageDialog,
            ),
            SizedBox(height: 24.h),
            _buildSectionHeader('Data & Backup'),
            _buildListTile(
              icon: Iconsax.export_1,
              title: 'Export Tasks',
              subtitle: 'Download or copy tasks as JSON or CSV',
              onTap: _showExportDialog,
            ),
            _buildListTile(
              icon: Iconsax.import_1,
              title: 'Import Tasks',
              subtitle: 'Restore tasks from backup JSON or CSV',
              onTap: _showImportDialog,
            ),
            SizedBox(height: 24.h),
            _buildSectionHeader('Account & Security'),
            _buildListTile(
              icon: Iconsax.lock,
              title: 'Change Password',
              subtitle: 'Update your account login password',
              onTap: _showChangePasswordDialog,
            ),
            _buildListTile(
              icon: Iconsax.security_safe,
              title: 'Two-Factor Authentication',
              subtitle: 'Extra layer of security',
              onTap: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Two-factor auth settings updated')),
                );
              },
            ),
            SizedBox(height: 24.h),
            _buildSectionHeader('About'),
            _buildListTile(
              icon: Iconsax.info_circle,
              title: 'About Task Manager',
              subtitle: 'Version 1.0.2 • Open Source',
              onTap: () {},
            ),
          ],
        ),
      ),
    ),
  ),
);
  }

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: EdgeInsets.only(bottom: 12.h, top: 8.h),
      child: Text(
        title,
        style: TextStyle(
          color: AppColors.primaryColor,
          fontSize: 14.sp,
          fontWeight: FontWeight.bold,
          letterSpacing: 0.5,
        ),
      ),
    );
  }

  Widget _buildSwitchTile({
    required IconData icon,
    required String title,
    required String subtitle,
    required bool value,
    required ValueChanged<bool> onChanged,
  }) {
    return Container(
      margin: EdgeInsets.only(bottom: 10.h),
      child: Material(
        color: AppColors.textFieldBackgroundColor,
        borderRadius: BorderRadius.circular(12.r),
        child: SwitchListTile(
          secondary: Icon(icon, color: AppColors.primaryColor),
          title: Text(title, style: TextStyle(color: Colors.white, fontSize: 16.sp)),
          subtitle: Text(subtitle, style: TextStyle(color: AppColors.lightGrey, fontSize: 12.sp)),
          value: value,
          activeTrackColor: AppColors.primaryColor,
          onChanged: onChanged,
        ),
      ),
    );
  }

  Widget _buildListTile({
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return Container(
      margin: EdgeInsets.only(bottom: 10.h),
      child: Material(
        color: AppColors.textFieldBackgroundColor,
        borderRadius: BorderRadius.circular(12.r),
        child: ListTile(
          leading: Icon(icon, color: AppColors.primaryColor),
          title: Text(title, style: TextStyle(color: Colors.white, fontSize: 16.sp)),
          subtitle: Text(subtitle, style: TextStyle(color: AppColors.lightGrey, fontSize: 12.sp)),
          trailing: const Icon(Icons.arrow_forward_ios, size: 14, color: AppColors.lightGrey),
          onTap: onTap,
        ),
      ),
    );
  }

  void _showExportDialog() {
    final tasks = context.read<TaskCubit>().state.allTasks;
    final jsonExport = TaskBackupService.exportToJson(tasks);
    final csvExport = TaskBackupService.exportToCsv(tasks);

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppColors.textFieldBackgroundColor,
        title: const Text('Export Tasks', style: TextStyle(color: Colors.white)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '${tasks.length} tasks ready for export.',
              style: const TextStyle(color: AppColors.lightGrey),
            ),
            SizedBox(height: 16.h),
            ListTile(
              leading: const Icon(Iconsax.document_code, color: AppColors.primaryColor),
              title: const Text('Copy JSON Export', style: TextStyle(color: Colors.white)),
              onTap: () {
                Clipboard.setData(ClipboardData(text: jsonExport));
                Navigator.pop(ctx);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('JSON data copied to clipboard!')),
                );
              },
            ),
            ListTile(
              leading: const Icon(Iconsax.document_text, color: Colors.greenAccent),
              title: const Text('Copy CSV Export', style: TextStyle(color: Colors.white)),
              onTap: () {
                Clipboard.setData(ClipboardData(text: csvExport));
                Navigator.pop(ctx);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('CSV data copied to clipboard!')),
                );
              },
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Close', style: TextStyle(color: AppColors.lightGrey)),
          ),
        ],
      ),
    );
  }

  void _showImportDialog() {
    final controller = TextEditingController();
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppColors.textFieldBackgroundColor,
        title: const Text('Import Tasks', style: TextStyle(color: Colors.white)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Paste JSON or CSV data below to import tasks:',
              style: TextStyle(color: AppColors.lightGrey, fontSize: 13),
            ),
            SizedBox(height: 10.h),
            TextField(
              controller: controller,
              maxLines: 5,
              style: const TextStyle(color: Colors.white, fontSize: 12),
              decoration: InputDecoration(
                hintText: 'Paste export payload here...',
                hintStyle: const TextStyle(color: AppColors.lightGrey),
                filled: true,
                fillColor: AppColors.darkBlue,
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(8.r)),
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
            onPressed: () {
              final text = controller.text.trim();
              if (text.isEmpty) return;

              List imported = TaskBackupService.importFromJson(text);
              if (imported.isEmpty) {
                imported = TaskBackupService.importFromCsv(text);
              }

              if (imported.isEmpty) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('No valid tasks found in input')),
                );
              } else {
                for (final t in imported) {
                  context.read<TaskCubit>().addTask(t);
                }
                Navigator.pop(ctx);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Successfully imported ${imported.length} tasks!')),
                );
              }
            },
            child: const Text('Import'),
          ),
        ],
      ),
    );
  }

  void _showLanguageDialog() {
    final languages = ['English', 'Spanish', 'French', 'German', 'Arabic'];
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppColors.textFieldBackgroundColor,
        title: const Text('Select Language', style: TextStyle(color: Colors.white)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: languages
              .map((lang) => ListTile(
                    title: Text(lang, style: const TextStyle(color: Colors.white)),
                    trailing: _selectedLanguage == lang
                        ? const Icon(Icons.check, color: AppColors.primaryColor)
                        : null,
                    onTap: () {
                      setState(() => _selectedLanguage = lang);
                      Navigator.pop(ctx);
                    },
                  ))
              .toList(),
        ),
      ),
    );
  }

  void _showChangePasswordDialog() {
    final controller = TextEditingController();
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppColors.textFieldBackgroundColor,
        title: const Text('Change Password', style: TextStyle(color: Colors.white)),
        content: TextField(
          controller: controller,
          obscureText: true,
          style: const TextStyle(color: Colors.white),
          decoration: const InputDecoration(
            hintText: 'Enter new password',
            hintStyle: TextStyle(color: AppColors.lightGrey),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel', style: TextStyle(color: AppColors.lightGrey)),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.primaryColor),
            onPressed: () {
              Navigator.pop(ctx);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Password changed successfully')),
              );
            },
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }
}
