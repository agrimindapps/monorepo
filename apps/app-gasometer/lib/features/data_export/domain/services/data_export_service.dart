import 'dart:convert';

import 'package:core/core.dart';
import 'package:drift/drift.dart';

import '../../../../database/gasometer_database.dart';
import '../entities/export_metadata.dart';
import '../entities/export_progress.dart';
import '../entities/export_request.dart';

/// Serviço principal para coleta e exportação de dados LGPD
class DataExportService {
  DataExportService(this._db, this._authService);
  
  final GasometerDatabase _db;
  final FirebaseAuthService _authService;

  /// Coleta todos os dados do usuário de acordo com as categorias especificadas
  Future<Map<String, dynamic>> collectUserData(
    ExportRequest request,
    void Function(ExportProgress progress)? onProgress,
  ) async {
    final userData = <String, dynamic>{};
    int processedCategories = 0;
    final totalCategories = request.includedCategories.length;
    onProgress?.call(ExportProgress.initial());
    for (final categoryKey in request.includedCategories) {
      onProgress?.call(
        ExportProgress.collecting(
          categoryKey,
          processedCategories,
          totalCategories,
        ),
      );

      try {
        switch (categoryKey) {
          case 'profile':
            userData['user_profile'] = await _collectUserProfile();
            break;
          case 'vehicles':
            userData['vehicles'] = await _collectVehicleData(request);
            break;
          case 'fuel_records':
            userData['fuel_records'] = await _collectFuelData(request);
            break;
          case 'maintenance':
            userData['maintenance_records'] = await _collectMaintenanceData(
              request,
            );
            break;
          case 'odometer':
            userData['odometer_readings'] = await _collectOdometerData(request);
            break;
          case 'expenses':
            userData['expenses'] = await _collectExpenseData(request);
            break;
          case 'categories':
            userData['expense_categories'] = await _collectCategoryData();
            break;
          case 'settings':
            userData['app_settings'] = await _collectSettingsData();
            break;
          default:
            continue;
        }
      } catch (e) {
        print('Erro ao coletar dados da categoria $categoryKey: $e');
        userData['${categoryKey}_error'] = 'Erro na coleta: $e';
      }

      processedCategories++;
    }

    return userData;
  }

  /// Gera arquivo JSON estruturado com todos os dados
  Future<Uint8List> generateJsonExport(
    Map<String, dynamic> userData,
    ExportMetadata metadata,
  ) async {
    final exportData = {
      'export_metadata': metadata.toJson(),
      'lgpd_compliance_info': {
        'data_controller': 'GasOMeter App',
        'export_purpose':
            'Atendimento ao direito de portabilidade de dados (LGPD)',
        'user_rights': [
          'Direito de acesso aos dados pessoais',
          'Direito de correção de dados inexatos',
          'Direito de eliminação de dados desnecessários',
          'Direito de portabilidade dos dados',
          'Direito de revogação do consentimento',
        ],
        'contact_info':
            'Para questões sobre seus dados, contate o DPO em: privacy@gasometer.app',
      },
      'exported_data': userData,
    };

    final jsonString = const JsonEncoder.withIndent('  ').convert(exportData);
    return Uint8List.fromList(utf8.encode(jsonString));
  }

  /// Gera arquivo CSV para dados tabulares
  Future<Uint8List> generateCsvExport(Map<String, dynamic> userData) async {
    final csvLines = <String>[];
    csvLines.add('Categoria,Item,Campo,Valor,Data_Registro');
    for (final entry in userData.entries) {
      final category = entry.key;
      final data = entry.value;

      if (data is List) {
        for (int i = 0; i < data.length; i++) {
          final item = data[i];
          if (item is Map<String, dynamic>) {
            for (final field in item.entries) {
              csvLines.add(
                _escapeCsvField([
                  category,
                  'item_${i + 1}',
                  field.key,
                  field.value?.toString() ?? '',
                  _extractDate(item) ?? '',
                ]),
              );
            }
          }
        }
      } else if (data is Map<String, dynamic>) {
        for (final field in data.entries) {
          csvLines.add(
            _escapeCsvField([
              category,
              'single_record',
              field.key,
              field.value?.toString() ?? '',
              DateTime.now().toIso8601String(),
            ]),
          );
        }
      }
    }

    final csvString = csvLines.join('\n');
    return Uint8List.fromList(utf8.encode(csvString));
  }

  /// Cria um arquivo com metadados da exportação
  Future<Uint8List> createMetadataFile(ExportMetadata metadata) async {
    final metadataJson = const JsonEncoder.withIndent('  ').convert({
      'informacoes_exportacao': metadata.toJson(),
      'instrucoes': {
        'dados_completos_json':
            'Contém todos os seus dados em formato estruturado JSON',
        'dados_tabulares_csv':
            'Contém os dados em formato tabular para análise em planilhas',
        'lgpd_compliance':
            'Esta exportação está em conformidade com a LGPD (Lei Geral de Proteção de Dados)',
        'formato_datas':
            'Todas as datas estão no formato ISO 8601 (YYYY-MM-DDTHH:MM:SS)',
      },
    });

    return Uint8List.fromList(utf8.encode(metadataJson));
  }

  /// Gera checksum simples do arquivo (usando hashCode)
  String generateChecksum(Uint8List data) {
    return data.hashCode.toString();
  }

  Future<Map<String, dynamic>> _collectUserProfile() async {
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
      return {'error': 'Não foi possível acessar dados do perfil: $e'};
    }
  }

  Future<List<Map<String, dynamic>>> _collectVehicleData(
    ExportRequest request,
  ) async {
    try {
      final user = await _authService.currentUser.first;
      final userId = user?.id;
      if (userId == null) return [];
      
      final vehicles = await _db.getVehiclesByUser(userId);
      final vehiclesData = <Map<String, dynamic>>[];

      for (final vehicle in vehicles) {
        final vehicleData = vehicle.toJson();
        if (_isWithinDateRange(vehicleData, request)) {
          vehiclesData.add(_sanitizeData(vehicleData));
        }
      }

      return vehiclesData;
    } catch (e) {
      return [
        {'error': 'Não foi possível acessar dados dos veículos: $e'},
      ];
    }
  }

  Future<List<Map<String, dynamic>>> _collectFuelData(
    ExportRequest request,
  ) async {
    try {
      final user = await _authService.currentUser.first;
      final userId = user?.id;
      if (userId == null) return [];
      
      final vehicles = await _db.getVehiclesByUser(userId);
      final fuelRecords = <Map<String, dynamic>>[];

      for (final vehicle in vehicles) {
        final supplies = await _db.getFuelSuppliesByVehicle(vehicle.id);
        for (final supply in supplies) {
          final fuelData = supply.toJson();
          if (_isWithinDateRange(fuelData, request)) {
            fuelRecords.add(_sanitizeData(fuelData));
          }
        }
      }

      return fuelRecords;
    } catch (e) {
      return [
        {'error': 'Não foi possível acessar dados de abastecimento: $e'},
      ];
    }
  }

  Future<List<Map<String, dynamic>>> _collectMaintenanceData(
    ExportRequest request,
  ) async {
    try {
      final user = await _authService.currentUser.first;
      final userId = user?.id;
      if (userId == null) return [];
      
      final vehicles = await _db.getVehiclesByUser(userId);
      final maintenanceRecords = <Map<String, dynamic>>[];

      for (final vehicle in vehicles) {
        final maintenances = await (_db.select(_db.maintenances)
          ..where((tbl) => tbl.vehicleId.equals(vehicle.id) & tbl.isDeleted.equals(false)))
          .get();
        
        for (final maintenance in maintenances) {
          final maintenanceData = maintenance.toJson();
          if (_isWithinDateRange(maintenanceData, request)) {
            maintenanceRecords.add(_sanitizeData(maintenanceData));
          }
        }
      }

      return maintenanceRecords;
    } catch (e) {
      return [
        {'error': 'Não foi possível acessar dados de manutenção: $e'},
      ];
    }
  }

  Future<List<Map<String, dynamic>>> _collectOdometerData(
    ExportRequest request,
  ) async {
    try {
      final user = await _authService.currentUser.first;
      final userId = user?.id;
      if (userId == null) return [];
      
      final vehicles = await _db.getVehiclesByUser(userId);
      final odometerRecords = <Map<String, dynamic>>[];

      for (final vehicle in vehicles) {
        final readings = await (_db.select(_db.odometerReadings)
          ..where((tbl) => tbl.vehicleId.equals(vehicle.id) & tbl.isDeleted.equals(false)))
          .get();
        
        for (final reading in readings) {
          final odometerData = reading.toJson();
          if (_isWithinDateRange(odometerData, request)) {
            odometerRecords.add(_sanitizeData(odometerData));
          }
        }
      }

      return odometerRecords;
    } catch (e) {
      return [
        {'error': 'Não foi possível acessar dados do odômetro: $e'},
      ];
    }
  }

  Future<List<Map<String, dynamic>>> _collectExpenseData(
    ExportRequest request,
  ) async {
    try {
      final user = await _authService.currentUser.first;
      final userId = user?.id;
      if (userId == null) return [];
      
      final vehicles = await _db.getVehiclesByUser(userId);
      final expenseRecords = <Map<String, dynamic>>[];

      for (final vehicle in vehicles) {
        final expenses = await (_db.select(_db.expenses)
          ..where((tbl) => tbl.vehicleId.equals(vehicle.id) & tbl.isDeleted.equals(false)))
          .get();
        
        for (final expense in expenses) {
          final expenseData = expense.toJson();
          if (_isWithinDateRange(expenseData, request)) {
            expenseRecords.add(_sanitizeData(expenseData));
          }
        }
      }

      return expenseRecords;
    } catch (e) {
      return [
        {'error': 'Não foi possível acessar dados de despesas: $e'},
      ];
    }
  }

  Future<List<Map<String, dynamic>>> _collectCategoryData() async {
    try {
      // Categories are static in gasometer, return empty for now
      return [];
    } catch (e) {
      return [
        {'error': 'Não foi possível acessar dados de categorias: $e'},
      ];
    }
  }

  Future<Map<String, dynamic>> _collectSettingsData() async {
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
      return {'error': 'Não foi possível acessar configurações: $e'};
    }
  }

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

  String _escapeCsvField(List<String> fields) {
    return fields
        .map((field) {
          if (field.contains(',') ||
              field.contains('"') ||
              field.contains('\n')) {
            return '"${field.replaceAll('"', '""')}"';
          }
          return field;
        })
        .join(',');
  }
}
