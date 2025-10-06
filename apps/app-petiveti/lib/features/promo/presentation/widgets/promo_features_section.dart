import 'package:flutter/material.dart';
import '../../../../shared/constants/splash_constants.dart';

class PromoFeaturesSection extends StatelessWidget {
  final dynamic features; // Will be ignored, using hardcoded features

  const PromoFeaturesSection({
    super.key,
    required this.features,
  });

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isMobile = screenWidth < 768;
    final isTablet = screenWidth >= 768 && screenWidth < 1024;
    
    return Container(
      width: double.infinity,
      padding: EdgeInsets.symmetric(
        horizontal: isMobile ? 16 : 32,
        vertical: 80,
      ),
      color: SplashColors.backgroundColor,
      child: Column(
        children: [
          _buildSectionHeader(context, isMobile),
          
          const SizedBox(height: 60),
          _buildFeaturesGrid(context, isMobile, isTablet),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(BuildContext context, bool isMobile) {
    return Column(
      children: [
        Text(
          'Recursos Completos para o Cuidado do seu Pet',
          style: TextStyle(
            fontSize: isMobile ? 28 : 36,
            fontWeight: FontWeight.bold,
            color: SplashColors.textColor,
            height: 1.2,
          ),
          textAlign: TextAlign.center,
        ),
        
        const SizedBox(height: 16),
        Container(
          constraints: const BoxConstraints(maxWidth: 600),
          child: Text(
            'Tudo o que você precisa para cuidar da saúde e bem-estar do seu animal de estimação em um único aplicativo.',
            style: TextStyle(
              fontSize: isMobile ? 16 : 18,
              color: SplashColors.textColor.withValues(alpha: 0.7),
              height: 1.5,
            ),
            textAlign: TextAlign.center,
          ),
        ),
        Container(
          margin: const EdgeInsets.only(top: 24),
          width: 60,
          height: 4,
          decoration: BoxDecoration(
            color: SplashColors.primaryColor,
            borderRadius: BorderRadius.circular(2),
          ),
        ),
      ],
    );
  }

  Widget _buildFeaturesGrid(BuildContext context, bool isMobile, bool isTablet) {
    final features = _getFeatures();
    
    if (isMobile) {
      return Column(
        children: features.map((feature) => 
          Padding(
            padding: const EdgeInsets.only(bottom: 32),
            child: _buildFeatureCard(feature),
          ),
        ).toList(),
      );
    }
    final crossAxisCount = isTablet ? 2 : 3;
    final children = <Widget>[];
    
    for (int i = 0; i < features.length; i += crossAxisCount) {
      final rowFeatures = features.skip(i).take(crossAxisCount).toList();
      children.add(
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: rowFeatures.map((feature) {
            final isLast = feature == rowFeatures.last;
            return Expanded(
              child: Padding(
                padding: EdgeInsets.only(
                  right: isLast ? 0 : 30,
                  bottom: 30,
                ),
                child: _buildFeatureCard(feature),
              ),
            );
          }).toList(),
        ),
      );
    }

    return Container(
      constraints: const BoxConstraints(maxWidth: 1200),
      child: Column(children: children),
    );
  }

  Widget _buildFeatureCard(_FeatureData feature) {
    return Container(
      height: 260,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            spreadRadius: 1,
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        children: [
          Container(
            width: 72,
            height: 72,
            decoration: BoxDecoration(
              color: feature.color.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Icon(
              feature.icon,
              size: 40,
              color: feature.color,
            ),
          ),
          
          const SizedBox(height: 20),
          Text(
            feature.title,
            style: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: SplashColors.textColor,
              height: 1.2,
            ),
            textAlign: TextAlign.center,
          ),
          
          const SizedBox(height: 12),
          Expanded(
            child: Text(
              feature.description,
              style: TextStyle(
                fontSize: 15,
                color: SplashColors.textColor.withValues(alpha: 0.7),
                height: 1.4,
              ),
              textAlign: TextAlign.center,
            ),
          ),
        ],
      ),
    );
  }

  List<_FeatureData> _getFeatures() {
    return [
      const _FeatureData(
        icon: Icons.pets,
        title: 'Perfis de Pet',
        description: 'Crie perfis detalhados para todos os seus animais de estimação com raça, idade, peso e muito mais.',
        color: SplashColors.petProfilesColor,
      ),
      const _FeatureData(
        icon: Icons.vaccines,
        title: 'Vacinas',
        description: 'Acompanhe o calendário de vacinação e receba notificações para nunca perder uma data importante.',
        color: SplashColors.vaccinesColor,
      ),
      const _FeatureData(
        icon: Icons.medication,
        title: 'Medicamentos',
        description: 'Gerencie os medicamentos, doses e horários para garantir tratamentos eficazes.',
        color: SplashColors.medicationsColor,
      ),
      const _FeatureData(
        icon: Icons.monitor_weight,
        title: 'Controle de Peso',
        description: 'Acompanhe a evolução do peso do seu animal com gráficos intuitivos.',
        color: SplashColors.weightControlColor,
      ),
      const _FeatureData(
        icon: Icons.calendar_today,
        title: 'Histórico de Consultas',
        description: 'Mantenha um registro completo de todas as consultas veterinárias, diagnósticos e recomendações.',
        color: SplashColors.appointmentsColor,
      ),
      const _FeatureData(
        icon: Icons.access_time,
        title: 'Lembretes',
        description: 'Configure alertas personalizados para consultas, medicamentos e outros cuidados importantes.',
        color: SplashColors.remindersColor,
      ),
    ];
  }
}

class _FeatureData {
  final IconData icon;
  final String title;
  final String description;
  final Color color;

  const _FeatureData({
    required this.icon,
    required this.title,
    required this.description,
    required this.color,
  });
}