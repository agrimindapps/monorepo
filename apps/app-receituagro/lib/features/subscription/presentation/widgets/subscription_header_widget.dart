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
        // Icon/Illustration Hero
        Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.1),
            shape: BoxShape.circle,
            boxShadow: [
              BoxShadow(
                color: Colors.green.withValues(alpha: 0.3),
                blurRadius: 30,
                spreadRadius: 5,
              ),
            ],
          ),
          child: const Icon(
            Icons.local_florist_rounded,
            size: 64,
            color: Color(0xFF66BB6A), // Light Green
          ),
        ),
        const SizedBox(height: 24),
        
        const Text(
          'Tenha acesso ilimitado\na todos os recursos',
          textAlign: TextAlign.center,
          style: TextStyle(
            color: Colors.white,
            fontSize: 28,
            fontWeight: FontWeight.bold,
            height: 1.2,
            letterSpacing: -0.5,
          ),
        ),
        
        const SizedBox(height: 12),
        Text(
          'Desbloqueie todo o potencial do ReceitAgro\ne garanta colheitas mais saudáveis',
          textAlign: TextAlign.center,
          style: TextStyle(
            color: Colors.white.withValues(alpha: 0.8),
            fontSize: 16,
            fontWeight: FontWeight.w400,
            height: 1.4,
          ),
        ),
      ],
    );
  }
}
