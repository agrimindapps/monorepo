import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:url_launcher/url_launcher.dart';

class AppsSection extends StatelessWidget {
  const AppsSection({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 100, horizontal: 20),
      color: const Color(0xFF121212),
      child: Column(
        children: [
          Text(
            'NOSSOS APLICATIVOS',
            style: GoogleFonts.inter(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: const Color(0xFF3ECF8E),
              letterSpacing: 1.5,
            ),
          ),
          const SizedBox(height: 16),
          Text(
            'Mais soluções para você',
            style: GoogleFonts.poppins(
              fontSize: 36,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 60),
          const Wrap(
            spacing: 30,
            runSpacing: 30,
            alignment: WrapAlignment.center,
            children: [
              _AppCard(
                title: 'Petiveti',
                description: 'Gestão completa para a saúde e bem-estar do seu pet.',
                iconAsset: 'assets/imagens/app_icons/petiveti.png',
                color: Colors.orange,
                url: 'https://petiveti.agrimind.com.br',
                features: ['Carteira de Vacinação', 'Lembretes', 'Histórico Médico'],
              ),
              _AppCard(
                title: 'Nebulalist',
                description: 'Gerenciador de listas inteligente com templates e compartilhamento.',
                iconAsset: 'assets/imagens/app_icons/nebulalist.png',
                color: Colors.purple,
                url: 'https://nebulalist.agrimind.com.br',
                features: ['Templates Personalizados', 'Compartilhamento', 'Modo Offline'],
              ),
              _AppCard(
                title: 'Taskolist',
                description: 'Organize suas tarefas e projetos de forma simples e eficiente.',
                iconAsset: 'assets/imagens/app_icons/taskolist.png',
                color: Colors.indigo,
                url: 'https://taskolist.agrimind.com.br',
                features: ['Gestão de Tarefas', 'Notificações', 'Produtividade'],
              ),
              _AppCard(
                title: 'AgriHurbi',
                description: 'Gestão agrícola completa para produtores rurais.',
                iconAsset: 'assets/imagens/app_icons/agrihurbi.png',
                color: Colors.lightGreen,
                url: 'https://agrihurbi.agrimind.com.br',
                features: ['Gestão de Safras', 'Controle de Custos', 'Relatórios'],
              ),
              _AppCard(
                title: 'Nutrituti',
                description: 'Acompanhamento nutricional e planejamento de refeições.',
                iconAsset: 'assets/imagens/app_icons/nutrituti.png',
                color: Colors.pink,
                url: 'https://nutrituti.agrimind.com.br',
                features: ['Cálculo Nutricional', 'Plano Alimentar', 'Receitas Saudáveis'],
              ),
              _AppCard(
                title: 'Termos Técnicos',
                description: 'Dicionário especializado de termos técnicos e científicos.',
                iconAsset: 'assets/imagens/app_icons/termostecnicos.png',
                color: Colors.amber,
                url: 'https://termostecnicos.agrimind.com.br',
                features: ['Busca Rápida', 'Offline', 'Múltiplas Áreas'],
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _AppCard extends StatelessWidget {
  final String title;
  final String description;
  final String? iconAsset;
  final Color color;
  final String url;
  final List<String> features;

  const _AppCard({
    required this.title,
    required this.description,
    this.iconAsset,
    required this.color,
    required this.url,
    required this.features,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 350,
      padding: const EdgeInsets.all(32),
      decoration: BoxDecoration(
        color: const Color(0xFF1E1E1E), // Dark card
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.2),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
        border: Border.all(color: Colors.grey.shade800),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(16),
            ),
            child: iconAsset != null
                ? ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: Image.asset(
                      iconAsset!,
                      width: 48,
                      height: 48,
                      fit: BoxFit.cover,
                    ),
                  )
                : Icon(Icons.apps, size: 32, color: color),
          ),
          const SizedBox(height: 24),
          Text(
            title,
            style: GoogleFonts.poppins(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 12),
          Text(
            description,
            style: GoogleFonts.inter(
              fontSize: 16,
              color: Colors.grey.shade400,
              height: 1.5,
            ),
          ),
          const SizedBox(height: 24),
          ...features.map((feature) => Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: Row(
                  children: [
                    Icon(Icons.check, size: 16, color: color),
                    const SizedBox(width: 8),
                    Text(
                      feature,
                      style: GoogleFonts.inter(
                        fontSize: 14,
                        color: Colors.grey.shade300,
                      ),
                    ),
                  ],
                ),
              )),
          const SizedBox(height: 32),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () async {
                final uri = Uri.parse(url);
                if (await canLaunchUrl(uri)) {
                  await launchUrl(uri);
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF3ECF8E),
                foregroundColor: Colors.black,
                padding: const EdgeInsets.symmetric(vertical: 20),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                elevation: 0,
              ),
              child: const Text(
                'Conhecer Mais',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
