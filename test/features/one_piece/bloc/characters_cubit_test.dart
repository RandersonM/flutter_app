import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:opfan/features/home/data/repository/featured_character_repository_interface.dart';
import 'package:opfan/features/one_piece/bloc/characters_cubit.dart';

class _MockFeaturedCharacterRepository extends Mock
    implements IFeaturedCharacterRepository {}

void main() {
  late _MockFeaturedCharacterRepository repository;

  setUp(() => repository = _MockFeaturedCharacterRepository());

  group('CharactersCubit behaviour', () {
    blocTest<CharactersCubit, CharactersState>(
      'emits a load failure, not a message, when the catalog fails to load',
      setUp: () => when(
        () => repository.getAllOnePieceCharacters(),
      ).thenThrow(Exception('firestore')),
      build: () => CharactersCubit(repository),
      act: (cubit) => cubit.fetchData(),
      expect: () => [
        const CharactersLoading(characters: [], isLoadingMore: false),
        const CharactersError(
          failure: CharactersFailure.loadFailed,
          characters: [],
        ),
      ],
    );
  });
}
