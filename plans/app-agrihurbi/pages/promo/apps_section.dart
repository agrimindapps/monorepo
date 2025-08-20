// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:url_launcher/url_launcher.dart';

class AppsSection extends StatefulWidget {
  const AppsSection({super.key});

  @override
  State<AppsSection> createState() => _AppsSectionState();
}

class _AppsSectionState extends State<AppsSection> {
// Lista de aplicativos
  final List<Map<String, dynamic>> _apps = [
    {
      'icon': Icons.agriculture,
      'title': 'ReceituAgro',
      'description':
          'Aplicativo com informações sobre bulas de defensivos agrícolas, pragas e dosagem recomendadas para aplicação em lavoura.',
      'target': 'Engenheiros Agrônomos',
      'color': Colors.green,
      'link': 'https://receituagro.agrimind.com.br',
      'linkImage':
          'https://fkjakafxqciukoesqvkp.supabase.co/storage/v1/object/public/agrihurb/website/receituagro.png',
      'tags': ['Agricultura', 'Defensivos']
    },
    {
      'icon': Icons.book,
      'title': 'Termus',
      'description':
          'Dicionário interativo que permite consultar termos, jogar aprendendo e ouvir a pronúncia correta.',
      'target': 'Estudantes e Profissionais',
      'color': Colors.blue,
      'link': 'https://termus.agrimind.com.br',
      'linkImage':
          'https://fkjakafxqciukoesqvkp.supabase.co/storage/v1/object/public/agrihurb/website/termus.png',
      'tags': ['Educação', 'Dicionário']
    },
    {
      'icon': Icons.dashboard,
      'title': 'AgriHurb',
      'description':
          'Diversas ferramentas do agro: notícias, cotações, tempo, registros de pluviometria e outros.',
      'target': 'Profissionais do Agronegócio',
      'color': Colors.amber,
      'link': '',
      'linkImage':
          'https://fkjakafxqciukoesqvkp.supabase.co/storage/v1/object/public/agrihurb/website/agrihurb.png',
      'tags': ['Agronegócio', 'Ferramentas']
    },
    {
      'icon': Icons.food_bank,
      'title': 'NutriTuti',
      'description':
          'Informações nutricionais, receitas fit, relaxamento, acompanhamento de peso e mais.',
      'target': 'Entusiastas de Saúde',
      'color': Colors.red,
      'link': 'https://nutrituti.agrimind.com.br',
      'linkImage':
          'https://fkjakafxqciukoesqvkp.supabase.co/storage/v1/object/public/agrihurb/website/nutrituti.png',
      'tags': ['Nutrição', 'Saúde']
    },
    {
      'icon': Icons.directions_car,
      'title': 'GasOMeter',
      'description':
          'Controle pessoal de veículo, abastecimentos, manutenções e despesas.',
      'target': 'Motoristas',
      'color': Colors.indigo,
      'link': '',
      'linkImage':
          'https://fkjakafxqciukoesqvkp.supabase.co/storage/v1/object/public/agrihurb/website/gasometer.png',
      'tags': ['Automóveis', 'Gestão']
    },
    {
      'icon': Icons.pets,
      'title': 'VetiPeti',
      'description':
          'Informações sobre raças, medicamentos para pet e ferramentas para acompanhamento do seu pet.',
      'target': 'Tutores de Pets',
      'color': Colors.purple,
      'link': '',
      'linkImage':
          'https://fkjakafxqciukoesqvkp.supabase.co/storage/v1/object/public/agrihurb/website/vetipeti.png',
      'tags': ['Pets', 'Veterinária']
    },
  ];

  // Lista para filtragem por categoria
  final List<String> _categories = [
    'Todos',
    'Agricultura',
    'Saúde',
    'Educação',
    'Gestão',
    'Pets'
  ];
  String _selectedCategory = 'Todos';

  @override
  Widget build(BuildContext context) {
    // Filtragem dos apps baseada na categoria selecionada
    final filteredApps = _selectedCategory == 'Todos'
        ? _apps
        : _apps
            .where((app) =>
                app['tags'] != null &&
                app['tags'].any((tag) => tag
                    .toString()
                    .toLowerCase()
                    .contains(_selectedCategory.toLowerCase())))
            .toList();

    return Column(
      children: [
        // Pequena descrição introdutória
        Container(
          constraints: const BoxConstraints(maxWidth: 800),
          margin: const EdgeInsets.only(bottom: 40),
          child: Text(
            'Desenvolvemos soluções digitais intuitivas que atendem às necessidades específicas de diversos setores, com foco especial no agronegócio e bem-estar.',
            style: TextStyle(
              fontSize: 18,
              height: 1.6,
              color: Colors.grey[700],
            ),
            textAlign: TextAlign.center,
          ),
        ),

        // Filtros por categoria
        Padding(
          padding: const EdgeInsets.only(bottom: 40),
          child: Wrap(
            spacing: 12,
            children: _categories.map((category) {
              final isSelected = _selectedCategory == category;
              return FilterChip(
                label: Text(category),
                selected: isSelected,
                showCheckmark: false,
                backgroundColor: Colors.grey.shade100,
                selectedColor: Colors.green.shade100,
                labelStyle: TextStyle(
                  color:
                      isSelected ? Colors.green.shade700 : Colors.grey.shade800,
                  fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                  side: BorderSide(
                    color:
                        isSelected ? Colors.green.shade700 : Colors.transparent,
                    width: 1,
                  ),
                ),
                onSelected: (selected) {
                  setState(() {
                    _selectedCategory = category;
                  });
                },
              );
            }).toList(),
          ),
        ),

        // Grade de aplicativos
        Center(
          child: AnimatedSwitcher(
            duration: const Duration(milliseconds: 500),
            child: SizedBox(
              key: ValueKey<String>(_selectedCategory),
              width: 1600,
              child: filteredApps.isEmpty
                  ? Center(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(vertical: 50),
                        child: Column(
                          children: [
                            Icon(
                              Icons.search_off,
                              size: 48,
                              color: Colors.grey.shade400,
                            ),
                            const SizedBox(height: 16),
                            Text(
                              'Nenhum aplicativo encontrado nesta categoria',
                              style: TextStyle(
                                color: Colors.grey.shade600,
                                fontSize: 18,
                              ),
                            ),
                          ],
                        ),
                      ),
                    )
                  : AlignedGridView.count(
                      crossAxisCount: MediaQuery.of(context).size.width < 600
                          ? 1
                          : MediaQuery.of(context).size.width < 900
                              ? 2
                              : 3,
                      mainAxisSpacing: 20,
                      crossAxisSpacing: 20,
                      itemCount: filteredApps.length,
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemBuilder: (context, index) {
                        final app = filteredApps[index];
                        return _buildAppCard(app);
                      },
                    ),
            ),
          ),
        )
      ],
    );
  }

  Widget _buildAppCard(Map<String, dynamic> app) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            offset: const Offset(0, 4),
            blurRadius: 15,
          ),
        ],
      ),
      child: Card(
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Imagem de cabeçalho do app
            Stack(
              children: [
                ClipRRect(
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(16),
                    topRight: Radius.circular(16),
                  ),
                  child:
                      app.containsKey('linkImage') && app['linkImage'] != null
                          ? Image.network(
                              app['linkImage'],
                              height: 180,
                              width: double.infinity,
                              fit: BoxFit.cover,
                              errorBuilder: (context, error, stackTrace) {
                                return Container(
                                  height: 180,
                                  color: app['color'].withValues(alpha: 0.1),
                                  child: Center(
                                    child: Icon(
                                      app['icon'],
                                      size: 64,
                                      color: app['color'],
                                    ),
                                  ),
                                );
                              },
                            )
                          : Container(
                              height: 180,
                              color: app['color'].withValues(alpha: 0.1),
                              child: Center(
                                child: Icon(
                                  app['icon'],
                                  size: 64,
                                  color: app['color'],
                                ),
                              ),
                            ),
                ),

                // Status tag (disponível ou em desenvolvimento)
                Positioned(
                  top: 16,
                  right: 16,
                  child: Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: app['link'] == ''
                          ? Colors.amber.withValues(alpha: 0.9)
                          : Colors.green.shade700.withValues(alpha: 0.9),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          app['link'] == ''
                              ? Icons.hourglass_empty
                              : Icons.check_circle_outline,
                          size: 16,
                          color: Colors.white,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          app['link'] == ''
                              ? 'Em desenvolvimento'
                              : 'Disponível',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),

            // Conteúdo do card
            Padding(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Tags do aplicativo
                  if (app.containsKey('tags') && app['tags'] != null)
                    Wrap(
                      spacing: 6,
                      runSpacing: 6,
                      children: (app['tags'] as List).map<Widget>((tag) {
                        return Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 10, vertical: 4),
                          decoration: BoxDecoration(
                            color: app['color'].withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            tag,
                            style: TextStyle(
                              fontSize: 12,
                              color: app['color'],
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        );
                      }).toList(),
                    ),
                  const SizedBox(height: 16),

                  // Título do aplicativo
                  Text(
                    app['title'],
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),

                  // Público alvo
                  Row(
                    children: [
                      Icon(
                        Icons.people_outline,
                        size: 16,
                        color: Colors.grey[600],
                      ),
                      const SizedBox(width: 6),
                      Text(
                        app['target'],
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.grey[600],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),

                  // Descrição
                  Text(
                    app['description'],
                    style: TextStyle(
                      fontSize: 16,
                      height: 1.5,
                      color: Colors.grey[800],
                    ),
                  ),
                  const SizedBox(height: 24),

                  // Botão de ação
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: app['link'] == ''
                          ? null
                          : () async {
                              final url = app['link'];
                              if (await canLaunchUrl(Uri.parse(url))) {
                                await launchUrl(Uri.parse(url));
                              }
                            },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: app['color'],
                        foregroundColor: Colors.white,
                        disabledBackgroundColor: Colors.grey.shade300,
                        disabledForegroundColor: Colors.grey.shade600,
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: Text(
                        app['link'] == '' ? 'Em breve' : 'Acessar aplicativo',
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

}
