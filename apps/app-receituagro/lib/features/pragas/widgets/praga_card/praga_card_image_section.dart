import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

import '../../../../core/widgets/optimized_praga_image_widget.dart';
import 'praga_card_helpers.dart';
import 'praga_card_main.dart';

/// Widget especializado em renderizar a seção de imagem do card
/// 
/// Responsabilidades:
/// - Otimização de carregamento de imagens
/// - Fallback com ícones tipados
/// - Múltiplos tamanhos e formatos
/// - Performance otimizada para listas grandes
class PragaCardImageSection extends StatelessWidget {
  final PragaCardProperties properties;
  final PragaCardImageMode mode;
  final double? width;
  final double? height;

  const PragaCardImageSection({
    super.key,
    required this.properties,
    required this.mode,
    this.width,
    this.height,
  });

  @override
  Widget build(BuildContext context) {
    switch (mode) {
      case PragaCardImageMode.list:
        return _buildListImage();
      case PragaCardImageMode.grid:
        return _buildGridImage();
    }
  }

  /// Imagem para modo lista (80x80 rounded)
  Widget _buildListImage() {
    return SizedBox(
      width: width ?? 80,
      height: height ?? 80,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(12),
        child: OptimizedPragaImageWidget(
          nomeCientifico: properties.praga.nomeCientifico,
          width: width ?? 80,
          height: height ?? 80,
          fit: BoxFit.cover,
          enablePreloading: properties.enableImagePreloading,
          errorWidget: _buildIconFallback(width ?? 80),
        ),
      ),
    );
  }

  /// Imagem para modo grid (full width)
  Widget _buildGridImage() {
    return SizedBox(
      width: double.infinity,
      height: height ?? 120,
      child: ClipRRect(
        borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
        child: Stack(
          children: [
            OptimizedPragaImageWidget(
              nomeCientifico: properties.praga.nomeCientifico,
              width: double.infinity,
              height: height ?? 120,
              fit: BoxFit.cover,
              enablePreloading: properties.enableImagePreloading,
              errorWidget: _buildIconFallback(double.infinity),
            ),
            // Gradient overlay para melhor legibilidade do texto
            Positioned(
              bottom: 0,
              left: 0,
              right: 0,
              child: Container(
                height: 40,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.bottomCenter,
                    end: Alignment.topCenter,
                    colors: [
                      Colors.black.withValues(alpha: 0.7),
                      Colors.transparent,
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }


  /// Constrói o fallback com ícone quando imagem falha
  Widget _buildIconFallback(double size) {
    final typeColor = PragaCardHelpers.getTypeColor(properties.praga.tipoPraga);
    final typeIcon = PragaCardHelpers.getTypeIcon(properties.praga.tipoPraga);
    
    return Container(
      width: size == double.infinity ? null : size,
      height: size == double.infinity ? null : size,
      decoration: BoxDecoration(
        color: typeColor.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: typeColor.withValues(alpha: 0.3),
          width: 1,
        ),
      ),
      child: Center(
        child: FaIcon(
          typeIcon,
          color: typeColor,
          size: size == double.infinity ? 48 : (size / 2).clamp(16, 48),
        ),
      ),
    );
  }
}

/// Modos de exibição da imagem
enum PragaCardImageMode {
  list,
  grid,
}