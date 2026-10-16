import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:opfan/features/custom_character/data/models/custom_character_model.dart';
import 'package:opfan/features/home/data/repository/i_featured_character_repository.dart';
import 'package:opfan/features/one_piece/bloc/search_cubit.dart';

class _MockFeaturedCharacterRepository extends Mock
    implements IFeaturedCharacterRepository {}

CustomCharacterModel _character(
  String name, {
  String? nickname,
  List<String> affiliations = const [],
  String? crew,
}) => CustomCharacterModel(
  id: name,
  name: name,
  nickname: nickname,
  affiliations: affiliations,
  crew: crew,
  image: '',
  occupation: const [],
  bounty: '0',
);

void main() {
  late _MockFeaturedCharacterRepository repository;

  final luffy = _character(
    'Monkey D. Luffy',
    nickname: 'Straw Hat',
    affiliations: ['Straw Hat Pirates'],
  );
  final zoro = _character(
    'Roronoa Zoro',
    nickname: 'Pirate Hunter',
    crew: 'Straw Hat Pirates',
  );
  final garp = _character('Monkey D. Garp', affiliations: ['Marines']);
  final sabo = _character('Sabo', affiliations: ['Revolutionary Army']);
  final ace = _character('Portgas D. Ace', crew: 'Whitebeard Pirates');
  final all = [luffy, zoro, garp, sabo, ace];

  setUp(() {
    repository = _MockFeaturedCharacterRepository();
    when(
      () => repository.getAllOnePieceCharacters(),
    ).thenAnswer((_) async => all);
  });

  Future<List<CustomCharacterModel>> resultsAfter(
    Future<void> Function(SearchCubit cubit) act,
  ) async {
    final cubit = SearchCubit(repository);
    await act(cubit);
    final results = cubit.queryResults;
    await cubit.close();
    return results;
  }

  group('SearchCubit query behaviour', () {
    blocTest<SearchCubit, SearchState>(
      'emits loading then the matching characters',
      build: () => SearchCubit(repository),
      act: (cubit) => cubit.setQuery('garp'),
      expect: () => [
        const SearchLoading(query: 'garp', statusFilters: []),
        SearchLoaded(query: 'garp', queryResults: [garp], statusFilters: []),
      ],
    );

    test('matches the name case-insensitively', () async {
      expect(await resultsAfter((c) => c.setQuery('MONKEY')), [luffy, garp]);
    });

    test('matches the nickname', () async {
      expect(await resultsAfter((c) => c.setQuery('pirate hunter')), [zoro]);
    });

    test('matches an affiliation', () async {
      expect(await resultsAfter((c) => c.setQuery('revolutionary')), [sabo]);
    });

    test('matches the crew', () async {
      expect(await resultsAfter((c) => c.setQuery('whitebeard')), [ace]);
    });

    test('returns every character for an empty query', () async {
      expect(await resultsAfter((c) => c.setQuery('')), all);
    });

    test('returns nothing when no field matches', () async {
      expect(await resultsAfter((c) => c.setQuery('buggy')), isEmpty);
    });

    test('runs the search right away for an initial query', () async {
      final cubit = SearchCubit(repository, 'sabo');
      await cubit.stream.firstWhere((s) => s is SearchLoaded);

      expect(cubit.queryResults, [sabo]);
      await cubit.close();
    });

    blocTest<SearchCubit, SearchState>(
      'emits an error state when the catalog fails to load',
      setUp: () => when(
        () => repository.getAllOnePieceCharacters(),
      ).thenThrow(Exception('offline')),
      build: () => SearchCubit(repository),
      act: (cubit) => cubit.setQuery('luffy'),
      expect: () => [isA<SearchLoading>(), isA<SearchError>()],
    );
  });

  group('SearchCubit filter behaviour', () {
    test('keeps only characters with the filtered affiliation', () async {
      expect(await resultsAfter((c) => c.addStatusFilter('Marines')), [garp]);
    });

    test('keeps characters whose crew equals the filter', () async {
      expect(
        await resultsAfter((c) => c.addStatusFilter('Whitebeard Pirates')),
        [ace],
      );
    });

    test('applies one filter at a time', () async {
      final cubit = SearchCubit(repository);
      await cubit.addStatusFilter('Marines');
      await cubit.addStatusFilter('Revolutionary Army');

      expect(cubit.statusFilters, ['Revolutionary Army']);
      expect(cubit.queryResults, [sabo]);
      await cubit.close();
    });

    test(
      'falls back to the full list when the filter matches nobody',
      () async {
        expect(
          await resultsAfter((c) => c.addStatusFilter('Cross Guild')),
          all,
        );
      },
    );

    test('restores the full list when the filter is removed', () async {
      final cubit = SearchCubit(repository);
      await cubit.addStatusFilter('Marines');
      await cubit.removeStatusFilter('Marines');

      expect(cubit.statusFilters, isEmpty);
      expect(cubit.queryResults, all);
      await cubit.close();
    });

    test('combines the query with the filter', () async {
      final results = await resultsAfter((c) async {
        await c.addStatusFilter('Straw Hat Pirates');
        await c.setQuery('zoro');
      });

      expect(results, [zoro]);
    });
  });

  group('SearchCubit straw hat behaviour', () {
    test(
      'matches straw hat crew members by affiliation or crew for the english label',
      () async {
        expect(await resultsAfter((c) => c.addStatusFilter('Straw Hat')), [
          luffy,
          zoro,
        ]);
      },
    );

    test('matches straw hat crew members for the portuguese label', () async {
      expect(await resultsAfter((c) => c.addStatusFilter('Chapéu de Palha')), [
        luffy,
        zoro,
      ]);
    });

    test('ignores case in the straw hat label', () async {
      expect(await resultsAfter((c) => c.addStatusFilter('CHAPÉU DE PALHA')), [
        luffy,
        zoro,
      ]);
    });
  });

  group('SearchCubit reset behaviour', () {
    test('clears the query, filters and results', () async {
      final cubit = SearchCubit(repository);
      await cubit.addStatusFilter('Marines');
      await cubit.setQuery('garp');

      cubit.reset();

      expect(cubit.state, const SearchInitial());
      expect(cubit.query, isEmpty);
      expect(cubit.statusFilters, isEmpty);
      expect(cubit.queryResults, isEmpty);
      await cubit.close();
    });
  });
}
