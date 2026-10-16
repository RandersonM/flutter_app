import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:opfan/core/services/one_piece/i_crew_image_service.dart';
import 'package:opfan/features/crews/bloc/index.dart';

class _MockCrewImageService extends Mock implements ICrewImageService {}

void main() {
  late _MockCrewImageService service;

  setUp(() => service = _MockCrewImageService());

  void stubJollyRoger(Future<String?> Function() answer) => when(
    () => service.generateJollyRogerImage(
      crewName: any(named: 'crewName'),
      prompt: any(named: 'prompt'),
      tags: any(named: 'tags'),
      description: any(named: 'description'),
    ),
  ).thenAnswer((_) => answer());

  Future<void> generateJollyRoger(CrewImageCubit cubit) => cubit.generate(
    CrewImageKind.jollyRoger,
    crewName: 'Straw Hats',
    prompt: 'skull with a straw hat',
  );

  group('CrewImageCubit behaviour', () {
    test('starts from the images of the crew being edited', () {
      final cubit = CrewImageCubit(
        crewImageService: service,
        jollyRogerUrl: 'flag.png',
        boatUrl: 'boat.png',
      );

      expect(cubit.state.jollyRogerUrl, 'flag.png');
      expect(cubit.state.boatUrl, 'boat.png');
      cubit.close();
    });

    blocTest<CrewImageCubit, CrewImageState>(
      'stores the generated jolly roger and reports success',
      setUp: () => stubJollyRoger(() async => 'new-flag.png'),
      build: () => CrewImageCubit(crewImageService: service),
      act: generateJollyRoger,
      expect: () => [
        const CrewImageState(generating: {CrewImageKind.jollyRoger}),
        const CrewImageState(
          jollyRogerUrl: 'new-flag.png',
          outcome: CrewImageGenerated(CrewImageKind.jollyRoger),
        ),
      ],
    );

    blocTest<CrewImageCubit, CrewImageState>(
      'generates the boat through the boat endpoint',
      setUp: () => when(
        () => service.generateBoatImage(
          crewName: 'Straw Hats',
          prompt: 'lion figurehead',
          tags: const ['pirates'],
          description: 'Going Merry',
        ),
      ).thenAnswer((_) async => 'sunny.png'),
      build: () => CrewImageCubit(crewImageService: service),
      act: (cubit) => cubit.generate(
        CrewImageKind.boat,
        crewName: 'Straw Hats',
        prompt: 'lion figurehead',
        tags: const ['pirates'],
        description: 'Going Merry',
      ),
      expect: () => [
        const CrewImageState(generating: {CrewImageKind.boat}),
        const CrewImageState(
          boatUrl: 'sunny.png',
          outcome: CrewImageGenerated(CrewImageKind.boat),
        ),
      ],
    );

    blocTest<CrewImageCubit, CrewImageState>(
      'keeps the previous image and reports a failure when generation throws',
      setUp: () => stubJollyRoger(() async => throw Exception('quota')),
      build: () =>
          CrewImageCubit(crewImageService: service, jollyRogerUrl: 'old.png'),
      act: generateJollyRoger,
      expect: () => [
        const CrewImageState(
          jollyRogerUrl: 'old.png',
          generating: {CrewImageKind.jollyRoger},
        ),
        const CrewImageState(
          jollyRogerUrl: 'old.png',
          outcome: CrewImageGenerationFailed(CrewImageKind.jollyRoger),
        ),
      ],
    );

    blocTest<CrewImageCubit, CrewImageState>(
      'keeps the previous image silently when the service returns nothing',
      setUp: () => stubJollyRoger(() async => null),
      build: () =>
          CrewImageCubit(crewImageService: service, jollyRogerUrl: 'old.png'),
      act: generateJollyRoger,
      expect: () => [
        const CrewImageState(
          jollyRogerUrl: 'old.png',
          generating: {CrewImageKind.jollyRoger},
        ),
        const CrewImageState(jollyRogerUrl: 'old.png'),
      ],
    );
  });
}
