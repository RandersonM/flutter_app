import 'package:opfan/shared/widgets/atoms/app_icon.dart';
import 'package:phosphoricons_flutter/phosphoricons_flutter.dart';
// Developed by Randerson Mayllon
// Copyright © 2022.

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:opfan/l10n/app_localizations.dart';
import 'package:opfan/features/devil_fruit/bloc/index.dart';
import 'package:opfan/shared/utils/constants.dart';

class DevilFruitSearchHeader extends StatefulWidget {
  const DevilFruitSearchHeader({super.key});

  @override
  State<DevilFruitSearchHeader> createState() => _DevilFruitSearchHeaderState();
}

class _DevilFruitSearchHeaderState extends State<DevilFruitSearchHeader> {
  final TextEditingController _searchController = TextEditingController();
  bool _isSearching = false;

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<DevilFruitBloc, DevilFruitState>(
      listener: (context, state) {
        if (state is DevilFruitLoaded) {
          setState(() {
            _isSearching = state.isSearching;
          });
        }
      },
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            AppLocalizations.of(context)!.devilFruitHeaderTitle,
            style: Theme.of(
              context,
            ).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: Constants.margin / 2),
          Text(
            AppLocalizations.of(context)!.devilFruitHeaderSubtitle,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: Theme.of(context).colorScheme.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: Constants.margin * 2),
          Container(
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.surfaceContainerHigh,
              borderRadius: BorderRadius.circular(Constants.margin * 2),
              border: Border.all(
                color: Theme.of(context).colorScheme.outlineVariant,
                width: 1,
              ),
            ),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: AppLocalizations.of(context)!.searchPlaceholder,
                hintStyle: TextStyle(
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                ),
                prefixIcon: AppIcon(
                  PhosphorIconsRegular.magnifyingGlass,
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                ),
                suffixIcon: _searchController.text.isNotEmpty
                    ? IconButton(
                        icon: AppIcon(
                          PhosphorIconsRegular.x,
                          color: Theme.of(context).colorScheme.onSurfaceVariant,
                        ),
                        onPressed: () {
                          _searchController.clear();
                          context.read<DevilFruitBloc>().add(
                            const SearchDevilFruits(''),
                          );
                        },
                      )
                    : null,
                border: InputBorder.none,
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: Constants.margin * 2,
                  vertical: Constants.margin * 1.5,
                ),
              ),
              onChanged: (value) {
                setState(() {});
                context.read<DevilFruitBloc>().add(SearchDevilFruits(value));
              },
            ),
          ),
          if (_isSearching)
            Padding(
              padding: const EdgeInsets.only(top: Constants.margin),
              child: Row(
                children: [
                  const SizedBox(
                    width: 16,
                    height: 16,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  ),
                  const SizedBox(width: Constants.margin),
                  Text(
                    AppLocalizations.of(context)!.searching,
                    style: TextStyle(
                      color: Theme.of(context).colorScheme.onSurfaceVariant,
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }
}
