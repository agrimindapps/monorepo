import 'package:flutter/material.dart';

import '../../../core/services/diagnostico_integration_service.dart';
import 'defensivo_completo_card_widget.dart';
import 'defensivos_empty_state_widget.dart';

/// Widget especializado para exibir lista de defensivos
/// 
/// Características:
/// - Renderização otimizada com SliverList
/// - Suporte a modo comparação
/// - Callback para navegação e seleção
/// - Estado vazio integrado
/// - Performance otimizada com RepaintBoundary
class DefensivosListWidget extends StatelessWidget {
  final List<DefensivoCompleto> defensivos;
  final bool modoComparacao;
  final List<DefensivoCompleto> defensivosSelecionados;
  final Function(DefensivoCompleto) onTap;
  final Function(DefensivoCompleto)? onSelecaoChanged;
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
                defensivoCompleto: defensivo,
                modoComparacao: modoComparacao,
                isSelecionado: defensivosSelecionados.contains(defensivo),
                onTap: () => onTap(defensivo),
                onSelecaoChanged: modoComparacao && onSelecaoChanged != null
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