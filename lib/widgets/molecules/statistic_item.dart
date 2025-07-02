// Developed by Randerson Mayllon
// Copyright © 2022.

import 'package:flutter/material.dart';

/// Molecular component - Displays a statistic item with icon, value and label
class StatisticItem extends StatelessWidget {
  const StatisticItem({
    super.key,
    required this.label,
    required this.value,
    required this.icon,
    this.iconColor,
    this.iconSize = 32.0,
    this.valueStyle,
    this.labelStyle,
    this.spacing = 4.0,
    this.onTap,
  });

  final String label;
  final String value;
  final IconData icon;
  final Color? iconColor;
  final double iconSize;
  final TextStyle? valueStyle;
  final TextStyle? labelStyle;
  final double spacing;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    final content = Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(
          icon,
          size: iconSize,
          color: iconColor ?? theme.primaryColor,
        ),
        SizedBox(height: spacing),
        Text(
          value,
          style: valueStyle ??
              theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
        ),
        Text(
          label,
          style: labelStyle ?? theme.textTheme.bodySmall,
          textAlign: TextAlign.center,
        ),
      ],
    );

    if (onTap != null) {
      return InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(8),
        child: Padding(
          padding: const EdgeInsets.all(8),
          child: content,
        ),
      );
    }

    return content;
  }
}
