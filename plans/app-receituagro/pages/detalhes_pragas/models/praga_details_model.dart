// Project imports:
import '../../../models/praga_unica_model.dart';

/// Modelo de dados para a página de detalhes de pragas
class PragaDetailsModel {
  final PragaUnica praga;
  final List<dynamic> diagnosticos;
  final bool isFavorite;
  final double fontSize;

  const PragaDetailsModel({
    required this.praga,
    required this.diagnosticos,
    required this.isFavorite,
    required this.fontSize,
  });

  // =========================================================================
  // Computed Properties
  // =========================================================================
  
  String get descricaoFormatada => _formatText(praga.descricao);
  String get biologiaFormatada => _formatText(praga.biologia);
  String get sintomasFormatados => _formatText(praga.sintomas);
  String get ocorrenciaFormatada => _formatText(praga.ocorrencia);
  String get sinonomiasFormatadas => _formatText(praga.sinonimias);
  String get nomesVulgaresFormatados => _formatText(praga.nomesVulgares);

  bool get temSinonimias => sinonomiasFormatadas.isNotEmpty;
  bool get temNomesVulgares => nomesVulgaresFormatados.isNotEmpty;
  bool get temDescricao => descricaoFormatada.isNotEmpty;
  bool get temBiologia => biologiaFormatada.isNotEmpty;
  bool get temSintomas => sintomasFormatados.isNotEmpty;
  bool get temOcorrencia => ocorrenciaFormatada.isNotEmpty;

  String get nomeComum => praga.nomeComum;
  String get nomeCientifico => praga.nomeCientifico;
  String get idReg => praga.idReg;

  // =========================================================================
  // Private Methods
  // =========================================================================
  
  String _formatText(String? text) {
    if (text == null) return '';
    text = text.trim();
    return text.isEmpty || text == '-' ? '' : text;
  }

  // =========================================================================
  // Utility Methods
  // =========================================================================
  
  PragaDetailsModel copyWith({
    PragaUnica? praga,
    List<dynamic>? diagnosticos,
    bool? isFavorite,
    double? fontSize,
  }) {
    return PragaDetailsModel(
      praga: praga ?? this.praga,
      diagnosticos: diagnosticos ?? this.diagnosticos,
      isFavorite: isFavorite ?? this.isFavorite,
      fontSize: fontSize ?? this.fontSize,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is PragaDetailsModel &&
        other.praga == praga &&
        other.isFavorite == isFavorite &&
        other.fontSize == fontSize;
  }

  @override
  int get hashCode {
    return praga.hashCode ^ isFavorite.hashCode ^ fontSize.hashCode;
  }

  @override
  String toString() {
    return 'PragaDetailsModel(praga: ${praga.nomeComum}, isFavorite: $isFavorite, fontSize: $fontSize)';
  }
}
