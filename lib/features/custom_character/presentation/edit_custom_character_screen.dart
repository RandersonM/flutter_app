import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:opfan/features/custom_character/data/character_form_choices.dart';
import 'package:opfan/features/custom_character/data/models/custom_character_model.dart';
import 'package:opfan/features/devil_fruit/data/models/devil_fruit.dart';
import 'package:opfan/features/crews/data/models/crew_model.dart';
import 'package:opfan/features/duels/data/models/fighting_style_model.dart';
import 'package:opfan/app/di/injection.dart';
import 'package:opfan/l10n/app_localizations.dart';
import 'package:opfan/features/custom_character/bloc/index.dart';
import 'package:opfan/shared/widgets/molecules/default_app_bar.dart';
import 'package:opfan/shared/widgets/organisms/character_form.dart';
import 'package:opfan/shared/widgets/organisms/form_actions.dart';
import 'package:opfan/shared/utils/zodiac_icons.dart';
import 'package:opfan/core/utils/character_localization_mapper.dart';

import 'custom_character_failure_message.dart';

class EditCustomCharacterScreen extends StatefulWidget {
  final CustomCharacterModel character;

  const EditCustomCharacterScreen({super.key, required this.character});

  @override
  State<EditCustomCharacterScreen> createState() =>
      _EditCustomCharacterScreenState();
}

class _EditCustomCharacterScreenState extends State<EditCustomCharacterScreen> {
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
  String? _devilFruitName;
  List<DevilFruit> _devilFruits = [];
  List<CrewModel> _availableCrews = [];
  String? _crewName;
  String? _selectedCrewRole;
  String? _memberCrewId;
  String? _heldCrewRole;
  bool _crewChanged = false;
  String? _selectedRace = 'human';
  FightingStyleModel? _fightingStyle;
  bool _hasMappedHaki = false;

  @override
  void initState() {
    super.initState();
    _populateFormWithCharacterData();
  }

  void _populateFormWithCharacterData() {
    final character = widget.character;

    _nameController.text = character.name;
    _nicknameController.text = character.nickname ?? '';
    _bountyController.text = character.bounty;
    _imageUrlController.text = character.image;
    _descriptionController.text = character.description ?? '';
    _selectedStatus = character.status;
    _selectedRace = character.race ?? 'human';
    _fightingStyle = character.fightingStyle;
    _devilFruitName = character.devilFruit;
    _crewName = character.crew;

    _selectedAffiliations = [];
    _selectedOccupations = [];
    _selectedHaki.clear();

    if (character.haki != null) {
      _selectedHaki.addAll(character.haki!);
    }
    if (character.affiliations.isNotEmpty) {
      _selectedAffiliations = List.from(character.affiliations);
    }
    if (character.occupation.isNotEmpty) {
      _selectedOccupations = List.from(character.occupation);
    }

    if (character.birthDate != null) {
      _birthDateController.text =
          '${character.birthDate!.day.toString().padLeft(2, '0')}/${character.birthDate!.month.toString().padLeft(2, '0')}/${character.birthDate!.year}';
    }

    setState(() {});
  }

  void _mapHakiDataIfNeeded() {
    if (!_hasMappedHaki && widget.character.haki != null) {
      _selectedHaki.clear();
      for (final haki in widget.character.haki!) {
        final localizedHaki = CharacterLocalizationMapper.mapHakiToLocalized(
          haki,
          AppLocalizations.of(context)!,
        );
        if (!_selectedHaki.contains(localizedHaki)) {
          _selectedHaki.add(localizedHaki);
        }
      }
      _hasMappedHaki = true;
      setState(() {});
    }
  }

  void _applyFormOptions(CharacterFormOptionsState options) {
    setState(() {
      _devilFruits = options.devilFruits;
      _availableCrews = options.crews;
      if (!_crewChanged) _readMembership(options.crews);
    });
  }

  /// The crew lists the character as a member with its role; the character
  /// itself only stores the crew name.
  void _readMembership(List<CrewModel> crews) {
    for (final crew in crews) {
      final member = crew.members
          .where((member) => member.characterId == widget.character.id)
          .firstOrNull;
      if (member != null) {
        _memberCrewId = crew.id;
        _heldCrewRole = member.role;
        _selectedCrewRole = member.role;
        return;
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    _mapHakiDataIfNeeded();

    return MultiBlocProvider(
      providers: [
        BlocProvider(create: (_) => getIt<CustomCharacterBloc>()),
        BlocProvider(create: (_) => getIt<CharacterFormOptionsCubit>()..load()),
        BlocProvider(create: (_) => getIt<CharacterImageCubit>()),
      ],
      child: BlocListener<CharacterFormOptionsCubit, CharacterFormOptionsState>(
        listener: (_, options) => _applyFormOptions(options),
        child: Builder(
          builder: (context) {
            return Scaffold(
              appBar: DefaultAppBar(
                title: Text(
                  AppLocalizations.of(context)!.editCustomCharacterTitle,
                ),
              ),
              body: BlocListener<CustomCharacterBloc, CustomCharacterState>(
                listenWhen: (previous, current) {
                  return current is CustomCharacterUpdated ||
                      (current is CustomCharacterError &&
                          current.failure !=
                              CustomCharacterFailure.listRefreshFailed);
                },
                listener: (context, state) {
                  if (state is CustomCharacterUpdated) {
                    _showSuccessDialog(context);
                  } else if (state is CustomCharacterError) {
                    _showErrorDialog(context, state.failure);
                  }
                },
                child: BlocBuilder<CustomCharacterBloc, CustomCharacterState>(
                  builder: (context, state) {
                    final isLoading = state is CustomCharacterUpdating;

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
                                  )!.editCustomCharacterTitle,
                                  style: Theme.of(context)
                                      .textTheme
                                      .headlineSmall
                                      ?.copyWith(
                                        fontWeight: FontWeight.bold,
                                        color: Theme.of(context).primaryColor,
                                      ),
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  AppLocalizations.of(
                                    context,
                                  )!.editCustomCharacterSubtitle,
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
                            selectedDevilFruit: devilFruitNamed(
                              _devilFruits,
                              _devilFruitName,
                            ),
                            onDevilFruitChanged: (fruit) {
                              setState(() {
                                _devilFruitName = fruit?.romanName;
                              });
                            },
                            availableCrews: _availableCrews,
                            selectedCrewId: crewIdNamed(
                              _availableCrews,
                              _crewName,
                            ),
                            onCrewChanged: (crewId) {
                              setState(() {
                                _crewChanged = true;
                                _crewName = crewNameWithId(
                                  _availableCrews,
                                  crewId,
                                );
                                _selectedCrewRole =
                                    crewId != null && crewId == _memberCrewId
                                    ? _heldCrewRole
                                    : null;
                              });
                            },
                            selectedCrewRole: _selectedCrewRole,
                            onCrewRoleChanged: (role) {
                              setState(() {
                                _crewChanged = true;
                                _selectedCrewRole = role;
                              });
                            },
                            heldCrewRole:
                                crewIdNamed(_availableCrews, _crewName) ==
                                    _memberCrewId
                                ? _heldCrewRole
                                : null,
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
                                    !_selectedOccupations.contains(
                                      occupation,
                                    )) {
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
                            saveButtonText: AppLocalizations.of(
                              context,
                            )!.update,
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

      final updatedCharacter = CustomCharacterModel(
        id: widget.character.id,
        name: _nameController.text.trim(),
        nickname: _nicknameController.text.trim().isNotEmpty
            ? _nicknameController.text.trim()
            : null,
        devilFruit: _devilFruitName,
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
        crew: _crewName,
        status: _selectedStatus,
        race: _selectedRace,
        age: birthDate != null ? ZodiacIcons.calculateAge(birthDate) : null,
        birthDate: birthDate,
        description: _descriptionController.text.trim().isNotEmpty
            ? _descriptionController.text.trim()
            : null,
      );

      context.read<CustomCharacterBloc>().add(
        UpdateCustomCharacter(
          widget.character.id!,
          updatedCharacter,
          crewAssignment: _crewChanged
              ? CrewAssignment(
                  crewId: crewIdNamed(_availableCrews, _crewName),
                  role: _selectedCrewRole,
                )
              : null,
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
        content: Text(l10n.characterUpdatedSuccess),
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

  void _showErrorDialog(BuildContext context, CustomCharacterFailure failure) {
    final l10n = AppLocalizations.of(context)!;

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(l10n.error),
        content: Text(customCharacterFailureMessage(l10n, failure)),
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
