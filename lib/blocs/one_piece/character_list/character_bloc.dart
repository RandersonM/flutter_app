// Developed by Randerson Mayllon
// Copyright © 2022.

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';

import 'package:simple_app/core/models/one_piece/character.dart';
import 'package:simple_app/core/repositories/one_piece/characters_repo.dart';

part 'character_state.dart';
part 'character_event.dart';

class CharacterBloc extends Bloc<CharacterEvent, CharacterState> {
  bool hasMoreData = false;

  CharacterBloc() : super(StateInitial()) {
    final CharactersRepo _apiRepository = CharactersRepo();
    int page = 10;

    on<GetCharactersList>((event, emit) async {
      try {
        emit(StateLoading());
        final mList = await _apiRepository.getCharactersList(page);
        hasMoreData = page <= _apiRepository.getTotalCount();
        if (hasMoreData) page += 10;
        emit(StateLoaded(mList));
      } on Exception {
        emit(const StateError("Failed to fetch data. is your device online?"));
      }
    });
  }
}
