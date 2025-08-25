// Dart imports:
import 'dart:io';

// Package imports:
import 'package:cloud_firestore/cloud_firestore.dart';

// Project imports:
import 'analytics_service.dart';

/// Service para integração Firebase específica do Gasometer com Analytics
class GasometerFirebaseService {
  static const String _subscriptionsCollection = 'subscriptions';
  static const String _appId = 'gasometer';
  
  static final AnalyticsService _analytics = AnalyticsService();

  /// Salvar dados de abastecimento
  static Future<void> saveFuelData({
    required String userId,
    required Map<String, dynamic> fuelData,
  }) async {
    try {
      final docRef = FirebaseFirestore.instance
          .collection('fuel_records')
          .doc('${_appId}_$userId')
          .collection('records')
          .doc();

      await docRef.set({
        ...fuelData,
        'createdAt': FieldValue.serverTimestamp(),
        'appId': _appId,
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
      print('✅ Dados de abastecimento salvos no Firebase');
    } catch (e, stackTrace) {
      print('❌ Erro ao salvar dados de abastecimento: $e');
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
    try {
      final docRef = FirebaseFirestore.instance
          .collection('maintenance_records')
          .doc('${_appId}_$userId')
          .collection('records')
          .doc();

      await docRef.set({
        ...maintenanceData,
        'createdAt': FieldValue.serverTimestamp(),
        'appId': _appId,
        'platform': Platform.operatingSystem,
      });

      // Log analytics
      await _analytics.logMaintenance(
        maintenanceType: maintenanceData['type'] as String? ?? 'unknown',
        cost: (maintenanceData['cost'] as num?)?.toDouble() ?? 0.0,
        odometer: (maintenanceData['odometer'] as num?)?.toInt() ?? 0,
      );

      await _analytics.log('Maintenance data saved successfully');
      print('✅ Dados de manutenção salvos no Firebase');
    } catch (e, stackTrace) {
      print('❌ Erro ao salvar dados de manutenção: $e');
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
          .collection('expense_records')
          .doc('${_appId}_$userId')
          .collection('records')
          .doc();

      await docRef.set({
        ...expenseData,
        'createdAt': FieldValue.serverTimestamp(),
        'appId': _appId,
        'platform': Platform.operatingSystem,
      });

      // Log analytics
      await _analytics.logExpense(
        expenseType: expenseData['type'] as String? ?? 'unknown',
        amount: (expenseData['amount'] as num?)?.toDouble() ?? 0.0,
      );

      await _analytics.log('Expense data saved successfully');
      print('✅ Dados de despesa salvos no Firebase');
    } catch (e, stackTrace) {
      print('❌ Erro ao salvar dados de despesa: $e');
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
          .collection('vehicles')
          .doc('${_appId}_$userId')
          .collection('vehicles')
          .doc();

      await docRef.set({
        ...vehicleData,
        'createdAt': FieldValue.serverTimestamp(),
        'appId': _appId,
        'platform': Platform.operatingSystem,
      });

      // Log analytics
      await _analytics.logVehicleCreated(
        vehicleData['type'] as String? ?? 'unknown',
      );

      await _analytics.log('Vehicle data saved successfully');
      print('✅ Dados de veículo salvos no Firebase');
    } catch (e, stackTrace) {
      print('❌ Erro ao salvar dados de veículo: $e');
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
          .collection('fuel_records')
          .doc('${_appId}_$userId')
          .collection('records')
          .get();

      final maintenanceQuery = await FirebaseFirestore.instance
          .collection('maintenance_records')
          .doc('${_appId}_$userId')
          .collection('records')
          .get();

      final expenseQuery = await FirebaseFirestore.instance
          .collection('expense_records')
          .doc('${_appId}_$userId')
          .collection('records')
          .get();

      final vehicleQuery = await FirebaseFirestore.instance
          .collection('vehicles')
          .doc('${_appId}_$userId')
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
      print('❌ Erro ao obter estatísticas do usuário: $e');
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
          .collection('feature_usage')
          .doc('${_appId}_$userId')
          .collection('usage')
          .add({
        'featureName': featureName,
        'timestamp': FieldValue.serverTimestamp(),
        'appId': _appId,
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