import 'package:opfan/shared/widgets/atoms/app_icon.dart';
import 'package:phosphoricons_flutter/phosphoricons_flutter.dart';
import 'package:opfan/core/connectivity/connectivity_cubit.dart';
import 'package:opfan/app/di/injection.dart';
import 'package:opfan/shared/widgets/organisms/offline_blocker_overlay.dart';
// Developed by Randerson Mayllon
// Copyright © 2022.

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:opfan/l10n/app_localizations.dart';

import 'package:opfan/features/devil_fruit/bloc/index.dart';
import 'package:opfan/features/devil_fruit/data/models/devil_fruit.dart';
import 'package:opfan/shared/utils/devil_fruit_type_palette.dart';
import 'package:opfan/features/devil_fruit/presentation/widgets/devil_fruit_card.dart';
import 'package:opfan/features/devil_fruit/presentation/widgets/devil_fruit_search_header.dart';

import 'package:opfan/features/devil_fruit/presentation/widgets/empty_devil_fruit_list.dart';
import 'package:opfan/shared/utils/constants.dart';
import 'package:opfan/shared/widgets/molecules/default_app_bar.dart';

class DevilFruitListScreen extends StatelessWidget {
  const DevilFruitListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(
          create: (_) => getIt<DevilFruitBloc>()..add(const LoadDevilFruits()),
        ),
        BlocProvider.value(value: getIt<ConnectivityCubit>()),
      ],
      child: const _DevilFruitListView(),
    );
  }
}

class _DevilFruitListView extends StatelessWidget {
  const _DevilFruitListView();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: DefaultAppBar(
        title: Text(
          AppLocalizations.of(context)!.devilFruit,
          style: Theme.of(
            context,
          ).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold),
        ),
        actions: [
          BlocBuilder<DevilFruitBloc, DevilFruitState>(
            builder: (context, state) {
              return IconButton(
                icon: const AppIcon(PhosphorIconsRegular.arrowsClockwise),
                onPressed: state is DevilFruitLoading
                    ? null
                    : () => context.read<DevilFruitBloc>().add(
                        const RefreshDevilFruits(),
                      ),
              );
            },
          ),
        ],
      ),
      body: OfflineBlockerOverlay(
        child: BlocBuilder<DevilFruitBloc, DevilFruitState>(
          builder: (context, state) {
            if (state is DevilFruitInitial || state is DevilFruitLoading) {
              return const Center(child: CircularProgressIndicator());
            }

            if (state is DevilFruitError) {
              return _buildErrorState(context, state.failure);
            }

            if (state is DevilFruitLoaded) {
              return _buildLoadedState(context, state);
            }
            return const SizedBox();
          },
        ),
      ),
    );
  }

  Widget _buildErrorState(BuildContext context, DevilFruitFailure failure) {
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
            const SizedBox(height: Constants.margin * 2),
            Text(
              l10n.devilFruitLoadErrorTitle,
              style: Theme.of(
                context,
              ).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: Constants.margin),
            Text(
              _failureMessage(l10n, failure),
              style: Theme.of(context).textTheme.bodyMedium,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: Constants.margin * 2),
            ElevatedButton.icon(
              onPressed: () =>
                  context.read<DevilFruitBloc>().add(const LoadDevilFruits()),
              icon: const AppIcon(PhosphorIconsRegular.arrowsClockwise),
              label: Text(l10n.tryAgain),
            ),
          ],
        ),
      ),
    );
  }

  String _failureMessage(AppLocalizations l10n, DevilFruitFailure failure) =>
      switch (failure) {
        DevilFruitFailure.loadFailed => l10n.devilFruitLoadError,
        DevilFruitFailure.refreshFailed => l10n.devilFruitRefreshError,
        DevilFruitFailure.searchFailed => l10n.devilFruitSearchFailed,
        DevilFruitFailure.filterFailed => l10n.devilFruitFilterError,
      };

  Widget _buildLoadedState(BuildContext context, DevilFruitLoaded state) {
    return RefreshIndicator(
      onRefresh: () async {
        context.read<DevilFruitBloc>().add(const RefreshDevilFruits());
      },
      child: CustomScrollView(
        slivers: [
          const SliverToBoxAdapter(
            child: Padding(
              padding: EdgeInsets.all(Constants.margin),
              child: DevilFruitSearchHeader(),
            ),
          ),
          SliverToBoxAdapter(child: _buildFiltersSection(context, state)),
          if (state.isSearching)
            const SliverToBoxAdapter(
              child: Padding(
                padding: EdgeInsets.all(Constants.margin),
                child: Center(child: CircularProgressIndicator()),
              ),
            ),
          if (state.filteredFruits.isEmpty && !state.isSearching)
            SliverToBoxAdapter(
              child: EmptyDevilFruitList(
                hasFilters:
                    state.searchQuery.isNotEmpty || state.selectedType != null,
                onClearFilters: () {
                  context.read<DevilFruitBloc>().add(
                    const ClearDevilFruitFilters(),
                  );
                },
              ),
            )
          else if (!state.isSearching)
            SliverPadding(
              padding: const EdgeInsets.all(Constants.margin),
              sliver: SliverGrid(
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  childAspectRatio: 0.75,
                  crossAxisSpacing: Constants.margin,
                  mainAxisSpacing: Constants.margin,
                ),
                delegate: SliverChildBuilderDelegate((context, index) {
                  final fruit = state.filteredFruits[index];
                  return DevilFruitCard(
                    devilFruit: fruit,
                    onTap: () => _showDevilFruitDetails(context, fruit),
                  );
                }, childCount: state.filteredFruits.length),
              ),
            ),
          const SliverToBoxAdapter(
            child: SizedBox(height: Constants.margin * 2),
          ),
        ],
      ),
    );
  }

  void _showDevilFruitDetails(BuildContext context, DevilFruit fruit) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(fruit.romanName),
        content: SingleChildScrollView(
          child: Column(
            spacing: Constants.margin / 2,
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                '${AppLocalizations.of(context)!.type}: ${fruit.type}',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: Theme.of(context).primaryColor,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox.shrink(),
              Text(
                '${AppLocalizations.of(context)!.description}:',
                style: Theme.of(
                  context,
                ).textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.bold),
              ),
              Text(
                fruit.description,
                style: Theme.of(context).textTheme.bodyMedium,
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text(AppLocalizations.of(context)!.close),
          ),
        ],
      ),
    );
  }

  Widget _buildFiltersSection(BuildContext context, DevilFruitLoaded state) {
    if (state.availableTypes.isEmpty) {
      return const SizedBox.shrink();
    }

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: Constants.margin),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                AppLocalizations.of(context)!.filterByType,
                style: Theme.of(
                  context,
                ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
              ),
              if (state.selectedType != null)
                TextButton(
                  onPressed: () {
                    context.read<DevilFruitBloc>().add(
                      const ClearDevilFruitFilters(),
                    );
                  },
                  child: Text(AppLocalizations.of(context)!.clear),
                ),
            ],
          ),
          const SizedBox(height: Constants.margin),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: state.availableTypes.map((type) {
                final isSelected = state.selectedType == type;
                return Padding(
                  padding: const EdgeInsets.only(right: Constants.margin),
                  child: FilterChip(
                    label: Text(type),
                    selected: isSelected,
                    onSelected: (_) {
                      if (isSelected) {
                        context.read<DevilFruitBloc>().add(
                          const FilterDevilFruitsByType(''),
                        );
                      } else {
                        context.read<DevilFruitBloc>().add(
                          FilterDevilFruitsByType(type),
                        );
                      }
                    },
                    selectedColor: DevilFruitTypePalette.of(
                      type,
                    ).accent.withValues(alpha: 0.2),
                    checkmarkColor: DevilFruitTypePalette.of(type).accent,
                    avatar: isSelected
                        ? null
                        : Icon(
                            _getTypeIcon(type),
                            size: 18,
                            color: DevilFruitTypePalette.of(type).accent,
                          ),
                    backgroundColor: Theme.of(
                      context,
                    ).colorScheme.surfaceContainerHigh,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(Constants.margin * 2),
                      side: BorderSide(
                        color: isSelected
                            ? DevilFruitTypePalette.of(type).accent
                            : Theme.of(context).colorScheme.outlineVariant,
                        width: isSelected ? 2 : 1,
                      ),
                    ),
                  ),
                );
              }).toList(),
            ),
          ),
          const SizedBox(height: Constants.margin),
        ],
      ),
    );
  }

  IconData _getTypeIcon(String type) {
    switch (type.toLowerCase()) {
      case 'logia':
        return PhosphorIconsRegular.drop;
      case 'paramecia':
        return PhosphorIconsRegular.magicWand;
      case 'zoan':
        return PhosphorIconsRegular.pawPrint;
      default:
        return PhosphorIconsRegular.question;
    }
  }
}
