import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import '../../core/widgets/modern_header_widget.dart';
import '../culturas/lista_culturas_page.dart';
import 'lista_pragas_page.dart';

class HomePragasPage extends StatelessWidget {
  const HomePragasPage({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final size = MediaQuery.of(context).size;
    final isSmallDevice = size.width < 360;
    
    return Scaffold(
      body: SafeArea(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 800),
          child: SingleChildScrollView(
            child: Column(
              children: [
                ModernHeaderWidget(
                  title: 'Pragas e Doenças',
                  subtitle: 'Identificação e controle de pragas',
                  leftIcon: Icons.bug_report_outlined,
                  isDark: isDark,
                  showBackButton: false,
                  showActions: false,
                ),
                
                const SizedBox(height: 16),
                
                _buildCategoriesSection(context, isSmallDevice),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildCategoriesSection(BuildContext context, bool isSmallDevice) {
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
            final availableWidth = constraints.maxWidth;
            final screenWidth = MediaQuery.of(context).size.width;
            final useVerticalLayout = isSmallDevice || availableWidth < 320;
            final isMediumDevice = screenWidth >= 360 && screenWidth < 600;
            
            return useVerticalLayout 
              ? _buildVerticalLayout(context, availableWidth, standardColor)
              : _buildGridLayout(context, availableWidth, standardColor, isMediumDevice);
          },
        ),
      ),
    );
  }

  Widget _buildVerticalLayout(BuildContext context, double availableWidth, Color standardColor) {
    final buttonWidth = availableWidth - 16;
    
    return Column(
      children: [
        _buildCategoryButton(
          'Insetos',
          FontAwesomeIcons.bug,
          standardColor,
          buttonWidth,
          () => _navigateToCategory(context, 'insetos'),
          '45',
        ),
        const SizedBox(height: 12),
        _buildCategoryButton(
          'Doenças',
          FontAwesomeIcons.virus,
          standardColor,
          buttonWidth,
          () => _navigateToCategory(context, 'doencas'),
          '32',
        ),
        const SizedBox(height: 12),
        _buildCategoryButton(
          'Plantas Daninhas',
          FontAwesomeIcons.seedling,
          standardColor,
          buttonWidth,
          () => _navigateToCategory(context, 'plantas_daninhas'),
          '28',
        ),
        const SizedBox(height: 12),
        _buildCategoryButton(
          'Culturas',
          FontAwesomeIcons.wheatAwn,
          standardColor,
          buttonWidth,
          () => _navigateToCategory(context, 'culturas'),
          '15',
        ),
      ],
    );
  }

  Widget _buildGridLayout(BuildContext context, double availableWidth, Color standardColor, bool isMediumDevice) {
    final buttonWidth = isMediumDevice 
        ? (availableWidth - 32) / 3 
        : (availableWidth - 40) / 3;
    
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            _buildCategoryButton(
              'Insetos',
              FontAwesomeIcons.bug,
              standardColor,
              buttonWidth,
              () => _navigateToCategory(context, 'insetos'),
              '45',
            ),
            const SizedBox(width: 8),
            _buildCategoryButton(
              'Doenças',
              FontAwesomeIcons.virus,
              standardColor,
              buttonWidth,
              () => _navigateToCategory(context, 'doencas'),
              '32',
            ),
            const SizedBox(width: 8),
            _buildCategoryButton(
              'Plantas',
              FontAwesomeIcons.seedling,
              standardColor,
              buttonWidth,
              () => _navigateToCategory(context, 'plantas_daninhas'),
              '28',
            ),
          ],
        ),
        const SizedBox(height: 12),
        _buildCategoryButton(
          'Culturas',
          FontAwesomeIcons.wheatAwn,
          standardColor,
          isMediumDevice ? availableWidth - 16 : availableWidth * 0.75,
          () => _navigateToCategory(context, 'culturas'),
          '15',
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
    String count,
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
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      FaIcon(
                        icon,
                        size: 20,
                        color: color,
                      ),
                      const SizedBox(width: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                        decoration: BoxDecoration(
                          color: color.withValues(alpha: 0.2),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          count,
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                            color: color,
                          ),
                        ),
                      ),
                    ],
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
    if (category == 'culturas') {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => const ListaCulturasPage(),
        ),
      );
    } else if (category == 'insetos') {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => const ListaPragasPage(pragaType: '1'),
        ),
      );
    } else if (category == 'doencas') {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => const ListaPragasPage(pragaType: '2'),
        ),
      );
    } else if (category == 'plantas_daninhas') {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => const ListaPragasPage(pragaType: '3'),
        ),
      );
    } else {
      debugPrint('Navegar para: $category');
    }
  }
}