import 'package:equatable/equatable.dart';

enum GoalCategory {
  study,
  work,
  personal,
  health,
  finance,
  other,
}

enum GoalStatus {
  notStarted,
  inProgress,
  completed,
  overdue,
}

class GoalModel extends Equatable {
  final String id;
  final String title;
  final String description;
  final DateTime deadline;
  final DateTime createdAt;
  final GoalCategory category;
  final GoalStatus status;
  final double progress;
  final List<String> tags;
  final String? notes;

  const GoalModel({
    required this.id,
    required this.title,
    required this.description,
    required this.deadline,
    required this.createdAt,
    required this.category,
    this.status = GoalStatus.notStarted,
    this.progress = 0.0,
    this.tags = const [],
    this.notes,
  });

  GoalModel copyWith({
    String? id,
    String? title,
    String? description,
    DateTime? deadline,
    DateTime? createdAt,
    GoalCategory? category,
    GoalStatus? status,
    double? progress,
    List<String>? tags,
    String? notes,
  }) {
    return GoalModel(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      deadline: deadline ?? this.deadline,
      createdAt: createdAt ?? this.createdAt,
      category: category ?? this.category,
      status: status ?? this.status,
      progress: progress ?? this.progress,
      tags: tags ?? this.tags,
      notes: notes ?? this.notes,
    );
  }

  bool get isOverdue =>
      DateTime.now().isAfter(deadline) && status != GoalStatus.completed;

  bool get isCompleted => status == GoalStatus.completed || progress >= 100.0;

  int get daysUntilDeadline {
    final now = DateTime.now();
    final difference = deadline.difference(now);
    return difference.inDays;
  }

  @override
  List<Object?> get props => [
        id,
        title,
        description,
        deadline,
        createdAt,
        category,
        status,
        progress,
        tags,
        notes,
      ];
}
