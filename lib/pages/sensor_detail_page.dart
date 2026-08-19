import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/sensor_data.dart';
import '../state/car_state.dart';
import '../theme/app_theme.dart';
import '../widgets/trend_chart.dart';

class SensorDetailPage extends StatefulWidget {
  final SensorKind kind;
  const SensorDetailPage({super.key, required this.kind});

  @override
  State<SensorDetailPage> createState() => _SensorDetailPageState();
}

class _SensorDetailPageState extends State<SensorDetailPage> {
  late Future<List<TimeSeriesPoint>> _future;

  @override
  void initState() {
    super.initState();
    _future = context.read<CarState>().history(widget.kind);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('${widget.kind.label} report')),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _SummaryCard(kind: widget.kind),
              const SizedBox(height: 18),
              FutureBuilder<List<TimeSeriesPoint>>(
                future: _future,
                builder: (context, snap) {
                  if (snap.connectionState != ConnectionState.done) {
                    return Container(
                      height: 280,
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                        color: AppColors.surface,
                        borderRadius: BorderRadius.circular(24),
                      ),
                      child: const CircularProgressIndicator(color: AppColors.turquoise),
                    );
                  }
                  if (snap.hasError) {
                    return Container(
                      height: 200,
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                        color: AppColors.surface,
                        borderRadius: BorderRadius.circular(24),
                      ),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(Icons.error_outline_rounded, color: AppColors.danger),
                          const SizedBox(height: 8),
                          const Text('Could not load history', style: TextStyle(color: AppColors.textSecondary)),
                          TextButton(
                            onPressed: () => setState(() => _future = context.read<CarState>().history(widget.kind)),
                            child: const Text('Retry'),
                          ),
                        ],
                      ),
                    );
                  }
                  final points = snap.data ?? [];
                  return TrendChart(points: points, unit: widget.kind.unit);
                },
              ),
              const SizedBox(height: 18),
              Text(
                'About this sensor',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700),
              ),
              const SizedBox(height: 8),
              Text(
                _description(widget.kind),
                style: const TextStyle(color: AppColors.textSecondary, height: 1.5),
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _description(SensorKind kind) {
    switch (kind) {
      case SensorKind.flame:
        return 'The flame sensor watches for infrared signatures from open flame. A detection immediately triggers the full-screen alert and, in Auto mode, an automatic maximum-speed reverse escape.';
      case SensorKind.gas:
        return 'The gas sensor (MQ-2 style) reports an approximate ppm reading for combustible/smoke gases along the inspection route.';
      case SensorKind.pir:
        return 'The passive infrared sensor flags nearby motion, useful for spotting personnel or moving machinery during unattended patrols.';
      case SensorKind.humidityTemp:
        return 'Combined humidity and temperature readings help flag overheating equipment or unsafe environmental conditions in the inspected area.';
    }
  }
}

class _SummaryCard extends StatelessWidget {
  final SensorKind kind;
  const _SummaryCard({required this.kind});

  @override
  Widget build(BuildContext context) {
    return Consumer<CarState>(
      builder: (context, car, _) {
        final s = car.sensors;
        String value;
        switch (kind) {
          case SensorKind.flame:
            value = s.flameDetected ? 'Flame detected' : 'No flame detected';
            break;
          case SensorKind.gas:
            value = '${s.gasPpm.toStringAsFixed(0)} ppm';
            break;
          case SensorKind.pir:
            value = s.pirMotion ? 'Motion detected' : 'No motion';
            break;
          case SensorKind.humidityTemp:
            value = '${s.temperature.toStringAsFixed(1)}°C · ${s.humidity.toStringAsFixed(0)}% RH';
            break;
        }
        return Container(
          width: double.infinity,
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(24),
            border: Border.all(color: AppColors.surfaceOutline),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('Live reading', style: TextStyle(color: AppColors.textSecondary, fontSize: 13)),
              const SizedBox(height: 6),
              Text(
                value,
                style: const TextStyle(color: AppColors.textPrimary, fontSize: 24, fontWeight: FontWeight.w800),
              ),
            ],
          ),
        );
      },
    );
  }
}
