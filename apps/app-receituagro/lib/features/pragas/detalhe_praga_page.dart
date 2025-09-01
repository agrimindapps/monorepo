import 'package:flutter/material.dart';

import 'presentation/pages/detalhe_praga_clean_page.dart';

/// Wrapper para manter compatibilidade com código existente
/// Redireciona para a versão refatorada seguindo Clean Architecture
class DetalhePragaPage extends StatelessWidget {
  final String pragaName;
  final String pragaScientificName;

  const DetalhePragaPage({
    super.key,
    required this.pragaName,
    required this.pragaScientificName,
  });

  @override
  Widget build(BuildContext context) {
    return DetalhePragaCleanPage(
      pragaName: pragaName,
      pragaScientificName: pragaScientificName,
    );
  }
}