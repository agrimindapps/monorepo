// Flutter imports:
import 'package:flutter/foundation.dart';

// Package imports:
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ConfigService extends GetxService {
  static ConfigService get to => Get.find<ConfigService>();

  final RxBool _isPromoMode = false.obs;
  bool get isPromoMode => _isPromoMode.value;

  // Chave para armazenar a configuração nas preferências
  final String _promoModeKey = 'promo_mode_enabled';

  Future<ConfigService> init() async {
    await _loadConfig();
    return this;
  }

  // Carrega a configuração das preferências
  Future<void> _loadConfig() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      _isPromoMode.value = prefs.getBool(_promoModeKey) ?? false;

      // Para fins de teste em ambiente de desenvolvimento web
      if (kIsWeb && kDebugMode) {
        debugPrint('ConfigService: Modo promocional: ${_isPromoMode.value}');
      }
    } catch (e) {
      debugPrint('ConfigService: Erro ao carregar configurações: $e');
    }
  }

  // Atualiza o modo promocional
  Future<void> setPromoMode(bool value) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool(_promoModeKey, value);
      _isPromoMode.value = value;
      debugPrint('ConfigService: Modo promocional atualizado para: $value');
    } catch (e) {
      debugPrint('ConfigService: Erro ao salvar modo promocional: $e');
    }
  }

  // Alterna o modo promocional
  Future<void> togglePromoMode() async {
    await setPromoMode(!_isPromoMode.value);
  }
}
