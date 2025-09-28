import 'dart:async';

import 'package:flutter/foundation.dart';

import '../services/analytics_service.dart';

/// Tipos de erro específicos do contexto automotivo do Gasometer
enum GasometerSyncErrorType {
  vehicleDataConflict,
  fuelRecordInvalid,
  maintenanceScheduleConflict,
  expenseCalculationError,
  oddometerInconsistency,
  reportGenerationFailed,
  offlineVehicleAccess,
  premiumFeatureBlocked,
  analyticsCorrupted,
}

/// Handler de erros específico para o contexto automotivo do Gasometer
class GasometerSyncErrorHandler {

  GasometerSyncErrorHandler(this._analytics);
  final AnalyticsService _analytics;
  final StreamController<GasometerSyncError> _errorController = 
      StreamController<GasometerSyncError>.broadcast();

  Stream<GasometerSyncError> get errorStream => _errorController.stream;

  /// Processa erro baseado no contexto automotivo
  Future<GasometerSyncError> handleSyncError(
    dynamic originalError, {
    String? modelType,
    String? operationType,
    Map<String, dynamic>? data,
  }) async {
    
    final gasometerError = _createGasometerError(
      originalError, 
      modelType: modelType,
      operationType: operationType,
      data: data,
    );

    // Log específico para analytics do Gasometer
    await _logGasometerError(gasometerError);

    // Adicionar ao stream para listeners
    if (!_errorController.isClosed) {
      _errorController.add(gasometerError);
    }

    return gasometerError;
  }

  /// Cria erro específico do Gasometer baseado no contexto
  GasometerSyncError _createGasometerError(
    dynamic originalError, {
    String? modelType,
    String? operationType,
    Map<String, dynamic>? data,
  }) {
    
    // Detectar tipo de erro baseado no modelo e operação
    final errorType = _detectGasometerErrorType(modelType, operationType, originalError, data);
    
    final userMessage = _generateUserMessage(errorType, modelType, data);
    final technicalMessage = _generateTechnicalMessage(errorType, originalError);
    final recoveryActions = _generateRecoveryActions(errorType, modelType);
    final fallbackData = _generateFallbackData(errorType, modelType, data);

    return GasometerSyncError(
      type: errorType,
      userMessage: userMessage,
      technicalMessage: technicalMessage,
      originalError: originalError,
      modelType: modelType,
      operationType: operationType,
      data: data,
      recoveryActions: recoveryActions,
      fallbackData: fallbackData,
      timestamp: DateTime.now(),
    );
  }

  /// Detecta tipo de erro específico do Gasometer
  GasometerSyncErrorType _detectGasometerErrorType(
    String? modelType, 
    String? operationType,
    dynamic originalError,
    Map<String, dynamic>? data,
  ) {
    final errorString = originalError.toString().toLowerCase();
    
    // Erros específicos por modelo
    switch (modelType?.toLowerCase()) {
      case 'vehicle':
      case 'vehicles':
        if (errorString.contains('conflict') || errorString.contains('duplicate')) {
          return GasometerSyncErrorType.vehicleDataConflict;
        }
        return GasometerSyncErrorType.offlineVehicleAccess;
        
      case 'fuel':
      case 'fuel_supply':
        if (errorString.contains('validation') || errorString.contains('invalid')) {
          return GasometerSyncErrorType.fuelRecordInvalid;
        }
        if (data != null && _hasOddometerIssue(data)) {
          return GasometerSyncErrorType.oddometerInconsistency;
        }
        break;
        
      case 'maintenance':
        if (errorString.contains('schedule') || errorString.contains('conflict')) {
          return GasometerSyncErrorType.maintenanceScheduleConflict;
        }
        break;
        
      case 'expense':
      case 'expenses':
        if (errorString.contains('calculation') || errorString.contains('math')) {
          return GasometerSyncErrorType.expenseCalculationError;
        }
        break;
        
      case 'report':
      case 'reports':
        return GasometerSyncErrorType.reportGenerationFailed;
        
      case 'analytics':
        return GasometerSyncErrorType.analyticsCorrupted;
    }

    // Erros de premium/licenciamento
    if (errorString.contains('premium') || errorString.contains('subscription')) {
      return GasometerSyncErrorType.premiumFeatureBlocked;
    }

    // Erro padrão baseado no modelo
    switch (modelType?.toLowerCase()) {
      case 'vehicle':
        return GasometerSyncErrorType.vehicleDataConflict;
      case 'fuel':
        return GasometerSyncErrorType.fuelRecordInvalid;
      case 'maintenance':
        return GasometerSyncErrorType.maintenanceScheduleConflict;
      case 'expense':
        return GasometerSyncErrorType.expenseCalculationError;
      default:
        return GasometerSyncErrorType.offlineVehicleAccess;
    }
  }

  /// Verifica se há problema com hodômetro nos dados
  bool _hasOddometerIssue(Map<String, dynamic> data) {
    final currentOdometer = data['current_odometer'] as num?;
    final previousOdometer = data['previous_odometer'] as num?;
    
    if (currentOdometer != null && previousOdometer != null) {
      return currentOdometer < previousOdometer;
    }
    return false;
  }

  /// Gera mensagem amigável para o usuário
  String _generateUserMessage(GasometerSyncErrorType type, String? modelType, Map<String, dynamic>? data) {
    switch (type) {
      case GasometerSyncErrorType.vehicleDataConflict:
        return 'Conflito nos dados do veículo. Alguns dados foram alterados em outro dispositivo. Deseja manter a versão mais recente?';
        
      case GasometerSyncErrorType.fuelRecordInvalid:
        return 'Dados de abastecimento inválidos. Verifique se o valor do combustível e a quilometragem estão corretos.';
        
      case GasometerSyncErrorType.maintenanceScheduleConflict:
        return 'Conflito no agendamento de manutenção. Outro serviço já foi agendado para esta data.';
        
      case GasometerSyncErrorType.expenseCalculationError:
        return 'Erro no cálculo de despesas. Verifique se os valores inseridos são válidos.';
        
      case GasometerSyncErrorType.oddometerInconsistency:
        final currentOdometer = data?['current_odometer'];
        final previousOdometer = data?['previous_odometer'];
        return 'Quilometragem inconsistente. O valor atual ($currentOdometer km) é menor que o anterior ($previousOdometer km).';
        
      case GasometerSyncErrorType.reportGenerationFailed:
        return 'Não foi possível gerar o relatório. Tente novamente ou verifique os dados selecionados.';
        
      case GasometerSyncErrorType.offlineVehicleAccess:
        return 'Alguns dados dos veículos não estão disponíveis offline. Conecte-se à internet para acessar todos os recursos.';
        
      case GasometerSyncErrorType.premiumFeatureBlocked:
        return 'Esta funcionalidade requer uma assinatura premium. Upgrade sua conta para continuar.';
        
      case GasometerSyncErrorType.analyticsCorrupted:
        return 'Dados de análise corrompidos. Os relatórios podem estar incompletos até a próxima sincronização.';
    }
  }

  /// Gera mensagem técnica para debug
  String _generateTechnicalMessage(GasometerSyncErrorType type, dynamic originalError) {
    return 'GasometerSync[${type.name}]: $originalError';
  }

  /// Gera ações de recuperação específicas
  List<GasometerRecoveryAction> _generateRecoveryActions(
    GasometerSyncErrorType type, 
    String? modelType,
  ) {
    switch (type) {
      case GasometerSyncErrorType.vehicleDataConflict:
        return [
          const GasometerRecoveryAction(
            id: 'keep_remote',
            title: 'Usar versão da nuvem',
            description: 'Manter os dados mais recentes do servidor',
            isRecommended: true,
          ),
          const GasometerRecoveryAction(
            id: 'keep_local',
            title: 'Usar versão local',
            description: 'Manter os dados deste dispositivo',
          ),
          const GasometerRecoveryAction(
            id: 'merge_data',
            title: 'Combinar dados',
            description: 'Tentar combinar as informações de ambas as versões',
          ),
        ];
        
      case GasometerSyncErrorType.fuelRecordInvalid:
        return [
          const GasometerRecoveryAction(
            id: 'fix_data',
            title: 'Corrigir dados',
            description: 'Abrir formulário para corrigir as informações',
            isRecommended: true,
          ),
          const GasometerRecoveryAction(
            id: 'skip_record',
            title: 'Pular registro',
            description: 'Ignorar este abastecimento e continuar',
          ),
        ];
        
      case GasometerSyncErrorType.maintenanceScheduleConflict:
        return [
          const GasometerRecoveryAction(
            id: 'reschedule',
            title: 'Reagendar',
            description: 'Escolher nova data para a manutenção',
            isRecommended: true,
          ),
          const GasometerRecoveryAction(
            id: 'override',
            title: 'Sobrescrever',
            description: 'Substituir o agendamento existente',
          ),
        ];
        
      case GasometerSyncErrorType.oddometerInconsistency:
        return [
          const GasometerRecoveryAction(
            id: 'correct_odometer',
            title: 'Corrigir quilometragem',
            description: 'Inserir a quilometragem correta do veículo',
            isRecommended: true,
          ),
          const GasometerRecoveryAction(
            id: 'reset_odometer',
            title: 'Resetar hodômetro',
            description: 'Considerar que o hodômetro foi resetado ou trocado',
          ),
        ];
        
      case GasometerSyncErrorType.premiumFeatureBlocked:
        return [
          const GasometerRecoveryAction(
            id: 'upgrade_premium',
            title: 'Fazer upgrade',
            description: 'Assinar plano premium para acessar o recurso',
            isRecommended: true,
          ),
          const GasometerRecoveryAction(
            id: 'use_basic',
            title: 'Usar versão básica',
            description: 'Continuar com funcionalidades limitadas',
          ),
        ];
        
      default:
        return [
          const GasometerRecoveryAction(
            id: 'retry',
            title: 'Tentar novamente',
            description: 'Repetir a operação de sincronização',
            isRecommended: true,
          ),
          const GasometerRecoveryAction(
            id: 'skip',
            title: 'Pular por agora',
            description: 'Continuar sem sincronizar este item',
          ),
        ];
    }
  }

  /// Gera dados de fallback para funcionalidade offline
  Map<String, dynamic>? _generateFallbackData(
    GasometerSyncErrorType type, 
    String? modelType, 
    Map<String, dynamic>? originalData,
  ) {
    switch (type) {
      case GasometerSyncErrorType.offlineVehicleAccess:
        return {
          'offline_mode': true,
          'limited_features': true,
          'sync_required': true,
        };
        
      case GasometerSyncErrorType.reportGenerationFailed:
        return {
          'basic_report': true,
          'estimated_data': true,
          'incomplete_analysis': true,
        };
        
      case GasometerSyncErrorType.analyticsCorrupted:
        return {
          'use_cached_analytics': true,
          'data_may_be_outdated': true,
        };
        
      default:
        return null;
    }
  }

  /// Log específico para analytics do Gasometer
  Future<void> _logGasometerError(GasometerSyncError error) async {
    try {
      await _analytics.recordError(
        error.originalError,
        null,
        reason: 'gasometer_sync_error',
        customKeys: {
          'error_type': error.type.name,
          'model_type': error.modelType ?? 'unknown',
          'operation_type': error.operationType ?? 'unknown',
          'user_message': error.userMessage,
          'recovery_actions_count': error.recoveryActions.length,
          'has_fallback_data': error.fallbackData != null,
        },
      );
      
      // Log específico para problemas automotivos
      await _analytics.logEvent('gasometer_sync_issue', {
        'issue_type': error.type.name,
        'affected_feature': error.modelType ?? 'general',
        'severity': _getErrorSeverity(error.type),
      });
      
    } catch (e) {
      if (kDebugMode) {
        debugPrint('Erro ao fazer log do erro do Gasometer: $e');
      }
    }
  }

  /// Determina severidade do erro
  String _getErrorSeverity(GasometerSyncErrorType type) {
    switch (type) {
      case GasometerSyncErrorType.oddometerInconsistency:
      case GasometerSyncErrorType.vehicleDataConflict:
        return 'high';
      case GasometerSyncErrorType.fuelRecordInvalid:
      case GasometerSyncErrorType.maintenanceScheduleConflict:
      case GasometerSyncErrorType.expenseCalculationError:
        return 'medium';
      case GasometerSyncErrorType.reportGenerationFailed:
      case GasometerSyncErrorType.analyticsCorrupted:
      case GasometerSyncErrorType.premiumFeatureBlocked:
        return 'low';
      case GasometerSyncErrorType.offlineVehicleAccess:
        return 'info';
    }
  }

  /// Dispose dos recursos
  void dispose() {
    _errorController.close();
  }
}

/// Erro específico do contexto automotivo Gasometer
class GasometerSyncError {

  const GasometerSyncError({
    required this.type,
    required this.userMessage,
    required this.technicalMessage,
    required this.originalError,
    this.modelType,
    this.operationType,
    this.data,
    required this.recoveryActions,
    this.fallbackData,
    required this.timestamp,
  });
  final GasometerSyncErrorType type;
  final String userMessage;
  final String technicalMessage;
  final dynamic originalError;
  final String? modelType;
  final String? operationType;
  final Map<String, dynamic>? data;
  final List<GasometerRecoveryAction> recoveryActions;
  final Map<String, dynamic>? fallbackData;
  final DateTime timestamp;

  /// Se o erro pode ser retentado automaticamente
  bool get isRetryable {
    switch (type) {
      case GasometerSyncErrorType.offlineVehicleAccess:
      case GasometerSyncErrorType.reportGenerationFailed:
      case GasometerSyncErrorType.analyticsCorrupted:
        return true;
      case GasometerSyncErrorType.premiumFeatureBlocked:
      case GasometerSyncErrorType.vehicleDataConflict:
      case GasometerSyncErrorType.maintenanceScheduleConflict:
      case GasometerSyncErrorType.oddometerInconsistency:
        return false;
      default:
        return true;
    }
  }

  /// Se o erro requer intervenção manual
  bool get requiresUserIntervention {
    return !isRetryable;
  }

  /// Se o erro bloqueia funcionalidade
  bool get isBlocking {
    switch (type) {
      case GasometerSyncErrorType.premiumFeatureBlocked:
      case GasometerSyncErrorType.oddometerInconsistency:
      case GasometerSyncErrorType.fuelRecordInvalid:
        return true;
      default:
        return false;
    }
  }

  @override
  String toString() {
    return 'GasometerSyncError(${type.name}): $userMessage';
  }
}

/// Ação de recuperação específica do Gasometer
class GasometerRecoveryAction {

  const GasometerRecoveryAction({
    required this.id,
    required this.title,
    required this.description,
    this.isRecommended = false,
    this.actionData,
  });
  final String id;
  final String title;
  final String description;
  final bool isRecommended;
  final Map<String, dynamic>? actionData;
}

/// Extensões úteis para trabalhar com erros do Gasometer
extension GasometerSyncErrorExtensions on GasometerSyncError {
  /// Retorna ícone apropriado para o tipo de erro
  String get iconName {
    switch (type) {
      case GasometerSyncErrorType.vehicleDataConflict:
        return 'directions_car';
      case GasometerSyncErrorType.fuelRecordInvalid:
        return 'local_gas_station';
      case GasometerSyncErrorType.maintenanceScheduleConflict:
        return 'build';
      case GasometerSyncErrorType.expenseCalculationError:
        return 'attach_money';
      case GasometerSyncErrorType.oddometerInconsistency:
        return 'speed';
      case GasometerSyncErrorType.reportGenerationFailed:
        return 'analytics';
      case GasometerSyncErrorType.offlineVehicleAccess:
        return 'wifi_off';
      case GasometerSyncErrorType.premiumFeatureBlocked:
        return 'star';
      case GasometerSyncErrorType.analyticsCorrupted:
        return 'warning';
    }
  }

  /// Retorna cor apropriada para o tipo de erro
  String get colorHex {
    switch (type) {
      case GasometerSyncErrorType.vehicleDataConflict:
      case GasometerSyncErrorType.fuelRecordInvalid:
        return '#FF5722'; // GasometerColors.primary
      case GasometerSyncErrorType.maintenanceScheduleConflict:
        return '#FF9800'; // Orange
      case GasometerSyncErrorType.expenseCalculationError:
        return '#4CAF50'; // GasometerColors.accent
      case GasometerSyncErrorType.oddometerInconsistency:
      case GasometerSyncErrorType.premiumFeatureBlocked:
        return '#F44336'; // Red
      case GasometerSyncErrorType.reportGenerationFailed:
      case GasometerSyncErrorType.analyticsCorrupted:
        return '#2196F3'; // GasometerColors.secondary
      case GasometerSyncErrorType.offlineVehicleAccess:
        return '#9E9E9E'; // Grey
    }
  }
}