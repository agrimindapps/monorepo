// Package imports:
import 'package:shared_preferences/shared_preferences.dart';

// Project imports:
import '../../core/services/info_device_service.dart';

/// Service para gerenciar test subscriptions no ambiente de desenvolvimento
class GasometerTestService {
  static const String _testSubscriptionKey = 'gasometer_test_subscription';
  static const String _testActivationTimeKey = 'gasometer_test_activation_time';
  static const Duration _testDuration = Duration(hours: 24);

  /// Ativar test subscription (apenas em desenvolvimento)
  static Future<bool> activateTestSubscription() async {
    try {
      final isDev = await InfoDeviceService.isDevelopmentVersion();
      if (!isDev) {
        print('⚠️ Test subscription só pode ser ativada em desenvolvimento');
        return false;
      }

      final prefs = await SharedPreferences.getInstance();
      final activationTime = DateTime.now().millisecondsSinceEpoch;

      await prefs.setBool(_testSubscriptionKey, true);
      await prefs.setInt(_testActivationTimeKey, activationTime);

      print('✅ Test subscription ativada por 24 horas');
      print('🕐 Expira em: ${DateTime.fromMillisecondsSinceEpoch(activationTime + _testDuration.inMilliseconds)}');
      
      return true;
    } catch (e) {
      print('❌ Erro ao ativar test subscription: $e');
      return false;
    }
  }

  /// Verificar se há test subscription ativa
  static Future<bool> hasActiveTestSubscription() async {
    try {
      final isDev = await InfoDeviceService.isDevelopmentVersion();
      if (!isDev) return false;

      final prefs = await SharedPreferences.getInstance();
      final isActive = prefs.getBool(_testSubscriptionKey) ?? false;
      
      if (!isActive) return false;

      final activationTime = prefs.getInt(_testActivationTimeKey);
      if (activationTime == null) return false;

      final now = DateTime.now().millisecondsSinceEpoch;
      final elapsed = now - activationTime;
      final isStillValid = elapsed < _testDuration.inMilliseconds;

      if (!isStillValid) {
        // Test subscription expirou, limpar
        await removeTestSubscription();
        return false;
      }

      return true;
    } catch (e) {
      print('❌ Erro ao verificar test subscription: $e');
      return false;
    }
  }

  /// Remover test subscription
  static Future<void> removeTestSubscription() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(_testSubscriptionKey);
      await prefs.remove(_testActivationTimeKey);
      
      print('❌ Test subscription removida');
    } catch (e) {
      print('❌ Erro ao remover test subscription: $e');
    }
  }

  /// Obter tempo restante da test subscription
  static Future<Duration?> getTestSubscriptionTimeLeft() async {
    try {
      final isDev = await InfoDeviceService.isDevelopmentVersion();
      if (!isDev) return null;

      final prefs = await SharedPreferences.getInstance();
      final activationTime = prefs.getInt(_testActivationTimeKey);
      
      if (activationTime == null) return null;

      final now = DateTime.now().millisecondsSinceEpoch;
      final elapsed = now - activationTime;
      final remaining = _testDuration.inMilliseconds - elapsed;

      return remaining > 0 ? Duration(milliseconds: remaining) : null;
    } catch (e) {
      print('❌ Erro ao obter tempo restante: $e');
      return null;
    }
  }

  /// Obter informações detalhadas da test subscription
  static Future<Map<String, dynamic>> getTestSubscriptionInfo() async {
    try {
      final isDev = await InfoDeviceService.isDevelopmentVersion();
      if (!isDev) {
        return {
          'isDevelopment': false,
          'message': 'Test subscription disponível apenas em desenvolvimento'
        };
      }

      final isActive = await hasActiveTestSubscription();
      final timeLeft = await getTestSubscriptionTimeLeft();
      
      if (!isActive) {
        return {
          'isDevelopment': true,
          'isActive': false,
          'message': 'Nenhuma test subscription ativa'
        };
      }

      final hours = timeLeft?.inHours ?? 0;
      final minutes = (timeLeft?.inMinutes ?? 0) % 60;

      return {
        'isDevelopment': true,
        'isActive': true,
        'timeLeft': timeLeft,
        'timeLeftFormatted': '${hours}h ${minutes}m',
        'message': 'Test subscription ativa por mais ${hours}h ${minutes}m'
      };
    } catch (e) {
      return {
        'isDevelopment': false,
        'isActive': false,
        'error': e.toString()
      };
    }
  }

  /// Verificar se o ambiente permite test subscriptions
  static Future<bool> isTestEnvironmentAvailable() async {
    return await InfoDeviceService.isDevelopmentVersion();
  }

  /// Renovar test subscription (resetar o timer)
  static Future<bool> renewTestSubscription() async {
    final isDev = await InfoDeviceService.isDevelopmentVersion();
    if (!isDev) return false;

    // Remove a atual e cria uma nova
    await removeTestSubscription();
    return await activateTestSubscription();
  }
}
