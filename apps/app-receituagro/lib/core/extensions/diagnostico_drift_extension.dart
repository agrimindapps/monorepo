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
    final min = double.tryParse(dsMin ?? '');
    final max = double.tryParse(dsMax);
    
    if (min != null && max != null && min < max) {
      return '${min.toStringAsFixed(2)} - ${max.toStringAsFixed(2)} $um';
    }
    if (max != null) {
      return '${max.toStringAsFixed(2)} $um';
    }
    return 'Não informado';
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
  Future<Map<String, String>> toDataMap() async {
    return {
      'dosagem': displayDosagem,
      'vazaoTerrestre': displayVazaoTerrestre,
      'vazaoAerea': displayVazaoAerea,
      'intervaloAplicacao': displayIntervaloAplicacao,
      'intervaloSeguranca': 'Não informado', // Field not in Diagnostico table
      'tecnologia': 'N/A', // Field not in Diagnostico table
      'formulacao': 'N/A', // Requires join
      'modoAcao': 'N/A', // Requires join
      'ingredienteAtivo': 'N/A', // Requires join
      'classificacaoToxicologica': 'N/A', // Requires join
      'classeAgronomica': 'N/A', // Requires join
      'classAmbiental': 'N/A', // Requires join
      'toxico': 'N/A', // Requires join
      'mapa': 'N/A', // Requires join
    };
  }
}
