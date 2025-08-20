// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:url_launcher/url_launcher.dart';

class MidiaSection extends StatefulWidget {
  const MidiaSection({super.key});

  @override
  State<MidiaSection> createState() => _MidiaSectionState();
}

class _MidiaSectionState extends State<MidiaSection> {
  final List<Map<String, dynamic>> _mediaFeatures = [
    {
      'source': 'TechAgro',
      'logo':
          'https://fkjakafxqciukoesqvkp.supabase.co/storage/v1/object/public/agrihurb/website/media_1.png',
      'quote':
          'ReceituAgro se destaca como ferramenta essencial para profissionais do agronegócio',
      'date': '12/03/2025',
      'link': 'https://techagro.com.br/review-receituagro'
    },
    {
      'source': 'Revista Agricultura Digital',
      'logo':
          'https://fkjakafxqciukoesqvkp.supabase.co/storage/v1/object/public/agrihurb/website/media_2.png',
      'quote':
          'AgriHub é destaque em nossa análise das melhores ferramentas para o produtor rural em 2025',
      'date': '05/02/2025',
      'link': 'https://agriculturadigital.com/melhores-apps-2025'
    },
    {
      'source': 'Jornal do Agronegócio',
      'logo':
          'https://fkjakafxqciukoesqvkp.supabase.co/storage/v1/object/public/agrihurb/website/media_3.png',
      'quote':
          'Termus simplifica aprendizado técnico e se torna favorito entre estudantes de agronomia',
      'date': '21/01/2025',
      'link': 'https://jornaldoagro.com.br/apps-educacionais'
    },
    {
      'source': 'Portal Tech & Pets',
      'logo':
          'https://fkjakafxqciukoesqvkp.supabase.co/storage/v1/object/public/agrihurb/website/media_4.png',
      'quote':
          'VetiPeti revoluciona o acompanhamento da saúde de pets com interface intuitiva',
      'date': '17/12/2024',
      'link': 'https://techandpets.com/review-vetipeti'
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Container(
      key: GlobalKey(), // Adicione uma key se quiser navegação para esta seção
      padding: const EdgeInsets.symmetric(vertical: 80, horizontal: 24),
      color: Colors.grey[50],
      child: Column(
        children: [
          const Text(
            'Apps na Mídia',
            style: TextStyle(
              fontSize: 32,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          Container(
            width: 80,
            height: 4,
            color: Colors.green.shade700,
          ),
          const SizedBox(height: 16),
          Text(
            'O que a imprensa especializada diz sobre nossos aplicativos',
            style: TextStyle(
              fontSize: 18,
              color: Colors.grey[700],
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 50),

          // Layout responsivo para os cards de mídia
          Center(
            child: SizedBox(
              width: 1600,
              child: LayoutBuilder(
                builder: (context, constraints) {
                  return constraints.maxWidth > 900
                      ? _buildMediaDesktopLayout()
                      : _buildMediaMobileLayout();
                },
              ),
            ),
          ),
        ],
      ),
    );
  }

  // Layout para desktop (duas colunas)
  Widget _buildMediaDesktopLayout() {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: Column(
            children: [
              _buildMediaCard(_mediaFeatures[0]),
              const SizedBox(height: 24),
              _buildMediaCard(_mediaFeatures[2]),
            ],
          ),
        ),
        const SizedBox(width: 24),
        Expanded(
          child: Column(
            children: [
              _buildMediaCard(_mediaFeatures[1]),
              const SizedBox(height: 24),
              _buildMediaCard(_mediaFeatures[3]),
            ],
          ),
        ),
      ],
    );
  }

  // Layout para mobile (uma coluna)
  Widget _buildMediaMobileLayout() {
    return Column(
      children: _mediaFeatures.map((feature) {
        return Padding(
          padding: const EdgeInsets.only(bottom: 24),
          child: _buildMediaCard(feature),
        );
      }).toList(),
    );
  }

  // Card individual de menção na mídia
  Widget _buildMediaCard(Map<String, dynamic> media) {
    return Card(
      elevation: 3,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Logo e fonte
            Row(
              children: [
                if (media.containsKey('logo') && media['logo'] != '')
                  ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: Image.network(
                      media['logo'],
                      height: 40,
                      width: 40,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) {
                        return Icon(
                          Icons.article,
                          size: 40,
                          color: Colors.green.shade700,
                        );
                      },
                    ),
                  ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        media['source'],
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        media['date'],
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.grey[600],
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),

            // Citação
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.grey[100],
                borderRadius: BorderRadius.circular(8),
                border: Border.all(
                  color: Colors.grey[300]!,
                  width: 1,
                ),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(
                    Icons.format_quote,
                    size: 24,
                    color: Colors.green.shade700.withValues(alpha: 0.7),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      media['quote'],
                      style: const TextStyle(
                        fontSize: 16,
                        fontStyle: FontStyle.italic,
                        height: 1.5,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // Link para a matéria completa
            Align(
              alignment: Alignment.centerRight,
              child: media['link'] == ''
                  ? TextButton(
                      onPressed: null,
                      style: TextButton.styleFrom(
                        disabledForegroundColor:
                            Colors.grey.withValues(alpha: 0.6),
                      ),
                      child: const Text('Indisponível'),
                    )
                  : TextButton.icon(
                      onPressed: () async {
                        final url = media['link'];
                        if (await canLaunchUrl(Uri.parse(url))) {
                          await launchUrl(Uri.parse(url));
                        }
                      },
                      icon: const Text('Ler matéria completa'),
                      label: const Icon(Icons.open_in_new, size: 16),
                    ),
            ),
          ],
        ),
      ),
    );
  }
}
