import 'package:opfan/shared/widgets/atoms/app_icon.dart';
import 'package:phosphoricons_flutter/phosphoricons_flutter.dart';
// Developed by Randerson Mayllon
// Copyright © 2022.

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:opfan/app/di/injection.dart';
import 'package:opfan/l10n/app_localizations.dart';
import 'package:opfan/features/duels/bloc/index.dart';
import 'package:opfan/features/duels/presentation/widgets/character_selector.dart';
import 'package:opfan/features/duels/presentation/widgets/duel_arena.dart';
import 'package:opfan/features/duels/presentation/widgets/duel_result.dart';
import 'package:opfan/shared/utils/constants.dart';
import 'package:opfan/shared/widgets/atoms/futuristic_background.dart';
import 'package:opfan/shared/widgets/molecules/default_app_bar.dart';

class DuelsScreen extends StatelessWidget {
  const DuelsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => getIt<DuelsBloc>()..add(const LoadDuelsScreen()),
      child: const _DuelsView(),
    );
  }
}

class _DuelsView extends StatelessWidget {
  const _DuelsView();

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: DefaultAppBar(
        title: Text(
          l10n.duels,
          style: Theme.of(context).textTheme.headlineSmall?.copyWith(),
        ),
        actions: [
          BlocBuilder<DuelsBloc, DuelsState>(
            builder: (context, state) {
              if (state is DuelsReady) {
                return IconButton(
                  icon: const Icon(PhosphorIconsRegular.shuffle),
                  onPressed: () {
                    context.read<DuelsBloc>().add(const RandomizeCharacters());
                  },
                  tooltip: l10n.randomizeCharacters,
                );
              }
              return const SizedBox.shrink();
            },
          ),
          BlocBuilder<DuelsBloc, DuelsState>(
            builder: (context, state) {
              if (state is DuelsReady && state.hasCharactersSelected) {
                return IconButton(
                  icon: const AppIcon(PhosphorIconsRegular.arrowsClockwise),
                  onPressed: () {
                    context.read<DuelsBloc>().add(const ResetDuel());
                  },
                  tooltip: l10n.resetDuel,
                );
              }
              return const SizedBox.shrink();
            },
          ),
        ],
      ),
      body: AnimatedFuturisticBackground(
        opacity: 0.1,
        child: BlocBuilder<DuelsBloc, DuelsState>(
          builder: (context, state) {
            if (state is DuelsInitial || state is DuelsLoading) {
              return Center(
                child: CircularProgressIndicator(
                  color: Theme.of(context).colorScheme.primary,
                ),
              );
            }

            if (state is DuelsError) {
              return _buildErrorState(context, state.failure);
            }

            if (state is DuelsReady) {
              return _buildDuelsContent(context, state);
            }

            return const SizedBox.shrink();
          },
        ),
      ),
    );
  }

  Widget _buildErrorState(BuildContext context, DuelsFailure failure) {
    final l10n = AppLocalizations.of(context)!;

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(Constants.margin * 2),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            AppIcon(
              PhosphorIconsRegular.warningCircle,
              size: 64,
              color: Theme.of(context).colorScheme.error,
            ),
            const SizedBox(height: Constants.margin),
            Text(
              l10n.error,
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                color: Theme.of(context).colorScheme.onSurface,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: Constants.margin),
            Text(
              switch (failure) {
                DuelsFailure.loadFailed => l10n.duelsLoadError,
              },
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: Constants.margin * 2),
            ElevatedButton(
              onPressed: () {
                context.read<DuelsBloc>().add(const LoadDuelsScreen());
              },
              child: Text(l10n.tryAgain),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDuelsContent(BuildContext context, DuelsReady state) {
    final l10n = AppLocalizations.of(context)!;

    return SafeArea(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(Constants.margin),
        child: Column(
          children: [
            _buildHeader(context),
            const SizedBox(height: Constants.margin * 2),
            CharacterSelector(
              title: l10n.selectFirstFighter,
              selectedCharacter: state.firstCharacter,
              availableCharacters: state.availableCharacters,
              onCharacterSelected: (character) {
                context.read<DuelsBloc>().add(SelectFirstCharacter(character));
              },
              onClearSelection: () {
                context.read<DuelsBloc>().add(const ClearCharacterSelection(1));
              },
              position: 1,
            ),
            const SizedBox(height: Constants.margin * 2),
            if (state.firstCharacter != null && state.secondCharacter != null)
              DuelArena(
                firstCharacter: state.firstCharacter!,
                secondCharacter: state.secondCharacter!,
                isDuelInProgress: state.isDuelInProgress,
                winner: state.winner,
                onStartDuel: () {
                  context.read<DuelsBloc>().add(const StartDuel());
                },
                canStartDuel: state.canStartDuel,
              )
            else
              _buildVsIndicator(context),
            const SizedBox(height: Constants.margin * 2),
            CharacterSelector(
              title: l10n.selectSecondFighter,
              selectedCharacter: state.secondCharacter,
              availableCharacters: state.availableCharacters,
              onCharacterSelected: (character) {
                context.read<DuelsBloc>().add(SelectSecondCharacter(character));
              },
              onClearSelection: () {
                context.read<DuelsBloc>().add(const ClearCharacterSelection(2));
              },
              position: 2,
            ),
            if (state.winner != null) ...[
              const SizedBox(height: Constants.margin * 2),
              DuelResult(
                winner: state.winner!,
                onNewDuel: () {
                  context.read<DuelsBloc>().add(const ResetDuel());
                },
              ),
            ],
            const SizedBox(height: Constants.margin * 4),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Column(
      children: [
        const SizedBox(height: Constants.margin),
        Text(
          l10n.duelsSubtitle,
          textAlign: TextAlign.center,
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
            color: Theme.of(context).colorScheme.onSurface,
            shadows: [
              Shadow(
                color: Theme.of(
                  context,
                ).colorScheme.shadow.withValues(alpha: 0.5),
                offset: const Offset(1, 1),
                blurRadius: 2,
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildVsIndicator(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(Constants.margin * 2),
      child: Text(
        'VS',
        style: Theme.of(context).textTheme.headlineLarge?.copyWith(
          fontWeight: FontWeight.bold,
          shadows: [
            Shadow(
              color: Theme.of(
                context,
              ).colorScheme.shadow.withValues(alpha: 0.5),
              offset: const Offset(3, 3),
              blurRadius: 6,
            ),
          ],
        ),
      ),
    );
  }
}
