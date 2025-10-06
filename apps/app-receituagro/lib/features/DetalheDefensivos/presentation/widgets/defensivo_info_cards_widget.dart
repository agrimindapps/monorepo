import 'package:core/core.dart';
import 'package:flutter/material.dart';

import '../../../../core/theme/spacing_tokens.dart';
import '../../domain/entities/defensivo_details_entity.dart';

/// Widget para cards de informações do defensivo
/// Responsabilidade: exibir dados técnicos e classificação
class DefensivoInfoCardsWidget extends StatelessWidget {
  final DefensivoDetailsEntity defensivo;

  const DefensivoInfoCardsWidget({
    super.key,
    required this.defensivo,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        _buildInfoCard(context),
        SpacingTokens.gapLG,
        _buildClassificacaoCard(context),
      ],
    );
  }

  Widget _buildInfoCard(BuildContext context) {
    final caracteristicas = {
      'ingredienteAtivo': defensivo.ingredienteAtivo,
      'nomeTecnico': defensivo.nomeTecnico,
      'toxico': defensivo.toxico ?? 'Não informado',
      'inflamavel': defensivo.inflamavel ?? 'Não informado',
      'corrosivo': defensivo.corrosivo ?? 'Não informado',
    };

    return _buildCardContainer(
      context: context,
      title: 'Informações Técnicas',
      icon: FontAwesomeIcons.info,
      children: [
        _buildInfoItem(
          'Ingrediente Ativo',
          caracteristicas['ingredienteAtivo']!,
          FontAwesomeIcons.flask,
          const Color(0xFF4CAF50),
        ),
        SpacingTokens.gapMD,
        _buildInfoItem(
          'Nome Técnico',
          caracteristicas['nomeTecnico']!,
          FontAwesomeIcons.tag,
          const Color(0xFF4CAF50),
        ),
        SpacingTokens.gapMD,
        _buildInfoItem(
          'Toxicologia',
          caracteristicas['toxico']!,
          FontAwesomeIcons.skull,
          const Color(0xFF4CAF50),
        ),
        SpacingTokens.gapMD,
        _buildInfoItem(
          'Inflamável',
          caracteristicas['inflamavel']!,
          FontAwesomeIcons.fire,
          const Color(0xFF4CAF50),
        ),
        SpacingTokens.gapMD,
        _buildInfoItem(
          'Corrosivo',
          caracteristicas['corrosivo']!,
          FontAwesomeIcons.droplet,
          const Color(0xFF4CAF50),
        ),
      ],
    );
  }

  Widget _buildClassificacaoCard(BuildContext context) {
    final caracteristicas = {
      'modoAcao': defensivo.modoAcao ?? 'Não informado',
      'classeAgronomica': defensivo.classeAgronomica ?? 'Não informado',
      'classAmbiental': defensivo.classAmbiental ?? 'Não informado',
      'formulacao': defensivo.formulacao ?? 'Não informado',
      'mapa': defensivo.mapa ?? 'Não informado',
    };

    return _buildCardContainer(
      context: context,
      title: 'Classificação',
      icon: FontAwesomeIcons.layerGroup,
      children: [
        _buildInfoItem(
          'Modo de Ação',
          caracteristicas['modoAcao']!,
          FontAwesomeIcons.gear,
          const Color(0xFF4CAF50),
        ),
        SpacingTokens.gapMD,
        _buildInfoItem(
          'Classe Agronômica',
          caracteristicas['classeAgronomica']!,
          FontAwesomeIcons.seedling,
          const Color(0xFF4CAF50),
        ),
        SpacingTokens.gapMD,
        _buildInfoItem(
          'Classe Ambiental',
          caracteristicas['classAmbiental']!,
          FontAwesomeIcons.leaf,
          const Color(0xFF4CAF50),
        ),
        SpacingTokens.gapMD,
        _buildInfoItem(
          'Formulação',
          caracteristicas['formulacao']!,
          FontAwesomeIcons.flask,
          const Color(0xFF4CAF50),
        ),
        SpacingTokens.gapMD,
        _buildInfoItem(
          'Registro MAPA',
          caracteristicas['mapa']!,
          FontAwesomeIcons.map,
          const Color(0xFF4CAF50),
        ),
      ],
    );
  }

  Widget _buildCardContainer({
    required BuildContext context,
    required String title,
    required IconData icon,
    required List<Widget> children,
  }) {
    final theme = Theme.of(context);

    return DecoratedBox(
      decoration: BoxDecoration(
        color: theme.cardColor,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: theme.shadowColor.withValues(alpha: 0.1),
            spreadRadius: 1,
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: SpacingTokens.paddingSM,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  const Color(0xFF4CAF50).withValues(alpha: 0.8),
                  const Color(0xFF4CAF50).withValues(alpha: 0.9),
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(12),
                topRight: Radius.circular(12),
              ),
            ),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(
                    icon,
                    color: Colors.white,
                    size: 20,
                  ),
                ),
                const SizedBox(width: 12),
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                    color: Colors.white,
                  ),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: children,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoItem(
    String label,
    String value,
    IconData icon,
    Color accentColor,
  ) {
    return Builder(
      builder: (context) {
        final theme = Theme.of(context);
        
        return Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: theme.colorScheme.surfaceContainerLowest,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(
              color: accentColor.withValues(alpha: 0.2),
              width: 1,
            ),
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      accentColor.withValues(alpha: 0.15),
                      accentColor.withValues(alpha: 0.05),
                    ],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Icon(
                  icon,
                  color: accentColor,
                  size: 16,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      label,
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: theme.colorScheme.onSurface,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      value,
                      style: TextStyle(
                        fontSize: 13,
                        color: theme.colorScheme.onSurfaceVariant,
                        height: 1.4,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
