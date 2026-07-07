import 'package:opfan/shared/widgets/atoms/app_icon.dart';
import 'package:phosphoricons_flutter/phosphoricons_flutter.dart';
// Developed by Randerson Mayllon
// Copyright © 2022.

import 'package:flutter/material.dart';
import 'package:opfan/l10n/app_localizations.dart';
import 'package:opfan/shared/utils/constants.dart';

class EmptyDevilFruitList extends StatelessWidget {
  final bool hasFilters;
  final VoidCallback? onClearFilters;

  const EmptyDevilFruitList({
    super.key,
    this.hasFilters = false,
    this.onClearFilters,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(Constants.margin * 4),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(Constants.margin * 2),
            decoration: BoxDecoration(
              color: Colors.grey[100],
              shape: BoxShape.circle,
            ),
            child: Icon(
              hasFilters
                  ? PhosphorIconsRegular.faders
                  : PhosphorIconsRegular.smileySad,
              size: 64,
              color: Colors.grey[400],
            ),
          ),
          const SizedBox(height: Constants.margin * 2),
          Text(
            hasFilters
                ? AppLocalizations.of(context)!.noFruitFound
                : AppLocalizations.of(context)!.noDevilFruitAvailable,
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.bold,
              color: Colors.grey[700],
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: Constants.margin),
          Text(
            hasFilters
                ? AppLocalizations.of(context)!.adjustFiltersOrSearch
                : 'No devil fruits to display at the moment',
            style: Theme.of(
              context,
            ).textTheme.bodyMedium?.copyWith(color: Colors.grey[600]),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: Constants.margin * 2),
          if (hasFilters && onClearFilters != null)
            ElevatedButton.icon(
              onPressed: onClearFilters,
              icon: const AppIcon(PhosphorIconsRegular.x),
              label: Text(AppLocalizations.of(context)!.clearFilters),
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(
                  horizontal: Constants.margin * 2,
                  vertical: Constants.margin,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(Constants.margin * 2),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
