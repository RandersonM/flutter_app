import 'package:flutter/material.dart';
import 'package:opfan/utils/theme.dart';

class NamiHeader extends StatefulWidget {
  const NamiHeader({Key? key}) : super(key: key);

  @override
  State<NamiHeader> createState() => _NamiHeaderState();
}

class _NamiHeaderState extends State<NamiHeader>
    with TickerProviderStateMixin {
  late AnimationController _coinAnimationController;
  late AnimationController _sparkleAnimationController;
  
  late Animation<double> _coinBounceAnimation;
  late Animation<double> _sparkleOpacityAnimation;

  @override
  void initState() {
    super.initState();
    _initializeAnimations();
  }

  void _initializeAnimations() {
    _coinAnimationController = AnimationController(
      duration: const Duration(seconds: 3),
      vsync: this,
    );

    _sparkleAnimationController = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    );

    _coinBounceAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _coinAnimationController,
      curve: Curves.easeInOut,
    ));

    _sparkleOpacityAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _sparkleAnimationController,
      curve: Curves.easeInOut,
    ));

    _coinAnimationController.forward();
    _sparkleAnimationController.repeat(reverse: true);
  }

  @override
  void dispose() {
    _coinAnimationController.dispose();
    _sparkleAnimationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        AnimatedBuilder(
          animation: _sparkleAnimationController,
          builder: (context, child) {
            return Positioned.fill(
              child: CustomPaint(
                painter: SparklePainter(
                  opacity: _sparkleOpacityAnimation.value,
                  color: AppColors.orange[500]!,
                ),
              ),
            );
          },
        ),
        
        Center(
          child: Image.asset(
            'assets/logo/nami.png',
            height: 200,
            width: double.infinity,
            fit: BoxFit.contain,
          ),
        ),
        
        AnimatedBuilder(
          animation: _coinAnimationController,
          builder: (context, child) {
            return Positioned(
              top: 20 + (_coinBounceAnimation.value * 20),
              right: 30,
              child: Icon(
                Icons.monetization_on,
                color: AppColors.orange[500]!,
                size: 24,
              ),
            );
          },
        ),
        
        AnimatedBuilder(
          animation: _coinAnimationController,
          builder: (context, child) {
            return Positioned(
              top: 40 + (_coinBounceAnimation.value * 15),
              left: 30,
              child: Icon(
                Icons.monetization_on,
                color: AppColors.orange[500]!,
                size: 20,
              ),
            );
          },
        ),
        
        AnimatedBuilder(
          animation: _coinAnimationController,
          builder: (context, child) {
            return Positioned(
              top: 60 + (_coinBounceAnimation.value * 25),
              right: 80,
              child: Icon(
                Icons.monetization_on,
                color: AppColors.orange[400]!,
                size: 18,
              ),
            );
          },
        ),
        
        AnimatedBuilder(
          animation: _coinAnimationController,
          builder: (context, child) {
            return Positioned(
              top: 80 + (_coinBounceAnimation.value * 10),
              left: 80,
              child: Icon(
                Icons.monetization_on,
                color: AppColors.orange[600]!,
                size: 22,
              ),
            );
          },
        ),
        
        AnimatedBuilder(
          animation: _coinAnimationController,
          builder: (context, child) {
            return Positioned(
              top: 30 + (_coinBounceAnimation.value * 30),
              right: 120,
              child: Icon(
                Icons.monetization_on,
                color: AppColors.orange[300]!,
                size: 16,
              ),
            );
          },
        ),
      ],
    );
  }
}

class SparklePainter extends CustomPainter {
  final double opacity;
  final Color color;

  SparklePainter({
    required this.opacity,
    required this.color,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color.withValues(alpha: opacity * 0.6)
      ..strokeWidth = 2
      ..strokeCap = StrokeCap.round;

    final sparklePositions = [
      const Offset(50, 30),
      const Offset(150, 50),
      const Offset(250, 40),
      const Offset(100, 120),
      const Offset(200, 100),
      const Offset(300, 80),
      const Offset(80, 80),
      const Offset(180, 30),
      const Offset(280, 120),
      const Offset(120, 60),
      const Offset(220, 90),
      const Offset(320, 50),
      const Offset(70, 110),
      const Offset(170, 70),
      const Offset(270, 30),
      const Offset(90, 100),
      const Offset(190, 40),
      const Offset(290, 80),
      const Offset(110, 90),
      const Offset(210, 60),
      const Offset(310, 110),
    ];

    for (final position in sparklePositions) {
      _drawSparkle(canvas, paint, position);
    }
  }

  void _drawSparkle(Canvas canvas, Paint paint, Offset center) {
    const size = 8.0;
    
    canvas.drawLine(
      Offset(center.dx, center.dy - size),
      Offset(center.dx, center.dy + size),
      paint,
    );
    
    canvas.drawLine(
      Offset(center.dx - size, center.dy),
      Offset(center.dx + size, center.dy),
      paint,
    );
    
    canvas.drawLine(
      Offset(center.dx - size * 0.7, center.dy - size * 0.7),
      Offset(center.dx + size * 0.7, center.dy + size * 0.7),
      paint,
    );
    
    canvas.drawLine(
      Offset(center.dx + size * 0.7, center.dy - size * 0.7),
      Offset(center.dx - size * 0.7, center.dy + size * 0.7),
      paint,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
} 