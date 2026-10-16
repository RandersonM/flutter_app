import 'package:phosphoricons_flutter/phosphoricons_flutter.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:opfan/features/crews/bloc/index.dart';
import 'package:opfan/shared/utils/app_semantic_colors.dart';
import 'package:opfan/shared/utils/constants.dart';
import 'package:opfan/core/auth/blocs/index.dart';
import 'package:opfan/l10n/app_localizations.dart';
import 'package:opfan/shared/widgets/atoms/app_icon.dart';
import 'package:opfan/shared/widgets/molecules/default_app_bar.dart';
import 'package:opfan/app/di/injection.dart';

import 'widgets/crew_form_card.dart';
import 'widgets/crew_image_generator_section.dart';
import 'widgets/crew_image_generators.dart';
import 'widgets/crew_tags_editor.dart';

class CreateCrewScreen extends StatefulWidget {
  const CreateCrewScreen({super.key});

  @override
  State<CreateCrewScreen> createState() => _CreateCrewScreenState();
}

class _CreateCrewScreenState extends State<CreateCrewScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _boatNameController = TextEditingController();
  final List<String> _tags = [];

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

  void _submit(BuildContext context) {
    if (!_formKey.currentState!.validate()) return;

    final images = context.read<CrewImageCubit>().state;
    context.read<CreateCrewBloc>().add(
      CreateCrewSubmitted(
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
    final authState = context.read<AuthBloc>().state;
    final userId = authState is AuthAuthenticated ? authState.user.uid : null;
    final loc = AppLocalizations.of(context)!;

    return MultiBlocProvider(
      providers: [
        BlocProvider(create: (_) => getIt<CreateCrewBloc>(param1: userId)),
        BlocProvider(create: (_) => getIt<CrewImageCubit>()),
      ],
      child: Builder(
        builder: (context) {
          return Scaffold(
            appBar: DefaultAppBar(title: Text(loc.createCrewTitle)),
            body: BlocListener<CreateCrewBloc, CreateCrewState>(
              listener: _onStateChange,
              child: ColoredBox(
                color: Theme.of(context).colorScheme.surfaceContainer,
                child: SafeArea(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.all(16.0),
                    child: Form(
                      key: _formKey,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          _Header(title: loc.newCrewTitle),
                          const SizedBox(height: 24),
                          _NameField(controller: _nameController),
                          const SizedBox(height: 16),
                          _DescriptionField(controller: _descriptionController),
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
                          const SizedBox(height: 32),
                          BlocBuilder<CreateCrewBloc, CreateCrewState>(
                            builder: (context, state) => _SubmitButton(
                              isLoading: state is CreateCrewLoading,
                              label: loc.createCrewTitle,
                              onPressed: () => _submit(context),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  void _onStateChange(BuildContext context, CreateCrewState state) {
    final loc = AppLocalizations.of(context)!;
    final theme = Theme.of(context);

    if (state is CreateCrewSuccess) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(loc.crewCreatedSuccess),
          backgroundColor: theme.semanticColors.success,
        ),
      );
      Navigator.pop(context, {'action': 'created', 'crewId': state.crewId});
    } else if (state is CreateCrewFailure) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(loc.errorPrefix(state.error)),
          backgroundColor: theme.colorScheme.error,
        ),
      );
    }
  }
}

class _Header extends StatelessWidget {
  const _Header({required this.title});

  final String title;

  @override
  Widget build(BuildContext context) {
    return CrewFormCard(
      height: 120,
      padding: EdgeInsets.zero,
      child: Column(
        spacing: Constants.margin,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const AppIcon(PhosphorIconsRegular.sailboat, size: 48),
          Text(
            title,
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              fontSize: 16,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
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
        labelText: loc.crewNameRequired,
        hintText: loc.customCrewHint,
        prefixIcon: const AppIcon(PhosphorIconsRegular.flag),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
        filled: true,
      ),
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
        labelText: loc.descriptionLabel,
        hintText: loc.crewDescriptionHint,
        prefixIcon: const AppIcon(PhosphorIconsRegular.fileText),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
        filled: true,
      ),
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
        labelText: loc.shipNameLabel,
        hintText: loc.merryShipHint,
        prefixIcon: const AppIcon(PhosphorIconsRegular.boat),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
        filled: true,
      ),
    );
  }
}

class _SubmitButton extends StatelessWidget {
  const _SubmitButton({
    required this.isLoading,
    required this.label,
    required this.onPressed,
  });

  final bool isLoading;
  final String label;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;

    return ElevatedButton(
      onPressed: isLoading ? null : onPressed,
      style: ElevatedButton.styleFrom(
        backgroundColor: colors.primary,
        foregroundColor: colors.onPrimary,
        padding: const EdgeInsets.symmetric(vertical: 16),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
      child: isLoading
          ? SizedBox(
              height: 20,
              width: 20,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                valueColor: AlwaysStoppedAnimation<Color>(colors.onPrimary),
              ),
            )
          : Text(
              label,
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
    );
  }
}
