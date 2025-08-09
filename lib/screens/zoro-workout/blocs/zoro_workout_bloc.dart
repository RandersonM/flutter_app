import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../core/models/workout_assessment_model.dart';
import '../../../core/services/workout_assessment_service.dart';
import 'zoro_workout_event.dart';
import 'zoro_workout_state.dart';

class ZoroWorkoutBloc extends Bloc<ZoroWorkoutEvent, ZoroWorkoutState> {
  final WorkoutAssessmentService _service = WorkoutAssessmentService();

  ZoroWorkoutBloc() : super(const ZoroWorkoutInitial()) {
    on<InitializeWorkoutAssessment>(_onInitializeWorkoutAssessment);
    on<CheckAndCreateNewMonth>(_onCheckAndCreateNewMonth);
    on<SaveNewAssessment>(_onSaveNewAssessment);
    on<UpdateWorkoutDays>(_onUpdateWorkoutDays);
    on<UpdateHealthResults>(_onUpdateHealthResults);
    on<UpdateWorkoutDaysGoal>(_onUpdateWorkoutDaysGoal);
    on<RefreshAssessment>(_onRefreshAssessment);
    on<ClearError>(_onClearError);
  }

  Future<void> _onInitializeWorkoutAssessment(
    InitializeWorkoutAssessment event,
    Emitter<ZoroWorkoutState> emit,
  ) async {
    emit(const ZoroWorkoutLoading());
    
    try {
      final currentAssessment = await _service.getCurrentMonthAssessment();
      final assessmentHistory = await _service.getAssessmentHistory();
      
      emit(ZoroWorkoutLoaded(
        currentAssessment: currentAssessment,
        assessmentHistory: assessmentHistory,
        hasCurrentAssessment: currentAssessment != null,
        canEditCurrentAssessment: currentAssessment?.canEdit ?? false,
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
    emit(const ZoroWorkoutLoading());
    
    try {
      final currentAssessment = await _service.checkAndCreateNewMonth();
      final assessmentHistory = await _service.getAssessmentHistory();
      
      emit(ZoroWorkoutLoaded(
        currentAssessment: currentAssessment,
        assessmentHistory: assessmentHistory,
        hasCurrentAssessment: currentAssessment != null,
        canEditCurrentAssessment: currentAssessment?.canEdit ?? false,
        currentMonthProgress: _calculateProgress(currentAssessment),
        remainingDaysToGoal: _calculateRemainingDays(currentAssessment),
      ));
    } catch (e) {
      emit(ZoroWorkoutError(message: 'Erro ao verificar novo mês: $e'));
    }
  }

  Future<void> _onSaveNewAssessment(
    SaveNewAssessment event,
    Emitter<ZoroWorkoutState> emit,
  ) async {
    try {
      final currentAssessment = await _service.getCurrentMonthAssessment();
      
      if (currentAssessment != null) {
        final updatedAssessment = currentAssessment.copyWith(
          healthResults: event.healthResults,
          workoutDaysGoal: event.workoutDaysGoal,
        );
        
        await _service.saveAssessment(updatedAssessment);
        
        emit(ZoroWorkoutLoaded(
          currentAssessment: updatedAssessment,
          assessmentHistory: await _service.getAssessmentHistory(),
          hasCurrentAssessment: true,
          canEditCurrentAssessment: updatedAssessment.canEdit,
          currentMonthProgress: _calculateProgress(updatedAssessment),
          remainingDaysToGoal: _calculateRemainingDays(updatedAssessment),
        ));
      } else {
        final now = DateTime.now();
        final monthYear = '${now.year}-${now.month.toString().padLeft(2, '0')}';
        
        final newAssessment = WorkoutAssessment(
          userId: '',
          monthYear: monthYear,
          createdAt: now,
          healthResults: event.healthResults,
          workoutDaysGoal: event.workoutDaysGoal,
          workoutDays: [],
          isCurrentMonth: true,
        );
        
        await _service.saveAssessment(newAssessment);
        
        final savedAssessment = await _service.getCurrentMonthAssessment();
        
        emit(ZoroWorkoutLoaded(
          currentAssessment: savedAssessment,
          assessmentHistory: await _service.getAssessmentHistory(),
          hasCurrentAssessment: savedAssessment != null,
          canEditCurrentAssessment: savedAssessment?.canEdit ?? false,
          currentMonthProgress: _calculateProgress(savedAssessment),
          remainingDaysToGoal: _calculateRemainingDays(savedAssessment),
        ));
      }
    } catch (e) {
      emit(ZoroWorkoutError(message: 'Erro ao salvar avaliação: $e'));
    }
  }

  Future<void> _onUpdateWorkoutDays(
    UpdateWorkoutDays event,
    Emitter<ZoroWorkoutState> emit,
  ) async {
    try {
      final currentAssessment = await _service.getCurrentMonthAssessment();
      if (currentAssessment == null || !currentAssessment.canEdit) {
        emit(const ZoroWorkoutError(message: 'Não é possível editar este mês'));
        return;
      }

      await _service.updateWorkoutDays(event.workoutDays);
      final updatedAssessment = currentAssessment.copyWith(workoutDays: event.workoutDays);
      
      emit(ZoroWorkoutLoaded(
        currentAssessment: updatedAssessment,
        assessmentHistory: await _service.getAssessmentHistory(),
        hasCurrentAssessment: true,
        canEditCurrentAssessment: updatedAssessment.canEdit,
        currentMonthProgress: _calculateProgress(updatedAssessment),
        remainingDaysToGoal: _calculateRemainingDays(updatedAssessment),
      ));
    } catch (e) {
      emit(ZoroWorkoutError(message: 'Erro ao atualizar dias de exercício: $e'));
    }
  }

  Future<void> _onUpdateHealthResults(
    UpdateHealthResults event,
    Emitter<ZoroWorkoutState> emit,
  ) async {
    try {
      final currentAssessment = await _service.getCurrentMonthAssessment();
      if (currentAssessment == null || !currentAssessment.canEdit) {
        emit(const ZoroWorkoutError(message: 'Não é possível editar este mês'));
        return;
      }

      await _service.updateHealthResults(event.healthResults);
      final updatedAssessment = currentAssessment.copyWith(healthResults: event.healthResults);
      
      emit(ZoroWorkoutLoaded(
        currentAssessment: updatedAssessment,
        assessmentHistory: await _service.getAssessmentHistory(),
        hasCurrentAssessment: true,
        canEditCurrentAssessment: updatedAssessment.canEdit,
        currentMonthProgress: _calculateProgress(updatedAssessment),
        remainingDaysToGoal: _calculateRemainingDays(updatedAssessment),
      ));
    } catch (e) {
      emit(ZoroWorkoutError(message: 'Erro ao atualizar resultados de saúde: $e'));
    }
  }

  Future<void> _onUpdateWorkoutDaysGoal(
    UpdateWorkoutDaysGoal event,
    Emitter<ZoroWorkoutState> emit,
  ) async {
    try {
      final currentAssessment = await _service.getCurrentMonthAssessment();
      if (currentAssessment == null || !currentAssessment.canEdit) {
        emit(const ZoroWorkoutError(message: 'Não é possível editar este mês'));
        return;
      }

      await _service.updateWorkoutDaysGoal(event.workoutDaysGoal);
      final updatedAssessment = currentAssessment.copyWith(workoutDaysGoal: event.workoutDaysGoal);
      
      emit(ZoroWorkoutLoaded(
        currentAssessment: updatedAssessment,
        assessmentHistory: await _service.getAssessmentHistory(),
        hasCurrentAssessment: true,
        canEditCurrentAssessment: updatedAssessment.canEdit,
        currentMonthProgress: _calculateProgress(updatedAssessment),
        remainingDaysToGoal: _calculateRemainingDays(updatedAssessment),
      ));
    } catch (e) {
      emit(ZoroWorkoutError(message: 'Erro ao atualizar meta de dias: $e'));
    }
  }

  Future<void> _onRefreshAssessment(
    RefreshAssessment event,
    Emitter<ZoroWorkoutState> emit,
  ) async {
    try {
      final currentAssessment = await _service.getCurrentMonthAssessment();
      final assessmentHistory = await _service.getAssessmentHistory();
      
      emit(ZoroWorkoutLoaded(
        currentAssessment: currentAssessment,
        assessmentHistory: assessmentHistory,
        hasCurrentAssessment: currentAssessment != null,
        canEditCurrentAssessment: currentAssessment?.canEdit ?? false,
        currentMonthProgress: _calculateProgress(currentAssessment),
        remainingDaysToGoal: _calculateRemainingDays(currentAssessment),
      ));
    } catch (e) {
      emit(ZoroWorkoutError(message: 'Erro ao recarregar dados: $e'));
    }
  }

  void _onClearError(
    ClearError event,
    Emitter<ZoroWorkoutState> emit,
  ) {
    if (state is ZoroWorkoutLoaded) {
      emit(state);
    }
  }

  double _calculateProgress(WorkoutAssessment? assessment) {
    if (assessment == null) return 0.0;
    
    final goal = assessment.workoutDaysGoal;
    final completed = assessment.workoutDays.length;
    
    if (goal == 0) return 0.0;
    return (completed / goal).clamp(0.0, 1.0);
  }

  int _calculateRemainingDays(WorkoutAssessment? assessment) {
    if (assessment == null) return 0;
    
    final goal = assessment.workoutDaysGoal;
    final completed = assessment.workoutDays.length;
    
    return (goal - completed).clamp(0, goal);
  }
}
