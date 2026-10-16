import 'package:flutter/material.dart';

/// The bordered, tinted panel that groups a section of the crew form.
///
/// The create and edit screens each repeated this `Container` decoration five
/// times; a tweak to the radius or border meant ten edits. Now it is one.
class CrewFormCard extends StatelessWidget {
  const CrewFormCard({
    super.key,
    required this.child,
    this.padding = const EdgeInsets.all(16),
    this.height,
  });

  final Widget child;
  final EdgeInsetsGeometry padding;
  final double? height;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;

    return Container(
      height: height,
      padding: padding,
      decoration: BoxDecoration(
        color: colors.primaryContainer,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: colors.primary),
      ),
      child: child,
    );
  }
}

/// Section heading: an icon next to a label, used at the top of a form card.
class CrewFormSectionTitle extends StatelessWidget {
  const CrewFormSectionTitle({
    super.key,
    required this.icon,
    required this.label,
    this.trailing,
  });

  final Widget icon;
  final String label;
  final Widget? trailing;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: trailing == null
          ? MainAxisAlignment.start
          : MainAxisAlignment.spaceBetween,
      children: [
        Row(
          children: [
            icon,
            const SizedBox(width: 8),
            Text(
              label,
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontSize: 16,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
        if (trailing != null) trailing!,
      ],
    );
  }
}
