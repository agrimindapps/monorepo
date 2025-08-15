import 'package:flutter/material.dart';
import 'detalhe_praga_page.dart';

class HomePragasPage extends StatelessWidget {
  const HomePragasPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            expandedHeight: 120,
            floating: false,
            pinned: true,
            backgroundColor: const Color(0xFF4CAF50),
            flexibleSpace: FlexibleSpaceBar(
              background: _buildHeader(),
            ),
            automaticallyImplyLeading: false,
          ),
          SliverToBoxAdapter(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 20),
                _buildRecentAccessSection(context),
                const SizedBox(height: 80), // Espaço para bottom navigation
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.fromLTRB(20, 60, 20, 20),
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [Color(0xFF4CAF50), Color(0xFF66BB6A)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.2),
              borderRadius: BorderRadius.circular(8),
            ),
            child: const Icon(
              Icons.pest_control,
              color: Colors.white,
              size: 24,
            ),
          ),
          const SizedBox(width: 12),
          const Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  'Pragas e Doenças',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(height: 2),
                Text(
                  'Identifique e controle 1139 pragas',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 14,
                    fontWeight: FontWeight.w400,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRecentAccessSection(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Últimos Acessados',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF4CAF50),
                ),
              ),
              IconButton(
                onPressed: () {},
                icon: const Icon(
                  Icons.history,
                  color: Color(0xFF4CAF50),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 12),
        Column(
          children: [
            _buildPragaItem(
              context,
              'Podridão',
              'Phoma exigua var. exigua',
              'Doença',
              Colors.brown[700]!,
              '🟤', // Emoji como placeholder para imagem
            ),
            _buildPragaItem(
              context,
              'Broca',
              'Etiella zinckenella',
              'Inseto',
              Colors.orange[800]!,
              '🐛',
            ),
            _buildPragaItem(
              context,
              'Besouro',
              'Cathartus quadricollis',
              'Inseto',
              Colors.red[700]!,
              '🪲',
            ),
            _buildPragaItem(
              context,
              'Lagarta',
              'Bonagota cranaodes',
              'Inseto',
              Colors.green[700]!,
              '🐛',
            ),
            _buildPragaItem(
              context,
              'Tripes',
              'Thrips palmi',
              'Inseto',
              Colors.yellow[700]!,
              '🦗',
            ),
            _buildPragaItem(
              context,
              'Erva',
              'Polygonum aviculare',
              'Planta',
              Colors.green[600]!,
              '🌿',
            ),
            _buildPragaItem(
              context,
              'Apaga',
              'Alternanthera tenella',
              'Planta',
              Colors.green[800]!,
              '🌱',
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildPragaItem(BuildContext context, String name, String scientificName, String category, Color categoryColor, String emoji) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      child: InkWell(
        onTap: () => _navigateToPragaDetails(context, name, scientificName),
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(
                color: Colors.grey.withOpacity(0.1),
                spreadRadius: 1,
                blurRadius: 4,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Row(
            children: [
              // Foto/Imagem circular
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: categoryColor.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: Center(
                  child: Text(
                    emoji,
                    style: const TextStyle(fontSize: 24),
                  ),
                ),
              ),
              const SizedBox(width: 16),
              // Conteúdo principal
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Nome da praga
                    Text(
                      name,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: Colors.black87,
                      ),
                    ),
                    const SizedBox(height: 4),
                    // Nome científico
                    Text(
                      scientificName,
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey[600],
                        fontStyle: FontStyle.italic,
                      ),
                    ),
                    const SizedBox(height: 8),
                    // Tag da categoria
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                          decoration: BoxDecoration(
                            color: Colors.grey[200],
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            category,
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.grey[600],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              // Seta à direita
              const Icon(
                Icons.chevron_right,
                color: Colors.grey,
                size: 20,
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _navigateToPragaDetails(BuildContext context, String pragaName, String scientificName) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => DetalhePragaPage(
          pragaName: pragaName,
          pragaScientificName: scientificName,
        ),
      ),
    );
  }

}