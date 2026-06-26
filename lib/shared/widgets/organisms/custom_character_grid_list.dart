import 'package:opfan/shared/widgets/atoms/app_icon.dart';
import 'package:phosphoricons_flutter/phosphoricons_flutter.dart';
// Developed by Randerson Mayllon
// Copyright © 2022.

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:opfan/l10n/app_localizations.dart';
import 'package:opfan/features/custom_character/data/models/custom_character_model.dart';
import 'package:opfan/features/custom_character/bloc/custom_character_bloc.dart';
import 'package:opfan/features/custom_character/bloc/custom_character_event.dart';
import 'package:opfan/features/custom_character/bloc/custom_character_state.dart';
import 'package:opfan/shared/utils/constants.dart';
import 'package:opfan/shared/widgets/atoms/custom_character_card.dart';
import 'package:opfan/shared/widgets/molecules/custom_character_search_header.dart';

class CustomCharacterGridList extends StatefulWidget {
  final Function(CustomCharacterModel)? onCharacterTap;
  final Function(CustomCharacterModel)? onCharacterEdit;
  final Function(CustomCharacterModel)? onCharacterDelete;

  const CustomCharacterGridList({
    super.key,
    this.onCharacterTap,
    this.onCharacterEdit,
    this.onCharacterDelete,
  });

  @override
  State<CustomCharacterGridList> createState() =>
      _CustomCharacterGridListState();
}

class _CustomCharacterGridListState extends State<CustomCharacterGridList> {
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<CustomCharacterBloc>().add(const LoadCustomCharacters());
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        CustomCharacterSearchHeader(
          searchController: _searchController,
          onSearch: _onSearch,
          onFilter: _showFilterDialog,
          filterLabel: 'Filtrar por Fruta/Equipe',
        ),
        Expanded(
          child: BlocBuilder<CustomCharacterBloc, CustomCharacterState>(
            builder: (context, state) {
              if (state is CustomCharacterLoading) {
                return const Center(
                  child: CircularProgressIndicator(),
                );
              }

              if (state is CustomCharacterError) {
                return Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      AppIcon(
                        PhosphorIconsRegular.warningCircle,
                        size: 64,
                        color: Colors.grey[600],
                      ),
                      const SizedBox(height: Constants.margin),
                      Text(
                        AppLocalizations.of(context)!.loadingError,
                        style: Theme.of(context).textTheme.titleMedium,
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: Constants.margin),
                      Text(
                        state.message,
                        style: Theme.of(context).textTheme.bodySmall,
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: Constants.margin),
                      ElevatedButton(
                        onPressed: () {
                          context
                              .read<CustomCharacterBloc>()
                              .add(const LoadCustomCharacters());
                        },
                        child: Text(AppLocalizations.of(context)!.tryAgain),
                      ),
                    ],
                  ),
                );
              }

              if (state is CustomCharacterLoaded) {
                if (state.characters.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        AppIcon(
                          PhosphorIconsRegular.userPlus,
                          size: 64,
                          color: Colors.grey[600],
                        ),
                        const SizedBox(height: Constants.margin),
                        Text(
                          AppLocalizations.of(context)!.noCustomCharactersFound,
                          style: Theme.of(context).textTheme.titleMedium,
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: Constants.margin),
                        Text(
                          AppLocalizations.of(context)!
                              .createFirstCustomCharacter,
                          style: Theme.of(context).textTheme.bodySmall,
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  );
                }

                return GridView.builder(
                  padding: const EdgeInsets.all(Constants.margin),
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    childAspectRatio: 0.75,
                    crossAxisSpacing: Constants.margin,
                    mainAxisSpacing: Constants.margin,
                  ),
                  itemCount: state.characters.length,
                  itemBuilder: (context, index) {
                    final character = state.characters[index];
                    return CustomCharacterCard(
                      character: character,
                      onTap: () => widget.onCharacterTap?.call(character),
                      onEdit: () => widget.onCharacterEdit?.call(character),
                      onDelete: () => _showDeleteConfirmation(character),
                    );
                  },
                );
              }

              return Center(
                child: Text(
                  AppLocalizations.of(context)!.loading,
                  style: Theme.of(context).textTheme.titleMedium,
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  void _onSearch() {
    final query = _searchController.text.trim();
    if (query.isEmpty) {
      context.read<CustomCharacterBloc>().add(const LoadCustomCharacters());
    } else {
      context.read<CustomCharacterBloc>().add(SearchCustomCharacters(query));
    }
  }

  void _showFilterDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(AppLocalizations.of(context)!.filterBy),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const AppIcon(PhosphorIconsRegular.fire),
              title: Text(AppLocalizations.of(context)!.devilFruit),
              onTap: () {
                Navigator.pop(context);
                _showDevilFruitFilter();
              },
            ),
            ListTile(
              leading: const AppIcon(PhosphorIconsRegular.users),
              title: Text(AppLocalizations.of(context)!.crews),
              onTap: () {
                Navigator.pop(context);
                _showCrewFilter();
              },
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(AppLocalizations.of(context)!.cancel),
          ),
        ],
      ),
    );
  }

  void _showDevilFruitFilter() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(AppLocalizations.of(context)!.filterByDevilFruit),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              decoration: InputDecoration(
                labelText: AppLocalizations.of(context)!.devilFruitName,
                hintText: AppLocalizations.of(context)!.devilFruitNameHint,
              ),
              onSubmitted: (value) {
                Navigator.pop(context);
                if (value.isNotEmpty) {
                  context.read<CustomCharacterBloc>().add(
                        FilterCustomCharactersByDevilFruit(value),
                      );
                }
              },
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(AppLocalizations.of(context)!.cancel),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              context
                  .read<CustomCharacterBloc>()
                  .add(const LoadCustomCharacters());
            },
            child: Text(AppLocalizations.of(context)!.clearFilters),
          ),
        ],
      ),
    );
  }

  void _showCrewFilter() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(AppLocalizations.of(context)!.filterByCrew),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              decoration: InputDecoration(
                labelText: AppLocalizations.of(context)!.crewNameFilter,
                hintText: AppLocalizations.of(context)!.crewNameFilterHint,
              ),
              onSubmitted: (value) {
                Navigator.pop(context);
                if (value.isNotEmpty) {
                  context.read<CustomCharacterBloc>().add(
                        FilterCustomCharactersByCrew(value),
                      );
                }
              },
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(AppLocalizations.of(context)!.cancel),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              context
                  .read<CustomCharacterBloc>()
                  .add(const LoadCustomCharacters());
            },
            child: Text(AppLocalizations.of(context)!.clearFilters),
          ),
        ],
      ),
    );
  }

  void _showDeleteConfirmation(CustomCharacterModel character) {
    final l10n = AppLocalizations.of(context)!;

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(l10n.confirmDelete),
        content: Text(
          l10n.confirmDeleteCrew(character.name),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(l10n.cancel),
          ),
          ElevatedButton(
            onPressed: () {
              widget.onCharacterDelete?.call(character);
              Navigator.pop(context);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
            ),
            child: Text(l10n.delete),
          ),
        ],
      ),
    );
  }
}
