import 'package:flutter/material.dart';

/// Widget responsável pelo header da tela de planos
///
/// Responsabilidades:
/// - Exibir título principal da oferta
/// - Design atrativo para conversão
/// - Consistência visual com tema
class SubscriptionHeaderWidget extends StatelessWidget {
  const SubscriptionHeaderWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        const Text(
          'Tenha acesso ilimitado\na todos os recursos',
          textAlign: TextAlign.center,
          style: TextStyle(
            color: Colors.white,
            fontSize: 28,
            fontWeight: FontWeight.bold,
            height: 1.2,
          ),
        ),
        
        const SizedBox(height: 12),
        Text(
          'Desbloqueie todo o potencial do ReceitAgro',
          textAlign: TextAlign.center,
          style: TextStyle(
            color: Colors.white.withValues(alpha: 0.8),
            fontSize: 16,
            fontWeight: FontWeight.w400,
          ),
        ),
      ],
    );
  }
}