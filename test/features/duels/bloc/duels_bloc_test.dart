import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:opfan/core/errors/app_exceptions.dart';
import 'package:opfan/features/custom_character/data/models/custom_character_model.dart';
import 'package:opfan/features/custom_character/data/repository/i_custom_character_repository.dart';
import 'package:opfan/features/duels/bloc/index.dart';
import 'package:opfan/features/home/data/repository/i_featured_character_repository.dart';

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
          () => custom.getUserCustomCharacters(),
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
      'offers only canon characters to a signed-out guest',
      setUp: () {
        when(
          () => canon.getAllOnePieceCharacters(limit: 100),
        ).thenAnswer((_) async => [luffy, zoro]);
        when(
          () => custom.getUserCustomCharacters(),
        ).thenThrow(const NotSignedInException());
      },
      build: build,
      act: (bloc) => bloc.add(const LoadDuelsScreen()),
      expect: () => [
        const DuelsLoading(),
        DuelsReady(availableCharacters: [luffy, zoro]),
      ],
      verify: (_) => verifyNever(() => custom.getAllCustomCharacters()),
    );

    blocTest<DuelsBloc, DuelsState>(
      'emits an error when loading throws',
      setUp: () => when(
        () => canon.getAllOnePieceCharacters(limit: 100),
      ).thenThrow(Exception('offline')),
      build: build,
      act: (bloc) => bloc.add(const LoadDuelsScreen()),
      expect: () => [
        const DuelsLoading(),
        const DuelsError(DuelsFailure.loadFailed),
      ],
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

    // testWidgets runs in a fake-async zone, so the 2 s delay is driven by pump.
    testWidgets('a reset during the suspense delay wins over the result', (
      tester,
    ) async {
      when(
        () => canon.getAllOnePieceCharacters(limit: 100),
      ).thenAnswer((_) async => [luffy, zoro]);
      when(() => custom.getUserCustomCharacters()).thenAnswer((_) async => []);
      final bloc = build()..add(const LoadDuelsScreen());
      addTearDown(bloc.close);
      await tester.pump();
      bloc
        ..add(SelectFirstCharacter(luffy))
        ..add(SelectSecondCharacter(zoro))
        ..add(const StartDuel());
      await tester.pump(const Duration(seconds: 1));
      expect((bloc.state as DuelsReady).isDuelInProgress, isTrue);

      bloc.add(const ResetDuel());
      await tester.pump(const Duration(seconds: 2));

      expect(bloc.state, DuelsReady(availableCharacters: [luffy, zoro]));
    });

    Future<DuelsBloc> startDuelBetweenLuffyAndZoro(WidgetTester tester) async {
      when(
        () => canon.getAllOnePieceCharacters(limit: 100),
      ).thenAnswer((_) async => [luffy, zoro, mine]);
      when(() => custom.getUserCustomCharacters()).thenAnswer((_) async => []);
      final bloc = build()..add(const LoadDuelsScreen());
      addTearDown(bloc.close);
      await tester.pump();
      bloc
        ..add(SelectFirstCharacter(luffy))
        ..add(SelectSecondCharacter(zoro))
        ..add(const StartDuel());
      await tester.pump(const Duration(seconds: 1));
      expect((bloc.state as DuelsReady).isDuelInProgress, isTrue);
      return bloc;
    }

    testWidgets(
      'picking a fighter during the suspense delay cancels the duel',
      (tester) async {
        final bloc = await startDuelBetweenLuffyAndZoro(tester);

        bloc.add(SelectSecondCharacter(mine));
        await tester.pump(const Duration(seconds: 2));

        expect(
          bloc.state,
          DuelsReady(
            availableCharacters: [luffy, zoro, mine],
            firstCharacter: luffy,
            secondCharacter: mine,
          ),
        );
      },
    );

    testWidgets(
      'clearing a fighter during the suspense delay cancels the duel',
      (tester) async {
        final bloc = await startDuelBetweenLuffyAndZoro(tester);

        bloc.add(const ClearCharacterSelection(1));
        await tester.pump(const Duration(seconds: 2));

        expect(
          bloc.state,
          DuelsReady(
            availableCharacters: [luffy, zoro, mine],
            secondCharacter: zoro,
          ),
        );
      },
    );

    testWidgets('shuffling during the suspense delay cancels the duel', (
      tester,
    ) async {
      final bloc = await startDuelBetweenLuffyAndZoro(tester);

      bloc.add(const RandomizeCharacters());
      await tester.pump();
      final shuffled = bloc.state as DuelsReady;
      await tester.pump(const Duration(seconds: 2));

      expect(bloc.state, shuffled);
      expect(shuffled.isDuelInProgress, isFalse);
      expect(shuffled.winner, isNull);
    });

    testWidgets('a new duel after a cancelled one judges the new pair', (
      tester,
    ) async {
      final bloc = await startDuelBetweenLuffyAndZoro(tester);

      bloc
        ..add(SelectSecondCharacter(mine))
        ..add(const StartDuel());
      await tester.pump(const Duration(seconds: 3));

      final state = bloc.state as DuelsReady;
      expect(state.secondCharacter, mine);
      expect(state.isDuelInProgress, isFalse);
      expect(state.winner, anyOf(luffy, mine));
    });

    for (final (description, event) in [
      ('picking a new first fighter', SelectFirstCharacter(mine)),
      ('picking a new second fighter', SelectSecondCharacter(mine)),
      ('clearing a fighter', const ClearCharacterSelection(1)),
    ]) {
      blocTest<DuelsBloc, DuelsState>(
        '$description drops the previous winner',
        build: build,
        seed: () => DuelsReady(
          availableCharacters: [luffy, zoro, mine],
          firstCharacter: luffy,
          secondCharacter: zoro,
          winner: luffy,
        ),
        act: (bloc) => bloc.add(event),
        verify: (bloc) => expect((bloc.state as DuelsReady).winner, isNull),
      );
    }

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
