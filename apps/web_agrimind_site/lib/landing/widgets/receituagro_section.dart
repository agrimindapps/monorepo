import 'package:flutter/material.dart';
import 'featured_app_section.dart';

class ReceituAgroSection extends StatelessWidget {
  const ReceituAgroSection({super.key});

  @override
  Widget build(BuildContext context) {
    return FeaturedAppSection(
      title: 'ReceituAgro',
      subtitle: 'Agricultura Inteligente',
      description:
          'Transforme o diagnóstico agrícola com nossa plataforma completa. '
          'Acesso instantâneo a mais de 117 mil diagnósticos de pragas, '
          '3 mil produtos fitossanitários e 210 culturas catalogadas. '
          'Tudo na palma da sua mão, mesmo sem internet.',
      iconAsset: 'assets/imagens/app_icons/receituagro.png',
      primaryColor: const Color(0xFF4CAF50),
      accentColor: const Color(0xFF8BC34A),
      imageOnRight: false,
      downloadUrl: 'https://receituagro.agrimind.com.br',
      features: const [
        FeatureItem(
          icon: Icons.search,
          title: 'Diagnóstico Inteligente',
          description:
              'Identifique pragas e doenças rapidamente com nossa base de dados com mais de 117.000 diagnósticos específicos por cultura.',
        ),
        FeatureItem(
          icon: Icons.eco,
          title: 'Gestão de Culturas',
          description:
              'Gerencie mais de 210 culturas com informações detalhadas sobre pragas, defensivos e melhores práticas agronômicas.',
        ),
        FeatureItem(
          icon: Icons.shield,
          title: 'Defensivos Certificados',
          description:
              'Acesse informações técnicas de +3.000 produtos fitossanitários com dosagens e recomendações de aplicação.',
        ),
        FeatureItem(
          icon: Icons.cloud_off,
          title: 'Modo Offline Completo',
          description:
              'Toda a base de dados disponível localmente. Trabalhe no campo sem depender de conexão com a internet.',
        ),
      ],
      stats: const [
        StatItem(value: '117k+', label: 'Diagnósticos'),
        StatItem(value: '210+', label: 'Culturas'),
        StatItem(value: '3k+', label: 'Defensivos'),
      ],
    );
  }
}
