import 'package:flutter/material.dart';
import 'package:phosphoricons_flutter/phosphoricons_flutter.dart';

import 'package:opfan/l10n/app_localizations.dart';
import 'package:opfan/shared/utils/app_semantic_colors.dart';

class DetailsStatusBadge extends StatelessWidget {
  const DetailsStatusBadge({super.key, required this.status});

  final String? status;

  Map<String, dynamic> _statusTheme(
    BuildContext context,
    AppLocalizations l10n,
  ) {
    final statusLower = status?.toLowerCase() ?? '';

    if (statusLower.contains('captured') ||
        statusLower.contains('imprisoned')) {
      return {
        'backgroundColor': Theme.of(context).semanticColors.warning,
        'textColor': Theme.of(context).semanticColors.onWarning,
        'icon': PhosphorIconsRegular.lock,
        'displayText': l10n.captured,
      };
    }

    if (statusLower.contains('deceased')) {
      return {
        'backgroundColor': Theme.of(context).colorScheme.error,
        'textColor': Theme.of(context).colorScheme.onError,
        'icon': PhosphorIconsRegular.skull,
        'displayText': l10n.dead,
      };
    }

    if (statusLower.contains('living') || statusLower.contains('live')) {
      return {
        'backgroundColor': Theme.of(context).semanticColors.success,
        'textColor': Theme.of(context).semanticColors.onSuccess,
        'icon': PhosphorIconsRegular.wind,
        'displayText': l10n.alive,
      };
    }

    return {
      'backgroundColor': Theme.of(
        context,
      ).colorScheme.onSurfaceVariant.withValues(alpha: 0.6),
      'textColor': Theme.of(context).colorScheme.surface,
      'icon': PhosphorIconsRegular.question,
      'displayText': l10n.unknown,
    };
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final theme = _statusTheme(context, l10n);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: theme['backgroundColor'],
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Theme.of(context).colorScheme.shadow.withValues(alpha: 0.3),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(theme['icon'], size: 16, color: theme['textColor']),
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
