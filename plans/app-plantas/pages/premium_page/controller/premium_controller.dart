// Flutter imports:
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

// Package imports:
import 'package:get/get.dart';

// Project imports:
import '../../../../core/services/subscription_config_service.dart';
import '../../../core/extensions/theme_extensions.dart';

class PremiumController extends GetxController {
  // Estados reativos
  final RxBool isLoading = false.obs;
  final RxBool isProcessingPurchase = false.obs;
  final RxString selectedPlan = ''.obs;
  final RxBool isConfigurationValid = false.obs;

  // Dados da configuração
  final RxList<Map<String, dynamic>> products = <Map<String, dynamic>>[].obs;
  final RxList<Map<String, dynamic>> advantages = <Map<String, dynamic>>[].obs;
  final RxList<String> configurationErrors = <String>[].obs;

  @override
  void onInit() {
    super.onInit();
    _initializePremiumConfig();
  }

  void _initializePremiumConfig() {
    try {
      isLoading.value = true;

      // Inicializar configuração para o app plantas
      SubscriptionConfigService.initializeForApp('plantas');

      // Carregar dados da configuração centralizada
      products.value = SubscriptionConfigService.getCurrentProducts();
      advantages.value = SubscriptionConfigService.getCurrentAdvantages();

      // Verificar se a configuração é válida
      isConfigurationValid.value =
          SubscriptionConfigService.isCurrentConfigValid();

      if (!isConfigurationValid.value) {
        configurationErrors.value =
            SubscriptionConfigService.getCurrentConfigErrors();
      }

      // Selecionar plano anual por padrão (melhor valor)
      if (products.isNotEmpty) {
        final annualPlan = products.firstWhere(
          (product) => product['productId'].toString().contains('anual'),
          orElse: () => products.first,
        );
        selectedPlan.value = annualPlan['productId'];
      }
    } catch (e) {
      debugPrint('Erro ao inicializar configuração premium: $e');
      final context = Get.context;
      if (context != null) {
        PlantasGetSnackbar.error(
            context, 'Erro', 'Erro ao carregar configuração: $e');
      }
    } finally {
      isLoading.value = false;
    }
  }

  // Selecionar plano
  void selectPlan(String productId) {
    selectedPlan.value = productId;
  }

  // Processar compra
  Future<void> purchasePlan(String productId) async {
    if (!hasValidApiKeys) {
      final context = Get.context;
      if (context != null) {
        PlantasGetSnackbar.error(
            context, 'Erro', 'API keys do RevenueCat não configuradas');
      }
      return;
    }

    try {
      isProcessingPurchase.value = true;

      // Aqui você integraria com o RevenueCat
      // final success = await RevenueCatService.purchaseProduct(productId);

      // Simulação da compra por enquanto
      await Future.delayed(const Duration(seconds: 2));

      final product = products.firstWhere(
        (p) => p['productId'] == productId,
        orElse: () => {'desc': 'Produto'},
      );

      final context = Get.context;
      if (context != null) {
        PlantasGetSnackbar.success(context, 'Sucesso',
            'Assinatura ativada com sucesso!\nProduto: ${product['desc']}');
      }

      // Atualizar estado do usuário premium
      // Isso seria integrado com o sistema de autenticação
    } catch (e) {
      debugPrint('Erro na compra: $e');
      final context = Get.context;
      if (context != null) {
        PlantasGetSnackbar.error(
            context, 'Erro', 'Erro ao processar assinatura: $e');
      }
    } finally {
      isProcessingPurchase.value = false;
    }
  }

  // Restaurar compras
  Future<void> restorePurchases() async {
    if (!hasValidApiKeys) {
      final context = Get.context;
      if (context != null) {
        PlantasGetSnackbar.error(
            context, 'Erro', 'API keys do RevenueCat não configuradas');
      }
      return;
    }

    try {
      isLoading.value = true;

      // Aqui você integraria com o RevenueCat
      // final restored = await RevenueCatService.restorePurchases();

      // Simulação da restauração por enquanto
      await Future.delayed(const Duration(seconds: 1));

      final context = Get.context;
      if (context != null) {
        PlantasGetSnackbar.success(
            context, 'Sucesso', 'Compras restauradas com sucesso!');
      }
    } catch (e) {
      debugPrint('Erro ao restaurar compras: $e');
      final context = Get.context;
      if (context != null) {
        PlantasGetSnackbar.error(
            context, 'Erro', 'Nenhuma compra encontrada para restaurar: $e');
      }
    } finally {
      isLoading.value = false;
    }
  }

  // Getters úteis
  bool get hasValidApiKeys => SubscriptionConfigService.hasValidApiKeys();

  String get appName => SubscriptionConfigService.getCurrentAppName();

  Map<String, dynamic>? get selectedProduct => products.firstWhereOrNull(
        (product) => product['productId'] == selectedPlan.value,
      );

  String get selectedProductPrice {
    final product = selectedProduct;
    if (product == null) return '';

    // Aqui você calcularia o preço baseado no productId
    // Por enquanto, valores fixos
    if (product['productId'].toString().contains('anual')) {
      return 'R\$ 79,99/ano';
    } else {
      return 'R\$ 9,99/mês';
    }
  }

  bool get isAnnualPlan =>
      selectedProduct?['productId']?.toString().contains('anual') ?? false;

  String get economyText => isAnnualPlan ? 'Economize 33%' : '';

  // Navegação
  void goBack() {
    Get.back();
  }

  void openTermsAndPrivacy() {
    // Implementar navegação para termos e política
    final context = Get.context;
    if (context != null) {
      PlantasGetSnackbar.info(context, 'Informação',
          'Redirecionando para Termos e Política de Privacidade');
    }
  }

  // Métodos auxiliares para mostrar mensagens (DEPRECATED - use PlantasGetSnackbar)
  /// @deprecated Use PlantasGetSnackbar.success(context, title, message) em vez disso
  void _showSuccess(String message) {
    final context = Get.context;
    if (context != null) {
      PlantasGetSnackbar.success(context, 'Sucesso', message);
    }
  }

  /// @deprecated Use PlantasGetSnackbar.error(context, title, message) em vez disso
  void _showError(String message) {
    final context = Get.context;
    if (context != null) {
      PlantasGetSnackbar.error(context, 'Erro', message);
    }
  }

  /// @deprecated Use PlantasGetSnackbar.info(context, title, message) em vez disso
  void _showInfo(String message) {
    final context = Get.context;
    if (context != null) {
      PlantasGetSnackbar.info(context, 'Informação', message);
    }
  }

  // Debug - obter informações de configuração
  Map<String, dynamic> get debugInfo {
    return {
      'isConfigurationValid': isConfigurationValid.value,
      'hasValidApiKeys': hasValidApiKeys,
      'productsCount': products.length,
      'advantagesCount': advantages.length,
      'selectedPlan': selectedPlan.value,
      'configurationErrors': configurationErrors,
      'appName': appName,
    };
  }
}
