import 'package:flutter/material.dart';

import '../models/sensor_data.dart';
import '../theme/app_theme.dart';
import 'half_gauge_painter.dart';

/// Rounded card with a semi-circular gauge, styled after the light
/// credit-score reference card, adapted to the app's blue brand ramp and
/// placed on the app's dark surfaces.
class HalfGaugeCard extends StatelessWidget {
  final SensorKind kind;
  final String bigValue;
  final String statusLabel;
  final Color statusColor;
  final double value; // 0..1 normalized for the gauge sweep
  final IconData icon;
  final VoidCallback onTap;

  const HalfGaugeCard({
    super.key,
    required this.kind,
    required this.bigValue,
    required this.statusLabel,
    required this.statusColor,
    required this.value,
    required this.icon,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(24),
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 14),
          decoration: BoxDecoration(
            color: AppColors.blue50,
            borderRadius: BorderRadius.circular(24),
            boxShadow: const [BoxShadow(color: Colors.black26, blurRadius: 10, offset: Offset(0, 4))],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(icon, size: 16, color: AppColors.blue500),
                  const SizedBox(width: 6),
                  Expanded(
                    child: Text(
                      kind.label,
                      style: const TextStyle(
                        color: AppColors.textOnLight,
                        fontWeight: FontWeight.w700,
                        fontSize: 13,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  const Icon(Icons.chevron_right_rounded, size: 18, color: AppColors.blue400),
                ],
              ),
              const SizedBox(height: 4),
              AspectRatio(
                aspectRatio: 2,
                child: CustomPaint(
                  painter: HalfGaugePainter(
                    value: value,
                    trackColor: AppColors.blue100,
                    valueGradient: AppColors.gaugeGradient,
                  ),
                  child: Align(
                    alignment: Alignment.bottomCenter,
                    child: Padding(
                      padding: const EdgeInsets.only(bottom: 2),
                      child: Text(
                        bigValue,
                        style: const TextStyle(
                          color: AppColors.textOnLight,
                          fontSize: 22,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 6),
              Container(
                alignment: Alignment.center,
                padding: const EdgeInsets.symmetric(vertical: 5),
                decoration: BoxDecoration(
                  color: statusColor.withValues(alpha: 0.14),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Text(
                  statusLabel,
                  style: TextStyle(color: statusColor, fontWeight: FontWeight.w700, fontSize: 12),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
