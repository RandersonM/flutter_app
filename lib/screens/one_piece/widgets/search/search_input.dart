// Developed by Randerson Mayllon
// Copyright © 2022.

import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:provider/provider.dart';

import 'package:simple_app/core/one_piece/search_provider.dart';
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
  late final SearchProvider searchProvider;
  InputState state = InputState.empty;

  @override
  void initState() {
    super.initState();
    searchProvider = Provider.of<SearchProvider>(context, listen: false);
  }

  String _clearInput(String input) {
    return input.trim().replaceAll(RegExp(' +'), ' ');
  }

  void _clearQuery() {
    setState(() {
      _controller.clear();
      searchProvider.query = '';
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
          searchProvider.query = _clearInput(value);
        });
      },
    );
  }
}
