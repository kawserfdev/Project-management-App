import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:iconsax/iconsax.dart';
import 'package:task_manager_app/core/constants/app_colors.dart';
import 'package:task_manager_app/core/themes/app_text_themes.dart';
import 'package:task_manager_app/features/focus/data/models/focus_settings_model.dart';
import 'package:task_manager_app/features/focus/presentation/manager/focus_cubit.dart';

class FocusSettingsSheet extends StatefulWidget {
  const FocusSettingsSheet({super.key, required this.initialSettings});
  final FocusSettingsModel initialSettings;

  @override
  State<FocusSettingsSheet> createState() => _FocusSettingsSheetState();
}

class _FocusSettingsSheetState extends State<FocusSettingsSheet> {
  late int _focusDuration;
  late int _shortBreak;
  late int _longBreak;
  late int _longBreakInterval;
  late bool _autoStartBreaks;
  late bool _autoStartFocus;
  late bool _soundEnabled;
  late bool _logCommentToTask;

  @override
  void initState() {
    super.initState();
    _focusDuration = widget.initialSettings.focusDurationMinutes;
    _shortBreak = widget.initialSettings.shortBreakMinutes;
    _longBreak = widget.initialSettings.longBreakMinutes;
    _longBreakInterval = widget.initialSettings.longBreakInterval;
    _autoStartBreaks = widget.initialSettings.autoStartBreaks;
    _autoStartFocus = widget.initialSettings.autoStartFocus;
    _soundEnabled = widget.initialSettings.soundEnabled;
    _logCommentToTask = widget.initialSettings.logCommentToTask;
  }

  void _saveSettings() {
    final updated = FocusSettingsModel(
      focusDurationMinutes: _focusDuration,
      shortBreakMinutes: _shortBreak,
      longBreakMinutes: _longBreak,
      longBreakInterval: _longBreakInterval,
      autoStartBreaks: _autoStartBreaks,
      autoStartFocus: _autoStartFocus,
      soundEnabled: _soundEnabled,
      logCommentToTask: _logCommentToTask,
    );
    context.read<FocusCubit>().updateSettings(updated);
    Navigator.pop(context);
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Focus settings updated'),
        backgroundColor: AppColors.primaryColor,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 20.h),
      decoration: BoxDecoration(
        color: AppColors.darkBlue,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20.r)),
      ),
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('Timer Settings', style: AppTextThemes.font20WhiteRegularWithStyle),
                IconButton(
                  onPressed: () => Navigator.pop(context),
                  icon: const Icon(Icons.close, color: AppColors.lightGrey),
                ),
              ],
            ),
            const Divider(color: AppColors.textFieldBackgroundColor),
            SizedBox(height: 12.h),

            // Focus Duration Slider
            _buildSliderTile(
              title: 'Focus Duration',
              subtitle: 'Work interval in minutes',
              value: _focusDuration.toDouble(),
              min: 10,
              max: 90,
              divisions: 16,
              displayUnit: '$_focusDuration min',
              icon: Iconsax.timer_1,
              color: AppColors.primaryColor,
              onChanged: (val) => setState(() => _focusDuration = val.round()),
            ),

            // Short Break Slider
            _buildSliderTile(
              title: 'Short Break',
              subtitle: 'Rest between focus blocks',
              value: _shortBreak.toDouble(),
              min: 2,
              max: 15,
              divisions: 13,
              displayUnit: '$_shortBreak min',
              icon: Iconsax.coffee,
              color: Colors.tealAccent,
              onChanged: (val) => setState(() => _shortBreak = val.round()),
            ),

            // Long Break Slider
            _buildSliderTile(
              title: 'Long Break',
              subtitle: 'Deep recharge after a cycle',
              value: _longBreak.toDouble(),
              min: 10,
              max: 45,
              divisions: 7,
              displayUnit: '$_longBreak min',
              icon: Iconsax.sun_1,
              color: Colors.lightBlueAccent,
              onChanged: (val) => setState(() => _longBreak = val.round()),
            ),

            // Long Break Interval
            _buildSliderTile(
              title: 'Long Break Interval',
              subtitle: 'Sessions before a long break',
              value: _longBreakInterval.toDouble(),
              min: 2,
              max: 6,
              divisions: 4,
              displayUnit: 'Every $_longBreakInterval sessions',
              icon: Iconsax.repeat,
              color: Colors.amber,
              onChanged: (val) => setState(() => _longBreakInterval = val.round()),
            ),

            SizedBox(height: 8.h),
            const Divider(color: AppColors.textFieldBackgroundColor),
            SizedBox(height: 8.h),

            // Switches
            _buildSwitchTile(
              title: 'Auto-start Breaks',
              subtitle: 'Automatically start break when focus completes',
              value: _autoStartBreaks,
              onChanged: (val) => setState(() => _autoStartBreaks = val),
            ),
            _buildSwitchTile(
              title: 'Auto-start Focus',
              subtitle: 'Automatically start next focus when break ends',
              value: _autoStartFocus,
              onChanged: (val) => setState(() => _autoStartFocus = val),
            ),
            _buildSwitchTile(
              title: 'Sound & Haptic Alerts',
              subtitle: 'Chime & vibrate when timer completes',
              value: _soundEnabled,
              onChanged: (val) => setState(() => _soundEnabled = val),
            ),
            _buildSwitchTile(
              title: 'Log Focus to Task Comments',
              subtitle: 'Record completed sessions directly inside task notes',
              value: _logCommentToTask,
              onChanged: (val) => setState(() => _logCommentToTask = val),
            ),

            SizedBox(height: 20.h),
            SizedBox(
              width: double.infinity,
              height: 48.h,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primaryColor,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10.r)),
                ),
                onPressed: _saveSettings,
                child: const Text('Save Settings', style: TextStyle(color: Colors.white, fontSize: 16)),
              ),
            ),
            SizedBox(height: 10.h),
          ],
        ),
      ),
    );
  }

  Widget _buildSliderTile({
    required String title,
    required String subtitle,
    required double value,
    required double min,
    required double max,
    required int divisions,
    required String displayUnit,
    required IconData icon,
    required Color color,
    required ValueChanged<double> onChanged,
  }) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 8.h),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, size: 16, color: color),
              SizedBox(width: 8.w),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(title, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w600)),
                    Text(subtitle, style: const TextStyle(color: AppColors.lightGrey, fontSize: 11)),
                  ],
                ),
              ),
              Text(
                displayUnit,
                style: TextStyle(color: color, fontWeight: FontWeight.bold, fontSize: 13.sp),
              ),
            ],
          ),
          SliderTheme(
            data: SliderThemeData(
              activeTrackColor: color,
              thumbColor: color,
              inactiveTrackColor: AppColors.textFieldBackgroundColor,
              trackHeight: 3,
            ),
            child: Slider(
              value: value,
              min: min,
              max: max,
              divisions: divisions,
              onChanged: onChanged,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSwitchTile({
    required String title,
    required String subtitle,
    required bool value,
    required ValueChanged<bool> onChanged,
  }) {
    return SwitchListTile(
      contentPadding: EdgeInsets.zero,
      title: Text(title, style: const TextStyle(color: Colors.white, fontSize: 14)),
      subtitle: Text(subtitle, style: const TextStyle(color: AppColors.lightGrey, fontSize: 11)),
      value: value,
      activeTrackColor: AppColors.primaryColor,
      activeThumbColor: Colors.white,
      onChanged: onChanged,
    );
  }
}
