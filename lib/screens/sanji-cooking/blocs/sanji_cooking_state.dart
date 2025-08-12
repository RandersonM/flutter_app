import 'package:equatable/equatable.dart';
import '../../../core/models/nutrition_calculation_model.dart';

abstract class SanjiCookingState extends Equatable {
  const SanjiCookingState();

  @override
  List<Object?> get props => [];
}

class SanjiCookingInitial extends SanjiCookingState {
  const SanjiCookingInitial();
}

class SanjiCookingLoading extends SanjiCookingState {
  const SanjiCookingLoading();
}

class SanjiCookingLoaded extends SanjiCookingState {
  final NutritionCalculationModel? nutritionResults;
  final bool hasExistingData;
  final bool showForm;

  const SanjiCookingLoaded({
    this.nutritionResults,
    this.hasExistingData = false,
    this.showForm = true,
  });

  @override
  List<Object?> get props => [nutritionResults, hasExistingData, showForm];

  SanjiCookingLoaded copyWith({
    NutritionCalculationModel? nutritionResults,
    bool? hasExistingData,
    bool? showForm,
  }) {
    return SanjiCookingLoaded(
      nutritionResults: nutritionResults ?? this.nutritionResults,
      hasExistingData: hasExistingData ?? this.hasExistingData,
      showForm: showForm ?? this.showForm,
    );
  }
}

class SanjiCookingFormWithData extends SanjiCookingState {
  final Map<String, dynamic> existingData;

  const SanjiCookingFormWithData({
    required this.existingData,
  });

  @override
  List<Object?> get props => [existingData];
}

class SanjiCookingError extends SanjiCookingState {
  final String message;

  const SanjiCookingError({required this.message});

  @override
  List<Object?> get props => [message];
}
