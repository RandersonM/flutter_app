import 'package:flutter/material.dart';
import 'package:opfan/core/models/one_piece/crew_model.dart';
import 'package:opfan/utils/constants.dart';
import 'package:opfan/l10n/app_localizations.dart';
import 'package:opfan/widgets/atoms/clickable_image.dart';

class CrewBoatSection extends StatelessWidget {
  final CrewModel crew;

  const CrewBoatSection({
    Key? key,
    required this.crew,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);

    if (crew.boatImageUrl == null || crew.boatImageUrl!.isEmpty) {
      return const SizedBox.shrink();
    }

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(Constants.margin),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.directions_boat,
                color: theme.colorScheme.primary,
                size: 20,
              ),
              const SizedBox(width: 8),
              Text(
                l10n.boat,
                style: theme.textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: theme.colorScheme.primary,
                ),
              ),
            ],
          ),
          const SizedBox(height: Constants.margin),
          
          ClickableImage(
            imageUrl: crew.boatImageUrl!,
            width: double.infinity,
            height: 300,
            fit: BoxFit.cover,
            borderRadius: BorderRadius.circular(8),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.1),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
            title: crew.boatName,
            showTitleInDialog: true,
          ),
          
          if (crew.boatName != null && crew.boatName!.isNotEmpty) ...[
            const SizedBox(height: Constants.margin),
            Container(
              padding: const EdgeInsets.symmetric(
                horizontal: Constants.margin,
                vertical: 8,
              ),
              decoration: BoxDecoration(
                color: theme.colorScheme.primaryContainer,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                children: [
                  const Icon(
                    Icons.label,
                    size: 16,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      crew.boatName!,
                      style: theme.textTheme.bodyMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

} 