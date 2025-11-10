import 'package:core/core.dart' hide Column;
import 'package:flutter/material.dart';

/// Widget responsável por exibir o status da assinatura ativa
///
/// Responsabilidades:
/// - Mostrar status visual (ícone de check)
/// - Exibir mensagem de confirmação premium
/// - Mostrar detalhes da assinatura (tipo e validade)
/// - Design com gradiente verde para indicar sucesso
class SubscriptionActiveStatusCardWidget extends StatelessWidget {
  final SubscriptionEntity? subscription;

  const SubscriptionActiveStatusCardWidget({
    super.key,
    required this.subscription,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(24.0),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          gradient: LinearGradient(
            colors: [Colors.green.shade400, Colors.green.shade600],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: Column(
          children: [
            const Icon(
              Icons.check_circle,
              color: Colors.white,
              size: 48,
            ),
            
            const SizedBox(height: 16),
            const Text(
              '🎉 Você é Premium!',
              style: TextStyle(
                color: Colors.white,
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            
            const SizedBox(height: 8),
            const Text(
              'Tenha acesso ilimitado a todos os recursos',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Colors.white,
                fontSize: 16,
                fontWeight: FontWeight.w400,
              ),
            ),
            
            if (subscription != null) ...[
              const SizedBox(height: 16),
              _buildSubscriptionDetails(),
            ],
          ],
        ),
      ),
    );
  }

  /// Constrói os detalhes da assinatura
  Widget _buildSubscriptionDetails() {
    if (subscription == null) return const SizedBox.shrink();
    
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.2),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Plano:',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                ),
              ),
              Text(
                _getSubscriptionTypeName(),
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Válido até:',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                ),
              ),
              Text(
                _formatExpirationDate(),
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  /// Retorna o nome do tipo de assinatura
  String _getSubscriptionTypeName() {
    if (subscription?.productId.contains('yearly') == true) {
      return 'Anual';
    } else if (subscription?.productId.contains('monthly') == true) {
      return 'Mensal';
    } else if (subscription?.productId.contains('weekly') == true) {
      return 'Semanal';
    }
    return 'Premium';
  }

  /// Formata a data de expiração
  String _formatExpirationDate() {
    final expirationDate = subscription?.expirationDate;
    if (expirationDate == null) return 'Indefinido';
    return '${expirationDate.day.toString().padLeft(2, '0')}/'
           '${expirationDate.month.toString().padLeft(2, '0')}/'
           '${expirationDate.year}';
  }
}
