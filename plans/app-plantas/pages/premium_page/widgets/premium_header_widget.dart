// Flutter imports:
import 'package:flutter/material.dart';

// Project imports:
import '../../../core/design_tokens/plantas_design_tokens.dart';

class PremiumHeaderWidget extends StatelessWidget {
  const PremiumHeaderWidget({super.key});

  @override
  Widget build(BuildContext context) {
    final plantasCores = PlantasDesignTokens.cores(context);
    final plantasGradientes = PlantasDesignTokens.gradientes(context);
    final plantasTextStyles = PlantasDesignTokens.textStyles(context);

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: plantasGradientes['premium']!,
        borderRadius: BorderRadius.circular(16.0),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.1),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        children: [
          // Ícone premium
          Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              color: plantasCores['textoClaro']!,
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.local_florist,
              size: 40,
              color: plantasCores['primaria']!,
            ),
          ),

          const SizedBox(height: 20),

          // Título
          Text(
            'Grow Premium',
            style: plantasTextStyles['h1']?.copyWith(
                  fontSize: 32.0,
                  fontWeight: FontWeight.bold,
                  color: plantasCores['textoClaro'],
                  letterSpacing: 1.2,
                ) ??
                TextStyle(
                  fontSize: 32.0,
                  fontWeight: FontWeight.bold,
                  color: plantasCores['textoClaro'],
                  letterSpacing: 1.2,
                ),
            textAlign: TextAlign.center,
          ),

          const SizedBox(height: 12),

          // Subtítulo
          Text(
            'Desbloqueie todo o potencial do seu jardim',
            style: plantasTextStyles['h2']?.copyWith(
                  fontSize: 24.0,
                  color: plantasCores['textoClaro']!.withValues(alpha: 0.9),
                  height: 1.4,
                ) ??
                TextStyle(
                  fontSize: 24.0,
                  fontWeight: FontWeight.w600,
                  color: plantasCores['textoClaro']!.withValues(alpha: 0.9),
                  height: 1.4,
                ),
            textAlign: TextAlign.center,
          ),

          const SizedBox(height: 8),

          // Descrição
          Text(
            'Transforme sua experiência com plantas com recursos avançados e cuidados personalizados',
            style: plantasTextStyles['bodyLarge']?.copyWith(
                  fontSize: 16.0,
                  color: plantasCores['textoClaro']!.withValues(alpha: 0.8),
                  height: 1.3,
                ) ??
                TextStyle(
                  fontSize: 16.0,
                  color: plantasCores['textoClaro']!.withValues(alpha: 0.8),
                  height: 1.3,
                ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}
