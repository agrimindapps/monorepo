import 'package:flutter/material.dart';

import '../../../core/services/diagnostico_integration_service.dart';
import 'praga_por_cultura_card_widget.dart';

/// ListView otimizada para exibir lista de pragas por cultura
/// Implementa performance otimizations e RepaintBoundary
class PragasListView extends StatelessWidget {
  final List<PragaPorCultura> pragasPorCultura;
  final void Function(PragaPorCultura) onPragaTap;
  final void Function(PragaPorCultura) onVerDefensivos;

  const PragasListView({
    super.key,
    required this.pragasPorCultura,
    required this.onPragaTap,
    required this.onVerDefensivos,
  });

  @override
  Widget build(BuildContext context) {
    return SliverList(
      delegate: SliverChildBuilderDelegate(
        (context, index) => _buildPragaCard(context, index),
        childCount: pragasPorCultura.length,
        addRepaintBoundaries: true,
        addSemanticIndexes: true,
      ),
    );
  }

  Widget _buildPragaCard(BuildContext context, int index) {
    final pragaPorCultura = pragasPorCultura[index];
    
    return RepaintBoundary(
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        child: PragaPorCulturaCardWidget(
          pragaPorCultura: pragaPorCultura,
          onTap: () => onPragaTap(pragaPorCultura),
          onVerDefensivos: () => onVerDefensivos(pragaPorCultura),
        ),
      ),
    );
  }
}
