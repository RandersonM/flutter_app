// Developed by Randerson Mayllon
// Copyright © 2022.

import 'package:flutter/material.dart';
import 'dart:ui' as ui;
import 'package:opfan/shared/utils/constants.dart';
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

    final content = Padding(
      padding: const EdgeInsets.all(Constants.margin),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (title != null) ...[
            Text(
              title!,
              style: titleStyle ??
                  theme.textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: theme.colorScheme.primary,
                  ),
            ),
            SizedBox(height: spacing),
          ],
          Row(
            mainAxisAlignment: mainAxisAlignment,
            crossAxisAlignment: CrossAxisAlignment.start,
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
      ),
    );

    final Widget blurredContent = ClipRRect(
      borderRadius: BorderRadius.circular(borderRadius),
      child: BackdropFilter(
        filter: ui.ImageFilter.blur(sigmaX: 12.0, sigmaY: 12.0),
        child: Container(
          decoration: BoxDecoration(
            color: backgroundColor ??
                theme.colorScheme.surfaceContainerHigh.withValues(alpha: 0.6),
            borderRadius: BorderRadius.circular(borderRadius),
            border: Border.all(
              color: theme.colorScheme.outline.withValues(alpha: 0.2),
              width: 1.0,
            ),
          ),
          child: Padding(
            padding: const EdgeInsets.all(0),
            child: content,
          ),
        ),
      ),
    );

    if (isCard) {
      return Card(
        elevation: elevation,
        color: Colors.transparent,
        shadowColor: Colors.black26,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(borderRadius),
        ),
        child: blurredContent,
      );
    }

    return Container(
      padding: padding,
      child: blurredContent,
    );
  }
}
