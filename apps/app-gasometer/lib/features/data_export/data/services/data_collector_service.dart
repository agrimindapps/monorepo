import 'package:core/core.dart';

import '../../../../core/interfaces/i_expenses_repository.dart';
import '../../../maintenance/domain/entities/maintenance_entity.dart';
import '../../../odometer/domain/entities/odometer_entity.dart';
import '../../../vehicles/domain/repositories/vehicle_repository.dart';
import '../../../fuel/domain/repositories/fuel_repository.dart';
import '../../../maintenance/domain/repositories/maintenance_repository.dart';
import '../../../odometer/domain/repositories/odometer_repository.dart';
import '../../domain/entities/export_request.dart';

/// Serviço de coleta de dados do usuário
///
/// Responsabilidade: Coletar dados das diferentes fontes (Drift, SharedPreferences)
/// Aplica SRP (Single Responsibility Principle)

class DataCollectorService {
  DataCollectorService(
    this._vehicleRepository,
    this._fuelRepository,
    this._maintenanceRepository,
    this._expensesRepository,
    this._odometerRepository,
  );

  final VehicleRepository _vehicleRepository;
  final FuelRepository _fuelRepository;
  final MaintenanceRepository _maintenanceRepository;
  final IExpensesRepository _expensesRepository;
  final OdometerRepository _odometerRepository;

  /// Coleta dados de perfil do usuário
  Future<Map<String, dynamic>> collectUserProfile() async {
    try {
      final prefs = await SharedPreferences.getInstance();

      return {
        'user_id': prefs.getString('user_id') ?? 'anonymous',
        'display_name': prefs.getString('display_name') ?? '',
        'email': prefs.getString('email') ?? '',
        'created_at': prefs.getString('created_at') ?? '',
        'last_login': prefs.getString('last_login') ?? '',
        'is_premium': prefs.getBool('is_premium') ?? false,
        'theme_preference': prefs.getString('theme_preference') ?? 'system',
        'language': prefs.getString('language') ?? 'pt',
      };
    } catch (e) {
      SecureLogger.warning('Erro ao coletar dados do perfil', error: e);
      return {'error': 'Não foi possível acessar dados do perfil: $e'};
    }
  }

  /// Coleta dados de veículos
  Future<List<Map<String, dynamic>>> collectVehicleData(
    ExportRequest request,
  ) async {
    try {
      final result = await _vehicleRepository.getAllVehicles();
      return result.fold(
        (failure) => [
          {'error': 'Erro ao coletar dados de veículos: ${failure.message}'},
        ],
        (vehicles) {
          final vehicleMaps = vehicles
              .map((vehicle) => vehicle.toFirebaseMap())
              .toList();
          return _filterByDateRange(vehicleMaps, request, 'createdAt');
        },
      );
    } catch (e) {
      SecureLogger.warning('Erro ao coletar dados de veículos', error: e);
      return [
        {'error': 'Não foi possível acessar dados de veículos: $e'},
      ];
    }
  }

  /// Coleta dados de combustível
  Future<List<Map<String, dynamic>>> collectFuelData(
    ExportRequest request,
  ) async {
    try {
      final result = await _fuelRepository.getAllFuelRecords();
      return result.fold(
        (failure) => [
          {'error': 'Erro ao coletar dados de combustível: ${failure.message}'},
        ],
        (fuelRecords) {
          final fuelMaps = fuelRecords
              .map((fuel) => fuel.toFirebaseMap())
              .toList();
          return _filterByDateRange(fuelMaps, request, 'date');
        },
      );
    } catch (e) {
      SecureLogger.warning('Erro ao coletar dados de combustível', error: e);
      return [
        {'error': 'Não foi possível acessar dados de combustível: $e'},
      ];
    }
  }

  /// Coleta dados de manutenção
  Future<List<Map<String, dynamic>>> collectMaintenanceData(
    ExportRequest request,
  ) async {
    try {
      final result = await _maintenanceRepository.getAllMaintenanceRecords();
      return result.fold(
        (Failure failure) => [
          {'error': 'Erro ao coletar dados de manutenção: ${failure.message}'},
        ],
        (List<MaintenanceEntity> maintenances) {
          final maintenanceMaps = maintenances
              .map(
                (MaintenanceEntity maintenance) => maintenance.toFirebaseMap(),
              )
              .toList();
          return _filterByDateRange(maintenanceMaps, request, 'date');
        },
      );
    } catch (e) {
      SecureLogger.warning('Erro ao coletar dados de manutenção', error: e);
      return [
        {'error': 'Não foi possível acessar dados de manutenção: $e'},
      ];
    }
  }

  /// Coleta dados de odômetro
  Future<List<Map<String, dynamic>>> collectOdometerData(
    ExportRequest request,
  ) async {
    try {
      final result = await _odometerRepository.getAllOdometerReadings();
      return result.fold(
        (Failure failure) => [
          {'error': 'Erro ao coletar dados de odômetro: ${failure.message}'},
        ],
        (List<OdometerEntity> readings) {
          final readingMaps = readings
              .map((OdometerEntity reading) => reading.toFirebaseMap())
              .toList();
          return _filterByDateRange(readingMaps, request, 'date');
        },
      );
    } catch (e) {
      SecureLogger.warning('Erro ao coletar dados de odômetro', error: e);
      return [
        {'error': 'Não foi possível acessar dados de odômetro: $e'},
      ];
    }
  }

  /// Coleta dados de despesas
  Future<List<Map<String, dynamic>>> collectExpenseData(
    ExportRequest request,
  ) async {
    try {
      final expenses = await _expensesRepository.getAllExpenses();
      final expenseMaps = expenses
          .map((expense) => expense.toFirebaseMap())
          .toList();
      return _filterByDateRange(expenseMaps, request, 'date');
    } catch (e) {
      SecureLogger.warning('Erro ao coletar dados de despesas', error: e);
      return [
        {'error': 'Não foi possível acessar dados de despesas: $e'},
      ];
    }
  }

  /// Coleta dados de categorias
  Future<List<Map<String, dynamic>>> collectCategoryData() async {
    try {
      // Categories are static in gasometer, return empty for now
      return [];
    } catch (e) {
      SecureLogger.warning('Erro ao coletar categorias', error: e);
      return [
        {'error': 'Não foi possível acessar dados de categorias: $e'},
      ];
    }
  }

  /// Coleta configurações do app
  Future<Map<String, dynamic>> collectSettingsData() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final settings = <String, dynamic>{};

      for (final key in prefs.getKeys()) {
        if (!_isSensitiveKey(key)) {
          final value = prefs.get(key);
          settings[key] = value;
        }
      }

      return settings;
    } catch (e) {
      SecureLogger.warning('Erro ao coletar configurações', error: e);
      return {'error': 'Não foi possível acessar configurações: $e'};
    }
  }

  // ============================================================================
  // PRIVATE HELPER METHODS
  // ============================================================================

  /// Filtra dados por range de datas
  List<Map<String, dynamic>> _filterByDateRange(
    List<Map<String, dynamic>> data,
    ExportRequest request,
    String dateField,
  ) {
    if (request.startDate == null && request.endDate == null) {
      return data.map(_sanitizeData).toList();
    }

    return data
        .where((item) {
          final dateStr = _extractDate(item, dateField);
          if (dateStr == null) return true;

          try {
            final itemDate = DateTime.parse(dateStr);
            final startDate = request.startDate;
            final endDate = request.endDate;

            if (startDate != null && itemDate.isBefore(startDate)) return false;
            if (endDate != null && itemDate.isAfter(endDate)) return false;
            return true;
          } catch (e) {
            // Se não conseguir parsear a data, inclui o item
            return true;
          }
        })
        .map(_sanitizeData)
        .toList();
  }

  /// Extrai data de um mapa de dados
  String? _extractDate(Map<String, dynamic> data, String dateField) {
    if (data.containsKey(dateField) && data[dateField] != null) {
      return data[dateField].toString();
    }

    // Fallback para campos de data comuns se o campo específico não existir
    for (final fallbackField in [
      'date',
      'createdAt',
      'created_at',
      'timestamp',
      'updatedAt',
    ]) {
      if (data.containsKey(fallbackField) && data[fallbackField] != null) {
        return data[fallbackField].toString();
      }
    }
    return null;
  }

  /// Remove dados sensíveis
  Map<String, dynamic> _sanitizeData(Map<String, dynamic> data) {
    final sanitized = <String, dynamic>{};

    for (final entry in data.entries) {
      final key = entry.key;
      final value = entry.value;

      if (_isSensitiveKey(key)) continue;

      sanitized[key] = value;
    }

    return sanitized;
  }

  /// Verifica se chave é sensível
  bool _isSensitiveKey(String key) {
    final sensitiveKeys = {
      'token',
      'password',
      'secret',
      'key',
      'auth',
      'session',
      'firebase_token',
      'device_id',
      'installation_id',
    };

    final lowerKey = key.toLowerCase();
    return sensitiveKeys.any((sensitive) => lowerKey.contains(sensitive));
  }
}
