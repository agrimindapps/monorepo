import 'package:flutter/material.dart';
import 'package:provider/provider.dart' as provider;

import 'presentation/pages/detalhe_diagnostico_clean_page.dart';
import 'presentation/providers/detalhe_diagnostico_provider.dart';

/// Wrapper page que mantém compatibilidade total com a implementação original
/// enquanto usa a nova arquitetura componentizada internamente.
/// 
/// Este approach permite:
/// - Manter todas as chamadas existentes funcionando
/// - Aplicar Clean Architecture gradualmente
/// - Facilitar testes e manutenção
/// - Permitir rollback seguro se necessário
class DetalheDiagnosticoPage extends StatelessWidget {
  final String diagnosticoId;
  final String nomeDefensivo;
  final String nomePraga;
  final String cultura;

  const DetalheDiagnosticoPage({
    super.key,
    required this.diagnosticoId,
    required this.nomeDefensivo,
    required this.nomePraga,
    required this.cultura,
  });

  @override
  Widget build(BuildContext context) {
    return provider.ChangeNotifierProvider(
      create: (_) => DetalheDiagnosticoProvider(),
      child: DetalheDiagnosticoCleanPage(
        diagnosticoId: diagnosticoId,
        nomeDefensivo: nomeDefensivo,
        nomePraga: nomePraga,
        cultura: cultura,
      ),
    );
  }
}