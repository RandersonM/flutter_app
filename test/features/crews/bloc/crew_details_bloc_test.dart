import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:opfan/core/auth/models/user_model.dart';
import 'package:opfan/core/services/auth_db/i_auth_service.dart';
import 'package:opfan/features/crews/bloc/index.dart';
import 'package:opfan/features/crews/data/models/crew_model.dart';
import 'package:opfan/features/crews/data/repository/i_crew_repository.dart';
import 'package:opfan/features/custom_character/data/models/custom_character_model.dart';
import 'package:opfan/features/custom_character/data/repository/i_custom_character_repository.dart';

class _MockCrewRepository extends Mock implements ICrewRepository {}

class _MockCustomCharacterRepository extends Mock
    implements ICustomCharacterRepository {}

class _MockAuthService extends Mock implements IAuthService {}

UserModel _user(String uid) => UserModel(
  uid: uid,
  email: '$uid@example.com',
  displayName: uid,
  emailVerified: true,
  providerId: 'google.com',
  createdAt: DateTime(2024),
  lastSignIn: DateTime(2024),
);

CustomCharacterModel _character(String id) => CustomCharacterModel(
  id: id,
  name: 'Character $id',
  nickname: 'nick-$id',
  affiliations: const [],
  image: '',
  occupation: const [],
  bounty: '1,000',
);

CrewModel _crew({List<CrewMember> members = const [], String id = 'c1'}) =>
    CrewModel(
      id: id,
      name: 'Straw Hats',
      userId: 'alice',
      members: members,
      rolesFilled: [for (final member in members) member.role!],
    );

CrewMember _member(String characterId, String role) => CrewMember(
  characterId: characterId,
  name: 'Character $characterId',
  role: role,
  bounty: '0',
);

void main() {
  late _MockCrewRepository crews;
  late _MockCustomCharacterRepository characters;
  late _MockAuthService auth;

  setUpAll(() {
    registerFallbackValue(_crew());
    registerFallbackValue(_character('fallback'));
  });

  setUp(() {
    crews = _MockCrewRepository();
    characters = _MockCustomCharacterRepository();
    auth = _MockAuthService();
    when(() => auth.currentUser).thenReturn(_user('alice'));
  });

  CrewDetailsBloc build({CrewModel? crew}) => CrewDetailsBloc(
    crew: crew ?? _crew(),
    crewRepository: crews,
    customCharacterRepository: characters,
    authService: auth,
  );

  group('CrewDetailsBloc ownership', () {
    test('owns the crew when the signed-in user created it', () {
      expect(build().state.isOwner, isTrue);
    });

    test('does not own a crew created by someone else', () {
      when(() => auth.currentUser).thenReturn(_user('bob'));
      expect(build().state.isOwner, isFalse);
    });

    test('does not own any crew when signed out', () {
      when(() => auth.currentUser).thenReturn(null);
      expect(build().state.isOwner, isFalse);
    });
  });

  group('CrewDetailsBloc deletion', () {
    blocTest<CrewDetailsBloc, CrewDetailsState>(
      'deletes the crew and reports it',
      setUp: () => when(() => crews.deleteCrew('c1')).thenAnswer((_) async {}),
      build: build,
      act: (bloc) => bloc.add(const ConfirmCrewDeletion()),
      expect: () => [
        isA<CrewDetailsState>().having((s) => s.isBusy, 'isBusy', isTrue),
        isA<CrewDetailsState>()
            .having((s) => s.isBusy, 'isBusy', isFalse)
            .having((s) => s.effect, 'effect', const CrewDeleted()),
      ],
      verify: (_) => verify(() => crews.deleteCrew('c1')).called(1),
    );

    blocTest<CrewDetailsBloc, CrewDetailsState>(
      'ignores deletion when the user does not own the crew',
      setUp: () => when(() => auth.currentUser).thenReturn(_user('bob')),
      build: build,
      act: (bloc) => bloc.add(const ConfirmCrewDeletion()),
      expect: () => const <CrewDetailsState>[],
      verify: (_) => verifyNever(() => crews.deleteCrew(any())),
    );

    blocTest<CrewDetailsBloc, CrewDetailsState>(
      'emits a failure, not a message, when deletion throws',
      setUp: () =>
          when(() => crews.deleteCrew('c1')).thenThrow(Exception('boom')),
      build: build,
      act: (bloc) => bloc.add(const ConfirmCrewDeletion()),
      skip: 1,
      expect: () => [
        isA<CrewDetailsState>().having(
          (s) => s.effect,
          'effect',
          const CrewDetailsFailed(CrewDetailsFailure.deleteFailed),
        ),
      ],
    );
  });

  group('CrewDetailsBloc available characters', () {
    blocTest<CrewDetailsBloc, CrewDetailsState>(
      'lists only characters that are in none of the user crews',
      setUp: () {
        when(
          () => characters.getUserCustomCharacters(),
        ).thenAnswer((_) async => [_character('a'), _character('b')]);
        when(() => crews.getUserCrews()).thenAnswer(
          (_) async => [
            _crew(id: 'other', members: [_member('a', 'cook')]),
          ],
        );
      },
      build: build,
      act: (bloc) => bloc.add(const LoadAvailableCharacters()),
      skip: 1,
      expect: () => [
        isA<CrewDetailsState>().having(
          (s) => s.availableCharacters?.map((c) => c.id),
          'available ids',
          ['b'],
        ),
      ],
    );

    blocTest<CrewDetailsBloc, CrewDetailsState>(
      'falls back to an empty list when loading fails',
      setUp: () => when(
        () => characters.getUserCustomCharacters(),
      ).thenThrow(Exception('boom')),
      build: build,
      act: (bloc) => bloc.add(const LoadAvailableCharacters()),
      skip: 1,
      expect: () => [
        isA<CrewDetailsState>().having(
          (s) => s.availableCharacters,
          'availableCharacters',
          isEmpty,
        ),
      ],
    );
  });

  group('CrewDetailsBloc adding a member', () {
    final luffy = _character('luffy');

    blocTest<CrewDetailsBloc, CrewDetailsState>(
      'adds the member, fills the role and moves the character to the crew',
      setUp: () {
        when(() => crews.updateCrew(any(), any())).thenAnswer((_) async {});
        when(
          () => characters.updateCustomCharacter(any(), any()),
        ).thenAnswer((_) async {});
      },
      build: build,
      act: (bloc) =>
          bloc.add(AddCrewMember(character: luffy, roleKey: 'captain')),
      skip: 1,
      expect: () => [
        isA<CrewDetailsState>()
            .having((s) => s.crew.members.single.characterId, 'member', 'luffy')
            .having((s) => s.crew.rolesFilled, 'rolesFilled', ['captain'])
            .having(
              (s) => s.effect,
              'effect',
              const CrewMemberAdded(
                characterName: 'Character luffy',
                roleKey: 'captain',
              ),
            ),
      ],
      verify: (_) {
        final savedCrew =
            verify(() => crews.updateCrew('c1', captureAny())).captured.single
                as CrewModel;
        expect(savedCrew.members.single.role, 'captain');
        final savedCharacter =
            verify(
                  () => characters.updateCustomCharacter('luffy', captureAny()),
                ).captured.single
                as CustomCharacterModel;
        expect(savedCharacter.crew, 'Straw Hats');
      },
    );

    blocTest<CrewDetailsBloc, CrewDetailsState>(
      'keeps the crew unchanged and reports a failure when saving throws',
      setUp: () => when(
        () => crews.updateCrew(any(), any()),
      ).thenThrow(Exception('boom')),
      build: build,
      act: (bloc) =>
          bloc.add(AddCrewMember(character: luffy, roleKey: 'captain')),
      skip: 1,
      expect: () => [
        isA<CrewDetailsState>()
            .having((s) => s.crew.members, 'members', isEmpty)
            .having(
              (s) => s.effect,
              'effect',
              const CrewDetailsFailed(CrewDetailsFailure.addMemberFailed),
            ),
      ],
      verify: (_) =>
          verifyNever(() => characters.updateCustomCharacter(any(), any())),
    );
  });

  group('CrewDetailsBloc opening a member', () {
    final member = _member('zoro', 'viceCaptain');

    blocTest<CrewDetailsBloc, CrewDetailsState>(
      'opens the member character when it exists',
      setUp: () => when(
        () => characters.getCustomCharacter('zoro'),
      ).thenAnswer((_) async => _character('zoro')),
      build: build,
      act: (bloc) => bloc.add(OpenCrewMember(member)),
      skip: 1,
      expect: () => [
        isA<CrewDetailsState>().having(
          (s) => s.effect,
          'effect',
          isA<CrewMemberOpened>().having(
            (e) => e.character.id,
            'character',
            'zoro',
          ),
        ),
      ],
    );

    blocTest<CrewDetailsBloc, CrewDetailsState>(
      'reports a missing character',
      setUp: () => when(
        () => characters.getCustomCharacter('zoro'),
      ).thenAnswer((_) async => null),
      build: build,
      act: (bloc) => bloc.add(OpenCrewMember(member)),
      skip: 1,
      expect: () => [
        isA<CrewDetailsState>().having(
          (s) => s.effect,
          'effect',
          const CrewMemberNotFound(),
        ),
      ],
    );

    blocTest<CrewDetailsBloc, CrewDetailsState>(
      'reports a load failure when the lookup throws',
      setUp: () => when(
        () => characters.getCustomCharacter('zoro'),
      ).thenThrow(Exception('boom')),
      build: build,
      act: (bloc) => bloc.add(OpenCrewMember(member)),
      skip: 1,
      expect: () => [
        isA<CrewDetailsState>().having(
          (s) => s.effect,
          'effect',
          const CrewDetailsFailed(CrewDetailsFailure.memberLoadFailed),
        ),
      ],
    );
  });
}
