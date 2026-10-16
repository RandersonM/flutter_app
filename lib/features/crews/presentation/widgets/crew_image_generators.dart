import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:opfan/features/crews/bloc/index.dart';
import 'package:opfan/l10n/app_localizations.dart';
import 'package:opfan/shared/utils/app_semantic_colors.dart';
import 'package:opfan/shared/widgets/atoms/app_icon.dart';
import 'package:phosphoricons_flutter/phosphoricons_flutter.dart';

import 'crew_image_generator_section.dart';

/// Jolly Roger and boat generators shared by the create and edit screens,
/// driving the [CrewImageCubit] provided above them.
class CrewImageGenerators extends StatefulWidget {
  const CrewImageGenerators({
    super.key,
    required this.nameController,
    required this.descriptionController,
    required this.tags,
    required this.boatNameField,
  });

  final TextEditingController nameController;
  final TextEditingController descriptionController;
  final List<String> tags;
  final Widget boatNameField;

  @override
  State<CrewImageGenerators> createState() => _CrewImageGeneratorsState();
}

class _CrewImageGeneratorsState extends State<CrewImageGenerators> {
  final _jollyRogerPromptController = TextEditingController();
  final _boatPromptController = TextEditingController();

  @override
  void dispose() {
    _jollyRogerPromptController.dispose();
    _boatPromptController.dispose();
    super.dispose();
  }

  void _generate(CrewImageKind kind) {
    final loc = AppLocalizations.of(context)!;
    final prompt = switch (kind) {
      CrewImageKind.jollyRoger => _jollyRogerPromptController,
      CrewImageKind.boat => _boatPromptController,
    }.text.trim();

    if (prompt.isEmpty) {
      _showSnack(switch (kind) {
        CrewImageKind.jollyRoger => loc.generatePirateFlagPrompt,
        CrewImageKind.boat => loc.generateBoatPrompt,
      }, Theme.of(context).semanticColors.warning);
      return;
    }

    final name = widget.nameController.text;
    final description = widget.descriptionController.text;
    context.read<CrewImageCubit>().generate(
      kind,
      crewName: name.isNotEmpty ? name : loc.defaultCrewName,
      prompt: prompt,
      tags: widget.tags,
      description: description.isEmpty ? null : description,
    );
  }

  void _showSnack(String message, Color background) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), backgroundColor: background),
    );
  }

  void _onOutcome(BuildContext context, CrewImageState state) {
    final loc = AppLocalizations.of(context)!;
    final theme = Theme.of(context);

    switch (state.outcome) {
      case CrewImageGenerated(kind: CrewImageKind.jollyRoger):
        _showSnack(
          loc.pirateFlagGeneratedSuccess,
          theme.semanticColors.success,
        );
      case CrewImageGenerated(kind: CrewImageKind.boat):
        _showSnack(loc.boatGeneratedSuccess, theme.semanticColors.success);
      case CrewImageGenerationFailed():
        _showSnack(loc.imageGenerationError, theme.colorScheme.error);
      case null:
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context)!;

    return BlocConsumer<CrewImageCubit, CrewImageState>(
      listenWhen: (previous, current) =>
          current.outcome != null && current.outcome != previous.outcome,
      listener: _onOutcome,
      builder: (context, state) => Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        spacing: 16,
        children: [
          CrewImageGeneratorSection(
            icon: const AppIcon(PhosphorIconsRegular.flag),
            title: loc.pirateFlagLabel,
            promptController: _jollyRogerPromptController,
            promptHint: loc.flagPromptHint,
            generateLabel: loc.generateFlagLabel,
            isGenerating: state.isGenerating(CrewImageKind.jollyRoger),
            onGenerate: () => _generate(CrewImageKind.jollyRoger),
            imageUrl: state.jollyRogerUrl,
            previewTitle: loc.pirateFlagTitle,
          ),
          CrewImageGeneratorSection(
            icon: const AppIcon(PhosphorIconsRegular.boat),
            title: loc.crewShipLabel,
            promptController: _boatPromptController,
            promptHint: loc.boatPromptHint,
            generateLabel: loc.generateBoatLabel,
            isGenerating: state.isGenerating(CrewImageKind.boat),
            onGenerate: () => _generate(CrewImageKind.boat),
            imageUrl: state.boatUrl,
            previewTitle: loc.crewBoatTitle,
            extraField: widget.boatNameField,
          ),
        ],
      ),
    );
  }
}
