// Developed by Randerson Mayllon
// Copyright © 2022.

import 'package:flutter/material.dart';

import 'package:simple_app/core/one_piece/characters_provider.dart';
import 'package:simple_app/screens/one_piece/widgets/list/character_grid_list.dart';

class ListContent extends StatefulWidget {
  const ListContent({Key? key, required this.provider}) : super(key: key);

  final CharactersProvider provider;

  @override
  State<ListContent> createState() => _ListContentState();
}

class _ListContentState extends State<ListContent> {
  late ScrollController controller;

  void _scrollListener() {
    if (controller.position.pixels == controller.position.maxScrollExtent) {
      if (!widget.provider.isLoading() && widget.provider.hasMoreData) {
        widget.provider.fetchData();
      }
    }
  }

  @override
  void initState() {
    super.initState();
    controller = ScrollController()..addListener(_scrollListener);
  }

  @override
  void dispose() {
    super.dispose();
    controller.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (widget.provider.loadState == LoadState.unitialized) {
      widget.provider.fetchData();
    }
    return Column(
      children: <Widget>[
        Expanded(
          child: NotificationListener<ScrollNotification>(
            onNotification: (ScrollNotification scrollInfo) {
              if (!widget.provider.isLoading() &&
                  scrollInfo.metrics.pixels ==
                      scrollInfo.metrics.maxScrollExtent) {
                widget.provider.fetchData();
              }
              return true;
            },
            child: widget.provider.loadState == LoadState.unitialized
                ? const Center(
                    child: CircularProgressIndicator(),
                  )
                : CharacterGridList(characters: widget.provider.characters),
          ),
        ),
        if (widget.provider.isLoading())
          const Center(child: CircularProgressIndicator()),
      ],
    );
  }
}
