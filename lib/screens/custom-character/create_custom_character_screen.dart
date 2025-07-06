import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:opfan/core/models/one_piece/custom_character_model.dart';
import 'package:opfan/core/models/one_piece/devil_fruit.dart';
import 'package:opfan/core/models/one_piece/crew_model.dart';
import 'package:opfan/core/services/service_locator.dart';
import 'package:opfan/l10n/app_localizations.dart';
import 'package:opfan/screens/custom-character/blocs/index.dart';
import 'package:opfan/widgets/molecules/default_app_bar.dart';
import '../../widgets/organisms/character_form.dart';
import '../../widgets/organisms/form_actions.dart';
import '../../utils/zodiac_icons.dart';

class CreateCustomCharacterScreen extends StatefulWidget {
  const CreateCustomCharacterScreen({Key? key}) : super(key: key);

  @override
  State<CreateCustomCharacterScreen> createState() => _CreateCustomCharacterScreenState();
}

class _CreateCustomCharacterScreenState extends State<CreateCustomCharacterScreen> {
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
      final devilFruitService = getIt.devilFruitService;
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
      final crewRepository = getIt.crewRepository;
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
    return BlocProvider<CustomCharacterBloc>(
      create: (context) => CustomCharacterBloc(
        customCharacterService: getIt.customCharacterService,
        crewRepository: getIt.crewRepository,
      ),
      child: Builder(
        builder: (context) => Scaffold(
          appBar: DefaultAppBar(
            title: Text(AppLocalizations.of(context)!.createCustomCharacterTitle),
            leading: IconButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              icon: const Icon(Icons.arrow_back),
            ),
          ),
          body: BlocListener<CustomCharacterBloc, CustomCharacterState>(
            listenWhen: (previous, current) {
              return current is CustomCharacterCreated || 
                     (current is CustomCharacterError && !current.message.contains('mas houve um erro ao atualizar a lista'));
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
                          color: Theme.of(context).primaryColor.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              AppLocalizations.of(context)!.createCustomCharacterTitle,
                              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                                fontWeight: FontWeight.bold,
                                color: Theme.of(context).primaryColor,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              AppLocalizations.of(context)!.createCustomCharacterSubtitle,
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
                            if (!_selectedAffiliations.contains(affiliation)) {
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
                            if (_selectedOccupations.length < 3 && !_selectedOccupations.contains(occupation)) {
                              _selectedOccupations.add(occupation);
                            }
                          });
                        },
                        onOccupationDeselected: (occupation) {
                          setState(() {
                            _selectedOccupations.remove(occupation);
                          });
                        },
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
        ),
      ),
    );
  }

  void _submitForm(BuildContext context) {
    if (_formKey.currentState!.validate()) {
      final newCharacter = CustomCharacterModel(
        name: _nameController.text.trim(),
        nickname: _nicknameController.text.trim().isNotEmpty 
            ? _nicknameController.text.trim() 
            : null,
        devilFruit: _selectedDevilFruit?.romanName,
        haki: _selectedHaki.isNotEmpty ? _selectedHaki : null,
        affiliations: _selectedAffiliations,
        image: _imageUrlController.text.trim().isNotEmpty 
            ? _imageUrlController.text.trim()
            : 'https://via.placeholder.com/300x400/FF6B6B/FFFFFF?text=Personagem+Customizado',
        occupation: _selectedOccupations,
        bounty: _bountyController.text.trim(),
        signo: _birthDateController.text.trim().isNotEmpty 
            ? _calculateSignoFromBirthDate(_birthDateController.text.trim())
            : null,
        crew: _selectedCrewId != null
            ? _availableCrews
                .firstWhere((crew) => crew.id == _selectedCrewId)
                .name
            : null,
        status: _selectedStatus,
        age: _birthDateController.text.trim().isNotEmpty 
            ? _calculateAgeFromBirthDate(_birthDateController.text.trim())
            : null,
        description: _descriptionController.text.trim().isNotEmpty 
            ? _descriptionController.text.trim() 
            : null,
      );
      
      context.read<CustomCharacterBloc>().add(CreateCustomCharacter(
            newCharacter,
            crewId: _selectedCrewId,
            crewRole: _selectedCrewRole,
          ));
    }
  }

  void _cancelForm() {
    Navigator.of(context).pop();
  }

  int? _calculateAgeFromBirthDate(String birthDateString) {
    final birthDate = ZodiacIcons.parseDateFromString(birthDateString);
    if (birthDate != null) {
      return ZodiacIcons.calculateAge(birthDate);
    }
    return null;
  }

  String? _calculateSignoFromBirthDate(String birthDateString) {
    final birthDate = ZodiacIcons.parseDateFromString(birthDateString);
    if (birthDate != null) {
      return ZodiacIcons.getZodiacSignFromDate(birthDate);
    }
    return null;
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
              Navigator.of(context).pop(); 
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

