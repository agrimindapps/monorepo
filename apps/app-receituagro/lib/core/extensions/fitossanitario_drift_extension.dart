import '../../database/receituagro_database.dart';

/// Extensão para Fitossanitario (Drift) com métodos display compatíveis com DefensivoModel
extension FitossanitarioDriftExtension on Fitossanitario {
  String get displayName => nomeComum?.isNotEmpty == true ? nomeComum! : nome;

  String get displayIngredient =>
      ingredienteAtivo?.isNotEmpty == true ? ingredienteAtivo! : nome;

  String get displayClass => classeAgronomica?.isNotEmpty == true
      ? classeAgronomica!
      : 'Não especificado';

  String get displayFabricante =>
      fabricante?.isNotEmpty == true ? fabricante! : 'Não informado';

  String get displayModoAcao => 'Não especificado';

  /// Retorna modo de ação consultando a tabela FitossanitariosInfo
  Future<String> getDisplayModoAcao() async {
    try {
      // TODO: Implementar consulta à tabela FitossanitariosInfo quando necessário
      // Por enquanto retorna valor padrão
      return 'Não especificado';
    } catch (e) {
      return 'Não especificado';
    }
  }

  String get line1 => displayName;

  String get line2 => displayIngredient.length > 40
      ? '${displayIngredient.substring(0, 40)}...'
      : displayIngredient;

  /// Verifica se o defensivo está ativo e elegível
  bool get isActive => status && elegivel && comercializado == 1;

  /// Retorna classe de segurança baseada na toxicidade
  Future<String> getClasseSeguranca() async {
    try {
      // TODO: Implementar consulta à tabela FitossanitariosInfo para obter toxicidade
      // Por enquanto retorna valor padrão
      return 'Não classificado';
    } catch (e) {
      return 'Não classificado';
    }
  }

  /// Converte para Map de String para dynamic para compatibilidade
  Map<String, dynamic> toDataMap() {
    return {
      'id': id,
      'idDefensivo': idDefensivo,
      'nome': nome,
      'nomeComum': nomeComum,
      'fabricante': fabricante,
      'classe': classe,
      'classeAgronomica': classeAgronomica,
      'ingredienteAtivo': ingredienteAtivo,
      'registroMapa': registroMapa,
      'status': status,
      'comercializado': comercializado,
      'elegivel': elegivel,
    };
  }
}
