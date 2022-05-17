// Developed by Randerson Mayllon
// Copyright © 2022.

import 'package:simple_app/core/models/one_piece/character.dart';
import 'package:simple_app/core/repositories/one_piece/characters_repo_impl.dart';

class CharactersRepo {
  CharactersRepoImpl charactersRepo = CharactersRepoImpl();

  int getTotalCount() => charactersRepo.totalCount;

  Future<List<Character>> getCharactersList(int page) =>
      charactersRepo.fetch(page);

  Future<List<Character>> getAllCharacters() => charactersRepo.fetchAll();
}
