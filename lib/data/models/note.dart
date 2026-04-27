class Note {
  final String id;
  final String title;
  final String content;
  final int? colorValue;
  final bool isPinned;
  final DateTime createdAt;
  final DateTime updatedAt;

  const Note({
    required this.id,
    required this.title,
    this.content = '',
    this.colorValue,
    this.isPinned = false,
    required this.createdAt,
    required this.updatedAt,
  });

  Note copyWith({
    String? id,
    String? title,
    String? content,
    int? colorValue,
    bool? isPinned,
    DateTime? createdAt,
    DateTime? updatedAt,
    bool clearColor = false,
  }) {
    return Note(
      id: id ?? this.id,
      title: title ?? this.title,
      content: content ?? this.content,
      colorValue: clearColor ? null : (colorValue ?? this.colorValue),
      isPinned: isPinned ?? this.isPinned,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? DateTime.now(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'content': content,
      'colorValue': colorValue,
      'isPinned': isPinned,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }

  factory Note.fromMap(Map<dynamic, dynamic> map) {
    return Note(
      id: map['id'] as String,
      title: map['title'] as String? ?? '',
      content: map['content'] as String? ?? '',
      colorValue: map['colorValue'] as int?,
      isPinned: map['isPinned'] as bool? ?? false,
      createdAt: DateTime.parse(map['createdAt'] as String),
      updatedAt: DateTime.parse(map['updatedAt'] as String),
    );
  }
}
