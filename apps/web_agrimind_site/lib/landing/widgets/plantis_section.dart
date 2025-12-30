import 'package:flutter/material.dart';
import 'featured_app_section.dart';

class PlantisSection extends StatelessWidget {
  const PlantisSection({super.key});

  @override
  Widget build(BuildContext context) {
    return FeaturedAppSection(
      title: 'Plantis',
      subtitle: 'Jardinagem Doméstica',
      description:
          'Seu assistente pessoal para cuidar de plantas ornamentais e hortas caseiras. '
          'Com notificações inteligentes, guias de cultivo e sincronização em múltiplos '
          'dispositivos, nunca foi tão fácil manter suas plantas saudáveis e bonitas.',
      iconAsset: 'assets/imagens/app_icons/plantis.png',
      primaryColor: const Color(0xFF00897B),
      accentColor: const Color(0xFF26A69A),
      imageOnRight: true,
      downloadUrl: 'https://plantis.agrimind.com.br',
      features: const [
        FeatureItem(
          icon: Icons.notifications_active,
          title: 'Lembretes Inteligentes',
          description:
              'Nunca mais esqueça de regar! Receba notificações personalizadas para cada planta baseadas em suas necessidades específicas.',
        ),
        FeatureItem(
          icon: Icons.camera_alt,
          title: 'Registro com Fotos',
          description:
              'Acompanhe a evolução das suas plantas com fotos e registre momentos importantes como floração e poda.',
        ),
        FeatureItem(
          icon: Icons.book,
          title: 'Guias de Cultivo',
          description:
              'Acesse informações detalhadas sobre como cuidar de cada espécie, incluindo luz, água, solo e temperatura ideal.',
        ),
        FeatureItem(
          icon: Icons.sync,
          title: 'Sincronização em Nuvem',
          description:
              'Seus dados seguros e sincronizados entre todos os seus dispositivos. Acesse de qualquer lugar.',
        ),
      ],
      stats: const [
        StatItem(value: '10/10', label: 'Qualidade'),
        StatItem(value: '80%+', label: 'Cobertura de Testes'),
        StatItem(value: '100%', label: 'Offline'),
      ],
    );
  }
}
