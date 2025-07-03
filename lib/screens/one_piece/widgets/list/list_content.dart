// Developed by Randerson Mayllon
// Copyright © 2022.

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:opfan/screens/one_piece/blocs/characters_cubit.dart';
import 'package:opfan/core/one_piece/models/character.dart';
import 'package:opfan/screens/one_piece/widgets/list/character_grid_list.dart';

class ListContent extends StatefulWidget {
  const ListContent({Key? key}) : super(key: key);

  @override
  State<ListContent> createState() => _ListContentState();
}

class _ListContentState extends State<ListContent> {
  late ScrollController controller;

  void _scrollListener() {
    if (controller.position.pixels == controller.position.maxScrollExtent) {
      final cubit = context.read<CharactersCubit>();
      if (!cubit.isLoading() && cubit.hasMoreData) {
        debugPrint('ListContent: Calling fetchData from scroll');
        cubit.fetchData();
      }
    }
  }

  @override
  void initState() {
    super.initState();
    debugPrint('ListContent: initState called');
    controller = ScrollController()..addListener(_scrollListener);
    
    // Carrega os dados iniciais apenas uma vez
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final cubit = context.read<CharactersCubit>();
      if (cubit.state is CharactersInitial) {
        debugPrint('ListContent: Calling initial fetchData');
        cubit.fetchData();
      }
    });
  }

  @override
  void dispose() {
    controller.removeListener(_scrollListener);
    controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<CharactersCubit, CharactersState>(
      builder: (context, state) {
        if (state is CharactersInitial) {
          return const Center(child: CircularProgressIndicator());
        }

        List<Character> characters = [];
        bool isLoadingMore = false;

        if (state is CharactersLoading) {
          characters = state.characters;
          isLoadingMore = state.isLoadingMore;
        } else if (state is CharactersLoaded) {
          characters = state.characters;
          debugPrint('ListContent: Loaded ${characters.length} characters');
        } else if (state is CharactersError) {
          characters = state.characters;
          debugPrint('ListContent: Error - ${state.message}');
        }

        if (characters.isEmpty && state is CharactersLoading) {
          return const Center(child: CircularProgressIndicator());
        }

        return Column(
          children: <Widget>[
            Expanded(
              child: CharacterGridList(
                characters: characters,
                controller: controller,
              ),
            ),
            if (isLoadingMore)
              const Padding(
                padding: EdgeInsets.all(16.0),
                child: CircularProgressIndicator(),
              ),
          ],
        );
      },
    );
  }
}

