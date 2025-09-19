import 'package:flutter/material.dart';

/// Widget base para páginas do Plantis com fundo e estilo padronizados
/// Baseado no mockup, com gradiente sutil e estrutura consistente
class BasePageScaffold extends StatelessWidget {
  /// Conteúdo principal da página
  final Widget body;

  /// AppBar customizada (opcional)
  final PreferredSizeWidget? appBar;

  /// Floating Action Button (opcional)
  final Widget? floatingActionButton;

  /// Bottom Navigation Bar (opcional)
  final Widget? bottomNavigationBar;

  /// Drawer lateral (opcional)
  final Widget? drawer;

  /// Se deve aplicar padding padrão no body
  final bool applyDefaultPadding;

  /// Padding personalizado (substitui o padrão se fornecido)
  final EdgeInsetsGeometry? padding;

  /// Se deve usar SafeArea
  final bool useSafeArea;

  /// Cor de fundo personalizada (opcional)
  final Color? backgroundColor;

  const BasePageScaffold({
    super.key,
    required this.body,
    this.appBar,
    this.floatingActionButton,
    this.bottomNavigationBar,
    this.drawer,
    this.applyDefaultPadding = true,
    this.padding,
    this.useSafeArea = true,
    this.backgroundColor,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    // Fundo baseado no mockup - gradiente sutil cinza claro
    final backgroundGradient = LinearGradient(
      begin: Alignment.topCenter,
      end: Alignment.bottomCenter,
      colors:
          backgroundColor != null
              ? [backgroundColor!, backgroundColor!]
              : isDark
              ? [const Color(0xFF1C1C1E), const Color(0xFF1A1A1C)]
              : [
                const Color(
                  0xFFF0F2F5,
                ), // Cinza mais escuro para melhor contraste com branco
                const Color(0xFFE8ECEF), // Cinza levemente mais escuro ainda
              ],
    );

    Widget content = DecoratedBox(
      decoration: BoxDecoration(gradient: backgroundGradient),
      child: useSafeArea ? SafeArea(child: _buildBody()) : _buildBody(),
    );

    return Scaffold(
      backgroundColor: Colors.transparent,
      appBar: appBar,
      body: content,
      floatingActionButton: floatingActionButton,
      bottomNavigationBar: bottomNavigationBar,
      drawer: drawer,
    );
  }

  Widget _buildBody() {
    Widget bodyWidget = body;

    if (applyDefaultPadding || padding != null) {
      final effectivePadding =
          padding ??
          const EdgeInsets.symmetric(horizontal: 8.0, vertical: 4.0);

      bodyWidget = Padding(padding: effectivePadding, child: bodyWidget);
    }

    return bodyWidget;
  }
}

/// Widget de card base seguindo o estilo do mockup
class PlantisCard extends StatelessWidget {
  /// Conteúdo do card
  final Widget child;

  /// Margem externa do card
  final EdgeInsetsGeometry? margin;

  /// Padding interno do card
  final EdgeInsetsGeometry? padding;

  /// Callback para tap no card
  final VoidCallback? onTap;

  /// Elevação personalizada
  final double? elevation;

  /// Cor de fundo personalizada
  final Color? backgroundColor;

  /// Border radius personalizado
  final BorderRadius? borderRadius;

  const PlantisCard({
    super.key,
    required this.child,
    this.margin,
    this.padding,
    this.onTap,
    this.elevation,
    this.backgroundColor,
    this.borderRadius,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    // Estilo baseado no mockup - branco puro para contraste máximo
    final cardDecoration = BoxDecoration(
      color:
          backgroundColor ??
          (isDark
              ? const Color(0xFF2D2D2D)
              : const Color(0xFFFFFFFF)), // Branco puro
      borderRadius: borderRadius ?? BorderRadius.circular(16.0),
      boxShadow: [
        BoxShadow(
          color:
              isDark
                  ? Colors.black.withValues(alpha: 0.3)
                  : const Color(
                    0xFF000000,
                  ).withValues(alpha: 0.12), // Sombra mais forte para contraste
          offset: const Offset(0, 3),
          blurRadius: 12,
          spreadRadius: 0,
        ),
        BoxShadow(
          color:
              isDark
                  ? Colors.black.withValues(alpha: 0.1)
                  : const Color(0xFF000000).withValues(alpha: 0.06),
          offset: const Offset(0, 1),
          blurRadius: 4,
          spreadRadius: 0,
        ),
      ],
    );

    Widget cardContent = Container(
      decoration: cardDecoration,
      margin: margin,
      padding: padding ?? const EdgeInsets.all(4.0),
      child: child,
    );

    if (onTap != null) {
      cardContent = Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: borderRadius ?? BorderRadius.circular(16.0),
          child: cardContent,
        ),
      );
    }

    return cardContent;
  }
}

/// Widget de header verde seguindo o estilo do mockup
class PlantisHeader extends StatelessWidget {
  /// Título do header
  final String title;

  /// Subtítulo opcional
  final String? subtitle;

  /// Ícone à esquerda (geralmente seta de voltar)
  final Widget? leading;

  /// Ações à direita
  final List<Widget>? actions;

  /// Callback para o botão de voltar
  final VoidCallback? onBackPressed;

  /// Margem externa
  final EdgeInsetsGeometry? margin;

  const PlantisHeader({
    super.key,
    required this.title,
    this.subtitle,
    this.leading,
    this.actions,
    this.onBackPressed,
    this.margin,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      margin: margin ?? const EdgeInsets.only(bottom: 8, top: 4),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Color(0xFF0D945A), // Verde primário
            Color(0xFF4DB377), // Verde mais claro
          ],
        ),
        borderRadius: BorderRadius.circular(16.0),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 12.0),
        child: Row(
          children: [
            if (leading != null || onBackPressed != null) ...[
              leading ??
                  IconButton(
                    icon: const Icon(Icons.arrow_back_ios, color: Colors.white),
                    onPressed:
                        onBackPressed ?? () => Navigator.of(context).pop(),
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(),
                  ),
              const SizedBox(width: 6),
            ],
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: theme.textTheme.headlineSmall?.copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 18,
                    ),
                  ),
                  if (subtitle != null) ...[
                    Text(
                      subtitle!,
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: Colors.white.withValues(alpha: 0.9),
                        fontSize: 14,
                      ),
                    ),
                  ],
                ],
              ),
            ),
            if (actions != null) ...[const SizedBox(width: 6), ...actions!],
          ],
        ),
      ),
    );
  }
}
