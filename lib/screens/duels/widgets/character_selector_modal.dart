

import 'package:flutter/material.dart';
import 'package:opfan/core/models/one_piece/custom_character_model.dart' show CustomCharacterModel;
import 'package:opfan/l10n/app_localizations.dart';
import 'package:opfan/widgets/atoms/clickable_image.dart' show ClickableImage;

class CharacterSelectionModal extends StatefulWidget {
  final List<CustomCharacterModel> availableCharacters;
  final Function(CustomCharacterModel) onCharacterSelected;
  final String title;

  const CharacterSelectionModal({super.key, 
    required this.availableCharacters,
    required this.onCharacterSelected,
    required this.title,
  });

  @override
  State<CharacterSelectionModal> createState() =>
      CharacterSelectionModalState();
}

class CharacterSelectionModalState extends State<CharacterSelectionModal> {
  late List<CustomCharacterModel> filteredCharacters;
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    filteredCharacters = widget.availableCharacters;
    _searchController.addListener(_onSearchChanged);
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _onSearchChanged() {
    final query = _searchController.text.toLowerCase();
    setState(() {
      if (query.isEmpty) {
        filteredCharacters = widget.availableCharacters;
      } else {
        filteredCharacters = widget.availableCharacters.where((character) {
          return character.name.toLowerCase().contains(query) ||
              (character.nickname?.toLowerCase().contains(query) ?? false);
        }).toList();
      }
    });
  }

  // Separar personagens customizados dos do One Piece
  List<CustomCharacterModel> get customCharacters {
    return filteredCharacters
        .where((character) => character.isCustomCharacter)
        .toList();
  }

  List<CustomCharacterModel> get onePieceCharacters {
    return filteredCharacters
        .where((character) => !character.isCustomCharacter)
        .toList();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Container(
      height: MediaQuery.of(context).size.height * 0.8,
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.onSurface,
        borderRadius: const BorderRadius.vertical(
          top: Radius.circular(20),
        ),
      ),
      child: Column(
        children: [
          Container(
            margin: const EdgeInsets.only(top: 8),
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: Colors.white54,
              borderRadius: BorderRadius.circular(2),
            ),
          ),

          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                Text(
                  widget.title,
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                ),
                const SizedBox(height: 16),

                // Search field
                TextField(
                  controller: _searchController,
                  style: const TextStyle(color: Colors.white),
                  decoration: InputDecoration(
                    hintText: l10n.searchPlaceholder,
                    hintStyle: const TextStyle(color: Colors.white54),
                    prefixIcon: const Icon(Icons.search, color: Colors.white54),
                    filled: true,
                    fillColor: Colors.white.withValues(alpha: 0.1),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide.none,
                    ),
                  ),
                ),
              ],
            ),
          ),

          // Character grid with sections
          Expanded(
            child: filteredCharacters.isEmpty
                ? Center(
                    child: Text(
                      l10n.noResultsFound,
                      style: const TextStyle(color: Colors.white54),
                    ),
                  )
                : ListView(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    children: [
                      // Custom Characters Section
                      if (customCharacters.isNotEmpty) ...[
                        _buildSectionHeader(
                            l10n.customCharacters, Icons.person_add),
                        const SizedBox(height: 8),
                        _buildCharacterGrid(customCharacters),
                        const SizedBox(height: 16),
                      ],

                      // Divider between sections
                      if (customCharacters.isNotEmpty &&
                          onePieceCharacters.isNotEmpty) ...[
                        Container(
                          height: 1,
                          color: Colors.white.withValues(alpha: 0.2),
                          margin: const EdgeInsets.symmetric(vertical: 8),
                        ),
                        const SizedBox(height: 8),
                      ],

                      // One Piece Characters Section
                      if (onePieceCharacters.isNotEmpty) ...[
                        _buildSectionHeader(
                            l10n.onePieceCharacters, Icons.star),
                        const SizedBox(height: 8),
                        _buildCharacterGrid(onePieceCharacters),
                      ],
                    ],
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(String title, IconData icon) {
    return Row(
      children: [
        Icon(
          icon,
          color: Colors.white70,
          size: 20,
        ),
        const SizedBox(width: 8),
        Text(
          title,
          style: const TextStyle(
            color: Colors.white70,
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }

  Widget _buildCharacterGrid(List<CustomCharacterModel> characters) {
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        crossAxisSpacing: 8,
        mainAxisSpacing: 8,
        childAspectRatio: 0.8,
      ),
      itemCount: characters.length,
      itemBuilder: (context, index) {
        final character = characters[index];
        return GestureDetector(
          onTap: () {
            widget.onCharacterSelected(character);
            Navigator.pop(context);
          },
          child: Container(
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(
                color: Colors.white.withValues(alpha: 0.2),
              ),
            ),
            child: Column(
              children: [
                Expanded(
                  flex: 3,
                  child: ClipRRect(
                    borderRadius: const BorderRadius.vertical(
                      top: Radius.circular(8),
                    ),
                    child: ClickableImage(
                      imageUrl: character.image,
                      width: double.infinity,
                      height: double.infinity,
                      fit: BoxFit.cover,
                      enableClick: false,
                    ),
                  ),
                ),
                Expanded(
                  flex: 1,
                  child: Padding(
                    padding: const EdgeInsets.all(4),
                    child: Text(
                      character.name,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                      ),
                      textAlign: TextAlign.center,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
