import 'package:equatable/equatable.dart';

abstract class EditCrewState extends Equatable {
  const EditCrewState();

  @override
  List<Object?> get props => [];
}

class EditCrewInitial extends EditCrewState {}

class EditCrewLoading extends EditCrewState {}

class EditCrewSuccess extends EditCrewState {
  final String crewId;

  const EditCrewSuccess(this.crewId);

  @override
  List<Object?> get props => [crewId];
}

class EditCrewFailure extends EditCrewState {
  final String error;

  const EditCrewFailure(this.error);

  @override
  List<Object?> get props => [error];
}
