import 'package:equatable/equatable.dart';
import 'package:opfan/features/crews/data/models/crew_model.dart';

abstract class ListCrewsState extends Equatable {
  const ListCrewsState();

  @override
  List<Object?> get props => [];
}

class ListCrewsInitial extends ListCrewsState {}

class ListCrewsLoading extends ListCrewsState {}

class ListCrewsLoaded extends ListCrewsState {
  final List<CrewModel> crews;
  final String? currentUserId;

  const ListCrewsLoaded(this.crews, {this.currentUserId});

  bool canEdit(CrewModel crew) =>
      currentUserId != null && crew.userId == currentUserId;

  @override
  List<Object?> get props => [crews, currentUserId];
}

class ListCrewsError extends ListCrewsState {
  final String message;

  const ListCrewsError(this.message);

  @override
  List<Object?> get props => [message];
}
