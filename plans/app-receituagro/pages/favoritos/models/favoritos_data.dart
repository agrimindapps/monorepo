// Project imports:
import '../../../models/favorito_model.dart';

class FavoritosData {
  // Single source of truth - apenas listas originais
  final List<FavoritoDefensivoModel> defensivos;
  final List<FavoritoPragaModel> pragas;
  final List<FavoritoDiagnosticoModel> diagnosticos;
  
  // Filtros de busca para cada tipo
  final String defensivosFilter;
  final String pragasFilter;
  final String diagnosticosFilter;

  FavoritosData({
    this.defensivos = const [],
    this.pragas = const [],
    this.diagnosticos = const [],
    this.defensivosFilter = '',
    this.pragasFilter = '',
    this.diagnosticosFilter = '',
  });

  // Getters computados para listas filtradas - não armazenam dados duplicados
  List<FavoritoDefensivoModel> get defensivosFiltered {
    if (defensivosFilter.isEmpty) return defensivos;
    
    final termoLowerCase = defensivosFilter.toLowerCase();
    return defensivos.where((defensivo) {
      final nomeComum = defensivo.nomeComum.toLowerCase();
      final ingredienteAtivo = defensivo.ingredienteAtivo.toLowerCase();
      return nomeComum.contains(termoLowerCase) || 
             ingredienteAtivo.contains(termoLowerCase);
    }).toList();
  }

  List<FavoritoPragaModel> get pragasFiltered {
    if (pragasFilter.isEmpty) return pragas;
    
    final termoLowerCase = pragasFilter.toLowerCase();
    return pragas.where((praga) {
      final nomeComum = praga.nomeComum.toLowerCase();
      final nomeCientifico = praga.nomeCientifico.toLowerCase();
      return nomeComum.contains(termoLowerCase) || 
             nomeCientifico.contains(termoLowerCase);
    }).toList();
  }

  List<FavoritoDiagnosticoModel> get diagnosticosFiltered {
    if (diagnosticosFilter.isEmpty) return diagnosticos;
    
    final termoLowerCase = diagnosticosFilter.toLowerCase();
    return diagnosticos.where((diagnostico) {
      final priNome = diagnostico.priNome.toLowerCase();
      final nomeComum = diagnostico.nomeComum.toLowerCase();
      final nomeCientifico = diagnostico.nomeCientifico.toLowerCase();
      final cultura = diagnostico.cultura?.toLowerCase() ?? '';
      return priNome.contains(termoLowerCase) ||
             nomeComum.contains(termoLowerCase) ||
             nomeCientifico.contains(termoLowerCase) ||
             cultura.contains(termoLowerCase);
    }).toList();
  }

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
}
