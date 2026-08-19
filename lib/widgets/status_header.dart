import 'package:flutter/material.dart';

import '../models/sensor_data.dart';
import '../theme/app_theme.dart';

/// Brief status strip: connection, mode, speed and a live sensor-alert chip.
class StatusHeader extends StatelessWidget {
  final CarStatus status;
  final bool alertActive;
  final String alertLabel;

  const StatusHeader({
    super.key,
    required this.status,
    required this.alertActive,
    required this.alertLabel,
  });

  String get _phaseLabel {
    switch (status.phase) {
      case NavPhase.idle:
        return 'Idle';
      case NavPhase.driving:
        return 'Driving';
      case NavPhase.obstacleStop:
        return 'Obstacle — stopping';
      case NavPhase.reversing:
        return 'Reversing';
      case NavPhase.scanningRight:
        return 'Scanning right';
      case NavPhase.scanningLeft:
        return 'Scanning left';
      case NavPhase.escaping:
        return 'Escaping — fire detected';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(20, 18, 20, 18),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: AppColors.surfaceOutline),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              _ConnectionDot(connected: status.connected),
              const SizedBox(width: 8),
              Text(
                status.connected ? 'Rover linked' : 'Connecting…',
                style: const TextStyle(color: AppColors.textSecondary, fontSize: 13, fontWeight: FontWeight.w500),
              ),
              const Spacer(),
              _ModePill(mode: status.mode),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '${status.speedPercent}',
                      style: const TextStyle(
                        color: AppColors.textPrimary,
                        fontSize: 40,
                        fontWeight: FontWeight.w800,
                        height: 1.0,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      'speed % · $_phaseLabel',
                      style: const TextStyle(color: AppColors.textSecondary, fontSize: 13),
                    ),
                  ],
                ),
              ),
              if (alertActive)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  decoration: BoxDecoration(
                    color: AppColors.danger.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(color: AppColors.danger),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.warning_rounded, color: AppColors.danger, size: 16),
                      const SizedBox(width: 6),
                      ConstrainedBox(
                        constraints: const BoxConstraints(maxWidth: 120),
                        child: Text(
                          alertLabel,
                          maxLines: 2,
                          style: const TextStyle(color: AppColors.danger, fontSize: 11, fontWeight: FontWeight.w700),
                        ),
                      ),
                    ],
                  ),
                ),
            ],
          ),
        ],
      ),
    );
  }
}

class _ConnectionDot extends StatelessWidget {
  final bool connected;
  const _ConnectionDot({required this.connected});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 9,
      height: 9,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: connected ? AppColors.success : AppColors.warning,
        boxShadow: [
          BoxShadow(color: (connected ? AppColors.success : AppColors.warning).withValues(alpha: 0.6), blurRadius: 6),
        ],
      ),
    );
  }
}

class _ModePill extends StatelessWidget {
  final DriveMode mode;
  const _ModePill({required this.mode});

  @override
  Widget build(BuildContext context) {
    final isAuto = mode == DriveMode.auto;
    final color = isAuto ? AppColors.turquoise : AppColors.pink;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color),
      ),
      child: Text(
        isAuto ? 'AUTO' : 'MANUAL',
        style: TextStyle(color: color, fontSize: 12, fontWeight: FontWeight.w800, letterSpacing: 0.5),
      ),
    );
  }
}
