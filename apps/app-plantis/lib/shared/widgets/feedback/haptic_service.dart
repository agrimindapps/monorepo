import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

/// Serviço centralizado para feedback háptico
/// Gerencia vibrações e feedback tátil para melhorar UX
class HapticService {
  static bool _isEnabled = true;
  static bool _isInitialized = false;

  /// Inicializa o serviço de haptic feedback
  static Future<void> initialize() async {
    if (_isInitialized) return;

    try {
      // Testar se haptic feedback está disponível
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
  static void setEnabled(bool enabled) {
    _isEnabled = enabled;
  }

  /// Verifica se haptic feedback está habilitado
  static bool get isEnabled => _isEnabled && _isInitialized;

  /// Feedback leve - para interações básicas
  /// Usado em: toques em botões, navegação, seleção
  static Future<void> light() async {
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
  static Future<void> medium() async {
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
  static Future<void> heavy() async {
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
  static Future<void> selection() async {
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
  static Future<void> vibrate() async {
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
  static Future<void> success() async {
    if (!isEnabled) return;

    await medium();
    await Future<void>.delayed(const Duration(milliseconds: 100));
    await light();
  }

  /// Padrão de erro - sequência de feedback para erro
  /// Usado em: erros críticos, falhas em operações
  static Future<void> error() async {
    if (!isEnabled) return;

    await heavy();
    await Future<void>.delayed(const Duration(milliseconds: 150));
    await heavy();
  }

  /// Padrão de warning - feedback para avisos
  /// Usado em: validações, campos obrigatórios
  static Future<void> warning() async {
    if (!isEnabled) return;

    await medium();
    await Future<void>.delayed(const Duration(milliseconds: 200));
    await light();
    await Future<void>.delayed(const Duration(milliseconds: 100));
    await light();
  }

  /// Padrão de progresso - feedback para atualizações de progresso
  /// Usado em: uploads, downloads, processamento
  static Future<void> progress() async {
    if (!isEnabled) return;

    await light();
  }

  /// Padrão de completar tarefa - feedback especializado para tarefas
  /// Usado em: marcar tarefas como concluídas
  static Future<void> taskComplete() async {
    if (!isEnabled) return;

    await medium();
    await Future<void>.delayed(const Duration(milliseconds: 50));
    await light();
    await Future<void>.delayed(const Duration(milliseconds: 50));
    await light();
  }

  /// Padrão de salvar planta - feedback para salvar plantas
  /// Usado em: adicionar ou editar plantas
  static Future<void> plantSave() async {
    if (!isEnabled) return;

    await selection();
    await Future<void>.delayed(const Duration(milliseconds: 100));
    await medium();
  }

  /// Padrão de compra premium - feedback para transações
  /// Usado em: compras, upgrades, assinaturas
  static Future<void> purchase() async {
    if (!isEnabled) return;

    await heavy();
    await Future<void>.delayed(const Duration(milliseconds: 200));
    await medium();
    await Future<void>.delayed(const Duration(milliseconds: 100));
    await light();
  }

  /// Padrão de sync - feedback para sincronização
  /// Usado em: backup, restore, sync de dados
  static Future<void> sync() async {
    if (!isEnabled) return;

    await selection();
    await Future<void>.delayed(const Duration(milliseconds: 150));
    await selection();
  }

  /// Padrão de navegação - feedback para mudanças de tela
  /// Usado em: navegação entre páginas, abrir modals
  static Future<void> navigation() async {
    if (!isEnabled) return;

    await light();
  }

  /// Padrão de auth - feedback para autenticação
  /// Usado em: login, logout, biometria
  static Future<void> auth() async {
    if (!isEnabled) return;

    await medium();
    await Future<void>.delayed(const Duration(milliseconds: 100));
    await selection();
  }

  /// Padrão personalizado com delays customizados
  static Future<void> custom({
    required List<HapticType> pattern,
    int delayBetween = 100,
  }) async {
    if (!isEnabled) return;

    for (int i = 0; i < pattern.length; i++) {
      await _executeHapticType(pattern[i]);

      // Adicionar delay entre haptics (exceto no último)
      if (i < pattern.length - 1) {
        await Future<void>.delayed(Duration(milliseconds: delayBetween));
      }
    }
  }

  static Future<void> _executeHapticType(HapticType type) async {
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
}

/// Tipos de haptic feedback disponíveis
enum HapticType { light, medium, heavy, selection, vibrate }

/// Contextos pré-definidos para haptic feedback
class HapticContexts {
  // Interações básicas
  static Future<void> buttonTap() => HapticService.light();
  static Future<void> cardTap() => HapticService.selection();
  static Future<void> swipe() => HapticService.light();

  // Navegação
  static Future<void> pageChange() => HapticService.navigation();
  static Future<void> openModal() => HapticService.medium();
  static Future<void> closeModal() => HapticService.light();

  // Tarefas
  static Future<void> completeTask() => HapticService.taskComplete();
  static Future<void> addTask() => HapticService.selection();
  static Future<void> deleteTask() => HapticService.heavy();

  // Plantas
  static Future<void> addPlant() => HapticService.plantSave();
  static Future<void> editPlant() => HapticService.plantSave();
  static Future<void> deletePlant() => HapticService.error();
  static Future<void> waterPlant() => HapticService.medium();

  // Premium
  static Future<void> purchaseSuccess() => HapticService.purchase();
  static Future<void> purchaseError() => HapticService.error();
  static Future<void> restorePurchase() => HapticService.success();

  // Sistema
  static Future<void> saveSettings() => HapticService.selection();
  static Future<void> syncData() => HapticService.sync();
  static Future<void> backupComplete() => HapticService.success();
  static Future<void> backupError() => HapticService.error();

  // Auth
  static Future<void> loginSuccess() => HapticService.auth();
  static Future<void> loginError() => HapticService.error();
  static Future<void> biometricSuccess() => HapticService.auth();
  static Future<void> biometricError() => HapticService.warning();

  // Upload
  static Future<void> uploadStart() => HapticService.light();
  static Future<void> uploadProgress() => HapticService.progress();
  static Future<void> uploadComplete() => HapticService.success();
  static Future<void> uploadError() => HapticService.error();

  // Validação
  static Future<void> validationError() => HapticService.warning();
  static Future<void> requiredField() => HapticService.warning();
  static Future<void> formSubmit() => HapticService.medium();

  // Notifications
  static Future<void> notificationReceived() => HapticService.vibrate();
  static Future<void> reminderAlert() => HapticService.medium();
}

/// Mixin para facilitar uso de haptic feedback em widgets
mixin HapticFeedbackMixin {
  /// Executa haptic feedback se habilitado
  Future<void> performHaptic(Future<void> Function() hapticFunction) async {
    if (HapticService.isEnabled) {
      await hapticFunction();
    }
  }

  /// Executa haptic feedback para contexto específico
  Future<void> performContextualHaptic(String context) async {
    switch (context) {
      case 'button_tap':
        await HapticContexts.buttonTap();
        break;
      case 'task_complete':
        await HapticContexts.completeTask();
        break;
      case 'plant_save':
        await HapticContexts.addPlant();
        break;
      case 'premium_purchase':
        await HapticContexts.purchaseSuccess();
        break;
      case 'error':
        await HapticService.error();
        break;
      case 'success':
        await HapticService.success();
        break;
      default:
        await HapticService.light();
    }
  }
}

/// Widget que adiciona haptic feedback automaticamente
class HapticWrapper extends StatelessWidget {
  final Widget child;
  final VoidCallback? onTap;
  final String? hapticContext;
  final HapticType hapticType;
  final bool enabled;

  const HapticWrapper({
    super.key,
    required this.child,
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
                // Executar haptic feedback primeiro
                if (hapticContext != null) {
                  await _executeContextualHaptic();
                } else {
                  await HapticService._executeHapticType(hapticType);
                }

                // Executar callback
                onTap?.call();
              }
              : onTap,
      child: child,
    );
  }

  Future<void> _executeContextualHaptic() async {
    switch (hapticContext) {
      case 'button':
        await HapticContexts.buttonTap();
        break;
      case 'card':
        await HapticContexts.cardTap();
        break;
      case 'task_complete':
        await HapticContexts.completeTask();
        break;
      case 'plant_save':
        await HapticContexts.addPlant();
        break;
      case 'purchase':
        await HapticContexts.purchaseSuccess();
        break;
      case 'navigation':
        await HapticContexts.pageChange();
        break;
      default:
        await HapticService.light();
    }
  }
}
