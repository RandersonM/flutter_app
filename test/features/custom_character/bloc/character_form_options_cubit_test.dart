import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:opfan/core/services/one_piece/i_devil_fruit_service.dart';
import 'package:opfan/features/crews/data/models/crew_model.dart';
import 'package:opfan/features/crews/data/repository/i_crew_repository.dart';
import 'package:opfan/features/custom_character/bloc/index.dart';
import 'package:opfan/features/devil_fruit/data/models/devil_fruit.dart';

class _MockDevilFruitService extends Mock implements IDevilFruitService {}

class _MockCrewRepository extends Mock implements ICrewRepository {}

void main() {
  late _MockDevilFruitService devilFruits;
  late _MockCrewRepository crews;

  final gomuGomu = DevilFruit(
    id: 1,
    name: 'Gum-Gum Fruit',
    description: 'Rubber body',
    romanName: 'Gomu Gomu no Mi',
    type: 'Paramecia',
  );
  final strawHats = CrewModel(id: 'c1', name: 'Straw Hats', userId: 'alice');

  setUp(() {
    devilFruits = _MockDevilFruitService();
    crews = _MockCrewRepository();
  });

  CharacterFormOptionsCubit build() => CharacterFormOptionsCubit(
    devilFruitService: devilFruits,
    crewRepository: crews,
  );

  group('CharacterFormOptionsCubit behaviour', () {
    blocTest<CharacterFormOptionsCubit, CharacterFormOptionsState>(
      'loads devil fruits and the user crews together',
      setUp: () {
        when(() => devilFruits.fetchAll()).thenAnswer((_) async => [gomuGomu]);
        when(() => crews.getUserCrews()).thenAnswer((_) async => [strawHats]);
      },
      build: build,
      act: (cubit) => cubit.load(),
      expect: () => [
        CharacterFormOptionsState(
          devilFruits: [gomuGomu],
          crews: [strawHats],
          isLoaded: true,
        ),
      ],
    );

    blocTest<CharacterFormOptionsCubit, CharacterFormOptionsState>(
      'keeps the crews when the devil fruit API fails',
      setUp: () {
        when(() => devilFruits.fetchAll()).thenThrow(Exception('offline'));
        when(() => crews.getUserCrews()).thenAnswer((_) async => [strawHats]);
      },
      build: build,
      act: (cubit) => cubit.load(),
      expect: () => [
        CharacterFormOptionsState(crews: [strawHats], isLoaded: true),
      ],
    );

    blocTest<CharacterFormOptionsCubit, CharacterFormOptionsState>(
      'keeps the devil fruits when loading crews fails',
      setUp: () {
        when(() => devilFruits.fetchAll()).thenAnswer((_) async => [gomuGomu]);
        when(() => crews.getUserCrews()).thenThrow(Exception('denied'));
      },
      build: build,
      act: (cubit) => cubit.load(),
      expect: () => [
        CharacterFormOptionsState(devilFruits: [gomuGomu], isLoaded: true),
      ],
    );
  });
}
