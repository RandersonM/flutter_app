import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:opfan/features/custom_character/data/models/custom_character_model.dart';
import 'package:opfan/features/custom_character/data/repository/custom_character_repository_interface.dart';
import 'package:opfan/features/duels/bloc/index.dart';
import 'package:opfan/features/home/data/repository/featured_character_repository_interface.dart';

class _MockFeaturedCharacterRepository extends Mock
    implements IFeaturedCharacterRepository {}

class _MockCustomCharacterRepository extends Mock
    implements ICustomCharacterRepository {}

CustomCharacterModel _character(String id) => CustomCharacterModel(
  id: id,
  name: id,
  affiliations: const [],
  image: '',
  occupation: const [],
  bounty: '0',
);

void main() {
  late _MockFeaturedCharacterRepository canon;
  late _MockCustomCharacterRepository custom;

  final luffy = _character('luffy');
  final zoro = _character('zoro');
  final mine = _character('mine');

  setUp(() {
    canon = _MockFeaturedCharacterRepository();
    custom = _MockCustomCharacterRepository();
  });

  DuelsBloc build() => DuelsBloc(
    featuredCharacterRepository: canon,
    customCharacterRepository: custom,
  );

  group('DuelsBloc loading', () {
    blocTest<DuelsBloc, DuelsState>(
      'offers custom characters first, then 100 canon characters',
      setUp: () {
        when(
          () => canon.getAllOnePieceCharacters(limit: 100),
        ).thenAnswer((_) async => [luffy, zoro]);
        when(
          () => custom.getAllCustomCharacters(),
        ).thenAnswer((_) async => [mine]);
      },
      build: build,
      act: (bloc) => bloc.add(const LoadDuelsScreen()),
      expect: () => [
        const DuelsLoading(),
        DuelsReady(availableCharacters: [mine, luffy, zoro]),
      ],
    );

    blocTest<DuelsBloc, DuelsState>(
      'emits an error when loading throws',
      setUp: () => when(
        () => canon.getAllOnePieceCharacters(limit: 100),
      ).thenThrow(Exception('offline')),
      build: build,
      act: (bloc) => bloc.add(const LoadDuelsScreen()),
      expect: () => [const DuelsLoading(), isA<DuelsError>()],
    );
  });

  group('DuelsBloc selection', () {
    final ready = DuelsReady(availableCharacters: [luffy, zoro]);

    blocTest<DuelsBloc, DuelsState>(
      'fills both slots',
      build: build,
      seed: () => ready,
      act: (bloc) => bloc
        ..add(SelectFirstCharacter(luffy))
        ..add(SelectSecondCharacter(zoro)),
      expect: () => [
        ready.copyWith(firstCharacter: luffy),
        ready.copyWith(firstCharacter: luffy, secondCharacter: zoro),
      ],
    );

    blocTest<DuelsBloc, DuelsState>(
      'moves a character to the other slot instead of duplicating it',
      build: build,
      seed: () => ready.copyWith(firstCharacter: luffy),
      act: (bloc) => bloc.add(SelectSecondCharacter(luffy)),
      expect: () => [ready.copyWith(secondCharacter: luffy)],
    );

    blocTest<DuelsBloc, DuelsState>(
      'clears one slot and resets both',
      build: build,
      seed: () => ready.copyWith(firstCharacter: luffy, secondCharacter: zoro),
      act: (bloc) => bloc
        ..add(const ClearCharacterSelection(1))
        ..add(const ResetDuel()),
      expect: () => [ready.copyWith(secondCharacter: zoro), ready],
    );
  });

  group('DuelsBloc duel', () {
    blocTest<DuelsBloc, DuelsState>(
      'picks one of the two fighters as the winner',
      build: build,
      seed: () => DuelsReady(
        availableCharacters: [luffy, zoro],
        firstCharacter: luffy,
        secondCharacter: zoro,
      ),
      act: (bloc) => bloc.add(const StartDuel()),
      wait: const Duration(milliseconds: 2100),
      expect: () => [
        isA<DuelsReady>().having(
          (s) => s.isDuelInProgress,
          'in progress',
          isTrue,
        ),
        isA<DuelsReady>()
            .having((s) => s.isDuelInProgress, 'in progress', isFalse)
            .having((s) => s.winner, 'winner', anyOf(luffy, zoro)),
      ],
    );

    blocTest<DuelsBloc, DuelsState>(
      'does not start without two fighters',
      build: build,
      seed: () =>
          DuelsReady(availableCharacters: [luffy, zoro], firstCharacter: luffy),
      act: (bloc) => bloc.add(const StartDuel()),
      expect: () => const <DuelsState>[],
    );
  });
}
