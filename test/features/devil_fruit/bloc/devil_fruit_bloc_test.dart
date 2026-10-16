import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:opfan/core/services/one_piece/i_devil_fruit_service.dart';
import 'package:opfan/features/devil_fruit/bloc/index.dart';
import 'package:opfan/features/devil_fruit/data/models/devil_fruit.dart';

class _MockDevilFruitService extends Mock implements IDevilFruitService {}

DevilFruit _fruit(int id, String name, String type) => DevilFruit(
  id: id,
  name: name,
  description: '',
  romanName: name,
  type: type,
);

void main() {
  late _MockDevilFruitService service;

  final gomu = _fruit(1, 'Gomu Gomu no Mi', 'Paramecia');
  final mera = _fruit(2, 'Mera Mera no Mi', 'Logia');
  const types = ['Logia', 'Paramecia'];

  setUp(() {
    service = _MockDevilFruitService();
    when(() => service.availableTypes).thenReturn(types);
  });

  DevilFruitBloc build() => DevilFruitBloc(devilFruitService: service);

  final loaded = DevilFruitLoaded(
    fruits: [gomu, mera],
    filteredFruits: [gomu, mera],
    availableTypes: types,
  );

  group('DevilFruitBloc behaviour', () {
    blocTest<DevilFruitBloc, DevilFruitState>(
      'loads every fruit and the available types',
      setUp: () =>
          when(() => service.fetchAll()).thenAnswer((_) async => [gomu, mera]),
      build: build,
      act: (bloc) => bloc.add(const LoadDevilFruits()),
      expect: () => [const DevilFruitLoading(), loaded],
    );

    blocTest<DevilFruitBloc, DevilFruitState>(
      'clears the cache before refreshing',
      setUp: () =>
          when(() => service.fetchAll()).thenAnswer((_) async => [gomu, mera]),
      build: build,
      act: (bloc) => bloc.add(const RefreshDevilFruits()),
      expect: () => [const DevilFruitLoading(), loaded],
      verify: (_) =>
          verifyInOrder([() => service.clearCache(), () => service.fetchAll()]),
    );

    blocTest<DevilFruitBloc, DevilFruitState>(
      'emits an error when loading throws',
      setUp: () => when(() => service.fetchAll()).thenThrow(Exception('api')),
      build: build,
      act: (bloc) => bloc.add(const LoadDevilFruits()),
      expect: () => [const DevilFruitLoading(), isA<DevilFruitError>()],
    );

    blocTest<DevilFruitBloc, DevilFruitState>(
      'filters by type through the service',
      setUp: () => when(
        () => service.fetchByType('Logia'),
      ).thenAnswer((_) async => [mera]),
      build: build,
      seed: () => loaded,
      act: (bloc) => bloc.add(const FilterDevilFruitsByType('Logia')),
      expect: () => [
        loaded.copyWith(isSearching: true),
        loaded.copyWith(filteredFruits: [mera], selectedType: 'Logia'),
      ],
    );
  });
}
