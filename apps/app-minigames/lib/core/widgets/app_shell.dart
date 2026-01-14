import 'dart:ui';
import 'package:core/core.dart' show FeedbackDialog;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../features/home/domain/enums/game_category.dart';
import '../../features/home/presentation/providers/home_providers.dart';
import '../../widgets/theme_toggle_button.dart';
import '../providers/user_preferences_providers.dart';

/// URLs para políticas
class _LegalUrls {
  static const String privacyPolicy =
      'https://agrimindapps.blogspot.com/2022/08/a-agrimind-apps-construiu-o-aplicativo.html';
  static const String termsOfUse =
      'https://agrimindapps.blogspot.com/2022/08/receituagro-termos-e-condicoes.html';
}

/// AppShell - Layout unificado para todas as páginas do app MiniGames
///
/// Fornece estrutura consistente com:
/// - Sidebar (desktop) / Drawer (mobile)
/// - Header adaptativo (search bar ou título do jogo)
/// - Área de conteúdo flexível
///
/// Usado tanto pela HomePage quanto pelas páginas de jogos
class AppShell extends ConsumerStatefulWidget {
  /// Conteúdo principal da página
  final Widget child;

  /// Título da página (null = home, mostra search bar)
  final String? pageTitle;

  /// Cor de destaque da página
  final Color? accentColor;

  /// Ações extras no header
  final List<Widget>? actions;

  /// Mostra botão de voltar no header
  final bool showBackButton;

  /// Mostra card com info do jogo atual na sidebar
  final bool showCurrentGameCard;

  /// Instruções do jogo (só aparece se showCurrentGameCard = true)
  final String? instructions;

  /// Widget de search (para home)
  final Widget? searchWidget;

  /// Widget extra no header (ex: profile button)
  final Widget? headerTrailing;

  /// Se a sidebar deve poder ser colapsada
  final bool collapsibleSidebar;

  const AppShell({
    super.key,
    required this.child,
    this.pageTitle,
    this.accentColor,
    this.actions,
    this.showBackButton = false,
    this.showCurrentGameCard = false,
    this.instructions,
    this.searchWidget,
    this.headerTrailing,
    this.collapsibleSidebar = false,
  });

  @override
  ConsumerState<AppShell> createState() => _AppShellState();
}

class _AppShellState extends ConsumerState<AppShell> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  bool _sidebarCollapsed = false;

  // Cores padrão do MiniGames
  static const _backgroundColor = Color(0xFF0F0F1A);
  static const _sidebarColor = Color(0xFF1A1A2E);
  static const _defaultAccentColor = Color(0xFFFFD700);

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isMobile = screenWidth < 800;
    final isTablet = screenWidth >= 800 && screenWidth < 1200;
    final accentColor = widget.accentColor ?? _defaultAccentColor;

    return Scaffold(
      key: _scaffoldKey,
      backgroundColor: _backgroundColor,
      drawer: isMobile ? _buildDrawer(context, accentColor) : null,
      body: Row(
        children: [
          // Sidebar (desktop/tablet)
          if (!isMobile)
            _buildSidebar(
              context,
              accentColor,
              isCollapsed: widget.collapsibleSidebar && isTablet
                  ? _sidebarCollapsed
                  : false,
              canCollapse: widget.collapsibleSidebar && isTablet,
            ),

          // Main content
          Expanded(
            child: Column(
              children: [
                // Header
                _buildHeader(context, isMobile, accentColor),

                // Content
                Expanded(child: widget.child),
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
    return Drawer(
      backgroundColor: _sidebarColor,
      child: _buildSidebarContent(context, accentColor, isDrawer: true),
    );
  }

  // ═══════════════════════════════════════════════════════════════════════════
  // SIDEBAR (Desktop)
  // ═══════════════════════════════════════════════════════════════════════════

  Widget _buildSidebar(
    BuildContext context,
    Color accentColor, {
    bool isCollapsed = false,
    bool canCollapse = false,
  }) {
    return ClipRRect(
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
        child: Container(
          width: isCollapsed ? 70 : 240,
          decoration: BoxDecoration(
            color: _sidebarColor.withValues(alpha: 0.85),
            border: Border(
              right: BorderSide(
                color: Colors.white.withValues(alpha: 0.1),
                width: 1,
              ),
            ),
          ),
          child: _buildSidebarContent(
            context,
            accentColor,
            isCollapsed: isCollapsed,
            canCollapse: canCollapse,
          ),
        ),
      ),
    );
  }

  Widget _buildSidebarContent(
    BuildContext context,
    Color accentColor, {
    bool isDrawer = false,
    bool isCollapsed = false,
    bool canCollapse = false,
  }) {
    return Column(
      children: [
        // Logo header
        _buildSidebarHeader(isCollapsed),

        // Categories section (from home sidebar)
        Expanded(
          child: _buildCategoriesSection(context, isCollapsed, isDrawer),
        ),

        // Feedback button
        if (!isCollapsed) ...[
          Divider(color: Colors.white.withValues(alpha: 0.1), height: 1),
          _buildFeedbackButton(context, isDrawer),
        ],

        // Legal links
        if (!isCollapsed) ...[
          Divider(color: Colors.white.withValues(alpha: 0.1), height: 1),
          _buildLegalLinksSection(),
        ],

        // Theme toggle
        if (!isCollapsed) ...[
          Divider(color: Colors.white.withValues(alpha: 0.1), height: 1),
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 8),
            child: ThemeToggleButton(
              color: Colors.white.withValues(alpha: 0.7),
            ),
          ),
        ],

        // Collapse button
        if (canCollapse)
          InkWell(
            onTap: () => setState(() => _sidebarCollapsed = !_sidebarCollapsed),
            child: Container(
              padding: const EdgeInsets.all(16),
              child: Icon(
                isCollapsed ? Icons.chevron_right : Icons.chevron_left,
                color: Colors.white54,
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildSidebarHeader(bool isCollapsed) {
    return Container(
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFFFFD700), Color(0xFFFFA000)],
              ),
              borderRadius: BorderRadius.circular(10),
            ),
            child: const Icon(Icons.games, color: Colors.white, size: 24),
          ),
          if (!isCollapsed) ...[
            const SizedBox(width: 12),
            const Text(
              'MiniGames',
              style: TextStyle(
                color: Colors.white,
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildCategoriesSection(
    BuildContext context,
    bool isCollapsed,
    bool isDrawer,
  ) {
    final selectedCategory = ref.watch(selectedCategoryProvider);
    final categoryCounts = ref.watch(categoryCountsProvider);
    final favoriteGames = ref.watch(favoriteGameEntitiesProvider);
    final recentGames = ref.watch(recentGameEntitiesProvider);
    final newGamesCount = ref.watch(newGamesProvider).length;
    final multiplayerCount = ref.watch(multiplayerGamesProvider).length;

    return ListView(
      padding: const EdgeInsets.symmetric(vertical: 8),
      children: [
        _SectionHeader(title: 'Filtros Rápidos', isCollapsed: isCollapsed),
        _SidebarItem(
          icon: Icons.favorite,
          label: 'Favoritos',
          count: favoriteGames.length,
          color: Colors.pink,
          isSelected: false,
          isCollapsed: isCollapsed,
          onTap: () {
            if (isDrawer) Navigator.of(context).pop();
            context.go('/');
          },
        ),
        _SidebarItem(
          icon: Icons.history,
          label: 'Recentes',
          count: recentGames.length,
          color: Colors.purple,
          isSelected: false,
          isCollapsed: isCollapsed,
          onTap: () {
            if (isDrawer) Navigator.of(context).pop();
            context.go('/');
          },
        ),
        _SidebarItem(
          icon: Icons.star,
          label: 'Novos jogos',
          count: newGamesCount,
          color: Colors.amber,
          isSelected: false,
          isCollapsed: isCollapsed,
          onTap: () {
            if (isDrawer) Navigator.of(context).pop();
            context.go('/');
          },
        ),
        _SidebarItem(
          icon: Icons.people,
          label: 'Multijogador',
          count: multiplayerCount,
          color: Colors.blue,
          isSelected: false,
          isCollapsed: isCollapsed,
          onTap: () {
            if (isDrawer) Navigator.of(context).pop();
            context.go('/');
          },
        ),

        const SizedBox(height: 12),
        _SectionHeader(title: 'Categorias', isCollapsed: isCollapsed),

        // Categories
        ...GameCategory.values.map((category) {
          return _SidebarItem(
            icon: _getCategoryIcon(category),
            label: category.displayName,
            count: categoryCounts[category] ?? 0,
            emoji: category.emoji,
            isSelected: selectedCategory == category,
            isCollapsed: isCollapsed,
            onTap: () {
              ref.read(selectedCategoryProvider.notifier).select(category);
              if (isDrawer) Navigator.of(context).pop();
              context.go('/');
            },
          );
        }),
      ],
    );
  }

  Widget _buildFeedbackButton(BuildContext context, bool isDrawer) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () {
            if (isDrawer) {
              Navigator.of(context).pop();
            }
            FeedbackDialog.show(context, primaryColor: const Color(0xFFFFD700));
          },
          borderRadius: BorderRadius.circular(10),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: const Color(0xFFFFD700).withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(10),
              border: Border.all(
                color: const Color(0xFFFFD700).withValues(alpha: 0.2),
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(
                  Icons.feedback_outlined,
                  color: Color(0xFFFFD700),
                  size: 18,
                ),
                const SizedBox(width: 8),
                Text(
                  'Enviar Feedback',
                  style: TextStyle(
                    color: Colors.white.withValues(alpha: 0.9),
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildLegalLinksSection() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          _buildLegalLink(label: 'Privacidade', url: _LegalUrls.privacyPolicy),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8),
            child: Text(
              '•',
              style: TextStyle(
                color: Colors.white.withValues(alpha: 0.4),
                fontSize: 10,
              ),
            ),
          ),
          _buildLegalLink(label: 'Termos de Uso', url: _LegalUrls.termsOfUse),
        ],
      ),
    );
  }

  Widget _buildLegalLink({required String label, required String url}) {
    return InkWell(
      onTap: () async {
        final uri = Uri.parse(url);
        if (await canLaunchUrl(uri)) {
          await launchUrl(uri, mode: LaunchMode.externalApplication);
        }
      },
      borderRadius: BorderRadius.circular(4),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
        child: Text(
          label,
          style: TextStyle(
            color: Colors.white.withValues(alpha: 0.4),
            fontSize: 11,
            decoration: TextDecoration.underline,
            decorationColor: Colors.white.withValues(alpha: 0.4),
          ),
        ),
      ),
    );
  }

  IconData _getCategoryIcon(GameCategory category) {
    switch (category) {
      case GameCategory.all:
        return Icons.apps;
      case GameCategory.puzzle:
        return Icons.extension;
      case GameCategory.strategy:
        return Icons.psychology;
      case GameCategory.arcade:
        return Icons.sports_esports;
      case GameCategory.word:
        return Icons.text_fields;
      case GameCategory.quiz:
        return Icons.quiz;
      case GameCategory.classic:
        return Icons.star;
      case GameCategory.casual:
        return Icons.emoji_emotions;
    }
  }

  // ═══════════════════════════════════════════════════════════════════════════
  // HEADER
  // ═══════════════════════════════════════════════════════════════════════════

  Widget _buildHeader(BuildContext context, bool isMobile, Color accentColor) {
    // Se tem título, mostra header de página de jogo
    if (widget.pageTitle != null) {
      return _buildGameHeader(context, isMobile, accentColor);
    }

    // Senão, mostra header de home
    return _buildHomeHeader(context, isMobile);
  }

  Widget _buildHomeHeader(BuildContext context, bool isMobile) {
    return ClipRRect(
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
        child: Container(
          padding: EdgeInsets.symmetric(
            horizontal: isMobile ? 12 : 24,
            vertical: 12,
          ),
          decoration: BoxDecoration(
            color: _backgroundColor.withValues(alpha: 0.8),
            border: Border(
              bottom: BorderSide(
                color: Colors.white.withValues(alpha: 0.1),
                width: 1,
              ),
            ),
          ),
          child: Row(
            children: [
              // Menu button (mobile)
              if (isMobile)
                IconButton(
                  icon: const Icon(Icons.menu, color: Colors.white),
                  onPressed: () => _scaffoldKey.currentState?.openDrawer(),
                ),

              // Search widget
              if (widget.searchWidget != null)
                Expanded(child: widget.searchWidget!),

              // Header trailing
              if (widget.headerTrailing != null) widget.headerTrailing!,
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildGameHeader(
    BuildContext context,
    bool isMobile,
    Color accentColor,
  ) {
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: isMobile ? 8 : 16,
        vertical: isMobile ? 8 : 12,
      ),
      decoration: BoxDecoration(
        color: _sidebarColor.withValues(alpha: 0.9),
        border: Border(
          bottom: BorderSide(color: Colors.white.withValues(alpha: 0.1)),
        ),
      ),
      child: Row(
        children: [
          // Menu button (mobile)
          if (isMobile)
            IconButton(
              icon: const Icon(Icons.menu, color: Colors.white, size: 22),
              onPressed: () => _scaffoldKey.currentState?.openDrawer(),
              padding: const EdgeInsets.all(8),
              constraints: const BoxConstraints(),
            ),

          // Back button
          if (widget.showBackButton)
            IconButton(
              icon: Icon(
                Icons.arrow_back,
                color: Colors.white,
                size: isMobile ? 22 : 24,
              ),
              onPressed: () => context.go('/'),
              tooltip: 'Voltar ao Início',
              padding: EdgeInsets.all(isMobile ? 8 : 12),
              constraints: const BoxConstraints(),
            ),

          SizedBox(width: isMobile ? 4 : 8),

          // Game icon (desktop only)
          if (!isMobile)
            Container(
              padding: const EdgeInsets.all(6),
              decoration: BoxDecoration(
                color: accentColor.withValues(alpha: 0.2),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(Icons.sports_esports, color: accentColor, size: 20),
            ),

          SizedBox(width: isMobile ? 4 : 12),

          // Title
          Flexible(
            child: Text(
              widget.pageTitle!,
              style: TextStyle(
                color: Colors.white,
                fontSize: isMobile ? 16 : 20,
                fontWeight: FontWeight.bold,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),

          const SizedBox(width: 8),

          // Actions
          if (widget.actions != null) ...widget.actions!,
        ],
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════════════════
// HELPER WIDGETS
// ═══════════════════════════════════════════════════════════════════════════

class _SectionHeader extends StatelessWidget {
  final String title;
  final bool isCollapsed;

  const _SectionHeader({required this.title, required this.isCollapsed});

  @override
  Widget build(BuildContext context) {
    if (isCollapsed) {
      return const SizedBox(height: 8);
    }

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 6),
      child: Text(
        title.toUpperCase(),
        style: TextStyle(
          color: Colors.white.withValues(alpha: 0.4),
          fontSize: 10,
          fontWeight: FontWeight.bold,
          letterSpacing: 1.2,
        ),
      ),
    );
  }
}

class _SidebarItem extends StatefulWidget {
  final IconData icon;
  final String label;
  final int? count;
  final String? emoji;
  final Color? color;
  final bool isSelected;
  final bool isCollapsed;
  final VoidCallback onTap;

  const _SidebarItem({
    required this.icon,
    required this.label,
    this.count,
    this.emoji,
    this.color,
    required this.isSelected,
    required this.isCollapsed,
    required this.onTap,
  });

  @override
  State<_SidebarItem> createState() => _SidebarItemState();
}

class _SidebarItemState extends State<_SidebarItem> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    final isActive = widget.isSelected || _isHovered;

    return MouseRegion(
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      child: InkWell(
        onTap: widget.onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 150),
          margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 1),
          padding: EdgeInsets.symmetric(
            horizontal: widget.isCollapsed ? 8 : 12,
            vertical: 8,
          ),
          decoration: BoxDecoration(
            color: isActive
                ? Colors.white.withValues(alpha: 0.1)
                : Colors.transparent,
            borderRadius: BorderRadius.circular(8),
            border: widget.isSelected
                ? Border.all(
                    color: widget.color ?? const Color(0xFFFFD700),
                    width: 1,
                  )
                : null,
          ),
          child: Row(
            children: [
              // Icon or emoji
              if (widget.emoji != null && !widget.isCollapsed)
                Text(widget.emoji!, style: const TextStyle(fontSize: 16))
              else
                Icon(
                  widget.icon,
                  color: widget.color ?? Colors.white70,
                  size: 18,
                ),

              if (!widget.isCollapsed) ...[
                const SizedBox(width: 10),

                // Label
                Expanded(
                  child: Text(
                    widget.label,
                    style: TextStyle(
                      color: isActive ? Colors.white : Colors.white70,
                      fontSize: 13,
                      fontWeight: widget.isSelected
                          ? FontWeight.w600
                          : FontWeight.normal,
                    ),
                  ),
                ),

                // Count badge
                if (widget.count != null && widget.count! > 0)
                  Container(
                    constraints: const BoxConstraints(minWidth: 24),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 6,
                      vertical: 2,
                    ),
                    decoration: BoxDecoration(
                      color:
                          widget.color?.withValues(alpha: 0.15) ??
                          Colors.white.withValues(alpha: 0.08),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      '${widget.count}',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: widget.color ?? Colors.white60,
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
