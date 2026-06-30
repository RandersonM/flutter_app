import 'package:flutter/material.dart';
import 'dart:math' as math;

class GomuGomuDivider extends StatelessWidget {
  final double height;
  final Color? color;
  final double thickness;
  final double spiralRadius;
  final double spiralSpacing;
  final int spiralCount;
  final double spiralTurns;

  const GomuGomuDivider({
    super.key,
    this.height = 40.0,
    this.color = const Color(0xFFE91E63),
    this.thickness = 2.0,
    this.spiralRadius = 12.0,
    this.spiralSpacing = 30.0,
    this.spiralCount = 6,
    this.spiralTurns = 2.5,
  });

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      painter: GomuGomuDividerPainter(
        color: color ?? const Color(0xFFE91E63),
        thickness: thickness,
        spiralRadius: spiralRadius,
        spiralSpacing: spiralSpacing,
        spiralCount: spiralCount,
        spiralTurns: spiralTurns,
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
  final double spiralRadius;
  final double spiralSpacing;
  final int spiralCount;
  final double spiralTurns;

  GomuGomuDividerPainter({
    required this.color,
    required this.thickness,
    required this.spiralRadius,
    required this.spiralSpacing,
    required this.spiralCount,
    required this.spiralTurns,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..strokeWidth = thickness
      ..strokeCap = StrokeCap.round
      ..style = PaintingStyle.stroke;

    final glowPaint = Paint()
      ..color = color.withValues(alpha: 0.3)
      ..strokeWidth = thickness + 2
      ..strokeCap = StrokeCap.round
      ..style = PaintingStyle.stroke;

    final centerY = size.height / 2;
    final availableWidth = size.width - (spiralRadius * 2);
    final actualSpacing =
        spiralCount > 1 ? availableWidth / (spiralCount - 1) : 0;

    for (int i = 0; i < spiralCount; i++) {
      final spiralCenterX = spiralRadius + (i * actualSpacing);

      _drawSpiral(canvas, paint, glowPaint, spiralCenterX, centerY);

      if (i < spiralCount - 1) {
        final nextSpiralX = spiralRadius + ((i + 1) * actualSpacing);
        _drawConnection(canvas, paint, glowPaint, spiralCenterX, centerY,
            nextSpiralX, centerY);
      }
    }
  }

  void _drawSpiral(Canvas canvas, Paint paint, Paint glowPaint, double centerX,
      double centerY) {
    final path = Path();
    final points = <Offset>[];

    final totalAngle = spiralTurns * 2 * math.pi;
    final angleStep = totalAngle / 50;

    for (int i = 0; i <= 50; i++) {
      final angle = i * angleStep;
      final radius = spiralRadius * (1 - (angle / totalAngle));
      final x = centerX + radius * math.cos(angle);
      final y = centerY + radius * math.sin(angle);
      points.add(Offset(x, y));
    }

    if (points.isNotEmpty) {
      path.moveTo(points.first.dx, points.first.dy);
      for (int i = 1; i < points.length; i++) {
        path.lineTo(points[i].dx, points[i].dy);
      }
    }

    canvas.drawPath(path, glowPaint);
    canvas.drawPath(path, paint);
  }

  void _drawConnection(Canvas canvas, Paint paint, Paint glowPaint,
      double startX, double startY, double endX, double endY) {
    final path = Path();

    final startPoint = Offset(startX + spiralRadius, startY);
    final endPoint = Offset(endX - spiralRadius, endY);

    path.moveTo(startPoint.dx, startPoint.dy);

    final distance = endPoint.dx - startPoint.dx;
    const waveHeight = 8.0;
    const waveCount = 2;

    for (int i = 0; i <= 20; i++) {
      final progress = i / 20.0;
      final x = startPoint.dx + (distance * progress);
      final wave = math.sin(progress * math.pi * waveCount) * waveHeight;
      final y = startPoint.dy + wave;

      if (i == 0) {
        path.moveTo(x, y);
      } else {
        path.lineTo(x, y);
      }
    }

    canvas.drawPath(path, glowPaint);
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
