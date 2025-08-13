// Project imports:
import '../../../../core/services/in_app_purchase_service.dart';
import '../interfaces/i_premium_service.dart';

/// Implementação do serviço premium
class PremiumServiceImpl implements IPremiumService {
  final InAppPurchaseService _inAppPurchaseService;

  PremiumServiceImpl(this._inAppPurchaseService);

  @override
  bool get isPremium => _inAppPurchaseService.isPremium.value;

  @override
  Map<String, dynamic> get subscriptionInfo => Map<String, dynamic>.from(_inAppPurchaseService.info);

  @override
  Future<bool> checkPremiumStatus() async {
    // Chama o método checkSignature para verificar o status premium atual
    return await _inAppPurchaseService.checkSignature();
  }

  @override
  Future<void> refreshPremiumStatus() async {
    // Atualiza o status premium recarregando as informações da assinatura
    await _inAppPurchaseService.inAppLoadDataSignature();
    // Atualiza o valor isPremium com base na verificação atual
    _inAppPurchaseService.isPremium.value = await _inAppPurchaseService.checkSignature();
  }
}
