import 'package:opfan/shared/widgets/atoms/app_icon.dart';
import 'package:phosphoricons_flutter/phosphoricons_flutter.dart';
// Developed by Randerson Mayllon
// Copyright © 2022.

import 'package:flutter/material.dart';
import 'package:opfan/features/custom_character/data/models/custom_character_model.dart';
import 'package:opfan/shared/utils/constants.dart';
import 'package:opfan/l10n/app_localizations.dart';
import 'package:opfan/shared/widgets/atoms/universal_image.dart';

class CustomCharacterCard extends StatelessWidget {
  final CustomCharacterModel character;
  final VoidCallback? onTap;
  final VoidCallback? onEdit;
  final VoidCallback? onDelete;

  const CustomCharacterCard({
    super.key,
    required this.character,
    this.onTap,
    this.onEdit,
    this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      shape: RoundedRectangleBorder(
        side: BorderSide(color: Theme.of(context).colorScheme.surfaceContainer),
        borderRadius: BorderRadius.circular(Constants.margin * 2),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(Constants.margin * 2),
        child: Padding(
          padding: const EdgeInsets.all(Constants.margin),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: <Widget>[
              Expanded(
                flex: 3,
                child: Container(
                  width: double.infinity,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(Constants.margin * 2),
                    color: Theme.of(
                      context,
                    ).colorScheme.onSurface.withValues(alpha: 0.08),
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(Constants.margin * 2),
                    child: character.image.isNotEmpty
                        ? UniversalImage(
                            imageUrl: character.image,
                            fit: BoxFit.cover,
                            loadingBuilder: (context, child, loadingProgress) {
                              if (loadingProgress == null) return child;
                              return Center(
                                child: CircularProgressIndicator(
                                  value:
                                      loadingProgress.expectedTotalBytes != null
                                      ? loadingProgress.cumulativeBytesLoaded /
                                            loadingProgress.expectedTotalBytes!
                                      : null,
                                ),
                              );
                            },
                            errorBuilder: (context, error, stackTrace) {
                              return _buildPlaceholderImage(context);
                            },
                          )
                        : _buildPlaceholderImage(context),
                  ),
                ),
              ),
              const SizedBox(height: Constants.margin),
              Expanded(
                flex: 1,
                child: Column(
                  children: [
                    FittedBox(
                      fit: BoxFit.scaleDown,
                      child: Text(
                        character.name,
                        textAlign: TextAlign.center,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: Theme.of(context).textTheme.bodySmall!.merge(
                          TextStyle(
                            fontWeight: FontWeight.bold,
                            color: Theme.of(
                              context,
                            ).appBarTheme.titleTextStyle!.color,
                          ),
                        ),
                      ),
                    ),
                    if (character.nickname != null &&
                        character.nickname!.isNotEmpty)
                      FittedBox(
                        fit: BoxFit.scaleDown,
                        child: Text(
                          '"${character.nickname}"',
                          textAlign: TextAlign.center,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: Theme.of(context).textTheme.bodySmall!.merge(
                            TextStyle(
                              color: Theme.of(
                                context,
                              ).colorScheme.onSurfaceVariant,
                              fontStyle: FontStyle.italic,
                            ),
                          ),
                        ),
                      ),
                  ],
                ),
              ),
              if (onEdit != null || onDelete != null)
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    if (onEdit != null)
                      IconButton(
                        onPressed: onEdit,
                        icon: const AppIcon(
                          PhosphorIconsRegular.pencil,
                          size: 16,
                        ),
                        tooltip: AppLocalizations.of(context)!.edit,
                        padding: EdgeInsets.zero,
                        constraints: const BoxConstraints(),
                      ),
                    if (onDelete != null)
                      IconButton(
                        onPressed: onDelete,
                        icon: AppIcon(
                          PhosphorIconsRegular.trash,
                          size: 16,
                          color: Theme.of(context).colorScheme.error,
                        ),
                        tooltip: AppLocalizations.of(context)!.delete,
                        padding: EdgeInsets.zero,
                        constraints: const BoxConstraints(),
                      ),
                  ],
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPlaceholderImage(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final onSurfaceVariant = colors.onSurfaceVariant;
    return Container(
      width: double.infinity,
      height: double.infinity,
      color: colors.surfaceContainerHighest,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          AppIcon(PhosphorIconsRegular.user, size: 48, color: onSurfaceVariant),
          const SizedBox(height: 8),
          Text(
            AppLocalizations.of(context)!.noImage,
            textAlign: TextAlign.center,
            style: TextStyle(
              color: onSurfaceVariant,
              fontSize: 12,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}
