// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:get/get.dart';

// Project imports:
import '../core/interfaces/i_auth_service.dart';
import '../core/interfaces/i_subscription_service.dart';
import '../models/subscription_model.dart';

class SubscriptionService extends GetxService implements ISubscriptionService {
  static SubscriptionService get instance => Get.find<SubscriptionService>();

  final _currentSubscription = Rx<SubscriptionModel>(SubscriptionModel());
  final _isLoading = false.obs;
  
  // Injeção de dependência para quebrar dependência circular
  late IAuthService _authService;

  @override
  SubscriptionModel get currentSubscription => _currentSubscription.value;
  
  @override
  bool get isPremium => _currentSubscription.value.isPremium;
  
  @override
  bool get isLoading => _isLoading.value;

  @override
  void onInit() {
    super.onInit();
    // Injetar dependência do AuthService
    _authService = Get.find<IAuthService>();
    _loadSubscriptionFromStorage();
    
    // Escutar mudanças no usuário para atualizar assinatura
    _authService.currentUserStream.listen((user) {
      if (user == null) {
        _currentSubscription.value = SubscriptionModel();
      } else {
        _loadSubscriptionFromStorage();
      }
    });
  }

  Future<void> _loadSubscriptionFromStorage() async {
    try {
      _isLoading.value = true;
      
      // TODO: Implementar carregamento da assinatura do storage/API
      await Future.delayed(const Duration(milliseconds: 500));
      
      // Por padrão, o usuário começa no plano gratuito
      _currentSubscription.value = SubscriptionModel();
      
    } catch (e) {
      debugPrint('❌ Erro ao carregar assinatura: $e');
    } finally {
      _isLoading.value = false;
    }
  }

  @override
  Future<bool> subscribe(SubscriptionPlan plan) async {
    try {
      _isLoading.value = true;
      
      // TODO: Implementar compra real com RevenueCat/In-App Purchase
      await Future.delayed(const Duration(seconds: 3));
      
      final preco = plan == SubscriptionPlan.monthly ? 12.90 : 119.90;
      final duracao = plan == SubscriptionPlan.monthly ? 30 : 365;
      
      _currentSubscription.value = SubscriptionModel(
        id: 'sub_${DateTime.now().millisecondsSinceEpoch}',
        status: SubscriptionStatus.active,
        plan: plan,
        inicioEm: DateTime.now(),
        terminaEm: DateTime.now().add(Duration(days: duracao)),
        proximaCobranca: DateTime.now().add(Duration(days: duracao)),
        preco: preco,
        moeda: 'BRL',
        autoRenovacao: true,
      );
      
      // Atualizar status premium do usuário
      await _authService.updateUserPremiumStatus(true);
      
      await _saveSubscriptionToStorage();
      
      Get.snackbar(
        'Parabéns! 🎉',
        'Você agora é um usuário Premium do PetiVeti!',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: const Color(0xFF4CAF50),
        colorText: Colors.white,
        duration: const Duration(seconds: 4),
      );
      
      return true;
    } catch (e) {
      Get.snackbar(
        'Erro',
        'Erro ao processar assinatura: $e',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
      return false;
    } finally {
      _isLoading.value = false;
    }
  }

  @override
  Future<bool> cancelSubscription() async {
    try {
      _isLoading.value = true;
      
      // TODO: Implementar cancelamento real
      await Future.delayed(const Duration(seconds: 2));
      
      _currentSubscription.value = _currentSubscription.value.copyWith(
        status: SubscriptionStatus.canceled,
        autoRenovacao: false,
      );
      
      await _saveSubscriptionToStorage();
      
      Get.snackbar(
        'Assinatura Cancelada',
        'Sua assinatura foi cancelada. Você manterá o acesso premium até ${_formatarData(_currentSubscription.value.terminaEm)}',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.orange,
        colorText: Colors.white,
        duration: const Duration(seconds: 5),
      );
      
      return true;
    } catch (e) {
      Get.snackbar(
        'Erro',
        'Erro ao cancelar assinatura: $e',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
      return false;
    } finally {
      _isLoading.value = false;
    }
  }

  @override
  Future<void> restoreSubscription() async {
    try {
      _isLoading.value = true;
      
      // TODO: Implementar restauração real
      await Future.delayed(const Duration(seconds: 2));
      
      Get.snackbar(
        'Verificando compras',
        'Restauração de compras concluída',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.blue,
        colorText: Colors.white,
      );
      
    } catch (e) {
      Get.snackbar(
        'Erro',
        'Erro ao restaurar compras: $e',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    } finally {
      _isLoading.value = false;
    }
  }

  Future<void> _saveSubscriptionToStorage() async {
    // TODO: Implementar salvamento no Hive ou SharedPreferences
    debugPrint('💾 Salvando assinatura no storage');
  }

  String _formatarData(DateTime? data) {
    if (data == null) return '';
    return '${data.day.toString().padLeft(2, '0')}/${data.month.toString().padLeft(2, '0')}/${data.year}';
  }

  @override
  void navegarParaPlanos() {
    // TODO: Implementar navegação para tela de planos
    Get.snackbar(
      'Em desenvolvimento',
      'Tela de planos será implementada em breve',
      snackPosition: SnackPosition.BOTTOM,
    );
  }

  @override
  void navegarParaGerenciarAssinatura() {
    // TODO: Implementar navegação para gerenciamento
    Get.snackbar(
      'Em desenvolvimento',
      'Gerenciamento de assinatura será implementado em breve',
      snackPosition: SnackPosition.BOTTOM,
    );
  }

  @override
  Future<bool> mostrarDialogoCancelamento() async {
    return await Get.dialog<bool>(
      AlertDialog(
        title: const Text('Cancelar Assinatura'),
        content: const Text(
          'Tem certeza que deseja cancelar sua assinatura Premium?\n\n'
          'Você manterá o acesso aos recursos premium até o final do período atual.',
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(result: false),
            child: const Text('Manter Premium'),
          ),
          ElevatedButton(
            onPressed: () => Get.back(result: true),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
            ),
            child: const Text('Cancelar'),
          ),
        ],
      ),
    ) ?? false;
  }

  static List<Map<String, dynamic>> get planosDisponiveis => [
    {
      'id': 'monthly',
      'nome': 'Premium Mensal',
      'preco': 12.90,
      'periodo': 'mês',
      'plan': SubscriptionPlan.monthly,
      'economia': null,
    },
    {
      'id': 'yearly',
      'nome': 'Premium Anual',
      'preco': 119.90,
      'periodo': 'ano',
      'plan': SubscriptionPlan.yearly,
      'economia': '23% de desconto',
    },
  ];
}
