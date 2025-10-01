import 'package:flutter/material.dart';

import '../../../../core/theme/design_tokens.dart';
import 'praga_card_image_section.dart';
import 'praga_card_main.dart';

/// Widget específico para modo grid vertical
/// 
/// Responsabilidades:
/// - Layout vertical com imagem no topo
/// - Aspect ratio controlado
/// - Imagem full width com overlay
/// - Conteúdo na parte inferior
/// - Botão de favorito flutuante
class PragaCardGridMode extends StatelessWidget {
  final PragaCardProperties properties;

  const PragaCardGridMode({
    super.key,
    required this.properties,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: EdgeInsets.zero,
      elevation: ReceitaAgroElevation.card,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(ReceitaAgroBorderRadius.card),
        side: BorderSide.none,
      ),
      color: properties.isDarkMode ? const Color(0xFF2A2A2E) : Colors.white,
      child: InkWell(
        borderRadius: BorderRadius.circular(ReceitaAgroBorderRadius.card),
        onTap: properties.onTap,
        child: ClipRRect(
          borderRadius: BorderRadius.circular(ReceitaAgroBorderRadius.card),
          child: Stack(
            children: [
              // Imagem da praga ocupando todo o card
              _buildFullImage(),
              // Gradiente overlay para legibilidade do texto
              _buildGradientOverlay(),
              // Conteúdo textual sobreposto
              _buildOverlayContent(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildFullImage() {
    return Positioned.fill(
      child: PragaCardImageSection(
        properties: properties,
        mode: PragaCardImageMode.grid,
        height: double.infinity,
      ),
    );
  }

  Widget _buildGradientOverlay() {
    return Positioned(
      bottom: 0,
      left: 0,
      right: 0,
      child: Container(
        height: 80, // Altura do overlay
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.bottomCenter,
            end: Alignment.topCenter,
            colors: [
              Colors.black.withValues(alpha: 0.8),
              Colors.black.withValues(alpha: 0.4),
              Colors.transparent,
            ],
            stops: const [0.0, 0.7, 1.0],
          ),
        ),
      ),
    );
  }

  Widget _buildOverlayContent() {
    return Positioned(
      bottom: ReceitaAgroSpacing.sm,
      left: ReceitaAgroSpacing.sm,
      right: ReceitaAgroSpacing.sm,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            properties.praga.nomeComum,
            style: ReceitaAgroTypography.itemTitle.copyWith(
              color: Colors.white,
              shadows: const [
                Shadow(
                  blurRadius: 2.0,
                  color: Colors.black,
                  offset: Offset(0, 1),
                ),
              ],
            ),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
          if (properties.praga.nomeCientifico.isNotEmpty) ...[
            const SizedBox(height: ReceitaAgroSpacing.xs / 2),
            Text(
              properties.praga.nomeCientifico,
              style: ReceitaAgroTypography.itemCategory.copyWith(
                color: Colors.white.withValues(alpha: 0.9),
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
          ],
        ],
      ),
    );
  }

  Color _getTypeColor() {
    switch (properties.praga.tipoPraga) {
      case '1': // Insetos
        return const Color(0xFFE53935); // Vermelho
      case '2': // Doenças
        return const Color(0xFFFF9800); // Laranja
      case '3': // Plantas Daninhas
        return const Color(0xFF4CAF50); // Verde
      default:
        return const Color(0xFF757575); // Cinza
    }
  }

  IconData _getTypeIcon() {
    switch (properties.praga.tipoPraga) {
      case '1': // Insetos
        return Icons.bug_report_outlined;
      case '2': // Doenças
        return Icons.coronavirus_outlined;
      case '3': // Plantas Daninhas
        return Icons.grass_outlined;
      default:
        return Icons.pest_control_outlined;
    }
  }
}