// Developed by Randerson Mayllon
// Copyright © 2022.

import 'package:flutter/material.dart';
import 'package:opfan/core/models/one_piece/crew_model.dart';
import 'package:opfan/core/models/one_piece/custom_character_model.dart';
import 'package:opfan/core/repository/custom_character_repository.dart';
import 'package:opfan/core/repository/crew_repository.dart';
import 'package:opfan/utils/app_routes.dart';
import 'package:opfan/utils/constants.dart';
import 'package:opfan/l10n/app_localizations.dart';
import 'package:opfan/widgets/molecules/default_app_bar.dart';
import 'package:opfan/widgets/atoms/custom_dropdown.dart';
import 'package:opfan/widgets/atoms/circle_avatar.dart';
import 'widgets/crew_header.dart';
import 'widgets/crew_statistics.dart';
import 'widgets/crew_members_list.dart';
import 'widgets/crew_tags_section.dart';
import 'widgets/crew_info_section.dart';
import 'widgets/crew_boat_section.dart';
import 'package:opfan/core/utils/character_localization_mapper.dart';

class CrewDetailsScreen extends StatefulWidget {
  final CrewModel crew;

  const CrewDetailsScreen({
    Key? key,
    required this.crew,
  }) : super(key: key);

  @override
  State<CrewDetailsScreen> createState() => _CrewDetailsScreenState();
}

class _CrewDetailsScreenState extends State<CrewDetailsScreen> {
  late CrewModel _crew = widget.crew;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: theme.colorScheme.surface,
      appBar: DefaultAppBar(
        title: Text(_crew.name),
        actions: [
          IconButton(
            onPressed: _onEditCrew,
            icon: const Icon(Icons.edit),
            tooltip: l10n.edit,
          ),
          IconButton(
            onPressed: _onDeleteCrew,
            icon: const Icon(Icons.delete, color: Colors.red),
            tooltip: l10n.delete,
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(Constants.margin),
        child: Column(
          spacing: Constants.margin * 2,
          children: [
            CrewHeader(
              crew: _crew,
              onEdit: _onEditCrew,
            ),
            
            CrewStatistics(crew: _crew),
            
            CrewMembersList(
              crew: _crew,
              onMemberTap: _onMemberTap,
            ),
              
            CrewBoatSection(crew: _crew),
            CrewTagsSection(crew: _crew),
            CrewInfoSection(crew: _crew),
            
            const SizedBox(height: Constants.margin * 10),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _onAddMember,
        backgroundColor: theme.colorScheme.primary,
        foregroundColor: Colors.white,
        icon: const Icon(Icons.person_add),
        label: const Text('Adicionar Membro'),
      ),
    );
  }

  void _onEditCrew() {  
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Editar tripulação: ${_crew.name}'),
        backgroundColor: Theme.of(context).colorScheme.primary,
      ),
    );
  }

  void _onDeleteCrew() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Confirmar exclusão'),
        content: Text(
          'Tem certeza que deseja excluir a tripulação "${_crew.name}"? Esta ação não pode ser desfeita.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancelar'),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              _confirmDeleteCrew();
            },
            style: TextButton.styleFrom(
              foregroundColor: Colors.red,
            ),
            child: const Text('Excluir'),
          ),
        ],
      ),
    );
  }

  void _confirmDeleteCrew() async {
    try {
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => const Center(
          child: CircularProgressIndicator(),
        ),
      );

      final crewRepository = CrewRepository();
      await crewRepository.deleteCrew(_crew.id!);

      if (!mounted) return;
      Navigator.of(context).pop(); 

      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Tripulação "${_crew.name}" excluída'),
              backgroundColor: Colors.red,
            ),
          );
        }
      });

      Navigator.of(context).pop({'action': 'deleted', 'crewId': _crew.id});
    } catch (e) {
      if (!mounted) return;
      Navigator.of(context).pop(); 
      
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Erro ao excluir tripulação: $e'),
              backgroundColor: Colors.red,
            ),
          );
        }
      });
    }
  }

  void _onAddMember() {
    _showAddMemberDialog();
  }

  void _showAddMemberDialog() {
    final l10n = AppLocalizations.of(context)!;

    final allRoles = [
      l10n.helmsman,
      l10n.captain,
      l10n.viceCaptain,
      l10n.navigator,
      l10n.cook,
      l10n.doctor,
      l10n.musician,
      l10n.carpenter,
      l10n.sharpshooter,
      l10n.archaeologist,
      l10n.boatswain,
    ];

    final filledRoles = _crew.rolesFilled
        .map((roleKey) =>
            CharacterLocalizationMapper.mapOccupationToLocalized(roleKey, l10n))
        .toSet();
    final availableRoles =
        allRoles.where((role) => !filledRoles.contains(role)).toList();

    if (availableRoles.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content:  Text('Todas as roles já estão preenchidas'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    CustomCharacterModel? selectedCharacter;
    String? selectedRole;

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          title: const Text('Adicionar Membro'),
          content: SizedBox(
            width: double.maxFinite,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                FutureBuilder<List<CustomCharacterModel>>(
                  future: _getAvailableCharacters(),
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const Center(child: CircularProgressIndicator());
                    }

                    if (snapshot.hasError) {
                      return Text('Erro:  [${snapshot.error}');
                    }

                    final availableCharacters = snapshot.data ?? [];
                    
                    if (availableCharacters.isEmpty) {
                      return const Text('Nenhum personagem disponível para adicionar');
                    }

                    return Padding(
                      padding: const EdgeInsets.symmetric(vertical: 8.0),
                      child: DropdownButtonFormField<CustomCharacterModel>(
                        value: selectedCharacter,
                        isExpanded: true,
                        menuMaxHeight: 300,
                        items: availableCharacters.map((character) {
                          return DropdownMenuItem<CustomCharacterModel>(
                            value: character,
                            child: _buildCharacterDropdownItem(character, l10n),
                          );
                        }).toList(),
                        onChanged: (character) {
                          if (mounted) {
                            setState(() {
                              selectedCharacter = character;
                            });
                          }
                        },
                        selectedItemBuilder: (BuildContext context) {
                          return availableCharacters.map<Widget>((character) {
                            return _buildSelectedCharacterItem(character);
                          }).toList();
                        },
                        decoration: InputDecoration(
                          labelText: 'Personagem',
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                          filled: true,
                          fillColor: Colors.grey[50],
                        ),
                      ),
                    );
                  },
                ),
                const SizedBox(height: 16),
                CustomDropdown<String>(
                  label: 'Role',
                  value: selectedRole,
                  items: availableRoles,
                  itemToString: (role) => role,
                  onChanged: (role) {
                    if (mounted) {
                      setState(() {
                        selectedRole = role;
                      });
                    }
                  },
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Cancelar'),
            ),
            ElevatedButton(
              onPressed: selectedCharacter != null && selectedRole != null
                  ? () async {
                      Navigator.of(context).pop();
                      await _addMemberToCrew(
                          selectedCharacter!, selectedRole!, l10n);
                    }
                  : null,
              child: const Text('Adicionar'),
            ),
          ],
        ),
      ),
    );
  }

  Future<List<CustomCharacterModel>> _getAvailableCharacters() async {
    try {
      final allCharacters = await CustomCharacterRepository().getUserCustomCharacters();
      
      if (allCharacters.isEmpty) {
        return [];
      }

      final allCrews = await CrewRepository().getUserCrews();
      
      final usedCharacterIds = <String>{};
      
      for (final crew in allCrews) {
        for (final member in crew.members) {
          usedCharacterIds.add(member.characterId);
        }
      }
      
      final availableCharacters = allCharacters
          .where((character) => !usedCharacterIds.contains(character.id))
          .toList();
      
      return availableCharacters;
    } catch (e) {
      return [];
    }
  }

  Widget _buildSelectedCharacterItem(CustomCharacterModel character) {
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
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 14,
            ),
            overflow: TextOverflow.ellipsis,
            maxLines: 1,
          ),
        ),
      ],
    );
  }

  Widget _buildCharacterDropdownItem(
      CustomCharacterModel character, AppLocalizations l10n) {
    final occupations = character.occupation
        .map((occ) =>
            CharacterLocalizationMapper.mapOccupationToLocalized(occ, l10n))
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
                        color: Colors.grey[600],
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

  Future<void> _addMemberToCrew(
    CustomCharacterModel character,
    String translatedRole,
    AppLocalizations l10n,
  ) async {
    try {
      final roleKey = _getRoleKeyFromLocalized(translatedRole, l10n);

      final newMember = CrewMember(
        characterId: character.id!,
        name: character.name,
        nickname: character.nickname,
        role: roleKey,
        bounty: character.bounty,
      );

      final updatedMembers = List<CrewMember>.from(_crew.members)..add(newMember);
      final updatedRolesFilled = List<String>.from(_crew.rolesFilled)..add(roleKey);

      final updatedCrew = _crew.copyWith(
        members: updatedMembers,
        rolesFilled: updatedRolesFilled,
      );

      final crewRepository = CrewRepository();
      await crewRepository.updateCrew(_crew.id!, updatedCrew);

      final updatedCharacter = character.copyWith(crew: _crew.name);
      final customCharacterRepository = CustomCharacterRepository();
      await customCharacterRepository.updateCustomCharacter(character.id!, updatedCharacter);

      if (mounted) {
        setState(() {
          _crew = updatedCrew;
        });
      }

      if (!mounted) return;
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('${character.name} adicionado como $translatedRole'),
              backgroundColor: Colors.green,
            ),
          );
        }
      });
    } catch (e) {
      if (!mounted) return;
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Erro ao adicionar membro: $e'),
              backgroundColor: Colors.red,
            ),
          );
        }
      });
    }
  }

  String _getRoleKeyFromLocalized(String localizedRole, AppLocalizations l10n) {
    switch (localizedRole) {
      case var v when v == l10n.helmsman:
        return 'helmsman';
      case var v when v == l10n.captain:
        return 'captain';
      case var v when v == l10n.viceCaptain:
        return 'viceCaptain';
      case var v when v == l10n.navigator:
        return 'navigator';
      case var v when v == l10n.cook:
        return 'cook';
      case var v when v == l10n.doctor:
        return 'doctor';
      case var v when v == l10n.musician:
        return 'musician';
      case var v when v == l10n.carpenter:
        return 'carpenter';
      case var v when v == l10n.sharpshooter:
        return 'sharpshooter';
      case var v when v == l10n.archaeologist:
        return 'archaeologist';
      case var v when v == l10n.boatswain:
        return 'boatswain';
      default:
        return '';
    }
  }

  void _onMemberTap(CrewMember member) async {
    try {
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => const Center(
          child: CircularProgressIndicator(),
        ),
      );

      final customCharacterRepository = CustomCharacterRepository();
      final character = await customCharacterRepository.getCustomCharacter(member.characterId);

      if (!mounted) return;
      Navigator.of(context).pop();

      if (character != null) {
        Navigator.pushNamed(context, AppRoutes.characterDetails,
            arguments: character);
        
      } else {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('Personagem "${member.name}" não encontrado'),
                backgroundColor: Colors.orange,
              ),
            );
          }
        });
      }
    } catch (e) {
      if (!mounted) return;
      Navigator.of(context).pop();
      
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Erro ao carregar personagem: $e'),
              backgroundColor: Colors.red,
            ),
          );
        }
      });
    }
  }
}
