// Flutter imports:
import 'package:flutter/material.dart';

class FeatureSection extends StatelessWidget {
  const FeatureSection({super.key});

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isSmallScreen = screenWidth < 800;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 16.0, horizontal: 8.0),
          child: Row(
            children: [
              Icon(
                Icons.star_outline_rounded,
                color: Colors.green.shade700,
              ),
              const SizedBox(width: 8),
              Text(
                'Recursos em destaque',
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: Colors.green.shade800,
                ),
              ),
            ],
          ),
        ),
        isSmallScreen ? _buildFeaturesColumn() : _buildFeaturesRow(),
      ],
    );
  }

  Widget _buildFeaturesColumn() {
    return Column(
      children: [
        _buildFeatureItem(
          Icons.calculate_outlined,
          'Cálculo de IMC',
          'Calcule seu Índice de Massa Corporal e receba análise personalizada.',
        ),
        const SizedBox(height: 16),
        _buildFeatureItem(
          Icons.local_fire_department_outlined,
          'Contador de Calorias',
          'Acompanhe seu consumo de calorias baseado nos alimentos que você consome.',
        ),
        const SizedBox(height: 16),
        _buildFeatureItem(
          Icons.favorite_border_outlined,
          'Perfil Nutricional',
          'Crie seu perfil nutricional e receba sugestões alimentares.',
        ),
      ],
    );
  }

  Widget _buildFeaturesRow() {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: _buildFeatureItem(
            Icons.calculate_outlined,
            'Cálculo de IMC',
            'Calcule seu Índice de Massa Corporal e receba análise personalizada.',
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: _buildFeatureItem(
            Icons.local_fire_department_outlined,
            'Contador de Calorias',
            'Acompanhe seu consumo de calorias baseado nos alimentos que você consome.',
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: _buildFeatureItem(
            Icons.favorite_border_outlined,
            'Perfil Nutricional',
            'Crie seu perfil nutricional e receba sugestões alimentares.',
          ),
        ),
      ],
    );
  }

  Widget _buildFeatureItem(IconData icon, String title, String description) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15),
        border: Border.all(
          color: Colors.grey.shade200,
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withValues(alpha: 0.1),
            spreadRadius: 1,
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.green.shade50,
              shape: BoxShape.circle,
            ),
            child: Icon(
              icon,
              color: Colors.green,
              size: 32,
            ),
          ),
          const SizedBox(height: 16),
          Text(
            title,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 8),
          Text(
            description,
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey.shade700,
              height: 1.5,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}
