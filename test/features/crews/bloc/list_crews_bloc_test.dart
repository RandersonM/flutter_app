import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:opfan/core/auth/models/user_model.dart';
import 'package:opfan/core/services/auth_db/i_auth_service.dart';
import 'package:opfan/features/crews/bloc/index.dart';
import 'package:opfan/features/crews/data/models/crew_model.dart';
import 'package:opfan/features/crews/data/repository/i_crew_repository.dart';

class _MockCrewRepository extends Mock implements ICrewRepository {}

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

void main() {
  late _MockCrewRepository repository;
  late _MockAuthService auth;

  final aliceCrew = CrewModel(id: 'c1', name: 'Straw Hats', userId: 'alice');
  final bobCrew = CrewModel(id: 'c2', name: 'Heart Pirates', userId: 'bob');

  setUp(() {
    repository = _MockCrewRepository();
    auth = _MockAuthService();
    when(() => auth.currentUser).thenReturn(_user('alice'));
  });

  ListCrewsBloc build() =>
      ListCrewsBloc(crewRepository: repository, authService: auth);

  group('ListCrewsBloc behaviour', () {
    blocTest<ListCrewsBloc, ListCrewsState>(
      'loads the user crews tagged with the signed-in user',
      setUp: () => when(
        () => repository.getUserCrews(),
      ).thenAnswer((_) async => [aliceCrew]),
      build: build,
      act: (bloc) => bloc.add(LoadUserCrews()),
      expect: () => [
        ListCrewsLoading(),
        ListCrewsLoaded([aliceCrew], currentUserId: 'alice'),
      ],
    );

    blocTest<ListCrewsBloc, ListCrewsState>(
      'filters all crews by name, ignoring case',
      setUp: () => when(
        () => repository.getAllCrews(),
      ).thenAnswer((_) async => [aliceCrew, bobCrew]),
      build: build,
      act: (bloc) => bloc.add(const SearchCrews('heart')),
      expect: () => [
        ListCrewsLoading(),
        ListCrewsLoaded([bobCrew], currentUserId: 'alice'),
      ],
    );

    blocTest<ListCrewsBloc, ListCrewsState>(
      'emits an error when the repository throws',
      setUp: () =>
          when(() => repository.getAllCrews()).thenThrow(Exception('boom')),
      build: build,
      act: (bloc) => bloc.add(LoadCrews()),
      expect: () => [
        ListCrewsLoading(),
        const ListCrewsError(CrewsFailure.loadFailed),
      ],
    );

    blocTest<ListCrewsBloc, ListCrewsState>(
      'emits deleteFailed when deleting a crew throws',
      setUp: () =>
          when(() => repository.deleteCrew('c1')).thenThrow(Exception('boom')),
      build: build,
      act: (bloc) => bloc.add(const DeleteCrew('c1')),
      expect: () => [const ListCrewsError(CrewsFailure.deleteFailed)],
    );
  });

  group('ListCrewsLoaded ownership', () {
    test('lets the user edit only the crews they created', () {
      final state = ListCrewsLoaded([
        aliceCrew,
        bobCrew,
      ], currentUserId: 'alice');

      expect(state.canEdit(aliceCrew), isTrue);
      expect(state.canEdit(bobCrew), isFalse);
    });

    test('lets a signed-out user edit nothing', () {
      final state = ListCrewsLoaded([aliceCrew]);

      expect(state.canEdit(aliceCrew), isFalse);
    });
  });
}
