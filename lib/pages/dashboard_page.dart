import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/sensor_data.dart';
import '../state/car_state.dart';
import '../theme/app_theme.dart';
import '../widgets/half_gauge_card.dart';
import 'sensor_detail_page.dart';

class DashboardPage extends StatelessWidget {
  const DashboardPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<CarState>(
      builder: (context, car, _) {
        final s = car.sensors;
        return Scaffold(
          appBar: AppBar(title: const Text('Sensor Dashboard')),
          body: SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: GridView.count(
                crossAxisCount: 2,
                mainAxisSpacing: 16,
                crossAxisSpacing: 16,
                childAspectRatio: 0.86,
                children: [
                  HalfGaugeCard(
                    kind: SensorKind.flame,
                    icon: Icons.local_fire_department_rounded,
                    value: s.flameDetected ? 1 : 0.08,
                    bigValue: s.flameDetected ? 'FIRE' : 'Clear',
                    statusLabel: s.flameDetected ? 'Danger' : 'Normal',
                    statusColor: s.flameDetected ? AppColors.danger : AppColors.success,
                    onTap: () => _openDetail(context, SensorKind.flame),
                  ),
                  HalfGaugeCard(
                    kind: SensorKind.gas,
                    icon: Icons.cloud_rounded,
                    value: (s.gasPpm / 420).clamp(0, 1),
                    bigValue: '${s.gasPpm.toStringAsFixed(0)}',
                    statusLabel: s.gasPpm > 300 ? 'High' : 'Normal',
                    statusColor: s.gasPpm > 300 ? AppColors.warning : AppColors.success,
                    onTap: () => _openDetail(context, SensorKind.gas),
                  ),
                  HalfGaugeCard(
                    kind: SensorKind.pir,
                    icon: Icons.sensors_rounded,
                    value: s.pirMotion ? 1 : 0.05,
                    bigValue: s.pirMotion ? 'Motion' : 'Still',
                    statusLabel: s.pirMotion ? 'Detected' : 'Normal',
                    statusColor: s.pirMotion ? AppColors.warning : AppColors.success,
                    onTap: () => _openDetail(context, SensorKind.pir),
                  ),
                  HalfGaugeCard(
                    kind: SensorKind.humidityTemp,
                    icon: Icons.thermostat_rounded,
                    value: (s.temperature / 45).clamp(0, 1),
                    bigValue: '${s.temperature.toStringAsFixed(0)}°/${s.humidity.toStringAsFixed(0)}%',
                    statusLabel: s.temperature > 38 ? 'Hot' : 'Normal',
                    statusColor: s.temperature > 38 ? AppColors.warning : AppColors.success,
                    onTap: () => _openDetail(context, SensorKind.humidityTemp),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  void _openDetail(BuildContext context, SensorKind kind) {
    Navigator.of(context).push(
      MaterialPageRoute(builder: (_) => SensorDetailPage(kind: kind)),
    );
  }
}
