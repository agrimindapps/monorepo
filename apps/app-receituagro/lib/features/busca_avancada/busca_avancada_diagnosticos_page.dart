import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'presentation/pages/busca_avancada_diagnosticos_clean_page.dart';
import 'presentation/providers/busca_avancada_provider.dart';

/// Wrapper page da busca avançada que gerencia o Provider e delega para a clean page
class BuscaAvancadaDiagnosticosPage extends StatelessWidget {
  const BuscaAvancadaDiagnosticosPage({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) => BuscaAvancadaProvider(),
      child: const BuscaAvancadaDiagnosticosCleanPage(),
    );
  }
}