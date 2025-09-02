import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'presentation/pages/comentarios_clean_page.dart';

/// **COMENTARIOS RIVERPOD PAGE - MAIN ENTRY POINT**
/// 
/// Entry point for the refactored Comentarios feature using Riverpod.
/// This wrapper provides the ProviderScope for Riverpod and delegates to the clean architecture implementation.
/// 
/// ## Architecture:
/// 
/// ```
/// ComentariosRiverpodPage (ProviderScope)
///    └── ComentariosCleanPage (Clean Architecture)
///        ├── Riverpod Providers (State Management)
///        ├── Use Cases (Business Logic)
///        ├── Repositories (Data Access)
///        └── UI Widgets (Presentation)
/// ```
/// 
/// ## Benefits:
/// 
/// - **Clean Separation**: Business logic separated from UI
/// - **Testability**: Each layer can be tested independently
/// - **Maintainability**: Clear responsibilities and dependencies
/// - **Performance**: Granular rebuilds with Riverpod
/// - **Type Safety**: Strong typing throughout the architecture
/// 
/// ## Usage:
/// 
/// ```dart
/// // General view
/// Navigator.push(context, MaterialPageRoute(
///   builder: (_) => const ComentariosRiverpodPage(),
/// ));
/// 
/// // Context-specific view
/// Navigator.push(context, MaterialPageRoute(
///   builder: (_) => ComentariosRiverpodPage(
///     pkIdentificador: 'def_123',
///     ferramenta: 'defensivos',
///   ),
/// ));
/// ```

class ComentariosRiverpodPage extends StatelessWidget {
  /// Optional context identifier for filtering comentarios
  final String? pkIdentificador;
  
  /// Optional tool/feature identifier for filtering comentarios
  final String? ferramenta;

  const ComentariosRiverpodPage({
    super.key,
    this.pkIdentificador,
    this.ferramenta,
  });

  @override
  Widget build(BuildContext context) {
    // Wrap with ProviderScope to enable Riverpod
    return ProviderScope(
      child: ComentariosCleanPage(
        pkIdentificador: pkIdentificador,
        ferramenta: ferramenta,
      ),
    );
  }

  // ========================================================================
  // FACTORY CONSTRUCTORS
  // ========================================================================

  /// Factory constructor for general comentarios view
  static ComentariosRiverpodPage general() {
    return const ComentariosRiverpodPage();
  }

  /// Factory constructor for context-specific view
  static ComentariosRiverpodPage forContext({
    required String pkIdentificador,
    String? ferramenta,
  }) {
    return ComentariosRiverpodPage(
      pkIdentificador: pkIdentificador,
      ferramenta: ferramenta,
    );
  }

  /// Factory constructor for tool-specific view
  static ComentariosRiverpodPage forTool({
    required String ferramenta,
  }) {
    return ComentariosRiverpodPage(
      ferramenta: ferramenta,
    );
  }

  // ========================================================================
  // NAVIGATION HELPERS
  // ========================================================================

  /// Navigate to general comentarios view
  static Future<void> navigateToGeneral(BuildContext context) {
    return Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => const ComentariosRiverpodPage(),
      ),
    );
  }

  /// Navigate to context-specific comentarios view
  static Future<void> navigateToContext(
    BuildContext context, {
    required String pkIdentificador,
    String? ferramenta,
  }) {
    return Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => ComentariosRiverpodPage(
          pkIdentificador: pkIdentificador,
          ferramenta: ferramenta,
        ),
      ),
    );
  }

  /// Navigate to tool-specific comentarios view  
  static Future<void> navigateToTool(
    BuildContext context, {
    required String ferramenta,
  }) {
    return Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => ComentariosRiverpodPage(
          ferramenta: ferramenta,
        ),
      ),
    );
  }

  /// Replace current route with comentarios page
  static Future<void> replaceWith(
    BuildContext context, {
    String? pkIdentificador,
    String? ferramenta,
  }) {
    return Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (_) => ComentariosRiverpodPage(
          pkIdentificador: pkIdentificador,
          ferramenta: ferramenta,
        ),
      ),
    );
  }
}