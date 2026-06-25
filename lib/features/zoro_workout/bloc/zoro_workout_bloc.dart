import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../core/models/workout_assessment_model.dart';
import '../../../core/services/workout_assessment_service.dart';
import '../../../core/services/auth_service.dart';
import '../../../app/di/injection.dart';
import '../../../core/auth/blocs/index.dart';
import 'zoro_workout_event.dart';
import 'zoro_workout_state.dart';

class ZoroWorkoutBloc extends Bloc<ZoroWorkoutEvent, ZoroWorkoutState> {
  final WorkoutAssessmentService _service = WorkoutAssessmentService();

  ZoroWorkoutBloc() : super(const ZoroWorkoutInitial()) {
    on<InitializeWorkoutAssessment>(_onInitializeWorkoutAssessment);
    on<CheckAndCreateNewMonth>(_onCheckAndCreateNewMonth);
    on<SaveNewAssessment>(_onSaveNewAssessment);
    on<UpdateWorkoutDays>(_onUpdateWorkoutDays);
    on<RefreshAssessment>(_onRefreshAssessment);
    on<ClearError>(_onClearError);
    on<SaveWorkoutPlan>(_onSaveWorkoutPlan);
  }

  Future<void> _onInitializeWorkoutAssessment(
    InitializeWorkoutAssessment event,
    Emitter<ZoroWorkoutState> emit,
  ) async {
    emit(const ZoroWorkoutLoading());

    try {
      final currentAssessment = await _service.getCurrentUserAssessment();
      final assessmentHistory = await _service.getUserAssessmentHistory();

      emit(ZoroWorkoutLoaded(
        currentAssessment: currentAssessment,
        assessmentHistory: assessmentHistory,
        hasCurrentAssessment: currentAssessment != null,
        canEditCurrentAssessment: true,
        currentMonthProgress: _calculateProgress(currentAssessment),
        remainingDaysToGoal: _calculateRemainingDays(currentAssessment),
      ));
    } catch (e) {
      emit(ZoroWorkoutError(message: 'Erro ao inicializar: $e'));
    }
  }

  Future<void> _onCheckAndCreateNewMonth(
    CheckAndCreateNewMonth event,
    Emitter<ZoroWorkoutState> emit,
  ) async {
    await _onInitializeWorkoutAssessment(
      const InitializeWorkoutAssessment(),
      emit,
    );
  }

  Future<void> _onSaveNewAssessment(
    SaveNewAssessment event,
    Emitter<ZoroWorkoutState> emit,
  ) async {
    try {
      final user = getIt<AuthService>().currentUser;
      if (user != null) {
        final updatedUser = user.copyWith(
          gender: event.healthResults['gender'] as String?,
          age: event.healthResults['age'] as int?,
          heightCm: event.healthResults['height'] as double?,
          weightKg: event.healthResults['weight'] as double?,
          waistCm: event.healthResults['waist'] as double?,
          activityLevel: event.healthResults['activity_level'] as String? ??
              user.activityLevel,
          goal: event.healthResults['goal'] as String? ?? user.goal,
        );
        getIt<AuthBloc>().add(AuthProfileBodyUpdated(updatedUser: updatedUser));
      }

      await _service.saveWorkoutAssessment(
        gender: event.healthResults['gender'] as String,
        age: event.healthResults['age'] as int,
        height: event.healthResults['height'] as double,
        weight: event.healthResults['weight'] as double,
        waist: event.healthResults['waist'] as double,
        bmi: event.healthResults['bmi'] as double?,
        waistToHeightRatio:
            event.healthResults['waist_to_height_ratio'] as double?,
        bodyFatPercentage:
            event.healthResults['body_fat_percentage'] as double?,
        healthScore: event.healthResults['health_score'] as double?,
        workoutDaysGoal: event.healthResults['workout_days_goal'] as int?,
        workoutDays: event.healthResults['workout_days'] as List<int>?,
        activityLevel: event.healthResults['activity_level'] as String? ??
            user?.activityLevel,
        goal: event.healthResults['goal'] as String? ?? user?.goal,
      );

      final currentAssessment = await _service.getCurrentUserAssessment();
      final assessmentHistory = await _service.getUserAssessmentHistory();

      emit(ZoroWorkoutLoaded(
        currentAssessment: currentAssessment,
        assessmentHistory: assessmentHistory,
        hasCurrentAssessment: currentAssessment != null,
        canEditCurrentAssessment: true,
        currentMonthProgress: _calculateProgress(currentAssessment),
        remainingDaysToGoal: _calculateRemainingDays(currentAssessment),
      ));
    } catch (e) {
      emit(ZoroWorkoutError(message: 'Erro ao salvar avaliação: $e'));
    }
  }

  Future<void> _onRefreshAssessment(
    RefreshAssessment event,
    Emitter<ZoroWorkoutState> emit,
  ) async {
    try {
      final currentAssessment = await _service.getCurrentUserAssessment();
      final assessmentHistory = await _service.getUserAssessmentHistory();

      emit(ZoroWorkoutLoaded(
        currentAssessment: currentAssessment,
        assessmentHistory: assessmentHistory,
        hasCurrentAssessment: currentAssessment != null,
        canEditCurrentAssessment: true,
        currentMonthProgress: _calculateProgress(currentAssessment),
        remainingDaysToGoal: _calculateRemainingDays(currentAssessment),
      ));
    } catch (e) {
      emit(ZoroWorkoutError(message: 'Erro ao atualizar: $e'));
    }
  }

  Future<void> _onUpdateWorkoutDays(
    UpdateWorkoutDays event,
    Emitter<ZoroWorkoutState> emit,
  ) async {
    try {
      final currentAssessment = await _service.getCurrentUserAssessment();
      if (currentAssessment == null) {
        emit(const ZoroWorkoutError(message: 'noAssessmentFound'));
        return;
      }

      await _service.updateWorkoutDays(event.workoutDays);

      final updatedAssessment = await _service.getCurrentUserAssessment();

      emit(ZoroWorkoutLoaded(
        currentAssessment: updatedAssessment,
        assessmentHistory: await _service.getUserAssessmentHistory(),
        hasCurrentAssessment: true,
        canEditCurrentAssessment: true,
        currentMonthProgress: _calculateProgress(updatedAssessment),
        remainingDaysToGoal: _calculateRemainingDays(updatedAssessment),
      ));
    } catch (e) {
      emit(ZoroWorkoutError(message: 'Error updating workout days: $e'));
    }
  }

  Future<void> _onSaveWorkoutPlan(
    SaveWorkoutPlan event,
    Emitter<ZoroWorkoutState> emit,
  ) async {
    try {
      await _service.updateWorkoutPlan(event.workoutPlan);

      final currentAssessment = await _service.getCurrentUserAssessment();
      final assessmentHistory = await _service.getUserAssessmentHistory();

      emit(ZoroWorkoutLoaded(
        currentAssessment: currentAssessment,
        assessmentHistory: assessmentHistory,
        hasCurrentAssessment: currentAssessment != null,
        canEditCurrentAssessment: true,
        currentMonthProgress: _calculateProgress(currentAssessment),
        remainingDaysToGoal: _calculateRemainingDays(currentAssessment),
      ));
    } catch (e) {
      emit(ZoroWorkoutError(message: 'Erro ao salvar plano de treino: $e'));
    }
  }

  void _onClearError(
    ClearError event,
    Emitter<ZoroWorkoutState> emit,
  ) {
    emit(const ZoroWorkoutInitial());
  }

  double _calculateProgress(WorkoutAssessmentModel? assessment) {
    if (assessment == null || assessment.workoutDaysGoal == null) return 0.0;

    return 0.0;
  }

  int _calculateRemainingDays(WorkoutAssessmentModel? assessment) {
    if (assessment == null || assessment.workoutDaysGoal == null) return 0;

    return 0;
  }
}
