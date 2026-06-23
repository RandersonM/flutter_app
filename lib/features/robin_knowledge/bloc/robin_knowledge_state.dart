part of 'robin_knowledge_bloc.dart';

abstract class RobinKnowledgeState extends Equatable {
  const RobinKnowledgeState();

  @override
  List<Object?> get props => [];
}

class RobinKnowledgeInitial extends RobinKnowledgeState {}

class RobinKnowledgeLoading extends RobinKnowledgeState {}

class RobinKnowledgeLoaded extends RobinKnowledgeState {
  final List<GoalModel> goals;

  const RobinKnowledgeLoaded({required this.goals});

  @override
  List<Object?> get props => [goals];
}

class RobinKnowledgeError extends RobinKnowledgeState {
  final String message;

  const RobinKnowledgeError({required this.message});

  @override
  List<Object?> get props => [message];
}
