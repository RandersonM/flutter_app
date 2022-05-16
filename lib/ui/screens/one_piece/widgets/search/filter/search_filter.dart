// Developed by Randerson Mayllon
// Copyright © 2022.

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:simple_app/blocs/one_piece/search/search_characters_bloc.dart';

import 'package:simple_app/shared/constants.dart';

class SearchFilter extends StatefulWidget {
  const SearchFilter({required this.label, Key? key}) : super(key: key);

  final String label;

  @override
  State<SearchFilter> createState() => _SearchFilterState();
}

class _SearchFilterState extends State<SearchFilter> {
  late bool isSelected = false;

  @override
  Widget build(BuildContext context) =>
      BlocListener<SearchCharactersBloc, SearchCharactersState>(
        listener: (BuildContext context, SearchCharactersState state) {
          setState(() {
            if (state.filters.contains(widget.label)) {
              isSelected = true;
            } else {
              isSelected = false;
            }
          });
        },
        child: FilterChip(
            labelPadding: EdgeInsets.zero,
            visualDensity: const VisualDensity(vertical: -4.0),
            label: Text(
              widget.label,
              style: Theme.of(context).textTheme.bodyText2!.merge(TextStyle(
                  color: isSelected
                      ? Colors.white
                      : Theme.of(context).colorScheme.onPrimary)),
            ),
            padding: const EdgeInsets.symmetric(horizontal: Constants.margin),
            selected: isSelected,
            selectedColor: Theme.of(context).colorScheme.onPrimary,
            showCheckmark: false,
            onSelected: (bool isSelected) {
              BlocProvider.of<SearchCharactersBloc>(context)
                  .add(GetFilterResult(widget.label));
            }),
      );
}
