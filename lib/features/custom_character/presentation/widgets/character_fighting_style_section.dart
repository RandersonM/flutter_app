import 'package:flutter/material.dart';
import 'package:opfan/core/utils/character_localization_mapper.dart';
import 'package:opfan/l10n/app_localizations.dart';
import 'package:opfan/features/duels/data/models/fighting_style_model.dart';
import 'package:opfan/shared/utils/constants.dart';

class CharacterFightingStyleSection extends StatefulWidget {
  final FightingStyleModel? fightingStyle;
  final void Function(FightingStyleModel?) onFightingStyleChanged;

  const CharacterFightingStyleSection({
    super.key,
    this.fightingStyle,
    required this.onFightingStyleChanged,
  });

  @override
  State<CharacterFightingStyleSection> createState() =>
      _CharacterFightingStyleSectionState();
}

class _CharacterFightingStyleSectionState
    extends State<CharacterFightingStyleSection> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _weaponController = TextEditingController();
  final TextEditingController _attackController = TextEditingController();
  String? _selectedType;
  List<String> _weapons = [];
  List<String> _attacks = [];

  @override
  void initState() {
    super.initState();
    _initializeFields();
  }

  void _initializeFields() {
    if (widget.fightingStyle != null) {
      _nameController.text = widget.fightingStyle!.name ?? '';
      _selectedType = widget.fightingStyle!.type;
      _weapons = widget.fightingStyle!.weapons ?? [];
      _attacks = widget.fightingStyle!.attacks ?? [];
    }
  }

  @override
  void didUpdateWidget(CharacterFightingStyleSection oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.fightingStyle != oldWidget.fightingStyle) {
      _initializeFields();
    }
  }

  void _updateFightingStyle() {
    if (_selectedType != null) {
      final fightingStyle = FightingStyleModel(
        name: _nameController.text.trim().isEmpty
            ? null
            : _nameController.text.trim(),
        type: _selectedType!,
        weapons: _weapons.isEmpty ? null : _weapons,
        attacks: _attacks.isEmpty ? null : _attacks,
      );
      widget.onFightingStyleChanged(fightingStyle);
    } else {
      widget.onFightingStyleChanged(null);
    }
  }

  void _addWeapon() {
    if (_weaponController.text.trim().isNotEmpty) {
      setState(() {
        _weapons.add(_weaponController.text.trim());
        _weaponController.clear();
      });
      _updateFightingStyle();
    }
  }

  void _removeWeapon(String weapon) {
    setState(() {
      _weapons.remove(weapon);
    });
    _updateFightingStyle();
  }

  void _addAttack() {
    if (_attackController.text.trim().isNotEmpty) {
      setState(() {
        _attacks.add(_attackController.text.trim());
        _attackController.clear();
      });
      _updateFightingStyle();
    }
  }

  void _removeAttack(String attack) {
    setState(() {
      _attacks.remove(attack);
    });
    _updateFightingStyle();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(Constants.margin * 2),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Estilo de Luta',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const SizedBox(height: Constants.margin * 2),

            // Nome do estilo (opcional)
            TextFormField(
              controller: _nameController,
              decoration: InputDecoration(
                labelText: l10n.styleName,
                hintText: l10n.threeSwordsStyleHint,
                border: const OutlineInputBorder(),
              ),
              onChanged: (_) => _updateFightingStyle(),
            ),
            const SizedBox(height: Constants.margin * 2),

            // Tipo do estilo (obrigatório)
            DropdownButtonFormField<String>(
              initialValue: _selectedType,
              decoration: InputDecoration(
                labelText: l10n.fightingType,
                border: const OutlineInputBorder(),
              ),
              items: CharacterLocalizationMapper.getFightingTypes().map((type) {
                return DropdownMenuItem(
                  value: type,
                  child: Text(CharacterLocalizationMapper.getFightingTypeLabel(
                      type, l10n)),
                );
              }).toList(),
              onChanged: (value) {
                setState(() {
                  _selectedType = value;
                });
                _updateFightingStyle();
              },
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Tipo de luta é obrigatório';
                }
                return null;
              },
            ),
            const SizedBox(height: Constants.margin * 2),

            // Armas
            Text(
              'Armas',
              style: Theme.of(context).textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const SizedBox(height: Constants.margin),

            Row(
              children: [
                Expanded(
                  child: TextFormField(
                    controller: _weaponController,
                    decoration: InputDecoration(
                      labelText: l10n.addWeapon,
                      border: const OutlineInputBorder(),
                    ),
                    onFieldSubmitted: (_) => _addWeapon(),
                  ),
                ),
                const SizedBox(width: Constants.margin),
                ElevatedButton(
                  onPressed: _addWeapon,
                  child: Text(l10n.addTag),
                ),
              ],
            ),

            if (_weapons.isNotEmpty) ...[
              const SizedBox(height: Constants.margin),
              Wrap(
                spacing: Constants.margin,
                runSpacing: Constants.margin,
                children: _weapons.map((weapon) {
                  return Chip(
                    label: Text(weapon),
                    onDeleted: () => _removeWeapon(weapon),
                  );
                }).toList(),
              ),
            ],

            const SizedBox(height: Constants.margin * 2),

            // Ataques
            Text(
              'Ataques',
              style: Theme.of(context).textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const SizedBox(height: Constants.margin),

            Row(
              children: [
                Expanded(
                  child: TextFormField(
                    controller: _attackController,
                    decoration: InputDecoration(
                      labelText: l10n.addAttack,
                      border: const OutlineInputBorder(),
                    ),
                    onFieldSubmitted: (_) => _addAttack(),
                  ),
                ),
                const SizedBox(width: Constants.margin),
                ElevatedButton(
                  onPressed: _addAttack,
                  child: Text(l10n.addAction),
                ),
              ],
            ),

            if (_attacks.isNotEmpty) ...[
              const SizedBox(height: Constants.margin),
              Wrap(
                spacing: Constants.margin,
                runSpacing: Constants.margin,
                children: _attacks.map((attack) {
                  return Chip(
                    label: Text(attack),
                    onDeleted: () => _removeAttack(attack),
                  );
                }).toList(),
              ),
            ],
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    _nameController.dispose();
    _weaponController.dispose();
    _attackController.dispose();
    super.dispose();
  }
}
