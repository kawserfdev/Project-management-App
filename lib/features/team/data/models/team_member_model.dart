import 'dart:convert';
import 'package:task_manager_app/features/team/data/models/team_model.dart';

class TeamMemberModel {
  final String uid;
  final String displayName;
  final String email;
  final String? photoUrl;
  final TeamRole role;
  final DateTime joinedAt;

  const TeamMemberModel({
    required this.uid,
    required this.displayName,
    required this.email,
    this.photoUrl,
    this.role = TeamRole.member,
    required this.joinedAt,
  });

  String get roleLabel {
    switch (role) {
      case TeamRole.owner:
        return 'Owner';
      case TeamRole.admin:
        return 'Admin';
      case TeamRole.member:
        return 'Member';
    }
  }

  TeamMemberModel copyWith({
    String? uid,
    String? displayName,
    String? email,
    String? photoUrl,
    TeamRole? role,
    DateTime? joinedAt,
  }) {
    return TeamMemberModel(
      uid: uid ?? this.uid,
      displayName: displayName ?? this.displayName,
      email: email ?? this.email,
      photoUrl: photoUrl ?? this.photoUrl,
      role: role ?? this.role,
      joinedAt: joinedAt ?? this.joinedAt,
    );
  }

  Map<String, dynamic> toMap() => {
    'uid': uid,
    'displayName': displayName,
    'email': email,
    'photoUrl': photoUrl,
    'role': role.name,
    'joinedAt': joinedAt.toIso8601String(),
  };

  factory TeamMemberModel.fromMap(Map<String, dynamic> map) {
    return TeamMemberModel(
      uid: map['uid'] as String? ?? '',
      displayName: map['displayName'] as String? ?? 'Unknown',
      email: map['email'] as String? ?? '',
      photoUrl: map['photoUrl'] as String?,
      role: TeamRole.values.firstWhere(
        (r) => r.name == (map['role'] as String? ?? 'member'),
        orElse: () => TeamRole.member,
      ),
      joinedAt: map['joinedAt'] != null
          ? DateTime.tryParse(map['joinedAt'] as String) ?? DateTime.now()
          : DateTime.now(),
    );
  }

  String toJson() => jsonEncode(toMap());
  factory TeamMemberModel.fromJson(String source) =>
      TeamMemberModel.fromMap(jsonDecode(source) as Map<String, dynamic>);
}
