// Developed by Randerson Mayllon
// Copyright © 2022.

import 'package:flutter/material.dart';
import 'statistic_item.dart';

/// Data model for a statistic item
class StatisticData {
  const StatisticData({
    required this.label,
    required this.value,
    this.icon,
    this.svgPath,
    this.onTap,
  });

  final String label;
  final String value;
  final IconData? icon;
  final String? svgPath;
  final VoidCallback? onTap;
}

/// Molecular component - Grid/Row of statistic items with consistent spacing
class StatisticsGrid extends StatelessWidget {
  const StatisticsGrid({
    super.key,
    required this.statistics,
    this.title,
    this.titleStyle,
    this.mainAxisAlignment = MainAxisAlignment.spaceBetween,
    this.crossAxisAlignment = CrossAxisAlignment.center,
    this.spacing = 16.0,
    this.padding = const EdgeInsets.all(16.0),
    this.backgroundColor,
    this.borderRadius = 12.0,
    this.elevation = 0.0,
    this.isCard = true,
  });

  final List<StatisticData> statistics;
  final String? title;
  final TextStyle? titleStyle;
  final MainAxisAlignment mainAxisAlignment;
  final CrossAxisAlignment crossAxisAlignment;
  final double spacing;
  final EdgeInsetsGeometry padding;
  final Color? backgroundColor;
  final double borderRadius;
  final double elevation;
  final bool isCard;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    final content = Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (title != null) ...[
          Text(
            title!,
            style: titleStyle ??
                theme.textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
          ),
          SizedBox(height: spacing),
        ],
        Row(
          mainAxisAlignment: mainAxisAlignment,
          crossAxisAlignment: crossAxisAlignment,
          children: statistics
              .map(
                (stat) => Expanded(
                  child: Center(
                    child: StatisticItem(
                      label: stat.label,
                      value: stat.value,
                      icon: stat.icon,
                      svgPath: stat.svgPath,
                      onTap: stat.onTap,
                    ),
                  ),
                ),
              )
              .toList(),
        ),
      ],
    );

    if (isCard) {
      return Card(
        elevation: elevation,
        color: backgroundColor,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(borderRadius),
        ),
        child: Padding(
          padding: const EdgeInsets.all(0),
          child: content,
        ),
      );
    }

    return Container(
      padding: padding,
      decoration: backgroundColor != null
          ? BoxDecoration(
              color: backgroundColor,
              borderRadius: BorderRadius.circular(borderRadius),
            )
          : null,
      child: content,
    );
  }
}
