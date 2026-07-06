enum TaskPriority {
  low,
  medium,
  high,
}

extension TaskPriorityInfo on TaskPriority {
  String get label {
    switch (this) {
      case TaskPriority.low:
        return 'Low';
      case TaskPriority.medium:
        return 'Medium';
      case TaskPriority.high:
        return 'High';
    }
  }

  int get rank {
    switch (this) {
      case TaskPriority.low:
        return 1;
      case TaskPriority.medium:
        return 2;
      case TaskPriority.high:
        return 3;
    }
  }
}

enum TaskCategory {
  personal,
  work,
  study,
  health,
  other,
}

extension TaskCategoryInfo on TaskCategory {
  String get label {
    switch (this) {
      case TaskCategory.personal:
        return 'Personal';
      case TaskCategory.work:
        return 'Work';
      case TaskCategory.study:
        return 'Study';
      case TaskCategory.health:
        return 'Health';
      case TaskCategory.other:
        return 'Other';
    }
  }
}

enum TaskFilter {
  all,
  active,
  completed,
}

extension TaskFilterInfo on TaskFilter {
  String get label {
    switch (this) {
      case TaskFilter.all:
        return 'All';
      case TaskFilter.active:
        return 'Active';
      case TaskFilter.completed:
        return 'Done';
    }
  }
}

enum TaskSort {
  newest,
  oldest,
  priority,
  dueDate,
}

extension TaskSortInfo on TaskSort {
  String get label {
    switch (this) {
      case TaskSort.newest:
        return 'Newest';
      case TaskSort.oldest:
        return 'Oldest';
      case TaskSort.priority:
        return 'Priority';
      case TaskSort.dueDate:
        return 'Due date';
    }
  }
}

class Task {
  final String id;
  final String title;
  final String description;
  final bool isCompleted;
  final TaskPriority priority;
  final TaskCategory category;
  final DateTime? dueDate;
  final DateTime createdAt;
  final DateTime updatedAt;

  const Task({
    required this.id,
    required this.title,
    required this.description,
    required this.isCompleted,
    required this.priority,
    required this.category,
    required this.dueDate,
    required this.createdAt,
    required this.updatedAt,
  });

  bool get isOverdue {
    if (dueDate == null || isCompleted) {
      return false;
    }

    final DateTime today = DateTime.now();
    final DateTime todayOnly = DateTime(today.year, today.month, today.day);
    final DateTime dueOnly = DateTime(dueDate!.year, dueDate!.month, dueDate!.day);

    return dueOnly.isBefore(todayOnly);
  }

  Task copyWith({
    String? id,
    String? title,
    String? description,
    bool? isCompleted,
    TaskPriority? priority,
    TaskCategory? category,
    DateTime? dueDate,
    bool clearDueDate = false,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return Task(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      isCompleted: isCompleted ?? this.isCompleted,
      priority: priority ?? this.priority,
      category: category ?? this.category,
      dueDate: clearDueDate ? null : dueDate ?? this.dueDate,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'isCompleted': isCompleted,
      'priority': priority.name,
      'category': category.name,
      'dueDate': dueDate?.toIso8601String(),
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }

  factory Task.fromJson(Map<String, dynamic> json) {
    return Task(
      id: json['id'] as String? ?? '',
      title: json['title'] as String? ?? '',
      description: json['description'] as String? ?? '',
      isCompleted: json['isCompleted'] as bool? ?? false,
      priority: _priorityFromName(json['priority'] as String?),
      category: _categoryFromName(json['category'] as String?),
      dueDate: DateTime.tryParse(json['dueDate'] as String? ?? ''),
      createdAt: DateTime.tryParse(json['createdAt'] as String? ?? '') ??
          DateTime.now(),
      updatedAt: DateTime.tryParse(json['updatedAt'] as String? ?? '') ??
          DateTime.now(),
    );
  }
}

TaskPriority _priorityFromName(String? name) {
  return TaskPriority.values.firstWhere(
    (priority) {
      return priority.name == name;
    },
    orElse: () {
      return TaskPriority.medium;
    },
  );
}

TaskCategory _categoryFromName(String? name) {
  return TaskCategory.values.firstWhere(
    (category) {
      return category.name == name;
    },
    orElse: () {
      return TaskCategory.personal;
    },
  );
}