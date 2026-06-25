// Developed by Randerson Mayllon
// Copyright © 2025.

import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter/foundation.dart';

import 'package:opfan/core/models/one_piece/custom_character_model.dart';
import 'package:opfan/features/home/data/repository/featured_character_repository_interface.dart';

abstract class CharactersState extends Equatable {
  const CharactersState();

  @override
  List<Object?> get props => [];
}

class CharactersInitial extends CharactersState {}

class CharactersLoading extends CharactersState {
  final List<CustomCharacterModel> characters;
  final bool isLoadingMore;

  const CharactersLoading(
      {required this.characters, required this.isLoadingMore});

  @override
  List<Object?> get props => [characters, isLoadingMore];
}

class CharactersLoaded extends CharactersState {
  final List<CustomCharacterModel> characters;
  final bool hasMoreData;

  const CharactersLoaded({
    required this.characters,
    required this.hasMoreData,
  });

  @override
  List<Object?> get props => [characters, hasMoreData];
}

class CharactersError extends CharactersState {
  final String message;
  final List<CustomCharacterModel> characters;

  const CharactersError({
    required this.message,
    required this.characters,
  });

  @override
  List<Object?> get props => [message, characters];
}

class CharactersCubit extends Cubit<CharactersState> {
  CharactersCubit(this.backend) : super(CharactersInitial());

  final IFeaturedCharacterRepository backend;
  List<CustomCharacterModel> _characters = [];

  List<CustomCharacterModel> get characters =>
      List<CustomCharacterModel>.from(_characters);
  bool get hasMoreData {
    // With CustomCharacterRepository, we load all characters at once
    // so there's no more data after the first load
    return _characters.isEmpty;
  }

  bool isLoading() {
    final result = state is CharactersLoading;
    return result;
  }

  Future<void> fetchData() async {
    if (isLoading() || !hasMoreData) {
      return;
    }

    final isInitialFetch = _characters.isEmpty;

    emit(CharactersLoading(
      characters: _characters,
      isLoadingMore: !isInitialFetch,
    ));

    try {
      // Get all One Piece characters from global collection
      _characters = await backend.getAllOnePieceCharacters();

      await Future.delayed(const Duration(seconds: 1));

      final newHasMoreData = hasMoreData;

      emit(CharactersLoaded(
        characters: _characters,
        hasMoreData: newHasMoreData,
      ));
    } catch (e) {
      debugPrint('CharactersCubit: Error - $e');
      emit(CharactersError(
        message: e.toString(),
        characters: _characters,
      ));
    }
  }

  void reset() {
    _characters = [];
    emit(CharactersInitial());
  }
}
