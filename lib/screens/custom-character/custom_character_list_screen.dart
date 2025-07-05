// Developed by Randerson Mayllon
// Copyright © 2022.

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:opfan/core/models/custom_character_model.dart';
import 'package:opfan/core/repository/custom_character_repository.dart';
import 'package:opfan/screens/custom-character/blocs/custom_character_bloc.dart';
import 'package:opfan/screens/custom-character/create_custom_character_screen.dart';

import 'package:opfan/widgets/molecules/default_app_bar.dart';
import 'package:opfan/widgets/organisms/custom_character_grid_list.dart';

class CustomCharacterListScreen extends StatelessWidget {
  const CustomCharacterListScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => CustomCharacterBloc(
        customCharacterService: CustomCharacterService(),
      ),
      child: Scaffold(
        appBar: DefaultAppBar(
          title: const Text('Meus Personagens'),
          actions: [
            IconButton(
              onPressed: () => _navigateToCreateCharacter(context),
              icon: const Icon(Icons.add),
              tooltip: 'Criar novo personagem',
            ),
          ],
        ),
        body: CustomCharacterGridList(
          onCharacterTap: (character) => _onCharacterTap(context, character),
          onCharacterEdit: (character) => _onCharacterEdit(context, character),
        ),
        floatingActionButton: FloatingActionButton(
          onPressed: () => _navigateToCreateCharacter(context),
          child: const Icon(Icons.add),
        ),
      ),
    );
  }

  static void _navigateToCreateCharacter(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const CreateCustomCharacterScreen(),
      ),
    );
  }

  static void _onCharacterTap(BuildContext context, CustomCharacterModel character) {
    // TODO: Implementar navegação para detalhes do personagem
    // Por enquanto, apenas mostra um snackbar
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Visualizando ${character.name}'),
        duration: const Duration(seconds: 2),
      ),
    );
  }

  static void _onCharacterEdit(BuildContext context, CustomCharacterModel character) {
    // TODO: Implementar navegação para edição do personagem
    // Por enquanto, apenas mostra um snackbar
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Editando ${character.name}'),
        duration: const Duration(seconds: 2),
      ),
    );
  }
} 