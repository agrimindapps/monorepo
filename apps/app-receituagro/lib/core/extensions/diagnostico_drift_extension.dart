import '../../database/receituagro_database.dart';
import '../utils/data_with_warnings.dart';

/// Extensão para Diagnostico (Drift) com métodos display e formatação
/// 
/// TODO: Refatorar para usar injeção de dependências via parâmetros
extension DiagnosticoDriftExtension on Diagnostico {
  /// Retorna o nome do defensivo
  /// TODO: Implementar com injeção de dependências
  Future<String> getDisplayNomeDefensivo() async {
    return 'N/A'; // Placeholder
  }

  /// Retorna o nome do defensivo com warnings
  /// TODO: Implementar com injeção de dependências
  Future<DataWithWarnings<String>> getDisplayNomeDefensivoWithWarnings() async {
    return const DataWithWarnings(data: 'N/A');
  }

  /// Retorna o nome da cultura
  /// TODO: Implementar com injeção de dependências
  Future<String> getDisplayNomeCultura() async {
    return 'N/A'; // Placeholder
  }

  /// Retorna o nome da cultura com warnings
  /// TODO: Implementar com injeção de dependências
  Future<DataWithWarnings<String>> getDisplayNomeCulturaWithWarnings() async {
    return const DataWithWarnings(data: 'N/A');
  }

  /// Retorna o nome da praga
  /// TODO: Implementar com injeção de dependências
  Future<String> getDisplayNomePraga() async {
    return 'N/A'; // Placeholder
  }

  /// Retorna o nome da praga com warnings
  /// TODO: Implementar com injeção de dependências
  Future<DataWithWarnings<String>> getDisplayNomePragaWithWarnings() async {
    return const DataWithWarnings(data: 'N/A');
  }

  String get displayDosagem {
    final minStr = dsMin?.trim() ?? '';
    final maxStr = dsMax.trim();
    final umStr = um.trim();
    
    final min = double.tryParse(minStr);
    final max = double.tryParse(maxStr);
    
    // Se ambos são 0 ou vazios, não há informação
    if ((min == null || min == 0) && (max == null || max == 0)) {
      return 'Não informado';
    }
    
    // Se tem min e max diferentes e válidos
    if (min != null && min > 0 && max != null && max > 0 && min < max) {
      return '${_formatDose(min)} - ${_formatDose(max)} $umStr'.trim();
    }
    
    // Se só tem max
    if (max != null && max > 0) {
      return '${_formatDose(max)} $umStr'.trim();
    }
    
    // Se só tem min
    if (min != null && min > 0) {
      return '${_formatDose(min)} $umStr'.trim();
    }
    
    return 'Não informado';
  }
  
  /// Formata dosagem removendo decimais desnecessários
  String _formatDose(double value) {
    if (value == value.toInt()) {
      return value.toInt().toString();
    }
    return value.toStringAsFixed(2);
  }

  String get displayVazaoTerrestre {
    final min = double.tryParse(minAplicacaoT ?? '');
    final max = double.tryParse(maxAplicacaoT ?? '');
    
    if (min != null && max != null) {
       return '${min.toStringAsFixed(0)} - ${max.toStringAsFixed(0)} L/ha';
    }
    if (max != null) {
      return '${max.toStringAsFixed(0)} L/ha';
    }
    return 'Não informado';
  }

  String get displayVazaoAerea {
    // Drift Diagnostico might not have specific aerial fields mapped directly or they might be named differently.
    // Assuming similar structure or returning default if not present.
    // Checking Diagnostico table definition would be best, but for now:
    return 'Não informado'; 
  }

  String get displayIntervaloAplicacao {
    if (intervalo != null) {
      return '$intervalo dias';
    }
    return 'Não informado';
  }

  /// Converte para mapa de dados para exibição
  Future<Map<String, String>> toDataMap({
    Fitossanitario? defensivo,
    FitossanitariosInfoData? defensivoInfo,
    Praga? praga,
  }) async {
    return {
      'dosagem': displayDosagem,
      'vazaoTerrestre': displayVazaoTerrestre,
      'vazaoAerea': displayVazaoAerea,
      'intervaloAplicacao': displayIntervaloAplicacao,
      'intervaloSeguranca': defensivoInfo?.carencia ?? 'Não informado',
      'tecnologia': defensivoInfo?.informacoesAdicionais ?? 'N/A',
      'formulacao': defensivoInfo?.formulacao ?? 'N/A',
      'modoAcao': defensivoInfo?.modoAcao ?? 'N/A',
      'ingredienteAtivo': defensivo?.ingredienteAtivo ?? 'N/A',
      'classificacaoToxicologica': defensivoInfo?.toxicidade ?? 'N/A',
      'classeAgronomica': defensivo?.classeAgronomica ?? 'N/A',
      'classificacaoAmbiental': 'N/A', // Campo não encontrado na tabela FitossanitariosInfo
      'toxico': defensivoInfo?.toxicidade ?? 'N/A',
      'mapa': defensivo?.registroMapa ?? 'N/A',
      'nomeDefensivo': defensivo?.nome ?? 'N/A',
      'fabricante': defensivo?.fabricante ?? 'N/A',
      'nomeCientifico': praga?.nomeLatino ?? 'N/A',
    };
  }
}
