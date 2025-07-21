// Developed by Randerson Mayllon
// Copyright © 2022.

import 'package:flutter/material.dart';
import 'package:opfan/core/models/one_piece/crew_model.dart';
import 'package:opfan/utils/constants.dart';
import 'package:opfan/l10n/app_localizations.dart';

class CrewCard extends StatefulWidget {
  final CrewModel crew;
  final VoidCallback? onTap;
  final VoidCallback? onEdit;
  final VoidCallback? onDelete;

  const CrewCard({
    Key? key,
    required this.crew,
    this.onTap,
    this.onEdit,
    this.onDelete,
  }) : super(key: key);

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
        side: const BorderSide(color: Colors.white),
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
                    color: Colors.grey[200],
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
                    if (widget.crew.captain != null || widget.crew.viceCaptain != null)
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          if (widget.crew.captain != null)
                            _buildInfoRow(
                              context,
                              Icons.person,
                              '${l10n.captain}: ${widget.crew.captain}',
                            ),
                          if (widget.crew.viceCaptain != null)
                            _buildInfoRow(
                              context,
                              Icons.person_outline,
                              '${l10n.viceCaptain}: ${widget.crew.viceCaptain}',
                            ),
                        ],
                      ),
                    _buildInfoRow(
                      context,
                      Icons.monetization_on,
                      '${_formatBounty(widget.crew.members.fold<int>(0, (sum, member) {
                        final bountyString =
                            member.bounty.replaceAll(RegExp(r'[^\d]'), '');
                        final bounty = int.tryParse(bountyString) ?? 0;
                        return sum + bounty;
                      }).toInt())} ${l10n.berriesTotal}',
                    ),
                    _buildInfoRow(
                      context,
                      Icons.group,
                      '${widget.crew.members.length} ${l10n.members(widget.crew.members.length)}',
                    ),
                    if (widget.crew.tags.isNotEmpty)
                      Wrap(
                        spacing: 4,
                        children: widget.crew.tags.take(2).map((tag) => Chip(
                          label: Text(
                            tag,
                            style: const TextStyle(fontSize: 10),
                          ),
                                  backgroundColor: Theme.of(context)
                                      .colorScheme
                                      .primaryContainer
                                      .withValues(alpha: 0.2),
                          materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                          visualDensity: VisualDensity.compact,
                        )).toList(),
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
                        icon: const Icon(Icons.edit, size: 20),
                        tooltip: AppLocalizations.of(context)!.edit,
                        padding: EdgeInsets.zero,
                        constraints: const BoxConstraints(),
                      ),
                    if (widget.onDelete != null)
                      IconButton(
                        onPressed: widget.onDelete,
                        icon: const Icon(Icons.delete, size: 20, color: Colors.red),
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
    if (widget.crew.jollyRogerUrl != null && widget.crew.jollyRogerUrl!.isNotEmpty) {
      return Image.network(
        widget.crew.jollyRogerUrl!,
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
    } else if (widget.crew.boatImageUrl != null && widget.crew.boatImageUrl!.isNotEmpty) {
      return Image.network(
        widget.crew.boatImageUrl!,
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
          color: Colors.grey[300],
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.sailing,
                size: 32,
                color: Colors.grey[600],
              ),
              const SizedBox(height: 4),
              Text(
                l10n.crew(0),
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Colors.grey[600],
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
    return Row(
      children: [
        Icon(
          icon,
          size: 14,
          color: Colors.grey[600],
        ),
        const SizedBox(width: 4),
        Expanded(
          child: Text(
            text,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: Colors.grey[600],
            ),
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