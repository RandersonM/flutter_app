import 'package:equatable/equatable.dart';

abstract class SanjiCookingEvent extends Equatable {
  const SanjiCookingEvent();

  @override
  List<Object?> get props => [];
}

class InitializeSanjiCooking extends SanjiCookingEvent {
  const InitializeSanjiCooking();
}

class CalculateNutrition extends SanjiCookingEvent {
  final Map<String, dynamic> nutritionData;

  const CalculateNutrition({required this.nutritionData});

  @override
  List<Object?> get props => [nutritionData];
}

class SaveNutritionData extends SanjiCookingEvent {
  final Map<String, dynamic> nutritionData;

  const SaveNutritionData({required this.nutritionData});

  @override
  List<Object?> get props => [nutritionData];
}

class NewCalculation extends SanjiCookingEvent {
  const NewCalculation();
}

class ClearError extends SanjiCookingEvent {
  const ClearError();
}
