import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/theme/design_tokens.dart';
import '../../../../core/widgets/praga_image_widget.dart';
import '../pages/detalhe_praga_page.dart';
import '../providers/home_pragas_notifier.dart';
import '../providers/pragas_providers.dart';

/// Widget para exibir seção de sugestões com CarouselView NATIVO do Flutter
///
/// Usa o novo CarouselView introduzido no Flutter 3.16+
/// Esta é uma versão experimental para comparação com o PageView.builder
class HomePragasSuggestionsNativeWidget extends ConsumerStatefulWidget {
  final HomePragasState state;

  const HomePragasSuggestionsNativeWidget({super.key, required this.state});

  @override
  ConsumerState<HomePragasSuggestionsNativeWidget> createState() =>
      _HomePragasSuggestionsNativeWidgetState();
}

class _HomePragasSuggestionsNativeWidgetState
    extends ConsumerState<HomePragasSuggestionsNativeWidget> {
  final CarouselController _carouselController = CarouselController();

  @override
  void dispose() {
    _carouselController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildHeader(theme),
        const SizedBox(height: 12),
        _buildCarousel(context),
        const SizedBox(height: 12),
        _buildDotIndicators(context),
      ],
    );
  }

  Widget _buildHeader(ThemeData theme) {
    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: ReceitaAgroSpacing.horizontalPadding,
      ),
      child: Row(
        children: [
          Container(
            width: 4,
            height: 24,
            decoration: BoxDecoration(
              color: theme.colorScheme.primary,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              'Sugestões',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: theme.colorScheme.primary,
              ),
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
    );
  }

  Widget _buildCarousel(BuildContext context) {
    final typeService = ref.read(pragasTypeServiceProvider);
    final suggestions = widget.state.getSuggestionsList(typeService);

    if (suggestions.isEmpty) {
      return _buildEmptyCarousel(context);
    }

    return ConstrainedBox(
      constraints: const BoxConstraints(maxHeight: 280),
      child: CarouselView(
        controller: _carouselController,
        itemExtent: MediaQuery.of(context).size.width * 0.65,
        shrinkExtent: MediaQuery.of(context).size.width * 0.55,
        itemSnapping: true,
        padding: const EdgeInsets.symmetric(
          horizontal: ReceitaAgroSpacing.horizontalPadding,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        onTap: (index) {
          final suggestion = suggestions[index];
          _navigateToPragaDetails(
            context,
            suggestion['name'] as String,
            suggestion['scientific'] as String,
            suggestion['id'] as String,
          );
        },
        children: suggestions.asMap().entries.map((entry) {
          return _buildCarouselItem(context, entry.value, entry.key);
        }).toList(),
      ),
    );
  }

  Widget _buildCarouselItem(
    BuildContext context,
    Map<String, dynamic> suggestion,
    int index,
  ) {
    return Stack(
      fit: StackFit.expand,
      children: [
        _buildItemBackground(context, suggestion),
        _buildGradientOverlay(context, suggestion),
      ],
    );
  }

  Widget _buildItemBackground(
    BuildContext context,
    Map<String, dynamic> suggestion,
  ) {
    final theme = Theme.of(context);

    return PragaImageWidget(
      nomeCientifico: suggestion['scientific'] as String,
      width: double.infinity,
      height: double.infinity,
      fit: BoxFit.cover,
      borderRadius: BorderRadius.circular(12),
      errorWidget: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: BoxDecoration(
          color: _getColorForType(
            suggestion['type'] as String,
            context,
          ).withValues(alpha: 0.8),
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
    );
  }

  Widget _buildGradientOverlay(
    BuildContext context,
    Map<String, dynamic> suggestion,
  ) {
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
              Colors.black.withValues(alpha: 0.9),
              Colors.black.withValues(alpha: 0.5),
              Colors.transparent,
            ],
            stops: const [0.0, 0.6, 1.0],
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
      case 'Doença':
        icon = Icons.coronavirus;
        backgroundColor = Colors.orange.withValues(alpha: 0.9);
      case 'Planta Daninha':
      case 'Planta':
        icon = Icons.grass;
        backgroundColor = Colors.green.withValues(alpha: 0.9);
      default:
        icon = Icons.help;
        backgroundColor = Colors.grey.withValues(alpha: 0.9);
    }

    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: ReceitaAgroSpacing.sm,
        vertical: 4,
      ),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(8),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.3),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: Colors.white, size: 12),
          const SizedBox(width: 6),
          Text(
            suggestion['type'] as String,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 11,
              fontWeight: FontWeight.bold,
              letterSpacing: 0.5,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDotIndicators(BuildContext context) {
    final typeService = ref.read(pragasTypeServiceProvider);
    final suggestions = widget.state.getSuggestionsList(typeService);

    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: suggestions.asMap().entries.map((entry) {
        return GestureDetector(
          onTap: () {
            _carouselController.animateTo(
              entry.key.toDouble() * MediaQuery.of(context).size.width * 0.65,
              duration: const Duration(milliseconds: 300),
              curve: Curves.easeInOut,
            );
          },
          child: Container(
            width: 8.0,
            height: 8.0,
            margin: const EdgeInsets.symmetric(
              horizontal: ReceitaAgroSpacing.xs,
            ),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: widget.state.currentCarouselIndex == entry.key
                  ? Theme.of(context).colorScheme.primary
                  : Theme.of(
                      context,
                    ).colorScheme.primary.withValues(alpha: 0.3),
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
    switch (type) {
      case 'Inseto':
        return Colors.red;
      case 'Doença':
        return Colors.orange;
      case 'Planta Daninha':
      case 'Planta':
        return Colors.green;
      default:
        return Theme.of(context).colorScheme.primary;
    }
  }

  void _navigateToPragaDetails(
    BuildContext context,
    String name,
    String scientificName,
    String id,
  ) {
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (context) => DetalhePragaPage(
          pragaName: name,
          pragaId: id,
          pragaScientificName: scientificName,
        ),
      ),
    );
  }
}
