// Developed by Randerson Mayllon
// Copyright © 2022.

import 'package:flutter/material.dart';
import 'package:simple_app/core/one_piece/search_provider.dart';

import 'package:simple_app/shared/constants.dart';

class SearchFilter extends StatelessWidget {
  const SearchFilter(
      {required this.label, Key? key, required this.searchProvider})
      : super(key: key);

  final String label;
  final SearchProvider searchProvider;

  void filterChipCallback(bool isSelected, String filter) {
    if (isSelected) {
      searchProvider.removeStatusFilter(filter);
    } else {
      searchProvider.addStatusFilter(filter);
    }
  }

  @override
  Widget build(BuildContext context) => FilterChip(
        labelPadding: EdgeInsets.zero,
        visualDensity: const VisualDensity(vertical: -4.0),
        label: Text(
          label,
          style: Theme.of(context).textTheme.bodyText2!.merge(TextStyle(
              color: searchProvider.statusFilters.contains(label)
                  ? Colors.white
                  : Theme.of(context).colorScheme.onPrimary)),
        ),
        padding: const EdgeInsets.symmetric(horizontal: Constants.margin),
        selected: searchProvider.statusFilters.contains(label),
        selectedColor: Theme.of(context).colorScheme.onPrimary,
        showCheckmark: false,
        onSelected: (bool isSelected) => filterChipCallback(
            searchProvider.statusFilters.contains(label), label),
      );
}
