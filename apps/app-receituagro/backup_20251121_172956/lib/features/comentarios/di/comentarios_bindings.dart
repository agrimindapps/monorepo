import 'package:flutter/material.dart';

import '../comentarios_page.dart';

/// Legacy wrapper - kept for backward compatibility
/// Use ComentariosPage directly in Riverpod-managed apps
class ComentariosPageWithProviders extends StatelessWidget {
  final String? pkIdentificador;
  final String? ferramenta;

  const ComentariosPageWithProviders({
    super.key,
    this.pkIdentificador,
    this.ferramenta,
  });

  @override
  Widget build(BuildContext context) {
    return ComentariosPage(
      pkIdentificador: pkIdentificador,
      ferramenta: ferramenta,
    );
  }
}
