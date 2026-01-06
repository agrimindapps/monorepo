import 'package:core/core.dart' hide Column;
import 'package:flutter/material.dart';

import '../providers/core_providers.dart';

/// AppBar customizado para páginas internas que preserva o bottomNavigation
///
/// Automaticamente adiciona botão de voltar quando especificado
/// e permite navegação de volta usando o novo serviço de navegação
class InternalPageAppBar extends ConsumerWidget implements PreferredSizeWidget {
  final String? title;
  final List<Widget>? actions;
  final Color? backgroundColor;
  final Color? foregroundColor;
  final double elevation;
  final bool automaticallyImplyLeading;
  final bool showBackButton;

  const InternalPageAppBar({
    super.key,
    this.title,
    this.actions,
    this.backgroundColor,
    this.foregroundColor,
    this.elevation = 0,
    this.automaticallyImplyLeading = true,
    this.showBackButton = true,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return AppBar(
      title: title != null ? Text(title!) : null,
      actions: actions,
      backgroundColor: backgroundColor,
      foregroundColor: foregroundColor,
      elevation: elevation,
      automaticallyImplyLeading: false, // Controlamos manualmente
      leading: automaticallyImplyLeading && showBackButton
          ? IconButton(
              icon: const Icon(Icons.arrow_back),
              onPressed: () => _handleBackPress(context, ref),
            )
          : null,
    );
  }

  void _handleBackPress(BuildContext context, WidgetRef ref) {
    // Primeiro tenta o Navigator padrão (funciona com MaterialPageRoute)
    if (Navigator.canPop(context)) {
      Navigator.pop(context);
      return;
    }
    
    // Tenta GoRouter se disponível
    try {
      final navigationService = ref.read(navigationServiceProvider);
      // Se não consegue voltar, vai para a home
      if (!navigationService.canGoBack()) {
        navigationService.navigateTo<void>('/');
      } else {
        navigationService.goBack<void>();
      }
    } catch (e) {
      // Último fallback: volta para home
      debugPrint('⚠️ InternalPageAppBar: Navegando para home como fallback - $e');
      Navigator.of(context).pushNamedAndRemoveUntil('/', (route) => false);
    }
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}

/// Extension para facilitar o uso do InternalPageAppBar
extension InternalPageScaffold on Widget {
  Widget wrapWithInternalScaffold({
    String? title,
    List<Widget>? actions,
    Color? appBarBackgroundColor,
    Color? appBarForegroundColor,
    double appBarElevation = 0,
    bool automaticallyImplyLeading = true,
    bool showBackButton = true,
  }) {
    return Scaffold(
      appBar: InternalPageAppBar(
        title: title,
        actions: actions,
        backgroundColor: appBarBackgroundColor,
        foregroundColor: appBarForegroundColor,
        elevation: appBarElevation,
        automaticallyImplyLeading: automaticallyImplyLeading,
        showBackButton: showBackButton,
      ),
      body: this,
    );
  }
}
