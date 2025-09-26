import 'package:flutter/material.dart';

import '../../../../core/design/design_tokens.dart';
import '../../../../core/widgets/praga_image_widget.dart';
import '../../detalhe_praga_page.dart';
import '../providers/home_pragas_provider.dart';

/// Widget para exibir seção de sugestões com carrossel na home de pragas
/// 
/// Responsabilidades:
/// - Exibir carrossel de pragas sugeridas
/// - Controlar indicadores de página (dots)
/// - Navegação para detalhes da praga
/// - Estados vazio e loading
class HomePragasSuggestionsWidget extends StatefulWidget {
  final HomePragasProvider provider;

  const HomePragasSuggestionsWidget({
    super.key,
    required this.provider,
  });

  @override
  State<HomePragasSuggestionsWidget> createState() => _HomePragasSuggestionsWidgetState();
}

class _HomePragasSuggestionsWidgetState extends State<HomePragasSuggestionsWidget> {
  final PageController _pageController = PageController(viewportFraction: 0.6);

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Header da seção
        Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: ReceitaAgroSpacing.horizontalPadding,
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Sugestões',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: theme.colorScheme.primary,
                ),
              ),
              IconButton(
                onPressed: () {},
                icon: Icon(
                  Icons.lightbulb_outline,
                  color: theme.colorScheme.primary,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 12),
        
        // Carrossel
        _buildCarousel(context),
        
        const SizedBox(height: 12),
        
        // Indicadores de página
        _buildDotIndicators(context),
      ],
    );
  }

  Widget _buildCarousel(BuildContext context) {
    final suggestions = widget.provider.getSuggestionsList();
    
    if (suggestions.isEmpty) {
      return _buildEmptyCarousel(context);
    }

    return Container(
      height: 280,
      padding: const EdgeInsets.only(left: 0),
      child: PageView.builder(
        controller: _pageController,
        itemCount: suggestions.length,
        onPageChanged: (index) {
          widget.provider.updateCarouselIndex(index);
        },
        itemBuilder: (context, index) {
          final suggestion = suggestions[index];
          return _buildCarouselItem(context, suggestion, index);
        },
      ),
    );
  }

  Widget _buildCarouselItem(BuildContext context, Map<String, dynamic> suggestion, int index) {
    return Container(
      margin: EdgeInsets.only(
        left: index == 0 ? 0 : ReceitaAgroSpacing.horizontalPadding,
        right: ReceitaAgroSpacing.xs + 1,
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(12),
        child: Stack(
          children: [
            _buildItemBackground(context, suggestion),
            _buildGradientOverlay(context, suggestion),
            _buildTouchLayer(context, suggestion),
          ],
        ),
      ),
    );
  }

  Widget _buildItemBackground(BuildContext context, Map<String, dynamic> suggestion) {
    final theme = Theme.of(context);
    
    return SizedBox(
      width: double.infinity,
      height: double.infinity,
      child: PragaImageWidget(
        nomeCientifico: suggestion['scientific'] as String,
        width: double.infinity,
        height: double.infinity,
        fit: BoxFit.cover,
        borderRadius: BorderRadius.circular(12),
        errorWidget: Container(
          width: double.infinity,
          height: double.infinity,
          decoration: BoxDecoration(
            color: _getColorForType(suggestion['type'] as String, context).withValues(alpha: 0.8),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Center(
            child: Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                color: theme.colorScheme.onPrimary.withValues(alpha: 0.2),
                borderRadius: BorderRadius.circular(40),
              ),
              child: Center(
                child: Text(
                  suggestion['emoji'] as String,
                  style: const TextStyle(fontSize: 48),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildGradientOverlay(BuildContext context, Map<String, dynamic> suggestion) {
    return Positioned(
      bottom: 0,
      left: 0,
      right: 0,
      child: Container(
        decoration: BoxDecoration(
          borderRadius: const BorderRadius.only(
            bottomLeft: Radius.circular(12),
            bottomRight: Radius.circular(12),
          ),
          gradient: LinearGradient(
            begin: Alignment.bottomCenter,
            end: Alignment.topCenter,
            colors: [
              Colors.black.withValues(alpha: 0.8),
              Colors.black.withValues(alpha: 0.3),
              Colors.transparent,
            ],
            stops: const [0.0, 0.5, 1.0],
          ),
        ),
        padding: const EdgeInsets.all(ReceitaAgroSpacing.lg),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              suggestion['name'] as String,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.bold,
                shadows: [
                  Shadow(
                    blurRadius: 2.0,
                    color: Colors.black,
                    offset: Offset(0, 1),
                  ),
                ],
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 2),
            Text(
              suggestion['scientific'] as String,
              style: TextStyle(
                color: Colors.white.withValues(alpha: 0.9),
                fontSize: 14,
                fontStyle: FontStyle.italic,
                shadows: const [
                  Shadow(
                    blurRadius: 2.0,
                    color: Colors.black,
                    offset: Offset(0, 1),
                  ),
                ],
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 6),
            _buildTypeTag(context, suggestion),
          ],
        ),
      ),
    );
  }

  Widget _buildTypeTag(BuildContext context, Map<String, dynamic> suggestion) {
    IconData icon;
    Color backgroundColor;
    
    switch (suggestion['type'] as String) {
      case 'Inseto':
        icon = Icons.bug_report;
        backgroundColor = Colors.red.withValues(alpha: 0.9);
        break;
      case 'Doença':
        icon = Icons.coronavirus;
        backgroundColor = Colors.orange.withValues(alpha: 0.9);
        break;
      case 'Planta':
        icon = Icons.grass;
        backgroundColor = Colors.green.withValues(alpha: 0.9);
        break;
      default:
        icon = Icons.help;
        backgroundColor = Colors.grey.withValues(alpha: 0.9);
    }
    
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: ReceitaAgroSpacing.sm,
        vertical: ReceitaAgroSpacing.xs,
      ),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.2),
            blurRadius: 2,
            offset: const Offset(0, 1),
          ),
        ],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            icon,
            color: Colors.white,
            size: 14,
          ),
          const SizedBox(width: 4),
          Text(
            suggestion['type'] as String,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 12,
              fontWeight: FontWeight.w600,
              shadows: [
                Shadow(
                  blurRadius: 1.0,
                  color: Colors.black,
                  offset: Offset(0, 0.5),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTouchLayer(BuildContext context, Map<String, dynamic> suggestion) {
    return Positioned.fill(
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () => _navigateToPragaDetails(
            context,
            suggestion['name'] as String,
            suggestion['scientific'] as String,
            suggestion['id'] as String, // Pass ID for better precision
          ),
          splashColor: Theme.of(context).colorScheme.surface.withValues(alpha: 0.1),
          highlightColor: Colors.transparent,
        ),
      ),
    );
  }

  Widget _buildDotIndicators(BuildContext context) {
    final suggestions = widget.provider.getSuggestionsList();
    
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: suggestions.asMap().entries.map((entry) {
        return GestureDetector(
          onTap: () => _pageController.animateToPage(
            entry.key,
            duration: const Duration(milliseconds: 300),
            curve: Curves.easeInOut,
          ),
          child: Container(
            width: 8.0,
            height: 8.0,
            margin: const EdgeInsets.symmetric(
              horizontal: ReceitaAgroSpacing.xs,
            ),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: widget.provider.currentCarouselIndex == entry.key
                  ? Theme.of(context).colorScheme.primary
                  : Theme.of(context).colorScheme.primary.withValues(alpha: 0.3),
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildEmptyCarousel(BuildContext context) {
    final theme = Theme.of(context);
    
    return Container(
      height: 280,
      margin: const EdgeInsets.symmetric(
        horizontal: ReceitaAgroSpacing.horizontalPadding,
      ),
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainerLowest,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.search_off,
              size: 64,
              color: theme.colorScheme.onSurfaceVariant,
            ),
            const SizedBox(height: 16),
            Text(
              'Nenhuma sugestão disponível',
              style: TextStyle(
                color: theme.colorScheme.onSurfaceVariant,
                fontSize: 16,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Color _getColorForType(String type, BuildContext context) {
    final theme = Theme.of(context);
    switch (type.toLowerCase()) {
      case 'inseto':
        return theme.colorScheme.primary;
      case 'doença':
        return theme.colorScheme.tertiary;
      case 'planta':
        return theme.colorScheme.secondary;
      default:
        return theme.colorScheme.primary;
    }
  }

  void _navigateToPragaDetails(BuildContext context, String pragaName, String scientificName, String pragaId) {
    Navigator.push(
      context,
      MaterialPageRoute<void>(
        builder: (context) => DetalhePragaPage(
          pragaName: pragaName,
          pragaId: pragaId, // Use ID for better precision
          pragaScientificName: scientificName,
        ),
      ),
    );
  }
}