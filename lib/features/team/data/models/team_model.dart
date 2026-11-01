import 'dart:convert';
import 'dart:math';
import 'package:flutter/material.dart';

enum TeamRole { owner, admin, member }

class TeamModel {
  final String id;
  final String name;
  final String description;
  final String ownerId;
  final List<String> memberUids;
  final String inviteCode;
  final int iconCode;
  final int colorValue;
  final DateTime createdAt;

  const TeamModel({
    required this.id,
    required this.name,
    this.description = '',
    required this.ownerId,
    this.memberUids = const [],
    required this.inviteCode,
    this.iconCode = 0xe3ae,
    this.colorValue = 0xFF8687E7,
    required this.createdAt,
  });

  IconData get icon => _iconMap[iconCode] ?? Icons.group;
  Color get color => Color(colorValue);

  static const Map<int, IconData> _iconMap = {
    0xe3ae: Icons.group,
    0xe105: Icons.business,
    0xe318: Icons.home,
    0xe6df: Icons.work,
    0xe2a3: Icons.folder,
    0xe5ef: Icons.star,
    0xe170: Icons.cloud,
    0xe58b: Icons.phone_android,
    0xe7fd: Icons.school,
    0xe9d0: Icons.sports_soccer,
  };

  static List<Map<String, dynamic>> get availableIcons => _iconMap.entries
      .map((e) => {'code': e.key, 'icon': e.value})
      .toList();

  static List<Color> get availableColors => const [
    Color(0xFF8687E7),
    Color(0xFFFF4949),
    Color(0xFF00E676),
    Color(0xFF00B0FF),
    Color(0xFFFFB300),
    Color(0xFFAB47BC),
    Color(0xFF26A69A),
    Color(0xFFEF5350),
  ];

  static String generateInviteCode() {
    const chars = 'ABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789';
    final rnd = Random.secure();
    return List.generate(6, (_) => chars[rnd.nextInt(chars.length)]).join();
  }

  TeamModel copyWith({
    String? id,
    String? name,
    String? description,
    String? ownerId,
    List<String>? memberUids,
    String? inviteCode,
    int? iconCode,
    int? colorValue,
    DateTime? createdAt,
  }) {
    return TeamModel(
      id: id ?? this.id,
      name: name ?? this.name,
      description: description ?? this.description,
      ownerId: ownerId ?? this.ownerId,
      memberUids: memberUids ?? this.memberUids,
      inviteCode: inviteCode ?? this.inviteCode,
      iconCode: iconCode ?? this.iconCode,
      colorValue: colorValue ?? this.colorValue,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  Map<String, dynamic> toMap() => {
    'id': id,
    'name': name,
    'description': description,
    'ownerId': ownerId,
    'memberUids': memberUids,
    'inviteCode': inviteCode,
    'iconCode': iconCode,
    'colorValue': colorValue,
    'createdAt': createdAt.toIso8601String(),
  };

  factory TeamModel.fromMap(Map<String, dynamic> map, [String? docId]) {
    return TeamModel(
      id: docId ?? map['id'] as String? ?? '',
      name: map['name'] as String? ?? 'Unnamed Team',
      description: map['description'] as String? ?? '',
      ownerId: map['ownerId'] as String? ?? '',
      memberUids: List<String>.from(map['memberUids'] as List? ?? []),
      inviteCode: map['inviteCode'] as String? ?? '',
      iconCode: map['iconCode'] as int? ?? 0xe3ae,
      colorValue: map['colorValue'] as int? ?? 0xFF8687E7,
      createdAt: map['createdAt'] != null
          ? DateTime.tryParse(map['createdAt'] as String) ?? DateTime.now()
          : DateTime.now(),
    );
  }

  String toJson() => jsonEncode(toMap());
  factory TeamModel.fromJson(String source) =>
      TeamModel.fromMap(jsonDecode(source) as Map<String, dynamic>);
}
