import 'dart:async';
import 'package:task_manager_app/features/task/data/models/task_model.dart';

enum CollaborationEventType {
  taskCreated,
  taskUpdated,
  taskStatusMoved,
  taskDeleted,
  commentAdded,
  teamMemberAction,
}

class CollaborationEvent {
  final CollaborationEventType type;
  final String author;
  final String message;
  final TaskModel? task;
  final DateTime timestamp;

  CollaborationEvent({
    required this.type,
    required this.author,
    required this.message,
    this.task,
    DateTime? timestamp,
  }) : timestamp = timestamp ?? DateTime.now();
}

class CollaborationService {
  static final CollaborationService _instance = CollaborationService._internal();
  factory CollaborationService() => _instance;
  CollaborationService._internal();

  final StreamController<CollaborationEvent> _eventController =
      StreamController<CollaborationEvent>.broadcast();

  Stream<CollaborationEvent> get eventStream => _eventController.stream;

  // Active online collaborators
  final List<String> activeMembers = [
    'You (Lead)',
    'Sarah Jenkins (Design)',
    'Alex Rivera (Backend)',
    'David Chen (QA)',
  ];

  void broadcastTaskCreated(TaskModel task, {String author = 'You'}) {
    _eventController.add(
      CollaborationEvent(
        type: CollaborationEventType.taskCreated,
        author: author,
        message: '$author created task "${task.title}"',
        task: task,
      ),
    );
  }

  void broadcastTaskUpdated(TaskModel task, {String author = 'You'}) {
    _eventController.add(
      CollaborationEvent(
        type: CollaborationEventType.taskUpdated,
        author: author,
        message: '$author updated "${task.title}"',
        task: task,
      ),
    );
  }

  void broadcastStatusMoved(TaskModel task, String newStatus, {String author = 'You'}) {
    final statusLabel = switch (newStatus) {
      'pending' || 'started' || 'todo' => 'Started / Pending',
      'in_progress' || 'active' => 'In Progress / Active',
      'on_hold' || 'blocked' => 'On Hold / Blocked',
      'in_review' => 'In Review',
      'completed' || 'done' => 'Completed',
      _ => newStatus,
    };
    _eventController.add(
      CollaborationEvent(
        type: CollaborationEventType.taskStatusMoved,
        author: author,
        message: '$author moved "${task.title}" to $statusLabel',
        task: task,
      ),
    );
  }

  void broadcastTaskDeleted(String taskId, String title, {String author = 'You'}) {
    _eventController.add(
      CollaborationEvent(
        type: CollaborationEventType.taskDeleted,
        author: author,
        message: '$author deleted task "$title"',
      ),
    );
  }

  void broadcastCommentAdded(TaskModel task, TaskComment comment) {
    _eventController.add(
      CollaborationEvent(
        type: CollaborationEventType.commentAdded,
        author: comment.author,
        message: '${comment.author} commented on "${task.title}": "${comment.message}"',
        task: task,
      ),
    );
  }

  void simulateRemoteTeamUpdate(Function(TaskModel updated)? onRemoteUpdate) {
    // Simulates an async incoming team collaboration update
    final remoteAuthors = ['Sarah Jenkins', 'Alex Rivera', 'David Chen'];
    final author = (remoteAuthors..shuffle()).first;

    _eventController.add(
      CollaborationEvent(
        type: CollaborationEventType.teamMemberAction,
        author: author,
        message: '$author synced latest progress with the team.',
      ),
    );
  }
}
