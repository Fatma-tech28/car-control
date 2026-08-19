import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/sensor_data.dart';
import '../state/car_state.dart';
import '../theme/app_theme.dart';
import '../widgets/alert_overlay.dart';
import '../widgets/directional_pad.dart';
import '../widgets/mode_toggle.dart';
import '../widgets/status_header.dart';

class ControlPage extends StatelessWidget {
  const ControlPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<CarState>(
      builder: (context, car, _) {
        final status = car.status;
        final manual = status.mode == DriveMode.manual;

        return Scaffold(
          appBar: AppBar(title: const Text('Inspection Rover')),
          body: SafeArea(
            child: Stack(
              children: [
                if (car.connecting)
                  const Center(child: CircularProgressIndicator(color: AppColors.turquoise))
                else
                  Padding(
                    padding: const EdgeInsets.fromLTRB(20, 8, 20, 20),
                    child: Column(
                      children: [
                        StatusHeader(
                          status: status,
                          alertActive: car.alertActive,
                          alertLabel: car.alert.message,
                        ),
                        const SizedBox(height: 18),
                        ModeToggle(
                          mode: status.mode,
                          onChanged: (m) => car.setMode(m),
                        ),
                        const SizedBox(height: 8),
                        Expanded(
                          child: Center(
                            child: manual
                                ? DirectionalPad(
                                    enabled: status.connected,
                                    onPressStart: (cmd) => car.pressCommand(cmd),
                                    onPressEnd: () => car.releaseCommand(),
                                  )
                                : _AutoModePanel(car: car),
                          ),
                        ),
                        _SensorStrip(sensors: car.sensors),
                        const SizedBox(height: 14),
                        SizedBox(
                          width: double.infinity,
                          child: OutlinedButton.icon(
                            onPressed: car.alertActive ? car.dismissAlert : null,
                            icon: const Icon(Icons.notifications_off_rounded),
                            label: const Text('Stop Alert'),
                            style: OutlinedButton.styleFrom(
                              foregroundColor: AppColors.danger,
                              side: BorderSide(color: car.alertActive ? AppColors.danger : AppColors.surfaceOutline),
                              padding: const EdgeInsets.symmetric(vertical: 16),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                if (car.alertActive)
                  Positioned.fill(
                    child: AlertOverlay(alert: car.alert, onDismiss: car.dismissAlert),
                  ),
              ],
            ),
          ),
        );
      },
    );
  }
}

class _AutoModePanel extends StatelessWidget {
  final CarState car;
  const _AutoModePanel({required this.car});

  String get _phaseCaption {
    switch (car.status.phase) {
      case NavPhase.idle:
        return 'Starting patrol…';
      case NavPhase.driving:
        return 'Patrolling forward at moderate speed';
      case NavPhase.obstacleStop:
        return 'Obstacle ahead — stopping';
      case NavPhase.reversing:
        return 'Reversing two steps';
      case NavPhase.scanningRight:
        return 'Servo scanning right';
      case NavPhase.scanningLeft:
        return 'Right blocked — scanning left';
      case NavPhase.escaping:
        return 'Flame detected — reversing at max speed';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 190,
          height: 190,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            gradient: RadialGradient(
              colors: [AppColors.turquoise.withValues(alpha: 0.25), AppColors.surface],
            ),
            border: Border.all(color: AppColors.turquoise, width: 2),
          ),
          child: const Icon(Icons.explore_rounded, color: AppColors.turquoise, size: 74),
        ),
        const SizedBox(height: 20),
        Text(
          _phaseCaption,
          textAlign: TextAlign.center,
          style: const TextStyle(color: AppColors.textSecondary, fontSize: 14, fontWeight: FontWeight.w500),
        ),
      ],
    );
  }
}

class _SensorStrip extends StatelessWidget {
  final SensorSnapshot sensors;
  const _SensorStrip({required this.sensors});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        _chip(Icons.straighten_rounded, '${sensors.ultrasonicCm.toStringAsFixed(0)} cm', AppColors.turquoise),
        const SizedBox(width: 8),
        _chip(Icons.local_fire_department_rounded, sensors.flameDetected ? 'Fire!' : 'Clear',
            sensors.flameDetected ? AppColors.danger : AppColors.textSecondary),
        const SizedBox(width: 8),
        _chip(Icons.cloud_rounded, '${sensors.gasPpm.toStringAsFixed(0)} ppm', AppColors.blue300),
      ],
    );
  }

  Widget _chip(IconData icon, String label, Color color) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 10),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: AppColors.surfaceOutline),
        ),
        child: Column(
          children: [
            Icon(icon, color: color, size: 16),
            const SizedBox(height: 4),
            Text(label, style: TextStyle(color: color, fontSize: 11, fontWeight: FontWeight.w700)),
          ],
        ),
      ),
    );
  }
}
