import 'dart:convert';

class SubTask {
  final String id;
  final String title;
  final bool isCompleted;

  SubTask({
    required this.id,
    required this.title,
    this.isCompleted = false,
  });

  SubTask copyWith({
    String? id,
    String? title,
    bool? isCompleted,
  }) {
    return SubTask(
      id: id ?? this.id,
      title: title ?? this.title,
      isCompleted: isCompleted ?? this.isCompleted,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'isCompleted': isCompleted ? 1 : 0,
    };
  }

  factory SubTask.fromMap(Map<String, dynamic> map) {
    return SubTask(
      id: map['id'] as String,
      title: map['title'] as String,
      isCompleted: map['isCompleted'] == 1 || map['isCompleted'] == true,
    );
  }
}

class TaskComment {
  final String id;
  final String author;
  final String message;
  final DateTime createdAt;

  TaskComment({
    required this.id,
    required this.author,
    required this.message,
    DateTime? createdAt,
  }) : createdAt = createdAt ?? DateTime.now();

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'author': author,
      'message': message,
      'createdAt': createdAt.toIso8601String(),
    };
  }

  factory TaskComment.fromMap(Map<String, dynamic> map) {
    return TaskComment(
      id: (map['id'] as String?) ?? '',
      author: (map['author'] as String?) ?? 'User',
      message: (map['message'] as String?) ?? '',
      createdAt: map['createdAt'] != null
          ? DateTime.tryParse(map['createdAt']) ?? DateTime.now()
          : DateTime.now(),
    );
  }
}

/// Project & Task Statuses:
/// 1. Started / Pending ('pending')
/// 2. In Progress / Active ('in_progress')
/// 3. On Hold / Blocked ('on_hold')
/// 4. In Review ('in_review')
/// 5. Completed ('completed')
enum TaskStatus {
  pending('pending', 'Started / Pending'),
  inProgress('in_progress', 'In Progress / Active'),
  onHold('on_hold', 'On Hold / Blocked'),
  inReview('in_review', 'In Review'),
  completed('completed', 'Completed');

  final String key;
  final String label;

  const TaskStatus(this.key, this.label);

  static TaskStatus fromKey(String? key) {
    switch (key) {
      case 'in_progress':
      case 'active':
        return TaskStatus.inProgress;
      case 'on_hold':
      case 'blocked':
        return TaskStatus.onHold;
      case 'in_review':
        return TaskStatus.inReview;
      case 'completed':
      case 'done':
        return TaskStatus.completed;
      case 'pending':
      case 'started':
      case 'todo':
      default:
        return TaskStatus.pending;
    }
  }

  static String getLabel(String? key) => fromKey(key).label;

  static bool isComplete(String? key) {
    final status = fromKey(key);
    return status == TaskStatus.completed;
  }
}

class TaskModel {
  final String id;
  final String title;
  final String description;
  final String category;
  final int priority; // 1: Low, 2: Medium, 3: High, 4: Urgent
  final DateTime? dueDate;
  final String? dueTime;
  final bool isCompleted;
  final String status; // 'pending', 'in_progress', 'on_hold', 'in_review', 'completed'
  final String workspaceId;
  final String spaceId;
  final String listId;
  final List<SubTask> subtasks;
  final List<TaskComment> comments;
  final String? assignedTo;
  final DateTime createdAt;

  TaskModel({
    required this.id,
    required this.title,
    this.description = '',
    this.category = 'General',
    this.priority = 1,
    this.dueDate,
    this.dueTime,
    bool? isCompleted,
    String? status,
    this.workspaceId = 'ws_default',
    this.spaceId = 'space_personal',
    this.listId = 'list_daily',
    this.subtasks = const [],
    this.comments = const [],
    this.assignedTo,
    DateTime? createdAt,
  })  : status = status != null
            ? TaskStatus.fromKey(status).key
            : ((isCompleted ?? false) ? 'completed' : 'pending'),
        isCompleted = isCompleted ?? (status != null ? TaskStatus.isComplete(status) : false),
        createdAt = createdAt ?? DateTime.now();

  TaskModel copyWith({
    String? id,
    String? title,
    String? description,
    String? category,
    int? priority,
    DateTime? dueDate,
    String? dueTime,
    bool? isCompleted,
    String? status,
    String? workspaceId,
    String? spaceId,
    String? listId,
    List<SubTask>? subtasks,
    List<TaskComment>? comments,
    String? assignedTo,
    DateTime? createdAt,
  }) {
    String newStatus = status ?? this.status;
    bool newIsCompleted = isCompleted ?? this.isCompleted;

    if (status != null) {
      newStatus = TaskStatus.fromKey(status).key;
      newIsCompleted = (newStatus == 'completed');
    } else if (isCompleted != null) {
      newIsCompleted = isCompleted;
      newStatus = isCompleted ? 'completed' : (this.status == 'completed' ? 'pending' : this.status);
    }

    return TaskModel(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      category: category ?? this.category,
      priority: priority ?? this.priority,
      dueDate: dueDate ?? this.dueDate,
      dueTime: dueTime ?? this.dueTime,
      isCompleted: newIsCompleted,
      status: newStatus,
      workspaceId: workspaceId ?? this.workspaceId,
      spaceId: spaceId ?? this.spaceId,
      listId: listId ?? this.listId,
      subtasks: subtasks ?? this.subtasks,
      comments: comments ?? this.comments,
      assignedTo: assignedTo ?? this.assignedTo,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'category': category,
      'priority': priority,
      'dueDate': dueDate?.toIso8601String(),
      'dueTime': dueTime,
      'isCompleted': isCompleted ? 1 : 0,
      'status': status,
      'workspaceId': workspaceId,
      'spaceId': spaceId,
      'listId': listId,
      'subtasks': jsonEncode(subtasks.map((s) => s.toMap()).toList()),
      'comments': jsonEncode(comments.map((c) => c.toMap()).toList()),
      'assignedTo': assignedTo,
      'createdAt': createdAt.toIso8601String(),
    };
  }

  factory TaskModel.fromMap(Map<String, dynamic> map) {
    List<SubTask> subtasksList = [];
    if (map['subtasks'] != null) {
      if (map['subtasks'] is String) {
        try {
          final decoded = jsonDecode(map['subtasks'] as String) as List;
          subtasksList = decoded
              .map((item) => SubTask.fromMap(item as Map<String, dynamic>))
              .toList();
        } catch (_) {}
      } else if (map['subtasks'] is List) {
        subtasksList = (map['subtasks'] as List)
            .map((item) => SubTask.fromMap(item as Map<String, dynamic>))
            .toList();
      }
    }

    List<TaskComment> commentsList = [];
    if (map['comments'] != null) {
      if (map['comments'] is String) {
        try {
          final decoded = jsonDecode(map['comments'] as String) as List;
          commentsList = decoded
              .map((item) => TaskComment.fromMap(item as Map<String, dynamic>))
              .toList();
        } catch (_) {}
      } else if (map['comments'] is List) {
        commentsList = (map['comments'] as List)
            .map((item) => TaskComment.fromMap(item as Map<String, dynamic>))
            .toList();
      }
    }

    final isCompleted = map['isCompleted'] == 1 || map['isCompleted'] == true;
    final rawStatus = map['status'] as String?;
    final status = rawStatus != null
        ? TaskStatus.fromKey(rawStatus).key
        : (isCompleted ? 'completed' : 'pending');

    return TaskModel(
      id: map['id'] as String,
      title: map['title'] as String,
      description: (map['description'] as String?) ?? '',
      category: (map['category'] as String?) ?? 'General',
      priority: (map['priority'] as int?) ?? 1,
      dueDate: map['dueDate'] != null ? DateTime.tryParse(map['dueDate']) : null,
      dueTime: map['dueTime'] as String?,
      isCompleted: isCompleted || status == 'completed',
      status: status,
      workspaceId: (map['workspaceId'] as String?) ?? 'ws_default',
      spaceId: (map['spaceId'] as String?) ?? 'space_personal',
      listId: (map['listId'] as String?) ?? 'list_daily',
      subtasks: subtasksList,
      comments: commentsList,
      assignedTo: map['assignedTo'] as String?,
      createdAt: map['createdAt'] != null
          ? DateTime.tryParse(map['createdAt']) ?? DateTime.now()
          : DateTime.now(),
    );
  }

  String toJson() => jsonEncode(toMap());

  factory TaskModel.fromJson(String source) =>
      TaskModel.fromMap(jsonDecode(source) as Map<String, dynamic>);
}
