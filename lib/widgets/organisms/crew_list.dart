// Developed by Randerson Mayllon
// Copyright © 2022.

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:opfan/core/models/one_piece/crew_model.dart';
import 'package:opfan/l10n/app_localizations.dart';
import 'package:opfan/screens/crews/blocs/list_crews_bloc.dart';
import 'package:opfan/screens/crews/blocs/list_crews_event.dart';
import 'package:opfan/screens/crews/blocs/list_crews_state.dart';
import 'package:opfan/utils/constants.dart';
import 'package:opfan/widgets/atoms/crew_card.dart';
import 'package:opfan/widgets/molecules/crew_search_header.dart';

class CrewList extends StatefulWidget {
  final Function(CrewModel)? onCrewTap;
  final Function(CrewModel)? onCrewEdit;
  final Function(CrewModel)? onCrewDelete;

  const CrewList({
    Key? key,
    this.onCrewTap,
    this.onCrewEdit,
    this.onCrewDelete,
  }) : super(key: key);

  @override
  State<CrewList> createState() => _CrewListState();
}

class _CrewListState extends State<CrewList> {
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<ListCrewsBloc>().add(LoadCrews());
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    
    return Column(
      children: [
        CrewSearchHeader(
          searchController: _searchController,
          onSearch: _onSearch,
        ),
        Expanded(
          child: BlocBuilder<ListCrewsBloc, ListCrewsState>(
            builder: (context, state) {
              if (state is ListCrewsLoading) {
                return const Center(
                  child: CircularProgressIndicator(),
                );
              }

              if (state is ListCrewsError) {
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
                        l10n.errorLoadingCrews,
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
                          context.read<ListCrewsBloc>().add(LoadCrews());
                        },
                        child: Text(l10n.tryAgain),
                      ),
                    ],
                  ),
                );
              }

              if (state is ListCrewsLoaded) {
                if (state.crews.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.sailing,
                          size: 64,
                          color: Colors.grey[600],
                        ),
                        const SizedBox(height: Constants.margin),
                        Text(
                          l10n.noCrewsFound,
                          style: Theme.of(context).textTheme.titleMedium,
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: Constants.margin),
                        Text(
                          l10n.createFirstCrew,
                          style: Theme.of(context).textTheme.bodySmall,
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  );
                }

                return ListView.builder(
                  padding: const EdgeInsets.symmetric(vertical: Constants.margin),
                  itemCount: state.crews.length,
                  itemBuilder: (context, index) {
                    final crew = state.crews[index];
                    return CrewCard(
                      crew: crew,
                      onTap: () => widget.onCrewTap?.call(crew),
                      onEdit: () => widget.onCrewEdit?.call(crew),
                      onDelete: () => _showDeleteConfirmation(crew),
                    );
                  },
                );
              }

              return Center(
                child: Text(
                  l10n.loading,
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
      context.read<ListCrewsBloc>().add(LoadCrews());
    } else {
      context.read<ListCrewsBloc>().add(SearchCrews(query));
    }
  }

  void _showDeleteConfirmation(CrewModel crew) {
    final l10n = AppLocalizations.of(context)!;
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(l10n.confirmDelete),
        content: Text(
          l10n.confirmDeleteCrew(crew.name),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(l10n.cancel),
          ),
          ElevatedButton(
            onPressed: () {
              widget.onCrewDelete?.call(crew);
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