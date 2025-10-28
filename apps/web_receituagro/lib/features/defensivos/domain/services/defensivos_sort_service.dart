import '../entities/defensivo.dart';

/// Service responsible for sorting defensivos (SOLID - SRP)
class DefensivosSortService {
  /// Sort defensivos by name (A-Z)
  List<Defensivo> sortByName(List<Defensivo> defensivos) {
    final sorted = List<Defensivo>.from(defensivos);
    sorted.sort((a, b) => a.nomeComum.compareTo(b.nomeComum));
    return sorted;
  }

  /// Sort defensivos by name (Z-A)
  List<Defensivo> sortByNameDescending(List<Defensivo> defensivos) {
    final sorted = List<Defensivo>.from(defensivos);
    sorted.sort((a, b) => b.nomeComum.compareTo(a.nomeComum));
    return sorted;
  }

  /// Sort defensivos by fabricante
  List<Defensivo> sortByFabricante(List<Defensivo> defensivos) {
    final sorted = List<Defensivo>.from(defensivos);
    sorted.sort((a, b) => a.fabricante.compareTo(b.fabricante));
    return sorted;
  }

  /// Sort defensivos by created date (newest first)
  List<Defensivo> sortByNewest(List<Defensivo> defensivos) {
    final sorted = List<Defensivo>.from(defensivos);
    sorted.sort((a, b) => b.createdAt.compareTo(a.createdAt));
    return sorted;
  }

  /// Sort defensivos by updated date (most recently updated first)
  List<Defensivo> sortByRecentlyUpdated(List<Defensivo> defensivos) {
    final sorted = List<Defensivo>.from(defensivos);
    sorted.sort((a, b) => b.updatedAt.compareTo(a.updatedAt));
    return sorted;
  }
}
