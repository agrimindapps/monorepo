import 'package:core/core.dart';
import 'package:flutter/material.dart';

import '../services/receituagro_navigation_service.dart';

/// AppBar customizado para páginas internas que preserva o bottomNavigation
///
/// Automaticamente adiciona botão de voltar quando especificado
/// e permite navegação de volta usando o novo serviço de navegação
class InternalPageAppBar extends StatelessWidget implements PreferredSizeWidget {
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
  Widget build(BuildContext context) {
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
              onPressed: () => _handleBackPress(),
            )
          : null,
    );
  }

  void _handleBackPress() {
    final navigationService = GetIt.instance<ReceitaAgroNavigationService>();
    navigationService.goBack<void>();
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
