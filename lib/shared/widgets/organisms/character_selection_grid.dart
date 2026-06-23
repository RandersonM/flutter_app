// Developed by Randerson Mayllon
// Copyright © 2022.

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:opfan/core/models/one_piece/custom_character_model.dart';
import 'package:opfan/features/one_piece/bloc/search_cubit.dart';

import 'package:opfan/app/di/injection.dart';
import 'package:opfan/l10n/app_localizations.dart';
import 'package:opfan/shared/utils/constants.dart';

class CharacterSelectionGrid extends StatefulWidget {
  const CharacterSelectionGrid({
    super.key,
    required this.onCharacterSelected,
  });

  final Function(CustomCharacterModel) onCharacterSelected;

  @override
  State<CharacterSelectionGrid> createState() => _CharacterSelectionGridState();
}

class _CharacterSelectionGridState extends State<CharacterSelectionGrid> {
  late final SearchCubit _searchCubit;

  @override
  void initState() {
    super.initState();
    _searchCubit = getIt<SearchCubit>();
    _searchCubit.filter();
  }

  @override
  void dispose() {
    _searchCubit.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider.value(
      value: _searchCubit,
      child: Column(
        children: [
          _buildSearchHeader(),
          const SizedBox(height: Constants.margin),
          Expanded(
            child: _buildCharacterList(),
          ),
        ],
      ),
    );
  }

  Widget _buildSearchHeader() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: Constants.margin),
      child: TextField(
        decoration: InputDecoration(
          hintText: AppLocalizations.of(context)!.search,
          prefixIcon: const Icon(Icons.search),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          filled: true,
          fillColor: Theme.of(context).colorScheme.surface,
        ),
        onChanged: (value) {
          _searchCubit.setQuery(value);
        },
      ),
    );
  }

  Widget _buildCharacterList() {
    return BlocBuilder<SearchCubit, SearchState>(
      builder: (context, state) {
        if (state is SearchLoading) {
          return const Center(
            child: CircularProgressIndicator(),
          );
        }

        if (state is SearchError) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.error_outline,
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
              ],
            ),
          );
        }

        if (state is SearchLoaded) {
          if (state.queryResults.isEmpty && state.query.isNotEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.search_off,
                    size: 64,
                    color: Colors.grey[600],
                  ),
                  const SizedBox(height: Constants.margin),
                  Text(
                    '${AppLocalizations.of(context)!.noResultsFound} "${state.query}"',
                    style: Theme.of(context).textTheme.titleMedium,
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
            itemCount: state.queryResults.length,
            itemBuilder: (context, index) {
              final character = state.queryResults[index];
              return GestureDetector(
                onTap: () => widget.onCharacterSelected(character),
                child: _buildSelectableCharacterCard(character),
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
    );
  }

  Widget _buildSelectableCharacterCard(CustomCharacterModel character) {
    return Card(
      shape: RoundedRectangleBorder(
        side: const BorderSide(color: Colors.white),
        borderRadius: BorderRadius.circular(Constants.margin * 2),
      ),
      child: Padding(
        padding: const EdgeInsets.all(Constants.margin),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: <Widget>[
            Expanded(
              flex: 3,
              child: Container(
                width: double.infinity,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(Constants.margin * 2),
                  color: Colors.grey[200],
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(Constants.margin * 2),
                  child: Image.network(
                    character.image,
                    fit: BoxFit.cover,
                    loadingBuilder: (context, child, loadingProgress) {
                      if (loadingProgress == null) return child;
                      return Center(
                        child: CircularProgressIndicator(
                          value: loadingProgress.expectedTotalBytes != null
                              ? loadingProgress.cumulativeBytesLoaded /
                                  loadingProgress.expectedTotalBytes!
                              : null,
                        ),
                      );
                    },
                    errorBuilder: (context, error, stackTrace) {
                      return Container(
                        width: double.infinity,
                        height: double.infinity,
                        color: Colors.grey[300],
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.person,
                              size: 48,
                              color: Colors.grey[600],
                            ),
                            const SizedBox(height: 8),
                            Text(
                              AppLocalizations.of(context)!.imageUnavailable,
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                color: Colors.grey[600],
                                fontSize: 12,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                ),
              ),
            ),
            const SizedBox(height: Constants.margin),
            Expanded(
              flex: 1,
              child: FittedBox(
                fit: BoxFit.scaleDown,
                child: Text(
                  character.name,
                  textAlign: TextAlign.center,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: Theme.of(context).textTheme.bodySmall!.merge(
                        TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Theme.of(context)
                              .appBarTheme
                              .titleTextStyle!
                              .color,
                        ),
                      ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
