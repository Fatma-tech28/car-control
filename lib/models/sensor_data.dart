import 'package:flutter/foundation.dart';

enum DriveMode { manual, auto }

enum DriveCommand { forward, backward, left, right, stop }

enum AlertSeverity { none, warning, danger }

enum AlertSource { none, ultrasonic, flame, gas, pir }

@immutable
class AlertEvent {
  final AlertSource source;
  final AlertSeverity severity;
  final String message;
  final DateTime timestamp;

  const AlertEvent({
    required this.source,
    required this.severity,
    required this.message,
    required this.timestamp,
  });

  static AlertEvent none() => AlertEvent(
        source: AlertSource.none,
        severity: AlertSeverity.none,
        message: '',
        timestamp: DateTime.fromMillisecondsSinceEpoch(0),
      );

  bool get isActive => severity != AlertSeverity.none;
}

/// Snapshot of every sensor reading coming off the ESP32/Arduino stack.
@immutable
class SensorSnapshot {
  final bool flameDetected;
  final double gasPpm; // ppm, mocked MQ-2 style reading
  final bool pirMotion;
  final double humidity; // %
  final double temperature; // Celsius
  final double ultrasonicCm; // distance to nearest obstacle

  const SensorSnapshot({
    required this.flameDetected,
    required this.gasPpm,
    required this.pirMotion,
    required this.humidity,
    required this.temperature,
    required this.ultrasonicCm,
  });

  factory SensorSnapshot.initial() => const SensorSnapshot(
        flameDetected: false,
        gasPpm: 120,
        pirMotion: false,
        humidity: 48,
        temperature: 27.5,
        ultrasonicCm: 180,
      );

  SensorSnapshot copyWith({
    bool? flameDetected,
    double? gasPpm,
    bool? pirMotion,
    double? humidity,
    double? temperature,
    double? ultrasonicCm,
  }) {
    return SensorSnapshot(
      flameDetected: flameDetected ?? this.flameDetected,
      gasPpm: gasPpm ?? this.gasPpm,
      pirMotion: pirMotion ?? this.pirMotion,
      humidity: humidity ?? this.humidity,
      temperature: temperature ?? this.temperature,
      ultrasonicCm: ultrasonicCm ?? this.ultrasonicCm,
    );
  }
}

enum NavPhase { idle, driving, obstacleStop, reversing, scanningRight, scanningLeft, escaping }

@immutable
class CarStatus {
  final DriveMode mode;
  final NavPhase phase;
  final int speedPercent; // 0-100, moderate ~55, max 100
  final bool connected;

  const CarStatus({
    required this.mode,
    required this.phase,
    required this.speedPercent,
    required this.connected,
  });

  factory CarStatus.initial() => const CarStatus(
        mode: DriveMode.manual,
        phase: NavPhase.idle,
        speedPercent: 0,
        connected: false,
      );

  CarStatus copyWith({
    DriveMode? mode,
    NavPhase? phase,
    int? speedPercent,
    bool? connected,
  }) {
    return CarStatus(
      mode: mode ?? this.mode,
      phase: phase ?? this.phase,
      speedPercent: speedPercent ?? this.speedPercent,
      connected: connected ?? this.connected,
    );
  }
}

/// One point in a historical time series, used on the report pages.
@immutable
class TimeSeriesPoint {
  final DateTime time;
  final double value;
  const TimeSeriesPoint(this.time, this.value);
}

enum SensorKind { flame, gas, pir, humidityTemp }

extension SensorKindMeta on SensorKind {
  String get label {
    switch (this) {
      case SensorKind.flame:
        return 'Flame';
      case SensorKind.gas:
        return 'Gas';
      case SensorKind.pir:
        return 'PIR Motion';
      case SensorKind.humidityTemp:
        return 'Humidity & Temp';
    }
  }

  String get unit {
    switch (this) {
      case SensorKind.flame:
        return '';
      case SensorKind.gas:
        return 'ppm';
      case SensorKind.pir:
        return '';
      case SensorKind.humidityTemp:
        return '%RH / °C';
    }
  }
}
