// Developed by Randerson Mayllon
// Copyright © 2022.

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:opfan/core/services/service_locator.dart';
import 'package:opfan/core/repository/featured_character_repository.dart';
import 'package:opfan/core/repository/custom_character_repository.dart';
import 'package:opfan/l10n/app_localizations.dart';
import 'package:opfan/screens/duels/blocs/index.dart';
import 'package:opfan/screens/duels/widgets/character_selector.dart';
import 'package:opfan/screens/duels/widgets/duel_arena.dart';
import 'package:opfan/screens/duels/widgets/duel_result.dart';
import 'package:opfan/utils/constants.dart';
import 'package:opfan/widgets/atoms/futuristic_background.dart';
import 'package:opfan/widgets/molecules/default_app_bar.dart';

class DuelsScreen extends StatefulWidget {
  const DuelsScreen({super.key});

  @override
  State<DuelsScreen> createState() => _DuelsScreenState();
}

class _DuelsScreenState extends State<DuelsScreen> {
  late DuelsBloc _duelsBloc;

  @override
  void initState() {
    super.initState();
    _duelsBloc = DuelsBloc(
      featuredCharacterRepository: getIt<FeaturedCharacterRepository>(),
      customCharacterRepository: getIt<CustomCharacterRepository>(),
    );
    _duelsBloc.add(const LoadDuelsScreen());
  }

  @override
  void dispose() {
    _duelsBloc.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    
    return BlocProvider.value(
      value: _duelsBloc,
      child: Scaffold(
        extendBodyBehindAppBar: true,
        appBar: DefaultAppBar(
          title: Text(
            l10n.duels,
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
            ),
          ),
          actions: [
            BlocBuilder<DuelsBloc, DuelsState>(
              builder: (context, state) {
                if (state is DuelsReady) {
                  return IconButton(
                    icon: const Icon(
                      FontAwesomeIcons.shuffle,
                    ),
                    onPressed: () {
                      _duelsBloc.add(const RandomizeCharacters());
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
                    icon: const Icon(
                      Icons.refresh,

                    ),
                    onPressed: () {
                      _duelsBloc.add(const ResetDuel());
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
                return _buildErrorState(state.message);
              }

              if (state is DuelsReady) {
                return _buildDuelsContent(state);
              }

              return const SizedBox.shrink();
            },
          ),
        ),
      ),
    );
  }

  Widget _buildErrorState(String message) {
    final l10n = AppLocalizations.of(context)!;
    
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(Constants.margin * 2),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.error_outline,
              size: 64,
              color: Colors.white,
            ),
            const SizedBox(height: Constants.margin),
            Text(
              l10n.error,
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: Constants.margin),
            Text(
              message,
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: Colors.white70,
              ),
            ),
            const SizedBox(height: Constants.margin * 2),
            ElevatedButton(
              onPressed: () {
                _duelsBloc.add(const LoadDuelsScreen());
              },
              child: Text(l10n.tryAgain),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDuelsContent(DuelsReady state) {
    final l10n = AppLocalizations.of(context)!;
    
    return SafeArea(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(Constants.margin),
        child: Column(
          children: [
            _buildHeader(),
            
            const SizedBox(height: Constants.margin * 2),
            
            CharacterSelector(
              title: l10n.selectFirstFighter,
              selectedCharacter: state.firstCharacter,
              availableCharacters: state.availableCharacters,
              onCharacterSelected: (character) {
                _duelsBloc.add(SelectFirstCharacter(character));
              },
              onClearSelection: () {
                _duelsBloc.add(const ClearCharacterSelection(1));
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
                  _duelsBloc.add(const StartDuel());
                },
                canStartDuel: state.canStartDuel,
              )
            else
              _buildVsIndicator(),
            
            const SizedBox(height: Constants.margin * 2),
            
            CharacterSelector(
              title: l10n.selectSecondFighter,
              selectedCharacter: state.secondCharacter,
              availableCharacters: state.availableCharacters,
              onCharacterSelected: (character) {
                _duelsBloc.add(SelectSecondCharacter(character));
              },
              onClearSelection: () {
                _duelsBloc.add(const ClearCharacterSelection(2));
              },
              position: 2,
            ),
            
            if (state.winner != null) ...[
              const SizedBox(height: Constants.margin * 2),
              DuelResult(
                winner: state.winner!,
                onNewDuel: () {
                  _duelsBloc.add(const ResetDuel());
                },
              ),
            ],
            
            const SizedBox(height: Constants.margin * 4),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    final l10n = AppLocalizations.of(context)!;
    
    return Column(
      children: [
        const SizedBox(height: Constants.margin),
        Text(
          l10n.duelsSubtitle,
          textAlign: TextAlign.center,
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
            color: Colors.black,
            shadows: [
              Shadow(
                color: Colors.black.withValues(alpha: 0.5),
                offset: const Offset(1, 1),
                blurRadius: 2,
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildVsIndicator() {
    return Container(
      padding: const EdgeInsets.all(Constants.margin * 2),
      child: Text(
        'VS',
        style: Theme.of(context).textTheme.headlineLarge?.copyWith(
          fontWeight: FontWeight.bold,
          shadows: [
            Shadow(
              color: Colors.black.withValues(alpha: 0.5),
              offset: const Offset(3, 3),
              blurRadius: 6,
            ),
          ],
        ),
      ),
    );
  }
} 