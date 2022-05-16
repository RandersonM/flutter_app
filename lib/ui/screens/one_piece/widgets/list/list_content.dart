// Developed by Randerson Mayllon
// Copyright © 2022.

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:simple_app/blocs/one_piece/character_list/character_bloc.dart';

import 'character_grid_list.dart';

class ListContent extends StatefulWidget {
  const ListContent({Key? key}) : super(key: key);

  @override
  State<ListContent> createState() => _ListContentState();
}

class _ListContentState extends State<ListContent> {
  final CharacterBloc _charactersBloc = CharacterBloc();

  @override
  void initState() {
    _charactersBloc.add(const GetCharactersList());

    super.initState();
  }

  Widget _buildLoading() => const Center(child: CircularProgressIndicator());

  Widget _buildCharacterList() {
    return Container(
      margin: const EdgeInsets.all(8.0),
      child: BlocProvider(
        create: (_) => _charactersBloc,
        child: BlocListener<CharacterBloc, CharacterState>(
          listener: (context, state) {
            if (state is StateError) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(state.message!),
                ),
              );
            }
          },
          child: BlocBuilder<CharacterBloc, CharacterState>(
            builder: (BuildContext context, CharacterState state) {
              if (state is StateInitial) {
                return _buildLoading();
              } else if (state is StateLoaded) {
                return Column(
                  children: <Widget>[
                    Expanded(
                        child: NotificationListener<ScrollNotification>(
                            onNotification: (ScrollNotification scrollInfo) {
                              if (state is! StateLoading &&
                                  scrollInfo.metrics.pixels ==
                                      scrollInfo.metrics.maxScrollExtent) {
                                _charactersBloc.add(const GetCharactersList());
                              }
                              return true;
                            },
                            child: CharacterGridList(
                                characters: state.loadState))),
                    if (state is StateLoading)
                      const Center(child: CircularProgressIndicator()),
                  ],
                );
              } else if (state is StateError) {
                return Container();
              } else {
                return Container();
              }
            },
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) => _buildCharacterList();
}
