import 'package:flutter/material.dart';

import '../../domain/entities/defensivo_entity.dart';
import 'defensivo_completo_card_widget.dart';
import 'defensivos_empty_state_widget.dart';

/// Widget especializado para exibir lista de defensivos
/// Migrado e adaptado de defensivos_agrupados para nova arquitetura SOLID
/// 
/// Características:
/// - Renderização otimizada com SliverList
/// - Suporte a modo comparação
/// - Callback para navegação e seleção
/// - Estado vazio integrado
/// - Performance otimizada com RepaintBoundary
class DefensivosListWidget extends StatelessWidget {
  final List<DefensivoEntity> defensivos;
  final bool modoComparacao;
  final List<DefensivoEntity> defensivosSelecionados;
  final Function(DefensivoEntity) onTap;
  final Function(DefensivoEntity)? onSelecaoChanged;
  final VoidCallback onClearFilters;

  const DefensivosListWidget({
    super.key,
    required this.defensivos,
    required this.modoComparacao,
    required this.defensivosSelecionados,
    required this.onTap,
    this.onSelecaoChanged,
    required this.onClearFilters,
  });

  @override
  Widget build(BuildContext context) {
    if (defensivos.isEmpty) {
      return SliverToBoxAdapter(
        child: DefensivosEmptyStateWidget(
          onClearFilters: onClearFilters,
        ),
      );
    }

    return SliverList(
      delegate: SliverChildBuilderDelegate(
        (context, index) {
          final defensivo = defensivos[index];
          return RepaintBoundary(
            child: Container(
              margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: DefensivoCompletoCardWidget(
                defensivo: defensivo,
                modoComparacao: modoComparacao,
                isSelected: defensivosSelecionados.contains(defensivo),
                onTap: () => onTap(defensivo),
                onSelecaoChanged: onSelecaoChanged != null 
                    ? () => onSelecaoChanged!(defensivo)
                    : null,
              ),
            ),
          );
        },
        childCount: defensivos.length,
      ),
    );
  }
}