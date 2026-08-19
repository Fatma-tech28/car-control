import 'dart:async';
import 'dart:math';

import '../models/sensor_data.dart';

/// Abstraction over the transport used to talk to the Arduino/ESP32.
///
/// A real implementation would open a WebSocket (e.g.
/// `ws://<esp32-ip>/ws`) with `web_socket_channel`, or poll REST
/// endpoints such as:
///   POST /command      { "cmd": "forward" }
///   GET  /sensors       -> live SensorSnapshot JSON
///   GET  /history/:kind -> time-series JSON for the dashboard report
///
/// [MockCarConnectionService] fulfills the same contract with simulated
/// data so the UI is fully functional without hardware attached.
abstract class CarConnectionService {
  Stream<SensorSnapshot> get sensorStream;
  Stream<bool> get connectionStream;

  Future<void> connect();
  void dispose();

  Future<void> sendCommand(DriveCommand command, {required int speedPercent});
  Future<void> setMode(DriveMode mode);

  Future<List<TimeSeriesPoint>> fetchHistory(SensorKind kind, {int points = 24});
}

class MockCarConnectionService implements CarConnectionService {
  final _sensorController = StreamController<SensorSnapshot>.broadcast();
  final _connectionController = StreamController<bool>.broadcast();
  final _random = Random();

  Timer? _tickTimer;
  SensorSnapshot _last = SensorSnapshot.initial();
  bool _connected = false;

  @override
  Stream<SensorSnapshot> get sensorStream => _sensorController.stream;

  @override
  Stream<bool> get connectionStream => _connectionController.stream;

  @override
  Future<void> connect() async {
    // Simulate a short handshake, as a real WebSocket connect would take.
    await Future.delayed(const Duration(milliseconds: 700));
    _connected = true;
    _connectionController.add(true);

    _tickTimer?.cancel();
    _tickTimer = Timer.periodic(const Duration(milliseconds: 900), (_) => _tick());
  }

  void _tick() {
    // Random-walk each sensor so the dashboard feels alive.
    final gas = (_last.gasPpm + _random.nextDouble() * 14 - 7).clamp(80, 420).toDouble();
    final humidity = (_last.humidity + _random.nextDouble() * 2 - 1).clamp(30, 85).toDouble();
    final temperature = (_last.temperature + _random.nextDouble() * 0.6 - 0.3).clamp(18, 45).toDouble();
    final ultrasonic = (_last.ultrasonicCm + _random.nextDouble() * 40 - 20).clamp(4, 250).toDouble();

    // Rare random events so alerts can be demoed live.
    final flame = _random.nextDouble() < 0.01 ? true : (_random.nextDouble() < 0.3 ? false : _last.flameDetected);
    final pir = _random.nextDouble() < 0.05;

    _last = _last.copyWith(
      flameDetected: flame,
      gasPpm: gas,
      pirMotion: pir,
      humidity: humidity,
      temperature: temperature,
      ultrasonicCm: ultrasonic,
    );
    _sensorController.add(_last);
  }

  @override
  Future<void> sendCommand(DriveCommand command, {required int speedPercent}) async {
    // In production this posts to the ESP32, e.g.:
    // await http.post(Uri.parse('$baseUrl/command'), body: {'cmd': command.name, 'speed': speedPercent});
    await Future.delayed(const Duration(milliseconds: 40));
  }

  @override
  Future<void> setMode(DriveMode mode) async {
    await Future.delayed(const Duration(milliseconds: 40));
  }

  @override
  Future<List<TimeSeriesPoint>> fetchHistory(SensorKind kind, {int points = 24}) async {
    await Future.delayed(const Duration(milliseconds: 350));
    final now = DateTime.now();
    double base;
    double spread;
    switch (kind) {
      case SensorKind.flame:
        base = 0;
        spread = 1;
        break;
      case SensorKind.gas:
        base = 180;
        spread = 90;
        break;
      case SensorKind.pir:
        base = 0;
        spread = 1;
        break;
      case SensorKind.humidityTemp:
        base = 50;
        spread = 15;
        break;
    }
    return List.generate(points, (i) {
      final t = now.subtract(Duration(minutes: (points - i) * 15));
      final v = (base + sin(i / 3) * spread * 0.5 + _random.nextDouble() * spread * 0.5).clamp(0, base + spread * 1.5);
      return TimeSeriesPoint(t, v.toDouble());
    });
  }

  @override
  void dispose() {
    _tickTimer?.cancel();
    _sensorController.close();
    _connectionController.close();
  }
}
