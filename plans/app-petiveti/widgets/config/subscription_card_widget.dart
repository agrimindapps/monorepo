// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:get/get.dart';

// Project imports:
import '../../core/interfaces/i_auth_service.dart';
import '../../core/interfaces/i_subscription_service.dart';
import '../../models/subscription_model.dart';

class SubscriptionCardWidget extends StatelessWidget {
  const SubscriptionCardWidget({super.key});

  @override
  Widget build(BuildContext context) {
    final subscriptionService = Get.find<ISubscriptionService>();
    
    return Obx(() {
        if (subscriptionService.isLoading) {
          return _buildLoadingCard();
        }

        return Card(
          elevation: 2,
          margin: const EdgeInsets.symmetric(horizontal: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          child: subscriptionService.isPremium
              ? _buildPremiumContent(subscriptionService.currentSubscription)
              : _buildFreeContent(),
        );
    });
  }

  Widget _buildLoadingCard() {
    return Card(
      elevation: 2,
      margin: const EdgeInsets.symmetric(horizontal: 16),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Row(
          children: [
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: Colors.grey[300],
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Center(
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF4CAF50)),
                ),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    height: 16,
                    width: 140,
                    decoration: BoxDecoration(
                      color: Colors.grey[300],
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Container(
                    height: 14,
                    width: 200,
                    decoration: BoxDecoration(
                      color: Colors.grey[300],
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFreeContent() {
    return DecoratedBox(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Colors.grey[50]!,
            Colors.grey[100]!,
          ],
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    color: Colors.amber[100],
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(
                    Icons.pets,
                    color: Colors.amber[700],
                    size: 28,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Plano Gratuito',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF2C3E50),
                        ),
                      ),
                      Text(
                        'Desbloqueie recursos premium',
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.grey[600],
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            Text(
              'Recursos Premium:',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: Colors.grey[700],
              ),
            ),
            const SizedBox(height: 12),
            ...SubscriptionModel.beneficiosPremium.take(4).map(
              (beneficio) => Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: Row(
                  children: [
                    Icon(
                      Icons.check_circle_outline,
                      size: 20,
                      color: Colors.grey[500],
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        beneficio,
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.grey[600],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            if (SubscriptionModel.beneficiosPremium.length > 4) ...[
              const SizedBox(height: 4),
              Text(
                'E mais ${SubscriptionModel.beneficiosPremium.length - 4} recursos...',
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey[500],
                  fontStyle: FontStyle.italic,
                ),
              ),
            ],
            const SizedBox(height: 20),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () => _handleUpgradeAction(),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF4CAF50),
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  elevation: 2,
                ),
                child: const Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.pets, size: 20),
                    SizedBox(width: 8),
                    Text(
                      'Assinar Premium',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPremiumContent(SubscriptionModel subscription) {
    return DecoratedBox(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Colors.amber[50]!,
            Colors.amber[100]!,
          ],
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    color: Colors.amber[200],
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(
                    Icons.pets,
                    color: Colors.amber[800],
                    size: 28,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          const Text(
                            'Premium',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF2C3E50),
                            ),
                          ),
                          const SizedBox(width: 8),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 4,
                            ),
                            decoration: BoxDecoration(
                              color: _getStatusColor(subscription.status),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Text(
                              subscription.statusTexto,
                              style: const TextStyle(
                                fontSize: 12,
                                color: Colors.white,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Plano ${subscription.planTexto}',
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.grey[600],
                        ),
                      ),
                    ],
                  ),
                ),
                PopupMenuButton<String>(
                  icon: Icon(
                    Icons.more_vert,
                    color: Colors.grey[600],
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  itemBuilder: (context) => [
                    const PopupMenuItem(
                      value: 'gerenciar',
                      child: Row(
                        children: [
                          Icon(Icons.settings, size: 20),
                          SizedBox(width: 12),
                          Text('Gerenciar'),
                        ],
                      ),
                    ),
                    const PopupMenuItem(
                      value: 'restaurar',
                      child: Row(
                        children: [
                          Icon(Icons.refresh, size: 20),
                          SizedBox(width: 12),
                          Text('Restaurar Compras'),
                        ],
                      ),
                    ),
                    if (subscription.status == SubscriptionStatus.active) ...[
                      const PopupMenuDivider(),
                      const PopupMenuItem(
                        value: 'cancelar',
                        child: Row(
                          children: [
                            Icon(Icons.cancel, size: 20, color: Colors.red),
                            SizedBox(width: 12),
                            Text(
                              'Cancelar',
                              style: TextStyle(color: Colors.red),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ],
                  onSelected: (value) => _handleMenuAction(value, subscription),
                ),
              ],
            ),
            const SizedBox(height: 20),
            _buildSubscriptionInfo(subscription),
            const SizedBox(height: 16),
            if (subscription.diasRestantes > 0) ...[
              _buildProgressBar(subscription),
              const SizedBox(height: 16),
            ],
            Row(
              children: [
                Expanded(
                  child: _buildInfoCard(
                    'Preço',
                    '${subscription.precoFormatado}/${subscription.plan == SubscriptionPlan.monthly ? 'mês' : 'ano'}',
                    Icons.payment,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _buildInfoCard(
                    'Próxima Cobrança',
                    _formatarData(subscription.proximaCobranca),
                    Icons.calendar_today,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSubscriptionInfo(SubscriptionModel subscription) {
    String texto = '';
    Color cor = Colors.green;

    switch (subscription.status) {
      case SubscriptionStatus.active:
        if (subscription.diasRestantes > 0) {
          texto = 'Sua assinatura está ativa e renova em ${subscription.diasRestantes} dias';
          cor = Colors.green;
        } else {
          texto = 'Sua assinatura está ativa';
          cor = Colors.green;
        }
        break;
      case SubscriptionStatus.canceled:
        texto = 'Assinatura cancelada - acesso até ${_formatarData(subscription.terminaEm)}';
        cor = Colors.orange;
        break;
      case SubscriptionStatus.expired:
        texto = 'Sua assinatura expirou em ${_formatarData(subscription.terminaEm)}';
        cor = Colors.red;
        break;
      default:
        texto = 'Status da assinatura indefinido';
        cor = Colors.grey;
    }

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: cor.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: cor.withValues(alpha: 0.3),
          width: 1,
        ),
      ),
      child: Row(
        children: [
          Icon(
            _getStatusIcon(subscription.status),
            color: cor,
            size: 20,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              texto,
              style: TextStyle(
                fontSize: 14,
                color: cor.withValues(alpha: 0.8),
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProgressBar(SubscriptionModel subscription) {
    if (subscription.inicioEm == null || subscription.terminaEm == null) {
      return const SizedBox.shrink();
    }

    final agora = DateTime.now();
    final totalDias = subscription.terminaEm!.difference(subscription.inicioEm!).inDays;
    final diasDecorridos = agora.difference(subscription.inicioEm!).inDays;
    final progresso = (diasDecorridos / totalDias).clamp(0.0, 1.0);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Período da assinatura',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: Colors.grey[700],
              ),
            ),
            Text(
              '${subscription.diasRestantes} dias restantes',
              style: TextStyle(
                fontSize: 12,
                color: Colors.grey[600],
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        LinearProgressIndicator(
          value: progresso,
          backgroundColor: Colors.grey[300],
          valueColor: AlwaysStoppedAnimation<Color>(
            subscription.status == SubscriptionStatus.active
                ? const Color(0xFF4CAF50)
                : Colors.orange,
          ),
          minHeight: 6,
        ),
      ],
    );
  }

  Widget _buildInfoCard(String titulo, String valor, IconData icone) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.7),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                icone,
                size: 16,
                color: Colors.grey[600],
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  titulo,
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey[600],
                    fontWeight: FontWeight.w500,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            valor,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: Color(0xFF2C3E50),
            ),
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }

  Color _getStatusColor(SubscriptionStatus status) {
    switch (status) {
      case SubscriptionStatus.active:
        return Colors.green;
      case SubscriptionStatus.canceled:
        return Colors.orange;
      case SubscriptionStatus.expired:
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  IconData _getStatusIcon(SubscriptionStatus status) {
    switch (status) {
      case SubscriptionStatus.active:
        return Icons.check_circle;
      case SubscriptionStatus.canceled:
        return Icons.cancel;
      case SubscriptionStatus.expired:
        return Icons.error;
      default:
        return Icons.help;
    }
  }

  String _formatarData(DateTime? data) {
    if (data == null) return 'N/A';
    return '${data.day.toString().padLeft(2, '0')}/${data.month.toString().padLeft(2, '0')}/${data.year}';
  }

  void _handleUpgradeAction() {
    if (!Get.find<IAuthService>().isLoggedIn) {
      Get.snackbar(
        'Login necessário',
        'Faça login para assinar o Premium',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.orange,
        colorText: Colors.white,
      );
      return;
    }

    Get.find<ISubscriptionService>().navegarParaPlanos();
  }

  void _handleMenuAction(String action, SubscriptionModel subscription) {
    switch (action) {
      case 'gerenciar':
        Get.find<ISubscriptionService>().navegarParaGerenciarAssinatura();
        break;
      case 'restaurar':
        Get.find<ISubscriptionService>().restoreSubscription();
        break;
      case 'cancelar':
        _handleCancelSubscription();
        break;
    }
  }

  Future<void> _handleCancelSubscription() async {
    final confirmar = await Get.find<ISubscriptionService>().mostrarDialogoCancelamento();
    if (confirmar) {
      await Get.find<ISubscriptionService>().cancelSubscription();
    }
  }
}
