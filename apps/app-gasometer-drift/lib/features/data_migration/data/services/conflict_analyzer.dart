import 'package:core/core.dart';

import '../../domain/entities/gasometer_account_data.dart';
import '../../domain/entities/gasometer_anonymous_data.dart';

/// Analisador de conflitos de dados
///
/// Responsabilidade: Analisar e identificar conflitos entre dados anônimos e de conta
/// Aplica SRP (Single Responsibility Principle)
@injectable
class ConflictAnalyzer {
  /// Analisa conflito entre dados anônimos e de conta
  DataConflictResult analyzeConflict(
    GasometerAnonymousData anonymousData,
    GasometerAccountData accountData,
  ) {
    final hasConflict = _hasSignificantConflict(anonymousData, accountData);
    final conflictDetails = _generateConflictDetails(
      anonymousData,
      accountData,
    );
    final recommendation = _generateRecommendation(anonymousData, accountData);
    final availableChoices = _getAvailableChoices(anonymousData, accountData);

    return DataConflictResult(
      hasConflict: hasConflict,
      anonymousData: anonymousData,
      accountData: accountData,
      conflictDetails: conflictDetails,
      recommendedChoice: recommendation,
      availableChoices: availableChoices,
    );
  }

  /// Verifica se há conflito significativo
  bool hasSignificantConflict(
    GasometerAnonymousData anonymousData,
    GasometerAccountData accountData,
  ) {
    return _hasSignificantConflict(anonymousData, accountData);
  }

  /// Gera recomendação de resolução
  DataResolutionChoice? getRecommendation(
    GasometerAnonymousData anonymousData,
    GasometerAccountData accountData,
  ) {
    return _generateRecommendation(anonymousData, accountData);
  }

  // ============================================================================
  // PRIVATE HELPER METHODS
  // ============================================================================

  bool _hasSignificantConflict(
    GasometerAnonymousData anonymousData,
    GasometerAccountData accountData,
  ) {
    // Nenhum dos dois tem dados significativos - sem conflito
    if (!anonymousData.hasSignificantData && !accountData.hasSignificantData) {
      return false;
    }

    // Apenas um tem dados significativos - sem conflito real
    if (anonymousData.hasSignificantData != accountData.hasSignificantData) {
      return false;
    }

    // Ambos têm dados significativos - há conflito
    return anonymousData.hasSignificantData && accountData.hasSignificantData;
  }

  Map<String, dynamic> _generateConflictDetails(
    GasometerAnonymousData anonymousData,
    GasometerAccountData accountData,
  ) {
    return {
      'anonymous_vehicles': anonymousData.vehicleCount,
      'account_vehicles': accountData.vehicleCount,
      'anonymous_fuel_records': anonymousData.fuelRecordCount,
      'account_fuel_records': accountData.fuelRecordCount,
      'anonymous_maintenance': anonymousData.maintenanceRecordCount,
      'account_maintenance': accountData.maintenanceRecordCount,
      'anonymous_total_records': anonymousData.recordCount,
      'account_total_records': accountData.recordCount,
      'data_value_comparison': {
        'anonymous_score': anonymousData.breakdown['data_value_score'] ?? 0,
        'account_score': accountData.breakdown['data_maturity_score'] ?? 0,
      },
      'anonymous_has_significant_data': anonymousData.hasSignificantData,
      'account_has_significant_data': accountData.hasSignificantData,
      'account_is_established': accountData.isEstablishedData,
      'anonymous_is_valuable': anonymousData.isValuableData,
    };
  }

  DataResolutionChoice? _generateRecommendation(
    GasometerAnonymousData anonymousData,
    GasometerAccountData accountData,
  ) {
    // Se não há conflito significativo, nenhuma recomendação
    if (!_hasSignificantConflict(anonymousData, accountData)) {
      return null;
    }

    // Se conta é estabelecida (tem histórico), prioriza conta
    if (accountData.isEstablishedData) {
      return DataResolutionChoice.keepAccountData;
    }

    // Se dados anônimos são valiosos e conta não tem dados, mantém anônimo
    if (anonymousData.isValuableData && !accountData.hasSignificantData) {
      return DataResolutionChoice.keepAnonymousData;
    }

    // Padrão: manter dados da conta
    return DataResolutionChoice.keepAccountData;
  }

  List<DataResolutionChoice> _getAvailableChoices(
    GasometerAnonymousData anonymousData,
    GasometerAccountData accountData,
  ) {
    final choices = <DataResolutionChoice>[DataResolutionChoice.cancel];

    // Sempre oferece opção de manter dados da conta
    choices.insert(0, DataResolutionChoice.keepAccountData);

    // Só oferece manter dados anônimos se houver dados significativos
    if (anonymousData.hasSignificantData) {
      choices.insert(0, DataResolutionChoice.keepAnonymousData);
    }

    return choices;
  }

  /// Calcula score de conflito (0-100)
  /// Útil para determinar severidade do conflito
  int calculateConflictScore(
    GasometerAnonymousData anonymousData,
    GasometerAccountData accountData,
  ) {
    if (!_hasSignificantConflict(anonymousData, accountData)) {
      return 0;
    }

    int score = 0;

    // Score baseado em quantidade de registros
    final anonymousRecords = anonymousData.recordCount;
    final accountRecords = accountData.recordCount;
    final totalRecords = anonymousRecords + accountRecords;

    if (totalRecords > 0) {
      final minRecords = anonymousRecords < accountRecords
          ? anonymousRecords
          : accountRecords;
      score += ((minRecords / totalRecords) * 50).round();
    }

    // Score baseado em valor dos dados
    if (anonymousData.isValuableData) score += 25;
    if (accountData.isEstablishedData) score += 25;

    return score.clamp(0, 100);
  }
}
