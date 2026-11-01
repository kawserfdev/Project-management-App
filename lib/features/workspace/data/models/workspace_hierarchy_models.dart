import 'dart:convert';
import 'package:flutter/material.dart';

class WorkspaceModel {
  final String id;
  final String name;
  final String description;
  final int iconCode;

  const WorkspaceModel({
    required this.id,
    required this.name,
    this.description = '',
    this.iconCode = 0xe105, // Icons.business
  });

  static const Map<int, IconData> _iconLookup = {
    0xe318: Icons.home,
    0xe105: Icons.business,
    0xe58b: Icons.phone_android,
    0xe170: Icons.cloud,
    0xe5ef: Icons.star,
    0xe2a3: Icons.folder,
    0xe6df: Icons.work,
    0xe3ae: Icons.group,
  };

  IconData get icon => _iconLookup[iconCode] ?? Icons.business;

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'iconCode': iconCode,
    };
  }

  factory WorkspaceModel.fromMap(Map<String, dynamic> map) {
    return WorkspaceModel(
      id: map['id'] as String? ?? 'default_ws',
      name: map['name'] as String? ?? 'My Workspace',
      description: map['description'] as String? ?? '',
      iconCode: map['iconCode'] as int? ?? 0xe105,
    );
  }

  String toJson() => jsonEncode(toMap());
  factory WorkspaceModel.fromJson(String source) =>
      WorkspaceModel.fromMap(jsonDecode(source) as Map<String, dynamic>);

  static List<WorkspaceModel> get defaultWorkspaces => const [
        WorkspaceModel(
          id: 'ws_default',
          name: 'Personal Workspace',
          description: 'Individual tasks and personal goals',
          iconCode: 0xe318, // Icons.home
        ),
        WorkspaceModel(
          id: 'ws_team',
          name: 'Engineering Team',
          description: 'Sprint planning and core app roadmap',
          iconCode: 0xe105, // Icons.business
        ),
      ];
}

class SpaceModel {
  final String id;
  final String workspaceId;
  final String name;
  final int iconCode;

  const SpaceModel({
    required this.id,
    required this.workspaceId,
    required this.name,
    this.iconCode = 0xe2a3, // Icons.folder
  });

  static const Map<int, IconData> _spaceIconLookup = {
    0xe58b: Icons.phone_android,
    0xe170: Icons.cloud,
    0xe5ef: Icons.star,
    0xe2a3: Icons.folder,
    0xe6df: Icons.work,
  };

  IconData get icon => _spaceIconLookup[iconCode] ?? Icons.folder;

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'workspaceId': workspaceId,
      'name': name,
      'iconCode': iconCode,
    };
  }

  factory SpaceModel.fromMap(Map<String, dynamic> map) {
    return SpaceModel(
      id: map['id'] as String? ?? 'default_space',
      workspaceId: map['workspaceId'] as String? ?? 'ws_default',
      name: map['name'] as String? ?? 'General Space',
      iconCode: map['iconCode'] as int? ?? 0xe2a3,
    );
  }

  String toJson() => jsonEncode(toMap());
  factory SpaceModel.fromJson(String source) =>
      SpaceModel.fromMap(jsonDecode(source) as Map<String, dynamic>);

  static List<SpaceModel> get defaultSpaces => const [
        SpaceModel(
          id: 'space_mobile',
          workspaceId: 'ws_team',
          name: 'Mobile App Project',
          iconCode: 0xe58b, // Icons.phone_android
        ),
        SpaceModel(
          id: 'space_backend',
          workspaceId: 'ws_team',
          name: 'Cloud & API Services',
          iconCode: 0xe170, // Icons.cloud
        ),
        SpaceModel(
          id: 'space_personal',
          workspaceId: 'ws_default',
          name: 'Daily Routines',
          iconCode: 0xe5ef, // Icons.star
        ),
      ];
}

class TaskListModel {
  final String id;
  final String spaceId;
  final String name;
  final int colorValue;

  const TaskListModel({
    required this.id,
    required this.spaceId,
    required this.name,
    this.colorValue = 0xFF8875FF,
  });

  Color get color => Color(colorValue);

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'spaceId': spaceId,
      'name': name,
      'colorValue': colorValue,
    };
  }

  factory TaskListModel.fromMap(Map<String, dynamic> map) {
    return TaskListModel(
      id: map['id'] as String? ?? 'default_list',
      spaceId: map['spaceId'] as String? ?? 'space_mobile',
      name: map['name'] as String? ?? 'Sprint Backlog',
      colorValue: map['colorValue'] as int? ?? 0xFF8875FF,
    );
  }

  String toJson() => jsonEncode(toMap());
  factory TaskListModel.fromJson(String source) =>
      TaskListModel.fromMap(jsonDecode(source) as Map<String, dynamic>);

  static List<TaskListModel> get defaultLists => const [
        TaskListModel(
          id: 'list_sprint',
          spaceId: 'space_mobile',
          name: 'Sprint 12 Tasks',
          colorValue: 0xFF8875FF,
        ),
        TaskListModel(
          id: 'list_bugs',
          spaceId: 'space_mobile',
          name: 'Bug Fixes & QA',
          colorValue: 0xFFFF4949,
        ),
        TaskListModel(
          id: 'list_api',
          spaceId: 'space_backend',
          name: 'REST Endpoints',
          colorValue: 0xFF00E676,
        ),
        TaskListModel(
          id: 'list_daily',
          spaceId: 'space_personal',
          name: 'Everyday Checklist',
          colorValue: 0xFF00B0FF,
        ),
      ];
}
