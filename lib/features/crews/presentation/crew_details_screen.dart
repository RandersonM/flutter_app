import 'package:opfan/shared/widgets/atoms/app_icon.dart';
import 'package:phosphoricons_flutter/phosphoricons_flutter.dart';
// Developed by Randerson Mayllon
// Copyright © 2022.

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:opfan/features/crews/bloc/index.dart';
import 'package:opfan/features/crews/data/models/crew_model.dart';
import 'package:opfan/features/custom_character/data/models/custom_character_model.dart';
import 'package:opfan/app/di/injection.dart';
import 'package:opfan/shared/utils/app_routes.dart';
import 'package:opfan/shared/utils/constants.dart';
import 'package:opfan/l10n/app_localizations.dart';
import 'package:opfan/shared/widgets/molecules/default_app_bar.dart';
import 'package:opfan/shared/widgets/atoms/custom_dropdown.dart';
import 'package:opfan/shared/widgets/atoms/circle_avatar.dart';
import 'widgets/crew_header.dart';
import 'widgets/crew_statistics.dart';
import 'widgets/crew_members_list.dart';
import 'widgets/crew_tags_section.dart';
import 'widgets/crew_info_section.dart';
import 'widgets/crew_boat_section.dart';
import 'package:opfan/core/utils/character_localization_mapper.dart';
import 'package:opfan/shared/utils/app_semantic_colors.dart';

class CrewDetailsScreen extends StatelessWidget {
  final CrewModel crew;

  const CrewDetailsScreen({super.key, required this.crew});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => getIt<CrewDetailsBloc>(param1: crew),
      child: const _CrewDetailsView(),
    );
  }
}

class _CrewDetailsView extends StatelessWidget {
  const _CrewDetailsView();

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<CrewDetailsBloc, CrewDetailsState>(
      listenWhen: (previous, current) =>
          current.effect != null && current.effect != previous.effect,
      listener: _onEffect,
      builder: (context, state) {
        final l10n = AppLocalizations.of(context)!;
        final theme = Theme.of(context);
        final crew = state.crew;

        return Stack(
          children: [
            Scaffold(
              backgroundColor: theme.colorScheme.surface,
              appBar: DefaultAppBar(
                title: Text(crew.name),
                actions: [
                  if (state.isOwner) ...[
                    IconButton(
                      onPressed: () => _onEditCrew(context, state),
                      icon: const AppIcon(PhosphorIconsRegular.pencil),
                      tooltip: l10n.edit,
                    ),
                    IconButton(
                      onPressed: () => _onDeleteCrew(context, crew),
                      icon: AppIcon(
                        PhosphorIconsRegular.trash,
                        color: theme.colorScheme.error,
                      ),
                      tooltip: l10n.delete,
                    ),
                  ],
                ],
              ),
              body: SingleChildScrollView(
                padding: const EdgeInsets.all(Constants.margin),
                child: Column(
                  spacing: Constants.margin * 2,
                  children: [
                    CrewHeader(
                      crew: crew,
                      onEdit: () => _onEditCrew(context, state),
                    ),
                    CrewStatistics(crew: crew),
                    CrewMembersList(
                      crew: crew,
                      onMemberTap: (member) => context
                          .read<CrewDetailsBloc>()
                          .add(OpenCrewMember(member)),
                    ),
                    CrewBoatSection(crew: crew),
                    CrewTagsSection(crew: crew),
                    CrewInfoSection(crew: crew),
                    const SizedBox(height: Constants.margin * 10),
                  ],
                ),
              ),
              floatingActionButton: state.isOwner
                  ? FloatingActionButton.extended(
                      onPressed: () => _onAddMember(context, crew),
                      backgroundColor: theme.colorScheme.primary,
                      foregroundColor: theme.colorScheme.onPrimary,
                      icon: const AppIcon(PhosphorIconsRegular.userPlus),
                      label: Text(l10n.addMember),
                    )
                  : null,
            ),
            if (state.isBusy) const _BusyOverlay(),
          ],
        );
      },
    );
  }

  void _onEffect(BuildContext context, CrewDetailsState state) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);

    void showSnack(String message, Color background) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(message), backgroundColor: background),
      );
    }

    switch (state.effect) {
      case CrewDeleted():
        showSnack(
          l10n.crewDeletedWithName(state.crew.name),
          theme.colorScheme.error,
        );
        Navigator.of(
          context,
        ).pop({'action': 'deleted', 'crewId': state.crew.id});
      case CrewMemberAdded(:final characterName, :final roleKey):
        showSnack(
          l10n.memberAddedAsRole(
            characterName,
            CharacterLocalizationMapper.mapOccupationToLocalized(roleKey, l10n),
          ),
          theme.semanticColors.success,
        );
      case CrewMemberOpened(:final character):
        Navigator.pushNamed(
          context,
          AppRoutes.characterDetails,
          arguments: character,
        );
      case CrewMemberNotFound():
        showSnack(l10n.characterNotFound, theme.semanticColors.warning);
      case CrewDetailsFailed(:final failure):
        showSnack(_failureMessage(l10n, failure), theme.colorScheme.error);
      case null:
        break;
    }
  }

  String _failureMessage(AppLocalizations l10n, CrewDetailsFailure failure) =>
      switch (failure) {
        CrewDetailsFailure.deleteFailed => l10n.crewDeletionError,
        CrewDetailsFailure.addMemberFailed => l10n.memberAdditionError,
        CrewDetailsFailure.memberLoadFailed => l10n.characterLoadError,
        CrewDetailsFailure.roleTaken => l10n.customCharacterCrewRoleTakenError,
      };

  void _onEditCrew(BuildContext context, CrewDetailsState state) {
    if (!state.isOwner) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(AppLocalizations.of(context)!.noPermissionToEdit),
          backgroundColor: Theme.of(context).semanticColors.warning,
        ),
      );
      return;
    }

    Navigator.pushNamed(context, AppRoutes.editCrew, arguments: state.crew);
  }

  void _onDeleteCrew(BuildContext context, CrewModel crew) {
    final l10n = AppLocalizations.of(context)!;

    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: Text(l10n.confirmDelete),
        content: Text(l10n.confirmDeleteCrew(crew.name)),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(),
            child: Text(l10n.cancel),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(dialogContext).pop();
              context.read<CrewDetailsBloc>().add(const ConfirmCrewDeletion());
            },
            style: TextButton.styleFrom(
              foregroundColor: Theme.of(context).colorScheme.error,
            ),
            child: Text(l10n.delete),
          ),
        ],
      ),
    );
  }

  Future<void> _onAddMember(BuildContext context, CrewModel crew) async {
    final l10n = AppLocalizations.of(context)!;

    final availableRoles = CharacterLocalizationMapper.getOccupations()
        .where((role) => !crew.isRoleFilled(role))
        .toList();

    if (availableRoles.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(l10n.allRolesFilled),
          backgroundColor: Theme.of(context).semanticColors.warning,
        ),
      );
      return;
    }

    final bloc = context.read<CrewDetailsBloc>()
      ..add(const LoadAvailableCharacters());
    final selection = await showDialog<AddCrewMember>(
      context: context,
      builder: (_) => BlocProvider.value(
        value: bloc,
        child: _AddMemberDialog(availableRoles: availableRoles),
      ),
    );
    if (selection != null) bloc.add(selection);
  }
}

class _BusyOverlay extends StatelessWidget {
  const _BusyOverlay();

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        ModalBarrier(
          dismissible: false,
          color: Theme.of(context).colorScheme.scrim.withValues(alpha: 0.5),
        ),
        const Center(child: CircularProgressIndicator()),
      ],
    );
  }
}

class _AddMemberDialog extends StatefulWidget {
  const _AddMemberDialog({required this.availableRoles});

  final List<String> availableRoles;

  @override
  State<_AddMemberDialog> createState() => _AddMemberDialogState();
}

class _AddMemberDialogState extends State<_AddMemberDialog> {
  CustomCharacterModel? _selectedCharacter;
  String? _selectedRole;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final availableCharacters = context.select(
      (CrewDetailsBloc bloc) => bloc.state.availableCharacters,
    );
    final character = _selectedCharacter;
    final role = _selectedRole;

    return AlertDialog(
      title: Text(l10n.addMember),
      content: SizedBox(
        width: double.maxFinite,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            switch (availableCharacters) {
              null => const Center(child: CircularProgressIndicator()),
              [] => Text(l10n.noCharactersAvailable),
              final characters => Padding(
                padding: const EdgeInsets.symmetric(vertical: 8.0),
                child: DropdownButtonFormField<CustomCharacterModel>(
                  initialValue: _selectedCharacter,
                  isExpanded: true,
                  menuMaxHeight: 300,
                  items: [
                    for (final character in characters)
                      DropdownMenuItem<CustomCharacterModel>(
                        value: character,
                        child: _CharacterDropdownItem(character: character),
                      ),
                  ],
                  onChanged: (character) =>
                      setState(() => _selectedCharacter = character),
                  selectedItemBuilder: (_) => [
                    for (final character in characters)
                      _SelectedCharacterItem(character: character),
                  ],
                  decoration: InputDecoration(
                    labelText: l10n.selectCharacter,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    filled: true,
                  ),
                ),
              ),
            },
            const SizedBox(height: 16),
            CustomDropdown<String>(
              label: l10n.crewRole,
              value: _selectedRole,
              items: widget.availableRoles,
              itemToString: (role) =>
                  CharacterLocalizationMapper.mapOccupationToLocalized(
                    role,
                    l10n,
                  ),
              onChanged: (role) => setState(() => _selectedRole = role),
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: Text(l10n.cancel),
        ),
        ElevatedButton(
          onPressed: character != null && role != null
              ? () => Navigator.of(
                  context,
                ).pop(AddCrewMember(character: character, roleKey: role))
              : null,
          child: Text(l10n.add),
        ),
      ],
    );
  }
}

class _SelectedCharacterItem extends StatelessWidget {
  const _SelectedCharacterItem({required this.character});

  final CustomCharacterModel character;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        CircleAvatarAtom(
          imageUrl: character.image.isNotEmpty ? character.image : null,
          radius: 12,
        ),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            character.name,
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
            overflow: TextOverflow.ellipsis,
            maxLines: 1,
          ),
        ),
      ],
    );
  }
}

class _CharacterDropdownItem extends StatelessWidget {
  const _CharacterDropdownItem({required this.character});

  final CustomCharacterModel character;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final occupations = character.occupation
        .map(
          (occ) =>
              CharacterLocalizationMapper.mapOccupationToLocalized(occ, l10n),
        )
        .take(2)
        .join(', ');

    return Container(
      constraints: const BoxConstraints(maxHeight: 60),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 4.0),
        child: Row(
          children: [
            CircleAvatarAtom(
              imageUrl: character.image.isNotEmpty ? character.image : null,
              radius: 16,
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    character.name,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 13,
                    ),
                    overflow: TextOverflow.ellipsis,
                    maxLines: 1,
                  ),
                  if (occupations.isNotEmpty)
                    Text(
                      occupations,
                      style: TextStyle(
                        fontSize: 11,
                        color: Theme.of(context).colorScheme.onSurfaceVariant,
                      ),
                      overflow: TextOverflow.ellipsis,
                      maxLines: 1,
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
