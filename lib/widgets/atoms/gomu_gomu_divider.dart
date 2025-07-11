import 'package:flutter/material.dart';

class GomuGomuDivider extends StatelessWidget {
  final double height;
  final Color? color;
  final double thickness;
  final double waveHeight;
  final double waveLength;
  final int stripes;

  const GomuGomuDivider({
    Key? key,
    this.height = 8.0,
    this.color = Colors.orange,
    this.thickness = 0.5,
    this.waveHeight = 2.0,
    this.waveLength = 15.0,
    this.stripes = 3,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      painter: GomuGomuDividerPainter(
        color: color ?? Colors.orange,
        thickness: thickness,
        waveHeight: waveHeight,
        waveLength: waveLength,
        stripes: stripes,
      ),
      child: SizedBox(
        height: height,
        width: double.infinity,
      ),
    );
  }
}

class GomuGomuDividerPainter extends CustomPainter {
  final Color color;
  final double thickness;
  final double waveHeight;
  final double waveLength;
  final int stripes;

  GomuGomuDividerPainter({
    required this.color,
    required this.thickness,
    required this.waveHeight,
    required this.waveLength,
    required this.stripes,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..strokeWidth = thickness
      ..strokeCap = StrokeCap.round
      ..style = PaintingStyle.stroke;

    final centerY = size.height / 2;
    final stripeHeight = size.height / stripes;
    
    for (int i = 0; i < stripes; i++) {
      final stripeY = centerY - (stripes - 1) * stripeHeight / 2 + i * stripeHeight;
      
      final path = Path();
      path.moveTo(0, stripeY);
      
      for (double x = 0; x <= size.width; x += waveLength) {
        final nextX = x + waveLength;
        final waveOffset = (i % 2 == 0 ? 1 : -1) * waveHeight;
        final controlY = stripeY + (x % (waveLength * 2) < waveLength ? waveOffset : -waveOffset);
        
        if (nextX <= size.width) {
          path.quadraticBezierTo(
            x + waveLength / 2,
            controlY,
            nextX,
            stripeY,
          );
        }
      }

      // Desenha a linha
      canvas.drawPath(path, paint);
      
      // Adiciona um efeito de brilho
      final glowPaint = Paint()
        ..color = color.withValues(alpha: 0.1)
        ..strokeWidth = thickness + 2
        ..strokeCap = StrokeCap.round
        ..style = PaintingStyle.stroke;
      
      canvas.drawPath(path, glowPaint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
} 