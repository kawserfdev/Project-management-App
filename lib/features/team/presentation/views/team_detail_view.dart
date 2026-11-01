import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:iconsax/iconsax.dart';
import 'package:task_manager_app/core/constants/app_colors.dart';
import 'package:task_manager_app/features/team/data/models/team_member_model.dart';
import 'package:task_manager_app/features/team/data/models/team_model.dart';
import 'package:task_manager_app/features/team/presentation/manager/team_cubit.dart';
import 'package:task_manager_app/features/team/presentation/manager/team_state.dart';
import 'package:task_manager_app/features/team/presentation/widgets/invite_code_card.dart';
import 'package:task_manager_app/features/team/presentation/widgets/member_tile.dart';

class TeamDetailView extends StatefulWidget {
  final TeamModel team;
  final TeamRole myRole;

  const TeamDetailView({
    super.key,
    required this.team,
    required this.myRole,
  });

  @override
  State<TeamDetailView> createState() => _TeamDetailViewState();
}

class _TeamDetailViewState extends State<TeamDetailView>
    with SingleTickerProviderStateMixin {
  late TabController _tabCtrl;

  @override
  void initState() {
    super.initState();
    _tabCtrl = TabController(length: 2, vsync: this);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<TeamCubit>().loadTeamDetail(widget.team);
    });
  }

  @override
  void dispose() {
    _tabCtrl.dispose();
    super.dispose();
  }

  bool get _isOwner => widget.myRole == TeamRole.owner;
  bool get _isOwnerOrAdmin =>
      widget.myRole == TeamRole.owner || widget.myRole == TeamRole.admin;

  void _confirmLeave(BuildContext context, TeamModel team) {
    debugPrint('⚙️ [TeamDetailView] User prompted to leave team "${team.name}" (ID: ${team.id})');
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppColors.textFieldBackgroundColor,
        title: const Text('Leave Team', style: TextStyle(color: Colors.white)),
        content: Text(
          'Are you sure you want to leave "${team.name}"?',
          style: const TextStyle(color: AppColors.lightGrey),
        ),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text('Cancel',
                  style: TextStyle(color: AppColors.lightGrey))),
          ElevatedButton(
            style:
                ElevatedButton.styleFrom(backgroundColor: AppColors.error),
            onPressed: () async {
              Navigator.pop(ctx);
              debugPrint('⚙️ [TeamDetailView] Leaving team "${team.name}" confirmed');
              await context.read<TeamCubit>().leaveTeam(team.id);
              if (context.mounted) Navigator.pop(context);
            },
            child: const Text('Leave'),
          ),
        ],
      ),
    );
  }

  void _confirmDelete(BuildContext context, TeamModel team) {
    debugPrint('⚙️ [TeamDetailView] User prompted to delete team "${team.name}" (ID: ${team.id})');
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppColors.textFieldBackgroundColor,
        title: const Text('Delete Team',
            style: TextStyle(color: Colors.red)),
        content: Text(
          'This will permanently delete "${team.name}" and remove all members. This cannot be undone.',
          style: const TextStyle(color: AppColors.lightGrey),
        ),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text('Cancel',
                  style: TextStyle(color: AppColors.lightGrey))),
          ElevatedButton(
            style:
                ElevatedButton.styleFrom(backgroundColor: AppColors.error),
            onPressed: () async {
              Navigator.pop(ctx);
              debugPrint('⚙️ [TeamDetailView] Deleting team "${team.name}" confirmed');
              await context.read<TeamCubit>().deleteTeam(team.id);
              if (context.mounted) Navigator.pop(context);
            },
            child: const Text('Delete Forever'),
          ),
        ],
      ),
    );
  }

  void _showEditTeamSheet(BuildContext context, TeamModel team) {
    final nameCtrl = TextEditingController(text: team.name);
    final descCtrl = TextEditingController(text: team.description);
    int selectedIcon = team.iconCode;
    int selectedColor = team.colorValue;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (sheetCtx) => StatefulBuilder(
        builder: (ctx, setSheetState) => Container(
          decoration: BoxDecoration(
            color: AppColors.textFieldBackgroundColor,
            borderRadius: BorderRadius.vertical(top: Radius.circular(20.r)),
          ),
          padding: EdgeInsets.fromLTRB(20.w, 16.h, 20.w,
              MediaQuery.of(context).viewInsets.bottom + 20.h),
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(
                  child: Container(
                    width: 40.w,
                    height: 4.h,
                    decoration: BoxDecoration(
                        color: AppColors.lightGrey.withValues(alpha: 0.4),
                        borderRadius: BorderRadius.circular(2.r)),
                  ),
                ),
                SizedBox(height: 16.h),
                Text('Edit Team',
                    style: TextStyle(
                        color: Colors.white,
                        fontSize: 18.sp,
                        fontWeight: FontWeight.bold)),
                SizedBox(height: 20.h),
                TextField(
                  controller: nameCtrl,
                  style: const TextStyle(color: Colors.white),
                  decoration: InputDecoration(
                    labelText: 'Team Name',
                    labelStyle:
                        const TextStyle(color: AppColors.lightGrey),
                    filled: true,
                    fillColor: AppColors.darkBlue,
                    border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10.r)),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10.r),
                      borderSide: const BorderSide(
                          color: AppColors.primaryColor),
                    ),
                  ),
                ),
                SizedBox(height: 12.h),
                TextField(
                  controller: descCtrl,
                  maxLines: 2,
                  style: const TextStyle(color: Colors.white),
                  decoration: InputDecoration(
                    labelText: 'Description',
                    labelStyle:
                        const TextStyle(color: AppColors.lightGrey),
                    filled: true,
                    fillColor: AppColors.darkBlue,
                    border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10.r)),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10.r),
                      borderSide: const BorderSide(
                          color: AppColors.primaryColor),
                    ),
                  ),
                ),
                SizedBox(height: 14.h),
                Text('Icon',
                    style: TextStyle(
                        color: AppColors.lightGrey, fontSize: 13.sp)),
                SizedBox(height: 8.h),
                SizedBox(
                  height: 52.h,
                  child: ListView(
                    scrollDirection: Axis.horizontal,
                    children: TeamModel.availableIcons.map((item) {
                      final code = item['code'] as int;
                      final icon = item['icon'] as IconData;
                      final selected = selectedIcon == code;
                      return GestureDetector(
                        onTap: () =>
                            setSheetState(() => selectedIcon = code),
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 150),
                          margin: EdgeInsets.only(right: 8.w),
                          width: 48.w,
                          height: 48.h,
                          decoration: BoxDecoration(
                            color: selected
                                ? AppColors.primaryColor
                                    .withValues(alpha: 0.2)
                                : AppColors.darkBlue,
                            borderRadius: BorderRadius.circular(10.r),
                            border: Border.all(
                              color: selected
                                  ? AppColors.primaryColor
                                  : AppColors.dividerColor
                                      .withValues(alpha: 0.4),
                            ),
                          ),
                          child: Icon(icon,
                              color: selected
                                  ? AppColors.primaryColor
                                  : AppColors.lightGrey,
                              size: 22.r),
                        ),
                      );
                    }).toList(),
                  ),
                ),
                SizedBox(height: 14.h),
                Text('Color',
                    style: TextStyle(
                        color: AppColors.lightGrey, fontSize: 13.sp)),
                SizedBox(height: 8.h),
                Row(
                  children: TeamModel.availableColors.map((c) {
                    final val = c.toARGB32();
                    final selected = selectedColor == val;
                    return GestureDetector(
                      onTap: () =>
                          setSheetState(() => selectedColor = val),
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 150),
                        margin: EdgeInsets.only(right: 10.w),
                        width: 30.w,
                        height: 30.w,
                        decoration: BoxDecoration(
                          color: c,
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: selected
                                ? Colors.white
                                : Colors.transparent,
                            width: 2.5,
                          ),
                        ),
                        child: selected
                            ? const Icon(Icons.check,
                                color: Colors.white, size: 16)
                            : null,
                      ),
                    );
                  }).toList(),
                ),
                SizedBox(height: 24.h),
                SizedBox(
                  width: double.infinity,
                  height: 50.h,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primaryColor,
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12.r)),
                    ),
                    onPressed: () {
                      final updated = team.copyWith(
                        name: nameCtrl.text.trim().isEmpty
                            ? team.name
                            : nameCtrl.text.trim(),
                        description: descCtrl.text.trim(),
                        iconCode: selectedIcon,
                        colorValue: selectedColor,
                      );
                      debugPrint('⚙️ [TeamDetailView] Save changes: "${updated.name}"');
                      context.read<TeamCubit>().updateTeam(updated);
                      Navigator.pop(sheetCtx);
                    },
                    child: Text('Save Changes',
                        style: TextStyle(
                            color: Colors.white,
                            fontSize: 16.sp,
                            fontWeight: FontWeight.bold)),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<TeamCubit, TeamState>(
      builder: (context, state) {
        final team = state is TeamDetailLoaded ? state.team : widget.team;
        final members =
            state is TeamDetailLoaded ? state.members : <TeamMemberModel>[];
        final currentUid = FirebaseAuth.instance.currentUser?.uid ?? '';
        final teamColor = team.color;

        return Scaffold(
          backgroundColor: AppColors.darkBlue,
          appBar: AppBar(
            backgroundColor: AppColors.darkBlue,
            leading: IconButton(
              icon: const Icon(Icons.arrow_back_ios_new_rounded,
                  color: Colors.white),
              onPressed: () => Navigator.pop(context),
            ),
            title: Row(
              children: [
                Container(
                  width: 32.w,
                  height: 32.w,
                  decoration: BoxDecoration(
                    color: teamColor.withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(8.r),
                  ),
                  child: Icon(team.icon, color: teamColor, size: 18.r),
                ),
                SizedBox(width: 10.w),
                Flexible(
                  child: Text(
                    team.name,
                    style: const TextStyle(
                        color: Colors.white, fontWeight: FontWeight.bold),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
            actions: [
              if (_isOwner)
                IconButton(
                  tooltip: 'Edit Team',
                  icon: const Icon(Iconsax.edit, color: AppColors.lightGrey),
                  onPressed: () => _showEditTeamSheet(context, team),
                ),
            ],
            bottom: TabBar(
              controller: _tabCtrl,
              indicatorColor: AppColors.primaryColor,
              labelColor: AppColors.primaryColor,
              unselectedLabelColor: AppColors.lightGrey,
              tabs: const [
                Tab(text: 'Members'),
                Tab(text: 'Settings'),
              ],
            ),
          ),
          body: state is TeamLoading
              ? const Center(
                  child: CircularProgressIndicator(
                      color: AppColors.primaryColor))
              : TabBarView(
                  controller: _tabCtrl,
                  children: [
                    _MembersTab(
                      team: team,
                      members: members,
                      isOwner: _isOwner,
                      isOwnerOrAdmin: _isOwnerOrAdmin,
                      currentUid: currentUid,
                    ),
                    _SettingsTab(
                      team: team,
                      isOwner: _isOwner,
                      onLeave: () => _confirmLeave(context, team),
                      onDelete: () => _confirmDelete(context, team),
                    ),
                  ],
                ),
        );
      },
    );
  }
}

class _MembersTab extends StatelessWidget {
  final TeamModel team;
  final List<TeamMemberModel> members;
  final bool isOwner;
  final bool isOwnerOrAdmin;
  final String currentUid;

  const _MembersTab({
    required this.team,
    required this.members,
    required this.isOwner,
    required this.isOwnerOrAdmin,
    required this.currentUid,
  });

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: EdgeInsets.only(top: 12.h, bottom: 40.h),
      children: [
        InviteCodeCard(
          inviteCode: team.inviteCode,
          isOwner: isOwner,
          onRegenerate: isOwner
              ? () async {
                  debugPrint('⚙️ [TeamDetailView] User requested new invite code');
                  final newCode = await context
                      .read<TeamCubit>()
                      .regenerateInviteCode(team.id, team);
                  if (context.mounted && newCode != null) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('New invite code generated!'),
                        backgroundColor: AppColors.success,
                        behavior: SnackBarBehavior.floating,
                      ),
                    );
                  }
                }
              : null,
        ),
        SizedBox(height: 8.h),
        Padding(
          padding: EdgeInsets.symmetric(horizontal: 16.w),
          child: Text(
            '${members.length} Member${members.length != 1 ? 's' : ''}',
            style: TextStyle(
                color: AppColors.lightGrey,
                fontSize: 12.sp,
                fontWeight: FontWeight.w500),
          ),
        ),
        SizedBox(height: 6.h),
        ...members.map((member) => MemberTile(
              member: member,
              isCurrentUserOwner: isOwner,
              onRemove: () {
                debugPrint('⚙️ [TeamDetailView] User removed member ${member.displayName} (${member.uid})');
                context
                    .read<TeamCubit>()
                    .removeMember(team.id, member.uid, team);
              },
              onChangeRole: (newRole) {
                debugPrint('⚙️ [TeamDetailView] User changed member ${member.displayName} role to ${newRole.name}');
                context
                    .read<TeamCubit>()
                    .updateMemberRole(team.id, member.uid, newRole, team);
              },
            )),
      ],
    );
  }
}

class _SettingsTab extends StatelessWidget {
  final TeamModel team;
  final bool isOwner;
  final VoidCallback onLeave;
  final VoidCallback onDelete;

  const _SettingsTab({
    required this.team,
    required this.isOwner,
    required this.onLeave,
    required this.onDelete,
  });

  Widget _settingTile({
    required IconData icon,
    required String title,
    String? subtitle,
    required VoidCallback onTap,
    Color? color,
  }) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      decoration: BoxDecoration(
        color: AppColors.textFieldBackgroundColor,
        borderRadius: BorderRadius.circular(10),
      ),
      child: ListTile(
        leading: Icon(icon, color: color ?? AppColors.primaryColor),
        title: Text(title,
            style: TextStyle(color: color ?? Colors.white, fontSize: 15)),
        subtitle: subtitle != null
            ? Text(subtitle,
                style: const TextStyle(color: AppColors.lightGrey, fontSize: 12))
            : null,
        trailing: const Icon(Icons.arrow_forward_ios,
            size: 14, color: AppColors.lightGrey),
        onTap: onTap,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.only(top: 16, bottom: 40),
      children: [
        const Padding(
          padding: EdgeInsets.symmetric(horizontal: 16, vertical: 4),
          child: Text('Team Info',
              style: TextStyle(
                  color: AppColors.lightGrey,
                  fontSize: 12,
                  fontWeight: FontWeight.w600)),
        ),
        Container(
          margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: AppColors.textFieldBackgroundColor,
            borderRadius: BorderRadius.circular(10),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: team.color.withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Icon(team.icon, color: team.color, size: 22),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(team.name,
                            style: const TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                                fontSize: 16)),
                        if (team.description.isNotEmpty)
                          Text(team.description,
                              style: const TextStyle(
                                  color: AppColors.lightGrey, fontSize: 13)),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              Text(
                'Created ${_formatDate(team.createdAt)}  ·  ${team.memberUids.length} members',
                style: const TextStyle(color: AppColors.lightGrey, fontSize: 11),
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),
        const Padding(
          padding: EdgeInsets.symmetric(horizontal: 16, vertical: 4),
          child: Text('Danger Zone',
              style: TextStyle(
                  color: AppColors.error,
                  fontSize: 12,
                  fontWeight: FontWeight.w600)),
        ),
        if (!isOwner)
          _settingTile(
            icon: Icons.exit_to_app_rounded,
            title: 'Leave Team',
            subtitle: 'You will be removed from this team',
            color: AppColors.error,
            onTap: onLeave,
          ),
        if (isOwner)
          _settingTile(
            icon: Icons.delete_forever_rounded,
            title: 'Delete Team',
            subtitle:
                'Permanently deletes the team and removes all members',
            color: AppColors.error,
            onTap: onDelete,
          ),
      ],
    );
  }

  String _formatDate(DateTime date) {
    final months = [
      'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'
    ];
    return '${months[date.month - 1]} ${date.day}, ${date.year}';
  }
}

