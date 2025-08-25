import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import '../../../core/widgets/optimized_praga_image_widget.dart';
import '../domain/entities/praga_entity.dart';

/// Widget otimizado para exibir cards de pragas
/// Performance máxima para listas com 1000+ itens
/// 
/// Características:
/// - Lazy loading de imagens
/// - Rendering otimizado
/// - Múltiplos modos de visualização
/// - Integração com favoritos
/// - Suporte a temas
class PragaCardWidget extends StatelessWidget {
  final PragaEntity praga;
  final PragaCardMode mode;
  final bool isDarkMode;
  final bool isFavorite;
  final VoidCallback? onTap;
  final VoidCallback? onFavoriteToggle;
  final double? customWidth;
  final double? customHeight;
  final bool showFavoriteButton;
  final bool showTypeIcon;
  final bool enableImagePreloading;

  const PragaCardWidget({
    super.key,
    required this.praga,
    this.mode = PragaCardMode.list,
    this.isDarkMode = false,
    this.isFavorite = false,
    this.onTap,
    this.onFavoriteToggle,
    this.customWidth,
    this.customHeight,
    this.showFavoriteButton = true,
    this.showTypeIcon = true,
    this.enableImagePreloading = false,
  });

  @override
  Widget build(BuildContext context) {
    return RepaintBoundary(
      child: _buildCardByMode(context),
    );
  }

  Widget _buildCardByMode(BuildContext context) {
    switch (mode) {
      case PragaCardMode.list:
        return _buildListCard(context);
      case PragaCardMode.grid:
        return _buildGridCard(context);
      case PragaCardMode.compact:
        return _buildCompactCard(context);
      case PragaCardMode.featured:
        return _buildFeaturedCard(context);
    }
  }

  /// Card no modo lista (horizontal)
  Widget _buildListCard(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      elevation: isDarkMode ? 4 : 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      color: _getCardColor(),
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: onTap,
        child: Container(
          height: customHeight ?? 120,
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              // Imagem/Ícone
              _buildImageSection(),
              const SizedBox(width: 16),
              
              // Conteúdo principal
              Expanded(
                child: _buildContentSection(),
              ),
              
              // Ações
              _buildActionSection(),
            ],
          ),
        ),
      ),
    );
  }

  /// Card no modo grid (vertical)
  Widget _buildGridCard(BuildContext context) {
    return Card(
      margin: const EdgeInsets.all(6),
      elevation: isDarkMode ? 4 : 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      color: _getCardColor(),
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: onTap,
        child: SizedBox(
          width: customWidth ?? 180,
          height: customHeight ?? 240,
          child: Column(
            children: [
              // Imagem principal
              Expanded(
                flex: 3,
                child: _buildGridImageSection(),
              ),
              
              // Conteúdo
              Expanded(
                flex: 2,
                child: Container(
                  padding: const EdgeInsets.all(12),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildGridContentSection(),
                      const Spacer(),
                      if (showFavoriteButton)
                        _buildGridActionSection(),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// Card no modo compacto (minimal)
  Widget _buildCompactCard(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      elevation: 1,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      color: _getCardColor(),
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: onTap,
        child: Container(
          height: customHeight ?? 80,
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          child: Row(
            children: [
              // Ícone ou mini imagem
              _buildCompactImageSection(),
              const SizedBox(width: 12),
              
              // Conteúdo simplificado
              Expanded(
                child: _buildCompactContentSection(),
              ),
              
              // Favorito (se habilitado)
              if (showFavoriteButton)
                _buildCompactFavoriteButton(),
            ],
          ),
        ),
      ),
    );
  }

  /// Card no modo featured (destaque)
  Widget _buildFeaturedCard(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      elevation: isDarkMode ? 6 : 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
      ),
      color: _getCardColor(),
      child: InkWell(
        borderRadius: BorderRadius.circular(20),
        onTap: onTap,
        child: SizedBox(
          height: customHeight ?? 160,
          child: Row(
            children: [
              // Imagem em destaque
              SizedBox(
                width: 140,
                child: _buildFeaturedImageSection(),
              ),
              
              // Conteúdo expandido
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: _buildFeaturedContentSection(),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ==================== SEÇÕES DE CONTEÚDO ====================

  Widget _buildImageSection() {
    return SizedBox(
      width: 80,
      height: 80,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(12),
        child: OptimizedPragaImageWidget(
          nomeCientifico: praga.nomeCientifico,
          width: 80,
          height: 80,
          fit: BoxFit.cover,
          enablePreloading: enableImagePreloading,
          errorWidget: _buildIconFallback(80),
        ),
      ),
    );
  }

  Widget _buildContentSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        // Nome principal
        Text(
          praga.nomeFormatado,
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: isDarkMode ? Colors.white : Colors.black87,
          ),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        
        const SizedBox(height: 4),
        
        // Nome científico
        if (praga.nomeCientifico.isNotEmpty)
          Text(
            praga.nomeCientifico,
            style: TextStyle(
              fontSize: 14,
              color: isDarkMode ? Colors.grey.shade300 : Colors.grey.shade600,
              fontStyle: FontStyle.italic,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        
        const SizedBox(height: 8),
        
        // Chip de tipo
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          decoration: BoxDecoration(
            color: _getTypeColor().withValues(alpha: 0.2),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: _getTypeColor().withValues(alpha: 0.5),
              width: 1,
            ),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (showTypeIcon) ...[
                FaIcon(
                  _getTypeIcon(),
                  size: 12,
                  color: _getTypeColor(),
                ),
                const SizedBox(width: 4),
              ],
              Text(
                _getTypeText(),
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                  color: _getTypeColor(),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildActionSection() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        // Botão de favorito
        if (showFavoriteButton && onFavoriteToggle != null)
          DecoratedBox(
            decoration: BoxDecoration(
              color: isFavorite 
                  ? Colors.red.withValues(alpha: 0.1)
                  : Colors.transparent,
              borderRadius: BorderRadius.circular(8),
            ),
            child: IconButton(
              icon: Icon(
                isFavorite ? Icons.favorite : Icons.favorite_border,
                color: isFavorite ? Colors.red : Colors.grey.shade500,
                size: 20,
              ),
              onPressed: onFavoriteToggle,
              padding: const EdgeInsets.all(8),
              constraints: const BoxConstraints(
                minWidth: 36,
                minHeight: 36,
              ),
            ),
          ),
        
        const SizedBox(height: 8),
        
        // Indicador de navegação
        Icon(
          Icons.chevron_right_rounded,
          color: isDarkMode ? Colors.grey.shade400 : Colors.grey.shade500,
          size: 24,
        ),
      ],
    );
  }

  Widget _buildGridImageSection() {
    return SizedBox(
      width: double.infinity,
      child: ClipRRect(
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(16),
          topRight: Radius.circular(16),
        ),
        child: Stack(
          children: [
            OptimizedPragaImageWidget(
              nomeCientifico: praga.nomeCientifico,
              width: double.infinity,
              height: double.infinity,
              fit: BoxFit.cover,
              enablePreloading: enableImagePreloading,
              errorWidget: _buildIconFallback(double.infinity),
            ),
            
            // Overlay para favorito
            if (showFavoriteButton)
              Positioned(
                top: 8,
                right: 8,
                child: _buildFloatingFavoriteButton(),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildGridContentSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Nome principal
        Text(
          praga.nomeFormatado,
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: isDarkMode ? Colors.white : Colors.black87,
          ),
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
        ),
        
        const SizedBox(height: 4),
        
        // Nome científico abreviado
        if (praga.nomeCientifico.isNotEmpty)
          Text(
            praga.nomeCientifico,
            style: TextStyle(
              fontSize: 12,
              color: isDarkMode ? Colors.grey.shade300 : Colors.grey.shade600,
              fontStyle: FontStyle.italic,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
      ],
    );
  }

  Widget _buildGridActionSection() {
    return Row(
      children: [
        // Chip de tipo compacto
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
          decoration: BoxDecoration(
            color: _getTypeColor().withValues(alpha: 0.2),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              FaIcon(
                _getTypeIcon(),
                size: 10,
                color: _getTypeColor(),
              ),
              const SizedBox(width: 3),
              Text(
                _getTypeText(),
                style: TextStyle(
                  fontSize: 10,
                  fontWeight: FontWeight.w500,
                  color: _getTypeColor(),
                ),
              ),
            ],
          ),
        ),
        const Spacer(),
      ],
    );
  }

  Widget _buildCompactImageSection() {
    return SizedBox(
      width: 48,
      height: 48,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(8),
        child: OptimizedPragaImageWidget(
          nomeCientifico: praga.nomeCientifico,
          width: 48,
          height: 48,
          fit: BoxFit.cover,
          enablePreloading: enableImagePreloading,
          errorWidget: _buildIconFallback(48),
        ),
      ),
    );
  }

  Widget _buildCompactContentSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          praga.nomeFormatado,
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w500,
            color: isDarkMode ? Colors.white : Colors.black87,
          ),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        const SizedBox(height: 2),
        Row(
          children: [
            FaIcon(
              _getTypeIcon(),
              size: 12,
              color: _getTypeColor(),
            ),
            const SizedBox(width: 6),
            Text(
              _getTypeText(),
              style: TextStyle(
                fontSize: 12,
                color: isDarkMode ? Colors.grey.shade300 : Colors.grey.shade600,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildCompactFavoriteButton() {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: isFavorite 
            ? Colors.red.withValues(alpha: 0.1)
            : Colors.transparent,
        borderRadius: BorderRadius.circular(6),
      ),
      child: IconButton(
        icon: Icon(
          isFavorite ? Icons.favorite : Icons.favorite_border,
          color: isFavorite ? Colors.red : Colors.grey.shade500,
          size: 16,
        ),
        onPressed: onFavoriteToggle,
        padding: const EdgeInsets.all(4),
        constraints: const BoxConstraints(
          minWidth: 28,
          minHeight: 28,
        ),
      ),
    );
  }

  Widget _buildFeaturedImageSection() {
    return ClipRRect(
      borderRadius: const BorderRadius.only(
        topLeft: Radius.circular(20),
        bottomLeft: Radius.circular(20),
      ),
      child: Stack(
        children: [
          OptimizedPragaImageWidget(
            nomeCientifico: praga.nomeCientifico,
            width: double.infinity,
            height: double.infinity,
            fit: BoxFit.cover,
            enablePreloading: enableImagePreloading,
            errorWidget: _buildIconFallback(double.infinity),
          ),
          
          // Gradiente overlay
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.centerLeft,
                end: Alignment.centerRight,
                colors: [
                  Colors.transparent,
                  _getCardColor().withValues(alpha: 0.3),
                ],
                stops: const [0.0, 1.0],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFeaturedContentSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        // Nome principal
        Text(
          praga.nomeFormatado,
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: isDarkMode ? Colors.white : Colors.black87,
          ),
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
        ),
        
        const SizedBox(height: 6),
        
        // Nome científico
        if (praga.nomeCientifico.isNotEmpty)
          Text(
            praga.nomeCientifico,
            style: TextStyle(
              fontSize: 14,
              color: isDarkMode ? Colors.grey.shade300 : Colors.grey.shade600,
              fontStyle: FontStyle.italic,
            ),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
        
        const SizedBox(height: 12),
        
        // Informações adicionais
        Row(
          children: [
            // Chip de tipo
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
              decoration: BoxDecoration(
                color: _getTypeColor().withValues(alpha: 0.2),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: _getTypeColor().withValues(alpha: 0.5),
                  width: 1,
                ),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  FaIcon(
                    _getTypeIcon(),
                    size: 14,
                    color: _getTypeColor(),
                  ),
                  const SizedBox(width: 6),
                  Text(
                    _getTypeText(),
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: _getTypeColor(),
                    ),
                  ),
                ],
              ),
            ),
            
            const Spacer(),
            
            // Botão de favorito
            if (showFavoriteButton && onFavoriteToggle != null)
              _buildFloatingFavoriteButton(),
          ],
        ),
      ],
    );
  }

  // ==================== WIDGETS AUXILIARES ====================

  Widget _buildFloatingFavoriteButton() {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: isFavorite 
            ? Colors.red.withValues(alpha: 0.9)
            : Colors.black.withValues(alpha: 0.7),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.3),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: IconButton(
        icon: Icon(
          isFavorite ? Icons.favorite : Icons.favorite_border,
          color: isFavorite ? Colors.white : Colors.white,
          size: 18,
        ),
        onPressed: onFavoriteToggle,
        padding: const EdgeInsets.all(8),
        constraints: const BoxConstraints(
          minWidth: 36,
          minHeight: 36,
        ),
      ),
    );
  }

  Widget _buildIconFallback(double size) {
    return Container(
      width: size == double.infinity ? null : size,
      height: size == double.infinity ? null : size,
      decoration: BoxDecoration(
        color: _getTypeColor().withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: _getTypeColor().withValues(alpha: 0.3),
          width: 1,
        ),
      ),
      child: Center(
        child: FaIcon(
          _getTypeIcon(),
          color: _getTypeColor(),
          size: size == double.infinity ? 48 : (size / 2).clamp(16, 48),
        ),
      ),
    );
  }

  // ==================== HELPERS ====================

  Color _getCardColor() {
    return isDarkMode ? const Color(0xFF222228) : Colors.white;
  }

  Color _getTypeColor() {
    switch (praga.tipoPraga) {
      case '1': // Insetos
        return const Color(0xFFE53935);
      case '2': // Doenças
        return const Color(0xFFFF9800);
      case '3': // Plantas Daninhas
        return const Color(0xFF4CAF50);
      default:
        return const Color(0xFF757575);
    }
  }

  IconData _getTypeIcon() {
    switch (praga.tipoPraga) {
      case '1': // Insetos
        return FontAwesomeIcons.bug;
      case '2': // Doenças
        return FontAwesomeIcons.virus;
      case '3': // Plantas Daninhas
        return FontAwesomeIcons.seedling;
      default:
        return FontAwesomeIcons.triangleExclamation;
    }
  }

  String _getTypeText() {
    switch (praga.tipoPraga) {
      case '1':
        return 'Inseto';
      case '2':
        return 'Doença';
      case '3':
        return 'Planta Daninha';
      default:
        return 'Praga';
    }
  }
}

/// Enumeration para os modos de visualização do card
enum PragaCardMode {
  /// Modo lista horizontal com detalhes completos
  list,
  
  /// Modo grid vertical com imagem em destaque
  grid,
  
  /// Modo compacto para listas densas
  compact,
  
  /// Modo destaque para itens selecionados/importantes
  featured,
}