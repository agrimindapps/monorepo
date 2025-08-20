import 'package:flutter/material.dart';

/// AppBar comum usado em todo o aplicativo
class CommonAppBar extends StatelessWidget implements PreferredSizeWidget {
  final String title;
  final bool showBackButton;
  final List<Widget>? actions;
  final Widget? leading;
  final bool centerTitle;
  final Color? backgroundColor;
  final Color? foregroundColor;
  final double? elevation;
  final Widget? flexibleSpace;
  final PreferredSizeWidget? bottom;

  const CommonAppBar({
    super.key,
    required this.title,
    this.showBackButton = false,
    this.actions,
    this.leading,
    this.centerTitle = true,
    this.backgroundColor,
    this.foregroundColor,
    this.elevation,
    this.flexibleSpace,
    this.bottom,
  });

  @override
  Widget build(BuildContext context) {
    return AppBar(
      title: Text(title),
      centerTitle: centerTitle,
      backgroundColor: backgroundColor,
      foregroundColor: foregroundColor,
      elevation: elevation,
      flexibleSpace: flexibleSpace,
      bottom: bottom,
      leading: leading ?? (showBackButton ? _buildBackButton(context) : null),
      automaticallyImplyLeading: showBackButton && leading == null,
      actions: actions,
    );
  }

  Widget? _buildBackButton(BuildContext context) {
    if (!showBackButton) return null;
    
    return IconButton(
      icon: const Icon(Icons.arrow_back),
      onPressed: () => Navigator.of(context).pop(),
      tooltip: 'Voltar',
    );
  }

  @override
  Size get preferredSize => Size.fromHeight(
    kToolbarHeight + (bottom?.preferredSize.height ?? 0.0),
  );

  /// Factory constructor para página principal
  factory CommonAppBar.main({
    required String title,
    List<Widget>? actions,
    Widget? flexibleSpace,
    PreferredSizeWidget? bottom,
  }) {
    return CommonAppBar(
      title: title,
      showBackButton: false,
      actions: actions,
      centerTitle: false,
      flexibleSpace: flexibleSpace,
      bottom: bottom,
    );
  }

  /// Factory constructor para páginas secundárias
  factory CommonAppBar.secondary({
    required String title,
    List<Widget>? actions,
    Widget? leading,
    PreferredSizeWidget? bottom,
  }) {
    return CommonAppBar(
      title: title,
      showBackButton: true,
      actions: actions,
      leading: leading,
      centerTitle: true,
      bottom: bottom,
    );
  }

  /// Factory constructor transparente
  factory CommonAppBar.transparent({
    required String title,
    bool showBackButton = true,
    List<Widget>? actions,
    Widget? leading,
  }) {
    return CommonAppBar(
      title: title,
      showBackButton: showBackButton,
      actions: actions,
      leading: leading,
      backgroundColor: Colors.transparent,
      elevation: 0,
    );
  }
}