import 'package:opfan/shared/widgets/atoms/app_icon.dart';
import 'package:phosphoricons_flutter/phosphoricons_flutter.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:opfan/core/models/one_piece/crew_model.dart';
import 'package:opfan/l10n/app_localizations.dart';
import 'package:opfan/features/crews/bloc/index.dart';
import 'package:opfan/shared/widgets/molecules/default_app_bar.dart';
import 'package:opfan/shared/widgets/organisms/form_actions.dart';
import 'package:opfan/shared/utils/theme.dart';
import 'package:opfan/core/services/index.dart';
import 'package:opfan/shared/widgets/atoms/clickable_image.dart';

class EditCrewScreen extends StatefulWidget {
  final CrewModel crew;

  const EditCrewScreen({
    super.key,
    required this.crew,
  });

  @override
  State<EditCrewScreen> createState() => _EditCrewScreenState();
}

class _EditCrewScreenState extends State<EditCrewScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _jollyRogerPromptController = TextEditingController();
  final _boatPromptController = TextEditingController();
  final _boatNameController = TextEditingController();
  List<String> _tags = [];

  final ICrewImageService _crewImageService = CrewImageService();
  String? _generatedJollyRogerUrl;
  String? _generatedBoatUrl;
  bool _isGeneratingJollyRoger = false;
  bool _isGeneratingBoat = false;

  @override
  void initState() {
    super.initState();
    _populateFormWithCrewData();
  }

  void _populateFormWithCrewData() {
    final crew = widget.crew;

    _nameController.text = crew.name;
    _descriptionController.text = crew.description ?? '';
    _boatNameController.text = crew.boatName ?? '';
    _tags = List.from(crew.tags);
    _generatedJollyRogerUrl = crew.jollyRogerUrl;
    _generatedBoatUrl = crew.boatImageUrl;

    setState(() {});
  }

  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
    _jollyRogerPromptController.dispose();
    _boatPromptController.dispose();
    _boatNameController.dispose();
    super.dispose();
  }

  void _addTag(String tag) {
    if (tag.isNotEmpty && !_tags.contains(tag)) {
      setState(() {
        _tags.add(tag);
      });
    }
  }

  void _removeTag(String tag) {
    setState(() {
      _tags.remove(tag);
    });
  }

  void _showAddTagDialog() {
    final tagController = TextEditingController();
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(AppLocalizations.of(context)!.addTag),
        content: TextField(
          controller: tagController,
          decoration: InputDecoration(
            labelText: AppLocalizations.of(context)!.tagName,
            hintText: AppLocalizations.of(context)!.tagNameHint,
          ),
          autofocus: true,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(AppLocalizations.of(context)!.cancel),
          ),
          ElevatedButton(
            onPressed: () {
              _addTag(tagController.text.trim());
              Navigator.pop(context);
            },
            child: Text(AppLocalizations.of(context)!.add),
          ),
        ],
      ),
    );
  }

  Future<void> _generateJollyRoger() async {
    final l10n = AppLocalizations.of(context)!;
    if (_jollyRogerPromptController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(l10n.generatePirateFlagPrompt),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    setState(() {
      _isGeneratingJollyRoger = true;
    });

    try {
      final imageUrl = await _crewImageService.generateJollyRogerImage(
        crewName: _nameController.text.isNotEmpty
            ? _nameController.text
            : AppLocalizations.of(context)!.crewName,
        prompt: _jollyRogerPromptController.text.trim(),
        tags: _tags,
        description: _descriptionController.text.isNotEmpty
            ? _descriptionController.text
            : null,
      );

      setState(() {
        _generatedJollyRogerUrl = imageUrl;
        _isGeneratingJollyRoger = false;
      });

      if (imageUrl != null && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(l10n.pirateFlagGeneratedSuccess),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      setState(() {
        _isGeneratingJollyRoger = false;
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(l10n.pirateFlagGenerationError(e.toString())),
            backgroundColor: Theme.of(context).colorScheme.error,
          ),
        );
      }
    }
  }

  Future<void> _generateBoat() async {
    final l10n = AppLocalizations.of(context)!;
    if (_boatPromptController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(l10n.generateBoatPrompt),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    setState(() {
      _isGeneratingBoat = true;
    });

    try {
      final imageUrl = await _crewImageService.generateBoatImage(
        crewName: _nameController.text.isNotEmpty
            ? _nameController.text
            : AppLocalizations.of(context)!.crewName,
        prompt: _boatPromptController.text.trim(),
        tags: _tags,
        description: _descriptionController.text.isNotEmpty
            ? _descriptionController.text
            : null,
      );

      setState(() {
        _generatedBoatUrl = imageUrl;
        _isGeneratingBoat = false;
      });

      if (imageUrl != null && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(l10n.boatGeneratedSuccess),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      setState(() {
        _isGeneratingBoat = false;
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(l10n.boatGenerationError(e.toString())),
            backgroundColor: Theme.of(context).colorScheme.error,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return BlocProvider(
      create: (context) => EditCrewBloc(),
      child: Builder(
        builder: (context) {
          return Scaffold(
            backgroundColor: theme.colorScheme.surfaceContainer,
            appBar: DefaultAppBar(
              title: Text(AppLocalizations.of(context)!.editCrewTitle),
            ),
            body: BlocListener<EditCrewBloc, EditCrewState>(
              listenWhen: (previous, current) {
                return current is EditCrewSuccess ||
                    (current is EditCrewFailure &&
                        !current.error.contains(
                            'mas houve um erro ao atualizar a lista'));
              },
              listener: (context, state) {
                if (state is EditCrewSuccess) {
                  _showSuccessDialog(context);
                } else if (state is EditCrewFailure) {
                  _showErrorDialog(context, state.error);
                }
              },
              child: BlocBuilder<EditCrewBloc, EditCrewState>(
                builder: (context, state) {
                  final isLoading = state is EditCrewLoading;
                  return SafeArea(
                    child: SingleChildScrollView(
                      padding: const EdgeInsets.all(16.0),
                      child: Form(
                        key: _formKey,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            Container(
                              width: double.infinity,
                              padding: const EdgeInsets.all(16),
                              decoration: BoxDecoration(
                                color: theme.colorScheme.primaryContainer,
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const SizedBox(height: 8),
                                  Text(
                                    AppLocalizations.of(context)!
                                        .editCrewSubtitle,
                                    style: theme.textTheme.titleLarge?.copyWith(
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(height: 24),
                            TextFormField(
                              controller: _nameController,
                              decoration: InputDecoration(
                                labelText:
                                    AppLocalizations.of(context)!.crewName,
                                hintText:
                                    AppLocalizations.of(context)!.crewNameHint,
                                prefixIcon:
                                    const AppIcon(PhosphorIconsRegular.flag),
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                filled: true,
                              ),
                              style: theme.textTheme.bodyMedium,
                              validator: (value) {
                                if (value == null || value.trim().isEmpty) {
                                  return AppLocalizations.of(context)!
                                      .nameRequired;
                                }
                                if (value.trim().length < 3) {
                                  return AppLocalizations.of(context)!
                                      .nameMinLength;
                                }
                                return null;
                              },
                            ),
                            const SizedBox(height: 16),
                            TextFormField(
                              controller: _descriptionController,
                              maxLines: 3,
                              decoration: InputDecoration(
                                labelText:
                                    AppLocalizations.of(context)!.description,
                                hintText: AppLocalizations.of(context)!
                                    .descriptionHint,
                                prefixIcon: const AppIcon(
                                    PhosphorIconsRegular.fileText),
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                filled: true,
                              ),
                              style: theme.textTheme.bodyMedium,
                            ),
                            const SizedBox(height: 16),
                            Container(
                              padding: const EdgeInsets.all(16),
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(
                                  color: Theme.of(context).colorScheme.primary,
                                ),
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      Text(
                                        AppLocalizations.of(context)!.tags,
                                        style: theme.textTheme.titleLarge
                                            ?.copyWith(
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                      IconButton(
                                        onPressed: _showAddTagDialog,
                                        icon: const AppIcon(
                                          PhosphorIconsRegular.plusCircle,
                                        ),
                                      ),
                                    ],
                                  ),
                                  if (_tags.isEmpty)
                                    Padding(
                                      padding: const EdgeInsets.only(top: 8),
                                      child: Text(
                                        AppLocalizations.of(context)!
                                            .noTagsAdded,
                                        style: const TextStyle(
                                          color: Colors.white54,
                                          fontSize: 14,
                                        ),
                                      ),
                                    ),
                                  if (_tags.isNotEmpty) ...[
                                    const SizedBox(height: 8),
                                    Wrap(
                                      spacing: 8,
                                      runSpacing: 8,
                                      children: _tags.map((tag) {
                                        return Chip(
                                          label: Text(tag,
                                              style:
                                                  theme.textTheme.bodyMedium),
                                          deleteIcon: const AppIcon(
                                              PhosphorIconsRegular.x),
                                          onDeleted: () => _removeTag(tag),
                                        );
                                      }).toList(),
                                    ),
                                  ],
                                ],
                              ),
                            ),
                            const SizedBox(height: 24),
                            Container(
                              padding: const EdgeInsets.all(16),
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(
                                  color: Theme.of(context).colorScheme.primary,
                                ),
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    AppLocalizations.of(context)!
                                        .pirateFlagSectionTitle,
                                    style: const TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  const SizedBox(height: 12),
                                  if (_generatedJollyRogerUrl != null) ...[
                                    Container(
                                      height: 120,
                                      decoration: BoxDecoration(
                                        borderRadius: BorderRadius.circular(8),
                                        border: Border.all(
                                            color: Theme.of(context)
                                                .colorScheme
                                                .primary),
                                      ),
                                      child: ClipRRect(
                                        borderRadius: BorderRadius.circular(8),
                                        child: ClickableImage(
                                          imageUrl: _generatedJollyRogerUrl!,
                                          height: 120,
                                          fit: BoxFit.cover,
                                          borderRadius:
                                              BorderRadius.circular(8),
                                          title: AppLocalizations.of(context)!
                                              .pirateFlagTitle,
                                        ),
                                      ),
                                    ),
                                    const SizedBox(height: 12),
                                  ],
                                  TextFormField(
                                    controller: _jollyRogerPromptController,
                                    decoration: InputDecoration(
                                      labelText: AppLocalizations.of(context)!
                                          .aiPromptLabel,
                                      hintText: AppLocalizations.of(context)!
                                          .pirateFlagPromptHint,
                                      border: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(8),
                                      ),
                                      filled: true,
                                    ),
                                    style: theme.textTheme.bodyMedium,
                                  ),
                                  const SizedBox(height: 12),
                                  Row(
                                    children: [
                                      Expanded(
                                        child: ElevatedButton.icon(
                                          onPressed: _isGeneratingJollyRoger
                                              ? null
                                              : _generateJollyRoger,
                                          icon: _isGeneratingJollyRoger
                                              ? const SizedBox(
                                                  width: 16,
                                                  height: 16,
                                                  child:
                                                      CircularProgressIndicator(
                                                    strokeWidth: 2,
                                                    valueColor:
                                                        AlwaysStoppedAnimation<
                                                                Color>(
                                                            Colors.white),
                                                  ),
                                                )
                                              : const AppIcon(
                                                  PhosphorIconsRegular
                                                      .magicWand),
                                          label: Text(_isGeneratingJollyRoger
                                              ? AppLocalizations.of(context)!
                                                  .generatingImage
                                              : AppLocalizations.of(context)!
                                                  .generateFlag),
                                          style: ElevatedButton.styleFrom(),
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(height: 24),
                            Container(
                              padding: const EdgeInsets.all(16),
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(
                                  color: AppColors.purple[600]!,
                                ),
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    AppLocalizations.of(context)!
                                        .crewBoatSectionTitle,
                                    style: theme.textTheme.bodyMedium!.copyWith(
                                      fontSize: 16,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                  const SizedBox(height: 12),
                                  TextFormField(
                                    controller: _boatNameController,
                                    decoration: InputDecoration(
                                      labelText: AppLocalizations.of(context)!
                                          .crewBoatName,
                                      hintText: AppLocalizations.of(context)!
                                          .boatNameHint,
                                      prefixIcon: const AppIcon(
                                          PhosphorIconsRegular.boat),
                                      border: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(12),
                                      ),
                                      filled: true,
                                    ),
                                    style: theme.textTheme.bodyMedium,
                                  ),
                                  const SizedBox(height: 12),
                                  TextFormField(
                                    controller: _boatPromptController,
                                    decoration: InputDecoration(
                                      labelText: AppLocalizations.of(context)!
                                          .aiPromptLabel,
                                      hintText: AppLocalizations.of(context)!
                                          .pirateFlagPromptHint,
                                      border: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(8),
                                      ),
                                      filled: true,
                                    ),
                                    style: theme.textTheme.bodyMedium,
                                  ),
                                  const SizedBox(height: 12),
                                  Row(
                                    children: [
                                      Expanded(
                                        child: ElevatedButton.icon(
                                          onPressed: _isGeneratingBoat
                                              ? null
                                              : _generateBoat,
                                          icon: _isGeneratingBoat
                                              ? const SizedBox(
                                                  width: 16,
                                                  height: 16,
                                                  child:
                                                      CircularProgressIndicator(
                                                    strokeWidth: 2,
                                                    valueColor:
                                                        AlwaysStoppedAnimation<
                                                                Color>(
                                                            Colors.white),
                                                  ),
                                                )
                                              : const AppIcon(
                                                  PhosphorIconsRegular
                                                      .magicWand),
                                          label: Text(_isGeneratingBoat
                                              ? AppLocalizations.of(context)!
                                                  .generatingImage
                                              : AppLocalizations.of(context)!
                                                  .generateBoat),
                                          style: ElevatedButton.styleFrom(),
                                        ),
                                      ),
                                    ],
                                  ),
                                  if (_generatedBoatUrl != null) ...[
                                    const SizedBox(height: 12),
                                    Container(
                                      height: 120,
                                      decoration: BoxDecoration(
                                        borderRadius: BorderRadius.circular(8),
                                        border: Border.all(
                                            color: AppColors.purple[600]!),
                                      ),
                                      child: ClipRRect(
                                        borderRadius: BorderRadius.circular(8),
                                        child: ClickableImage(
                                          imageUrl: _generatedBoatUrl!,
                                          height: 120,
                                          fit: BoxFit.cover,
                                          borderRadius:
                                              BorderRadius.circular(8),
                                          title: AppLocalizations.of(context)!
                                              .boatTitle,
                                        ),
                                      ),
                                    ),
                                  ],
                                ],
                              ),
                            ),
                            const SizedBox(height: 24),
                            Container(
                              padding: const EdgeInsets.all(16),
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(
                                  color: Theme.of(context).colorScheme.primary,
                                ),
                              ),
                              child: Row(
                                children: [
                                  AppIcon(
                                    PhosphorIconsRegular.info,
                                    color: AppColors.purple[600]!,
                                  ),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: Text(
                                      AppLocalizations.of(context)!
                                          .aiPromptInfo,
                                      style: TextStyle(
                                        color: AppColors.purple[400]!,
                                        fontSize: 14,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(height: 24),
                            FormActions(
                              onSave: () => _submitForm(context),
                              onCancel: _cancelForm,
                              isLoading: isLoading,
                              saveButtonText:
                                  AppLocalizations.of(context)!.update,
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

  void _submitForm(BuildContext context) {
    if (_formKey.currentState!.validate()) {
      context.read<EditCrewBloc>().add(
            EditCrewSubmitted(
              crewId: widget.crew.id!,
              name: _nameController.text,
              description: _descriptionController.text.isEmpty
                  ? null
                  : _descriptionController.text,
              jollyRogerUrl: _generatedJollyRogerUrl,
              boatImageUrl: _generatedBoatUrl,
              tags: _tags,
              boatName: _boatNameController.text.isEmpty
                  ? null
                  : _boatNameController.text,
            ),
          );
    }
  }

  void _cancelForm() {
    Navigator.of(context).pop();
  }

  void _showSuccessDialog(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        title: Text(l10n.success),
        content: Text(l10n.crewUpdatedSuccess),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              Navigator.of(context).pop(true);
            },
            child: Text(l10n.ok),
          ),
        ],
      ),
    );
  }

  void _showErrorDialog(BuildContext context, String message) {
    final l10n = AppLocalizations.of(context)!;

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(l10n.error),
        content: Text('${l10n.crewUpdateError}: $message'),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
            },
            child: Text(l10n.ok),
          ),
        ],
      ),
    );
  }
}
