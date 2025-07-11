import 'package:equatable/equatable.dart';

abstract class EditCrewEvent extends Equatable {
  const EditCrewEvent();

  @override
  List<Object?> get props => [];
}

class EditCrewSubmitted extends EditCrewEvent {
  final String crewId;
  final String name;
  final String? description;
  final String? jollyRogerUrl;
  final String? boatImageUrl;
  final List<String> tags;
  final String? boatName;

  const EditCrewSubmitted({
    required this.crewId,
    required this.name,
    this.description,
    this.jollyRogerUrl,
    this.boatImageUrl,
    this.tags = const [],
    this.boatName,
  });

  @override
  List<Object?> get props =>
      [crewId, name, description, jollyRogerUrl, boatImageUrl, tags, boatName];
}

class EditCrewReset extends EditCrewEvent {} 