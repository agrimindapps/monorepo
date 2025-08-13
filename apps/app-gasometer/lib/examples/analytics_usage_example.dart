// Exemplos de uso do Analytics Service no Gasometer

import '../core/services/analytics_service.dart';
import '../core/services/gasometer_firebase_service.dart';

/// Exemplos de como usar o Analytics Service em diferentes cenários
class AnalyticsUsageExample {
  static final AnalyticsService _analytics = AnalyticsService();

  /// Exemplo: Registrar abastecimento com analytics
  static Future<void> exampleFuelRefill() async {
    // 1. Salvar dados no Firebase com analytics automático
    await GasometerFirebaseService.saveFuelData(
      userId: 'user123',
      fuelData: {
        'fuelType': 'gasolina',
        'liters': 45.5,
        'totalCost': 280.50,
        'fullTank': true,
        'odometer': 85000,
        'pricePerLiter': 6.17,
      },
    );

    // 2. Analytics específicos adicionais (opcional)
    await _analytics.logUserAction('fuel_form_completed', parameters: {
      'completion_time_seconds': 180,
      'has_photo': 'false',
    });

    // 3. Log de navegação de tela
    await _analytics.logScreenView('FuelRefillSuccess');
  }

  /// Exemplo: Registrar manutenção
  static Future<void> exampleMaintenance() async {
    await GasometerFirebaseService.saveMaintenanceData(
      userId: 'user123',
      maintenanceData: {
        'type': 'oil_change',
        'cost': 150.00,
        'odometer': 85000,
        'description': 'Troca de óleo e filtro',
        'nextServiceOdometer': 90000,
      },
    );

    await _analytics.logScreenView('MaintenanceSuccess');
  }

  /// Exemplo: Registrar despesa
  static Future<void> exampleExpense() async {
    await GasometerFirebaseService.saveExpenseData(
      userId: 'user123',
      expenseData: {
        'type': 'insurance',
        'amount': 800.00,
        'description': 'Seguro veicular anual',
        'category': 'mandatory',
      },
    );

    await _analytics.logUserAction('expense_category_selected', parameters: {
      'category': 'insurance',
    });
  }

  /// Exemplo: Eventos de premium
  static Future<void> examplePremiumFeature() async {
    // Quando usuário tenta acessar feature premium
    await _analytics.logPremiumFeatureAttempted('advanced_reports');

    // Quando converte para premium
    await _analytics.logUserAction('premium_purchase', parameters: {
      'plan': 'monthly',
      'price': '9.99',
      'feature_trigger': 'advanced_reports',
    });
  }

  /// Exemplo: Eventos de navegação
  static Future<void> exampleNavigation() async {
    // Sempre que navegar para uma nova tela
    await _analytics.logScreenView('Dashboard');
    await _analytics.logScreenView('VehiclesList');
    await _analytics.logScreenView('Reports');
    await _analytics.logScreenView('Settings');
  }

  /// Exemplo: Log de erros específicos
  static Future<void> exampleErrorHandling() async {
    try {
      // Simular operação que pode falhar
      throw Exception('Erro ao sincronizar dados');
    } catch (e, stackTrace) {
      // Log de erro com contexto
      await _analytics.recordError(
        e,
        stackTrace,
        reason: 'Data sync failed',
        customKeys: {
          'operation': 'sync_fuel_data',
          'user_has_internet': 'true',
          'retry_count': 3,
        },
      );
    }
  }

  /// Exemplo: Configuração inicial do usuário
  static Future<void> exampleUserSetup(String userId) async {
    // Configurar usuário no analytics
    await _analytics.setUserId(userId);

    await _analytics.setUserProperties({
      'signup_date': DateTime.now().toIso8601String(),
      'platform': 'mobile',
      'app_version': '1.0.0',
      'user_type': 'free',
    });

    // Log de onboarding
    await _analytics.logUserAction('onboarding_completed', parameters: {
      'completion_time_minutes': 5,
      'skipped_steps': 0,
    });
  }

  /// Exemplo: Eventos de feature usage
  static Future<void> exampleFeatureUsage() async {
    // Quando usuário exporta dados
    await _analytics.logDataExport('pdf');

    // Quando visualiza relatórios
    await _analytics.logReportViewed('fuel_consumption_chart');

    // Log através do Firebase Service
    await GasometerFirebaseService.logFeatureUsage(
      userId: 'user123',
      featureName: 'vehicle_comparison',
      additionalData: {
        'vehicles_compared': 2,
        'chart_type': 'bar',
      },
    );
  }

  /// Exemplo: Teste de analytics (apenas em debug)
  static Future<void> exampleTesting() async {
    // Testar crash reporting (apenas em debug)
    await _analytics.testNonFatalError();

    // Log de teste
    await _analytics.log('Testing analytics integration');

    // Evento de teste
    await _analytics.logEvent('test_event', {
      'test_type': 'analytics_integration',
      'timestamp': DateTime.now().millisecondsSinceEpoch,
    });
  }
}

/// Como usar nos seus widgets/providers:
/// 
/// ```dart
/// class FuelProvider extends ChangeNotifier {
///   final AnalyticsService _analytics = AnalyticsService();
/// 
///   Future<void> addFuelRecord(FuelRecord record) async {
///     try {
///       // Salvar dados
///       await repository.save(record);
/// 
///       // Analytics automático via Firebase Service
///       await GasometerFirebaseService.saveFuelData(
///         userId: currentUserId,
///         fuelData: record.toMap(),
///       );
/// 
///       // Analytics específico adicional
///       await _analytics.logUserAction('fuel_record_added');
/// 
///     } catch (e) {
///       await _analytics.recordError(e, StackTrace.current);
///     }
///   }
/// }
/// ```