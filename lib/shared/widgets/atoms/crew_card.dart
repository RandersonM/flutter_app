import 'package:opfan/shared/widgets/atoms/app_icon.dart';
import 'package:phosphoricons_flutter/phosphoricons_flutter.dart';
// Developed by Randerson Mayllon
// Copyright © 2022.

import 'package:flutter/material.dart';
import 'package:opfan/features/crews/data/models/crew_model.dart';
import 'package:opfan/shared/utils/constants.dart';
import 'package:opfan/l10n/app_localizations.dart';
import 'package:opfan/shared/widgets/atoms/universal_image.dart';

class CrewCard extends StatefulWidget {
  final CrewModel crew;
  final VoidCallback? onTap;
  final VoidCallback? onEdit;
  final VoidCallback? onDelete;

  const CrewCard({
    super.key,
    required this.crew,
    this.onTap,
    this.onEdit,
    this.onDelete,
  });

  @override
  State<CrewCard> createState() => _CrewCardState();
}

class _CrewCardState extends State<CrewCard> {
  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Card(
      margin: const EdgeInsets.symmetric(
        horizontal: Constants.margin,
        vertical: Constants.margin / 2,
      ),
      shape: RoundedRectangleBorder(
        side: BorderSide(color: Theme.of(context).colorScheme.surfaceContainer),
        borderRadius: BorderRadius.circular(Constants.margin * 2),
      ),
      elevation: 4,
      color: Theme.of(context).colorScheme.surface,
      child: InkWell(
        onTap: widget.onTap,
        borderRadius: BorderRadius.circular(Constants.margin * 2),
        child: Container(
          padding: const EdgeInsets.all(Constants.margin),
          child: Row(
            children: [
              Expanded(
                flex: 2,
                child: Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(Constants.margin),
                    color: Theme.of(
                      context,
                    ).colorScheme.onSurface.withValues(alpha: 0.08),
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(Constants.margin),
                    child: _buildCrewImage(),
                  ),
                ),
              ),
              const SizedBox(width: Constants.margin),
              Expanded(
                flex: 4,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  spacing: Constants.margin,
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      widget.crew.name,
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: Theme.of(context).colorScheme.primary,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: Constants.margin),
                    if ((widget.crew.captain?.isNotEmpty ?? false) ||
                        (widget.crew.viceCaptain?.isNotEmpty ?? false))
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          if (widget.crew.captain?.isNotEmpty ?? false)
                            _buildInfoRow(
                              context,
                              PhosphorIconsRegular.user,
                              l10n.labelValue(
                                l10n.captain,
                                widget.crew.captain!,
                              ),
                            ),
                          if (widget.crew.viceCaptain?.isNotEmpty ?? false)
                            _buildInfoRow(
                              context,
                              PhosphorIconsRegular.user,
                              l10n.labelValue(
                                l10n.viceCaptain,
                                widget.crew.viceCaptain!,
                              ),
                            ),
                        ],
                      ),
                    _buildInfoRow(
                      context,
                      PhosphorIconsRegular.coin,
                      '${_formatBounty(widget.crew.members.fold<int>(0, (sum, member) {
                        final bountyString = member.bounty.replaceAll(RegExp(r'[^\d]'), '');
                        final bounty = int.tryParse(bountyString) ?? 0;
                        return sum + bounty;
                      }).toInt())} ${l10n.berriesTotal}',
                    ),
                    _buildInfoRow(
                      context,
                      PhosphorIconsRegular.users,
                      l10n.membersCount(widget.crew.members.length),
                    ),
                    if (widget.crew.tags.isNotEmpty)
                      Wrap(
                        spacing: 4,
                        children: widget.crew.tags
                            .take(2)
                            .map(
                              (tag) => Chip(
                                label: Text(
                                  tag,
                                  style: const TextStyle(fontSize: 10),
                                ),
                                backgroundColor: Theme.of(context)
                                    .colorScheme
                                    .primaryContainer
                                    .withValues(alpha: 0.2),
                                materialTapTargetSize:
                                    MaterialTapTargetSize.shrinkWrap,
                                visualDensity: VisualDensity.compact,
                              ),
                            )
                            .toList(),
                      ),
                  ],
                ),
              ),
              if (widget.onEdit != null || widget.onDelete != null)
                Column(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    if (widget.onEdit != null)
                      IconButton(
                        onPressed: widget.onEdit,
                        icon: const AppIcon(
                          PhosphorIconsRegular.pencil,
                          size: 20,
                        ),
                        tooltip: AppLocalizations.of(context)!.edit,
                        padding: EdgeInsets.zero,
                        constraints: const BoxConstraints(),
                      ),
                    if (widget.onDelete != null)
                      IconButton(
                        onPressed: widget.onDelete,
                        icon: AppIcon(
                          PhosphorIconsRegular.trash,
                          size: 20,
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

  Widget _buildCrewImage() {
    if (widget.crew.jollyRogerUrl != null &&
        widget.crew.jollyRogerUrl!.isNotEmpty) {
      return UniversalImage(
        imageUrl: widget.crew.jollyRogerUrl!,
        fit: BoxFit.fill,
        loadingBuilder: (context, child, loadingProgress) {
          if (loadingProgress == null) return child;
          return Center(
            child: CircularProgressIndicator(
              value: loadingProgress.expectedTotalBytes != null
                  ? loadingProgress.cumulativeBytesLoaded /
                        loadingProgress.expectedTotalBytes!
                  : null,
            ),
          );
        },
        errorBuilder: (context, error, stackTrace) {
          return _buildPlaceholderImage();
        },
      );
    } else if (widget.crew.boatImageUrl != null &&
        widget.crew.boatImageUrl!.isNotEmpty) {
      return UniversalImage(
        imageUrl: widget.crew.boatImageUrl!,
        fit: BoxFit.cover,
        loadingBuilder: (context, child, loadingProgress) {
          if (loadingProgress == null) return child;
          return Center(
            child: CircularProgressIndicator(
              value: loadingProgress.expectedTotalBytes != null
                  ? loadingProgress.cumulativeBytesLoaded /
                        loadingProgress.expectedTotalBytes!
                  : null,
            ),
          );
        },
        errorBuilder: (context, error, stackTrace) {
          return _buildPlaceholderImage();
        },
      );
    } else {
      return _buildPlaceholderImage();
    }
  }

  Widget _buildPlaceholderImage() {
    return Builder(
      builder: (context) {
        final l10n = AppLocalizations.of(context)!;
        return Container(
          width: double.infinity,
          height: double.infinity,
          color: Theme.of(
            context,
          ).colorScheme.onSurface.withValues(alpha: 0.12),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              AppIcon(
                PhosphorIconsRegular.sailboat,
                size: 32,
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
              const SizedBox(height: 4),
              Text(
                l10n.crew(0),
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                  fontSize: 10,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildInfoRow(BuildContext context, IconData icon, String text) {
    final mutedColor = Theme.of(context).colorScheme.onSurfaceVariant;
    return Row(
      children: [
        Icon(icon, size: 14, color: mutedColor),
        const SizedBox(width: 4),
        Expanded(
          child: Text(
            text,
            style: Theme.of(
              context,
            ).textTheme.bodySmall?.copyWith(color: mutedColor),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }

  String _formatBounty(int bounty) {
    return Constants.formatAbbreviateBounty(bounty.toDouble());
  }
}
