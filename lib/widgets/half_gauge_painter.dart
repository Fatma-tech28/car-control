import 'dart:math';
import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

class HalfGaugePainter extends CustomPainter {
  final double value;
  final Color trackColor;
  final List<Color> valueGradient;
  final double strokeWidth;

  HalfGaugePainter({
    required this.value,
    required this.trackColor,
    required this.valueGradient,
    this.strokeWidth = 10,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final rect = Rect.fromLTWH(
      strokeWidth / 2,
      strokeWidth / 2 + 2,
      size.width - strokeWidth,
      size.width - strokeWidth,
    );

    // Track
    final track = Paint()
      ..color = trackColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round;

    canvas.drawArc(rect, pi, pi, false, track);

    // Value arc
    final sweep = pi * value.clamp(0.0, 1.0);
    final valuePaint = Paint()
      ..shader = SweepGradient(
        startAngle: pi,
        endAngle: 2 * pi,
        colors: valueGradient,
        stops: const [0.0, 0.35, 0.7, 1.0],
      ).createShader(rect)
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round;

    canvas.drawArc(rect, pi, sweep, false, valuePaint);

    // Needle
    final center = Offset(rect.center.dx, rect.center.dy);
    final needleAngle = pi + sweep;
    final needleLength = rect.width / 2 - strokeWidth * 0.8;
    final needleEnd = Offset(
      center.dx + needleLength * cos(needleAngle),
      center.dy + needleLength * sin(needleAngle),
    );

    final needlePaint = Paint()
      ..color = AppColors.blue600
      ..strokeWidth = 2.5
      ..strokeCap = StrokeCap.round;

    canvas.drawLine(center, needleEnd, needlePaint);

    // Needle pivot
    canvas.drawCircle(
      center,
      4,
      Paint()..color = AppColors.blue600,
    );
    canvas.drawCircle(
      center,
      2,
      Paint()..color = Colors.white,
    );
  }

  @override
  bool shouldRepaint(covariant HalfGaugePainter oldDelegate) {
    return oldDelegate.value != value ||
        oldDelegate.valueGradient != valueGradient ||
        oldDelegate.strokeWidth != strokeWidth;
  }
}
