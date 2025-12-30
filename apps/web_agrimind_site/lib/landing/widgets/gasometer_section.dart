import 'package:flutter/material.dart';
import 'featured_app_section.dart';

class GasometerSection extends StatelessWidget {
  const GasometerSection({super.key});

  @override
  Widget build(BuildContext context) {
    return FeaturedAppSection(
      title: 'Gasometer',
      subtitle: 'Gestão Veicular',
      description:
          'Tenha controle total sobre seus veículos e máquinas. '
          'Registre abastecimentos, acompanhe manutenções, analise custos '
          'e otimize o consumo. Tudo com relatórios detalhados e análise de desempenho.',
      iconAsset: 'assets/imagens/app_icons/gasometer.png',
      primaryColor: const Color(0xFF2196F3),
      accentColor: const Color(0xFF64B5F6),
      imageOnRight: false,
      downloadUrl: 'https://gasometer.agrimind.com.br',
      features: const [
        FeatureItem(
          icon: Icons.local_gas_station,
          title: 'Controle de Abastecimentos',
          description:
              'Registre cada abastecimento e acompanhe o consumo médio, custos por quilômetro e tendências de consumo.',
        ),
        FeatureItem(
          icon: Icons.build,
          title: 'Gestão de Manutenções',
          description:
              'Mantenha histórico completo de manutenções preventivas e corretivas com lembretes automáticos.',
        ),
        FeatureItem(
          icon: Icons.analytics,
          title: 'Análise de Custos',
          description:
              'Visualize gráficos e relatórios detalhados sobre gastos com combustível, manutenção e custos totais.',
        ),
        FeatureItem(
          icon: Icons.speed,
          title: 'Métricas de Performance',
          description:
              'Acompanhe km/l, custo por km, eficiência do veículo e identifique oportunidades de economia.',
        ),
      ],
      stats: const [
        StatItem(value: 'Real-time', label: 'Analytics'),
        StatItem(value: 'Multi', label: 'Veículos'),
        StatItem(value: '100%', label: 'Offline'),
      ],
    );
  }
}
