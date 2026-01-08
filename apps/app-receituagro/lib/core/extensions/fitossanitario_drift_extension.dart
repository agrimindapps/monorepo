import '../../database/receituagro_database.dart';

/// Extensão para Fitossanitario (Drift) com métodos display compatíveis com DefensivoModel
extension FitossanitarioDriftExtension on Fitossanitario {
  String get displayName => nome;

  String get displayIngredient =>
      ingredienteAtivo?.isNotEmpty == true ? ingredienteAtivo! : nome;

  String get displayClass => classeAgronomica?.isNotEmpty == true
      ? classeAgronomica!
      : 'Não especificado';

  String get displayFabricante =>
      fabricante?.isNotEmpty == true ? fabricante! : 'Não informado';

  /// Modo de ação agora está no próprio Fitossanitario
  String get displayModoAcao => modoAcao ?? 'Não especificado';

  /// Retorna modo de ação (agora disponível direto no modelo)
  Future<String> getDisplayModoAcao() async {
    return modoAcao ?? 'Não especificado';
  }

  String get line1 => displayName;

  String get line2 => displayIngredient.length > 40
      ? '${displayIngredient.substring(0, 40)}...'
      : displayIngredient;

  /// Verifica se o defensivo está ativo e elegível
  bool get isActive => status && elegivel && comercializado == 1;

  /// Retorna classe de segurança baseada na toxicidade
  Future<String> getClasseSeguranca() async {
    return classeToxico ?? 'Não classificado';
  }

  /// Converte para Map de String para dynamic para compatibilidade
  Map<String, dynamic> toDataMap() {
    return {
      'idDefensivo': idDefensivo,
      'nome': nome,
      'nomeTecnico': nomeTecnico,
      'fabricante': fabricante,
      'classeAgronomica': classeAgronomica,
      'classeAmbiental': classeAmbiental,
      'classeToxico': classeToxico,
      'modoAcao': modoAcao,
      'formulacao': formulacao,
      'ingredienteAtivo': ingredienteAtivo,
      'registroMapa': registroMapa,
      'corrosivo': corrosivo,
      'inflamavel': inflamavel,
      'quantProduto': quantProduto,
      'status': status,
      'comercializado': comercializado,
      'elegivel': elegivel,
    };
  }
}
