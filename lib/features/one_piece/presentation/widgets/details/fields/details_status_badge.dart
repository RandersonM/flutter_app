import 'package:flutter/material.dart';
import 'package:phosphoricons_flutter/phosphoricons_flutter.dart';

import 'package:opfan/l10n/app_localizations.dart';

class DetailsStatusBadge extends StatelessWidget {
  const DetailsStatusBadge({super.key, required this.status});

  final String? status;

  Map<String, dynamic> _statusTheme(AppLocalizations l10n) {
    final statusLower = status?.toLowerCase() ?? '';

    if (statusLower.contains('captured') || statusLower.contains('imprisoned')) {
      return {
        'backgroundColor': Colors.grey,
        'textColor': Colors.white,
        'icon': PhosphorIconsRegular.lock,
        'displayText': l10n.captured,
      };
    }

    if (statusLower.contains('deceased')) {
      return {
        'backgroundColor': Colors.red,
        'textColor': Colors.white,
        'icon': PhosphorIconsRegular.skull,
        'displayText': l10n.dead,
      };
    }

    if (statusLower.contains('living') || statusLower.contains('live')) {
      return {
        'backgroundColor': Colors.green[500],
        'textColor': Colors.white,
        'icon': PhosphorIconsRegular.wind,
        'displayText': l10n.alive,
      };
    }

    return {
      'backgroundColor': Colors.grey.withValues(alpha: 0.6),
      'textColor': Colors.white,
      'icon': PhosphorIconsRegular.question,
      'displayText': l10n.unknown,
    };
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final theme = _statusTheme(l10n);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: theme['backgroundColor'],
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.3),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            theme['icon'],
            size: 16,
            color: theme['textColor'],
          ),
          const SizedBox(width: 6),
          Text(
            theme['displayText'],
            style: Theme.of(context).textTheme.labelLarge?.copyWith(
                  color: theme['textColor'],
                  fontWeight: FontWeight.bold,
                ),
          ),
        ],
      ),
    );
  }
}
