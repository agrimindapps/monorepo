import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'presentation/pages/lista_defensivos_agrupados_clean_page.dart';
import 'presentation/providers/lista_defensivos_agrupados_provider.dart';

/// Wrapper page for Lista de Defensivos Agrupados
/// Maintains 100% compatibility with existing navigation
/// Refactored following successful template (7th consecutive success)
class ListaDefensivosAgrupadosPage extends StatelessWidget {
  final String tipoAgrupamento;
  final String? textoFiltro;

  const ListaDefensivosAgrupadosPage({
    super.key,
    required this.tipoAgrupamento,
    this.textoFiltro,
  });

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) => ListaDefensivosAgrupadosProvider(),
      child: ListaDefensivosAgrupadosCleanPage(
        tipoAgrupamento: tipoAgrupamento,
        textoFiltro: textoFiltro,
      ),
    );
  }
}

