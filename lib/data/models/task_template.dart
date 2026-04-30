import 'task.dart';

typedef SuggestedTime = ({int hour, int minute});

class TemplateTask {
  final String title;
  final Priority priority;
  final String? description;
  final SuggestedTime? suggestedTime;

  const TemplateTask({
    required this.title,
    this.priority = Priority.medium,
    this.description,
    this.suggestedTime,
  });
}

class TaskTemplate {
  final String id;
  final String name;
  final String description;
  final String emoji;
  final List<TemplateTask> tasks;

  const TaskTemplate({
    required this.id,
    required this.name,
    required this.description,
    required this.emoji,
    required this.tasks,
  });
}
