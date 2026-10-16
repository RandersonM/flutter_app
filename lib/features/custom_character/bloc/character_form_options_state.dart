import 'package:equatable/equatable.dart';
import 'package:opfan/features/crews/data/models/crew_model.dart';
import 'package:opfan/features/devil_fruit/data/models/devil_fruit.dart';

/// Choices offered by the character form: devil fruits and the user's crews.
final class CharacterFormOptionsState extends Equatable {
  const CharacterFormOptionsState({
    this.devilFruits = const [],
    this.crews = const [],
    this.isLoaded = false,
  });

  final List<DevilFruit> devilFruits;
  final List<CrewModel> crews;
  final bool isLoaded;

  @override
  List<Object?> get props => [devilFruits, crews, isLoaded];
}
