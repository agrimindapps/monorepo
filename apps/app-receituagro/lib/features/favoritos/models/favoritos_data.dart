import 'favorito_defensivo_model.dart';
import 'favorito_praga_model.dart';
import 'favorito_diagnostico_model.dart';

class FavoritosData {
  final List<FavoritoDefensivoModel> defensivos;
  final List<FavoritoPragaModel> pragas;
  final List<FavoritoDiagnosticoModel> diagnosticos;
  
  final String defensivosFilter;
  final String pragasFilter;
  final String diagnosticosFilter;

  const FavoritosData({
    this.defensivos = const [],
    this.pragas = const [],
    this.diagnosticos = const [],
    this.defensivosFilter = '',
    this.pragasFilter = '',
    this.diagnosticosFilter = '',
  });

  List<FavoritoDefensivoModel> get defensivosFiltered {
    if (defensivosFilter.isEmpty) return defensivos;
    final filter = defensivosFilter.toLowerCase();
    return defensivos.where((item) =>
        item.displayName.toLowerCase().contains(filter) ||
        item.displayIngredient.toLowerCase().contains(filter) ||
        item.displayClass.toLowerCase().contains(filter) ||
        item.displayFabricante.toLowerCase().contains(filter)
    ).toList();
  }

  List<FavoritoPragaModel> get pragasFiltered {
    if (pragasFilter.isEmpty) return pragas;
    final filter = pragasFilter.toLowerCase();
    return pragas.where((item) =>
        item.displayName.toLowerCase().contains(filter) ||
        item.displaySecondaryName.toLowerCase().contains(filter) ||
        item.displayType.toLowerCase().contains(filter) ||
        (item.nomeCientifico?.toLowerCase().contains(filter) ?? false)
    ).toList();
  }

  List<FavoritoDiagnosticoModel> get diagnosticosFiltered {
    if (diagnosticosFilter.isEmpty) return diagnosticos;
    final filter = diagnosticosFilter.toLowerCase();
    return diagnosticos.where((item) =>
        item.displayName.toLowerCase().contains(filter) ||
        item.displayCultura.toLowerCase().contains(filter) ||
        item.displayCategoria.toLowerCase().contains(filter) ||
        item.displayDescription.toLowerCase().contains(filter)
    ).toList();
  }

  int get totalCount => defensivos.length + pragas.length + diagnosticos.length;
  int get totalFilteredCount => defensivosFiltered.length + pragasFiltered.length + diagnosticosFiltered.length;

  FavoritosData copyWith({
    List<FavoritoDefensivoModel>? defensivos,
    List<FavoritoPragaModel>? pragas,
    List<FavoritoDiagnosticoModel>? diagnosticos,
    String? defensivosFilter,
    String? pragasFilter,
    String? diagnosticosFilter,
  }) {
    return FavoritosData(
      defensivos: defensivos ?? this.defensivos,
      pragas: pragas ?? this.pragas,
      diagnosticos: diagnosticos ?? this.diagnosticos,
      defensivosFilter: defensivosFilter ?? this.defensivosFilter,
      pragasFilter: pragasFilter ?? this.pragasFilter,
      diagnosticosFilter: diagnosticosFilter ?? this.diagnosticosFilter,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is FavoritosData &&
        other.defensivos == defensivos &&
        other.pragas == pragas &&
        other.diagnosticos == diagnosticos &&
        other.defensivosFilter == defensivosFilter &&
        other.pragasFilter == pragasFilter &&
        other.diagnosticosFilter == diagnosticosFilter;
  }

  @override
  int get hashCode {
    return defensivos.hashCode ^
        pragas.hashCode ^
        diagnosticos.hashCode ^
        defensivosFilter.hashCode ^
        pragasFilter.hashCode ^
        diagnosticosFilter.hashCode;
  }
}