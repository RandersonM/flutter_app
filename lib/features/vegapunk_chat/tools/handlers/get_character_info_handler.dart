import 'dart:convert';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:opfan/features/home/data/repository/featured_character_repository_interface.dart';
import 'package:opfan/features/custom_character/data/repository/custom_character_repository_interface.dart';

import '../models/tool_call.dart';
import '../models/tool_result.dart';
import '../tool_handler.dart';

/// [ToolHandler] that searches for a character in the featured and custom characters databases.
///
/// Invoked when Gemma emits:
/// ```json
/// {"name": "getCharacterInfo", "arguments": {"characterName": "Luffy"}}
/// ```
class GetCharacterInfoHandler extends ToolHandler {
  GetCharacterInfoHandler({
    required this._featuredCharacterRepository,
    required this._customCharacterRepository,
  });

  final IFeaturedCharacterRepository _featuredCharacterRepository;
  final ICustomCharacterRepository _customCharacterRepository;

  @override
  String get name => 'getCharacterInfo';

  @override
  String get description =>
      'Fetch stats, devil fruit, and lore for a specific One Piece character from the database.';

  @override
  String get descriptionPt =>
      'Busca status, akuma no mi e lore de um personagem específico de One Piece no banco de dados.';

  @override
  Map<String, String> get parameterDescriptions => {
    'characterName':
        'The name of the character to search for (e.g., "Luffy", "Zoro").',
  };

  @override
  Map<String, String> get parameterDescriptionsPt => {
    'characterName':
        'O nome do personagem a ser buscado (ex: "Luffy", "Zoro").',
  };

  @override
  Future<ToolResult> execute(ToolCall call) async {
    debugPrint(
      'GetCharacterInfoHandler: fetching character info for ${call.arguments['characterName']}',
    );

    try {
      final characterName = call.arguments['characterName'] as String?;

      if (characterName == null || characterName.trim().isEmpty) {
        return ToolResult.error(
          toolName: name,
          reason: 'characterName parameter is required.',
        );
      }

      // Search in featured characters (canonical One Piece characters)
      final featuredCharacters = await _featuredCharacterRepository
          .searchOnePieceCharacters(characterName.trim());

      // Search in custom characters (user created characters)
      final customCharacters = await _customCharacterRepository
          .searchCustomCharactersByName(characterName.trim());

      if (featuredCharacters.isEmpty && customCharacters.isEmpty) {
        return ToolResult.success(
          toolName: name,
          content: 'No character found with name "$characterName".',
        );
      }

      final combinedResults = [
        ...featuredCharacters.map((c) => c.toFirestoreWithEnglishKeys()),
        ...customCharacters.map((c) => c.toFirestoreWithEnglishKeys()),
      ];

      // Safely convert Timestamp objects to ISO strings for JSON encoding
      final safeResults = combinedResults.map((map) {
        final newMap = Map<String, dynamic>.from(map);
        newMap.forEach((key, value) {
          if (value is Timestamp) {
            newMap[key] = value.toDate().toIso8601String();
          } else if (value is DateTime) {
            newMap[key] = value.toIso8601String();
          }
        });
        return newMap;
      }).toList();

      return ToolResult.success(
        toolName: name,
        content: jsonEncode({'characters': safeResults}),
      );
    } catch (e) {
      debugPrint('GetCharacterInfoHandler: error — $e');
      return ToolResult.error(toolName: name, reason: e.toString());
    }
  }
}
