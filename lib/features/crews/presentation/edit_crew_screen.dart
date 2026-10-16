import 'package:phosphoricons_flutter/phosphoricons_flutter.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:opfan/features/crews/data/models/crew_model.dart';
import 'package:opfan/l10n/app_localizations.dart';
import 'package:opfan/features/crews/bloc/index.dart';
import 'package:opfan/shared/widgets/atoms/app_icon.dart';
import 'package:opfan/shared/widgets/molecules/default_app_bar.dart';
import 'package:opfan/shared/widgets/organisms/form_actions.dart';
import 'package:opfan/app/di/injection.dart';

import 'widgets/crew_image_generator_section.dart';
import 'widgets/crew_image_generators.dart';
import 'widgets/crew_tags_editor.dart';

class EditCrewScreen extends StatefulWidget {
  final CrewModel crew;

  const EditCrewScreen({super.key, required this.crew});

  @override
  State<EditCrewScreen> createState() => _EditCrewScreenState();
}

class _EditCrewScreenState extends State<EditCrewScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _boatNameController = TextEditingController();
  List<String> _tags = [];

  @override
  void initState() {
    super.initState();
    _populateFormWithCrewData();
  }

  /// Seeds the form from the crew being edited. Runs in [initState] before the
  /// first build, so no setState is needed.
  void _populateFormWithCrewData() {
    final crew = widget.crew;

    _nameController.text = crew.name;
    _descriptionController.text = crew.description ?? '';
    _boatNameController.text = crew.boatName ?? '';
    _tags = List.from(crew.tags);
  }

  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
    _boatNameController.dispose();
    super.dispose();
  }

  void _addTag(String tag) {
    if (!_tags.contains(tag)) {
      setState(() => _tags.add(tag));
    }
  }

  void _removeTag(String tag) {
    setState(() => _tags.remove(tag));
  }

  String? get _descriptionOrNull =>
      _descriptionController.text.isEmpty ? null : _descriptionController.text;

  void _submitForm(BuildContext context) {
    if (!_formKey.currentState!.validate()) return;

    final images = context.read<CrewImageCubit>().state;
    context.read<EditCrewBloc>().add(
      EditCrewSubmitted(
        crewId: widget.crew.id!,
        name: _nameController.text,
        description: _descriptionOrNull,
        jollyRogerUrl: images.jollyRogerUrl,
        boatImageUrl: images.boatUrl,
        tags: _tags,
        boatName: _boatNameController.text.isEmpty
            ? null
            : _boatNameController.text,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final loc = AppLocalizations.of(context)!;

    return MultiBlocProvider(
      providers: [
        BlocProvider(create: (_) => getIt<EditCrewBloc>()),
        BlocProvider(create: (_) => getIt<CrewImageCubit>(param1: widget.crew)),
      ],
      child: Builder(
        builder: (context) {
          return Scaffold(
            backgroundColor: theme.colorScheme.surfaceContainer,
            appBar: DefaultAppBar(title: Text(loc.editCrewTitle)),
            body: BlocListener<EditCrewBloc, EditCrewState>(
              listener: (context, state) {
                if (state is EditCrewSuccess) {
                  _showSuccessDialog(context);
                } else if (state is EditCrewFailure) {
                  _showErrorDialog(context, state.failure);
                }
              },
              child: BlocBuilder<EditCrewBloc, EditCrewState>(
                builder: (context, state) {
                  return SafeArea(
                    child: SingleChildScrollView(
                      padding: const EdgeInsets.all(16.0),
                      child: Form(
                        key: _formKey,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            _EditHeader(subtitle: loc.editCrewSubtitle),
                            const SizedBox(height: 24),
                            _NameField(controller: _nameController),
                            const SizedBox(height: 16),
                            _DescriptionField(
                              controller: _descriptionController,
                            ),
                            const SizedBox(height: 16),
                            CrewTagsEditor(
                              tags: _tags,
                              onAdd: _addTag,
                              onRemove: _removeTag,
                            ),
                            const SizedBox(height: 24),
                            CrewImageGenerators(
                              nameController: _nameController,
                              descriptionController: _descriptionController,
                              tags: _tags,
                              boatNameField: _BoatNameField(
                                controller: _boatNameController,
                              ),
                            ),
                            const SizedBox(height: 24),
                            const CrewImageHelpBanner(
                              icon: AppIcon(PhosphorIconsRegular.info),
                            ),
                            const SizedBox(height: 24),
                            FormActions(
                              onSave: () => _submitForm(context),
                              onCancel: () => Navigator.of(context).pop(),
                              isLoading: state is EditCrewLoading,
                              saveButtonText: loc.update,
                            ),
                            const SizedBox(height: 24),
                          ],
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
          );
        },
      ),
    );
  }

  void _showSuccessDialog(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) => AlertDialog(
        title: Text(l10n.success),
        content: Text(l10n.crewUpdatedSuccess),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(dialogContext).pop();
              Navigator.of(context).pop(true);
            },
            child: Text(l10n.ok),
          ),
        ],
      ),
    );
  }

  void _showErrorDialog(BuildContext context, CrewsFailure failure) {
    final l10n = AppLocalizations.of(context)!;

    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: Text(l10n.error),
        content: Text(switch (failure) {
          CrewsFailure.notFound => l10n.crewNotFoundError,
          _ => l10n.crewUpdateError,
        }),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(),
            child: Text(l10n.ok),
          ),
        ],
      ),
    );
  }
}

class _EditHeader extends StatelessWidget {
  const _EditHeader({required this.subtitle});

  final String subtitle;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: theme.colorScheme.primaryContainer,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        subtitle,
        style: theme.textTheme.titleLarge?.copyWith(
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}

class _NameField extends StatelessWidget {
  const _NameField({required this.controller});

  final TextEditingController controller;

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context)!;

    return TextFormField(
      controller: controller,
      decoration: InputDecoration(
        labelText: loc.crewName,
        hintText: loc.crewNameHint,
        prefixIcon: const AppIcon(PhosphorIconsRegular.flag),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
        filled: true,
      ),
      style: Theme.of(context).textTheme.bodyMedium,
      validator: (value) {
        if (value == null || value.trim().isEmpty) return loc.nameRequired;
        if (value.trim().length < 3) return loc.nameMinLength;
        return null;
      },
    );
  }
}

class _DescriptionField extends StatelessWidget {
  const _DescriptionField({required this.controller});

  final TextEditingController controller;

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context)!;

    return TextFormField(
      controller: controller,
      maxLines: 3,
      decoration: InputDecoration(
        labelText: loc.description,
        hintText: loc.descriptionHint,
        prefixIcon: const AppIcon(PhosphorIconsRegular.fileText),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
        filled: true,
      ),
      style: Theme.of(context).textTheme.bodyMedium,
    );
  }
}

class _BoatNameField extends StatelessWidget {
  const _BoatNameField({required this.controller});

  final TextEditingController controller;

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context)!;

    return TextFormField(
      controller: controller,
      decoration: InputDecoration(
        labelText: loc.crewBoatName,
        hintText: loc.boatNameHint,
        prefixIcon: const AppIcon(PhosphorIconsRegular.boat),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
        filled: true,
      ),
      style: Theme.of(context).textTheme.bodyMedium,
    );
  }
}
