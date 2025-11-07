import 'package:core/core.dart';

import '../../../../core/services/database_inspector_service.dart';
import '../../domain/entities/export_request.dart';

/// Serviço de coleta de dados do usuário
///
/// Responsabilidade: Coletar dados das diferentes fontes (Hive, SharedPreferences)
/// Aplica SRP (Single Responsibility Principle)
@LazySingleton()
class DataCollectorService {
  DataCollectorService()
    : _databaseInspector = GasOMeterDatabaseInspectorService.instance;

  final GasOMeterDatabaseInspectorService _databaseInspector;

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
    return _collectFromHiveBox('vehicles', request);
  }

  /// Coleta dados de combustível
  Future<List<Map<String, dynamic>>> collectFuelData(
    ExportRequest request,
  ) async {
    return _collectFromHiveBox('fuel_records', request);
  }

  /// Coleta dados de manutenção
  Future<List<Map<String, dynamic>>> collectMaintenanceData(
    ExportRequest request,
  ) async {
    return _collectFromHiveBox('maintenance', request);
  }

  /// Coleta dados de odômetro
  Future<List<Map<String, dynamic>>> collectOdometerData(
    ExportRequest request,
  ) async {
    return _collectFromHiveBox('odometer', request);
  }

  /// Coleta dados de despesas
  Future<List<Map<String, dynamic>>> collectExpenseData(
    ExportRequest request,
  ) async {
    return _collectFromHiveBox('expenses', request);
  }

  /// Coleta dados de categorias
  Future<List<Map<String, dynamic>>> collectCategoryData() async {
    try {
      final records = await _databaseInspector.loadHiveBoxData('categories');
      final categories = <Map<String, dynamic>>[];

      for (final record in records) {
        categories.add(_sanitizeData(record.data));
      }

      return categories;
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

  /// Coleta dados de uma Hive box com filtro de data
  Future<List<Map<String, dynamic>>> _collectFromHiveBox(
    String boxName,
    ExportRequest request,
  ) async {
    try {
      final records = await _databaseInspector.loadHiveBoxData(boxName);
      final results = <Map<String, dynamic>>[];

      for (final record in records) {
        final data = record.data;
        if (_isWithinDateRange(data, request)) {
          results.add(_sanitizeData(data));
        }
      }

      return results;
    } catch (e) {
      SecureLogger.warning('Erro ao coletar dados de $boxName', error: e);
      return [
        {'error': 'Não foi possível acessar dados de $boxName: $e'},
      ];
    }
  }

  /// Verifica se dados estão dentro do range de datas
  bool _isWithinDateRange(Map<String, dynamic> data, ExportRequest request) {
    if (request.startDate == null && request.endDate == null) return true;

    final dataDateStr = _extractDate(data);
    if (dataDateStr == null) return true;

    try {
      final dataDate = DateTime.parse(dataDateStr);

      if (request.startDate != null && dataDate.isBefore(request.startDate!)) {
        return false;
      }

      if (request.endDate != null && dataDate.isAfter(request.endDate!)) {
        return false;
      }

      return true;
    } catch (e) {
      return true; // Se não conseguir parsear, inclui no resultado
    }
  }

  /// Extrai data de um mapa de dados
  String? _extractDate(Map<String, dynamic> data) {
    for (final dateField in [
      'date',
      'createdAt',
      'created_at',
      'timestamp',
      'updatedAt',
    ]) {
      if (data.containsKey(dateField) && data[dateField] != null) {
        return data[dateField].toString();
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
