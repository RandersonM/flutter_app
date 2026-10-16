import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:opfan/core/services/connectivity/i_connectivity_service.dart';
import 'package:opfan/core/services/youtube/i_youtube_service.dart';
import 'package:opfan/features/custom_character/data/models/custom_character_model.dart';
import 'package:opfan/features/home/bloc/home_bloc.dart';
import 'package:opfan/features/home/bloc/home_event.dart';
import 'package:opfan/features/home/bloc/home_state.dart';
import 'package:opfan/features/home/data/repository/featured_character_repository_interface.dart';

class _MockYouTubeService extends Mock implements IYouTubeService {}

class _MockFeaturedCharacterRepository extends Mock
    implements IFeaturedCharacterRepository {}

class _MockConnectivityService extends Mock implements IConnectivityService {}

void main() {
  late _MockYouTubeService youTube;
  late _MockFeaturedCharacterRepository characters;
  late _MockConnectivityService connectivity;

  final luffy = CustomCharacterModel(
    id: 'luffy',
    name: 'Monkey D. Luffy',
    affiliations: const [],
    image: '',
    occupation: const [],
    bounty: '3,000,000,000',
  );

  setUp(() {
    youTube = _MockYouTubeService();
    characters = _MockFeaturedCharacterRepository();
    connectivity = _MockConnectivityService();
    when(
      () => characters.getTodaysFeaturedCharacter(),
    ).thenAnswer((_) async => luffy);
    when(
      () => youTube.searchCharacterAMVWithFallback(any()),
    ).thenAnswer((_) async => null);
  });

  HomeBloc build() => HomeBloc(
    youTubeService: youTube,
    featuredCharacterRepository: characters,
    connectivityService: connectivity,
  );

  group('HomeBloc connectivity', () {
    blocTest<HomeBloc, HomeState>(
      'shows the offline placeholder without hitting the network',
      setUp: () =>
          when(() => connectivity.isOnline()).thenAnswer((_) async => false),
      build: build,
      act: (bloc) => bloc.add(const LoadFeaturedCharacter()),
      expect: () => [const HomeOffline()],
      verify: (_) => verifyNever(() => characters.getTodaysFeaturedCharacter()),
    );

    blocTest<HomeBloc, HomeState>(
      'loads the featured character when online',
      setUp: () =>
          when(() => connectivity.isOnline()).thenAnswer((_) async => true),
      build: build,
      act: (bloc) => bloc.add(const LoadFeaturedCharacter()),
      expect: () => containsAllInOrder([
        const HomeLoading(),
        isA<HomeLoaded>().having((s) => s.featuredCharacter, 'featured', luffy),
      ]),
    );

    blocTest<HomeBloc, HomeState>(
      'reloads when connectivity comes back',
      setUp: () =>
          when(() => connectivity.isOnline()).thenAnswer((_) async => true),
      build: build,
      seed: () => const HomeOffline(),
      act: (bloc) => bloc.add(const ConnectivityRestored()),
      expect: () =>
          containsAllInOrder([const HomeLoading(), isA<HomeLoaded>()]),
    );

    blocTest<HomeBloc, HomeState>(
      'refuses a random character while offline',
      setUp: () =>
          when(() => connectivity.isOnline()).thenAnswer((_) async => false),
      build: build,
      act: (bloc) => bloc.add(const LoadRandomCharacter()),
      expect: () => [const HomeOffline()],
      verify: (_) => verifyNever(() => characters.getRandomCharacter()),
    );
  });

  group('HomeBloc failures', () {
    setUp(
      () => when(() => connectivity.isOnline()).thenAnswer((_) async => true),
    );

    blocTest<HomeBloc, HomeState>(
      'emits a featured-character failure, not a message, when loading throws',
      setUp: () => when(
        () => characters.getTodaysFeaturedCharacter(),
      ).thenThrow(Exception('firestore')),
      build: build,
      act: (bloc) => bloc.add(const LoadFeaturedCharacter()),
      expect: () => [
        const HomeLoading(),
        const HomeError(HomeFailure.loadFeaturedFailed),
      ],
    );

    blocTest<HomeBloc, HomeState>(
      'emits a random-character failure when the pick throws',
      setUp: () => when(
        () => characters.getRandomCharacter(),
      ).thenThrow(Exception('firestore')),
      build: build,
      act: (bloc) => bloc.add(const LoadRandomCharacter()),
      expect: () => [
        const HomeLoading(),
        const HomeError(HomeFailure.loadRandomFailed),
      ],
    );

    blocTest<HomeBloc, HomeState>(
      'emits a refresh failure when refreshing throws',
      setUp: () => when(
        () => characters.getTodaysFeaturedCharacter(),
      ).thenThrow(Exception('firestore')),
      build: build,
      act: (bloc) => bloc.add(const RefreshHome()),
      expect: () => [
        const HomeLoading(),
        const HomeError(HomeFailure.refreshFailed),
      ],
    );
  });
}
