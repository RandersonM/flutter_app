// Developed by Randerson Mayllon
// Copyright © 2022.

import 'package:flutter/material.dart';

enum AppButtonVariant { primary, secondary, outline, tertiary, text }

class AppButton extends StatelessWidget {
  const AppButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.icon,
    this.variant = AppButtonVariant.primary,
    this.isLoading = false,
    this.isFullWidth = false,
    this.padding = const EdgeInsets.symmetric(vertical: 16, horizontal: 24),
    this.borderRadius = 16.0,
    this.backgroundColor,
    this.foregroundColor,
  });

  final String label;
  final VoidCallback? onPressed;
  final Widget? icon;
  final AppButtonVariant variant;
  final bool isLoading;
  final bool isFullWidth;
  final EdgeInsetsGeometry padding;
  final double borderRadius;
  final Color? backgroundColor;
  final Color? foregroundColor;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    Color backgroundColor;
    Color foregroundColor;
    BorderSide borderSide = BorderSide.none;
    List<BoxShadow>? boxShadow;

    switch (variant) {
      case AppButtonVariant.primary:
        backgroundColor = colorScheme.primaryContainer.withValues(alpha: 0.9);
        foregroundColor = colorScheme.onPrimaryContainer;
        borderSide = BorderSide(
          color: colorScheme.primary.withValues(alpha: 0.5),
          width: 1.5,
        );
        boxShadow = [
          BoxShadow(
            color: colorScheme.primary.withValues(alpha: 0.2),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ];
        break;
      case AppButtonVariant.secondary:
        backgroundColor = colorScheme.secondaryContainer.withValues(alpha: 0.9);
        foregroundColor = colorScheme.onSecondaryContainer;
        borderSide = BorderSide(
          color: colorScheme.secondary.withValues(alpha: 0.3),
          width: 1.0,
        );
        break;
      case AppButtonVariant.outline:
        backgroundColor = Colors.transparent;
        foregroundColor = colorScheme.primary;
        borderSide = BorderSide(
          color: colorScheme.primary.withValues(alpha: 0.5),
          width: 1.5,
        );
        break;
      case AppButtonVariant.tertiary:
        backgroundColor = colorScheme.surfaceContainerHigh;
        foregroundColor = colorScheme.onSurface;
        borderSide = BorderSide(
          color: colorScheme.outline.withValues(alpha: 0.2),
          width: 1.0,
        );
        break;
      case AppButtonVariant.text:
        backgroundColor = Colors.transparent;
        foregroundColor = colorScheme.primary;
        break;
    }

    final bool isDisabled = onPressed == null || isLoading;

    if (isDisabled) {
      backgroundColor = colorScheme.surfaceContainerHighest.withValues(
        alpha: 0.5,
      );
      foregroundColor = colorScheme.onSurface.withValues(alpha: 0.4);
      borderSide = BorderSide(
        color: colorScheme.outline.withValues(alpha: 0.1),
        width: 1.0,
      );
      boxShadow = null;
    } else {
      if (this.backgroundColor != null) backgroundColor = this.backgroundColor!;
      if (this.foregroundColor != null) {
        foregroundColor = this.foregroundColor!;
        if (variant == AppButtonVariant.outline) {
          borderSide = BorderSide(
            color: foregroundColor.withValues(alpha: 0.5),
            width: 1.5,
          );
        }
      }
    }

    Widget content = Row(
      mainAxisSize: isFullWidth ? MainAxisSize.max : MainAxisSize.min,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        if (isLoading) ...[
          SizedBox(
            width: 18,
            height: 18,
            child: CircularProgressIndicator(
              strokeWidth: 2,
              color: foregroundColor,
            ),
          ),
          const SizedBox(width: 8),
        ] else if (icon != null) ...[
          IconTheme(
            data: IconThemeData(color: foregroundColor, size: 20),
            child: icon!,
          ),
          const SizedBox(width: 8),
        ],
        Flexible(
          child: Text(
            label,
            style: theme.textTheme.labelLarge?.copyWith(
              color: foregroundColor,
              fontWeight: FontWeight.w600,
              fontSize: 15,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );

    return Material(
      color: Colors.transparent,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        decoration: BoxDecoration(
          color: backgroundColor,
          borderRadius: BorderRadius.circular(borderRadius),
          border: Border.all(
            color: borderSide.color,
            width: borderSide.width,
            style: borderSide.style,
          ),
          boxShadow: boxShadow,
        ),
        child: InkWell(
          onTap: isDisabled ? null : onPressed,
          borderRadius: BorderRadius.circular(borderRadius),
          splashColor: foregroundColor.withValues(alpha: 0.1),
          highlightColor: foregroundColor.withValues(alpha: 0.05),
          child: Padding(padding: padding, child: content),
        ),
      ),
    );
  }
}
