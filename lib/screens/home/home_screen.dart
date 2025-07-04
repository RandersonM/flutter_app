// Developed by Randerson Mayllon
// Copyright © 2022.

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:opfan/core/one_piece/models/character.dart';
import 'package:opfan/core/services/service_locator.dart';
import 'package:opfan/l10n/app_localizations.dart';
import 'package:opfan/widgets/molecules/statistics_grid.dart';
import 'package:opfan/widgets/organisms/bottom_navigation.dart';
import 'package:opfan/screens/home/widgets/simple_video_banner.dart';
import 'package:opfan/screens/home/widgets/character_info_card.dart';
import 'package:opfan/screens/home/blocs/index.dart';
import 'package:opfan/utils/app_routes.dart';
import 'package:opfan/utils/constants.dart';
import 'package:opfan/utils/zodiac_icons.dart';
import 'package:opfan/core/auth/blocs/index.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final double videoBannerHeight = 250;
  
  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(
          create: (context) =>
              getIt<HomeBloc>()..add(const LoadFeaturedCharacter()),
        ),
        BlocProvider.value(
          value: getIt<AuthBloc>(),
        ),
      ],
      child: Scaffold(
        appBar: _buildAppBar(context),
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
                  _buildCharacterStatistics(context, state),
                ],
              ),
            );
          },
        ),
        bottomNavigationBar: const BottomNavigation(BottomNavigationPages.home),
      ),
    );
  }

  PreferredSizeWidget _buildAppBar(BuildContext context) {
    return AppBar(
      title: BlocBuilder<AuthBloc, AuthState>(
        builder: (context, state) {
          if (state is AuthAuthenticated) {
            return Row(
              children: [
                CircleAvatar(
                  backgroundImage: state.user.photoUrl != null
                      ? NetworkImage(state.user.photoUrl!)
                      : null,
                  child: state.user.photoUrl == null
                      ? const Icon(Icons.person)
                      : null,
                ),
                const SizedBox(width: Constants.margin),
                Expanded(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        AppLocalizations.of(context)!.welcome,
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              color: Theme.of(context).colorScheme.onSurface,
                            ),
                      ),
                      Text(
                        state.user.displayName,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: Theme.of(context)
                            .textTheme
                            .titleMedium
                            ?.copyWith(
                              color: Theme.of(context).colorScheme.onSurface,
                              fontWeight: FontWeight.bold,
                            ),
                      ),
                    ],
                  ),
                ),
              ],
            );
          }
          return Text(AppLocalizations.of(context)!.home);
        },
      ),
      actions: [
        BlocBuilder<AuthBloc, AuthState>(
          builder: (context, state) {
            if (state is AuthAuthenticated) {
              return IconButton(
                icon: const Icon(Icons.logout),
                onPressed: () {
                  context.read<AuthBloc>().add(const AuthSignOutRequested());
                },
              );
            }
            return const SizedBox.shrink();
          },
        ),
      ],
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

  String _getLocalizedZodiacSign(BuildContext context, String zodiacSign) {
    final translationKey = ZodiacIcons.getZodiacTranslationKey(zodiacSign);

    switch (translationKey) {
      case 'ariesSign':
        return AppLocalizations.of(context)!.ariesSign;
      case 'taurusSign':
        return AppLocalizations.of(context)!.taurusSign;
      case 'geminiSign':
        return AppLocalizations.of(context)!.geminiSign;
      case 'cancerSign':
        return AppLocalizations.of(context)!.cancerSign;
      case 'leoSign':
        return AppLocalizations.of(context)!.leoSign;
      case 'virgoSign':
        return AppLocalizations.of(context)!.virgoSign;
      case 'libraSign':
        return AppLocalizations.of(context)!.libraSign;
      case 'scorpioSign':
        return AppLocalizations.of(context)!.scorpioSign;
      case 'sagittariusSign':
        return AppLocalizations.of(context)!.sagittariusSign;
      case 'capricornSign':
        return AppLocalizations.of(context)!.capricornSign;
      case 'aquariusSign':
        return AppLocalizations.of(context)!.aquariusSign;
      case 'piscesSign':
        return AppLocalizations.of(context)!.piscesSign;
      default:
        return AppLocalizations.of(context)!.unknown;
    }
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

  Widget _buildCharacterStatistics(BuildContext context, HomeState state) {
    if (state is HomeLoaded) {
      final character = state.featuredCharacter;

      final zodiacIconPath = ZodiacIcons.getZodiacIconPath(character.signo);

      return StatisticsGrid(
        title: AppLocalizations.of(context)!.statistics,
        statistics: [
          StatisticData(
            label: AppLocalizations.of(context)!.crew,
            value: character.crew ?? 'N/A',
            svgPath: 'assets/logo/ship-crew.svg',
          ),
          StatisticData(
            label:
                character.devilFruit != null && character.devilFruit!.isNotEmpty
                    ? AppLocalizations.of(context)!.devilFruit
                    : AppLocalizations.of(context)!.status,
            value:
                character.devilFruit != null && character.devilFruit!.isNotEmpty
                    ? character.devilFruit!
                    : character.status ?? 'Unknown',
            icon:
                character.devilFruit != null && character.devilFruit!.isNotEmpty
                    ? Icons.apple_outlined
                    : Icons.flag,
          ),
          StatisticData(
            label: AppLocalizations.of(context)!.signo,
            value: character.signo != null
                ? _getLocalizedZodiacSign(context, character.signo!)
                : 'N/A',
            svgPath: zodiacIconPath,
            icon: zodiacIconPath == null ? Icons.star : null,
          ),
        ],
      );
    }

    return StatisticsGrid(
      title: AppLocalizations.of(context)!.statistics,
      statistics: [
        StatisticData(
          label: AppLocalizations.of(context)!.status,
          value: '...',
          icon: Icons.flag,
        ),
        StatisticData(
          label: AppLocalizations.of(context)!.crew,
          value: '...',
          svgPath: 'assets/logo/ship-crew.svg',
        ),
        StatisticData(
          label: AppLocalizations.of(context)!.signo,
          value: '...',
          icon: Icons.star,
        ),
      ],
    );
  }
}
