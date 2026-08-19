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
        final status = car.status;

        return Scaffold(
          backgroundColor: AppColors.background,
          body: SafeArea(
            child: CustomScrollView(
              slivers: [
                // Header
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(24, 16, 24, 8),
                    child: Row(
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                'Sensor Dashboard',
                                style: TextStyle(
                                  fontSize: 26,
                                  fontWeight: FontWeight.w800,
                                  color: AppColors.textPrimary,
                                  height: 1.2,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                _formatNow(),
                                style: const TextStyle(
                                  fontSize: 13,
                                  color: AppColors.textSecondary,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ],
                          ),
                        ),
                        _LivePill(connected: status.connected),
                      ],
                    ),
                  ),
                ),

                // Summary chips
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(24, 16, 24, 8),
                    child: Row(
                      children: [
                        _SummaryChip(
                          label: 'Mode',
                          value: status.mode == DriveMode.auto ? 'Auto' : 'Manual',
                          icon: status.mode == DriveMode.auto
                              ? Icons.auto_mode_rounded
                              : Icons.touch_app_rounded,
                          color: AppColors.blue500,
                        ),
                        const SizedBox(width: 10),
                        _SummaryChip(
                          label: 'Speed',
                          value: '${status.speedPercent}%',
                          icon: Icons.speed_rounded,
                          color: AppColors.blue400,
                        ),
                        const SizedBox(width: 10),
                        _SummaryChip(
                          label: 'Alerts',
                          value: car.alertActive ? 'Active' : 'None',
                          icon: car.alertActive
                              ? Icons.notification_important_rounded
                              : Icons.notifications_none_rounded,
                          color: car.alertActive ? AppColors.danger : AppColors.success,
                        ),
                      ],
                    ),
                  ),
                ),

                // Section title
                const SliverToBoxAdapter(
                  child: Padding(
                    padding: EdgeInsets.fromLTRB(24, 28, 24, 12),
                    child: Text(
                      'Live Sensors',
                      style: TextStyle(
                        fontSize: 17,
                        fontWeight: FontWeight.w700,
                        color: AppColors.textPrimary,
                      ),
                    ),
                  ),
                ),

                // Sensor grid
                SliverPadding(
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  sliver: SliverGrid(
                    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                      mainAxisSpacing: 16,
                      crossAxisSpacing: 16,
                      childAspectRatio: 0.82,
                    ),
                    delegate: SliverChildListDelegate([
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
                        unit: 'ppm',
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
                        bigValue: '${s.temperature.toStringAsFixed(0)}°',
                        unit: '/ ${s.humidity.toStringAsFixed(0)}%',
                        statusLabel: s.temperature > 38 ? 'Hot' : 'Normal',
                        statusColor: s.temperature > 38 ? AppColors.warning : AppColors.success,
                        onTap: () => _openDetail(context, SensorKind.humidityTemp),
                      ),
                    ]),
                  ),
                ),

                // Bottom padding for safe scroll
                const SliverPadding(padding: EdgeInsets.only(bottom: 32)),
              ],
            ),
          ),
        );
      },
    );
  }

  String _formatNow() {
    final now = DateTime.now();
    final months = ['Jan','Feb','Mar','Apr','May','Jun','Jul','Aug','Sep','Oct','Nov','Dec'];
    return '${months[now.month - 1]} ${now.day}, ${now.year}';
  }

  void _openDetail(BuildContext context, SensorKind kind) {
    Navigator.of(context).push(
      MaterialPageRoute(builder: (_) => SensorDetailPage(kind: kind)),
    );
  }
}

class _LivePill extends StatelessWidget {
  final bool connected;
  const _LivePill({required this.connected});

  @override
  Widget build(BuildContext context) {
    final color = connected ? AppColors.success : AppColors.warning;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: color.withOpacity(0.10),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withOpacity(0.25)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 7,
            height: 7,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: color,
              boxShadow: [
                BoxShadow(color: color.withOpacity(0.5), blurRadius: 6),
              ],
            ),
          ),
          const SizedBox(width: 6),
          Text(
            connected ? 'Live' : 'Offline',
            style: TextStyle(
              color: color,
              fontSize: 12,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }
}

class _SummaryChip extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;
  final Color color;

  const _SummaryChip({
    required this.label,
    required this.value,
    required this.icon,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 12),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppColors.surfaceOutline),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(icon, size: 14, color: color),
                const SizedBox(width: 6),
                Text(
                  label,
                  style: const TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              value,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w800,
                color: AppColors.textPrimary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
