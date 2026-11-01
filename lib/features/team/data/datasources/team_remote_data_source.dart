import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:task_manager_app/features/team/data/models/team_member_model.dart';
import 'package:task_manager_app/features/team/data/models/team_model.dart';

abstract class TeamRemoteDataSource {
  Future<TeamModel> createTeam(TeamModel team);
  Future<List<TeamModel>> getMyTeams(String userId);
  Future<TeamModel?> getTeamByInviteCode(String code);
  Future<void> updateTeam(TeamModel team);
  Future<void> deleteTeam(String teamId);
  Future<void> addMember(String teamId, TeamMemberModel member);
  Future<void> removeMember(String teamId, String uid);
  Future<void> updateMemberRole(String teamId, String uid, TeamRole role);
  Future<List<TeamMemberModel>> getTeamMembers(String teamId);
  Future<void> updateTeamMemberUids(String teamId, List<String> memberUids);
}

class TeamRemoteDataSourceImpl implements TeamRemoteDataSource {
  final FirebaseFirestore _firestore;

  TeamRemoteDataSourceImpl({FirebaseFirestore? firestore})
      : _firestore = firestore ?? FirebaseFirestore.instance;

  CollectionReference<Map<String, dynamic>> get _teamsRef =>
      _firestore.collection('teams');

  @override
  Future<TeamModel> createTeam(TeamModel team) async {
    debugPrint('📡 [TeamDataSource] createTeam: Starting creation for "${team.name}" (owner: ${team.ownerId})');
    try {
      final docRef = _teamsRef.doc(team.id.isEmpty ? null : team.id);
      final finalTeam = team.id.isEmpty ? team.copyWith(id: docRef.id) : team;
      await docRef.set(finalTeam.toMap());
      debugPrint('✅ [TeamDataSource] createTeam: Success! Doc ID: ${finalTeam.id}, InviteCode: ${finalTeam.inviteCode}');
      return finalTeam;
    } catch (e, stack) {
      debugPrint('❌ [TeamDataSource] createTeam: Failed: $e\n$stack');
      rethrow;
    }
  }

  @override
  Future<List<TeamModel>> getMyTeams(String userId) async {
    debugPrint('📡 [TeamDataSource] getMyTeams: Fetching teams where member contains $userId');
    try {
      QuerySnapshot<Map<String, dynamic>> snap;
      try {
        snap = await _teamsRef
            .where('memberUids', arrayContains: userId)
            .orderBy('createdAt', descending: true)
            .get();
      } catch (orderErr) {
        debugPrint('⚠️ [TeamDataSource] getMyTeams: orderBy failed (possible missing index), retrying without order: $orderErr');
        snap = await _teamsRef
            .where('memberUids', arrayContains: userId)
            .get();
      }
      final teams = snap.docs.map((d) => TeamModel.fromMap(d.data(), d.id)).toList();
      debugPrint('✅ [TeamDataSource] getMyTeams: Found ${teams.length} teams for user $userId');
      return teams;
    } catch (e, stack) {
      debugPrint('❌ [TeamDataSource] getMyTeams: Error: $e\n$stack');
      return [];
    }
  }

  @override
  Future<TeamModel?> getTeamByInviteCode(String code) async {
    final cleanCode = code.toUpperCase().trim();
    debugPrint('📡 [TeamDataSource] getTeamByInviteCode: Searching for code "$cleanCode"');
    try {
      final snap = await _teamsRef
          .where('inviteCode', isEqualTo: cleanCode)
          .limit(1)
          .get();
      if (snap.docs.isEmpty) {
        debugPrint('⚠️ [TeamDataSource] getTeamByInviteCode: No team found with code "$cleanCode"');
        return null;
      }
      final doc = snap.docs.first;
      final team = TeamModel.fromMap(doc.data(), doc.id);
      debugPrint('✅ [TeamDataSource] getTeamByInviteCode: Found team "${team.name}" (ID: ${team.id})');
      return team;
    } catch (e, stack) {
      debugPrint('❌ [TeamDataSource] getTeamByInviteCode: Error: $e\n$stack');
      return null;
    }
  }

  @override
  Future<void> updateTeam(TeamModel team) async {
    debugPrint('📡 [TeamDataSource] updateTeam: Updating team ${team.id} ("${team.name}")');
    try {
      await _teamsRef.doc(team.id).update(team.toMap());
      debugPrint('✅ [TeamDataSource] updateTeam: Updated successfully');
    } catch (e, stack) {
      debugPrint('❌ [TeamDataSource] updateTeam: Error: $e\n$stack');
      rethrow;
    }
  }

  @override
  Future<void> deleteTeam(String teamId) async {
    debugPrint('📡 [TeamDataSource] deleteTeam: Deleting team $teamId and subcollections');
    try {
      final membersSnap =
          await _teamsRef.doc(teamId).collection('members').get();
      final batch = _firestore.batch();
      for (final doc in membersSnap.docs) {
        batch.delete(doc.reference);
      }
      batch.delete(_teamsRef.doc(teamId));
      await batch.commit();
      debugPrint('✅ [TeamDataSource] deleteTeam: Team $teamId and ${membersSnap.docs.length} members deleted');
    } catch (e, stack) {
      debugPrint('❌ [TeamDataSource] deleteTeam: Error: $e\n$stack');
      rethrow;
    }
  }

  @override
  Future<void> addMember(String teamId, TeamMemberModel member) async {
    debugPrint('📡 [TeamDataSource] addMember: Adding ${member.displayName} (${member.uid}) with role ${member.role.name} to team $teamId');
    try {
      await _teamsRef
          .doc(teamId)
          .collection('members')
          .doc(member.uid)
          .set(member.toMap());
      debugPrint('✅ [TeamDataSource] addMember: Successfully added member');
    } catch (e, stack) {
      debugPrint('❌ [TeamDataSource] addMember: Error: $e\n$stack');
      rethrow;
    }
  }

  @override
  Future<void> removeMember(String teamId, String uid) async {
    debugPrint('📡 [TeamDataSource] removeMember: Removing member $uid from team $teamId');
    try {
      await _teamsRef.doc(teamId).collection('members').doc(uid).delete();
      debugPrint('✅ [TeamDataSource] removeMember: Member removed successfully');
    } catch (e, stack) {
      debugPrint('❌ [TeamDataSource] removeMember: Error: $e\n$stack');
      rethrow;
    }
  }

  @override
  Future<void> updateMemberRole(
      String teamId, String uid, TeamRole role) async {
    debugPrint('📡 [TeamDataSource] updateMemberRole: Setting role=${role.name} for member $uid in team $teamId');
    try {
      await _teamsRef
          .doc(teamId)
          .collection('members')
          .doc(uid)
          .update({'role': role.name});
      debugPrint('✅ [TeamDataSource] updateMemberRole: Role updated successfully');
    } catch (e, stack) {
      debugPrint('❌ [TeamDataSource] updateMemberRole: Error: $e\n$stack');
      rethrow;
    }
  }

  @override
  Future<List<TeamMemberModel>> getTeamMembers(String teamId) async {
    debugPrint('📡 [TeamDataSource] getTeamMembers: Fetching members for team $teamId');
    try {
      final snap =
          await _teamsRef.doc(teamId).collection('members').get();
      final members = snap.docs
          .map((d) => TeamMemberModel.fromMap(d.data()))
          .toList();
      debugPrint('✅ [TeamDataSource] getTeamMembers: Found ${members.length} members for team $teamId');
      return members;
    } catch (e, stack) {
      debugPrint('❌ [TeamDataSource] getTeamMembers: Error: $e\n$stack');
      return [];
    }
  }

  @override
  Future<void> updateTeamMemberUids(
      String teamId, List<String> memberUids) async {
    debugPrint('📡 [TeamDataSource] updateTeamMemberUids: Team $teamId uids: $memberUids');
    try {
      await _teamsRef.doc(teamId).update({'memberUids': memberUids});
      debugPrint('✅ [TeamDataSource] updateTeamMemberUids: Updated memberUids');
    } catch (e, stack) {
      debugPrint('❌ [TeamDataSource] updateTeamMemberUids: Error: $e\n$stack');
      rethrow;
    }
  }
}
