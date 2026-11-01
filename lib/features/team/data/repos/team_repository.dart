import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:task_manager_app/features/team/data/datasources/team_remote_data_source.dart';
import 'package:task_manager_app/features/team/data/models/team_member_model.dart';
import 'package:task_manager_app/features/team/data/models/team_model.dart';

abstract class TeamRepository {
  Future<TeamModel> createTeam({
    required String name,
    String description,
    int iconCode,
    int colorValue,
  });
  Future<List<TeamModel>> getMyTeams();
  Future<TeamModel> joinTeamByCode(String code);
  Future<void> leaveTeam(String teamId);
  Future<void> updateTeam(TeamModel team);
  Future<void> deleteTeam(String teamId);
  Future<List<TeamMemberModel>> getTeamMembers(String teamId);
  Future<void> removeMember(String teamId, String uid);
  Future<void> updateMemberRole(String teamId, String uid, TeamRole role);
  Future<String> regenerateInviteCode(String teamId);
}

class TeamRepositoryImpl implements TeamRepository {
  final TeamRemoteDataSource _remote;

  TeamRepositoryImpl({required TeamRemoteDataSource remote}) : _remote = remote;

  String get _currentUid =>
      FirebaseAuth.instance.currentUser?.uid ?? 'anonymous';
  String get _currentDisplayName =>
      FirebaseAuth.instance.currentUser?.displayName ?? 'You';
  String get _currentEmail =>
      FirebaseAuth.instance.currentUser?.email ?? '';
  String? get _currentPhotoUrl =>
      FirebaseAuth.instance.currentUser?.photoURL;

  @override
  Future<TeamModel> createTeam({
    required String name,
    String description = '',
    int iconCode = 0xe3ae,
    int colorValue = 0xFF8687E7,
  }) async {
    final uid = _currentUid;
    debugPrint('💼 [TeamRepository] createTeam: User "$uid" (name: $_currentDisplayName) creating team "$name"');
    final team = TeamModel(
      id: '',
      name: name.trim(),
      description: description.trim(),
      ownerId: uid,
      memberUids: [uid],
      inviteCode: TeamModel.generateInviteCode(),
      iconCode: iconCode,
      colorValue: colorValue,
      createdAt: DateTime.now(),
    );
    final created = await _remote.createTeam(team);
    // Add creator as owner member
    await _remote.addMember(
      created.id,
      TeamMemberModel(
        uid: uid,
        displayName: _currentDisplayName,
        email: _currentEmail,
        photoUrl: _currentPhotoUrl,
        role: TeamRole.owner,
        joinedAt: DateTime.now(),
      ),
    );
    debugPrint('💼 [TeamRepository] createTeam: Success! Team created with ID: ${created.id}');
    return created;
  }

  @override
  Future<List<TeamModel>> getMyTeams() async {
    final uid = _currentUid;
    debugPrint('💼 [TeamRepository] getMyTeams: Fetching teams for user "$uid"');
    final teams = await _remote.getMyTeams(uid);
    debugPrint('💼 [TeamRepository] getMyTeams: Returned ${teams.length} teams');
    return teams;
  }

  @override
  Future<TeamModel> joinTeamByCode(String code) async {
    final uid = _currentUid;
    final cleanCode = code.toUpperCase().trim();
    debugPrint('💼 [TeamRepository] joinTeamByCode: User "$uid" joining with code "$cleanCode"');
    final team = await _remote.getTeamByInviteCode(cleanCode);
    if (team == null) {
      debugPrint('⚠️ [TeamRepository] joinTeamByCode: No team found with code "$cleanCode"');
      throw Exception('Team not found. Please check the invite code.');
    }
    if (team.memberUids.contains(uid)) {
      debugPrint('⚠️ [TeamRepository] joinTeamByCode: User "$uid" already in team "${team.name}"');
      throw Exception('You are already a member of this team.');
    }
    // Add self as member
    await _remote.addMember(
      team.id,
      TeamMemberModel(
        uid: uid,
        displayName: _currentDisplayName,
        email: _currentEmail,
        photoUrl: _currentPhotoUrl,
        role: TeamRole.member,
        joinedAt: DateTime.now(),
      ),
    );
    final updatedUids = [...team.memberUids, uid];
    await _remote.updateTeamMemberUids(team.id, updatedUids);
    debugPrint('💼 [TeamRepository] joinTeamByCode: Successfully joined team "${team.name}" (ID: ${team.id})');
    return team.copyWith(memberUids: updatedUids);
  }

  @override
  Future<void> leaveTeam(String teamId) async {
    final uid = _currentUid;
    debugPrint('💼 [TeamRepository] leaveTeam: User "$uid" leaving team "$teamId"');
    await _remote.removeMember(teamId, uid);
    final doc = await FirebaseFirestore.instance
        .collection('teams')
        .doc(teamId)
        .get();
    if (doc.exists) {
      final currentUids = List<String>.from(
          doc.data()?['memberUids'] as List? ?? []);
      final updated = currentUids.where((id) => id != uid).toList();
      await _remote.updateTeamMemberUids(teamId, updated);
    }
    debugPrint('💼 [TeamRepository] leaveTeam: Completed leaving team "$teamId"');
  }

  @override
  Future<void> updateTeam(TeamModel team) async {
    debugPrint('💼 [TeamRepository] updateTeam: Updating team "${team.name}" (ID: ${team.id})');
    await _remote.updateTeam(team);
    debugPrint('💼 [TeamRepository] updateTeam: Completed');
  }

  @override
  Future<void> deleteTeam(String teamId) async {
    debugPrint('💼 [TeamRepository] deleteTeam: Deleting team "$teamId"');
    await _remote.deleteTeam(teamId);
    debugPrint('💼 [TeamRepository] deleteTeam: Completed');
  }

  @override
  Future<List<TeamMemberModel>> getTeamMembers(String teamId) async {
    debugPrint('💼 [TeamRepository] getTeamMembers: Fetching members for team "$teamId"');
    final members = await _remote.getTeamMembers(teamId);
    debugPrint('💼 [TeamRepository] getTeamMembers: Found ${members.length} members');
    return members;
  }

  @override
  Future<void> removeMember(String teamId, String uid) async {
    debugPrint('💼 [TeamRepository] removeMember: Removing member "$uid" from team "$teamId"');
    await _remote.removeMember(teamId, uid);
    final doc = await FirebaseFirestore.instance
        .collection('teams')
        .doc(teamId)
        .get();
    if (doc.exists) {
      final currentUids = List<String>.from(
          doc.data()?['memberUids'] as List? ?? []);
      final updated = currentUids.where((id) => id != uid).toList();
      await _remote.updateTeamMemberUids(teamId, updated);
    }
    debugPrint('💼 [TeamRepository] removeMember: Completed removing member');
  }

  @override
  Future<void> updateMemberRole(
      String teamId, String uid, TeamRole role) async {
    debugPrint('💼 [TeamRepository] updateMemberRole: Setting role "${role.name}" for member "$uid" in team "$teamId"');
    await _remote.updateMemberRole(teamId, uid, role);
    debugPrint('💼 [TeamRepository] updateMemberRole: Completed');
  }

  @override
  Future<String> regenerateInviteCode(String teamId) async {
    final newCode = TeamModel.generateInviteCode();
    debugPrint('💼 [TeamRepository] regenerateInviteCode: Generated new code "$newCode" for team "$teamId"');
    await FirebaseFirestore.instance
        .collection('teams')
        .doc(teamId)
        .update({'inviteCode': newCode});
    debugPrint('💼 [TeamRepository] regenerateInviteCode: Saved to Firestore');
    return newCode;
  }
}
