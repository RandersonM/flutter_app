import 'package:opfan/shared/widgets/atoms/app_icon.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:opfan/features/crews/bloc/index.dart';
import 'package:opfan/shared/utils/constants.dart';
import 'package:opfan/shared/utils/theme.dart';
import 'package:opfan/core/auth/blocs/index.dart';
import 'package:opfan/core/services/crew_image_service.dart';
import 'package:opfan/shared/widgets/atoms/clickable_image.dart';
import 'package:opfan/l10n/app_localizations.dart';
import 'package:opfan/shared/widgets/molecules/default_app_bar.dart';

class CreateCrewScreen extends StatefulWidget {
  const CreateCrewScreen({super.key});

  @override
  State<CreateCrewScreen> createState() => _CreateCrewScreenState();
}

class _CreateCrewScreenState extends State<CreateCrewScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _jollyRogerPromptController = TextEditingController();
  final _boatPromptController = TextEditingController();
  final _boatNameController = TextEditingController();
  final List<String> _tags = [];

  final CrewImageService _crewImageService = CrewImageService();
  String? _generatedJollyRogerUrl;
  String? _generatedBoatUrl;
  bool _isGeneratingJollyRoger = false;
  bool _isGeneratingBoat = false;

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
            labelText: AppLocalizations.of(context)!.tagNameLabel,
            hintText: AppLocalizations.of(context)!.crewTagsHint,
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
    if (_jollyRogerPromptController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(AppLocalizations.of(context)!.promptPirateFlag),
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
            : 'Tripulação',
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
            content: Text(AppLocalizations.of(context)!.flagGeneratedSuccess),
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
            content: Text(AppLocalizations.of(context)!
                .errorGeneratingFlag(e.toString())),
            backgroundColor: Theme.of(context).colorScheme.error,
          ),
        );
      }
    }
  }

  Future<void> _generateBoat() async {
    if (_boatPromptController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(AppLocalizations.of(context)!.promptShip),
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
            : 'Tripulação',
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
            content: Text(AppLocalizations.of(context)!.shipGeneratedSuccess),
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
            content: Text(AppLocalizations.of(context)!
                .errorGeneratingShip(e.toString())),
            backgroundColor: Theme.of(context).colorScheme.error,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final authState = context.read<AuthBloc>().state;
    final userId = authState is AuthAuthenticated ? authState.user.uid : null;

    return BlocProvider(
      create: (context) => CreateCrewBloc(userId: userId),
      child: Builder(
        builder: (context) {
          return Scaffold(
            appBar: DefaultAppBar(
              title: Text(AppLocalizations.of(context)!.createCrewTitle),
            ),
            body: BlocListener<CreateCrewBloc, CreateCrewState>(
              listener: (context, state) {
                if (state is CreateCrewSuccess) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(
                          AppLocalizations.of(context)!.crewCreatedSuccess),
                      backgroundColor: AppColors.green[500]!,
                    ),
                  );
                  Navigator.pop(
                      context, {'action': 'created', 'crewId': state.crewId});
                } else if (state is CreateCrewFailure) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(AppLocalizations.of(context)!
                          .errorPrefix(state.error)),
                      backgroundColor: Theme.of(context).colorScheme.error,
                    ),
                  );
                }
              },
              child: Container(
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.surfaceContainer,
                ),
                child: SafeArea(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.all(16.0),
                    child: Form(
                      key: _formKey,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          Container(
                            height: 120,
                            decoration: BoxDecoration(
                              color: Theme.of(context)
                                  .colorScheme
                                  .primaryContainer,
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(
                                color: AppColors.purple[600]!,
                              ),
                            ),
                            child: Column(
                              spacing: Constants.margin,
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                const AppIcon(
                                  PhosphorIconsRegular.sailboat,
                                  size: 48,
                                ),
                                Text(
                                  'Nova Tripulação',
                                  style: Theme.of(context)
                                      .textTheme
                                      .titleMedium
                                      ?.copyWith(
                                        fontSize: 16,
                                        fontWeight: FontWeight.w500,
                                      ),
                                ),
                              ],
                            ),
                          ),

                          const SizedBox(height: 24),

                          TextFormField(
                            controller: _nameController,
                            decoration: InputDecoration(
                              labelText: AppLocalizations.of(context)!
                                  .crewNameRequired,
                              hintText:
                                  AppLocalizations.of(context)!.customCrewHint,
                              prefixIcon:
                                  const AppIcon(PhosphorIconsRegular.flag),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                              filled: true,
                            ),
                            style: TextStyle(color: AppColors.purple[600]!),
                            validator: (value) {
                              if (value == null || value.trim().isEmpty) {
                                return 'Nome é obrigatório';
                              }
                              if (value.trim().length < 3) {
                                return 'Nome deve ter pelo menos 3 caracteres';
                              }
                              return null;
                            },
                          ),

                          const SizedBox(height: 16),

                          TextFormField(
                            controller: _descriptionController,
                            maxLines: 3,
                            decoration: InputDecoration(
                              labelText: 'Descrição',
                              hintText: AppLocalizations.of(context)!
                                  .crewDescriptionHint,
                              prefixIcon:
                                  const AppIcon(PhosphorIconsRegular.fileText),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                              filled: true,
                            ),
                            style: TextStyle(color: AppColors.purple[600]!),
                          ),

                          const SizedBox(height: 16),

                          Container(
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              color: Theme.of(context)
                                  .colorScheme
                                  .primaryContainer,
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(
                                color: AppColors.purple[600]!,
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
                                      'Tags',
                                      style: Theme.of(context)
                                          .textTheme
                                          .titleMedium
                                          ?.copyWith(
                                            fontSize: 16,
                                            fontWeight: FontWeight.w500,
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
                                      'Nenhuma tag adicionada',
                                      style: Theme.of(context)
                                          .textTheme
                                          .bodyMedium
                                          ?.copyWith(
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
                                        label: Text(tag),
                                        deleteIcon: const AppIcon(
                                          PhosphorIconsRegular.x,
                                          size: 18,
                                        ),
                                        onDeleted: () => _removeTag(tag),
                                      );
                                    }).toList(),
                                  ),
                                ],
                              ],
                            ),
                          ),

                          const SizedBox(height: 24),

                          // Seção de Geração de Jolly Roger
                          Container(
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              color: Theme.of(context)
                                  .colorScheme
                                  .primaryContainer,
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(
                                color: AppColors.purple[600]!,
                              ),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    const AppIcon(
                                      PhosphorIconsRegular.flag,
                                    ),
                                    const SizedBox(width: 8),
                                    Text(
                                      AppLocalizations.of(context)!
                                          .pirateFlagLabel,
                                      style: const TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 12),
                                TextFormField(
                                  controller: _jollyRogerPromptController,
                                  decoration: InputDecoration(
                                    labelText: AppLocalizations.of(context)!
                                        .aiPromptLabel,
                                    hintText:
                                        'Ex: caveira com espadas cruzadas, bandeira negra',
                                    border: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    filled: true,
                                  ),
                                  style:
                                      TextStyle(color: AppColors.purple[600]!),
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
                                                          Color>(Colors.white),
                                                ),
                                              )
                                            : const AppIcon(
                                                PhosphorIconsRegular.magicWand),
                                        label: Text(_isGeneratingJollyRoger
                                            ? 'Gerando...'
                                            : 'Gerar Bandeira'),
                                        style: ElevatedButton.styleFrom(
                                          backgroundColor:
                                              AppColors.purple[500],
                                          foregroundColor: Colors.white,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                                if (_generatedJollyRogerUrl != null) ...[
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
                                        imageUrl: _generatedJollyRogerUrl!,
                                        height: 120,
                                        fit: BoxFit.cover,
                                        borderRadius: BorderRadius.circular(8),
                                        title: 'Bandeira Pirata',
                                      ),
                                    ),
                                  ),
                                ],
                              ],
                            ),
                          ),

                          const SizedBox(height: 16),

                          // Seção de Geração de Barco
                          Container(
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              color: Theme.of(context)
                                  .colorScheme
                                  .primaryContainer,
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(
                                color: AppColors.purple[600]!,
                              ),
                            ),
                            child: Column(
                              spacing: Constants.margin,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    const AppIcon(
                                      PhosphorIconsRegular.boat,
                                    ),
                                    Text(
                                      AppLocalizations.of(context)!
                                          .crewShipLabel,
                                      style: Theme.of(context)
                                          .textTheme
                                          .titleMedium
                                          ?.copyWith(
                                            fontSize: 16,
                                            fontWeight: FontWeight.w500,
                                          ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 12),
                                TextFormField(
                                  controller: _boatNameController,
                                  decoration: InputDecoration(
                                    labelText: AppLocalizations.of(context)!
                                        .shipNameLabel,
                                    hintText: AppLocalizations.of(context)!
                                        .merryShipHint,
                                    prefixIcon: const AppIcon(
                                        PhosphorIconsRegular.boat),
                                    border: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    filled: true,
                                  ),
                                  style:
                                      TextStyle(color: AppColors.purple[600]!),
                                ),
                                const SizedBox(height: 12),
                                TextFormField(
                                  controller: _boatPromptController,
                                  decoration: InputDecoration(
                                    labelText: AppLocalizations.of(context)!
                                        .aiPromptLabel,
                                    hintText:
                                        'Ex: navio pirata de madeira com velas pretas',
                                    border: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    filled: true,
                                  ),
                                  style:
                                      TextStyle(color: AppColors.purple[600]!),
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
                                                          Color>(Colors.white),
                                                ),
                                              )
                                            : const AppIcon(
                                                PhosphorIconsRegular.magicWand),
                                        label: Text(_isGeneratingBoat
                                            ? 'Gerando...'
                                            : 'Gerar Barco'),
                                        style: ElevatedButton.styleFrom(
                                          backgroundColor:
                                              AppColors.purple[500],
                                          foregroundColor: Colors.white,
                                        ),
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
                                        borderRadius: BorderRadius.circular(8),
                                        title: 'Barco da Tripulação',
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
                              color:
                                  AppColors.purple[200]!.withValues(alpha: 0.1),
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(
                                color: AppColors.purple[600]!,
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
                                    'Use prompts descritivos para gerar imagens únicas da sua tripulação. '
                                    'As imagens geradas serão salvas automaticamente.',
                                    style: TextStyle(
                                      color: AppColors.purple[400]!,
                                      fontSize: 14,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),

                          const SizedBox(height: 32),

                          BlocBuilder<CreateCrewBloc, CreateCrewState>(
                            builder: (context, state) {
                              return ElevatedButton(
                                onPressed: state is CreateCrewLoading
                                    ? null
                                    : () {
                                        if (_formKey.currentState!.validate()) {
                                          context.read<CreateCrewBloc>().add(
                                                CreateCrewSubmitted(
                                                  name: _nameController.text,
                                                  description:
                                                      _descriptionController
                                                              .text.isEmpty
                                                          ? null
                                                          : _descriptionController
                                                              .text,
                                                  jollyRogerUrl:
                                                      _generatedJollyRogerUrl,
                                                  boatImageUrl:
                                                      _generatedBoatUrl,
                                                  tags: _tags,
                                                  boatName: _boatNameController
                                                          .text.isEmpty
                                                      ? null
                                                      : _boatNameController
                                                          .text,
                                                ),
                                              );
                                        }
                                      },
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: AppColors.purple[500],
                                  foregroundColor: Colors.white,
                                  padding:
                                      const EdgeInsets.symmetric(vertical: 16),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                ),
                                child: state is CreateCrewLoading
                                    ? const SizedBox(
                                        height: 20,
                                        width: 20,
                                        child: CircularProgressIndicator(
                                          strokeWidth: 2,
                                          valueColor:
                                              AlwaysStoppedAnimation<Color>(
                                            Colors.white,
                                          ),
                                        ),
                                      )
                                    : Text(
                                        AppLocalizations.of(context)!
                                            .createCrewTitle,
                                        style: const TextStyle(
                                          fontSize: 16,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                              );
                            },
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
}
