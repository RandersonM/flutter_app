import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:json_annotation/json_annotation.dart';

part 'workout_assessment_model.g.dart';

@JsonSerializable()
class WorkoutAssessment {
  final String? id;
  final String userId;
  final String monthYear;
  final DateTime createdAt;
  final DateTime? lockedAt;
  final Map<String, dynamic> healthResults;
  final int workoutDaysGoal;
  final List<int> workoutDays;
  final bool isCurrentMonth;

  const WorkoutAssessment({
    this.id,
    required this.userId,
    required this.monthYear,
    required this.createdAt,
    this.lockedAt,
    required this.healthResults,
    required this.workoutDaysGoal,
    required this.workoutDays,
    required this.isCurrentMonth,
  });

  factory WorkoutAssessment.fromJson(Map<String, dynamic> json) =>
      _$WorkoutAssessmentFromJson(json);

  Map<String, dynamic> toJson() => _$WorkoutAssessmentToJson(this);

  factory WorkoutAssessment.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    final workoutDaysRaw = data['workoutDays'] ?? [];
    final workoutDays = List<int>.from(workoutDaysRaw);
    
    return WorkoutAssessment(
      id: doc.id,
      userId: data['userId'] ?? '',
      monthYear: data['monthYear'] ?? '',
      createdAt: (data['createdAt'] as Timestamp).toDate(),
      lockedAt: data['lockedAt'] != null 
          ? (data['lockedAt'] as Timestamp).toDate() 
          : null,
      healthResults: Map<String, dynamic>.from(data['healthResults'] ?? {}),
      workoutDaysGoal: data['workoutDaysGoal'] ?? 0,
      workoutDays: workoutDays,
      isCurrentMonth: data['isCurrentMonth'] ?? false,
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'userId': userId,
      'monthYear': monthYear,
      'createdAt': Timestamp.fromDate(createdAt),
      'lockedAt': lockedAt != null ? Timestamp.fromDate(lockedAt!) : null,
      'healthResults': healthResults,
      'workoutDaysGoal': workoutDaysGoal,
      'workoutDays': workoutDays,
      'isCurrentMonth': isCurrentMonth,
    };
  }

  WorkoutAssessment copyWith({
    String? id,
    String? userId,
    String? monthYear,
    DateTime? createdAt,
    DateTime? lockedAt,
    Map<String, dynamic>? healthResults,
    int? workoutDaysGoal,
    List<int>? workoutDays,
    bool? isCurrentMonth,
  }) {
    return WorkoutAssessment(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      monthYear: monthYear ?? this.monthYear,
      createdAt: createdAt ?? this.createdAt,
      lockedAt: lockedAt ?? this.lockedAt,
      healthResults: healthResults ?? this.healthResults,
      workoutDaysGoal: workoutDaysGoal ?? this.workoutDaysGoal,
      workoutDays: workoutDays ?? this.workoutDays,
      isCurrentMonth: isCurrentMonth ?? this.isCurrentMonth,
    );
  }

  bool get canEdit => isCurrentMonth && lockedAt == null;
}
