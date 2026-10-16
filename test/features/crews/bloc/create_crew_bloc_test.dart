import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:opfan/features/crews/bloc/index.dart';
import 'package:opfan/features/crews/data/models/crew_model.dart';
import 'package:opfan/features/crews/data/repository/i_crew_repository.dart';

class _MockCrewRepository extends Mock implements ICrewRepository {}

void main() {
  late _MockCrewRepository repository;

  setUpAll(() => registerFallbackValue(CrewModel(name: 'x', userId: 'x')));

  setUp(() => repository = _MockCrewRepository());

  CreateCrewBloc build({String? userId = 'alice'}) =>
      CreateCrewBloc(crewRepository: repository, userId: userId);

  const submitted = CreateCrewSubmitted(
    name: '  Straw Hats  ',
    tags: ['pirates'],
  );

  group('CreateCrewBloc', () {
    blocTest<CreateCrewBloc, CreateCrewState>(
      'creates an empty crew owned by the user with a trimmed name',
      setUp: () => when(
        () => repository.createCrew(any()),
      ).thenAnswer((_) async => 'c1'),
      build: build,
      act: (bloc) => bloc.add(submitted),
      expect: () => [CreateCrewLoading(), const CreateCrewSuccess('c1')],
      verify: (_) {
        final crew =
            verify(() => repository.createCrew(captureAny())).captured.single
                as CrewModel;
        expect(crew.name, 'Straw Hats');
        expect(crew.userId, 'alice');
        expect(crew.tags, ['pirates']);
        expect(crew.members, isEmpty);
      },
    );

    blocTest<CreateCrewBloc, CreateCrewState>(
      'emits notSignedIn without saving when there is no user',
      build: () => build(userId: null),
      act: (bloc) => bloc.add(submitted),
      expect: () => [
        CreateCrewLoading(),
        const CreateCrewFailure(CrewsFailure.notSignedIn),
      ],
      verify: (_) => verifyNever(() => repository.createCrew(any())),
    );

    blocTest<CreateCrewBloc, CreateCrewState>(
      'emits saveFailed when the repository throws',
      setUp: () => when(
        () => repository.createCrew(any()),
      ).thenThrow(Exception('offline')),
      build: build,
      act: (bloc) => bloc.add(submitted),
      expect: () => [
        CreateCrewLoading(),
        const CreateCrewFailure(CrewsFailure.saveFailed),
      ],
    );
  });
}
