import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:opfan/features/crews/data/models/crew_model.dart';
import 'package:opfan/features/crews/data/repository/crew_repository_interface.dart';
import 'package:opfan/features/custom_character/bloc/index.dart';
import 'package:opfan/features/custom_character/data/models/custom_character_model.dart';
import 'package:opfan/features/custom_character/data/repository/custom_character_repository_interface.dart';

class _MockCustomCharacterRepository extends Mock
    implements ICustomCharacterRepository {}

class _MockCrewRepository extends Mock implements ICrewRepository {}

CustomCharacterModel _character(String id) => CustomCharacterModel(
  id: id,
  name: 'Character $id',
  nickname: 'nick-$id',
  affiliations: const [],
  image: '',
  occupation: const [],
  bounty: '1,000',
);

void main() {
  late _MockCustomCharacterRepository characters;
  late _MockCrewRepository crews;

  final luffy = _character('luffy');
  const listRefreshDelay = Duration(milliseconds: 600);

  setUpAll(() {
    registerFallbackValue(luffy);
    registerFallbackValue(CrewMember(characterId: 'x', name: 'x', bounty: '0'));
  });

  setUp(() {
    characters = _MockCustomCharacterRepository();
    crews = _MockCrewRepository();
  });

  CustomCharacterBloc build() => CustomCharacterBloc(
    customCharacterRepository: characters,
    crewRepository: crews,
  );

  group('CustomCharacterBloc loading', () {
    blocTest<CustomCharacterBloc, CustomCharacterState>(
      'loads the user characters',
      setUp: () => when(
        () => characters.getUserCustomCharacters(),
      ).thenAnswer((_) async => [luffy]),
      build: build,
      act: (bloc) => bloc.add(const LoadCustomCharacters()),
      expect: () => [
        CustomCharacterLoading(),
        CustomCharacterLoaded([luffy]),
      ],
    );

    blocTest<CustomCharacterBloc, CustomCharacterState>(
      'emits an error when loading throws',
      setUp: () => when(
        () => characters.getUserCustomCharacters(),
      ).thenThrow(Exception('boom')),
      build: build,
      act: (bloc) => bloc.add(const LoadCustomCharacters()),
      expect: () => [CustomCharacterLoading(), isA<CustomCharacterError>()],
    );
  });

  group('CustomCharacterBloc creation', () {
    setUp(() {
      when(
        () => characters.createCustomCharacter(any()),
      ).thenAnswer((_) async => 'new-id');
      when(
        () => characters.getUserCustomCharacters(),
      ).thenAnswer((_) async => [luffy]);
    });

    blocTest<CustomCharacterBloc, CustomCharacterState>(
      'creates the character and refreshes the list',
      build: build,
      act: (bloc) => bloc.add(CreateCustomCharacter(luffy)),
      wait: listRefreshDelay,
      expect: () => [
        CustomCharacterCreating(),
        const CustomCharacterCreated('new-id'),
        CustomCharacterLoaded([luffy]),
      ],
      verify: (_) => verifyNever(() => crews.addMemberToCrew(any(), any())),
    );

    blocTest<CustomCharacterBloc, CustomCharacterState>(
      'adds the new character to the chosen crew with its role',
      setUp: () => when(
        () => crews.addMemberToCrew(any(), any()),
      ).thenAnswer((_) async {}),
      build: build,
      act: (bloc) => bloc.add(
        CreateCustomCharacter(luffy, crewId: 'c1', crewRole: 'captain'),
      ),
      wait: listRefreshDelay,
      verify: (_) {
        final member =
            verify(
                  () => crews.addMemberToCrew('c1', captureAny()),
                ).captured.single
                as CrewMember;
        expect(member.characterId, 'new-id');
        expect(member.role, 'captain');
      },
    );

    blocTest<CustomCharacterBloc, CustomCharacterState>(
      'still reports the character as created when joining the crew fails',
      setUp: () => when(
        () => crews.addMemberToCrew(any(), any()),
      ).thenThrow(Exception('crew gone')),
      build: build,
      act: (bloc) => bloc.add(
        CreateCustomCharacter(luffy, crewId: 'c1', crewRole: 'captain'),
      ),
      wait: listRefreshDelay,
      expect: () => [
        CustomCharacterCreating(),
        const CustomCharacterCreated('new-id'),
        CustomCharacterLoaded([luffy]),
      ],
    );
  });

  group('CustomCharacterBloc update and delete', () {
    setUp(
      () => when(
        () => characters.getUserCustomCharacters(),
      ).thenAnswer((_) async => [luffy]),
    );

    blocTest<CustomCharacterBloc, CustomCharacterState>(
      'updates the character and refreshes the list',
      setUp: () => when(
        () => characters.updateCustomCharacter('luffy', any()),
      ).thenAnswer((_) async {}),
      build: build,
      act: (bloc) => bloc.add(UpdateCustomCharacter('luffy', luffy)),
      wait: listRefreshDelay,
      expect: () => [
        CustomCharacterUpdating(),
        const CustomCharacterUpdated('luffy'),
        CustomCharacterLoaded([luffy]),
      ],
    );

    blocTest<CustomCharacterBloc, CustomCharacterState>(
      'deletes the character and refreshes the list',
      setUp: () => when(
        () => characters.deleteCustomCharacter('luffy'),
      ).thenAnswer((_) async {}),
      build: build,
      act: (bloc) => bloc.add(const DeleteCustomCharacter('luffy')),
      wait: listRefreshDelay,
      expect: () => [
        CustomCharacterDeleting(),
        const CustomCharacterDeleted('luffy'),
        CustomCharacterLoaded([luffy]),
      ],
    );
  });
}
