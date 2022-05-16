// Developed by Randerson Mayllon
// Copyright © 2022.

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

import 'package:simple_app/blocs/one_piece/search/search_characters_bloc.dart';

import 'package:simple_app/shared/theme.dart';

enum InputState { empty, filled }

class SearchInput extends StatefulWidget {
  SearchInput({Key? key}) : super(key: key);

  final Icon searchIcon = Icon(
    Icons.search,
    color: AppColors.grey[700],
    size: IconSize.small,
  );
  final Icon clearIcon = Icon(
    Icons.cancel,
    size: IconSize.standard,
    color: AppColors.grey[700]!,
  );

  @override
  State<SearchInput> createState() => _SearchInputState();
}

class _SearchInputState extends State<SearchInput> {
  final TextEditingController _controller = TextEditingController();
  InputState state = InputState.empty;

  @override
  void initState() {
    super.initState();
  }

  String _clearInput(String input) {
    return input.trim().replaceAll(RegExp(' +'), ' ');
  }

  void _clearQuery() {
    setState(() {
      _controller.clear();
      state = InputState.empty;
    });
  }

  Widget _inputIcon() {
    if (state == InputState.filled) {
      return IconButton(
        icon: widget.clearIcon,
        onPressed: _clearQuery,
      );
    }
    return widget.searchIcon;
  }

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: _controller,
      decoration: InputDecoration(
          hintText: AppLocalizations.of(context)!.search,
          suffixIcon: _inputIcon()),
      onChanged: (String value) {
        setState(() {
          if (value.isEmpty) {
            state = InputState.empty;
          } else {
            state = InputState.filled;
          }
          BlocProvider.of<SearchCharactersBloc>(context)
              .add(GetSearchResult(_clearInput(value)));
        });
      },
    );
  }
}
