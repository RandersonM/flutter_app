import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

class FuturisticBackground extends StatelessWidget {
  final Widget child;
  final Color? overlayColor;
  final double opacity;
  final bool useThemeColors;
  final Color? customBackgroundColor;

  const FuturisticBackground({
    super.key,
    required this.child,
    this.overlayColor,
    this.opacity = 0.1,
    this.useThemeColors = false,
    this.customBackgroundColor,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    List<Color> gradientColors;
    if (useThemeColors) {
      gradientColors = [
        colorScheme.primaryContainer,
        colorScheme.primaryContainer.withValues(alpha: 0.8),
        colorScheme.primaryContainer.withValues(alpha: 0.6),
        colorScheme.primaryContainer.withValues(alpha: 0.4),
      ];
    } else {
      gradientColors = [
        Colors.purple.withValues(alpha: 0.8),
        Colors.blue.withValues(alpha: 0.6),
        Colors.orange.withValues(alpha: 0.4),
        Colors.red.withValues(alpha: 0.6),
      ];
    }

    return Stack(
      children: [
        Container(
          decoration: BoxDecoration(
            color: customBackgroundColor != null
                ? customBackgroundColor!.withValues(alpha: 0.9)
                : (useThemeColors
                      ? colorScheme.primaryContainer.withValues(alpha: 0.9)
                      : null),
            gradient: (customBackgroundColor != null || useThemeColors)
                ? null
                : LinearGradient(
                    begin: Alignment.center,
                    end: Alignment.bottomCenter,
                    colors: gradientColors,
                    stops: const [0.0, 0.3, 0.7, 1.0],
                  ),
          ),
        ),

        Positioned.fill(
          child: Opacity(
            opacity: opacity,
            child: SvgPicture.asset(
              'assets/svg/gomu-gomu.svg',
              fit: BoxFit.cover,
              colorFilter: ColorFilter.mode(
                Theme.of(context).colorScheme.primary.withValues(alpha: 0.8),
                BlendMode.srcIn,
              ),
            ),
          ),
        ),

        if (overlayColor != null)
          Container(
            decoration: BoxDecoration(
              color: overlayColor!.withValues(alpha: 0.1),
            ),
          ),

        // Conteúdo principal
        child,
      ],
    );
  }
}

class AnimatedFuturisticBackground extends StatefulWidget {
  final Widget child;
  final Color? overlayColor;
  final double opacity;
  final Duration animationDuration;
  final bool useThemeColors;
  final Color? customBackgroundColor;

  const AnimatedFuturisticBackground({
    super.key,
    required this.child,
    this.overlayColor,
    this.opacity = 0.1,
    this.animationDuration = const Duration(seconds: 3),
    this.useThemeColors = false,
    this.customBackgroundColor,
  });

  @override
  State<AnimatedFuturisticBackground> createState() =>
      _AnimatedFuturisticBackgroundState();
}

class _AnimatedFuturisticBackgroundState
    extends State<AnimatedFuturisticBackground>
    with TickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _rotationAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: widget.animationDuration,
      vsync: this,
    );

    _rotationAnimation = Tween<double>(begin: 0, end: 2 * 3.14159).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.linear),
    );

    _animationController.repeat();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    List<Color> gradientColors;
    gradientColors = [
      colorScheme.surfaceContainer.withValues(alpha: 0.1),
      colorScheme.surfaceContainer.withValues(alpha: 0.2),
      colorScheme.primaryContainer.withValues(alpha: 1.0),
      colorScheme.onTertiaryContainer.withValues(alpha: 0.8),
      colorScheme.tertiary.withValues(alpha: 0.6),
      colorScheme.onTertiary.withValues(alpha: 0.4),
      colorScheme.surfaceContainer.withValues(alpha: 0.3),
      colorScheme.surfaceContainer.withValues(alpha: 0.7),
      colorScheme.surfaceContainer,
    ];

    return Stack(
      children: [
        AnimatedBuilder(
          animation: _animationController,
          builder: (context, child) {
            return Container(
              decoration: BoxDecoration(
                color: Colors.white,
                gradient: RadialGradient(
                  center: Alignment.center,
                  radius: 0.9,
                  colors: gradientColors,
                  stops: const [0.0, 0.1, 0.2, 0.3, 0.4, 0.5, 0.6, 0.8, 1.0],
                  transform: GradientRotation(_rotationAnimation.value),
                ),
              ),
            );
          },
        ),

        // Overlay adicional para melhorar legibilidade
        if (widget.overlayColor != null)
          Container(
            decoration: BoxDecoration(
              color: widget.overlayColor!.withValues(alpha: 0.1),
            ),
          ),

        // Conteúdo principal
        widget.child,
      ],
    );
  }
}
