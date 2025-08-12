// Dart imports:
import 'dart:async';

// Flutter imports:
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

// Project imports:
import '../models/launch_countdown_model.dart';

class CountdownController extends ChangeNotifier {
  // State
  LaunchCountdown? _countdown;
  Timer? _timer;
  bool _isActive = false;
  bool _isInitialized = false;

  // Getters
  LaunchCountdown? get countdown => _countdown;
  bool get isActive => _isActive;
  bool get isInitialized => _isInitialized;
  bool get isLaunched => _countdown?.isLaunched ?? false;
  bool get isCountdownActive => _countdown?.isCountdownActive ?? false;

  // Countdown values
  int get daysRemaining => _countdown?.daysRemaining ?? 0;
  int get hoursRemaining => _countdown?.hoursRemaining ?? 0;
  int get minutesRemaining => _countdown?.minutesRemaining ?? 0;
  int get secondsRemaining => _countdown?.secondsRemaining ?? 0;

  // Formatted values
  String get formattedLaunchDate => _countdown?.formattedLaunchDate ?? '';
  String get countdownText => _countdown?.countdownText ?? '';
  String get statusMessage => _countdown?.statusMessage ?? '';
  LaunchStatus get currentStatus => _countdown?.status ?? LaunchStatus.preAnnouncement;

  CountdownController() {
    _initializeCountdown();
  }

  void _initializeCountdown() {
    try {
      _countdown = LaunchCountdownRepository.getCurrentCountdown();
      _isInitialized = true;
      notifyListeners();
    } catch (e) {
      debugPrint('CountdownController initialization error: $e');
    }
  }

  Future<void> initialize() async {
    try {
      await _loadCountdown();
      _startTimer();
    } catch (e) {
      debugPrint('CountdownController async initialization error: $e');
    }
  }

  Future<void> _loadCountdown() async {
    try {
      _countdown = LaunchCountdownRepository.getCurrentCountdown();
      _isInitialized = true;
      notifyListeners();
    } catch (e) {
      throw Exception('Erro ao carregar countdown: $e');
    }
  }

  void _startTimer() {
    if (_countdown == null || _countdown!.isLaunched) return;

    _isActive = true;
    _timer = Timer.periodic(const Duration(seconds: 1), (_) {
      _updateCountdown();
    });
  }

  void _updateCountdown() {
    if (_countdown == null) return;

    final newCountdown = LaunchCountdownRepository.getCurrentCountdown();
    
    if (newCountdown.isLaunched && !_countdown!.isLaunched) {
      // App just launched
      _onLaunchReached();
    }

    _countdown = newCountdown;
    notifyListeners();
  }

  void _onLaunchReached() {
    _stopTimer();
    debugPrint('Launch date reached!');
    // Trigger launch celebrations or notifications
  }

  void _stopTimer() {
    _timer?.cancel();
    _timer = null;
    _isActive = false;
  }

  // Countdown units
  List<CountdownUnit> getCountdownUnits() {
    if (_countdown == null) return [];
    return LaunchCountdownRepository.getCountdownUnits(_countdown!);
  }

  List<CountdownUnit> getDetailedCountdownUnits() {
    if (_countdown == null) return [];
    return LaunchCountdownRepository.getDetailedCountdownUnits(_countdown!);
  }

  CountdownUnit? getCountdownUnit(CountdownUnitType type) {
    final units = getDetailedCountdownUnits();
    try {
      return units.firstWhere((unit) => unit.type == type);
    } catch (e) {
      return null;
    }
  }

  // Launch information
  LaunchInformation getLaunchInformation() {
    return LaunchCountdownRepository.getLaunchInformation();
  }

  String? getStoreUrl(String platform) {
    final info = getLaunchInformation();
    return info.getStoreUrl(platform);
  }

  List<String> getAvailablePlatforms() {
    final info = getLaunchInformation();
    return info.availablePlatforms;
  }

  bool hasMultiplePlatforms() {
    final info = getLaunchInformation();
    return info.hasMultiplePlatforms;
  }

  List<String> getNewFeatures() {
    final info = getLaunchInformation();
    return info.newFeatures;
  }

  String? getReleaseNotes() {
    final info = getLaunchInformation();
    return info.releaseNotes;
  }

  String getAppVersion() {
    final info = getLaunchInformation();
    return info.version;
  }

  // Progress and milestones
  String getProgressMessage() {
    return LaunchCountdownRepository.getProgressMessage();
  }

  List<String> getMilestones() {
    return LaunchCountdownRepository.getMilestones();
  }

  double getProgressPercentage() {
    if (_countdown == null) return 0.0;
    
    final launchDate = _countdown!.launchDate;
    final currentDate = _countdown!.currentDate;
    
    // Calculate progress from announcement date (e.g., 6 months ago) to launch
    final announcementDate = launchDate.subtract(const Duration(days: 180));
    final totalDuration = launchDate.difference(announcementDate);
    final elapsed = currentDate.difference(announcementDate);
    
    if (elapsed.isNegative) return 0.0;
    if (currentDate.isAfter(launchDate)) return 100.0;
    
    return (elapsed.inMilliseconds / totalDuration.inMilliseconds * 100).clamp(0.0, 100.0);
  }

  // Countdown formatting
  String formatTimeUnit(int value, CountdownUnitType type) {
    switch (type) {
      case CountdownUnitType.days:
        return value.toString();
      case CountdownUnitType.hours:
      case CountdownUnitType.minutes:
      case CountdownUnitType.seconds:
        return value.toString().padLeft(2, '0');
    }
  }

  String getCountdownDisplay({bool showSeconds = false}) {
    if (_countdown == null || _countdown!.isLaunched) {
      return 'Disponível agora!';
    }

    final days = daysRemaining;
    final hours = hoursRemaining;
    final minutes = minutesRemaining;
    final seconds = secondsRemaining;

    if (days > 0) {
      return '$days dias, ${hours.toString().padLeft(2, '0')}h${minutes.toString().padLeft(2, '0')}m';
    } else if (hours > 0) {
      return '${hours.toString().padLeft(2, '0')}h ${minutes.toString().padLeft(2, '0')}m${showSeconds ? ' ${seconds.toString().padLeft(2, '0')}s' : ''}';
    } else {
      return '${minutes.toString().padLeft(2, '0')}m${showSeconds ? ' ${seconds.toString().padLeft(2, '0')}s' : ''}';
    }
  }

  String getShortCountdownDisplay() {
    if (_countdown == null || _countdown!.isLaunched) {
      return 'Lançado!';
    }

    final days = daysRemaining;
    if (days > 0) {
      return '$days dias restantes';
    } else if (hoursRemaining > 0) {
      return '${hoursRemaining}h ${minutesRemaining}m';
    } else {
      return '${minutesRemaining}m ${secondsRemaining}s';
    }
  }

  // Validation and state checks
  bool isValidCountdown() {
    return _countdown != null && _isInitialized;
  }

  bool shouldShowCountdown() {
    return isValidCountdown() && isCountdownActive && !isLaunched;
  }

  bool shouldShowLaunchMessage() {
    return isValidCountdown() && isLaunched;
  }

  bool shouldShowPreAnnouncement() {
    return isValidCountdown() && currentStatus == LaunchStatus.preAnnouncement;
  }

  Duration? getTimeRemaining() {
    return _countdown?.timeRemaining;
  }

  DateTime? getLaunchDate() {
    return _countdown?.launchDate;
  }

  // Custom countdown configuration
  void setCustomLaunchDate(DateTime launchDate) {
    try {
      _stopTimer();
      _countdown = LaunchCountdownRepository.getCountdownWithCustomDate(launchDate);
      if (!_countdown!.isLaunched) {
        _startTimer();
      }
      notifyListeners();
    } catch (e) {
      debugPrint('Error setting custom launch date: $e');
    }
  }

  void resetToDefaultLaunchDate() {
    try {
      _stopTimer();
      _countdown = LaunchCountdownRepository.getCurrentCountdown();
      if (!_countdown!.isLaunched) {
        _startTimer();
      }
      notifyListeners();
    } catch (e) {
      debugPrint('Error resetting to default launch date: $e');
    }
  }

  // Statistics and analytics
  Map<String, dynamic> getCountdownStatistics() {
    return LaunchCountdownRepository.getCountdownStatistics();
  }

  Map<String, dynamic> getTimerStatistics() {
    return {
      'isActive': _isActive,
      'isInitialized': _isInitialized,
      'isLaunched': isLaunched,
      'isCountdownActive': isCountdownActive,
      'currentStatus': currentStatus.id,
      'daysRemaining': daysRemaining,
      'hoursRemaining': hoursRemaining,
      'minutesRemaining': minutesRemaining,
      'secondsRemaining': secondsRemaining,
      'progressPercentage': getProgressPercentage(),
    };
  }

  // Manual refresh
  Future<void> refresh() async {
    try {
      await _loadCountdown();
      if (!isLaunched && !_isActive) {
        _startTimer();
      } else if (isLaunched && _isActive) {
        _stopTimer();
      }
    } catch (e) {
      debugPrint('Error refreshing countdown: $e');
    }
  }

  void pause() {
    _stopTimer();
    notifyListeners();
  }

  void resume() {
    if (_countdown != null && !_countdown!.isLaunched && !_isActive) {
      _startTimer();
      notifyListeners();
    }
  }

  @override
  void dispose() {
    _stopTimer();
    super.dispose();
  }
}
