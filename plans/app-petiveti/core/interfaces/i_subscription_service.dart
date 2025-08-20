// Project imports:
import '../../models/subscription_model.dart';

/// Interface para o serviço de assinatura
/// Quebra dependência circular entre SubscriptionService e outros services
abstract class ISubscriptionService {
  /// Assinatura atual do usuário
  SubscriptionModel get currentSubscription;
  
  /// Indica se o usuário é premium
  bool get isPremium;
  
  /// Indica se está carregando
  bool get isLoading;
  
  /// Assinar um plano premium
  Future<bool> subscribe(SubscriptionPlan plan);
  
  /// Cancelar assinatura atual
  Future<bool> cancelSubscription();
  
  /// Restaurar compras anteriores
  Future<void> restoreSubscription();
  
  /// Navegar para tela de planos
  void navegarParaPlanos();
  
  /// Navegar para gerenciamento de assinatura
  void navegarParaGerenciarAssinatura();
  
  /// Mostrar diálogo de cancelamento
  Future<bool> mostrarDialogoCancelamento();
}
