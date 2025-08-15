import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import '../../core/widgets/modern_header_widget.dart';
import 'lista_defensivos_page.dart';
import '../DetalheDefensivos/detalhe_defensivo_page.dart';
import 'lista_defensivos_agrupados_page.dart';

class HomeDefensivosPage extends StatelessWidget {
  const HomeDefensivosPage({super.key});

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
              background: _buildHeader(context),
            ),
            automaticallyImplyLeading: false,
          ),
          SliverToBoxAdapter(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 20),
                _buildStatsGrid(context),
                const SizedBox(height: 24),
                _buildRecentAccessSection(context),
                const SizedBox(height: 24),
                _buildNewItemsSection(context),
                const SizedBox(height: 80), // Espaço para bottom navigation
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
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
              Icons.shield_outlined,
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
                  'Defensivos',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(height: 2),
                Text(
                  '3148 Registros',
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

  Widget _buildStatsGrid(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        children: [
          Row(
            children: [
              Expanded(
                child: _buildStatCard(
                  '3148',
                  'Defensivos',
                  FontAwesomeIcons.sprayCan,
                  () => _navigateToCategory(context, 'defensivos'),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildStatCard(
                  '233',
                  'Fabricantes',
                  FontAwesomeIcons.industry,
                  () => _navigateToCategory(context, 'fabricantes'),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: _buildStatCard(
                  '98',
                  'Modo de Ação',
                  FontAwesomeIcons.bullseye,
                  () => _navigateToCategory(context, 'modoAcao'),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildStatCard(
                  '671',
                  'Ingrediente Ativo',
                  FontAwesomeIcons.flask,
                  () => _navigateToCategory(context, 'ingredienteAtivo'),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          _buildStatCard(
            '43',
            'Classe Agronômica',
            FontAwesomeIcons.seedling,
            () => _navigateToCategory(context, 'classeAgronomica'),
            isFullWidth: true,
          ),
        ],
      ),
    );
  }

  Widget _buildStatCard(
    String number,
    String label,
    IconData icon,
    VoidCallback onTap, {
    bool isFullWidth = false,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [Color(0xFF4CAF50), Color(0xFF66BB6A)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                FaIcon(
                  icon,
                  color: Colors.white,
                  size: 24,
                ),
                Container(
                  padding: const EdgeInsets.all(4),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: const Icon(
                    Icons.arrow_upward,
                    color: Colors.white,
                    size: 12,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              number,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 32,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              label,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 14,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
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
            _buildListItem(
              context,
              'Alion',
              'Indaziflam',
              'Herbicida',
              FontAwesomeIcons.leaf,
              fabricante: 'Bayer',
            ),
            _buildListItem(
              context,
              'Mojiave',
              'Glifosato - Sal de Potássio + Glifos...',
              'Herbicida',
              FontAwesomeIcons.leaf,
              fabricante: 'Syngenta',
            ),
            _buildListItem(
              context,
              '2,4-D Crop 806 SL',
              '2,4-D + Equivalente ácido de 2,4-D',
              'Herbicida',
              FontAwesomeIcons.leaf,
              fabricante: 'Crop',
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildNewItemsSection(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Novos Defensivos',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF4CAF50),
                ),
              ),
              IconButton(
                onPressed: () {},
                icon: const Icon(
                  Icons.settings,
                  color: Color(0xFF4CAF50),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 12),
        Column(
          children: [
            _buildListItem(
              context,
              'Lungo',
              'Baculovírus Spodoptera frugiperda...',
              'Inseticida microbiológico',
              FontAwesomeIcons.bug,
              fabricante: 'FMC',
            ),
            _buildListItem(
              context,
              'BT-Turbo Max',
              'Bacillus thuringiensis var. kurstaki ...',
              'Inseticida microbiológico',
              FontAwesomeIcons.bug,
              fabricante: 'Sumitomo',
            ),
            _buildListItem(
              context,
              'BLOWOUT, CLEANOVER',
              'Dibrometo de diquate',
              'Herbicida',
              FontAwesomeIcons.leaf,
              fabricante: 'Syngenta',
            ),
            _buildListItem(
              context,
              'Biagro Solo',
              'Mix de microrganismos',
              'Fungicida biológico',
              FontAwesomeIcons.seedling,
              fabricante: 'Biagro',
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildListItem(BuildContext context, String title, String subtitle, String category, IconData icon, {String fabricante = 'Fabricante'}) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      child: InkWell(
        onTap: () => _navigateToDefensivoDetails(context, title, fabricante),
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
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: const Color(0xFF4CAF50).withOpacity(0.1),
              borderRadius: BorderRadius.circular(10),
            ),
            child: FaIcon(
              icon,
              color: const Color(0xFF4CAF50),
              size: 20,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: Colors.black87,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  subtitle,
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey[600],
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 4),
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
          ),
          const Icon(
            Icons.chevron_right,
            color: Colors.grey,
          ),
        ],
          ),
        ),
      ),
    );
  }

  void _navigateToDefensivoDetails(BuildContext context, String defensivoName, String fabricante) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => DetalheDefensivoPage(
          defensivoName: defensivoName,
          fabricante: fabricante,
        ),
      ),
    );
  }

  void _navigateToCategory(BuildContext context, String category) {
    if (category == 'defensivos') {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => const ListaDefensivosPage(),
        ),
      );
    } else {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => ListaDefensivosAgrupadosPage(
            tipoAgrupamento: category,
          ),
        ),
      );
    }
  }
}