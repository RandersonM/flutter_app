// Developed by Randerson Mayllon
// Copyright © 2022.

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:simple_app/core/one_piece/models/character.dart';
import 'package:simple_app/core/services/characters_backend_service.dart';
import 'package:simple_app/core/services/youtube_service.dart';
import 'package:simple_app/l10n/app_localizations.dart';
import 'package:simple_app/widgets/molecules/default_app_bar.dart';
import 'package:simple_app/widgets/molecules/statistics_grid.dart';
import 'package:simple_app/widgets/organisms/bottom_navigation.dart';
import 'package:simple_app/screens/home/widgets/simple_video_banner.dart';
import 'package:simple_app/screens/home/widgets/character_info_card.dart';
import 'package:simple_app/screens/home/blocs/index.dart';
import 'package:simple_app/utils/app_routes.dart';
import 'package:simple_app/utils/constants.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final double videoBannerHeight = 250;
  
  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => HomeBloc(
        charactersService: CharactersBackendService(),
        youTubeService: YouTubeService(),
      )..add(const LoadFeaturedCharacter()),
      child: Scaffold(
        appBar: DefaultAppBar(
          title: Text(AppLocalizations.of(context)!.home),
        ),
        body: BlocBuilder<HomeBloc, HomeState>(
          builder: (context, state) {
            return SingleChildScrollView(
              padding: const EdgeInsets.all(Constants.margin),
              child: Column(
                spacing: Constants.margin,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildDynamicBanner(state),
                  const SizedBox.shrink(),
                  Text(
                    AppLocalizations.of(context)!.featuredCharacter,
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                  _buildCharacterCard(context, state),
                  Row(
                    spacing: Constants.margin,
                    children: [
                      Expanded(
                        child: OutlinedButton.icon(
                          // child: ElevatedButton.icon(
                          onPressed: state is HomeLoading
                              ? null
                              : () async {
                                  final selectedCharacter =
                                      await Navigator.pushNamed<Character>(
                                    context,
                                    AppRoutes.characterSelection,
                                  );

                                  if (selectedCharacter != null &&
                                      context.mounted) {
                                    context.read<HomeBloc>().add(
                                        SelectCharacter(selectedCharacter));
                                  }
                                },
                          icon: const Icon(Icons.person_search),
                          label: Text(
                              AppLocalizations.of(context)!.selectCharacter),
                        ),
                      ),
                      Expanded(
                        // child: OutlinedButton.icon(
                        child: ElevatedButton.icon(
                          onPressed: state is HomeLoading
                              ? null
                              : () {
                                  context
                                      .read<HomeBloc>()
                                      .add(const LoadRandomCharacter());
                                },
                          icon: state is HomeLoading
                              ? const SizedBox(
                                  width: 16,
                                  height: 16,
                                  child:
                                      CircularProgressIndicator(strokeWidth: 2),
                                )
                              : const Icon(Icons.shuffle),
                          label: Text(
                              AppLocalizations.of(context)!.randomCharacter),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox.shrink(),
                  StatisticsGrid(
                    title: AppLocalizations.of(context)!.statistics,
                    statistics: [
                      StatisticData(
                        label: AppLocalizations.of(context)!.totalCharacters,
                        value: '51',
                        icon: Icons.people,
                      ),
                      StatisticData(
                        label: AppLocalizations.of(context)!.highestBounty,
                        value: '฿5.5B',
                        icon: Icons.monetization_on,
                      ),
                      StatisticData(
                        label: AppLocalizations.of(context)!.crews,
                        value: '15+',
                        icon: Icons.sailing,
                      ),
                    ],
                  ),
                ],
              ),
            );
          },
        ),
        bottomNavigationBar: const BottomNavigation(BottomNavigationPages.home),
      ),
    );
  }

  Widget _buildDynamicBanner(HomeState state) {
    if (state is HomeLoaded) {
      final character = state.featuredCharacter;
      if (state.currentVideo != null) {
        return SimpleVideoBanner(
          bannerType: SimpleBannerType.youtube,
          youTubeVideo: state.currentVideo,
          height: videoBannerHeight,
          title: character.name,
          subtitle: state.currentVideo!.title,
          onTap: () => _playVideo(state.currentVideo!),
        );
      }

      if (state.isLoadingVideo) {
        return Container(
          height: videoBannerHeight,
          decoration: BoxDecoration(
            color: Colors.grey[900],
            borderRadius: BorderRadius.circular(12),
          ),
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const CircularProgressIndicator(color: Colors.white),
                const SizedBox(height: 16),
                Text(
                  AppLocalizations.of(context)!.searchingVideo,
                  style: const TextStyle(color: Colors.white),
                ),
              ],
            ),
          ),
        );
      }

      return SimpleVideoBanner(
        url: character.image,
        fallbackUrl: 'assets/logo/splash_logo.png',
        bannerType: SimpleBannerType.image,
        height: 200,
        title: character.name,
        subtitle: AppLocalizations.of(context)!.featuredCharacter,
      );
    }

    return Container(
      height: 200,
      decoration: BoxDecoration(
        color: Colors.grey[300],
        borderRadius: BorderRadius.circular(12),
      ),
      child: const Center(
        child: CircularProgressIndicator(),
      ),
    );
  }

  void _playVideo(video) {
    Navigator.pushNamed(
      context,
      AppRoutes.youtubePlayer,
      arguments: video,
    );
  }

  Widget _buildCharacterCard(BuildContext context, HomeState state) {
    if (state is HomeLoading) {
      return const Card(
        child: Padding(
          padding: EdgeInsets.all(Constants.margin * 2),
          child: Center(
            child: CircularProgressIndicator(),
          ),
        ),
      );
    }

    if (state is HomeError) {
      return Card(
        child: Padding(
          padding: const EdgeInsets.all(Constants.margin),
          child: Column(
            children: [
              const Icon(
                Icons.error_outline,
                size: 48,
                color: Colors.red,
              ),
              const SizedBox(height: Constants.margin),
              Text(
                AppLocalizations.of(context)!.loadingError,
                style: Theme.of(context).textTheme.titleMedium,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: Constants.margin / 2),
              Text(
                state.message,
                style: Theme.of(context).textTheme.bodySmall,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: Constants.margin),
              ElevatedButton(
                onPressed: () {
                  context.read<HomeBloc>().add(const LoadFeaturedCharacter());
                },
                child: Text(AppLocalizations.of(context)!.tryAgain),
              ),
            ],
          ),
        ),
      );
    }
    
    if (state is HomeLoaded) {
      final character = state.featuredCharacter;
      return CharacterInfoCard(
        characterName: character.name,
        characterBounty: character.bounty,
        characterImage: character.image,
        onTap: () => Navigator.pushNamed(
          context,
          AppRoutes.characterDetails,
          arguments: character,
        ),
      );
    }

    return CharacterInfoCard(
      characterName: AppLocalizations.of(context)!.loading,
      characterBounty: "...",
      characterImage: 'assets/logo/splash_logo.png',
      onTap: () {},
    );
  }
}
