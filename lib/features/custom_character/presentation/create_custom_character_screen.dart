import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:opfan/features/custom_character/data/models/custom_character_model.dart';
import 'package:opfan/features/devil_fruit/data/models/devil_fruit.dart';
import 'package:opfan/features/crews/data/models/crew_model.dart';
import 'package:opfan/features/duels/data/models/fighting_style_model.dart';
import 'package:opfan/app/di/injection.dart';
import 'package:opfan/features/custom_character/data/repository/custom_character_repository_interface.dart';
import 'package:opfan/features/crews/data/repository/crew_repository_interface.dart';
import 'package:opfan/core/services/index.dart';
import 'package:opfan/l10n/app_localizations.dart';
import 'package:opfan/features/custom_character/bloc/index.dart';
import 'package:opfan/shared/widgets/molecules/default_app_bar.dart';
import 'package:opfan/shared/widgets/organisms/character_form.dart';
import 'package:opfan/shared/widgets/organisms/form_actions.dart';
import 'package:opfan/shared/utils/zodiac_icons.dart';
import 'package:opfan/core/utils/character_localization_mapper.dart';

class CreateCustomCharacterScreen extends StatefulWidget {
  const CreateCustomCharacterScreen({super.key});

  @override
  State<CreateCustomCharacterScreen> createState() =>
      _CreateCustomCharacterScreenState();
}

class _CreateCustomCharacterScreenState
    extends State<CreateCustomCharacterScreen> {
  final _formKey = GlobalKey<FormState>();

  final _nameController = TextEditingController();
  final _nicknameController = TextEditingController();
  final _birthDateController = TextEditingController();
  final _bountyController = TextEditingController();
  final _imageUrlController = TextEditingController();
  final _descriptionController = TextEditingController();

  String? _selectedStatus;
  List<String> _selectedOccupations = [];
  final List<String> _selectedHaki = [];
  List<String> _selectedAffiliations = [];
  DevilFruit? _selectedDevilFruit;
  List<DevilFruit> _devilFruits = [];
  List<CrewModel> _availableCrews = [];
  String? _selectedCrewId;
  String? _selectedCrewRole;
  String? _selectedRace = 'human';
  FightingStyleModel? _fightingStyle;

  @override
  void initState() {
    super.initState();
    _selectedAffiliations = ['independent'];
    _selectedOccupations = [];
    _loadDevilFruits();
    _loadCrews();
  }

  Future<void> _loadDevilFruits() async {
    try {
      final devilFruitService = getIt<IDevilFruitService>();
      final fruits = await devilFruitService.fetchAll();
      setState(() {
        _devilFruits = fruits;
      });
    } catch (e) {
      setState(() {
        _devilFruits = [];
      });
    }
  }

  Future<void> _loadCrews() async {
    try {
      final crewRepository = getIt<ICrewRepository>();
      final crews = await crewRepository.getUserCrews();
      setState(() {
        _availableCrews = crews;
      });
    } catch (e) {
      setState(() {
        _availableCrews = [];
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => CustomCharacterBloc(
        customCharacterService: getIt<ICustomCharacterRepository>(),
        crewRepository: getIt<ICrewRepository>(),
      ),
      child: Builder(
        builder: (context) {
          return Scaffold(
            appBar: DefaultAppBar(
              title: Text(
                AppLocalizations.of(context)!.createCustomCharacterTitle,
              ),
            ),
            body: BlocListener<CustomCharacterBloc, CustomCharacterState>(
              listenWhen: (previous, current) {
                return current is CustomCharacterCreated ||
                    (current is CustomCharacterError &&
                        !current.message.contains(
                          'mas houve um erro ao atualizar a lista',
                        ));
              },
              listener: (context, state) {
                if (state is CustomCharacterCreated) {
                  _showSuccessDialog(context);
                } else if (state is CustomCharacterError) {
                  _showErrorDialog(context, state.message);
                }
              },
              child: BlocBuilder<CustomCharacterBloc, CustomCharacterState>(
                builder: (context, state) {
                  final isLoading = state is CustomCharacterCreating;

                  return SingleChildScrollView(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      children: [
                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: Theme.of(
                              context,
                            ).primaryColor.withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                AppLocalizations.of(
                                  context,
                                )!.createCustomCharacterTitle,
                                style: Theme.of(context).textTheme.headlineSmall
                                    ?.copyWith(
                                      fontWeight: FontWeight.bold,
                                      color: Theme.of(context).primaryColor,
                                    ),
                              ),
                              const SizedBox(height: 8),
                              Text(
                                AppLocalizations.of(
                                  context,
                                )!.createCustomCharacterSubtitle,
                                style: Theme.of(context).textTheme.bodyMedium,
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 24),
                        CharacterForm(
                          formKey: _formKey,
                          nameController: _nameController,
                          nicknameController: _nicknameController,
                          birthDateController: _birthDateController,
                          devilFruits: _devilFruits,
                          selectedDevilFruit: _selectedDevilFruit,
                          onDevilFruitChanged: (fruit) {
                            setState(() {
                              _selectedDevilFruit = fruit;
                            });
                          },
                          availableCrews: _availableCrews,
                          selectedCrewId: _selectedCrewId,
                          onCrewChanged: (crewId) {
                            setState(() {
                              _selectedCrewId = crewId;
                              if (crewId == null) {
                                _selectedCrewRole = null;
                              }
                            });
                          },
                          selectedCrewRole: _selectedCrewRole,
                          onCrewRoleChanged: (role) {
                            setState(() {
                              _selectedCrewRole = role;
                            });
                          },
                          bountyController: _bountyController,
                          imageUrlController: _imageUrlController,
                          descriptionController: _descriptionController,
                          selectedStatus: _selectedStatus,
                          selectedHaki: _selectedHaki,
                          selectedAffiliations: _selectedAffiliations,
                          selectedOccupations: _selectedOccupations,
                          onStatusChanged: (status) {
                            setState(() {
                              _selectedStatus = status;
                            });
                          },
                          onHakiSelected: (haki) {
                            setState(() {
                              if (!_selectedHaki.contains(haki)) {
                                _selectedHaki.add(haki);
                              }
                            });
                          },
                          onHakiDeselected: (haki) {
                            setState(() {
                              _selectedHaki.remove(haki);
                            });
                          },
                          onAffiliationSelected: (affiliation) {
                            setState(() {
                              if (!_selectedAffiliations.contains(
                                affiliation,
                              )) {
                                _selectedAffiliations.add(affiliation);
                              }
                            });
                          },
                          onAffiliationDeselected: (affiliation) {
                            setState(() {
                              _selectedAffiliations.remove(affiliation);
                            });
                          },
                          onOccupationSelected: (occupation) {
                            setState(() {
                              if (_selectedOccupations.length < 3 &&
                                  !_selectedOccupations.contains(occupation)) {
                                _selectedOccupations.add(occupation);
                              }
                            });
                          },
                          onOccupationDeselected: (occupation) {
                            setState(() {
                              _selectedOccupations.remove(occupation);
                            });
                          },
                          selectedRace: _selectedRace,
                          onRaceChanged: (race) {
                            setState(() {
                              _selectedRace = race;
                            });
                          },
                          fightingStyle: _fightingStyle,
                          onFightingStyleChanged: (fightingStyle) {
                            setState(() {
                              _fightingStyle = fightingStyle;
                            });
                          },
                          showAiGenerator: true,
                        ),
                        const SizedBox(height: 24),
                        FormActions(
                          onSave: () => _submitForm(context),
                          onCancel: _cancelForm,
                          isLoading: isLoading,
                        ),
                        const SizedBox(height: 24),
                      ],
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
      final birthDate = _birthDateController.text.trim().isNotEmpty
          ? ZodiacIcons.parseDateFromString(_birthDateController.text.trim())
          : null;

      // Mapear os dados de Haki do formato localizado para o formato salvo
      final mappedHaki = _selectedHaki.map((localizedHaki) {
        return CharacterLocalizationMapper.mapLocalizedToHaki(
          localizedHaki,
          AppLocalizations.of(context)!,
        );
      }).toList();

      final newCharacter = CustomCharacterModel(
        name: _nameController.text.trim(),
        nickname: _nicknameController.text.trim().isNotEmpty
            ? _nicknameController.text.trim()
            : null,
        devilFruit: _selectedDevilFruit?.romanName,
        haki: mappedHaki.isNotEmpty ? mappedHaki : null,
        affiliations: _selectedAffiliations,
        image: _imageUrlController.text.trim().isNotEmpty
            ? _imageUrlController.text.trim()
            : 'https://via.placeholder.com/300x400/FF6B6B/FFFFFF?text=Personagem+Customizado',
        occupation: _selectedOccupations,
        fightingStyle: _fightingStyle,
        bounty: _bountyController.text.trim(),
        signo: birthDate != null
            ? ZodiacIcons.getZodiacSignFromDate(birthDate)
            : null,
        crew: _selectedCrewId != null
            ? _availableCrews
                  .firstWhere((crew) => crew.id == _selectedCrewId)
                  .name
            : null,
        status: _selectedStatus,
        race: _selectedRace,
        age: birthDate != null ? ZodiacIcons.calculateAge(birthDate) : null,
        birthDate: birthDate,
        description: _descriptionController.text.trim().isNotEmpty
            ? _descriptionController.text.trim()
            : null,
      );

      debugPrint(
        'CreateCharacter: Character birth date: ${newCharacter.birthDate}',
      );
      debugPrint('CreateCharacter: Character age: ${newCharacter.age}');
      debugPrint('CreateCharacter: Character signo: ${newCharacter.signo}');

      context.read<CustomCharacterBloc>().add(
        CreateCustomCharacter(
          newCharacter,
          crewId: _selectedCrewId,
          crewRole: _selectedCrewRole,
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
        content: Text(l10n.characterCreatedSuccess),
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
        content: Text(l10n.characterCreationError(message)),
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

  @override
  void dispose() {
    _nameController.dispose();
    _nicknameController.dispose();
    _birthDateController.dispose();
    _bountyController.dispose();
    _imageUrlController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }
}
