import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:opfan/core/errors/app_exceptions.dart';
import 'package:opfan/features/crews/data/models/crew_model.dart';
import 'package:opfan/features/crews/data/repository/i_crew_repository.dart';
import 'package:opfan/features/custom_character/bloc/index.dart';
import 'package:opfan/features/custom_character/data/models/custom_character_model.dart';
import 'package:opfan/features/custom_character/data/repository/i_custom_character_repository.dart';

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
      expect: () => [
        CustomCharacterLoading(),
        const CustomCharacterError(CustomCharacterFailure.loadFailed),
      ],
    );
  });

  group('CustomCharacterBloc creation', () {
    setUp(() {
      when(
        () => crews.getCrew('c1'),
      ).thenAnswer((_) async => CrewModel(name: 'Straw Hats', userId: 'alice'));
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
      'deletes the new character when joining the crew fails',
      setUp: () {
        when(
          () => crews.addMemberToCrew(any(), any()),
        ).thenThrow(Exception('crew gone'));
        when(
          () => characters.deleteCustomCharacter('new-id'),
        ).thenAnswer((_) async {});
      },
      build: build,
      act: (bloc) => bloc.add(
        CreateCustomCharacter(luffy, crewId: 'c1', crewRole: 'captain'),
      ),
      expect: () => [
        CustomCharacterCreating(),
        const CustomCharacterError(CustomCharacterFailure.createFailed),
      ],
      verify: (_) =>
          verify(() => characters.deleteCustomCharacter('new-id')).called(1),
    );

    blocTest<CustomCharacterBloc, CustomCharacterState>(
      'reports the role as taken when it was filled after the check',
      setUp: () {
        when(
          () => crews.addMemberToCrew(any(), any()),
        ).thenThrow(const CrewRoleTakenException('captain'));
        when(
          () => characters.deleteCustomCharacter('new-id'),
        ).thenAnswer((_) async {});
      },
      build: build,
      act: (bloc) => bloc.add(
        CreateCustomCharacter(luffy, crewId: 'c1', crewRole: 'captain'),
      ),
      expect: () => [
        CustomCharacterCreating(),
        const CustomCharacterError(CustomCharacterFailure.crewRoleTaken),
      ],
      verify: (_) =>
          verify(() => characters.deleteCustomCharacter('new-id')).called(1),
    );

    blocTest<CustomCharacterBloc, CustomCharacterState>(
      'creates nothing when the chosen crew role is already taken',
      setUp: () => when(() => crews.getCrew('c1')).thenAnswer(
        (_) async => CrewModel(
          name: 'Straw Hats',
          userId: 'alice',
          captain: 'Monkey D. Luffy',
          rolesFilled: const ['captain'],
          members: [
            CrewMember(
              characterId: 'luffy',
              name: 'Monkey D. Luffy',
              role: 'captain',
              bounty: '0',
            ),
          ],
        ),
      ),
      build: build,
      act: (bloc) => bloc.add(
        CreateCustomCharacter(luffy, crewId: 'c1', crewRole: 'captain'),
      ),
      expect: () => [
        CustomCharacterCreating(),
        const CustomCharacterError(CustomCharacterFailure.crewRoleTaken),
      ],
      verify: (_) {
        verifyNever(() => characters.createCustomCharacter(any()));
        verifyNever(() => crews.addMemberToCrew(any(), any()));
      },
    );

    blocTest<CustomCharacterBloc, CustomCharacterState>(
      'emits createFailed when saving the character throws',
      setUp: () => when(
        () => characters.createCustomCharacter(any()),
      ).thenThrow(Exception('boom')),
      build: build,
      act: (bloc) => bloc.add(CreateCustomCharacter(luffy)),
      expect: () => [
        CustomCharacterCreating(),
        const CustomCharacterError(CustomCharacterFailure.createFailed),
      ],
    );

    blocTest<CustomCharacterBloc, CustomCharacterState>(
      'emits listRefreshFailed after the success when the refresh throws',
      setUp: () => when(
        () => characters.getUserCustomCharacters(),
      ).thenThrow(Exception('offline')),
      build: build,
      act: (bloc) => bloc.add(CreateCustomCharacter(luffy)),
      wait: listRefreshDelay,
      expect: () => [
        CustomCharacterCreating(),
        const CustomCharacterCreated('new-id'),
        const CustomCharacterError(CustomCharacterFailure.listRefreshFailed),
      ],
    );
  });

  group('CustomCharacterBloc update and delete', () {
    setUp(() {
      when(
        () => characters.getUserCustomCharacters(),
      ).thenAnswer((_) async => [luffy]);
      when(() => crews.getCrewsByMember(any())).thenAnswer((_) async => []);
    });

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
      'leaves the crew membership alone when the crew was not changed',
      setUp: () => when(
        () => characters.updateCustomCharacter('luffy', any()),
      ).thenAnswer((_) async {}),
      build: build,
      act: (bloc) => bloc.add(UpdateCustomCharacter('luffy', luffy)),
      wait: listRefreshDelay,
      verify: (_) => verifyNever(
        () => crews.moveMember(any(), toCrewId: any(named: 'toCrewId')),
      ),
    );

    blocTest<CustomCharacterBloc, CustomCharacterState>(
      'moves the character to the chosen crew and role before saving it',
      setUp: () {
        when(
          () => crews.moveMember(any(), toCrewId: any(named: 'toCrewId')),
        ).thenAnswer((_) async {});
        when(
          () => characters.updateCustomCharacter('luffy', any()),
        ).thenAnswer((_) async {});
      },
      build: build,
      act: (bloc) => bloc.add(
        UpdateCustomCharacter(
          'luffy',
          luffy,
          crewAssignment: const CrewAssignment(crewId: 'c2', role: 'cook'),
        ),
      ),
      wait: listRefreshDelay,
      expect: () => [
        CustomCharacterUpdating(),
        const CustomCharacterUpdated('luffy'),
        CustomCharacterLoaded([luffy]),
      ],
      verify: (_) {
        final member =
            verify(
                  () => crews.moveMember(captureAny(), toCrewId: 'c2'),
                ).captured.single
                as CrewMember;
        expect(member.characterId, 'luffy');
        expect(member.role, 'cook');
        expect(member.name, luffy.name);
      },
    );

    blocTest<CustomCharacterBloc, CustomCharacterState>(
      'saves nothing when the new crew role is taken',
      setUp: () => when(
        () => crews.moveMember(any(), toCrewId: any(named: 'toCrewId')),
      ).thenThrow(const CrewRoleTakenException('cook')),
      build: build,
      act: (bloc) => bloc.add(
        UpdateCustomCharacter(
          'luffy',
          luffy,
          crewAssignment: const CrewAssignment(crewId: 'c2', role: 'cook'),
        ),
      ),
      expect: () => [
        CustomCharacterUpdating(),
        const CustomCharacterError(CustomCharacterFailure.crewRoleTaken),
      ],
      verify: (_) =>
          verifyNever(() => characters.updateCustomCharacter(any(), any())),
    );

    blocTest<CustomCharacterBloc, CustomCharacterState>(
      'puts the character back in its crew when saving it fails',
      setUp: () {
        final captain = CrewMember(
          characterId: 'luffy',
          name: luffy.name,
          role: 'captain',
          bounty: luffy.bounty,
        );
        when(() => crews.getCrewsByMember('luffy')).thenAnswer(
          (_) async => [
            CrewModel(
              id: 'c1',
              name: 'Straw Hats',
              userId: 'alice',
              members: [captain],
            ),
          ],
        );
        when(
          () => crews.moveMember(any(), toCrewId: any(named: 'toCrewId')),
        ).thenAnswer((_) async {});
        when(
          () => characters.updateCustomCharacter('luffy', any()),
        ).thenThrow(Exception('offline'));
      },
      build: build,
      act: (bloc) => bloc.add(
        UpdateCustomCharacter(
          'luffy',
          luffy,
          crewAssignment: const CrewAssignment(crewId: 'c2', role: 'cook'),
        ),
      ),
      expect: () => [
        CustomCharacterUpdating(),
        const CustomCharacterError(CustomCharacterFailure.updateFailed),
      ],
      verify: (_) {
        verify(() => crews.moveMember(any(), toCrewId: 'c2')).called(1);
        final restored =
            verify(
                  () => crews.moveMember(captureAny(), toCrewId: 'c1'),
                ).captured.single
                as CrewMember;
        expect(restored.role, 'captain');
      },
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

    blocTest<CustomCharacterBloc, CustomCharacterState>(
      'emits updateFailed when saving the update throws',
      setUp: () => when(
        () => characters.updateCustomCharacter('luffy', any()),
      ).thenThrow(Exception('boom')),
      build: build,
      act: (bloc) => bloc.add(UpdateCustomCharacter('luffy', luffy)),
      expect: () => [
        CustomCharacterUpdating(),
        const CustomCharacterError(CustomCharacterFailure.updateFailed),
      ],
    );

    blocTest<CustomCharacterBloc, CustomCharacterState>(
      'emits deleteFailed when deleting throws',
      setUp: () => when(
        () => characters.deleteCustomCharacter('luffy'),
      ).thenThrow(Exception('boom')),
      build: build,
      act: (bloc) => bloc.add(const DeleteCustomCharacter('luffy')),
      expect: () => [
        CustomCharacterDeleting(),
        const CustomCharacterError(CustomCharacterFailure.deleteFailed),
      ],
    );
  });
}
