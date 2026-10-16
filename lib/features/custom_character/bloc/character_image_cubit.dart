import 'dart:math';

import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:opfan/core/services/one_piece/i_character_image_service.dart';

import 'character_image_state.dart';

class CharacterImageCubit extends Cubit<CharacterImageState> {
  CharacterImageCubit({required this._characterImageService})
    : super(const CharacterImageState());

  final ICharacterImageService _characterImageService;
  final _random = Random();
  int _regenerationCount = 0;

  Future<void> generate({
    required String characterName,
    required String prompt,
    required String race,
    List<String>? haki,
    String? status,
    List<String>? occupations,
    bool forceRegeneration = false,
  }) async {
    if (state.isGenerating) return;
    final previousUrl = state.imageUrl;
    emit(CharacterImageState(imageUrl: previousUrl, isGenerating: true));

    try {
      final url = await _characterImageService.generateCharacterImage(
        characterName: characterName,
        prompt: forceRegeneration ? _uniquePrompt(prompt) : prompt,
        race: race,
        haki: haki,
        status: status,
        occupations: occupations,
      );
      if (isClosed) return;
      emit(
        url == null
            ? CharacterImageState(imageUrl: previousUrl, failed: true)
            : CharacterImageState(imageUrl: url),
      );
    } catch (e) {
      debugPrint('CharacterImageCubit: generation failed: $e');
      if (isClosed) return;
      emit(CharacterImageState(imageUrl: previousUrl, failed: true));
    }
  }

  /// The image service caches by prompt, so a regeneration needs a prompt it
  /// has not seen yet.
  String _uniquePrompt(String prompt) {
    _regenerationCount++;
    final timestamp = DateTime.now().millisecondsSinceEpoch;
    return '$prompt [regeneration_${_regenerationCount}_${timestamp}_'
        '${_random.nextInt(1000)}]';
  }
}
