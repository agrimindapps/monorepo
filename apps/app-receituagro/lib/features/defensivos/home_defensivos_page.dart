import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import '../../core/widgets/modern_header_widget.dart';
import 'lista_defensivos_page.dart';
import 'lista_defensivos_agrupados_page.dart';

class HomeDefensivosPage extends StatelessWidget {
  const HomeDefensivosPage({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final size = MediaQuery.of(context).size;
    final isSmallDevice = size.width < 360;
    final isMediumDevice = size.width >= 360 && size.width < 600;
    
    return Scaffold(
      body: SafeArea(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 800),
          child: SingleChildScrollView(
            child: Column(
              children: [
                ModernHeaderWidget(
                  title: 'Defensivos',
                  subtitle: 'Produtos e informações defensivos',
                  leftIcon: Icons.shield_outlined,
                  isDark: isDark,
                  showBackButton: false,
                  showActions: false,
                ),
                
                const SizedBox(height: 16),
                
                _buildCategoriesSection(context, isSmallDevice, isMediumDevice),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildCategoriesSection(BuildContext context, bool isSmallDevice, bool isMediumDevice) {
    final standardColor = const Color(0xFF2E7D32);
    
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 8),
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: LayoutBuilder(
          builder: (context, constraints) {
            final useVerticalLayout = isSmallDevice || constraints.maxWidth < 320;
            final buttonWidth = useVerticalLayout 
                ? constraints.maxWidth - 32 
                : (constraints.maxWidth - 48) / 2;
            
            return useVerticalLayout 
              ? _buildVerticalLayout(context, buttonWidth, standardColor)
              : _buildHorizontalLayout(context, buttonWidth, standardColor);
          },
        ),
      ),
    );
  }

  Widget _buildVerticalLayout(BuildContext context, double buttonWidth, Color standardColor) {
    return Column(
      children: [
        _buildCategoryButton(
          'Defensivos',
          FontAwesomeIcons.sprayCan,
          standardColor,
          buttonWidth,
          () => _navigateToCategory(context, 'defensivos'),
        ),
        const SizedBox(height: 12),
        _buildCategoryButton(
          'Fabricantes',
          FontAwesomeIcons.industry,
          standardColor,
          buttonWidth,
          () => _navigateToCategory(context, 'fabricantes'),
        ),
        const SizedBox(height: 12),
        _buildCategoryButton(
          'Modo de Ação',
          FontAwesomeIcons.bullseye,
          standardColor,
          buttonWidth,
          () => _navigateToCategory(context, 'modoAcao'),
        ),
        const SizedBox(height: 12),
        _buildCategoryButton(
          'Ingrediente Ativo',
          FontAwesomeIcons.flask,
          standardColor,
          buttonWidth,
          () => _navigateToCategory(context, 'ingredienteAtivo'),
        ),
        const SizedBox(height: 12),
        _buildCategoryButton(
          'Classe Agronômica',
          FontAwesomeIcons.seedling,
          standardColor,
          buttonWidth,
          () => _navigateToCategory(context, 'classeAgronomica'),
        ),
      ],
    );
  }

  Widget _buildHorizontalLayout(BuildContext context, double buttonWidth, Color standardColor) {
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            _buildCategoryButton(
              'Defensivos',
              FontAwesomeIcons.sprayCan,
              standardColor,
              buttonWidth,
              () => _navigateToCategory(context, 'defensivos'),
            ),
            _buildCategoryButton(
              'Fabricantes',
              FontAwesomeIcons.industry,
              standardColor,
              buttonWidth,
              () => _navigateToCategory(context, 'fabricantes'),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            _buildCategoryButton(
              'Modo de Ação',
              FontAwesomeIcons.bullseye,
              standardColor,
              buttonWidth,
              () => _navigateToCategory(context, 'modoAcao'),
            ),
            _buildCategoryButton(
              'Ingrediente Ativo',
              FontAwesomeIcons.flask,
              standardColor,
              buttonWidth,
              () => _navigateToCategory(context, 'ingredienteAtivo'),
            ),
          ],
        ),
        const SizedBox(height: 12),
        _buildCategoryButton(
          'Classe Agronômica',
          FontAwesomeIcons.seedling,
          standardColor,
          buttonWidth,
          () => _navigateToCategory(context, 'classeAgronomica'),
        ),
      ],
    );
  }

  Widget _buildCategoryButton(
    String title,
    IconData icon,
    Color color,
    double width,
    VoidCallback onTap,
  ) {
    return SizedBox(
      width: width,
      child: Card(
        elevation: 3,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        child: InkWell(
          borderRadius: BorderRadius.circular(12),
          onTap: onTap,
          child: Container(
            padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 16),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12),
              gradient: LinearGradient(
                colors: [
                  color.withValues(alpha: 0.1),
                  color.withValues(alpha: 0.05),
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: color.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: FaIcon(
                    icon,
                    size: 24,
                    color: color,
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: color,
                  ),
                  textAlign: TextAlign.center,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
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