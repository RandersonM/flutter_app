import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get_it/get_it.dart';
import 'package:mocktail/mocktail.dart';
import 'package:opfan/core/services/one_piece/i_character_image_service.dart';
import 'package:opfan/core/services/one_piece/i_devil_fruit_service.dart';
import 'package:opfan/core/utils/character_localization_mapper.dart';
import 'package:opfan/features/crews/data/models/crew_model.dart';
import 'package:opfan/features/crews/data/repository/i_crew_repository.dart';
import 'package:opfan/features/custom_character/bloc/index.dart';
import 'package:opfan/features/custom_character/data/models/custom_character_model.dart';
import 'package:opfan/features/custom_character/data/repository/i_custom_character_repository.dart';
import 'package:opfan/features/custom_character/presentation/edit_custom_character_screen.dart';
import 'package:opfan/features/devil_fruit/data/models/devil_fruit.dart';
import 'package:opfan/features/duels/data/models/fighting_style_model.dart';
import 'package:opfan/l10n/app_localizations.dart';

import '../../testable_widget.dart';

class _MockCharacterRepository extends Mock
    implements ICustomCharacterRepository {}

class _MockCrewRepository extends Mock implements ICrewRepository {}

class _MockDevilFruitService extends Mock implements IDevilFruitService {}

class _MockCharacterImageService extends Mock
    implements ICharacterImageService {}

DevilFruit _fruit(int id, String romanName) => DevilFruit(
  id: id,
  name: romanName,
  description: '',
  romanName: romanName,
  type: 'Paramecia',
);

void main() {
  final getIt = GetIt.instance;
  late _MockCharacterRepository characters;
  late _MockCrewRepository crews;
  late _MockDevilFruitService devilFruits;

  final luffy = CustomCharacterModel(
    id: 'luffy',
    name: 'Monkey D. Luffy',
    devilFruit: 'Gomu Gomu no Mi',
    crew: 'Straw Hats',
    affiliations: const [],
    image: '',
    occupation: const [],
    bounty: '3,000,000,000',
    race: 'human',
    fightingStyle: FightingStyleModel(type: 'fighter'),
  );

  setUpAll(() {
    registerFallbackValue(luffy);
    registerFallbackValue(CrewMember(characterId: 'x', name: 'x', bounty: '0'));
  });

  setUp(() {
    characters = _MockCharacterRepository();
    crews = _MockCrewRepository();
    devilFruits = _MockDevilFruitService();
    when(
      () => characters.updateCustomCharacter(any(), any()),
    ).thenAnswer((_) async {});
    when(
      () => characters.getUserCustomCharacters(),
    ).thenAnswer((_) async => []);

    getIt
      ..registerFactory<CustomCharacterBloc>(
        () => CustomCharacterBloc(
          customCharacterRepository: characters,
          crewRepository: crews,
        ),
      )
      ..registerFactory<CharacterFormOptionsCubit>(
        () => CharacterFormOptionsCubit(
          devilFruitService: devilFruits,
          crewRepository: crews,
        ),
      )
      ..registerFactory<CharacterImageCubit>(
        () => CharacterImageCubit(
          characterImageService: _MockCharacterImageService(),
        ),
      );
  });

  tearDown(() => getIt.reset());

  Future<CustomCharacterModel> saveUnchanged(WidgetTester tester) async {
    await tester.pumpWidget(
      getTestableWidget(EditCustomCharacterScreen(character: luffy)),
    );
    await tester.pump();

    final update = find.text('Update');
    await tester.ensureVisible(update);
    await tester.tap(update);
    await tester.pump();

    final saved =
        verify(
              () => characters.updateCustomCharacter('luffy', captureAny()),
            ).captured.single
            as CustomCharacterModel;
    await tester.pump(const Duration(seconds: 1));
    return saved;
  }

  group('EditCustomCharacterScreen behaviour', () {
    testWidgets(
      'keeps the fruit and crew when the loaded options do not list them',
      (tester) async {
        when(() => devilFruits.fetchAll()).thenAnswer(
          (_) async => [
            _fruit(1, 'Mera Mera no Mi'),
            _fruit(2, 'Hie Hie no Mi'),
          ],
        );
        when(() => crews.getUserCrews()).thenAnswer(
          (_) async => [CrewModel(id: 'c1', name: 'Red Hairs', userId: 'u')],
        );

        final saved = await saveUnchanged(tester);

        expect(saved.devilFruit, 'Gomu Gomu no Mi');
        expect(saved.crew, 'Straw Hats');
      },
    );

    testWidgets('keeps the fruit and crew while the options are loading', (
      tester,
    ) async {
      final fruitsLoading = Completer<List<DevilFruit>>();
      final crewsLoading = Completer<List<CrewModel>>();
      when(
        () => devilFruits.fetchAll(),
      ).thenAnswer((_) => fruitsLoading.future);
      when(() => crews.getUserCrews()).thenAnswer((_) => crewsLoading.future);

      final saved = await saveUnchanged(tester);

      expect(saved.devilFruit, 'Gomu Gomu no Mi');
      expect(saved.crew, 'Straw Hats');
    });

    testWidgets('keeps the fruit and crew when they are among the options', (
      tester,
    ) async {
      when(() => devilFruits.fetchAll()).thenAnswer(
        (_) async => [
          _fruit(1, 'Mera Mera no Mi'),
          _fruit(2, 'Gomu Gomu no Mi'),
        ],
      );
      when(() => crews.getUserCrews()).thenAnswer(
        (_) async => [
          CrewModel(id: 'c1', name: 'Red Hairs', userId: 'u'),
          CrewModel(id: 'c2', name: 'Straw Hats', userId: 'u'),
        ],
      );

      final saved = await saveUnchanged(tester);

      expect(saved.devilFruit, 'Gomu Gomu no Mi');
      expect(saved.crew, 'Straw Hats');
    });

    testWidgets('offers the crew role the character already holds', (
      tester,
    ) async {
      when(() => devilFruits.fetchAll()).thenAnswer((_) async => []);
      when(() => crews.getUserCrews()).thenAnswer(
        (_) async => [
          CrewModel(
            id: 'c2',
            name: 'Straw Hats',
            userId: 'u',
            captain: 'Monkey D. Luffy',
            rolesFilled: const ['captain'],
            members: [
              CrewMember(
                characterId: 'luffy',
                name: 'Monkey D. Luffy',
                role: 'captain',
                bounty: '3,000,000,000',
              ),
            ],
          ),
        ],
      );

      await tester.pumpWidget(
        getTestableWidget(EditCustomCharacterScreen(character: luffy)),
      );
      await tester.pump();

      final l10n = AppLocalizations.of(
        tester.element(find.byType(EditCustomCharacterScreen)),
      )!;
      final captain = CharacterLocalizationMapper.mapOccupationToLocalized(
        'captain',
        l10n,
      );
      final dropdowns = tester.widgetList<DropdownButtonFormField<String>>(
        find.byType(DropdownButtonFormField<String>),
      );
      expect(
        dropdowns.map((dropdown) => dropdown.initialValue),
        contains(captain),
      );
    });

    testWidgets('leaves the crew membership alone when it was not edited', (
      tester,
    ) async {
      when(() => devilFruits.fetchAll()).thenAnswer((_) async => []);
      when(() => crews.getUserCrews()).thenAnswer((_) async => []);

      await saveUnchanged(tester);

      verifyNever(
        () => crews.moveMember(any(), toCrewId: any(named: 'toCrewId')),
      );
    });
  });
}
