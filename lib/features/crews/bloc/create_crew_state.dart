import 'package:equatable/equatable.dart';
import 'package:opfan/features/crews/bloc/crews_failure.dart';

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
  final CrewsFailure failure;

  const CreateCrewFailure(this.failure);

  @override
  List<Object?> get props => [failure];
}
