import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:iconsax/iconsax.dart';
import 'package:task_manager_app/core/constants/app_colors.dart';
import 'package:task_manager_app/core/di/service_locator.dart';
import 'package:task_manager_app/features/team/data/models/team_model.dart';
import 'package:task_manager_app/features/team/presentation/manager/team_cubit.dart';
import 'package:task_manager_app/features/team/presentation/manager/team_state.dart';
import 'package:task_manager_app/features/team/presentation/views/team_detail_view.dart';
import 'package:task_manager_app/features/team/presentation/widgets/create_team_sheet.dart';
import 'package:task_manager_app/features/team/presentation/widgets/join_team_dialog.dart';
import 'package:task_manager_app/features/team/presentation/widgets/team_card.dart';

class TeamsHubView extends StatelessWidget {
  const TeamsHubView({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => getIt<TeamCubit>()..loadMyTeams(),
      child: const _TeamsHubContent(),
    );
  }
}

class _TeamsHubContent extends StatelessWidget {
  const _TeamsHubContent();

  void _openCreateTeam(BuildContext context) {
    debugPrint('👥 [TeamsHubView] Opening Create Team');
    final isWide = MediaQuery.of(context).size.width >= 650;
    if (isWide) {
      showDialog(
        context: context,
        builder: (_) => BlocProvider.value(
          value: context.read<TeamCubit>(),
          child: const Dialog(
            backgroundColor: Colors.transparent,
            insetPadding: EdgeInsets.symmetric(horizontal: 24, vertical: 24),
            child: CreateTeamSheet(),
          ),
        ),
      ).then((team) {
        if (team != null && context.mounted) {
          debugPrint('👥 [TeamsHubView] Create Team dialog closed with result, reloading teams');
          context.read<TeamCubit>().loadMyTeams();
        }
      });
    } else {
      showModalBottomSheet(
        context: context,
        isScrollControlled: true,
        backgroundColor: Colors.transparent,
        builder: (_) => BlocProvider.value(
          value: context.read<TeamCubit>(),
          child: const CreateTeamSheet(),
        ),
      ).then((team) {
        if (team != null && context.mounted) {
          debugPrint('👥 [TeamsHubView] Create Team sheet closed with result, reloading teams');
          context.read<TeamCubit>().loadMyTeams();
        }
      });
    }
  }

  void _openJoinTeam(BuildContext context) {
    debugPrint('👥 [TeamsHubView] Opening Join Team dialog');
    showDialog(
      context: context,
      builder: (_) => BlocProvider.value(
        value: context.read<TeamCubit>(),
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 480),
            child: const JoinTeamDialog(),
          ),
        ),
      ),
    ).then((team) {
      if (team != null && context.mounted) {
        debugPrint('👥 [TeamsHubView] Join Team dialog closed with result, reloading teams');
        context.read<TeamCubit>().loadMyTeams();
      }
    });
  }

  void _openTeamDetail(BuildContext context, TeamModel team, TeamRole role) {
    debugPrint('👥 [TeamsHubView] Navigating to TeamDetailView: "${team.name}" (ID: ${team.id}), role: ${role.name}');
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => BlocProvider.value(
          value: context.read<TeamCubit>(),
          child: TeamDetailView(team: team, myRole: role),
        ),
      ),
    ).then((_) {
      if (context.mounted) {
        debugPrint('👥 [TeamsHubView] Returned from TeamDetailView, reloading teams');
        context.read<TeamCubit>().loadMyTeams();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final currentUid = FirebaseAuth.instance.currentUser?.uid ?? '';

    return Scaffold(
      appBar: AppBar(
        backgroundColor: AppColors.darkBlue,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text('My Teams',
            style: TextStyle(
                color: Colors.white, fontWeight: FontWeight.bold)),
        centerTitle: false,
        actions: [
          IconButton(
            tooltip: 'Join by Code',
            icon: const Icon(Iconsax.add_square, color: AppColors.primaryColor),
            onPressed: () => _openJoinTeam(context),
          ),
        ],
      ),
      backgroundColor: AppColors.darkBlue,
      floatingActionButton: FloatingActionButton.extended(
        backgroundColor: AppColors.primaryColor,
        icon: const Icon(Icons.group_add_rounded, color: Colors.white),
        label: const Text('Create Team',
            style:
                TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        onPressed: () => _openCreateTeam(context),
      ),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 1150),
          child: BlocBuilder<TeamCubit, TeamState>(
            builder: (context, state) {
              if (state is TeamLoading) {
                return const Center(
                  child: CircularProgressIndicator(color: AppColors.primaryColor),
                );
              }

              if (state is TeamError) {
                return Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.error_outline,
                          color: AppColors.error, size: 48),
                      SizedBox(height: 12.h),
                      Text(state.message,
                          style: const TextStyle(color: AppColors.lightGrey)),
                      SizedBox(height: 12.h),
                      TextButton(
                        onPressed: () =>
                            context.read<TeamCubit>().loadMyTeams(),
                        child: const Text('Retry',
                            style:
                                TextStyle(color: AppColors.primaryColor)),
                      ),
                    ],
                  ),
                );
              }

              final teams = state is TeamsLoaded ? state.teams : <TeamModel>[];

              if (teams.isEmpty) {
                return Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.group_outlined,
                          size: 72.r,
                          color: AppColors.lightGrey.withValues(alpha: 0.4)),
                      SizedBox(height: 16.h),
                      Text(
                        "You're not in any team yet",
                        style: TextStyle(
                            color: Colors.white,
                            fontSize: 18.sp,
                            fontWeight: FontWeight.w600),
                      ),
                      SizedBox(height: 8.h),
                      Text(
                        'Create a new team or join one with an invite code',
                        style: TextStyle(
                            color: AppColors.lightGrey, fontSize: 13.sp),
                        textAlign: TextAlign.center,
                      ),
                      SizedBox(height: 24.h),
                      OutlinedButton.icon(
                        icon: const Icon(Icons.vpn_key_outlined,
                            color: AppColors.primaryColor, size: 16),
                        label: const Text('Join by Code',
                            style: TextStyle(color: AppColors.primaryColor)),
                        style: OutlinedButton.styleFrom(
                          side: const BorderSide(color: AppColors.primaryColor),
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8.r)),
                        ),
                        onPressed: () => _openJoinTeam(context),
                      ),
                    ],
                  ),
                );
              }

              return LayoutBuilder(
                builder: (context, constraints) {
                  final isDesktop = constraints.maxWidth >= 950;
                  final isTablet = constraints.maxWidth >= 600 && !isDesktop;

                  if (isDesktop || isTablet) {
                    final columns = isDesktop ? 3 : 2;
                    return RefreshIndicator(
                      color: AppColors.primaryColor,
                      onRefresh: () => context.read<TeamCubit>().loadMyTeams(),
                      child: GridView.builder(
                        padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 16.h),
                        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: columns,
                          crossAxisSpacing: 16.w,
                          mainAxisSpacing: 16.h,
                          mainAxisExtent: 130.h,
                        ),
                        itemCount: teams.length,
                        itemBuilder: (context, index) {
                          final team = teams[index];
                          final myRole = team.ownerId == currentUid
                              ? TeamRole.owner
                              : TeamRole.member;
                          return TeamCard(
                            team: team,
                            myRole: myRole,
                            margin: EdgeInsets.zero,
                            onTap: () => _openTeamDetail(context, team, myRole),
                          );
                        },
                      ),
                    );
                  }

                  // Mobile list layout
                  return RefreshIndicator(
                    color: AppColors.primaryColor,
                    onRefresh: () => context.read<TeamCubit>().loadMyTeams(),
                    child: ListView.builder(
                      padding: EdgeInsets.only(top: 8.h, bottom: 100.h),
                      itemCount: teams.length,
                      itemBuilder: (context, index) {
                        final team = teams[index];
                        final myRole = team.ownerId == currentUid
                            ? TeamRole.owner
                            : TeamRole.member;
                        return TeamCard(
                          team: team,
                          myRole: myRole,
                          onTap: () => _openTeamDetail(context, team, myRole),
                        );
                      },
                    ),
                  );
                },
              );
            },
          ),
        ),
      ),
    );
  }
}

