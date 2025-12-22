import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:url_launcher/url_launcher.dart';

class AppsSection extends StatelessWidget {
  const AppsSection({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
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
            'Soluções para cada necessidade',
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
                title: 'ReceituAgro',
                description: 'Diagnóstico fitossanitário e prescrição agrícola completa na palma da sua mão.',
                icon: Icons.assignment_turned_in,
                color: Colors.green,
                url: 'https://receituagro.agrimind.com.br',
                features: ['Diagnóstico Preciso', 'Receituário Digital', 'Base de Dados Offline'],
              ),
              _AppCard(
                title: 'Petiveti',
                description: 'Gestão completa para a saúde e bem-estar do seu pet.',
                icon: Icons.pets,
                color: Colors.orange,
                url: 'https://petiveti.agrimind.com.br',
                features: ['Carteira de Vacinação', 'Lembretes', 'Histórico Médico'],
              ),
              _AppCard(
                title: 'Plantis',
                description: 'Seu assistente pessoal para o cuidado com plantas ornamentais e hortas.',
                icon: Icons.local_florist,
                color: Colors.teal,
                url: 'https://plantis.agrimind.com.br',
                features: ['Identificação de Plantas', 'Guia de Cultivo', 'Lembretes de Rega'],
              ),
              _AppCard(
                title: 'Gasometer',
                description: 'Controle de abastecimento e manutenção de veículos e máquinas.',
                icon: Icons.local_gas_station,
                color: Colors.blue,
                url: 'https://gasometer.agrimind.com.br',
                features: ['Média de Consumo', 'Gestão de Frota', 'Relatórios de Custos'],
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
  final IconData icon;
  final Color color;
  final String url;
  final List<String> features;

  const _AppCard({
    required this.title,
    required this.description,
    required this.icon,
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
            color: Colors.black.withOpacity(0.2),
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
              color: color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Icon(icon, size: 32, color: color),
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
                backgroundColor: color,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                elevation: 0,
              ),
              child: const Text('Conhecer Mais'),
            ),
          ),
        ],
      ),
    );
  }
}
