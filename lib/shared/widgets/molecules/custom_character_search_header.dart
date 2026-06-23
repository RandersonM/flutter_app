// Developed by Randerson Mayllon
// Copyright © 2022.

import 'package:flutter/material.dart';
import 'package:opfan/l10n/app_localizations.dart';
import 'package:opfan/shared/utils/constants.dart';

class CustomCharacterSearchHeader extends StatelessWidget {
  final TextEditingController searchController;
  final VoidCallback? onSearch;
  final VoidCallback? onFilter;
  final String? filterLabel;

  const CustomCharacterSearchHeader({
    Key? key,
    required this.searchController,
    this.onSearch,
    this.onFilter,
    this.filterLabel,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(Constants.margin),
      child: Column(
        children: [
          TextField(
            controller: searchController,
            decoration: InputDecoration(
              hintText: AppLocalizations.of(context)!.search,
              prefixIcon: const Icon(Icons.search),
              suffixIcon: searchController.text.isNotEmpty
                  ? IconButton(
                      onPressed: () {
                        searchController.clear();
                        onSearch?.call();
                      },
                      icon: const Icon(Icons.clear),
                    )
                  : null,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              filled: true,
              fillColor: Theme.of(context).colorScheme.surface,
            ),
            onChanged: (value) => onSearch?.call(),
          ),
          if (onFilter != null) ...[
            const SizedBox(height: Constants.margin),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: onFilter,
                    icon: const Icon(Icons.filter_list),
                    label: Text(filterLabel ?? 'Filtrar'),
                    style: OutlinedButton.styleFrom(
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }
} 