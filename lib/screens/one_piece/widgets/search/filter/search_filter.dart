// Developed by Randerson Mayllon
// Copyright © 2022.

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:opfan/screens/one_piece/blocs/search_cubit.dart';

import 'package:opfan/utils/constants.dart';

class SearchFilter extends StatelessWidget {
  const SearchFilter({required this.label, Key? key}) : super(key: key);

  final String label;

  void filterChipCallback(
      BuildContext context, bool isSelected, String filter) {
    final cubit = context.read<SearchCubit>();
    if (isSelected) {
      cubit.removeStatusFilter(filter);
    } else {
      cubit.addStatusFilter(filter);
    }
  }

  @override
  Widget build(BuildContext context) => BlocBuilder<SearchCubit, SearchState>(
        builder: (context, state) {
          List<String> statusFilters = [];

          if (state is SearchLoaded) {
            statusFilters = state.statusFilters;
          } else if (state is SearchLoading) {
            statusFilters = state.statusFilters;
          } else if (state is SearchInitial) {
            statusFilters = state.statusFilters;
          } else if (state is SearchError) {
            statusFilters = state.statusFilters;
          }

          return FilterChip(
            labelPadding: EdgeInsets.zero,
            visualDensity: const VisualDensity(vertical: -4.0),
            label: Text(
              label,
              style: Theme.of(context).textTheme.bodyMedium!.merge(TextStyle(
                  color: statusFilters.contains(label)
                      ? Colors.white
                      : Theme.of(context).colorScheme.onPrimary)),
            ),
            padding: const EdgeInsets.symmetric(horizontal: Constants.margin),
            selected: statusFilters.contains(label),
            selectedColor: Theme.of(context).colorScheme.onPrimary,
            showCheckmark: false,
            onSelected: (bool isSelected) => filterChipCallback(
                context, statusFilters.contains(label), label),
          );
        },
      );
}
