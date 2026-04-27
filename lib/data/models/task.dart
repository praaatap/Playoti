enum Priority { high, medium, low }

enum RecurrenceType { daily, weekly, monthly, yearly }

class Subtask {
  final String title;
  final bool isCompleted;

  const Subtask({required this.title, this.isCompleted = false});

  Subtask copyWith({String? title, bool? isCompleted}) {
    return Subtask(
      title: title ?? this.title,
      isCompleted: isCompleted ?? this.isCompleted,
    );
  }

  Map<String, dynamic> toMap() => {'title': title, 'isCompleted': isCompleted};

  factory Subtask.fromMap(Map<dynamic, dynamic> map) {
    return Subtask(
      title: map['title'] as String? ?? '',
      isCompleted: map['isCompleted'] as bool? ?? false,
    );
  }
}

class Task {
  final String id;
  final String title;
  final String? description;
  final DateTime date;
  final DateTime? startTime;
  final DateTime? endTime;
  final Priority priority;
  final bool isCompleted;
  final DateTime? completedAt;
  final RecurrenceType? recurrenceType;
  final int? recurrenceInterval;
  final DateTime? recurrenceEndDate;
  final String? categoryId;
  final int sortOrder;
  final List<Subtask> subtasks;
  final DateTime? reminderDateTime;
  final DateTime createdAt;
  final DateTime updatedAt;

  const Task({
    required this.id,
    required this.title,
    this.description,
    required this.date,
    this.startTime,
    this.endTime,
    this.priority = Priority.medium,
    this.isCompleted = false,
    this.completedAt,
    this.recurrenceType,
    this.recurrenceInterval,
    this.recurrenceEndDate,
    this.categoryId,
    this.sortOrder = 0,
    this.subtasks = const [],
    this.reminderDateTime,
    required this.createdAt,
    required this.updatedAt,
  });

  Task copyWith({
    String? id,
    String? title,
    String? description,
    DateTime? date,
    DateTime? startTime,
    DateTime? endTime,
    Priority? priority,
    bool? isCompleted,
    DateTime? completedAt,
    RecurrenceType? recurrenceType,
    int? recurrenceInterval,
    DateTime? recurrenceEndDate,
    String? categoryId,
    int? sortOrder,
    List<Subtask>? subtasks,
    DateTime? reminderDateTime,
    DateTime? createdAt,
    DateTime? updatedAt,
    bool clearDescription = false,
    bool clearStartTime = false,
    bool clearEndTime = false,
    bool clearCompletedAt = false,
    bool clearRecurrence = false,
    bool clearCategory = false,
    bool clearReminder = false,
  }) {
    return Task(
      id: id ?? this.id,
      title: title ?? this.title,
      description: clearDescription ? null : (description ?? this.description),
      date: date ?? this.date,
      startTime: clearStartTime ? null : (startTime ?? this.startTime),
      endTime: clearEndTime ? null : (endTime ?? this.endTime),
      priority: priority ?? this.priority,
      isCompleted: isCompleted ?? this.isCompleted,
      completedAt: clearCompletedAt ? null : (completedAt ?? this.completedAt),
      recurrenceType:
          clearRecurrence ? null : (recurrenceType ?? this.recurrenceType),
      recurrenceInterval:
          clearRecurrence ? null : (recurrenceInterval ?? this.recurrenceInterval),
      recurrenceEndDate:
          clearRecurrence ? null : (recurrenceEndDate ?? this.recurrenceEndDate),
      categoryId: clearCategory ? null : (categoryId ?? this.categoryId),
      sortOrder: sortOrder ?? this.sortOrder,
      subtasks: subtasks ?? this.subtasks,
      reminderDateTime:
          clearReminder ? null : (reminderDateTime ?? this.reminderDateTime),
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? DateTime.now(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'date': date.toIso8601String(),
      'startTime': startTime?.toIso8601String(),
      'endTime': endTime?.toIso8601String(),
      'priority': priority.index,
      'isCompleted': isCompleted,
      'completedAt': completedAt?.toIso8601String(),
      'recurrenceType': recurrenceType?.index,
      'recurrenceInterval': recurrenceInterval,
      'recurrenceEndDate': recurrenceEndDate?.toIso8601String(),
      'categoryId': categoryId,
      'sortOrder': sortOrder,
      'subtasks': subtasks.map((s) => s.toMap()).toList(),
      'reminderDateTime': reminderDateTime?.toIso8601String(),
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }

  factory Task.fromMap(Map<dynamic, dynamic> map) {
    return Task(
      id: map['id'] as String,
      title: map['title'] as String? ?? '',
      description: map['description'] as String?,
      date: DateTime.parse(map['date'] as String),
      startTime: map['startTime'] != null
          ? DateTime.parse(map['startTime'] as String)
          : null,
      endTime: map['endTime'] != null
          ? DateTime.parse(map['endTime'] as String)
          : null,
      priority: Priority.values[map['priority'] as int? ?? 1],
      isCompleted: map['isCompleted'] as bool? ?? false,
      completedAt: map['completedAt'] != null
          ? DateTime.parse(map['completedAt'] as String)
          : null,
      recurrenceType: map['recurrenceType'] != null
          ? RecurrenceType.values[map['recurrenceType'] as int]
          : null,
      recurrenceInterval: map['recurrenceInterval'] as int?,
      recurrenceEndDate: map['recurrenceEndDate'] != null
          ? DateTime.parse(map['recurrenceEndDate'] as String)
          : null,
      categoryId: map['categoryId'] as String?,
      sortOrder: map['sortOrder'] as int? ?? 0,
      subtasks: (map['subtasks'] as List<dynamic>?)
              ?.map((s) => Subtask.fromMap(s as Map<dynamic, dynamic>))
              .toList() ??
          [],
      reminderDateTime: map['reminderDateTime'] != null
          ? DateTime.parse(map['reminderDateTime'] as String)
          : null,
      createdAt: DateTime.parse(map['createdAt'] as String),
      updatedAt: DateTime.parse(map['updatedAt'] as String),
    );
  }
}
