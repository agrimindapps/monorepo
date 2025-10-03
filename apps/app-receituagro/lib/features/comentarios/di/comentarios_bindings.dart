import 'package:flutter/material.dart';

import '../comentarios_page.dart';

// Provider removed - Riverpod manages lifecycle automatically
// Repository/service registrations moved to injectable modules
// See comentarios_di.dart for DI configuration

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
    // Direct navigation - Riverpod providers are managed globally
    return ComentariosPage(
      pkIdentificador: pkIdentificador,
      ferramenta: ferramenta,
    );
  }
}