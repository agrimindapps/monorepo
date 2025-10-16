import '../entities/defensivo.dart';

/// Service responsible for filtering defensivos (SOLID - SRP)
class DefensivosFilterService {
  /// Filter defensivos by search query (name or active ingredient)
  List<Defensivo> filterByQuery(List<Defensivo> defensivos, String query) {
    if (query.trim().isEmpty) return defensivos;

    final lowerQuery = query.toLowerCase().trim();

    return defensivos.where((defensivo) {
      final nomeMatch = defensivo.nomeComum.toLowerCase().contains(lowerQuery);
      final ingredienteMatch =
          defensivo.ingredienteAtivo.toLowerCase().contains(lowerQuery);
      final fabricanteMatch =
          defensivo.fabricante.toLowerCase().contains(lowerQuery);

      return nomeMatch || ingredienteMatch || fabricanteMatch;
    }).toList();
  }

  /// Filter defensivos by fabricante
  List<Defensivo> filterByFabricante(
    List<Defensivo> defensivos,
    String fabricante,
  ) {
    if (fabricante.trim().isEmpty) return defensivos;

    final lowerFabricante = fabricante.toLowerCase().trim();

    return defensivos
        .where((d) => d.fabricante.toLowerCase().contains(lowerFabricante))
        .toList();
  }

  /// Filter defensivos by ingrediente ativo
  List<Defensivo> filterByIngredienteAtivo(
    List<Defensivo> defensivos,
    String ingredienteAtivo,
  ) {
    if (ingredienteAtivo.trim().isEmpty) return defensivos;

    final lowerIngrediente = ingredienteAtivo.toLowerCase().trim();

    return defensivos
        .where((d) =>
            d.ingredienteAtivo.toLowerCase().contains(lowerIngrediente))
        .toList();
  }
}
