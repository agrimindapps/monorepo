import 'package:flutter/material.dart';

class PragasPage extends StatefulWidget {
  const PragasPage({super.key});

  @override
  State<PragasPage> createState() => _PragasPageState();
}

class _PragasPageState extends State<PragasPage> {
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return Scaffold(
      appBar: AppBar(
        title: const Text('🐛 Pragas'),
        centerTitle: true,
        elevation: 2,
        actions: [
          IconButton(
            icon: const Icon(Icons.search),
            onPressed: () {
              // TODO: Implementar busca
            },
            tooltip: 'Buscar pragas',
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header Card
            Card(
              elevation: 4,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(16),
                  gradient: LinearGradient(
                    colors: [theme.colorScheme.primary, theme.colorScheme.primaryContainer],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                ),
                child: Column(
                  children: [
                    const Icon(
                      Icons.bug_report,
                      color: Colors.white,
                      size: 48,
                    ),
                    const SizedBox(height: 16),
                    const Text(
                      'Pragas da Soja',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Identificação e manejo integrado de pragas',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: Colors.white.withValues(alpha: 0.9),
                        fontSize: 16,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            
            const SizedBox(height: 24),
            
            // Quick Access Section
            const Text(
              'Acesso Rápido',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
            ),
            
            const SizedBox(height: 16),
            
            // Quick Access Cards
            Row(
              children: [
                Expanded(
                  child: _buildQuickAccessCard(
                    'Diagnosticar',
                    Icons.search,
                    Colors.blue.shade600,
                    'Identifique pragas',
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: _buildQuickAccessCard(
                    'Listar Todas',
                    Icons.list,
                    Colors.green.shade600,
                    'Ver todas as pragas',
                  ),
                ),
              ],
            ),
            
            const SizedBox(height: 24),
            
            // Common Pests Section
            const Text(
              'Pragas Mais Comuns',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
            ),
            
            const SizedBox(height: 16),
            
            // Pest List
            ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: _commonPests.length,
              itemBuilder: (context, index) {
                final pest = _commonPests[index];
                return _buildPestCard(pest);
              },
            ),
            
            const SizedBox(height: 24),
            
            // Coming Soon Card
            Card(
              elevation: 2,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  children: [
                    Icon(
                      Icons.science,
                      size: 48,
                      color: Colors.grey.shade600,
                    ),
                    const SizedBox(height: 16),
                    const Text(
                      'Base de Dados Completa',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.black87,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Em breve: mais de 100 pragas catalogadas com fotos, descrições e tratamentos!',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: Colors.grey.shade600,
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildQuickAccessCard(
    String title,
    IconData icon,
    Color color,
    String description,
  ) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: () {
          // TODO: Implementar ação
        },
        child: Container(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              Icon(
                icon,
                size: 32,
                color: color,
              ),
              const SizedBox(height: 8),
              Text(
                title,
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: color,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                description,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey.shade600,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPestCard(Map<String, dynamic> pest) {
    return Card(
      elevation: 2,
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.all(16),
        leading: CircleAvatar(
          backgroundColor: pest['color'].withValues(alpha: 0.1),
          child: Icon(
            pest['icon'],
            color: pest['color'],
          ),
        ),
        title: Text(
          pest['name'],
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 16,
          ),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 4),
            Text(
              pest['scientificName'],
              style: TextStyle(
                fontStyle: FontStyle.italic,
                color: Colors.grey.shade600,
                fontSize: 12,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              pest['description'],
              style: const TextStyle(fontSize: 14),
            ),
          ],
        ),
        trailing: Icon(
          Icons.chevron_right,
          color: Colors.grey.shade400,
        ),
        onTap: () {
          // TODO: Navegar para detalhes da praga
        },
      ),
    );
  }

  // Dados mock de pragas comuns
  List<Map<String, dynamic>> get _commonPests => [
    {
      'name': 'Lagarta-da-soja',
      'scientificName': 'Anticarsia gemmatalis',
      'description': 'Principal desfolhadora da cultura da soja',
      'icon': Icons.bug_report,
      'color': Colors.green.shade700,
    },
    {
      'name': 'Percevejo-marrom',
      'scientificName': 'Euschistus heros',
      'description': 'Sugador de vagens e grãos',
      'icon': Icons.coronavirus,
      'color': Colors.brown.shade600,
    },
    {
      'name': 'Mosca-branca',
      'scientificName': 'Bemisia tabaci',
      'description': 'Transmissora de viroses',
      'icon': Icons.air,
      'color': Colors.grey.shade600,
    },
    {
      'name': 'Ácaro-rajado',
      'scientificName': 'Tetranychus urticae',
      'description': 'Sugador de folhas',
      'icon': Icons.scatter_plot,
      'color': Colors.red.shade600,
    },
  ];
}