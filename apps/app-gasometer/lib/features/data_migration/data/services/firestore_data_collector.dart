import 'package:core/core.dart';
import 'package:flutter/foundation.dart';

/// Coletor de dados do Firestore
///
/// Responsabilidade: Coletar dados específicos do Firestore
/// Aplica SRP (Single Responsibility Principle)

class FirestoreDataCollector {
  FirestoreDataCollector(this._firestore);

  final FirebaseFirestore _firestore;

  /// Obtém documento do Firestore
  Future<DocumentSnapshot<Map<String, dynamic>>?> getUserDocument(
    String userId,
  ) async {
    try {
      final doc = await _firestore.collection('users').doc(userId).get();
      return doc.exists ? doc : null;
    } catch (e) {
      if (kDebugMode) {
        debugPrint('❌ Error getting user document: $e');
      }
      return null;
    }
  }

  /// Conta registros em uma coleção para um usuário
  Future<int> getRecordCount(String collection, String userId) async {
    try {
      final query = await _firestore
          .collection(collection)
          .where('user_id', isEqualTo: userId)
          .count()
          .get();
      return query.count ?? 0;
    } catch (e) {
      if (kDebugMode) {
        debugPrint('❌ Error counting records in $collection: $e');
      }
      return 0;
    }
  }

  /// Obtém totais de abastecimento
  Future<Map<String, double>> getFuelTotals(String userId) async {
    try {
      final query = await _firestore
          .collection('fuel_supplies')
          .where('user_id', isEqualTo: userId)
          .get();

      double totalCost = 0.0;
      double maxOdometer = 0.0;

      for (final doc in query.docs) {
        final data = doc.data();
        totalCost += (data['total_price'] as num?)?.toDouble() ?? 0.0;
        final odometer = (data['odometer'] as num?)?.toDouble() ?? 0.0;
        if (odometer > maxOdometer) maxOdometer = odometer;
      }

      return {'totalCost': totalCost, 'totalDistance': maxOdometer};
    } catch (e) {
      if (kDebugMode) {
        debugPrint('❌ Error getting fuel totals: $e');
      }
      return {'totalCost': 0.0, 'totalDistance': 0.0};
    }
  }

  /// Limpa dados remotos de um usuário
  Future<Map<String, int>> cleanRemoteUserData(String userId) async {
    try {
      int deletedVehicles = 0;
      int deletedFuelRecords = 0;

      // Deleta veículos
      final vehiclesQuery = await _firestore
          .collection('vehicles')
          .where('user_id', isEqualTo: userId)
          .get();

      for (final doc in vehiclesQuery.docs) {
        await doc.reference.delete();
        deletedVehicles++;
      }

      // Deleta abastecimentos
      final fuelQuery = await _firestore
          .collection('fuel_supplies')
          .where('user_id', isEqualTo: userId)
          .get();

      for (final doc in fuelQuery.docs) {
        await doc.reference.delete();
        deletedFuelRecords++;
      }

      if (kDebugMode) {
        debugPrint(
          '✅ Remote cleanup: $deletedVehicles vehicles, $deletedFuelRecords fuel records',
        );
      }

      return {'vehicles': deletedVehicles, 'fuel_records': deletedFuelRecords};
    } catch (e) {
      if (kDebugMode) {
        debugPrint('❌ Error cleaning remote data: $e');
      }
      throw Exception('Erro ao limpar dados remotos: $e');
    }
  }

  /// Verifica conectividade testando acesso ao Firestore
  Future<bool> checkConnectivity() async {
    try {
      await _firestore.collection('_connection_test').limit(1).get();
      return true;
    } catch (e) {
      return false;
    }
  }
}
