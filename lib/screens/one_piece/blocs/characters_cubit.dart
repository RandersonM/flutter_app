// Developed by Randerson Mayllon
// Copyright © 2025.

import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter/foundation.dart';

import 'package:simple_app/core/one_piece/models/character.dart';
import 'package:simple_app/core/services/characters_backend_service.dart';

abstract class CharactersState extends Equatable {
  const CharactersState();

  @override
  List<Object?> get props => [];
}

class CharactersInitial extends CharactersState {}

class CharactersLoading extends CharactersState {
  final List<Character> characters;
  final bool isLoadingMore;

  const CharactersLoading(
      {required this.characters, required this.isLoadingMore});

  @override
  List<Object?> get props => [characters, isLoadingMore];
}

class CharactersLoaded extends CharactersState {
  final List<Character> characters;
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
  final List<Character> characters;

  const CharactersError({
    required this.message,
    required this.characters,
  });

  @override
  List<Object?> get props => [message, characters];
}

class CharactersCubit extends Cubit<CharactersState> {
  CharactersCubit(this.backend) : super(CharactersInitial());

  final CharactersBackendService backend;
  List<Character> _characters = [];
  int _pages = 0;

  List<Character> get characters => List<Character>.from(_characters);
  bool get hasMoreData {
    if (backend.totalCount == 0) {
      return true;
    }

    final result = _characters.length < backend.totalCount;
    return result;
  }

  bool isLoading() {
    final result = state is CharactersLoading;
    return result;
  }

  Future<void> fetchData() async {
    if (isLoading() || !hasMoreData) {
      debugPrint(
          'CharactersCubit: fetchData aborted - isLoading: ${isLoading()}, hasMoreData: $hasMoreData');
      return;
    }

    final isInitialFetch = _characters.isEmpty;

    emit(CharactersLoading(
      characters: _characters,
      isLoadingMore: !isInitialFetch,
    ));

    try {
      _pages += 10;
      _characters = await backend.fetch(_pages);
      debugPrint('CharactersCubit: Fetched ${_characters.length} characters');

      await Future.delayed(const Duration(seconds: 1));

      final newHasMoreData = hasMoreData;

      emit(CharactersLoaded(
        characters: _characters,
        hasMoreData: newHasMoreData,
      ));

      debugPrint('CharactersCubit: Load completed successfully');
    } catch (e) {
      debugPrint('CharactersCubit: Error - $e');
      emit(CharactersError(
        message: e.toString(),
        characters: _characters,
      ));
    }
  }

  void reset() {
    debugPrint('CharactersCubit: Reset called');
    _characters = [];
    _pages = 0;
    emit(CharactersInitial());
  }
}
