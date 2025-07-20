import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

class FuturisticBackground extends StatelessWidget {
  final Widget child;
  final Color? overlayColor;
  final double opacity;

  const FuturisticBackground({
    Key? key,
    required this.child,
    this.overlayColor,
    this.opacity = 0.1,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        // Background com gradiente futurista
        Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                Colors.purple.withValues(alpha: 0.8),
                Colors.blue.withValues(alpha: 0.6),
                Colors.orange.withValues(alpha: 0.4),
                Colors.red.withValues(alpha: 0.6),
              ],
              stops: const [0.0, 0.3, 0.7, 1.0],
            ),
          ),
        ),
        
        // Padrão de fundo com gomu-gomu
        Positioned.fill(
          child: Opacity(
            opacity: opacity,
            child: SvgPicture.asset(
              'assets/svg/gomu-gomu.svg',
              fit: BoxFit.cover,
              colorFilter: ColorFilter.mode(
                Colors.white.withValues(alpha: 0.3),
                BlendMode.srcIn,
              ),
            ),
          ),
        ),
        
        // Overlay adicional para melhorar legibilidade
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

  const AnimatedFuturisticBackground({
    Key? key,
    required this.child,
    this.overlayColor,
    this.opacity = 0.1,
    this.animationDuration = const Duration(seconds: 3),
  }) : super(key: key);

  @override
  State<AnimatedFuturisticBackground> createState() => _AnimatedFuturisticBackgroundState();
}

class _AnimatedFuturisticBackgroundState extends State<AnimatedFuturisticBackground>
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
    
    _rotationAnimation = Tween<double>(
      begin: 0,
      end: 2 * 3.14159,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.linear,
    ));
    
    _animationController.repeat();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        // Background com gradiente futurista animado
        AnimatedBuilder(
          animation: _animationController,
          builder: (context, child) {
            return Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    Colors.purple.withValues(alpha: 0.8),
                    Colors.blue.withValues(alpha: 0.6),
                    Colors.orange.withValues(alpha: 0.4),
                    Colors.red.withValues(alpha: 0.6),
                  ],
                  stops: const [0.0, 0.3, 0.7, 1.0],
                  transform: GradientRotation(_rotationAnimation.value),
                ),
              ),
            );
          },
        ),
        
        // Padrão de fundo com gomu-gomu
        Positioned.fill(
          child: Opacity(
            opacity: widget.opacity,
            child: SvgPicture.asset(
              'assets/svg/gomu-gomu.svg',
              fit: BoxFit.cover,
              colorFilter: ColorFilter.mode(
                Colors.white.withValues(alpha: 0.3),
                BlendMode.srcIn,
              ),
            ),
          ),
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