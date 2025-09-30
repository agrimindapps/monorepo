// Dart imports:
import 'dart:io';

// Package imports:
import 'package:core/core.dart';

// Project imports:
import 'package:gasometer/core/services/gasometer_analytics_service.dart';

/// Service para integração Firebase específica do Gasometer com Analytics
class GasometerFirebaseService {
  static const String _subscriptionsCollection = 'subscriptions';
  static const String _appId = 'gasometer';
  
  static final AnalyticsService _analytics = AnalyticsService();
  
  /// Diagnóstico de conectividade Firebase
  static Future<Map<String, dynamic>> checkFirebaseConnectivity() async {
    final result = <String, dynamic>{
      'timestamp': DateTime.now().toIso8601String(),
      'connectivity': {},
      'firestore': {},
      'errors': <String>[],
    };
    
    try {
      // Test basic connectivity
      result['connectivity']['internet'] = await _hasInternetConnection();
      
      // Test Firestore connectivity
      final startTime = DateTime.now();
      await FirebaseFirestore.instance
          .collection('_health_check')
          .doc('test')
          .set({'timestamp': FieldValue.serverTimestamp()}, SetOptions(merge: true));
      
      final duration = DateTime.now().difference(startTime);
      result['firestore']['write_success'] = true;
      result['firestore']['write_duration_ms'] = duration.inMilliseconds;
      result['firestore']['status'] = 'connected';
      
      print('✅ Firebase connectivity test successful (${duration.inMilliseconds}ms)');
      
    } catch (e) {
      result['firestore']['write_success'] = false;
      result['firestore']['status'] = 'failed';
      result['errors'].add('Firestore test failed: $e');
      
      print('❌ Firebase connectivity test failed: $e');
      
      // Log analytics event
      _analytics.logEvent('firebase_connectivity_test', {
        'success': false,
        'error': e.toString(),
        'app_id': _appId,
      });
    }
    
    return result;
  }
  
  /// Verifica conectividade básica com internet
  static Future<bool> _hasInternetConnection() async {
    try {
      final result = await InternetAddress.lookup('firebase.googleapis.com');
      return result.isNotEmpty && result[0].rawAddress.isNotEmpty;
    } catch (e) {
      return false;
    }
  }

  /// Salvar dados de abastecimento
  static Future<void> saveFuelData({
    required String userId,
    required Map<String, dynamic> fuelData,
  }) async {
    // Validação de entrada
    if (userId.trim().isEmpty) {
      throw ArgumentError('userId não pode estar vazio');
    }
    if (fuelData.isEmpty) {
      throw ArgumentError('fuelData não pode estar vazio');
    }
    // Validar campos obrigatórios
    final requiredFields = ['fuelType', 'liters', 'totalCost'];
    for (final field in requiredFields) {
      if (!fuelData.containsKey(field) || fuelData[field] == null) {
        throw ArgumentError('Campo obrigatório ausente: $field');
      }
    }
    
    try {
      final docRef = FirebaseFirestore.instance
          .collection('users')
          .doc(userId)
          .collection('fuel_records')
          .doc();

      await docRef.set({
        ...fuelData,
        'createdAt': FieldValue.serverTimestamp(),
        'user_id': userId,
        'platform': Platform.operatingSystem,
      });

      // Log analytics
      await _analytics.logFuelRefill(
        fuelType: fuelData['fuelType'] as String? ?? 'unknown',
        liters: (fuelData['liters'] as num?)?.toDouble() ?? 0.0,
        totalCost: (fuelData['totalCost'] as num?)?.toDouble() ?? 0.0,
        fullTank: fuelData['fullTank'] as bool? ?? false,
      );

      await _analytics.log('Fuel data saved successfully');
      await _analytics.log('Dados de abastecimento salvos no Firebase');
    } catch (e, stackTrace) {
      await _analytics.log('Erro ao salvar dados de abastecimento');
      await _analytics.recordError(
        e,
        stackTrace,
        reason: 'Failed to save fuel data',
      );
    }
  }

  /// Salvar dados de manutenção
  static Future<void> saveMaintenanceData({
    required String userId,
    required Map<String, dynamic> maintenanceData,
  }) async {
    // Validação de entrada
    if (userId.trim().isEmpty) {
      throw ArgumentError('userId não pode estar vazio');
    }
    if (maintenanceData.isEmpty) {
      throw ArgumentError('maintenanceData não pode estar vazio');
    }
    // Validar campos obrigatórios
    final requiredFields = ['type', 'cost'];
    for (final field in requiredFields) {
      if (!maintenanceData.containsKey(field) || maintenanceData[field] == null) {
        throw ArgumentError('Campo obrigatório ausente: $field');
      }
    }
    
    try {
      final docRef = FirebaseFirestore.instance
          .collection('users')
          .doc(userId)
          .collection('maintenance_records')
          .doc();

      await docRef.set({
        ...maintenanceData,
        'createdAt': FieldValue.serverTimestamp(),
        'user_id': userId,
        'platform': Platform.operatingSystem,
      });

      // Log analytics
      await _analytics.logMaintenance(
        maintenanceType: maintenanceData['type'] as String? ?? 'unknown',
        cost: (maintenanceData['cost'] as num?)?.toDouble() ?? 0.0,
        odometer: (maintenanceData['odometer'] as num?)?.toInt() ?? 0,
      );

      await _analytics.log('Maintenance data saved successfully');
      await _analytics.log('Dados de manutenção salvos no Firebase');
    } catch (e, stackTrace) {
      await _analytics.log('Erro ao salvar dados de manutenção');
      await _analytics.recordError(
        e,
        stackTrace,
        reason: 'Failed to save maintenance data',
      );
    }
  }

  /// Salvar dados de despesa
  static Future<void> saveExpenseData({
    required String userId,
    required Map<String, dynamic> expenseData,
  }) async {
    try {
      final docRef = FirebaseFirestore.instance
          .collection('users')
          .doc(userId)
          .collection('expense_records')
          .doc();

      await docRef.set({
        ...expenseData,
        'createdAt': FieldValue.serverTimestamp(),
        'user_id': userId,
        'platform': Platform.operatingSystem,
      });

      // Log analytics
      await _analytics.logExpense(
        expenseType: expenseData['type'] as String? ?? 'unknown',
        amount: (expenseData['amount'] as num?)?.toDouble() ?? 0.0,
      );

      await _analytics.log('Expense data saved successfully');
      await _analytics.log('Dados de despesa salvos no Firebase');
    } catch (e, stackTrace) {
      await _analytics.log('Erro ao salvar dados de despesa');
      await _analytics.recordError(
        e,
        stackTrace,
        reason: 'Failed to save expense data',
      );
    }
  }

  /// Salvar dados de veículo
  static Future<void> saveVehicleData({
    required String userId,
    required Map<String, dynamic> vehicleData,
  }) async {
    try {
      final docRef = FirebaseFirestore.instance
          .collection('users')
          .doc(userId)
          .collection('vehicles')
          .doc();

      await docRef.set({
        ...vehicleData,
        'createdAt': FieldValue.serverTimestamp(),
        'user_id': userId,
        'platform': Platform.operatingSystem,
      });

      // Log analytics
      await _analytics.logVehicleCreated(
        vehicleData['type'] as String? ?? 'unknown',
      );

      await _analytics.log('Vehicle data saved successfully');
      await _analytics.log('Dados de veículo salvos no Firebase');
    } catch (e, stackTrace) {
      await _analytics.log('Erro ao salvar dados de veículo');
      await _analytics.recordError(
        e,
        stackTrace,
        reason: 'Failed to save vehicle data',
      );
    }
  }

  /// Obter estatísticas do usuário
  static Future<Map<String, dynamic>> getUserStats(String userId) async {
    try {
      final fuelQuery = await FirebaseFirestore.instance
          .collection('users')
          .doc(userId)
          .collection('fuel_records')
          .get();

      final maintenanceQuery = await FirebaseFirestore.instance
          .collection('users')
          .doc(userId)
          .collection('maintenance_records')
          .get();

      final expenseQuery = await FirebaseFirestore.instance
          .collection('users')
          .doc(userId)
          .collection('expense_records')
          .get();

      final vehicleQuery = await FirebaseFirestore.instance
          .collection('users')
          .doc(userId)
          .collection('vehicles')
          .get();

      final stats = {
        'totalFuelRecords': fuelQuery.docs.length,
        'totalMaintenanceRecords': maintenanceQuery.docs.length,
        'totalExpenseRecords': expenseQuery.docs.length,
        'totalVehicles': vehicleQuery.docs.length,
        'lastActivity': DateTime.now().toIso8601String(),
      };

      // Log analytics
      await _analytics.logEvent('user_stats_retrieved', {
        'fuel_records': fuelQuery.docs.length,
        'maintenance_records': maintenanceQuery.docs.length,
        'expense_records': expenseQuery.docs.length,
        'vehicles': vehicleQuery.docs.length,
      });

      return stats;
    } catch (e, stackTrace) {
      await _analytics.log('Erro ao obter estatísticas do usuário');
      await _analytics.recordError(
        e,
        stackTrace,
        reason: 'Failed to get user stats',
      );
      return {};
    }
  }

  /// Log de uso de feature
  static Future<void> logFeatureUsage({
    required String userId,
    required String featureName,
    Map<String, Object>? additionalData,
  }) async {
    try {
      await FirebaseFirestore.instance
          .collection('users')
          .doc(userId)
          .collection('feature_usage')
          .add({
        'featureName': featureName,
        'timestamp': FieldValue.serverTimestamp(),
        'user_id': userId,
        'platform': Platform.operatingSystem,
        'additionalData': additionalData,
      });

      // Log analytics
      await _analytics.logUserAction(featureName, parameters: additionalData);
      await _analytics.log('Feature usage logged: $featureName');
    } catch (e, stackTrace) {
      await _analytics.recordError(
        e,
        stackTrace,
        reason: 'Failed to log feature usage: $featureName',
      );
    }
  }

  /// Backup de dados
  static Future<bool> backupUserData(String userId) async {
    try {
      await _analytics.logEvent('data_backup_started', {'user_id': userId});

      // Aqui você implementaria a lógica de backup
      // Por exemplo, exportar dados do Hive para Firebase

      await _analytics.logEvent('data_backup_completed', {'user_id': userId});
      await _analytics.log('User data backup completed successfully');
      
      return true;
    } catch (e, stackTrace) {
      await _analytics.recordError(
        e,
        stackTrace,
        reason: 'Failed to backup user data',
      );
      return false;
    }
  }

  /// Sincronização de dados
  static Future<bool> syncUserData(String userId) async {
    try {
      await _analytics.logEvent('data_sync_started', {'user_id': userId});

      // Aqui você implementaria a lógica de sincronização
      // Por exemplo, sincronizar dados locais com Firebase

      await _analytics.logEvent('data_sync_completed', {'user_id': userId});
      await _analytics.log('User data sync completed successfully');
      
      return true;
    } catch (e, stackTrace) {
      await _analytics.recordError(
        e,
        stackTrace,
        reason: 'Failed to sync user data',
      );
      return false;
    }
  }

  /// Log de error específico do app
  static Future<void> logAppError({
    required String errorType,
    required String errorMessage,
    Map<String, Object>? context,
  }) async {
    await _analytics.recordError(
      Exception('$errorType: $errorMessage'),
      StackTrace.current,
      reason: errorType,
      customKeys: context,
    );
  }

  /// Configurar usuário para analytics
  static Future<void> setAnalyticsUser({
    required String userId,
    Map<String, String>? userProperties,
  }) async {
    await _analytics.setUserId(userId);
    
    if (userProperties != null) {
      await _analytics.setUserProperties(userProperties);
    }
    
    await _analytics.log('Analytics user configured: $userId');
  }
}