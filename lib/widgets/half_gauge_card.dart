import 'package:flutter/material.dart';

import '../models/sensor_data.dart';
import '../theme/app_theme.dart';
import 'half_gauge_painter.dart';

class HalfGaugeCard extends StatelessWidget {
  final SensorKind kind;
  final String bigValue;
  final String? unit;
  final String statusLabel;
  final Color statusColor;
  final double value;
  final IconData icon;
  final VoidCallback onTap;

  const HalfGaugeCard({
    super.key,
    required this.kind,
    required this.bigValue,
    this.unit,
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
      borderRadius: BorderRadius.circular(20),
      child: InkWell(
        borderRadius: BorderRadius.circular(20),
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.fromLTRB(16, 14, 16, 12),
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: AppColors.surfaceOutline),
            boxShadow: [
              BoxShadow(
                color: AppColors.blue500.withOpacity(0.04),
                blurRadius: 12,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Title row
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(6),
                    decoration: BoxDecoration(
                      color: AppColors.blue50,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Icon(icon, size: 14, color: AppColors.blue500),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      kind.label,
                      style: const TextStyle(
                        color: AppColors.textPrimary,
                        fontWeight: FontWeight.w700,
                        fontSize: 12.5,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  Icon(
                    Icons.chevron_right_rounded,
                    size: 16,
                    color: AppColors.textSecondary.withOpacity(0.5),
                  ),
                ],
              ),

              const SizedBox(height: 6),

              // Gauge
              Expanded(
                child: AspectRatio(
                  aspectRatio: 2.1,
                  child: CustomPaint(
                    painter: HalfGaugePainter(
                      value: value,
                      trackColor: AppColors.blue100,
                      valueGradient: AppColors.gaugeGradient,
                      strokeWidth: 10,
                    ),
                    child: Align(
                      alignment: Alignment.bottomCenter,
                      child: Padding(
                        padding: const EdgeInsets.only(bottom: 2),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            Text(
                              bigValue,
                              style: const TextStyle(
                                color: AppColors.textPrimary,
                                fontSize: 20,
                                fontWeight: FontWeight.w800,
                                height: 1.0,
                              ),
                            ),
                            if (unit != null)
                              Padding(
                                padding: const EdgeInsets.only(bottom: 2, left: 2),
                                child: Text(
                                  unit!,
                                  style: TextStyle(
                                    color: AppColors.textSecondary.withOpacity(0.8),
                                    fontSize: 11,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 8),

              // Status pill
              Container(
                alignment: Alignment.center,
                padding: const EdgeInsets.symmetric(vertical: 6),
                decoration: BoxDecoration(
                  color: statusColor.withOpacity(0.08),
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: statusColor.withOpacity(0.18)),
                ),
                child: Text(
                  statusLabel,
                  style: TextStyle(
                    color: statusColor,
                    fontWeight: FontWeight.w700,
                    fontSize: 11.5,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
