import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

import '../models/sensor_data.dart';
import '../services/car_connection_service.dart';

/// Drives all control-page and dashboard behavior described in the brief:
/// manual press-to-move controls, an autonomous driving loop, the
/// ultrasonic stop/reverse/scan routine, the flame-triggered max-speed
/// escape, and the persistent full-screen alert.
class CarState extends ChangeNotifier {
  CarState(this._service);

  final CarConnectionService _service;

  static const int moderateSpeed = 55;
  static const int maxSpeed = 100;
  static const double obstacleThresholdCm = 18;
  static const double clearThresholdCm = 35;

  CarStatus _status = CarStatus.initial();
  SensorSnapshot _sensors = SensorSnapshot.initial();
  AlertEvent _alert = AlertEvent.none();
  DriveCommand? _heldCommand;
  bool _sequenceBusy = false;
  bool _flameEscapeActive = false;
  bool _connecting = true;

  StreamSubscription<SensorSnapshot>? _sensorSub;
  StreamSubscription<bool>? _connSub;
  Timer? _autoDriveTimer;
  Timer? _sequenceTimer;
  Timer? _flameTimer;

  CarStatus get status => _status;
  SensorSnapshot get sensors => _sensors;
  AlertEvent get alert => _alert;
  bool get alertActive => _alert.isActive;
  DriveCommand? get heldCommand => _heldCommand;
  bool get connecting => _connecting;

  Future<void> init() async {
    _connSub = _service.connectionStream.listen((connected) {
      _connecting = false;
      _status = _status.copyWith(connected: connected);
      notifyListeners();
    });
    _sensorSub = _service.sensorStream.listen(_onSensorUpdate);
    await _service.connect();
  }

  // ---------------------------------------------------------------------
  // Mode switching
  // ---------------------------------------------------------------------
  Future<void> setMode(DriveMode mode) async {
    if (_status.mode == mode) return;
    _heldCommand = null;
    _sequenceBusy = false;
    _autoDriveTimer?.cancel();
    _sequenceTimer?.cancel();
    _status = _status.copyWith(mode: mode, phase: NavPhase.idle, speedPercent: 0);
    notifyListeners();
    await _service.setMode(mode);
    await _service.sendCommand(DriveCommand.stop, speedPercent: 0);
    if (mode == DriveMode.auto) {
      _startAutoLoop();
    }
  }

  // ---------------------------------------------------------------------
  // Manual mode: press-and-hold controls
  // ---------------------------------------------------------------------
  void pressCommand(DriveCommand cmd) {
    if (_status.mode != DriveMode.manual) return;
    // Ultrasonic safety routine and flame escape take priority over manual input.
    if (_sequenceBusy || _flameEscapeActive) return;

    _heldCommand = cmd;
    _status = _status.copyWith(phase: NavPhase.driving, speedPercent: moderateSpeed);
    notifyListeners();
    _service.sendCommand(cmd, speedPercent: moderateSpeed);
  }

  void releaseCommand() {
    if (_status.mode != DriveMode.manual) return;
    _heldCommand = null;
    if (!_sequenceBusy && !_flameEscapeActive) {
      _status = _status.copyWith(phase: NavPhase.idle, speedPercent: 0);
      notifyListeners();
      _service.sendCommand(DriveCommand.stop, speedPercent: 0);
    }
  }

  // ---------------------------------------------------------------------
  // Auto mode: continuous moderate-speed driving loop
  // ---------------------------------------------------------------------
  void _startAutoLoop() {
    _autoDriveTimer?.cancel();
    _autoDriveTimer = Timer.periodic(const Duration(milliseconds: 700), (_) {
      if (_status.mode != DriveMode.auto) return;
      if (_sequenceBusy || _flameEscapeActive) return;
      _status = _status.copyWith(phase: NavPhase.driving, speedPercent: moderateSpeed);
      _service.sendCommand(DriveCommand.forward, speedPercent: moderateSpeed);
      notifyListeners();
    });
  }

  // ---------------------------------------------------------------------
  // Sensor stream handling
  // ---------------------------------------------------------------------
  void _onSensorUpdate(SensorSnapshot snap) {
    _sensors = snap;

    if (snap.flameDetected && !_flameEscapeActive) {
      _handleFlame();
    }

    final drivingForward = _status.phase == NavPhase.driving &&
        (_status.mode == DriveMode.auto || _heldCommand == DriveCommand.forward);

    if (!_flameEscapeActive && !_sequenceBusy && drivingForward && snap.ultrasonicCm <= obstacleThresholdCm) {
      _runObstacleSequence();
    }

    notifyListeners();
  }

  /// Flame sensor safety behavior: reverse at maximum speed and escape.
  /// Applied automatically in Auto mode; in Manual mode the operator keeps
  /// control but is warned immediately via the full-screen alert.
  void _handleFlame() {
    _flameEscapeActive = true;
    _sequenceTimer?.cancel();
    _raiseAlert(AlertSource.flame, AlertSeverity.danger, 'Flame detected! Escaping at maximum speed.');

    if (_status.mode == DriveMode.auto) {
      _status = _status.copyWith(phase: NavPhase.escaping, speedPercent: maxSpeed);
      _service.sendCommand(DriveCommand.backward, speedPercent: maxSpeed);
      notifyListeners();

      _flameTimer?.cancel();
      _flameTimer = Timer(const Duration(seconds: 3), () {
        _flameEscapeActive = false;
        if (_status.mode == DriveMode.auto) {
          _status = _status.copyWith(phase: NavPhase.driving, speedPercent: moderateSpeed);
        } else {
          _status = _status.copyWith(phase: NavPhase.idle, speedPercent: 0);
        }
        notifyListeners();
      });
    } else {
      _flameEscapeActive = false;
    }
  }

  /// Ultrasonic safety routine, active at 100% capability in both modes:
  /// stop -> reverse two steps -> scan right -> proceed if clear, else
  /// scan left -> proceed if clear, else remain stopped and alert.
  void _runObstacleSequence() {
    _sequenceBusy = true;
    _raiseAlert(AlertSource.ultrasonic, AlertSeverity.warning, 'Obstacle detected ahead. Reversing and scanning.');

    _status = _status.copyWith(phase: NavPhase.obstacleStop, speedPercent: 0);
    _service.sendCommand(DriveCommand.stop, speedPercent: 0);
    notifyListeners();

    _sequenceTimer = Timer(const Duration(milliseconds: 500), () {
      _status = _status.copyWith(phase: NavPhase.reversing, speedPercent: moderateSpeed);
      _service.sendCommand(DriveCommand.backward, speedPercent: moderateSpeed);
      notifyListeners();

      // "Reverses two steps"
      _sequenceTimer = Timer(const Duration(milliseconds: 900), () {
        _service.sendCommand(DriveCommand.stop, speedPercent: 0);
        _status = _status.copyWith(phase: NavPhase.scanningRight, speedPercent: 0);
        notifyListeners();

        _sequenceTimer = Timer(const Duration(milliseconds: 800), () {
          final rightClear = _sensors.ultrasonicCm > clearThresholdCm;
          if (rightClear) {
            _resumeAfterScan();
          } else {
            _status = _status.copyWith(phase: NavPhase.scanningLeft);
            notifyListeners();
            _sequenceTimer = Timer(const Duration(milliseconds: 800), _resumeAfterScan);
          }
        });
      });
    });
  }

  void _resumeAfterScan() {
    _sequenceBusy = false;
    final auto = _status.mode == DriveMode.auto;
    _status = _status.copyWith(
      phase: auto ? NavPhase.driving : NavPhase.idle,
      speedPercent: auto ? moderateSpeed : 0,
    );
    if (auto) {
      _service.sendCommand(DriveCommand.forward, speedPercent: moderateSpeed);
    } else {
      _service.sendCommand(DriveCommand.stop, speedPercent: 0);
    }
    notifyListeners();
  }

  // ---------------------------------------------------------------------
  // Alert system
  // ---------------------------------------------------------------------
  void _raiseAlert(AlertSource source, AlertSeverity severity, String message) {
    _alert = AlertEvent(source: source, severity: severity, message: message, timestamp: DateTime.now());
    HapticFeedback.heavyImpact();
  }

  /// "Stop Alert" — dismisses the active alert. Does not by itself resume
  /// motion; the underlying safety sequence (if any) continues on its own.
  void dismissAlert() {
    _alert = AlertEvent.none();
    notifyListeners();
  }

  Future<List<TimeSeriesPoint>> history(SensorKind kind) => _service.fetchHistory(kind);

  @override
  void dispose() {
    _sensorSub?.cancel();
    _connSub?.cancel();
    _autoDriveTimer?.cancel();
    _sequenceTimer?.cancel();
    _flameTimer?.cancel();
    _service.dispose();
    super.dispose();
  }
}
