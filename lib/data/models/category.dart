class TaskCategory {
  final String id;
  final String name;
  final int colorValue;
  final String iconName;
  final int sortOrder;
  final DateTime createdAt;

  const TaskCategory({
    required this.id,
    required this.name,
    required this.colorValue,
    this.iconName = 'circle',
    this.sortOrder = 0,
    required this.createdAt,
  });

  TaskCategory copyWith({
    String? id,
    String? name,
    int? colorValue,
    String? iconName,
    int? sortOrder,
    DateTime? createdAt,
  }) {
    return TaskCategory(
      id: id ?? this.id,
      name: name ?? this.name,
      colorValue: colorValue ?? this.colorValue,
      iconName: iconName ?? this.iconName,
      sortOrder: sortOrder ?? this.sortOrder,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'colorValue': colorValue,
      'iconName': iconName,
      'sortOrder': sortOrder,
      'createdAt': createdAt.toIso8601String(),
    };
  }

  factory TaskCategory.fromMap(Map<dynamic, dynamic> map) {
    return TaskCategory(
      id: map['id'] as String,
      name: map['name'] as String? ?? '',
      colorValue: map['colorValue'] as int? ?? 0xFF6B9080,
      iconName: map['iconName'] as String? ?? 'circle',
      sortOrder: map['sortOrder'] as int? ?? 0,
      createdAt: DateTime.parse(map['createdAt'] as String),
    );
  }
}
