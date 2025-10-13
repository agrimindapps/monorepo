import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:injectable/injectable.dart';

/// Serviço centralizado para feedback háptico
/// Gerencia vibrações e feedback tátil para melhorar UX
@lazySingleton
class HapticService {
  bool _isEnabled = true;
  bool _isInitialized = false;

  /// Inicializa o serviço de haptic feedback
  Future<void> initialize() async {
    if (_isInitialized) return;

    try {
      await HapticFeedback.lightImpact();
      _isInitialized = true;

      if (kDebugMode) {
        print('HapticService: Inicializado com sucesso');
      }
    } catch (e) {
      _isEnabled = false;
      if (kDebugMode) {
        print('HapticService: Haptic feedback não disponível - $e');
      }
    }
  }

  /// Habilita ou desabilita feedback háptico globalmente
  void setEnabled(bool enabled) {
    _isEnabled = enabled;
  }

  /// Verifica se haptic feedback está habilitado
  bool get isEnabled => _isEnabled && _isInitialized;

  /// Feedback leve - para interações básicas
  /// Usado em: toques em botões, navegação, seleção
  Future<void> light() async {
    if (!isEnabled) return;

    try {
      await HapticFeedback.lightImpact();
    } catch (e) {
      if (kDebugMode) {
        print('HapticService.light: Erro - $e');
      }
    }
  }

  /// Feedback médio - para ações importantes
  /// Usado em: completar tarefas, salvar dados, confirmações
  Future<void> medium() async {
    if (!isEnabled) return;

    try {
      await HapticFeedback.mediumImpact();
    } catch (e) {
      if (kDebugMode) {
        print('HapticService.medium: Erro - $e');
      }
    }
  }

  /// Feedback pesado - para ações críticas
  /// Usado em: erros, alertas, ações destrutivas
  Future<void> heavy() async {
    if (!isEnabled) return;

    try {
      await HapticFeedback.heavyImpact();
    } catch (e) {
      if (kDebugMode) {
        print('HapticService.heavy: Erro - $e');
      }
    }
  }

  /// Feedback de seleção - para mudanças de estado
  /// Usado em: toggles, sliders, seleções em lista
  Future<void> selection() async {
    if (!isEnabled) return;

    try {
      await HapticFeedback.selectionClick();
    } catch (e) {
      if (kDebugMode) {
        print('HapticService.selection: Erro - $e');
      }
    }
  }

  /// Feedback de vibração longa - para notificações importantes
  /// Usado em: notificações push, alertas críticos
  Future<void> vibrate() async {
    if (!isEnabled) return;

    try {
      await HapticFeedback.vibrate();
    } catch (e) {
      if (kDebugMode) {
        print('HapticService.vibrate: Erro - $e');
      }
    }
  }

  /// Padrão de sucesso - sequência de feedback para sucesso
  /// Usado em: operações completadas com sucesso
  Future<void> success() async {
    if (!isEnabled) return;

    await medium();
    await Future<void>.delayed(const Duration(milliseconds: 100));
    await light();
  }

  /// Padrão de erro - sequência de feedback para erro
  /// Usado em: erros críticos, falhas em operações
  Future<void> error() async {
    if (!isEnabled) return;

    await heavy();
    await Future<void>.delayed(const Duration(milliseconds: 150));
    await heavy();
  }

  /// Padrão de warning - feedback para avisos
  /// Usado em: validações, campos obrigatórios
  Future<void> warning() async {
    if (!isEnabled) return;

    await medium();
    await Future<void>.delayed(const Duration(milliseconds: 200));
    await light();
    await Future<void>.delayed(const Duration(milliseconds: 100));
    await light();
  }

  /// Padrão de progresso - feedback para atualizações de progresso
  /// Usado em: uploads, downloads, processamento
  Future<void> progress() async {
    if (!isEnabled) return;

    await light();
  }

  /// Padrão de completar tarefa - feedback especializado para tarefas
  /// Usado em: marcar tarefas como concluídas
  Future<void> taskComplete() async {
    if (!isEnabled) return;

    await medium();
    await Future<void>.delayed(const Duration(milliseconds: 50));
    await light();
    await Future<void>.delayed(const Duration(milliseconds: 50));
    await light();
  }

  /// Padrão de salvar planta - feedback para salvar plantas
  /// Usado em: adicionar ou editar plantas
  Future<void> plantSave() async {
    if (!isEnabled) return;

    await selection();
    await Future<void>.delayed(const Duration(milliseconds: 100));
    await medium();
  }

  /// Padrão de compra premium - feedback para transações
  /// Usado em: compras, upgrades, assinaturas
  Future<void> purchase() async {
    if (!isEnabled) return;

    await heavy();
    await Future<void>.delayed(const Duration(milliseconds: 200));
    await medium();
    await Future<void>.delayed(const Duration(milliseconds: 100));
    await light();
  }

  /// Padrão de sync - feedback para sincronização
  /// Usado em: backup, restore, sync de dados
  Future<void> sync() async {
    if (!isEnabled) return;

    await selection();
    await Future<void>.delayed(const Duration(milliseconds: 150));
    await selection();
  }

  /// Padrão de navegação - feedback para mudanças de tela
  /// Usado em: navegação entre páginas, abrir modals
  Future<void> navigation() async {
    if (!isEnabled) return;

    await light();
  }

  /// Padrão de auth - feedback para autenticação
  /// Usado em: login, logout, biometria
  Future<void> auth() async {
    if (!isEnabled) return;

    await medium();
    await Future<void>.delayed(const Duration(milliseconds: 100));
    await selection();
  }

  /// Padrão personalizado com delays customizados
  Future<void> custom({
    required List<HapticType> pattern,
    int delayBetween = 100,
  }) async {
    if (!isEnabled) return;

    for (int i = 0; i < pattern.length; i++) {
      await _executeHapticType(pattern[i]);
      if (i < pattern.length - 1) {
        await Future<void>.delayed(Duration(milliseconds: delayBetween));
      }
    }
  }

  Future<void> _executeHapticType(HapticType type) async {
    switch (type) {
      case HapticType.light:
        await light();
        break;
      case HapticType.medium:
        await medium();
        break;
      case HapticType.heavy:
        await heavy();
        break;
      case HapticType.selection:
        await selection();
        break;
      case HapticType.vibrate:
        await vibrate();
        break;
    }
  }

  // Contextos pré-definidos (merged from HapticContexts)
  Future<void> buttonTap() => light();
  Future<void> cardTap() => selection();
  Future<void> swipe() => light();
  Future<void> pageChange() => navigation();
  Future<void> openModal() => medium();
  Future<void> closeModal() => light();
  Future<void> completeTask() => taskComplete();
  Future<void> addTask() => selection();
  Future<void> deleteTask() => heavy();
  Future<void> addPlant() => plantSave();
  Future<void> editPlant() => plantSave();
  Future<void> deletePlant() => error();
  Future<void> waterPlant() => medium();
  Future<void> purchaseSuccess() => purchase();
  Future<void> purchaseError() => error();
  Future<void> restorePurchase() => success();
  Future<void> saveSettings() => selection();
  Future<void> syncData() => sync();
  Future<void> backupComplete() => success();
  Future<void> backupError() => error();
  Future<void> loginSuccess() => auth();
  Future<void> loginError() => error();
  Future<void> biometricSuccess() => auth();
  Future<void> biometricError() => warning();
  Future<void> uploadStart() => light();
  Future<void> uploadProgress() => progress();
  Future<void> uploadComplete() => success();
  Future<void> uploadError() => error();
  Future<void> validationError() => warning();
  Future<void> requiredField() => warning();
  Future<void> formSubmit() => medium();
  Future<void> notificationReceived() => vibrate();
  Future<void> reminderAlert() => medium();
}

/// Tipos de haptic feedback disponíveis
enum HapticType { light, medium, heavy, selection, vibrate }

/// Mixin para facilitar uso de haptic feedback em widgets
/// Requer HapticService como dependência injetada
mixin HapticFeedbackMixin {
  HapticService get hapticService;

  /// Executa haptic feedback se habilitado
  Future<void> performHaptic(Future<void> Function() hapticFunction) async {
    if (hapticService.isEnabled) {
      await hapticFunction();
    }
  }

  /// Executa haptic feedback para contexto específico
  Future<void> performContextualHaptic(String context) async {
    switch (context) {
      case 'button_tap':
        await hapticService.buttonTap();
        break;
      case 'task_complete':
        await hapticService.completeTask();
        break;
      case 'plant_save':
        await hapticService.addPlant();
        break;
      case 'premium_purchase':
        await hapticService.purchaseSuccess();
        break;
      case 'error':
        await hapticService.error();
        break;
      case 'success':
        await hapticService.success();
        break;
      default:
        await hapticService.light();
    }
  }
}

/// Widget que adiciona haptic feedback automaticamente
/// Requer HapticService como dependência injetada via GetIt
class HapticWrapper extends StatelessWidget {
  final Widget child;
  final VoidCallback? onTap;
  final String? hapticContext;
  final HapticType hapticType;
  final bool enabled;
  final HapticService hapticService;

  const HapticWrapper({
    super.key,
    required this.child,
    required this.hapticService,
    this.onTap,
    this.hapticContext,
    this.hapticType = HapticType.light,
    this.enabled = true,
  });

  @override
  Widget build(BuildContext context) {
    if (onTap == null) {
      return child;
    }

    return GestureDetector(
      onTap:
          enabled
              ? () async {
                if (hapticContext != null) {
                  await _executeContextualHaptic();
                } else {
                  await hapticService._executeHapticType(hapticType);
                }
                onTap?.call();
              }
              : onTap,
      child: child,
    );
  }

  Future<void> _executeContextualHaptic() async {
    switch (hapticContext) {
      case 'button':
        await hapticService.buttonTap();
        break;
      case 'card':
        await hapticService.cardTap();
        break;
      case 'task_complete':
        await hapticService.completeTask();
        break;
      case 'plant_save':
        await hapticService.addPlant();
        break;
      case 'purchase':
        await hapticService.purchaseSuccess();
        break;
      case 'navigation':
        await hapticService.pageChange();
        break;
      default:
        await hapticService.light();
    }
  }
}
