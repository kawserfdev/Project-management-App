import 'package:flutter_test/flutter_test.dart';
import 'package:task_manager_app/features/task/data/models/task_model.dart';
import 'package:task_manager_app/features/team/data/models/team_member_model.dart';
import 'package:task_manager_app/features/team/data/models/team_model.dart';

void main() {
  group('TeamModel Tests', () {
    test('Can create TeamModel and serialize to/from map', () {
      final now = DateTime.now();
      final team = TeamModel(
        id: 'team_alpha',
        name: 'Alpha Squad',
        description: 'Core Engineering',
        ownerId: 'uid_1',
        memberUids: const ['uid_1', 'uid_2'],
        inviteCode: 'ALPHA1',
        createdAt: now,
      );

      final map = team.toMap();
      expect(map['name'], 'Alpha Squad');
      expect(map['inviteCode'], 'ALPHA1');
      expect(map['memberUids'], ['uid_1', 'uid_2']);

      final fromMap = TeamModel.fromMap(map, 'team_alpha');
      expect(fromMap.id, 'team_alpha');
      expect(fromMap.name, 'Alpha Squad');
      expect(fromMap.memberUids.length, 2);
    });

    test('generateInviteCode produces 6 alphanumeric characters', () {
      final code = TeamModel.generateInviteCode();
      expect(code.length, 6);
      expect(RegExp(r'^[A-Z0-9]{6}$').hasMatch(code), isTrue);
    });

    test('TeamMemberModel serializes and deserializes roles correctly', () {
      final member = TeamMemberModel(
        uid: 'user_1',
        displayName: 'Test User',
        email: 'test@example.com',
        role: TeamRole.admin,
        joinedAt: DateTime.now(),
      );

      expect(member.roleLabel, 'Admin');
      final map = member.toMap();
      expect(map['role'], 'admin');

      final fromMap = TeamMemberModel.fromMap(map);
      expect(fromMap.role, TeamRole.admin);
      expect(fromMap.displayName, 'Test User');
    });
    test('TaskModel serializes and deserializes team & statusLogs correctly', () {
      final now = DateTime.now();
      final log = TaskStatusLog(
        id: 'log_1',
        fromStatus: 'pending',
        toStatus: 'in_progress',
        updatedBy: 'Lead PM',
        timestamp: now,
      );

      final task = TaskModel(
        id: 'task_team_1',
        title: 'Build API Gateway',
        teamId: 'team_alpha',
        teamName: 'Alpha Squad',
        assignedTo: 'Bob Programmer',
        assignedToUid: 'dev_bob',
        statusLogs: [log],
        createdAt: now,
      );

      final map = task.toMap();
      expect(map['teamId'], 'team_alpha');
      expect(map['teamName'], 'Alpha Squad');
      expect(map['assignedToUid'], 'dev_bob');

      final fromMap = TaskModel.fromMap(map);
      expect(fromMap.teamId, 'team_alpha');
      expect(fromMap.teamName, 'Alpha Squad');
      expect(fromMap.assignedTo, 'Bob Programmer');
      expect(fromMap.statusLogs.length, 1);
      expect(fromMap.statusLogs.first.toStatus, 'in_progress');
      expect(fromMap.statusLogs.first.updatedBy, 'Lead PM');
    });
  });
}

