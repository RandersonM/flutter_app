import 'package:json_annotation/json_annotation.dart';

part 'workout_plan_model.g.dart';

/// A single exercise within a workout split.
@JsonSerializable(explicitToJson: true)
class WorkoutExerciseModel {
  @JsonKey(name: 'name')
  final String name;

  /// e.g. "3x15", "45 min", "3*15"
  @JsonKey(name: 'volume')
  final String volume;

  const WorkoutExerciseModel({
    required this.name,
    required this.volume,
  });

  factory WorkoutExerciseModel.fromJson(Map<String, dynamic> json) =>
      _$WorkoutExerciseModelFromJson(json);

  Map<String, dynamic> toJson() => _$WorkoutExerciseModelToJson(this);

  WorkoutExerciseModel copyWith({String? name, String? volume}) =>
      WorkoutExerciseModel(
        name: name ?? this.name,
        volume: volume ?? this.volume,
      );
}

/// A named workout split (e.g. "Treino A", "Treino B").
@JsonSerializable(explicitToJson: true)
class WorkoutSplitModel {
  @JsonKey(name: 'name')
  final String name;

  @JsonKey(name: 'exercises')
  final List<WorkoutExerciseModel> exercises;

  const WorkoutSplitModel({
    required this.name,
    required this.exercises,
  });

  factory WorkoutSplitModel.fromJson(Map<String, dynamic> json) =>
      _$WorkoutSplitModelFromJson(json);

  Map<String, dynamic> toJson() => _$WorkoutSplitModelToJson(this);

  WorkoutSplitModel copyWith({
    String? name,
    List<WorkoutExerciseModel>? exercises,
  }) =>
      WorkoutSplitModel(
        name: name ?? this.name,
        exercises: exercises ?? this.exercises,
      );
}

/// The user's complete workout plan containing 1–N splits.
@JsonSerializable(explicitToJson: true)
class WorkoutPlanModel {
  @JsonKey(name: 'splits')
  final List<WorkoutSplitModel> splits;

  const WorkoutPlanModel({required this.splits});

  factory WorkoutPlanModel.fromJson(Map<String, dynamic> json) =>
      _$WorkoutPlanModelFromJson(json);

  Map<String, dynamic> toJson() => _$WorkoutPlanModelToJson(this);

  WorkoutPlanModel copyWith({List<WorkoutSplitModel>? splits}) =>
      WorkoutPlanModel(splits: splits ?? this.splits);

  bool get isEmpty => splits.isEmpty;
  bool get isNotEmpty => splits.isNotEmpty;
}
