import 'package:equatable/equatable.dart';

abstract class CreateCrewEvent extends Equatable {
  const CreateCrewEvent();

  @override
  List<Object?> get props => [];
}

class CreateCrewSubmitted extends CreateCrewEvent {
  final String name;
  final String? description;
  final String? jollyRogerUrl;
  final String? boatImageUrl;
  final List<String> tags;
  final String? boatName;

  const CreateCrewSubmitted({
    required this.name,
    this.description,
    this.jollyRogerUrl,
    this.boatImageUrl,
    this.tags = const [],
    this.boatName,
  });

  @override
  List<Object?> get props => [
    name,
    description,
    jollyRogerUrl,
    boatImageUrl,
    tags,
    boatName,
  ];
}

class CreateCrewReset extends CreateCrewEvent {}
