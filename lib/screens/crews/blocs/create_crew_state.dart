import 'package:equatable/equatable.dart';

abstract class CreateCrewState extends Equatable {
  const CreateCrewState();

  @override
  List<Object?> get props => [];
}

class CreateCrewInitial extends CreateCrewState {}

class CreateCrewLoading extends CreateCrewState {}

class CreateCrewSuccess extends CreateCrewState {
  final String crewId;

  const CreateCrewSuccess(this.crewId);

  @override
  List<Object?> get props => [crewId];
}

class CreateCrewFailure extends CreateCrewState {
  final String error;

  const CreateCrewFailure(this.error);

  @override
  List<Object?> get props => [error];
} 