import 'package:opfan/shared/widgets/atoms/app_icon.dart';
import 'package:phosphoricons_flutter/phosphoricons_flutter.dart';
// Developed by Randerson Mayllon
// Copyright © 2022.

import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

/// Molecular component - Displays a statistic item with icon, value and label
class StatisticItem extends StatelessWidget {
  const StatisticItem({
    super.key,
    required this.label,
    required this.value,
    this.icon,
    this.svgPath,
    this.iconColor,
    this.iconSize = 32.0,
    this.valueStyle,
    this.labelStyle,
    this.spacing = 4.0,
    this.onTap,
  });

  final String label;
  final String value;
  final IconData? icon;
  final String? svgPath;
  final Color? iconColor;
  final double iconSize;
  final TextStyle? valueStyle;
  final TextStyle? labelStyle;
  final double spacing;
  final VoidCallback? onTap;

  Widget _buildIcon(BuildContext context) {
    if (svgPath != null) {
      return SvgPicture.asset(
        svgPath!,
        width: iconSize,
        height: iconSize,
        colorFilter: iconColor != null
            ? ColorFilter.mode(iconColor!, BlendMode.srcIn)
            : ColorFilter.mode(
                Theme.of(context).colorScheme.primary, BlendMode.srcIn),
      );
    } else if (icon != null) {
      return Icon(
        icon,
        size: iconSize,
        color: iconColor ?? Theme.of(context).colorScheme.primary,
      );
    } else {
      return AppIcon(
        PhosphorIconsRegular.question,
        size: iconSize,
        color: iconColor ?? Theme.of(context).colorScheme.primary,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.center,
        spacing: spacing,
        mainAxisSize: MainAxisSize.max,
        children: [
          _buildIcon(context),
          SizedBox(height: spacing / 2),
          Text(
            label,
            style: labelStyle ?? Theme.of(context).textTheme.bodySmall,
            textAlign: TextAlign.center,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
          Text(
            value,
            style: valueStyle ??
                Theme.of(context).textTheme.bodySmall?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}
