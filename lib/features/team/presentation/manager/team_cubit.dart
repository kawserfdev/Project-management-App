import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:task_manager_app/features/team/data/models/team_model.dart';
import 'package:task_manager_app/features/team/data/repos/team_repository.dart';
import 'package:task_manager_app/features/team/presentation/manager/team_state.dart';

class TeamCubit extends Cubit<TeamState> {
  final TeamRepository _repo;

  TeamCubit({required TeamRepository repository})
      : _repo = repository,
        super(const TeamInitial());

  Future<void> loadMyTeams() async {
    debugPrint('🎯 [TeamCubit] loadMyTeams: Triggered');
    emit(const TeamLoading());
    try {
      final teams = await _repo.getMyTeams();
      debugPrint('🎯 [TeamCubit] loadMyTeams: Loaded ${teams.length} teams');
      emit(TeamsLoaded(teams));
    } catch (e, stack) {
      debugPrint('❌ [TeamCubit] loadMyTeams: Error: $e\n$stack');
      emit(TeamError(e.toString()));
    }
  }

  Future<void> loadTeamDetail(TeamModel team) async {
    debugPrint('🎯 [TeamCubit] loadTeamDetail: Triggered for team "${team.name}" (ID: ${team.id})');
    emit(const TeamLoading());
    try {
      final members = await _repo.getTeamMembers(team.id);
      debugPrint('🎯 [TeamCubit] loadTeamDetail: Loaded ${members.length} members');
      emit(TeamDetailLoaded(team: team, members: members));
    } catch (e, stack) {
      debugPrint('❌ [TeamCubit] loadTeamDetail: Error: $e\n$stack');
      emit(TeamError(e.toString()));
    }
  }

  Future<void> createTeam({
    required String name,
    String description = '',
    int iconCode = 0xe3ae,
    int colorValue = 0xFF8687E7,
  }) async {
    debugPrint('🎯 [TeamCubit] createTeam: Triggered with name="$name"');
    emit(const TeamLoading());
    try {
      final team = await _repo.createTeam(
        name: name,
        description: description,
        iconCode: iconCode,
        colorValue: colorValue,
      );
      debugPrint('🎯 [TeamCubit] createTeam: Success! Team created ID: ${team.id}');
      emit(TeamActionSuccess(
          message: 'Team "${team.name}" created!', team: team));
    } catch (e, stack) {
      debugPrint('❌ [TeamCubit] createTeam: Error: $e\n$stack');
      emit(TeamError(e.toString()));
    }
  }

  Future<void> joinTeamByCode(String code) async {
    debugPrint('🎯 [TeamCubit] joinTeamByCode: Triggered with code="$code"');
    emit(const TeamLoading());
    try {
      final team = await _repo.joinTeamByCode(code);
      debugPrint('🎯 [TeamCubit] joinTeamByCode: Successfully joined "${team.name}"');
      emit(TeamActionSuccess(
          message: 'Joined "${team.name}" successfully!', team: team));
    } catch (e, stack) {
      debugPrint('❌ [TeamCubit] joinTeamByCode: Error: $e\n$stack');
      emit(TeamError(e.toString()));
    }
  }

  Future<void> leaveTeam(String teamId) async {
    debugPrint('🎯 [TeamCubit] leaveTeam: Triggered for teamId="$teamId"');
    try {
      await _repo.leaveTeam(teamId);
      debugPrint('🎯 [TeamCubit] leaveTeam: Successfully left team');
      emit(const TeamActionSuccess(message: 'Left team successfully.'));
    } catch (e, stack) {
      debugPrint('❌ [TeamCubit] leaveTeam: Error: $e\n$stack');
      emit(TeamError(e.toString()));
    }
  }

  Future<void> deleteTeam(String teamId) async {
    debugPrint('🎯 [TeamCubit] deleteTeam: Triggered for teamId="$teamId"');
    try {
      await _repo.deleteTeam(teamId);
      debugPrint('🎯 [TeamCubit] deleteTeam: Successfully deleted team');
      emit(const TeamActionSuccess(message: 'Team deleted.'));
    } catch (e, stack) {
      debugPrint('❌ [TeamCubit] deleteTeam: Error: $e\n$stack');
      emit(TeamError(e.toString()));
    }
  }

  Future<void> updateTeam(TeamModel team) async {
    debugPrint('🎯 [TeamCubit] updateTeam: Triggered for teamId="${team.id}"');
    try {
      await _repo.updateTeam(team);
      final members = await _repo.getTeamMembers(team.id);
      debugPrint('🎯 [TeamCubit] updateTeam: Successfully updated team');
      emit(TeamDetailLoaded(team: team, members: members));
    } catch (e, stack) {
      debugPrint('❌ [TeamCubit] updateTeam: Error: $e\n$stack');
      emit(TeamError(e.toString()));
    }
  }

  Future<void> removeMember(
      String teamId, String uid, TeamModel currentTeam) async {
    debugPrint('🎯 [TeamCubit] removeMember: Triggered for teamId="$teamId", uid="$uid"');
    try {
      await _repo.removeMember(teamId, uid);
      final updatedTeam = currentTeam.copyWith(
        memberUids: currentTeam.memberUids.where((id) => id != uid).toList(),
      );
      final members = await _repo.getTeamMembers(teamId);
      debugPrint('🎯 [TeamCubit] removeMember: Successfully removed member');
      emit(TeamDetailLoaded(team: updatedTeam, members: members));
    } catch (e, stack) {
      debugPrint('❌ [TeamCubit] removeMember: Error: $e\n$stack');
      emit(TeamError(e.toString()));
    }
  }

  Future<void> updateMemberRole(
      String teamId, String uid, TeamRole role, TeamModel currentTeam) async {
    debugPrint('🎯 [TeamCubit] updateMemberRole: Triggered for teamId="$teamId", uid="$uid", role="${role.name}"');
    try {
      await _repo.updateMemberRole(teamId, uid, role);
      final members = await _repo.getTeamMembers(teamId);
      debugPrint('🎯 [TeamCubit] updateMemberRole: Successfully updated role');
      emit(TeamDetailLoaded(team: currentTeam, members: members));
    } catch (e, stack) {
      debugPrint('❌ [TeamCubit] updateMemberRole: Error: $e\n$stack');
      emit(TeamError(e.toString()));
    }
  }

  Future<String?> regenerateInviteCode(
      String teamId, TeamModel currentTeam) async {
    debugPrint('🎯 [TeamCubit] regenerateInviteCode: Triggered for teamId="$teamId"');
    try {
      final newCode = await _repo.regenerateInviteCode(teamId);
      final updatedTeam = currentTeam.copyWith(inviteCode: newCode);
      final members = await _repo.getTeamMembers(teamId);
      debugPrint('🎯 [TeamCubit] regenerateInviteCode: New code generated: "$newCode"');
      emit(TeamDetailLoaded(team: updatedTeam, members: members));
      return newCode;
    } catch (e, stack) {
      debugPrint('❌ [TeamCubit] regenerateInviteCode: Error: $e\n$stack');
      emit(TeamError(e.toString()));
      return null;
    }
  }
}
