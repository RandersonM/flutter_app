import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../core/services/nutrition_calculation_service.dart';
import '../../../core/services/workout_assessment_service.dart';
import 'sanji_cooking_event.dart';
import 'sanji_cooking_state.dart';

class SanjiCookingBloc extends Bloc<SanjiCookingEvent, SanjiCookingState> {
  final WorkoutAssessmentService _workoutService = WorkoutAssessmentService();

  SanjiCookingBloc() : super(const SanjiCookingInitial()) {
    on<InitializeSanjiCooking>(_onInitializeSanjiCooking);
    on<CalculateNutrition>(_onCalculateNutrition);
    on<SaveNutritionData>(_onSaveNutritionData);
    on<NewCalculation>(_onNewCalculation);
    on<ClearError>(_onClearError);
  }

  Future<void> _onInitializeSanjiCooking(
    InitializeSanjiCooking event,
    Emitter<SanjiCookingState> emit,
  ) async {
    emit(const SanjiCookingLoading());
    
    try {
      final currentAssessment = await _workoutService.getCurrentUserAssessment();
      
      if (currentAssessment != null) {
        final hasRequiredData = currentAssessment.gender.isNotEmpty &&
            currentAssessment.age > 0 &&
            currentAssessment.height > 0 &&
            currentAssessment.weight > 0 &&
            currentAssessment.activityLevel != null &&
            currentAssessment.goal != null &&
            currentAssessment.waist > 0;
        
        if (hasRequiredData) {
          final nutritionResults = NutritionCalculationService.calculateNutrition(
            age: currentAssessment.age,
            gender: currentAssessment.gender,
            weight: currentAssessment.weight,
            height: currentAssessment.height,
            waist: currentAssessment.waist,
            activityLevel: currentAssessment.activityLevel!,
            goal: currentAssessment.goal!,
          );
          
          emit(SanjiCookingLoaded(
            nutritionResults: nutritionResults,
            hasExistingData: true,
            showForm: false,
          ));
        } else {
          // Preparar dados existentes para o formulário
          final existingData = {
            'age': currentAssessment.age,
            'gender': currentAssessment.gender,
            'weight': currentAssessment.weight,
            'height': currentAssessment.height,
            'waist': currentAssessment.waist,
            'activityLevel': currentAssessment.activityLevel,
            'goal': currentAssessment.goal,
          };
          
          emit(SanjiCookingFormWithData(existingData: existingData));
        }
      } else {
        emit(const SanjiCookingLoaded(
          hasExistingData: false,
          showForm: true,
        ));
      }
    } catch (e) {
      emit(SanjiCookingError(message: 'Erro ao inicializar: $e'));
    }
  }

  Future<void> _onCalculateNutrition(
    CalculateNutrition event,
    Emitter<SanjiCookingState> emit,
  ) async {
    emit(const SanjiCookingLoading());
    
    try {
      final nutritionResults = NutritionCalculationService.calculateNutrition(
        age: event.nutritionData['age'],
        gender: event.nutritionData['gender'],
        weight: event.nutritionData['weight'],
        height: event.nutritionData['height'],
        waist: event.nutritionData['waist'],
        activityLevel: event.nutritionData['activityLevel'],
        goal: event.nutritionData['goal'],
      );
      
      emit(SanjiCookingLoaded(
        nutritionResults: nutritionResults,
        hasExistingData: false,
        showForm: false,
      ));
    } catch (e) {
      emit(SanjiCookingError(message: 'Erro ao calcular nutrição: $e'));
    }
  }

  Future<void> _onSaveNutritionData(
    SaveNutritionData event,
    Emitter<SanjiCookingState> emit,
  ) async {
    try {
      debugPrint('SanjiCookingBloc: Starting _onSaveNutritionData');
      debugPrint('SanjiCookingBloc: nutritionData: ${event.nutritionData}');
      
      await _workoutService.updateNutritionData(
        gender: event.nutritionData['gender'],
        age: event.nutritionData['age'],
        height: event.nutritionData['height'],
        weight: event.nutritionData['weight'],
        waist: event.nutritionData['waist'],
        activityLevel: event.nutritionData['activityLevel'],
        goal: event.nutritionData['goal'],
      );
      
      debugPrint('SanjiCookingBloc: Successfully saved nutrition data');
      
      emit(const SanjiCookingLoaded(
        hasExistingData: false,
        showForm: true,
      ));
    } catch (e, stackTrace) {
      debugPrint('SanjiCookingBloc: Error in _onSaveNutritionData: $e');
      debugPrint('SanjiCookingBloc: Stack trace: $stackTrace');
      emit(SanjiCookingError(message: 'Error saving nutrition data: $e'));
    }
  }

  void _onNewCalculation(
    NewCalculation event,
    Emitter<SanjiCookingState> emit,
  ) async {
    try {
      final currentAssessment = await _workoutService.getCurrentUserAssessment();
      
      if (currentAssessment != null) {
        final existingData = {
          'age': currentAssessment.age,
          'gender': currentAssessment.gender,
          'weight': currentAssessment.weight,
          'height': currentAssessment.height,
          'waist': currentAssessment.waist,
          'activityLevel': currentAssessment.activityLevel,
          'goal': currentAssessment.goal,
        };
        
        emit(SanjiCookingFormWithData(existingData: existingData));
      } else {
        emit(const SanjiCookingLoaded(
          hasExistingData: false,
          showForm: true,
        ));
      }
    } catch (e) {
      emit(SanjiCookingError(message: 'Erro ao carregar dados existentes: $e'));
    }
  }

  void _onClearError(
    ClearError event,
    Emitter<SanjiCookingState> emit,
  ) {
    emit(const SanjiCookingInitial());
  }
}
