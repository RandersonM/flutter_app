import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:opfan/core/services/one_piece/i_character_image_service.dart';
import 'package:opfan/features/custom_character/bloc/index.dart';

class _MockCharacterImageService extends Mock
    implements ICharacterImageService {}

void main() {
  late _MockCharacterImageService service;

  setUp(() => service = _MockCharacterImageService());

  void stub(Future<String?> Function(Invocation) answer) => when(
    () => service.generateCharacterImage(
      characterName: any(named: 'characterName'),
      prompt: any(named: 'prompt'),
      race: any(named: 'race'),
      haki: any(named: 'haki'),
      status: any(named: 'status'),
      occupations: any(named: 'occupations'),
    ),
  ).thenAnswer(answer);

  Future<void> generate(CharacterImageCubit cubit, {bool force = false}) =>
      cubit.generate(
        characterName: 'Luffy',
        prompt: 'straw hat pirate',
        race: 'human',
        forceRegeneration: force,
      );

  group('CharacterImageCubit behaviour', () {
    blocTest<CharacterImageCubit, CharacterImageState>(
      'stores the generated image',
      setUp: () => stub((_) async => 'luffy.png'),
      build: () => CharacterImageCubit(characterImageService: service),
      act: generate,
      expect: () => [
        const CharacterImageState(isGenerating: true),
        const CharacterImageState(imageUrl: 'luffy.png'),
      ],
    );

    blocTest<CharacterImageCubit, CharacterImageState>(
      'keeps the previous image and flags a failure when generation throws',
      setUp: () => stub((_) async => throw Exception('quota')),
      build: () => CharacterImageCubit(characterImageService: service),
      seed: () => const CharacterImageState(imageUrl: 'old.png'),
      act: generate,
      expect: () => [
        const CharacterImageState(imageUrl: 'old.png', isGenerating: true),
        const CharacterImageState(imageUrl: 'old.png', failed: true),
      ],
    );

    blocTest<CharacterImageCubit, CharacterImageState>(
      'flags a failure when the service returns no image',
      setUp: () => stub((_) async => null),
      build: () => CharacterImageCubit(characterImageService: service),
      act: generate,
      expect: () => [
        const CharacterImageState(isGenerating: true),
        const CharacterImageState(failed: true),
      ],
    );

    blocTest<CharacterImageCubit, CharacterImageState>(
      'sends a never-seen prompt when regenerating, so the cache is bypassed',
      setUp: () => stub((_) async => 'new.png'),
      build: () => CharacterImageCubit(characterImageService: service),
      act: (cubit) async {
        await generate(cubit, force: true);
        await generate(cubit, force: true);
      },
      verify: (_) {
        final prompts = verify(
          () => service.generateCharacterImage(
            characterName: any(named: 'characterName'),
            prompt: captureAny(named: 'prompt'),
            race: any(named: 'race'),
            haki: any(named: 'haki'),
            status: any(named: 'status'),
            occupations: any(named: 'occupations'),
          ),
        ).captured.cast<String>();
        expect(prompts, hasLength(2));
        expect(prompts.toSet(), hasLength(2));
        expect(
          prompts.every((p) => p.startsWith('straw hat pirate [')),
          isTrue,
        );
      },
    );
  });
}
