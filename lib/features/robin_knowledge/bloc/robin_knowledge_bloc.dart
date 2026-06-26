import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:opfan/features/robin_knowledge/data/models/goal_model.dart';
import 'package:opfan/features/robin_knowledge/data/repository/planner_repository_interface.dart';

part 'robin_knowledge_event.dart';
part 'robin_knowledge_state.dart';

class RobinKnowledgeBloc
    extends Bloc<RobinKnowledgeEvent, RobinKnowledgeState> {
  final PlannerRepositoryInterface _plannerRepository;

  RobinKnowledgeBloc({required this._plannerRepository})
    : super(RobinKnowledgeInitial()) {
    on<LoadGoals>(_onLoadGoals);
    on<AddGoal>(_onAddGoal);
    on<UpdateGoal>(_onUpdateGoal);
    on<DeleteGoal>(_onDeleteGoal);
    on<UpdateGoalProgress>(_onUpdateGoalProgress);
  }

  Future<void> _onLoadGoals(
      LoadGoals event, Emitter<RobinKnowledgeState> emit) async {
    emit(RobinKnowledgeLoading());
    try {
      final goals = await _plannerRepository.getGoals();
      emit(RobinKnowledgeLoaded(goals: goals));
    } catch (e) {
      emit(RobinKnowledgeError(message: e.toString()));
    }
  }

  Future<void> _onAddGoal(
      AddGoal event, Emitter<RobinKnowledgeState> emit) async {
    try {
      await _plannerRepository.createGoal(event.goal);
      final goals = await _plannerRepository.getGoals();
      emit(RobinKnowledgeLoaded(goals: goals));
    } catch (e) {
      emit(RobinKnowledgeError(message: e.toString()));
    }
  }

  Future<void> _onUpdateGoal(
      UpdateGoal event, Emitter<RobinKnowledgeState> emit) async {
    try {
      await _plannerRepository.updateGoal(event.goal);
      final goals = await _plannerRepository.getGoals();
      emit(RobinKnowledgeLoaded(goals: goals));
    } catch (e) {
      emit(RobinKnowledgeError(message: e.toString()));
    }
  }

  Future<void> _onDeleteGoal(
      DeleteGoal event, Emitter<RobinKnowledgeState> emit) async {
    try {
      await _plannerRepository.deleteGoal(event.goalId);
      final goals = await _plannerRepository.getGoals();
      emit(RobinKnowledgeLoaded(goals: goals));
    } catch (e) {
      emit(RobinKnowledgeError(message: e.toString()));
    }
  }

  Future<void> _onUpdateGoalProgress(
      UpdateGoalProgress event, Emitter<RobinKnowledgeState> emit) async {
    try {
      await _plannerRepository.updateGoalProgress(event.goalId, event.progress,
          notes: event.notes);
      final goals = await _plannerRepository.getGoals();
      emit(RobinKnowledgeLoaded(goals: goals));
    } catch (e) {
      emit(RobinKnowledgeError(message: e.toString()));
    }
  }
}
