import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../theme/adaptive_colors.dart';
import '../theme/theme_providers.dart';
import 'category_menu.dart';

/// AppShell - Layout unificado para todas as páginas do app
/// 
/// Fornece estrutura consistente com:
/// - Sidebar (desktop) / Drawer (mobile)
/// - Header adaptativo (search bar ou título da página)
/// - Área de conteúdo flexível
/// 
/// Usado tanto pela HomePage quanto pelas páginas de calculadoras
class AppShell extends ConsumerStatefulWidget {
  /// Conteúdo principal da página
  final Widget child;
  
  /// Título da página (null = mostra search bar como na home)
  final String? pageTitle;
  
  /// Subtítulo da página (só aparece se pageTitle != null)
  final String? pageSubtitle;
  
  /// Cor de destaque da página
  final Color? accentColor;
  
  /// Ícone da página (usado no header e card da sidebar)
  final IconData? pageIcon;
  
  /// Ações extras no header (botões, etc)
  final List<Widget>? actions;
  
  /// Mostra botão de voltar no header
  final bool showBackButton;
  
  /// Mostra search bar no header (só se pageTitle == null)
  final TextEditingController? searchController;
  final ValueChanged<String>? onSearchChanged;
  final String? searchHint;
  
  /// Widget extra no header (ex: view toggle)
  final Widget? headerTrailing;
  
  /// Categoria atual selecionada
  final String? currentCategory;
  
  /// Filtro atual selecionado
  final String? currentFilter;
  
  /// Largura máxima do conteúdo
  final double maxContentWidth;
  
  /// Padding do conteúdo
  final EdgeInsets contentPadding;
  
  /// Se deve mostrar o background pattern
  final bool showBackgroundPattern;

  const AppShell({
    super.key,
    required this.child,
    this.pageTitle,
    this.pageSubtitle,
    this.accentColor,
    this.pageIcon,
    this.actions,
    this.showBackButton = false,
    this.searchController,
    this.onSearchChanged,
    this.searchHint,
    this.headerTrailing,
    this.currentCategory,
    this.currentFilter,
    this.maxContentWidth = double.infinity,
    this.contentPadding = EdgeInsets.zero,
    this.showBackgroundPattern = false,
  });

  @override
  ConsumerState<AppShell> createState() => _AppShellState();
}

class _AppShellState extends ConsumerState<AppShell> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isMobile = screenWidth < 800;
    final colors = context.colors;
    final accentColor = widget.accentColor ?? colors.primary;

    return Scaffold(
      key: _scaffoldKey,
      backgroundColor: colors.background,
      drawer: isMobile ? _buildDrawer(context, accentColor) : null,
      body: Row(
        children: [
          // Sidebar (desktop only)
          if (!isMobile) _buildSidebar(context, accentColor),

          // Main content
          Expanded(
            child: Column(
              children: [
                // Header
                _buildHeader(context, isMobile, accentColor),

                // Content
                Expanded(
                  child: _buildContent(context, accentColor),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ═══════════════════════════════════════════════════════════════════════════
  // DRAWER (Mobile)
  // ═══════════════════════════════════════════════════════════════════════════

  Widget _buildDrawer(BuildContext context, Color accentColor) {
    final colors = context.colors;
    return Drawer(
      backgroundColor: colors.sidebar,
      child: _buildSidebarContent(context, accentColor, isDrawer: true),
    );
  }

  // ═══════════════════════════════════════════════════════════════════════════
  // SIDEBAR (Desktop)
  // ═══════════════════════════════════════════════════════════════════════════

  Widget _buildSidebar(BuildContext context, Color accentColor) {
    final colors = context.colors;
    return ClipRRect(
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
        child: Container(
          width: 260,
          decoration: BoxDecoration(
            color: colors.sidebar.withValues(alpha: 0.95),
            border: Border(
              right: BorderSide(
                color: colors.sidebarBorder,
                width: 1,
              ),
            ),
          ),
          child: _buildSidebarContent(context, accentColor),
        ),
      ),
    );
  }

  Widget _buildSidebarContent(BuildContext context, Color accentColor, {bool isDrawer = false}) {
    return Column(
      children: [
        // Logo header
        _buildSidebarHeader(context, accentColor),

        // Category menu
        Expanded(
          child: SingleChildScrollView(
            child: CategoryMenu(
              currentCategory: widget.currentCategory,
              currentFilter: widget.currentFilter,
              closeDrawerOnTap: isDrawer,
              showBackToHome: false,
              showQuickFilters: true,
              showLegalLinks: true,
              themeToggleButton: _buildThemeToggle(context),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildSidebarHeader(BuildContext context, Color accentColor) {
    final colors = context.colors;
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        border: Border(
          bottom: BorderSide(
            color: colors.sidebarBorder,
          ),
        ),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [colors.primary, colors.primary.withValues(alpha: 0.7)],
              ),
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(
                  color: colors.primary.withValues(alpha: 0.3),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Icon(
              Icons.calculate_rounded,
              color: colors.onPrimary,
              size: 24,
            ),
          ),
          const SizedBox(width: 14),
          Text(
            'Calculei',
            style: TextStyle(
              color: colors.sidebarTextPrimary,
              fontSize: 22,
              fontWeight: FontWeight.bold,
              letterSpacing: 0.5,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildThemeToggle(BuildContext context) {
    final colors = context.colors;
    final themeMode = ref.watch(themeModeProvider);
    final isDark = themeMode == ThemeMode.dark || 
        (themeMode == ThemeMode.system && 
         MediaQuery.platformBrightnessOf(context) == Brightness.dark);
    
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        IconButton(
          icon: AnimatedSwitcher(
            duration: const Duration(milliseconds: 300),
            transitionBuilder: (child, animation) {
              return RotationTransition(
                turns: Tween(begin: 0.5, end: 1.0).animate(animation),
                child: FadeTransition(
                  opacity: animation,
                  child: child,
                ),
              );
            },
            child: Icon(
              isDark ? Icons.light_mode_rounded : Icons.dark_mode_rounded,
              key: ValueKey(isDark),
              color: colors.sidebarTextSecondary,
            ),
          ),
          onPressed: () {
            ref.read(themeModeProvider.notifier).toggleTheme();
            _showThemeSnackBar(context, !isDark);
          },
          tooltip: isDark ? 'Tema Claro' : 'Tema Escuro',
        ),
      ],
    );
  }

  void _showThemeSnackBar(BuildContext context, bool isDark) {
    ScaffoldMessenger.of(context).hideCurrentSnackBar();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Icon(
              isDark ? Icons.dark_mode_rounded : Icons.light_mode_rounded,
              color: Colors.white,
              size: 20,
            ),
            const SizedBox(width: 12),
            Text(
              isDark ? 'Tema Escuro ativado' : 'Tema Claro ativado',
              style: const TextStyle(fontWeight: FontWeight.w500),
            ),
          ],
        ),
        backgroundColor: isDark ? const Color(0xFF1A1A2E) : const Color(0xFF4CAF50),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        duration: const Duration(seconds: 2),
        margin: const EdgeInsets.all(16),
      ),
    );
  }

  // ═══════════════════════════════════════════════════════════════════════════
  // HEADER
  // ═══════════════════════════════════════════════════════════════════════════

  Widget _buildHeader(BuildContext context, bool isMobile, Color accentColor) {
    // Se tem título, mostra header de página interna
    if (widget.pageTitle != null) {
      return _buildPageHeader(context, isMobile, accentColor);
    }
    
    // Senão, mostra header de home com search
    return _buildHomeHeader(context, isMobile, accentColor);
  }

  Widget _buildHomeHeader(BuildContext context, bool isMobile, Color accentColor) {
    final colors = context.colors;
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: isMobile ? 16 : 32,
        vertical: 16,
      ),
      decoration: BoxDecoration(
        color: colors.surface.withValues(alpha: 0.5),
        border: Border(
          bottom: BorderSide(color: colors.border),
        ),
      ),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 1120),
          child: Row(
            children: [
              // Menu button (mobile only)
              if (isMobile) ...[
                IconButton(
                  icon: Icon(Icons.menu, color: colors.textPrimary),
                  onPressed: () => _scaffoldKey.currentState?.openDrawer(),
                ),
                const SizedBox(width: 8),
              ],

              // Search bar
              if (widget.searchController != null)
                Expanded(
                  child: Container(
                    constraints: const BoxConstraints(maxWidth: 500),
                    decoration: BoxDecoration(
                      color: colors.background,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: colors.border),
                    ),
                    child: TextField(
                      controller: widget.searchController,
                      onChanged: widget.onSearchChanged,
                      style: TextStyle(color: colors.textPrimary),
                      decoration: InputDecoration(
                        hintText: widget.searchHint ?? 'Pesquisar...',
                        hintStyle: TextStyle(color: colors.textHint),
                        prefixIcon: Icon(
                          Icons.search,
                          color: colors.textHint,
                        ),
                        border: InputBorder.none,
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 14,
                        ),
                      ),
                    ),
                  ),
                )
              else
                const Spacer(),

              // Header trailing widget
              if (widget.headerTrailing != null) ...[
                const SizedBox(width: 16),
                widget.headerTrailing!,
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPageHeader(BuildContext context, bool isMobile, Color accentColor) {
    final colors = context.colors;
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: isMobile ? 12 : 20,
        vertical: 20, // Match sidebar header padding
      ),
      decoration: BoxDecoration(
        color: colors.surface.withValues(alpha: 0.95),
        border: Border(
          bottom: BorderSide(
            color: colors.border,
          ),
        ),
      ),
      child: Row(
        children: [
          // Menu button (mobile only)
          if (isMobile)
            IconButton(
              icon: Icon(Icons.menu_rounded, color: colors.textPrimary),
              onPressed: () => _scaffoldKey.currentState?.openDrawer(),
              padding: EdgeInsets.zero,
              constraints: const BoxConstraints(minWidth: 40, minHeight: 40),
            ),
          
          // Back button
          if (widget.showBackButton)
            IconButton(
              icon: Icon(Icons.arrow_back_rounded, color: colors.textPrimary),
              onPressed: () {
                if (context.canPop()) {
                  context.pop();
                } else {
                  context.go('/home');
                }
              },
              padding: EdgeInsets.zero,
              constraints: const BoxConstraints(minWidth: 40, minHeight: 40),
            ),
          
          const SizedBox(width: 12),
          
          // Page icon - match sidebar logo size
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: accentColor.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              widget.pageIcon ?? Icons.calculate_rounded,
              color: accentColor,
              size: 24,
            ),
          ),
          
          const SizedBox(width: 14),
          
          // Title and subtitle
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  widget.pageTitle!,
                  style: TextStyle(
                    color: colors.textPrimary,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
                if (widget.pageSubtitle != null)
                  Text(
                    widget.pageSubtitle!,
                    style: TextStyle(
                      color: colors.textMuted,
                      fontSize: 13,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
              ],
            ),
          ),
          
          // Actions
          if (widget.actions != null) ...widget.actions!,
        ],
      ),
    );
  }

  // ═══════════════════════════════════════════════════════════════════════════
  // CONTENT
  // ═══════════════════════════════════════════════════════════════════════════

  Widget _buildContent(BuildContext context, Color accentColor) {
    final colors = context.colors;
    
    Widget content = widget.child;
    
    // Apply max width constraint if specified
    if (widget.maxContentWidth != double.infinity) {
      content = Center(
        child: ConstrainedBox(
          constraints: BoxConstraints(maxWidth: widget.maxContentWidth),
          child: content,
        ),
      );
    }
    
    // Apply padding if specified
    if (widget.contentPadding != EdgeInsets.zero) {
      content = Padding(
        padding: widget.contentPadding,
        child: content,
      );
    }
    
    // Add background pattern if specified
    if (widget.showBackgroundPattern) {
      // Opacidade reduzida para evitar interferência visual com o conteúdo
      final isDark = Theme.of(context).brightness == Brightness.dark;
      final patternOpacity = isDark ? 0.025 : 0.035;
      
      return Container(
        color: colors.background,
        child: Stack(
          children: [
            Positioned.fill(
              child: CustomPaint(
                painter: _BackgroundPatternPainter(
                  color: colors.textPrimary.withValues(alpha: patternOpacity),
                ),
              ),
            ),
            content,
          ],
        ),
      );
    }
    
    return content;
  }
}

// ═══════════════════════════════════════════════════════════════════════════
// BACKGROUND PATTERN PAINTER
// ═══════════════════════════════════════════════════════════════════════════

class _BackgroundPatternPainter extends CustomPainter {
  final Color color;

  _BackgroundPatternPainter({required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    // Símbolos matemáticos variados para criar um padrão interessante
    final symbols = [
      '+', '−', '×', '÷', '=', '%', 
      '√', 'π', '∑', '∞', '±', '≈',
      '∫', 'Δ', 'θ', 'λ', 'μ', 'σ',
      '²', '³', '⁄', '≤', '≥', '≠',
    ];
    
    const baseSpacing = 120.0;
    const rowOffset = 60.0; // Offset para criar padrão diagonal
    var symbolIndex = 0;
    var rowCount = 0;
    
    for (var y = -20.0; y < size.height + 40; y += baseSpacing * 0.7) {
      // Alterna offset horizontal a cada linha para padrão mais orgânico
      final xOffset = (rowCount % 2 == 0) ? 0.0 : rowOffset;
      
      for (var x = -20.0 + xOffset; x < size.width + 40; x += baseSpacing) {
        // Variação sutil de opacidade para criar profundidade
        final opacityVariation = 0.6 + (symbolIndex % 3) * 0.2;
        final symbolColor = color.withValues(alpha: color.a * opacityVariation);
        
        // Variação de tamanho para interesse visual
        final sizeVariation = 18.0 + (symbolIndex % 4) * 4.0;
        
        // Rotação sutil para alguns símbolos
        final shouldRotate = symbolIndex % 5 == 0;
        
        canvas.save();
        
        if (shouldRotate) {
          canvas.translate(x + sizeVariation / 2, y + sizeVariation / 2);
          canvas.rotate(0.1 + (symbolIndex % 3) * 0.05);
          canvas.translate(-sizeVariation / 2, -sizeVariation / 2);
          
          _drawSymbol(
            canvas, 
            Offset.zero, 
            symbols[symbolIndex % symbols.length],
            symbolColor,
            sizeVariation,
          );
        } else {
          _drawSymbol(
            canvas, 
            Offset(x, y), 
            symbols[symbolIndex % symbols.length],
            symbolColor,
            sizeVariation,
          );
        }
        
        canvas.restore();
        symbolIndex++;
      }
      rowCount++;
    }
  }
  
  void _drawSymbol(
    Canvas canvas, 
    Offset position, 
    String symbol,
    Color symbolColor,
    double fontSize,
  ) {
    final textPainter = TextPainter(
      text: TextSpan(
        text: symbol,
        style: TextStyle(
          color: symbolColor,
          fontSize: fontSize,
          fontWeight: FontWeight.w200,
          fontFamily: 'SF Pro Display', // Fallback to system font
        ),
      ),
      textDirection: TextDirection.ltr,
    )..layout();
    
    textPainter.paint(canvas, position);
  }

  @override
  bool shouldRepaint(covariant _BackgroundPatternPainter oldDelegate) => 
      oldDelegate.color != color;
}
