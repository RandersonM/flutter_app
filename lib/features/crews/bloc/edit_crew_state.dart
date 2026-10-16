import 'package:equatable/equatable.dart';
import 'package:opfan/features/crews/bloc/crews_failure.dart';

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
  final CrewsFailure failure;

  const EditCrewFailure(this.failure);

  @override
  List<Object?> get props => [failure];
}
