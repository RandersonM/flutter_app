import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:opfan/features/crews/bloc/index.dart';
import 'package:opfan/features/crews/data/models/crew_model.dart';
import 'package:opfan/features/crews/data/repository/crew_repository_interface.dart';

class _MockCrewRepository extends Mock implements ICrewRepository {}

void main() {
  late _MockCrewRepository repository;

  final existing = CrewModel(
    id: 'c1',
    name: 'Straw Hats',
    userId: 'alice',
    captain: 'Luffy',
    rolesFilled: const ['captain'],
  );

  setUpAll(() => registerFallbackValue(CrewModel(name: 'x', userId: 'x')));

  setUp(() => repository = _MockCrewRepository());

  EditCrewBloc build() => EditCrewBloc(crewRepository: repository);

  const submitted = EditCrewSubmitted(
    crewId: 'c1',
    name: ' Mugiwara ',
    tags: ['pirates'],
  );

  group('EditCrewBloc', () {
    blocTest<EditCrewBloc, EditCrewState>(
      'updates the edited fields and keeps the rest of the crew',
      setUp: () {
        when(() => repository.getCrew('c1')).thenAnswer((_) async => existing);
        when(() => repository.updateCrew('c1', any())).thenAnswer((_) async {});
      },
      build: build,
      act: (bloc) => bloc.add(submitted),
      expect: () => [EditCrewLoading(), const EditCrewSuccess('c1')],
      verify: (_) {
        final crew =
            verify(
                  () => repository.updateCrew('c1', captureAny()),
                ).captured.single
                as CrewModel;
        expect(crew.name, 'Mugiwara');
        expect(crew.tags, ['pirates']);
        expect(crew.captain, 'Luffy');
        expect(crew.rolesFilled, ['captain']);
      },
    );

    blocTest<EditCrewBloc, EditCrewState>(
      'emits notFound when the crew no longer exists',
      setUp: () =>
          when(() => repository.getCrew('c1')).thenAnswer((_) async => null),
      build: build,
      act: (bloc) => bloc.add(submitted),
      expect: () => [
        EditCrewLoading(),
        const EditCrewFailure(CrewsFailure.notFound),
      ],
      verify: (_) => verifyNever(() => repository.updateCrew(any(), any())),
    );

    blocTest<EditCrewBloc, EditCrewState>(
      'emits saveFailed when the update throws',
      setUp: () {
        when(() => repository.getCrew('c1')).thenAnswer((_) async => existing);
        when(
          () => repository.updateCrew('c1', any()),
        ).thenThrow(Exception('offline'));
      },
      build: build,
      act: (bloc) => bloc.add(submitted),
      expect: () => [
        EditCrewLoading(),
        const EditCrewFailure(CrewsFailure.saveFailed),
      ],
    );
  });
}
