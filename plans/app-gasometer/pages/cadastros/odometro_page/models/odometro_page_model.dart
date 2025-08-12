// Package imports:
import 'package:carousel_slider/carousel_slider.dart';
import 'package:get/get.dart';

// Project imports:
import '../../../../database/20_odometro_model.dart';

class OdometroPageModel {
  final RxMap<DateTime, List<OdometroCar>> _odometros =
      <DateTime, List<OdometroCar>>{}.obs;
  final RxBool _isLoading = false.obs;
  final RxBool _showHeader = true.obs;
  final RxInt _currentCarouselIndex = 0.obs;
  final RxString _error = ''.obs;
  final RxList<DateTime> _monthsList = <DateTime>[].obs;
  final Rx<DateTime?> _selectedMonth = Rx<DateTime?>(null);

  // Carousel controller
  final CarouselSliderController carouselController =
      CarouselSliderController();

  // Reactive getters - standardized access pattern
  RxMap<DateTime, List<OdometroCar>> get odometros => _odometros;
  RxBool get isLoading => _isLoading;
  RxBool get showHeader => _showHeader;
  RxInt get currentCarouselIndex => _currentCarouselIndex;
  RxString get error => _error;
  RxList<DateTime> get monthsList => _monthsList;
  Rx<DateTime?> get selectedMonth => _selectedMonth;

  // Computed properties - using reactive getters consistently
  bool get hasData => _odometros.isNotEmpty;
  bool get hasError => _error.value.isNotEmpty;
  int get totalMonths => _monthsList.length;
  int get totalRecords =>
      _odometros.values.fold(0, (sum, list) => sum + list.length);

  // Setters
  void setOdometros(Map<DateTime, List<OdometroCar>> odometros) {
    _odometros.assignAll(odometros);
  }

  void addOdometros(DateTime month, List<OdometroCar> odometros) {
    _odometros[month] = odometros;
  }

  void removeOdometros(DateTime month) {
    _odometros.remove(month);
  }

  void setIsLoading(bool loading) {
    _isLoading.value = loading;
  }

  void setShowHeader(bool show) {
    _showHeader.value = show;
  }

  void toggleHeader() {
    _showHeader.value = !_showHeader.value;
  }

  void setCurrentCarouselIndex(int index) {
    _currentCarouselIndex.value = index;
  }

  void setError(String error) {
    _error.value = error;
  }

  void clearError() {
    _error.value = '';
  }

  void setMonthsList(List<DateTime> months) {
    _monthsList.assignAll(months);
  }

  void setSelectedMonth(DateTime? month) {
    _selectedMonth.value = month;
  }

  // Navigation methods
  void animateToPage(int index) {
    carouselController.animateToPage(index);
  }

  // Data filtering and querying
  List<OdometroCar> getOdometrosForMonth(DateTime month) {
    return _odometros[month] ?? [];
  }

  bool hasDataForMonth(DateTime month) {
    return _odometros.containsKey(month) && _odometros[month]!.isNotEmpty;
  }

  // Statistics methods
  Map<String, dynamic> getStatisticsForMonth(DateTime month) {
    final odometros = getOdometrosForMonth(month);
    if (odometros.isEmpty) {
      return {
        'totalRecords': 0,
        'totalDistance': 0.0,
        'averagePerDay': 0.0,
        'maxOdometer': 0.0,
        'minOdometer': 0.0,
      };
    }

    final sortedOdometros = List<OdometroCar>.from(odometros)
      ..sort((a, b) => a.odometro.compareTo(b.odometro));

    final totalDistance =
        sortedOdometros.last.odometro - sortedOdometros.first.odometro;
    final daysInMonth = DateTime(month.year, month.month + 1, 0).day;
    final averagePerDay = totalDistance / daysInMonth;

    return {
      'totalRecords': odometros.length,
      'totalDistance': totalDistance,
      'averagePerDay': averagePerDay,
      'maxOdometer': sortedOdometros.last.odometro,
      'minOdometer': sortedOdometros.first.odometro,
    };
  }

  Map<String, dynamic> getOverallStatistics() {
    if (_odometros.isEmpty) {
      return {
        'totalRecords': 0,
        'totalMonths': 0,
        'totalDistance': 0.0,
        'averageRecordsPerMonth': 0.0,
      };
    }

    final allOdometros = _odometros.values.expand((list) => list).toList();
    if (allOdometros.isEmpty) {
      return {
        'totalRecords': 0,
        'totalMonths': _odometros.length,
        'totalDistance': 0.0,
        'averageRecordsPerMonth': 0.0,
      };
    }

    final sortedOdometros = List<OdometroCar>.from(allOdometros)
      ..sort((a, b) => a.odometro.compareTo(b.odometro));

    final totalDistance =
        sortedOdometros.last.odometro - sortedOdometros.first.odometro;
    final averageRecordsPerMonth = allOdometros.length / _odometros.length;

    return {
      'totalRecords': allOdometros.length,
      'totalMonths': _odometros.length,
      'totalDistance': totalDistance,
      'averageRecordsPerMonth': averageRecordsPerMonth,
    };
  }

  // Calculate difference between consecutive odometer readings
  double calculateDifference(List<OdometroCar> odometros, int index) {
    if (index < odometros.length - 1) {
      return odometros[index].odometro - odometros[index + 1].odometro;
    }
    return 0.0;
  }

  // Search and filter methods
  List<OdometroCar> searchOdometros(String query) {
    if (query.isEmpty) return [];

    final allOdometros = _odometros.values.expand((list) => list).toList();
    return allOdometros.where((odometro) {
      final searchTerm = query.toLowerCase();
      return odometro.descricao.toLowerCase().contains(searchTerm) ||
          odometro.odometro.toString().contains(searchTerm);
    }).toList();
  }

  List<OdometroCar> getOdometrosInRange(DateTime start, DateTime end) {
    final result = <OdometroCar>[];
    for (final entry in _odometros.entries) {
      if (entry.key.isAfter(start.subtract(const Duration(days: 1))) &&
          entry.key.isBefore(end.add(const Duration(days: 1)))) {
        result.addAll(entry.value);
      }
    }
    return result;
  }

  // Reset and cleanup
  void reset() {
    _odometros.clear();
    _isLoading.value = false;
    _showHeader.value = true;
    _currentCarouselIndex.value = 0;
    _error.value = '';
    _monthsList.clear();
    _selectedMonth.value = null;
  }

  // Convert to/from Map for persistence or serialization
  Map<String, dynamic> toMap() {
    return {
      'odometros': _odometros.map((key, value) => MapEntry(
            key.millisecondsSinceEpoch.toString(),
            value.map((o) => o.toMap()).toList(),
          )),
      'isLoading': _isLoading.value,
      'showHeader': _showHeader.value,
      'currentCarouselIndex': _currentCarouselIndex.value,
      'error': _error.value,
      'monthsList': _monthsList.map((m) => m.millisecondsSinceEpoch).toList(),
      'selectedMonth': _selectedMonth.value?.millisecondsSinceEpoch,
    };
  }

  void fromMap(Map<String, dynamic> map) {
    if (map['odometros'] != null) {
      final odometrosMap = map['odometros'] as Map<String, dynamic>;
      final convertedMap = <DateTime, List<OdometroCar>>{};

      for (final entry in odometrosMap.entries) {
        final date = DateTime.fromMillisecondsSinceEpoch(int.parse(entry.key));
        final odometrosList =
            (entry.value as List).map((o) => OdometroCar.fromMap(o)).toList();
        convertedMap[date] = odometrosList;
      }

      setOdometros(convertedMap);
    }

    _isLoading.value = map['isLoading'] ?? false;
    _showHeader.value = map['showHeader'] ?? true;
    _currentCarouselIndex.value = map['currentCarouselIndex'] ?? 0;
    _error.value = map['error'] ?? '';

    if (map['monthsList'] != null) {
      final monthsList = (map['monthsList'] as List)
          .map((m) => DateTime.fromMillisecondsSinceEpoch(m))
          .toList();
      setMonthsList(monthsList);
    }

    if (map['selectedMonth'] != null) {
      _selectedMonth.value =
          DateTime.fromMillisecondsSinceEpoch(map['selectedMonth']);
    }
  }
}
