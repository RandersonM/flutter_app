import 'package:opfan/shared/widgets/atoms/app_icon.dart';
import 'package:phosphoricons_flutter/phosphoricons_flutter.dart';
// Developed by Randerson Mayllon
// Copyright © 2022.

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:opfan/features/crews/data/models/crew_model.dart';
import 'package:opfan/l10n/app_localizations.dart';
import 'package:opfan/features/crews/bloc/list_crews_bloc.dart';
import 'package:opfan/features/crews/bloc/list_crews_event.dart';
import 'package:opfan/features/crews/bloc/list_crews_state.dart';
import 'package:opfan/shared/utils/constants.dart';
import 'package:opfan/shared/widgets/atoms/crew_card.dart';
import 'package:opfan/shared/widgets/molecules/crew_search_header.dart';

class CrewList extends StatefulWidget {
  final Function(CrewModel)? onCrewTap;
  final Function(CrewModel)? onCrewEdit;
  final Function(CrewModel)? onCrewDelete;
  final bool Function(CrewModel)? showEditDeleteButtons;
  final bool isUserCrews;
  final void Function(String query)? onSearch;

  const CrewList({
    super.key,
    this.onCrewTap,
    this.onCrewEdit,
    this.onCrewDelete,
    this.showEditDeleteButtons,
    this.isUserCrews = false,
    this.onSearch,
  });

  @override
  State<CrewList> createState() => _CrewListState();
}

class _CrewListState extends State<CrewList> {
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (widget.isUserCrews) {
        context.read<ListCrewsBloc>().add(LoadUserCrews());
      } else {
        context.read<ListCrewsBloc>().add(LoadCrews());
      }
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
                      AppIcon(
                        PhosphorIconsRegular.warningCircle,
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
                          if (widget.isUserCrews) {
                            context.read<ListCrewsBloc>().add(LoadUserCrews());
                          } else {
                            context.read<ListCrewsBloc>().add(LoadCrews());
                          }
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
                        AppIcon(
                          PhosphorIconsRegular.sailboat,
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
                  padding:
                      const EdgeInsets.symmetric(vertical: Constants.margin),
                  itemCount: state.crews.length,
                  itemBuilder: (context, index) {
                    final crew = state.crews[index];
                    final canEdit =
                        widget.showEditDeleteButtons?.call(crew) ?? true;
                    return CrewCard(
                      crew: crew,
                      onTap: () => widget.onCrewTap?.call(crew),
                      onEdit:
                          canEdit ? () => widget.onCrewEdit?.call(crew) : null,
                      onDelete:
                          canEdit ? () => _showDeleteConfirmation(crew) : null,
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
    if (widget.onSearch != null) {
      widget.onSearch!(query);
    } else {
      if (query.isEmpty) {
        if (widget.isUserCrews) {
          context.read<ListCrewsBloc>().add(LoadUserCrews());
        } else {
          context.read<ListCrewsBloc>().add(LoadCrews());
        }
      } else {
        if (widget.isUserCrews) {
          context.read<ListCrewsBloc>().add(SearchUserCrews(query));
        } else {
          context.read<ListCrewsBloc>().add(SearchCrews(query));
        }
      }
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
