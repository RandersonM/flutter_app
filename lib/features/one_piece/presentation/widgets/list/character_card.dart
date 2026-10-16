import 'package:opfan/shared/widgets/atoms/app_icon.dart';
import 'package:phosphoricons_flutter/phosphoricons_flutter.dart';
// Developed by Randerson Mayllon
// Copyright © 2022.

import 'package:flutter/material.dart';
import 'package:opfan/features/custom_character/data/models/custom_character_model.dart';
import 'package:opfan/l10n/app_localizations.dart';
import 'package:opfan/shared/utils/app_routes.dart';
import 'package:opfan/shared/utils/constants.dart';

class CharacterCard extends StatefulWidget {
  final CustomCharacterModel character;

  const CharacterCard({super.key, required this.character});

  @override
  State<CharacterCard> createState() => _CharacterCardState();
}

class _CharacterCardState extends State<CharacterCard> {
  bool _imageLoadError = false;

  @override
  Widget build(BuildContext context) => InkWell(
    onTap: () => Navigator.pushNamed(
      context,
      AppRoutes.characterDetails,
      arguments: widget.character,
    ),
    child: Card(
      shape: RoundedRectangleBorder(
        side: BorderSide(color: Theme.of(context).colorScheme.outlineVariant),
        borderRadius: BorderRadius.circular(Constants.margin * 2),
      ),
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
                  color: Theme.of(context).colorScheme.surfaceContainerHigh,
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(Constants.margin * 2),
                  child: _imageLoadError
                      ? _buildPlaceholder()
                      : Image.network(
                          widget.character.image,
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
                            WidgetsBinding.instance.addPostFrameCallback((_) {
                              if (mounted) {
                                setState(() {
                                  _imageLoadError = true;
                                });
                              }
                            });
                            return _buildPlaceholder();
                          },
                        ),
                ),
              ),
            ),
            const SizedBox(height: Constants.margin),
            Expanded(
              flex: 1,
              child: SizedBox(
                width: double.infinity,
                child: FittedBox(
                  fit: BoxFit.scaleDown,
                  child: Text(
                    widget.character.name,
                    textAlign: TextAlign.center,
                    maxLines: 2,
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
              ),
            ),
          ],
        ),
      ),
    ),
  );

  Widget _buildPlaceholder() {
    return Container(
      width: double.infinity,
      height: double.infinity,
      color: Theme.of(context).colorScheme.surfaceContainerHigh,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          AppIcon(
            PhosphorIconsRegular.user,
            size: 48,
            color: Theme.of(context).colorScheme.onSurfaceVariant,
          ),
          const SizedBox(height: 8),
          Text(
            AppLocalizations.of(context)!.imageUnavailable,
            textAlign: TextAlign.center,
            style: TextStyle(
              color: Theme.of(context).colorScheme.onSurfaceVariant,
              fontSize: 12,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}
