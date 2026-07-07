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
            'Explore as Akuma no Mi',
            style: Theme.of(
              context,
            ).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: Constants.margin / 2),
          Text(
            'Descubra os poderes místicos das frutas do diabo',
            style: Theme.of(
              context,
            ).textTheme.bodyMedium?.copyWith(color: Colors.grey[600]),
          ),
          const SizedBox(height: Constants.margin * 2),
          Container(
            decoration: BoxDecoration(
              color: Colors.grey[100],
              borderRadius: BorderRadius.circular(Constants.margin * 2),
              border: Border.all(color: Colors.grey[300]!, width: 1),
            ),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: AppLocalizations.of(context)!.searchPlaceholder,
                hintStyle: TextStyle(color: Colors.grey[600]),
                prefixIcon: AppIcon(
                  PhosphorIconsRegular.magnifyingGlass,
                  color: Colors.grey[600],
                ),
                suffixIcon: _searchController.text.isNotEmpty
                    ? IconButton(
                        icon: AppIcon(
                          PhosphorIconsRegular.x,
                          color: Colors.grey[600],
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
                    style: const TextStyle(color: Colors.grey, fontSize: 12),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }
}
