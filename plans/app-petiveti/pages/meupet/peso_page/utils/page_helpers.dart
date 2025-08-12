// Project imports:
import '../../../../models/17_peso_model.dart';
import '../../../../utils/peso/peso_calculations.dart';
import '../../../../utils/peso/peso_core.dart';

/// Page-specific helpers for peso listing/browsing
class PageHelpers {
  
  /// Gets peso statistics for display
  static Map<String, dynamic> getPesoStatistics(List<PesoAnimal> pesos) {
    if (pesos.isEmpty) {
      return {
        'count': 0,
        'average': 0.0,
        'min': 0.0,
        'max': 0.0,
        'trend': 'stable',
        'lastPeso': null,
      };
    }
    
    final sortedPesos = List<PesoAnimal>.from(pesos)
      ..sort((a, b) => a.dataPesagem.compareTo(b.dataPesagem));
    
    final average = PesoCalculations.calculateAveragePeso(pesos);
    final minPeso = pesos.map((p) => p.peso).reduce((a, b) => a < b ? a : b);
    final maxPeso = pesos.map((p) => p.peso).reduce((a, b) => a > b ? a : b);
    final growthRate = PesoCalculations.calculateGrowthRate(pesos);
    
    String trend = 'stable';
    if (growthRate != null) {
      if (growthRate > 0.1) {
        trend = 'increasing';
      } else if (growthRate < -0.1) {
        trend = 'decreasing';
      }
    }
    
    return {
      'count': pesos.length,
      'average': average,
      'min': minPeso,
      'max': maxPeso,
      'trend': trend,
      'lastPeso': sortedPesos.last,
      'growthRate': growthRate,
    };
  }
  
  /// Formats statistics for display
  static String formatStatistic(String key, dynamic value) {
    switch (key) {
      case 'count':
        return '$value registro${value == 1 ? '' : 's'}';
      case 'average':
        return PesoCore.formatPesoWithUnit(value);
      case 'min':
        return PesoCore.formatPesoWithUnit(value);
      case 'max':
        return PesoCore.formatPesoWithUnit(value);
      case 'trend':
        switch (value) {
          case 'increasing':
            return 'Aumentando';
          case 'decreasing':
            return 'Diminuindo';
          case 'stable':
            return 'Estável';
          default:
            return 'Desconhecido';
        }
      case 'growthRate':
        return PesoCalculations.formatGrowthRate(value);
      default:
        return value.toString();
    }
  }
  
  /// Gets trend icon for display
  static String getTrendIcon(String trend) {
    switch (trend) {
      case 'increasing':
        return '📈';
      case 'decreasing':
        return '📉';
      case 'stable':
        return '➡️';
      default:
        return '❓';
    }
  }
  
  /// Sorts peso list by different criteria
  static List<PesoAnimal> sortPesos(List<PesoAnimal> pesos, String sortBy, bool ascending) {
    final sortedPesos = List<PesoAnimal>.from(pesos);
    
    switch (sortBy) {
      case 'data':
        sortedPesos.sort((a, b) => ascending 
          ? a.dataPesagem.compareTo(b.dataPesagem)
          : b.dataPesagem.compareTo(a.dataPesagem));
        break;
      case 'peso':
        sortedPesos.sort((a, b) => ascending 
          ? a.peso.compareTo(b.peso)
          : b.peso.compareTo(a.peso));
        break;
      case 'categoria':
        sortedPesos.sort((a, b) {
          final catA = PesoCore.getPesoCategory(a.peso);
          final catB = PesoCore.getPesoCategory(b.peso);
          return ascending 
            ? catA.compareTo(catB)
            : catB.compareTo(catA);
        });
        break;
      default:
        // Default sort by date (newest first)
        sortedPesos.sort((a, b) => b.dataPesagem.compareTo(a.dataPesagem));
    }
    
    return sortedPesos;
  }
  
  /// Filters peso list by different criteria
  static List<PesoAnimal> filterPesos(List<PesoAnimal> pesos, {
    double? minPeso,
    double? maxPeso,
    DateTime? startDate,
    DateTime? endDate,
    String? categoria,
  }) {
    return pesos.where((peso) {
      // Filter by peso range
      if (minPeso != null && peso.peso < minPeso) return false;
      if (maxPeso != null && peso.peso > maxPeso) return false;
      
      // Filter by date range
      final pesoDate = DateTime.fromMillisecondsSinceEpoch(peso.dataPesagem);
      if (startDate != null && pesoDate.isBefore(startDate)) return false;
      if (endDate != null && pesoDate.isAfter(endDate)) return false;
      
      // Filter by categoria
      if (categoria != null && categoria.isNotEmpty) {
        final pesoCategoria = PesoCore.getPesoCategory(peso.peso);
        if (pesoCategoria != categoria) return false;
      }
      
      return true;
    }).toList();
  }
  
  /// Searches peso list by text
  static List<PesoAnimal> searchPesos(List<PesoAnimal> pesos, String searchText) {
    if (searchText.trim().isEmpty) return pesos;
    
    final searchLower = searchText.toLowerCase();
    
    return pesos.where((peso) {
      // Search in peso value
      final pesoText = PesoCore.formatPeso(peso.peso).toLowerCase();
      if (pesoText.contains(searchLower)) return true;
      
      // Search in categoria
      final categoria = PesoCore.getPesoCategory(peso.peso).toLowerCase();
      if (categoria.contains(searchLower)) return true;
      
      // Search in observacoes
      final observacoes = peso.observacoes?.toLowerCase() ?? '';
      if (observacoes.contains(searchLower)) return true;
      
      return false;
    }).toList();
  }
  
  /// Gets recent peso changes
  static List<Map<String, dynamic>> getRecentChanges(List<PesoAnimal> pesos, {int limit = 5}) {
    if (pesos.length < 2) return [];
    
    final sortedPesos = List<PesoAnimal>.from(pesos)
      ..sort((a, b) => a.dataPesagem.compareTo(b.dataPesagem));
    
    final changes = <Map<String, dynamic>>[];
    
    for (int i = 1; i < sortedPesos.length && changes.length < limit; i++) {
      final current = sortedPesos[i];
      final previous = sortedPesos[i - 1];
      
      final change = current.peso - previous.peso;
      final changePercentage = (change / previous.peso) * 100;
      
      changes.add({
        'current': current,
        'previous': previous,
        'change': change,
        'changePercentage': changePercentage,
        'changeFormatted': PesoCore.formatPesoChange(change),
        'changePercentageFormatted': PesoCore.formatPesoChangePercentage(change, previous.peso),
      });
    }
    
    return changes.reversed.toList(); // Show most recent first
  }
  
  /// Checks if peso change is significant
  static bool isSignificantChange(double change, double previousPeso) {
    final percentageChange = (change.abs() / previousPeso) * 100;
    return percentageChange > 10; // More than 10% change is significant
  }
  
  /// Gets export data for sharing
  static Map<String, dynamic> getExportData(List<PesoAnimal> pesos) {
    final statistics = getPesoStatistics(pesos);
    final changes = getRecentChanges(pesos);
    
    return {
      'statistics': statistics,
      'recentChanges': changes,
      'totalRecords': pesos.length,
      'exportDate': DateTime.now().millisecondsSinceEpoch,
      'data': pesos.map((peso) => PesoCore.exportToJson(
        animalId: peso.animalId,
        peso: peso.peso,
        dataPesagem: DateTime.fromMillisecondsSinceEpoch(peso.dataPesagem),
        observacoes: peso.observacoes,
      )).toList(),
    };
  }
  
  /// Gets chart data for visualization
  static Map<String, dynamic> getChartData(List<PesoAnimal> pesos) {
    final dataPoints = PesoCalculations.generateChartData(pesos);
    final trendLine = PesoCalculations.calculateTrendLine(pesos);
    final groupedData = PesoCalculations.groupPesosByMonth(pesos);
    
    return {
      'dataPoints': dataPoints,
      'trendLine': trendLine,
      'groupedData': groupedData,
      'hasData': pesos.isNotEmpty,
    };
  }
  
  /// Gets pagination info
  static Map<String, dynamic> getPaginationInfo(List<PesoAnimal> pesos, int page, int itemsPerPage) {
    final totalItems = pesos.length;
    final totalPages = (totalItems / itemsPerPage).ceil();
    final startIndex = (page - 1) * itemsPerPage;
    final endIndex = (startIndex + itemsPerPage).clamp(0, totalItems);
    
    return {
      'totalItems': totalItems,
      'totalPages': totalPages,
      'currentPage': page,
      'itemsPerPage': itemsPerPage,
      'startIndex': startIndex,
      'endIndex': endIndex,
      'hasNext': page < totalPages,
      'hasPrevious': page > 1,
    };
  }
}
