import 'package:phosphoricons_flutter/phosphoricons_flutter.dart';
// Developed by Randerson Mayllon
// Copyright © 2022.

import 'package:flutter/material.dart';
import 'package:opfan/features/devil_fruit/data/models/devil_fruit.dart';
import 'package:opfan/shared/utils/devil_fruit_type_palette.dart';
import 'package:opfan/l10n/app_localizations.dart';
import 'package:opfan/shared/utils/constants.dart';

class DevilFruitCard extends StatelessWidget {
  final DevilFruit devilFruit;
  final VoidCallback? onTap;

  const DevilFruitCard({super.key, required this.devilFruit, this.onTap});

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(Constants.margin * 2),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(Constants.margin * 2),
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(Constants.margin * 2),
            gradient: _palette.gradient,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                flex: 3,
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(Constants.margin),
                  child: Column(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: Constants.margin,
                          vertical: Constants.margin / 2,
                        ),
                        decoration: BoxDecoration(
                          color: DevilFruitTypePalette.onGradient.withValues(
                            alpha: 0.9,
                          ),
                          borderRadius: BorderRadius.circular(Constants.margin),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              _getTypeIcon(),
                              size: 16,
                              color: _palette.accent,
                            ),
                            const SizedBox(width: Constants.margin / 2),
                            Text(
                              devilFruit.type,
                              style: Theme.of(context).textTheme.bodySmall
                                  ?.copyWith(
                                    fontWeight: FontWeight.bold,
                                    color: _palette.accent,
                                  ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: Constants.margin),
                      Expanded(
                        child: Container(
                          width: double.infinity,
                          decoration: BoxDecoration(
                            color: DevilFruitTypePalette.onGradient.withValues(
                              alpha: 0.1,
                            ),
                            borderRadius: BorderRadius.circular(
                              Constants.margin,
                            ),
                          ),
                          child:
                              devilFruit.filename != null &&
                                  devilFruit.filename!.isNotEmpty
                              ? ClipRRect(
                                  borderRadius: BorderRadius.circular(
                                    Constants.margin,
                                  ),
                                  child: Image.network(
                                    devilFruit.filename!,
                                    fit: BoxFit.contain,
                                    loadingBuilder:
                                        (context, child, loadingProgress) {
                                          if (loadingProgress == null) {
                                            return child;
                                          }
                                          return Center(
                                            child: CircularProgressIndicator(
                                              value:
                                                  loadingProgress
                                                          .expectedTotalBytes !=
                                                      null
                                                  ? loadingProgress
                                                            .cumulativeBytesLoaded /
                                                        loadingProgress
                                                            .expectedTotalBytes!
                                                  : null,
                                              strokeWidth: 2,
                                              color: DevilFruitTypePalette
                                                  .onGradient
                                                  .withValues(alpha: 0.7),
                                            ),
                                          );
                                        },
                                    errorBuilder: (context, error, stackTrace) {
                                      return _buildPlaceholderImage(context);
                                    },
                                  ),
                                )
                              : _buildPlaceholderImage(context),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              Expanded(
                flex: 2,
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(Constants.margin),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        devilFruit.romanName,
                        style: Theme.of(context).textTheme.titleSmall?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: DevilFruitTypePalette.onGradient,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: Constants.margin / 2),
                      Text(
                        devilFruit.name,
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: DevilFruitTypePalette.onGradient.withValues(
                            alpha: 0.8,
                          ),
                          fontStyle: FontStyle.italic,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPlaceholderImage(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Container(
      width: double.infinity,
      height: double.infinity,
      decoration: BoxDecoration(
        color: DevilFruitTypePalette.onGradient.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(Constants.margin),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            _getTypeIcon(),
            color: DevilFruitTypePalette.onGradient.withValues(alpha: 0.7),
            size: 32,
          ),
          const SizedBox(height: Constants.margin / 2),
          Text(
            l10n.devilFruit,
            style: TextStyle(
              color: DevilFruitTypePalette.onGradient.withValues(alpha: 0.7),
              fontSize: 10,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  DevilFruitTypePalette get _palette =>
      DevilFruitTypePalette.of(devilFruit.type);

  IconData _getTypeIcon() {
    switch (devilFruit.type.toLowerCase()) {
      case 'logia':
        return PhosphorIconsRegular.drop;
      case 'paramecia':
        return PhosphorIconsRegular.magicWand;
      case 'zoan':
        return PhosphorIconsRegular.pawPrint;
      default:
        return PhosphorIconsRegular.question;
    }
  }
}
