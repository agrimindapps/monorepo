import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../navigation/app_navigation_provider.dart';

/// AppBar customizado para páginas internas que preserva o bottomNavigation
/// 
/// Automaticamente adiciona botão de voltar quando está em uma página de detalhe
/// e permite navegação de volta mantendo o bottomNavigation visível
class InternalPageAppBar extends StatelessWidget implements PreferredSizeWidget {
  final String? title;
  final List<Widget>? actions;
  final Color? backgroundColor;
  final Color? foregroundColor;
  final double elevation;
  final bool automaticallyImplyLeading;

  const InternalPageAppBar({
    super.key,
    this.title,
    this.actions,
    this.backgroundColor,
    this.foregroundColor,
    this.elevation = 0,
    this.automaticallyImplyLeading = true,
  });

  @override
  Widget build(BuildContext context) {
    return Consumer<AppNavigationProvider>(
      builder: (context, navigationProvider, child) {
        return AppBar(
          title: title != null ? Text(title!) : null,
          actions: actions,
          backgroundColor: backgroundColor,
          foregroundColor: foregroundColor,
          elevation: elevation,
          automaticallyImplyLeading: false, // Controlamos manualmente
          leading: automaticallyImplyLeading && navigationProvider.isInDetailPage
              ? IconButton(
                  icon: const Icon(Icons.arrow_back),
                  onPressed: () => navigationProvider.goBack(),
                )
              : null,
        );
      },
    );
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
  }) {
    return Scaffold(
      appBar: InternalPageAppBar(
        title: title,
        actions: actions,
        backgroundColor: appBarBackgroundColor,
        foregroundColor: appBarForegroundColor,
        elevation: appBarElevation,
        automaticallyImplyLeading: automaticallyImplyLeading,
      ),
      body: this,
    );
  }
}