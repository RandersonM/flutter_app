import 'package:opfan/shared/widgets/atoms/app_icon.dart';
import 'package:phosphoricons_flutter/phosphoricons_flutter.dart';
// Developed by Randerson Mayllon
// Copyright © 2022.

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:opfan/core/connectivity/connectivity_cubit.dart';
import 'package:opfan/core/connectivity/connectivity_state.dart';
import 'package:opfan/features/custom_character/data/models/custom_character_model.dart';
import 'package:opfan/app/di/injection.dart';
import 'package:opfan/l10n/app_localizations.dart';
import 'package:opfan/shared/widgets/molecules/statistics_grid.dart';
import 'package:opfan/shared/widgets/organisms/bottom_navigation.dart';
import 'package:opfan/shared/widgets/atoms/app_button.dart';
import 'package:opfan/features/home/presentation/widgets/dynamic_banner.dart';
import 'package:opfan/features/home/presentation/widgets/character_info_card.dart';
import 'package:opfan/features/home/presentation/widgets/home_app_bar.dart';
import 'package:opfan/features/home/bloc/index.dart';
import 'package:opfan/shared/utils/app_routes.dart';
import 'package:opfan/shared/utils/constants.dart';
import 'package:opfan/shared/utils/zodiac_icons.dart';
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
        BlocProvider.value(
          value: getIt<ConnectivityCubit>(),
        ),
      ],
      child: BlocListener<ConnectivityCubit, ConnectivityState>(
        listener: (context, state) {
          if (state is ConnectivityOnline) {
            context.read<HomeBloc>().add(const ConnectivityRestored());
          }
        },
        child: BlocBuilder<AuthBloc, AuthState>(
        builder: (context, authState) {
          return Scaffold(
            appBar: const HomeAppBar(),
            body: Column(
              children: [
                if (authState is! AuthAuthenticated)
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(
                      horizontal: Constants.margin,
                      vertical: Constants.margin / 2,
                    ),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          Theme.of(context)
                              .colorScheme
                              .primary
                              .withValues(alpha: 0.1),
                          Theme.of(context)
                              .colorScheme
                              .primary
                              .withValues(alpha: 0.05),
                        ],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      border: Border(
                        bottom: BorderSide(
                          color: Theme.of(context)
                              .colorScheme
                              .primary
                              .withValues(alpha: 0.2),
                          width: 1,
                        ),
                      ),
                    ),
                    child: Material(
                      color: Colors.transparent,
                      child: InkWell(
                        onTap: () {
                          Navigator.pushNamedAndRemoveUntil(
                              context, AppRoutes.login, (route) => false);
                        },
                        borderRadius: BorderRadius.circular(8),
                        child: Padding(
                          padding: const EdgeInsets.all(Constants.margin),
                          child: Row(
                            children: [
                              AppIcon(
                                PhosphorIconsRegular.signIn,
                                color: Theme.of(context).colorScheme.primary,
                                size: 20,
                              ),
                              const SizedBox(width: Constants.margin),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      AppLocalizations.of(context)!
                                          .loginBannerTitle,
                                      style: Theme.of(context)
                                          .textTheme
                                          .bodyMedium
                                          ?.copyWith(
                                            fontWeight: FontWeight.w600,
                                            color: Theme.of(context)
                                                .colorScheme
                                                .primary,
                                          ),
                                    ),
                                    const SizedBox(height: 2),
                                    Text(
                                      AppLocalizations.of(context)!
                                          .loginBannerSubtitle,
                                      style: Theme.of(context)
                                          .textTheme
                                          .bodySmall
                                          ?.copyWith(
                                            color: Theme.of(context)
                                                .colorScheme
                                                .onSurface
                                                .withValues(alpha: 0.7),
                                          ),
                                    ),
                                  ],
                                ),
                              ),
                              AppIcon(
                                PhosphorIconsRegular.caretRight,
                                color: Theme.of(context).colorScheme.primary,
                                size: 16,
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                // Conteúdo principal da tela
                Expanded(
                  child: BlocBuilder<HomeBloc, HomeState>(
                    builder: (context, state) {
                      return SingleChildScrollView(
                        padding: const EdgeInsets.all(Constants.margin),
                        child: Column(
                          spacing: Constants.margin,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            DynamicBanner(
                              state: state,
                              height: videoBannerHeight,
                            ),
                            const SizedBox.shrink(),
                            Text(
                              AppLocalizations.of(context)!.featuredCharacter,
                              style: Theme.of(context)
                                  .textTheme
                                  .headlineSmall
                                  ?.copyWith(
                                    fontWeight: FontWeight.bold,
                                    color:
                                        Theme.of(context).colorScheme.primary,
                                  ),
                            ),
                            _buildCharacterCard(context, state),
                            Row(
                              spacing: Constants.margin,
                              children: [
                                Expanded(
                                  child: AppButton(
                                    label: AppLocalizations.of(context)!
                                        .selectCharacter,
                                    icon: const AppIcon(
                                        PhosphorIconsRegular.magnifyingGlass),
                                    variant: AppButtonVariant.tertiary,
                                    onPressed: state is HomeLoading
                                        ? null
                                        : () async {
                                            final selectedCharacter =
                                                await Navigator.pushNamed<
                                                    CustomCharacterModel>(
                                              context,
                                              AppRoutes.characterSelection,
                                            );
                                            if (selectedCharacter != null &&
                                                context.mounted) {
                                              context.read<HomeBloc>().add(
                                                  SelectCharacter(
                                                      selectedCharacter));
                                            }
                                          },
                                  ),
                                ),
                                Expanded(
                                  child: AppButton(
                                    label: AppLocalizations.of(context)!
                                        .randomCharacter,
                                    icon: const AppIcon(
                                        PhosphorIconsRegular.shuffle),
                                    variant: AppButtonVariant.primary,
                                    isLoading: state is HomeLoading,
                                    onPressed: state is HomeLoading
                                        ? null
                                        : () {
                                            context.read<HomeBloc>().add(
                                                const LoadRandomCharacter());
                                          },
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: Constants.margin),
                            _buildCharacterStatistics(context, state),
                          ],
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
            bottomNavigationBar:
                const BottomNavigation(BottomNavigationPages.home),
          );
        },
        ),
      ),
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

    // Offline: show static placeholder so the home doesn't get stuck loading.
    if (state is HomeOffline) {
      return CharacterInfoCard(
        characterName: 'Monkey D. Luffy',
        characterBounty: '฿1.500.000.000',
        characterImage: 'assets/logo/splash_logo.png',
        onTap: () {},
      );
    }

    if (state is HomeError) {
      return Card(
        child: Padding(
          padding: const EdgeInsets.all(Constants.margin),
          child: Column(
            children: [
              const AppIcon(
                PhosphorIconsRegular.warningCircle,
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
        characterBounty: '฿${Constants.formatBounty(character.bounty)}',
        characterImage: character.image,
        characterDescription: character.description,
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
    // Offline placeholder statistics
    if (state is HomeOffline) {
      return StatisticsGrid(
        title: AppLocalizations.of(context)!.statistics,
        statistics: [
          StatisticData(
            label: AppLocalizations.of(context)!.status,
            value: '—',
            icon: PhosphorIconsRegular.flag,
          ),
          StatisticData(
            label: AppLocalizations.of(context)!.crew(0),
            value: '—',
            svgPath: 'assets/logo/ship-crew.svg',
          ),
          StatisticData(
            label: AppLocalizations.of(context)!.signo,
            value: '—',
            icon: PhosphorIconsRegular.star,
          ),
        ],
      );
    }

    if (state is HomeLoaded) {
      final character = state.featuredCharacter;

      final zodiacIconPath = ZodiacIcons.getZodiacIconPath(character.signo);

      return StatisticsGrid(
        title: AppLocalizations.of(context)!.statistics,
        statistics: [
          StatisticData(
            label: AppLocalizations.of(context)!.crew(0),
            value: character.crew ?? 'N/A',
            icon: PhosphorIconsRegular.boat,
          ),
          StatisticData(
            label:
                character.devilFruit != null && character.devilFruit!.isNotEmpty
                    ? AppLocalizations.of(context)!.devilFruit
                    : AppLocalizations.of(context)!.noDevilFruit,
            value:
                character.devilFruit != null && character.devilFruit!.isNotEmpty
                    ? character.devilFruit!
                    : '',
            svgPath:
                character.devilFruit != null && character.devilFruit!.isNotEmpty
                    ? 'assets/svg/gomu-gomu.svg'
                    : null,
            icon:
                character.devilFruit != null && character.devilFruit!.isNotEmpty
                    ? null
                    : PhosphorIconsRegular.personSimpleSwim,
          ),
          StatisticData(
            label: AppLocalizations.of(context)!.signo,
            value: character.signo != null
                ? ZodiacIcons.getLocalizedZodiacSign(context, character.signo!)
                : 'N/A',
            svgPath: zodiacIconPath,
            icon: zodiacIconPath == null ? PhosphorIconsRegular.star : null,
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
          icon: PhosphorIconsRegular.flag,
        ),
        StatisticData(
          label: AppLocalizations.of(context)!.crew(0),
          value: '...',
          svgPath: 'assets/logo/ship-crew.svg',
        ),
        StatisticData(
          label: AppLocalizations.of(context)!.signo,
          value: '...',
          icon: PhosphorIconsRegular.star,
        ),
      ],
    );
  }
}
