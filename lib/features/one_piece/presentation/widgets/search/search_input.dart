import 'package:opfan/shared/widgets/atoms/app_icon.dart';
import 'package:phosphoricons_flutter/phosphoricons_flutter.dart';
// Developed by Randerson Mayllon
// Copyright © 2022.

import 'package:flutter/material.dart';
import 'package:opfan/features/one_piece/bloc/search_cubit.dart';
import 'package:opfan/l10n/app_localizations.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:opfan/shared/utils/theme.dart';

enum InputState { empty, filled }

class SearchInput extends StatefulWidget {
  SearchInput({super.key});

  final Widget searchIcon = AppIcon(
    PhosphorIconsRegular.magnifyingGlass,
    color: AppColors.grey[700],
    size: IconSize.small,
  );
  final Widget clearIcon = AppIcon(
    PhosphorIconsRegular.xCircle,
    size: IconSize.standard,
    color: AppColors.grey[700]!,
  );

  @override
  State<SearchInput> createState() => _SearchInputState();
}

class _SearchInputState extends State<SearchInput> {
  final TextEditingController _controller = TextEditingController();
  InputState state = InputState.empty;

  String _clearInput(String input) {
    return input.trim().replaceAll(RegExp(' +'), ' ');
  }

  void _clearQuery() {
    setState(() {
      _controller.clear();
      context.read<SearchCubit>().clearQuery();
      state = InputState.empty;
    });
  }

  Widget _inputIcon() {
    if (state == InputState.filled) {
      return IconButton(icon: widget.clearIcon, onPressed: _clearQuery);
    }
    return widget.searchIcon;
  }

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: _controller,
      decoration: InputDecoration(
        hintText: AppLocalizations.of(context)!.search,
        suffixIcon: _inputIcon(),
      ),
      onChanged: (String value) {
        setState(() {
          if (value.isEmpty) {
            state = InputState.empty;
          } else {
            state = InputState.filled;
          }
          context.read<SearchCubit>().setQuery(_clearInput(value));
        });
      },
    );
  }
}
