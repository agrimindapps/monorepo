import 'package:core/core.dart';
import 'package:flutter/foundation.dart';
import '../models/premium_status_hive.dart';

/// Repository para gerenciar dados premium com cache local Hive
class PremiumHiveRepository extends BaseHiveRepository<PremiumStatusHive> {
  static const String _boxName = 'receituagro_premium_status';

  PremiumHiveRepository() : super(
    hiveManager: GetIt.instance<IHiveManager>(),
    boxName: _boxName,
  );


  /// Obtém ID do usuário atual
  String _getCurrentUserId() {
    final user = FirebaseAuth.instance.currentUser;
    return user?.uid ?? 'anonymous';
  }

  /// Obtém status premium do usuário atual
  Future<PremiumStatusHive?> getCurrentUserPremiumStatus() async {
    try {
      final userId = _getCurrentUserId();
      final result = await getByKey(userId);
      
      if (result.isSuccess && result.data != null) {
        return result.data;
      } else {
        return _createDefaultStatus(userId);
      }
    } catch (e) {
      debugPrint('Error getting current user premium status: $e');
      return _createDefaultStatus(_getCurrentUserId());
    }
  }

  /// Salva status premium para o usuário atual
  Future<void> saveCurrentUserPremiumStatus(PremiumStatusHive status) async {
    try {
      final userId = _getCurrentUserId();
      status.userId = userId;
      status.updatedAt = DateTime.now().millisecondsSinceEpoch;

      final result = await save(status, key: userId);
      if (result.isError) {
        throw Exception('Falha ao salvar status premium: ${result.error}');
      }

      debugPrint('Premium status saved for user: $userId');
    } catch (e) {
      debugPrint('Error saving premium status: $e');
      throw Exception('Falha ao salvar status premium: $e');
    }
  }

  /// Verifica se usuário atual tem premium válido
  Future<bool> isCurrentUserPremium() async {
    final status = await getCurrentUserPremiumStatus();
    return status?.isValidPremium ?? false;
  }

  /// Verifica se precisa sincronizar online
  Future<bool> shouldSyncOnline() async {
    final status = await getCurrentUserPremiumStatus();
    return status?.shouldSyncOnline ?? true;
  }

  /// Marca status como sincronizado
  Future<void> markCurrentUserAsSynced() async {
    final status = await getCurrentUserPremiumStatus();
    if (status != null) {
      status.markAsSynced();
      await saveCurrentUserPremiumStatus(status);
    }
  }

  /// Marca como necessitando sincronização
  Future<void> markCurrentUserNeedsSync() async {
    final status = await getCurrentUserPremiumStatus();
    if (status != null) {
      status.markNeedsSync();
      await saveCurrentUserPremiumStatus(status);
    }
  }

  /// Ativa premium para usuário atual (para testes)
  Future<void> activateTestPremium({
    String planType = 'test',
    Duration duration = const Duration(days: 30),
  }) async {
    final userId = _getCurrentUserId();
    final expiryDate = DateTime.now().add(duration);

    final testStatus = PremiumStatusHive(
      userId: userId,
      isActive: true,
      isTestSubscription: true,
      planType: planType,
      expiryDateTimestamp: expiryDate.millisecondsSinceEpoch,
      createdAt: DateTime.now().millisecondsSinceEpoch,
      updatedAt: DateTime.now().millisecondsSinceEpoch,
      needsOnlineSync: false,
    );

    await saveCurrentUserPremiumStatus(testStatus);
    debugPrint('Test premium activated for user: $userId until $expiryDate');
  }

  /// Remove premium de teste
  Future<void> removeTestPremium() async {
    final userId = _getCurrentUserId();
    await deleteByKey(userId);
    debugPrint('Test premium removed for user: $userId');
  }

  /// Limpa cache premium (força nova sincronização)
  Future<void> clearPremiumCache() async {
    await markCurrentUserNeedsSync();
    debugPrint('Premium cache cleared - will sync online');
  }

  /// Obtém informações detalhadas do status premium
  Future<Map<String, dynamic>> getCurrentUserPremiumInfo() async {
    final status = await getCurrentUserPremiumStatus();

    return {
      'isPremium': status?.isValidPremium ?? false,
      'isActive': status?.isActive ?? false,
      'isTestSubscription': status?.isTestSubscription ?? false,
      'planType': status?.planType,
      'expiryDate': status?.expiryDate?.toIso8601String(),
      'subscriptionId': status?.subscriptionId,
      'productId': status?.productId,
      'lastSync': status?.lastSync?.toIso8601String(),
      'needsSync': status?.shouldSyncOnline ?? true,
    };
  }

  /// Cria status padrão para novo usuário
  PremiumStatusHive _createDefaultStatus(String userId) {
    return PremiumStatusHive(
      userId: userId,
      isActive: false,
      isTestSubscription: false,
      createdAt: DateTime.now().millisecondsSinceEpoch,
      updatedAt: DateTime.now().millisecondsSinceEpoch,
      needsOnlineSync: true,
    );
  }

  /// Limpa dados de todos os usuários (apenas para desenvolvimento)
  Future<void> clearAllPremiumData() async {
    try {
      await clear();
      debugPrint('All premium data cleared');
    } catch (e) {
      debugPrint('Error clearing premium data: $e');
    }
  }

  /// Obtém estatísticas do cache premium
  Future<Map<String, dynamic>> getCacheStats() async {
    try {
      final result = await getAll();
      if (result.isError) {
        return {'error': result.error.toString()};
      }
      
      final allStatuses = result.data!;

      return {
        'totalUsers': allStatuses.length,
        'premiumUsers': allStatuses.where((s) => s.isValidPremium).length,
        'testSubscriptions':
            allStatuses.where((s) => s.isTestSubscription).length,
        'needingSync': allStatuses.where((s) => s.shouldSyncOnline).length,
        'currentUserId': _getCurrentUserId(),
        'currentUserStatus': await getCurrentUserPremiumInfo(),
      };
    } catch (e) {
      debugPrint('Error getting cache stats: $e');
      return {'error': e.toString()};
    }
  }
}
