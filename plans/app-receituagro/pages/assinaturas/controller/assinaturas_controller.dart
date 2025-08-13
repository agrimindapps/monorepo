import 'dart:async';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:purchases_flutter/purchases_flutter.dart';

import '../../../../core/services/in_app_purchase_service.dart';
import '../../../../core/services/revenuecat_service.dart';
import '../../../services/premium_service.dart';
import '../models/assinatura_state.dart';

/// Controller específico para assinaturas do app-receituagro
/// Mantém o uso dos services do core mas adiciona funcionalidades específicas
class AssinaturasController extends GetxController {
  // Services do core
  final InAppPurchaseService _inAppPurchaseService =
      Get.find<InAppPurchaseService>();
  final RevenuecatService _revenuecatService = RevenuecatService.instance;
  final PremiumService _premiumService = Get.find<PremiumService>();

  // Estado reativo específico do receituagro
  final Rx<AssinaturaState> _state = AssinaturaState.initial().obs;
  AssinaturaState get state => _state.value;

  // Controle de timers
  Timer? _pointsTimer;
  Timer? _loadingTimer;
  Timer? _timeoutTimer;

  // Propriedades observáveis
  final RxBool isLoading = false.obs;
  final RxBool isInteractingWithStore = false.obs;
  final RxString pointsAnimation = '...'.obs;
  final RxInt timeoutCountdown = 15.obs;
  final Rx<Offering?> currentOffering = Rx<Offering?>(null);

  // Propriedades específicas do receituagro
  final RxString welcomeMessage = 'Bem-vindo ao ReceitaAgro Premium!'.obs;
  final RxList<String> receituagroFeatures = <String>[
    '🌾 Acesso ilimitado a defensivos agrícolas',
    '🐛 Diagnóstico completo de pragas',
    '📊 Relatórios detalhados de culturas',
    '💬 Comentários ilimitados',
    '⭐ Suporte prioritário',
    '📱 Sincronização entre dispositivos',
    '🔔 Notificações personalizadas',
    '📈 Análises avançadas de produtividade'
  ].obs;

  @override
  void onInit() {
    super.onInit();
    _initializeAssinaturas();
  }

  @override
  void onClose() {
    _pointsTimer?.cancel();
    _loadingTimer?.cancel();
    _timeoutTimer?.cancel();
    super.onClose();
  }

  /// Inicializa os dados de assinatura
  Future<void> _initializeAssinaturas() async {
    _startPointsAnimation();

    // Atualizar status premium primeiro (incluindo simulação)
    await _premiumService.atualizarStatusPremium();

    // Carregar dados de assinatura real
    await _loadSubscriptionData();

    // Só carrega produtos se não há simulação ativa
    if (!_premiumService.isPremium) {
      await _loadAvailableProducts();
    }
  }

  /// Inicia animação de pontos de carregamento
  void _startPointsAnimation() {
    _pointsTimer = Timer.periodic(
      const Duration(milliseconds: 500),
      (Timer timer) {
        if (pointsAnimation.value == '...') {
          pointsAnimation.value = '..';
        } else if (pointsAnimation.value == '..') {
          pointsAnimation.value = '.';
        } else {
          pointsAnimation.value = '...';
        }
      },
    );
  }

  /// Carrega dados da assinatura atual
  Future<void> _loadSubscriptionData() async {
    try {
      isLoading.value = true;
      await _inAppPurchaseService.inAppLoadDataSignature();

      _state.value = _state.value.copyWith(
        isPremium: _inAppPurchaseService.isPremium.value,
        subscriptionInfo: _inAppPurchaseService.info,
        isLoading: false,
      );
    } catch (e) {
      _state.value = _state.value.copyWith(
        isLoading: false,
        errorMessage: 'Erro ao carregar dados da assinatura: $e',
      );
    } finally {
      isLoading.value = false;
    }
  }

  /// Carrega produtos disponíveis
  Future<void> _loadAvailableProducts() async {
    try {
      final offering = await _revenuecatService.getOfferings();
      currentOffering.value = offering;

      _state.value = _state.value.copyWith(
        availableProducts: offering?.availablePackages ?? [],
        hasProducts: offering?.availablePackages.isNotEmpty ?? false,
      );
    } catch (e) {
      _state.value = _state.value.copyWith(
        errorMessage: 'Erro ao carregar produtos: $e',
      );
    }
  }

  /// Realiza compra de um pacote
  Future<void> purchasePackage(Package package) async {
    try {
      isInteractingWithStore.value = true;
      _showLoadingDialog();

      final purchased = await _revenuecatService.purchasePackage(package);

      if (purchased) {
        await _refreshSubscriptionStatus();
        _showSuccessMessage();
      } else {
        _showErrorMessage('Não foi possível completar a compra');
      }
    } catch (e) {
      _showErrorMessage('Erro durante a compra: $e');
    } finally {
      isInteractingWithStore.value = false;
      _hideLoadingDialog();
    }
  }

  /// Restaura compras anteriores
  Future<void> restorePurchases() async {
    try {
      isInteractingWithStore.value = true;
      _showLoadingDialog();

      final restored = await _revenuecatService.restorePurchases();

      if (restored) {
        await _refreshSubscriptionStatus();
        _showSuccessMessage('Assinatura restaurada com sucesso!');
      } else {
        _showRestoreErrorDialog();
      }
    } catch (e) {
      _showErrorMessage('Erro ao restaurar compras: $e');
    } finally {
      isInteractingWithStore.value = false;
      _hideLoadingDialog();
    }
  }

  /// Atualiza status da assinatura
  Future<void> _refreshSubscriptionStatus() async {
    final isPremium = await _inAppPurchaseService.checkSignature();
    _inAppPurchaseService.isPremium.value = isPremium;
    await _loadSubscriptionData();
  }

  /// Mostra dialog de carregamento com timeout
  void _showLoadingDialog() {
    if (!(Get.isDialogOpen ?? false)) {
      // Reset timeout state
      timeoutCountdown.value = 15;

      // Inicia timeout countdown
      _startTimeoutCountdown();

      Get.dialog(
        PopScope(
          canPop: false,
          child: Dialog(
            backgroundColor: Colors.white,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            child: Container(
              padding: const EdgeInsets.all(24),
              constraints: const BoxConstraints(
                maxWidth: 300,
                maxHeight: 200,
              ),
              child: Obx(() => Column(
                    mainAxisSize: MainAxisSize.min,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const CircularProgressIndicator(
                        color: Colors.green,
                        strokeWidth: 3,
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'Processando${pointsAnimation.value}',
                        style: const TextStyle(
                          color: Colors.black,
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      const SizedBox(height: 8),
                      const Text(
                        'Aguarde enquanto processamos sua solicitação',
                        style: TextStyle(
                          color: Colors.grey,
                          fontSize: 12,
                        ),
                        textAlign: TextAlign.center,
                      ),

                      // Timeout countdown section (compacto)
                      if (timeoutCountdown.value <= 10) ...[
                        const SizedBox(height: 12),
                        Text(
                          'Timeout em ${timeoutCountdown.value}s',
                          style: TextStyle(
                            color: timeoutCountdown.value <= 5
                                ? Colors.red.shade600
                                : Colors.orange.shade600,
                            fontSize: 11,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ],
                  )),
            ),
          ),
        ),
        barrierDismissible: false,
      );
    }
  }

  /// Oculta dialog de carregamento
  void _hideLoadingDialog() {
    // Cancela timer de timeout
    _timeoutTimer?.cancel();
    _timeoutTimer = null;

    // Reset countdown
    timeoutCountdown.value = 15;

    if (Get.isDialogOpen ?? false) {
      Get.back();
    }
  }

  /// Inicia countdown do timeout
  void _startTimeoutCountdown() {
    _timeoutTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (timeoutCountdown.value > 0) {
        timeoutCountdown.value--;
      } else {
        timer.cancel();
        _handleTimeout();
      }
    });
  }

  /// Trata o timeout da operação
  void _handleTimeout() {
    _hideLoadingDialog();

    Get.snackbar(
      'Não foi possível realizar a requisição',
      'A operação demorou mais que o esperado e foi cancelada. Tente novamente.',
      snackPosition: SnackPosition.BOTTOM,
      backgroundColor: Colors.orange.shade100,
      colorText: Colors.orange.shade800,
      icon: Icon(Icons.error_outline, color: Colors.orange.shade600),
      duration: const Duration(seconds: 5),
      margin: const EdgeInsets.all(16),
      borderRadius: 8,
    );

    // Reset loading states
    isLoading.value = false;
    isInteractingWithStore.value = false;
  }

  /// Mostra mensagem de sucesso
  void _showSuccessMessage([String? message]) {
    Get.snackbar(
      'Sucesso!',
      message ?? 'Assinatura ativada com sucesso!',
      backgroundColor: Colors.green,
      colorText: Colors.white,
      icon: const Icon(Icons.check_circle, color: Colors.white),
      duration: const Duration(seconds: 3),
      snackPosition: SnackPosition.TOP,
    );
  }

  /// Mostra mensagem de erro
  void _showErrorMessage(String message) {
    Get.snackbar(
      'Erro',
      message,
      backgroundColor: Colors.red,
      colorText: Colors.white,
      icon: const Icon(Icons.error, color: Colors.white),
      duration: const Duration(seconds: 4),
      snackPosition: SnackPosition.TOP,
    );
  }

  /// Mostra dialog de erro na restauração
  void _showRestoreErrorDialog() {
    Get.dialog(
      AlertDialog(
        title: const Text('Assinatura não encontrada'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(
              Icons.info_outline,
              size: 48,
              color: Colors.amber,
            ),
            const SizedBox(height: 16),
            Text(
              GetPlatform.isAndroid
                  ? 'Não encontramos assinaturas válidas para esta conta do Google Play.\n\nCaso possua mais de uma conta, altere a conta ativa no Google Play e tente novamente.'
                  : 'Não encontramos assinaturas válidas para esta conta da App Store.\n\nVerifique se a assinatura está ativa na sua conta.',
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 14),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  /// Mostra dialog de gerenciamento de assinatura
  void showSubscriptionManagementDialog() {
    Get.dialog(
      AlertDialog(
        title: const Text('Gerenciar Assinatura'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              'Para gerenciar sua assinatura, acesse as configurações da sua conta:',
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            if (GetPlatform.isAndroid) ...[
              const Text(
                '• Abra o Google Play Store\n'
                '• Toque no menu (≡)\n'
                '• Selecione "Assinaturas"\n'
                '• Encontre ReceitaAgro',
                style: TextStyle(fontSize: 12),
              ),
            ] else ...[
              const Text(
                '• Abra o App Store\n'
                '• Toque no seu avatar\n'
                '• Selecione "Assinaturas"\n'
                '• Encontre ReceitaAgro',
                style: TextStyle(fontSize: 12),
              ),
            ],
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: const Text('Entendi'),
          ),
        ],
      ),
    );
  }

  /// Abre termos de uso
  void openTermsOfUse() {
    _inAppPurchaseService.launchTermoUso();
  }

  /// Abre política de privacidade
  void openPrivacyPolicy() {
    _inAppPurchaseService.launchPoliticaPrivacidade();
  }

  /// Retorna se o usuário é premium
  /// Prioriza assinatura fake (simulação) sobre assinatura real
  bool get isPremium {
    // 1. Verifica primeiro se há simulação ativa
    if (_premiumService.isPremium) {
      return true;
    }
    // 2. Se não há simulação, verifica assinatura real
    return _inAppPurchaseService.isPremium.value;
  }

  /// Retorna informações da assinatura
  /// Se simulação estiver ativa, retorna dados fake, senão dados reais
  Map<String, dynamic> get subscriptionInfo {
    // Se há simulação ativa, retornar dados fake
    if (_premiumService.isPremium && !_inAppPurchaseService.isPremium.value) {
      return _getFakeSubscriptionInfo();
    }
    // Senão, retornar dados reais
    return _inAppPurchaseService.info;
  }

  /// Gera informações fake para assinatura simulada
  Map<String, dynamic> _getFakeSubscriptionInfo() {
    final now = DateTime.now();
    final endDate = now.add(const Duration(days: 25)); // 25 dias restantes
    final startDate =
        now.subtract(const Duration(days: 5)); // Começou há 5 dias

    return {
      'active': true,
      'percentComplete': 83.3, // 25 dias de 30 = ~83%
      'daysRemaining': '25 Dias Restantes',
      'subscriptionDesc': 'Plano de Teste (Simulação)',
      'endDate':
          '${endDate.day.toString().padLeft(2, '0')}/${endDate.month.toString().padLeft(2, '0')}/${endDate.year}',
      'startDate':
          '${startDate.day.toString().padLeft(2, '0')}/${startDate.month.toString().padLeft(2, '0')}/${startDate.year}',
    };
  }

  /// Retorna se tem produtos disponíveis
  bool get hasProducts =>
      currentOffering.value?.availablePackages.isNotEmpty ?? false;

  /// Retorna lista de produtos disponíveis
  List<Package> get availablePackages =>
      currentOffering.value?.availablePackages ?? [];

  /// Retorna progresso da assinatura (0-100)
  double get subscriptionProgress {
    if (!isPremium) return 0.0;

    final percentComplete = subscriptionInfo['percentComplete'];
    if (percentComplete is num) {
      return percentComplete.toDouble();
    }
    return 0.0;
  }

  /// Retorna dias restantes da assinatura
  int get daysRemaining {
    if (!isPremium) return 0;

    // Para simulação, extrair número da string "X Dias Restantes"
    final daysInfo = subscriptionInfo['daysRemaining'];
    if (daysInfo is String) {
      final match = RegExp(r'(\d+)').firstMatch(daysInfo);
      if (match != null) {
        return int.tryParse(match.group(1)!) ?? 0;
      }
    }
    if (daysInfo is num) {
      return daysInfo.toInt();
    }
    return 0;
  }

  /// Retorna se a assinatura está ativa
  bool get isSubscriptionActive {
    // Se há simulação ativa, sempre considerar ativa
    if (_premiumService.isPremium && !_inAppPurchaseService.isPremium.value) {
      return true;
    }
    return subscriptionInfo['active'] == true;
  }

  /// Retorna se estamos usando assinatura simulada (fake)
  bool get isUsingFakeSubscription {
    return _premiumService.isPremium && !_inAppPurchaseService.isPremium.value;
  }

  /// Força atualização dos dados
  Future<void> refreshData() async {
    // Atualizar status premium (incluindo simulação)
    await _premiumService.atualizarStatusPremium();

    // Atualizar dados de assinatura real
    await _loadSubscriptionData();
    await _loadAvailableProducts();
  }
}
