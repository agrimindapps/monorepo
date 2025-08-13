// Package imports:
import 'package:get/get.dart';

// Project imports:
import '../../core/services/info_device_service.dart';
import 'secure_storage_service.dart';

/// Serviço Premium refatorado com armazenamento seguro
class PremiumService extends GetxService {
  final _isPremium = false.obs;
  final _isLoading = false.obs;
  
  // Instância do SecureStorageService
  late final SecureStorageService _secureStorage;
  
  // Chaves para dados sensíveis
  static const String _testSubscriptionKey = 'dev_test_subscription';
  static const String _testSubscriptionTimestampKey = 'dev_test_subscription_timestamp';

  bool get isLoading => _isLoading.value;
  bool get isPremium => _isPremium.value;
  
  @override
  Future<void> onInit() async {
    super.onInit();
    _secureStorage = SecureStorageService.instance;
    await _secureStorage.onInit();
  }

  Future<PremiumService> init() async {
    await verificarStatusPremium();
    return this;
  }

  Future<bool> verificarStatusPremium() async {
    if (_isLoading.value) return _isPremium.value;

    _isLoading.value = true;
    try {
      await Future.delayed(const Duration(milliseconds: 500));

      // Verificar se existe assinatura de teste para desenvolvimento
      final testSubscription = await _hasTestSubscription();
      if (testSubscription) {
        _isPremium.value = true;
        return _isPremium.value;
      }

      // Em versões de desenvolvimento (.0 ou .00), sem test subscription = não premium
      // Em produção, manter como true por enquanto
      final isDevelopment = await InfoDeviceService.isDevelopmentVersion();
      if (isDevelopment) {
        _isPremium.value = false; // Permite testar comportamento não-premium
      } else {
        _isPremium.value = true; // Produção mantém premium
      }

      return _isPremium.value;
    } catch (e) {
      print('Erro ao verificar status premium: $e');
      _isPremium.value = false;
      return false;
    } finally {
      _isLoading.value = false;
    }
  }

  /// Verifica se existe uma assinatura de teste ativa de forma segura
  Future<bool> _hasTestSubscription() async {
    try {
      final testData = await _secureStorage.getSecureValue(_testSubscriptionKey);
      
      if (testData != null && testData == 'active') {
        // Verificar se a assinatura de teste ainda é válida (ex: 30 dias)
        final timestampStr = await _secureStorage.getSecureValue(_testSubscriptionTimestampKey);
        
        if (timestampStr != null) {
          final timestamp = int.tryParse(timestampStr) ?? 0;
          final now = DateTime.now().millisecondsSinceEpoch;
          const thirtyDaysInMs = 30 * 24 * 60 * 60 * 1000;
          
          final isValid = (now - timestamp) < thirtyDaysInMs;
          
          if (!isValid) {
            // Remove assinatura expirada automaticamente
            await _cleanupExpiredTestSubscription();
          }
          
          return isValid;
        }
      }
      
      return false;
    } catch (e) {
      print('Erro ao verificar assinatura de teste: $e');
      return false;
    }
  }

  /// Gera uma assinatura de teste local de forma segura
  Future<void> generateTestSubscription() async {
    try {
      final timestamp = DateTime.now().millisecondsSinceEpoch;
      
      // Armazena dados de assinatura de forma segura
      final subscriptionSuccess = await _secureStorage.setSecureValue(
        _testSubscriptionKey, 
        'active',
      );
      
      final timestampSuccess = await _secureStorage.setSecureValue(
        _testSubscriptionTimestampKey, 
        timestamp.toString(),
      );
      
      if (subscriptionSuccess && timestampSuccess) {
        print('✅ Assinatura de teste criada com armazenamento seguro');
        // Atualizar status imediatamente
        await atualizarStatusPremium();
      } else {
        throw Exception('Falha ao armazenar dados de assinatura de forma segura');
      }
    } catch (e) {
      print('❌ Erro ao gerar assinatura de teste: $e');
    }
  }

  /// Remove a assinatura de teste local de forma segura
  Future<void> removeTestSubscription() async {
    try {
      final subscriptionRemoved = await _secureStorage.removeSecureValue(_testSubscriptionKey);
      final timestampRemoved = await _secureStorage.removeSecureValue(_testSubscriptionTimestampKey);
      
      if (subscriptionRemoved && timestampRemoved) {
        print('✅ Assinatura de teste removida do armazenamento seguro');
        // Atualizar status imediatamente
        await atualizarStatusPremium();
      } else {
        print('⚠️ Alguns dados podem não ter sido removidos completamente');
      }
    } catch (e) {
      print('❌ Erro ao remover assinatura de teste: $e');
    }
  }

  Future<void> atualizarStatusPremium() async {
    await verificarStatusPremium();
  }
  
  /// Limpa assinatura de teste expirada automaticamente
  Future<void> _cleanupExpiredTestSubscription() async {
    try {
      await _secureStorage.removeSecureValue(_testSubscriptionKey);
      await _secureStorage.removeSecureValue(_testSubscriptionTimestampKey);
      print('🧹 Assinatura de teste expirada removida automaticamente');
    } catch (e) {
      print('⚠️ Erro ao limpar assinatura expirada: $e');
    }
  }
  
  /// Obtém informações sobre o armazenamento seguro (para debug)
  Map<String, dynamic> getSecureStorageInfo() {
    return _secureStorage.getStats();
  }
  
  /// Verifica se dados sensíveis existem
  Future<bool> hasSensitiveData() async {
    try {
      return await _secureStorage.containsKey(_testSubscriptionKey);
    } catch (e) {
      return false;
    }
  }
  
  /// Limpa todos os dados sensíveis
  Future<void> clearAllSensitiveData() async {
    try {
      await _secureStorage.removeSecureValue(_testSubscriptionKey);
      await _secureStorage.removeSecureValue(_testSubscriptionTimestampKey);
      print('🧹 Todos os dados sensíveis removidos');
      await atualizarStatusPremium();
    } catch (e) {
      print('❌ Erro ao limpar dados sensíveis: $e');
    }
  }
}
