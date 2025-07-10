import 'package:flutter/material.dart';
import 'package:opfan/utils/theme.dart';


class WavyDivider extends StatelessWidget {
  final double height;
  final Color? color;
  final double thickness;
  final double waveHeight;
  final double waveLength;

  const WavyDivider({
    Key? key,
    this.height = 1.0,
    this.color = Colors.blue,
    this.thickness = 1.0,
    this.waveHeight = 4.0,
    this.waveLength = 20.0,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      painter: WavyDividerPainter(
        color: color ?? Theme.of(context).dividerColor,
        thickness: thickness,
        waveHeight: waveHeight,
        waveLength: waveLength,
      ),
      child: SizedBox(
        height: height,
        width: double.infinity,
      ),
    );
  }
}

class WavyDividerPainter extends CustomPainter {
  final Color color;
  final double thickness;
  final double waveHeight;
  final double waveLength;

  WavyDividerPainter({
    required this.color,
    required this.thickness,
    required this.waveHeight,
    required this.waveLength,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..strokeWidth = thickness
      ..strokeCap = StrokeCap.round
      ..style = PaintingStyle.stroke;

    final path = Path();
    final centerY = size.height / 2;
    
    path.moveTo(0, centerY);
    
    for (double x = 0; x <= size.width; x += waveLength) {
      final nextX = x + waveLength;
      final controlY = centerY + (x % (waveLength * 2) < waveLength ? waveHeight : -waveHeight);
      
      if (nextX <= size.width) {
        path.quadraticBezierTo(
          x + waveLength / 2,
          controlY,
          nextX,
          centerY,
        );
      }
    }

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
} 