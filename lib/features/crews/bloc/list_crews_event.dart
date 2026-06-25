import 'package:equatable/equatable.dart';

abstract class ListCrewsEvent extends Equatable {
  const ListCrewsEvent();

  @override
  List<Object?> get props => [];
}

class LoadCrews extends ListCrewsEvent {}

class LoadUserCrews extends ListCrewsEvent {}

class SearchCrews extends ListCrewsEvent {
  final String query;

  const SearchCrews(this.query);

  @override
  List<Object?> get props => [query];
}

class SearchUserCrews extends ListCrewsEvent {
  final String query;

  const SearchUserCrews(this.query);

  @override
  List<Object?> get props => [query];
}

class DeleteCrew extends ListCrewsEvent {
  final String crewId;

  const DeleteCrew(this.crewId);

  @override
  List<Object?> get props => [crewId];
}
