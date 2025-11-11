import '../data/models/fitossanitario_legacy.dart';

/// Extensão para FitossanitarioHive com métodos display compatíveis com DefensivoModel
extension FitossanitarioHiveExtension on FitossanitarioHive {
  String get displayName => nomeComum.isNotEmpty ? nomeComum : nomeTecnico;
  
  String get displayIngredient => ingredienteAtivo?.isNotEmpty == true 
      ? ingredienteAtivo! 
      : nomeTecnico;
  
  String get displayClass => classeAgronomica?.isNotEmpty == true
      ? classeAgronomica!
      : 'Não especificado';

  String get displayFabricante => fabricante?.isNotEmpty == true
      ? fabricante!
      : 'Não informado';
  
  String get displayModoAcao => modoAcao?.isNotEmpty == true
      ? modoAcao!
      : 'Não especificado';
  String get line1 => displayName;
  
  String get line2 => displayIngredient.length > 40 
      ? '${displayIngredient.substring(0, 40)}...' 
      : displayIngredient;

  /// Verifica se o defensivo está ativo e elegível
  bool get isActive => status && elegivel && comercializado == 1;

  /// Retorna classe de segurança baseada nas propriedades
  String get classeSeguranca {
    if (toxico?.toLowerCase() == 'alta') return 'Alto risco';
    if (toxico?.toLowerCase() == 'media') return 'Médio risco';
    if (toxico?.toLowerCase() == 'baixa') return 'Baixo risco';
    return 'Não classificado';
  }
}
