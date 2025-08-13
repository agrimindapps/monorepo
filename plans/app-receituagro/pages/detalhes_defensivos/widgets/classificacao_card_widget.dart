// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:icons_plus/icons_plus.dart';

// Project imports:
import '../constants/detalhes_defensivos_design_tokens.dart';

class ClassificacaoCardWidget extends StatelessWidget {
  final Map<String, dynamic> caracteristicas;

  const ClassificacaoCardWidget({
    super.key,
    required this.caracteristicas,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(
          bottom: DetalhesDefensivosDesignTokens.mediumSpacing),
      decoration: DetalhesDefensivosDesignTokens.cardDecorationFlat(context),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header do card
          Container(
            padding: DetalhesDefensivosDesignTokens.contentPadding,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  DetalhesDefensivosDesignTokens.accentColor
                      .withValues(alpha: 0.8),
                  DetalhesDefensivosDesignTokens.accentColor
                      .withValues(alpha: 0.9),
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(
                    DetalhesDefensivosDesignTokens.defaultBorderRadius),
                topRight: Radius.circular(
                    DetalhesDefensivosDesignTokens.defaultBorderRadius),
              ),
            ),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(
                      DetalhesDefensivosDesignTokens.smallSpacing),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(
                        DetalhesDefensivosDesignTokens.smallBorderRadius),
                  ),
                  child: const Icon(
                    FontAwesome.layer_group_solid,
                    color: Colors.white,
                    size: DetalhesDefensivosDesignTokens.defaultIconSize,
                  ),
                ),
                const SizedBox(
                    width: DetalhesDefensivosDesignTokens.mediumSpacing),
                Text(
                  'Classificação',
                  style: DetalhesDefensivosDesignTokens.cardTitleStyle.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
          ),

          // Conteúdo do card
          Padding(
            padding: DetalhesDefensivosDesignTokens.cardPadding,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildInfoItem(
                  context,
                  'Modo de Ação',
                  caracteristicas['modoAcao'] ?? 'Não disponível',
                  FontAwesome.gear_solid,
                  Colors.green,
                ),
                const SizedBox(
                    height: DetalhesDefensivosDesignTokens.mediumSpacing),
                _buildInfoItem(
                  context,
                  'Classe Agronômica',
                  caracteristicas['classeAgronomica'] ?? 'Não disponível',
                  FontAwesome.seedling_solid,
                  Colors.green,
                ),
                const SizedBox(
                    height: DetalhesDefensivosDesignTokens.mediumSpacing),
                _buildInfoItem(
                  context,
                  'Classe Ambiental',
                  caracteristicas['classAmbiental'] ?? 'Não disponível',
                  FontAwesome.leaf_solid,
                  Colors.green,
                ),
                const SizedBox(
                    height: DetalhesDefensivosDesignTokens.mediumSpacing),
                _buildInfoItem(
                  context,
                  'Formulação',
                  caracteristicas['formulacao'] ?? 'Não disponível',
                  FontAwesome.flask_solid,
                  Colors.green,
                ),
                const SizedBox(
                    height: DetalhesDefensivosDesignTokens.mediumSpacing),
                _buildInfoItem(
                  context,
                  'Mapa',
                  caracteristicas['mapa'] ?? 'Não disponível',
                  FontAwesome.map_solid,
                  Colors.green,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoItem(
    BuildContext context,
    String label,
    String value,
    IconData icon,
    Color accentColor,
  ) {
    return Container(
      padding: DetalhesDefensivosDesignTokens.contentPadding,
      decoration: BoxDecoration(
        color: DetalhesDefensivosDesignTokens.getSurfaceColor(context),
        borderRadius: BorderRadius.circular(
            DetalhesDefensivosDesignTokens.smallBorderRadius),
        border: Border.all(
          color: accentColor.withValues(alpha: 0.2),
          width: 1,
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(
                DetalhesDefensivosDesignTokens.smallSpacing),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  accentColor.withValues(alpha: 0.15),
                  accentColor.withValues(alpha: 0.05),
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(
                  DetalhesDefensivosDesignTokens.smallBorderRadius),
            ),
            child: Icon(
              icon,
              color: accentColor,
              size: DetalhesDefensivosDesignTokens.smallIconSize,
            ),
          ),
          const SizedBox(width: DetalhesDefensivosDesignTokens.mediumSpacing),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: DetalhesDefensivosDesignTokens.cardTitleStyle.copyWith(
                    color: DetalhesDefensivosDesignTokens.getTextColor(context),
                    fontSize: DetalhesDefensivosDesignTokens.bodyFontSize,
                  ),
                ),
                const SizedBox(
                    height: DetalhesDefensivosDesignTokens.smallSpacing),
                Text(
                  value,
                  style:
                      DetalhesDefensivosDesignTokens.cardSubtitleStyle.copyWith(
                    color: DetalhesDefensivosDesignTokens.getSubtitleColor(
                        context),
                    height: 1.4,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
