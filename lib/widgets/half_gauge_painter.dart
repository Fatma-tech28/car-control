import 'dart:math';
import 'package:flutter/material.dart';

/// Paints a half-circle (180°) gauge track plus a colored value arc and a
/// needle, matching the reference credit-score-style card.
class HalfGaugePainter extends CustomPainter {
  final double value; // 0..1
  final Color trackColor;
  final List<Color> valueGradient;
  final double strokeWidth;

  HalfGaugePainter({
    required this.value,
    required this.trackColor,
    required this.valueGradient,
    this.strokeWidth = 14,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final rect = Rect.fromLTWH(
      strokeWidth / 2,
      strokeWidth / 2,
      size.width - strokeWidth,
      size.width - strokeWidth,
    );

    final track = Paint()
      ..color = trackColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round;

    // Background half-circle track, from 180° to 360° (the top half).
    canvas.drawArc(rect, pi, pi, false, track);

    final sweep = pi * value.clamp(0.0, 1.0);
    final valuePaint = Paint()
      ..shader = SweepGradient(
        startAngle: pi,
        endAngle: 2 * pi,
        colors: valueGradient,
      ).createShader(rect)
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round;

    canvas.drawArc(rect, pi, sweep, false, valuePaint);

    // Needle
    final center = Offset(rect.center.dx, rect.center.dy);
    final needleAngle = pi + sweep;
    final needleLength = rect.width / 2 - strokeWidth;
    final needleEnd = Offset(
      center.dx + needleLength * cos(needleAngle),
      center.dy + needleLength * sin(needleAngle),
    );
    final needlePaint = Paint()
      ..color = valueGradient.last
      ..strokeWidth = 3
      ..strokeCap = StrokeCap.round;
    canvas.drawLine(center, needleEnd, needlePaint);
    canvas.drawCircle(center, 4.5, Paint()..color = valueGradient.last);
  }

  @override
  bool shouldRepaint(covariant HalfGaugePainter oldDelegate) {
    return oldDelegate.value != value || oldDelegate.valueGradient != valueGradient;
  }
}
