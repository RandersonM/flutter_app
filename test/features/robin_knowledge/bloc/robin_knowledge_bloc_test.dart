import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:opfan/core/errors/app_exceptions.dart';
import 'package:opfan/features/robin_knowledge/bloc/index.dart';
import 'package:opfan/features/robin_knowledge/data/models/goal_model.dart';
import 'package:opfan/features/robin_knowledge/data/repository/i_planner_repository.dart';

class _MockPlannerRepository extends Mock implements IPlannerRepository {}

void main() {
  late _MockPlannerRepository repository;

  final goal = GoalModel(
    id: 'g1',
    title: 'Read Ohara archives',
    description: '',
    deadline: DateTime(2030),
    createdAt: DateTime(2026),
    category: GoalCategory.study,
  );

  setUpAll(() => registerFallbackValue(goal));
  setUp(() => repository = _MockPlannerRepository());

  RobinKnowledgeBloc build() =>
      RobinKnowledgeBloc(plannerRepository: repository);

  group('RobinKnowledgeBloc behaviour', () {
    blocTest<RobinKnowledgeBloc, RobinKnowledgeState>(
      'loads the goals',
      setUp: () =>
          when(() => repository.getGoals()).thenAnswer((_) async => [goal]),
      build: build,
      act: (bloc) => bloc.add(const LoadGoals()),
      expect: () => [
        RobinKnowledgeLoading(),
        RobinKnowledgeLoaded(goals: [goal]),
      ],
    );

    blocTest<RobinKnowledgeBloc, RobinKnowledgeState>(
      'emits a load failure, not a message, when loading throws',
      setUp: () => when(
        () => repository.getGoals(),
      ).thenThrow(const NotSignedInException()),
      build: build,
      act: (bloc) => bloc.add(const LoadGoals()),
      expect: () => [
        RobinKnowledgeLoading(),
        const RobinKnowledgeError(failure: RobinKnowledgeFailure.loadFailed),
      ],
    );

    blocTest<RobinKnowledgeBloc, RobinKnowledgeState>(
      'emits a create failure when creating a goal throws',
      setUp: () => when(
        () => repository.createGoal(any()),
      ).thenThrow(Exception('firestore')),
      build: build,
      act: (bloc) => bloc.add(AddGoal(goal)),
      expect: () => [
        const RobinKnowledgeError(failure: RobinKnowledgeFailure.createFailed),
      ],
    );

    blocTest<RobinKnowledgeBloc, RobinKnowledgeState>(
      'emits a progress failure when the goal no longer exists',
      setUp: () => when(
        () => repository.updateGoalProgress(
          any(),
          any(),
          notes: any(named: 'notes'),
        ),
      ).thenThrow(const NotFoundException('goal g1')),
      build: build,
      act: (bloc) => bloc.add(const UpdateGoalProgress('g1', 50)),
      expect: () => [
        const RobinKnowledgeError(
          failure: RobinKnowledgeFailure.progressUpdateFailed,
        ),
      ],
    );

    blocTest<RobinKnowledgeBloc, RobinKnowledgeState>(
      'emits a delete failure when deleting a goal throws',
      setUp: () => when(
        () => repository.deleteGoal(any()),
      ).thenThrow(Exception('firestore')),
      build: build,
      act: (bloc) => bloc.add(const DeleteGoal('g1')),
      expect: () => [
        const RobinKnowledgeError(failure: RobinKnowledgeFailure.deleteFailed),
      ],
    );
  });
}
