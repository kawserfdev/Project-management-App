import 'dart:convert';
import 'package:intl/intl.dart';
import 'package:task_manager_app/features/task/data/models/task_model.dart';

class TaskBackupService {
  /// Exports a list of tasks into a formatted JSON string
  static String exportToJson(List<TaskModel> tasks) {
    final list = tasks.map((t) => t.toMap()).toList();
    const encoder = JsonEncoder.withIndent('  ');
    return encoder.convert({
      'version': '1.0',
      'exportedAt': DateTime.now().toIso8601String(),
      'taskCount': tasks.length,
      'tasks': list,
    });
  }

  /// Imports a list of tasks from a JSON string
  static List<TaskModel> importFromJson(String jsonContent) {
    try {
      final decoded = jsonDecode(jsonContent);
      if (decoded is Map<String, dynamic> && decoded['tasks'] != null) {
        final taskList = decoded['tasks'] as List;
        return taskList
            .map((item) => TaskModel.fromMap(item as Map<String, dynamic>))
            .toList();
      } else if (decoded is List) {
        return decoded
            .map((item) => TaskModel.fromMap(item as Map<String, dynamic>))
            .toList();
      }
      return [];
    } catch (_) {
      return [];
    }
  }

  /// Exports tasks to standard CSV format
  static String exportToCsv(List<TaskModel> tasks) {
    final buffer = StringBuffer();
    // CSV Header
    buffer.writeln('ID,Title,Description,Category,Priority,DueDate,DueTime,Completed,SubtasksCount');

    for (final task in tasks) {
      final id = _escapeCsv(task.id);
      final title = _escapeCsv(task.title);
      final desc = _escapeCsv(task.description);
      final cat = _escapeCsv(task.category);
      final priority = task.priority.toString();
      final dueDate = task.dueDate != null
          ? DateFormat('yyyy-MM-dd').format(task.dueDate!)
          : '';
      final dueTime = _escapeCsv(task.dueTime ?? '');
      final completed = task.isCompleted ? 'true' : 'false';
      final subtasksCount = task.subtasks.length.toString();

      buffer.writeln('$id,$title,$desc,$cat,$priority,$dueDate,$dueTime,$completed,$subtasksCount');
    }

    return buffer.toString();
  }

  /// Imports tasks from a CSV string
  static List<TaskModel> importFromCsv(String csvContent) {
    final lines = const LineSplitter().convert(csvContent);
    if (lines.length <= 1) return [];

    final tasks = <TaskModel>[];
    // Skip header line
    for (int i = 1; i < lines.length; i++) {
      final line = lines[i].trim();
      if (line.isEmpty) continue;

      final fields = _parseCsvLine(line);
      if (fields.length < 5) continue;

      try {
        final id = fields[0].isEmpty
            ? DateTime.now().millisecondsSinceEpoch.toString() + i.toString()
            : fields[0];
        final title = fields[1];
        final description = fields.length > 2 ? fields[2] : '';
        final category = fields.length > 3 ? fields[3] : 'General';
        final priority = fields.length > 4 ? int.tryParse(fields[4]) ?? 1 : 1;
        final dueDate = fields.length > 5 && fields[5].isNotEmpty
            ? DateTime.tryParse(fields[5])
            : null;
        final dueTime = fields.length > 6 && fields[6].isNotEmpty ? fields[6] : null;
        final isCompleted = fields.length > 7 && fields[7].toLowerCase() == 'true';

        tasks.add(
          TaskModel(
            id: id,
            title: title,
            description: description,
            category: category.isEmpty ? 'General' : category,
            priority: priority,
            dueDate: dueDate,
            dueTime: dueTime,
            isCompleted: isCompleted,
          ),
        );
      } catch (_) {}
    }

    return tasks;
  }

  static String _escapeCsv(String field) {
    if (field.contains(',') || field.contains('"') || field.contains('\n')) {
      return '"${field.replaceAll('"', '""')}"';
    }
    return field;
  }

  static List<String> _parseCsvLine(String line) {
    final fields = <String>[];
    final buffer = StringBuffer();
    bool insideQuotes = false;

    for (int i = 0; i < line.length; i++) {
      final char = line[i];
      if (char == '"') {
        if (insideQuotes && i + 1 < line.length && line[i + 1] == '"') {
          buffer.write('"');
          i++;
        } else {
          insideQuotes = !insideQuotes;
        }
      } else if (char == ',' && !insideQuotes) {
        fields.add(buffer.toString());
        buffer.clear();
      } else {
        buffer.write(char);
      }
    }
    fields.add(buffer.toString());
    return fields;
  }
}

