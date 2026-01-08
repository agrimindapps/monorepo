import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

/// Layout wrapper for game pages that matches the home page style
/// Includes sidebar (on desktop), consistent colors, and proper spacing
class GamePageLayout extends StatefulWidget {
  final String title;
  final Widget child;
  final Color? accentColor;
  final List<Widget>? actions;
  final Widget? bottomWidget;
  final String? instructions;
  final double maxGameWidth;
  /// If true, wraps content in SingleChildScrollView (for Flutter widgets)
  /// If false, uses Expanded for Flame games that need full space
  final bool scrollable;
  
  const GamePageLayout({
    super.key,
    required this.title,
    required this.child,
    this.accentColor,
    this.actions,
    this.bottomWidget,
    this.instructions,
    this.maxGameWidth = 600,
    this.scrollable = false,
  });

  @override
  State<GamePageLayout> createState() => _GamePageLayoutState();
}

class _GamePageLayoutState extends State<GamePageLayout> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isMobile = screenWidth < 800;
    final accentColor = widget.accentColor ?? const Color(0xFFFFD700);

    return Scaffold(
      key: _scaffoldKey,
      backgroundColor: const Color(0xFF0F0F1A),
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

  Widget _buildDrawer(BuildContext context, Color accentColor) {
    return Drawer(
      backgroundColor: const Color(0xFF1A1A2E),
      child: _buildSidebarContent(context, accentColor, isDrawer: true),
    );
  }

  Widget _buildSidebar(BuildContext context, Color accentColor) {
    return ClipRRect(
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
        child: Container(
          width: 240,
          decoration: BoxDecoration(
            color: const Color(0xFF1A1A2E).withValues(alpha: 0.85),
            border: Border(
              right: BorderSide(
                color: Colors.white.withValues(alpha: 0.1),
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
        // Header with logo
        Container(
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
                child: const Icon(
                  Icons.games,
                  color: Colors.white,
                  size: 24,
                ),
              ),
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
          ),
        ),

        const Divider(color: Colors.white12, height: 1),

        // Current game info
        Padding(
          padding: const EdgeInsets.all(16),
          child: Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: accentColor.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: accentColor.withValues(alpha: 0.3),
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(
                      Icons.sports_esports,
                      color: accentColor,
                      size: 20,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      'Jogando',
                      style: TextStyle(
                        color: accentColor,
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Text(
                  widget.title,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
        ),

        // Instructions if provided
        if (widget.instructions != null) ...[
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.05),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(
                        Icons.info_outline,
                        color: Colors.white.withValues(alpha: 0.7),
                        size: 16,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        'Como jogar',
                        style: TextStyle(
                          color: Colors.white.withValues(alpha: 0.7),
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    widget.instructions!,
                    style: TextStyle(
                      color: Colors.white.withValues(alpha: 0.6),
                      fontSize: 12,
                      height: 1.4,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],

        const Spacer(),

        // Back to home button
        Padding(
          padding: const EdgeInsets.all(16),
          child: SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: () {
                if (isDrawer) Navigator.of(context).pop();
                context.go('/');
              },
              icon: const Icon(Icons.home),
              label: const Text('Voltar ao Início'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.white.withValues(alpha: 0.1),
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildHeader(BuildContext context, bool isMobile, Color accentColor) {
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: isMobile ? 8 : 16, 
        vertical: isMobile ? 8 : 12,
      ),
      decoration: BoxDecoration(
        color: const Color(0xFF1A1A2E).withValues(alpha: 0.9),
        border: Border(
          bottom: BorderSide(
            color: Colors.white.withValues(alpha: 0.1),
          ),
        ),
      ),
      child: Row(
        children: [
          if (isMobile)
            IconButton(
              icon: const Icon(Icons.menu, color: Colors.white, size: 22),
              onPressed: () => _scaffoldKey.currentState?.openDrawer(),
              padding: const EdgeInsets.all(8),
              constraints: const BoxConstraints(),
            ),
          
          IconButton(
            icon: Icon(Icons.arrow_back, color: Colors.white, size: isMobile ? 22 : 24),
            onPressed: () => context.go('/'),
            tooltip: 'Voltar ao Início',
            padding: EdgeInsets.all(isMobile ? 8 : 12),
            constraints: const BoxConstraints(),
          ),
          
          SizedBox(width: isMobile ? 4 : 8),
          
          if (!isMobile) // Hide icon on mobile to save space
            Container(
              padding: const EdgeInsets.all(6),
              decoration: BoxDecoration(
                color: accentColor.withValues(alpha: 0.2),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(
                Icons.sports_esports,
                color: accentColor,
                size: 20,
              ),
            ),
          
          SizedBox(width: isMobile ? 4 : 12),
          
          Flexible(
            child: Text(
              widget.title,
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
          
          if (widget.actions != null) 
            ...widget.actions!.map((action) {
              // Make action buttons more compact on mobile
              if (isMobile && action is IconButton) {
                return IconButton(
                  icon: action.icon ?? const Icon(Icons.more_vert),
                  onPressed: action.onPressed,
                  tooltip: action.tooltip,
                  color: Colors.white,
                  iconSize: 22,
                  padding: const EdgeInsets.all(8),
                  constraints: const BoxConstraints(),
                );
              }
              return action;
            }),
        ],
      ),
    );
  }

  Widget _buildContent(BuildContext context, Color accentColor) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isMobile = screenWidth < 800;
    
    // On mobile, use minimal/no padding and constraints for fullscreen
    final effectivePadding = isMobile 
        ? const EdgeInsets.all(8) 
        : const EdgeInsets.all(24);
    
    final effectiveMaxWidth = isMobile 
        ? screenWidth // Full width on mobile
        : widget.maxGameWidth;
    
    // Mobile games should have minimal border radius for more screen space
    final effectiveBorderRadius = isMobile ? 8.0 : 16.0;
    
    final gameContainer = Container(
      constraints: BoxConstraints(
        maxWidth: effectiveMaxWidth,
      ),
      decoration: BoxDecoration(
        color: isMobile 
            ? Colors.transparent // No background on mobile for more space
            : const Color(0xFF1A1A2E).withValues(alpha: 0.5),
        borderRadius: BorderRadius.circular(effectiveBorderRadius),
        border: isMobile 
            ? null // No border on mobile
            : Border.all(
                color: accentColor.withValues(alpha: 0.2),
              ),
        boxShadow: isMobile 
            ? null // No shadow on mobile
            : [
                BoxShadow(
                  color: accentColor.withValues(alpha: 0.1),
                  blurRadius: 20,
                  spreadRadius: 2,
                ),
              ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(effectiveBorderRadius),
        child: RepaintBoundary(
          child: widget.child,
        ),
      ),
    );

    final bottomSection = widget.bottomWidget != null
        ? Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              SizedBox(height: isMobile ? 8 : 16),
              Container(
                constraints: BoxConstraints(
                  maxWidth: effectiveMaxWidth,
                ),
                child: widget.bottomWidget!,
              ),
            ],
          )
        : const SizedBox.shrink();

    return Container(
      decoration: const BoxDecoration(
        color: Color(0xFF0F0F1A),
      ),
      child: RepaintBoundary(
        child: CustomPaint(
          painter: isMobile ? null : _BackgroundPatternPainter(), // Skip pattern on mobile for performance
          child: widget.scrollable
              // Scrollable mode for Flutter widget games (TicTacToe, etc)
              ? Center(
                  child: SingleChildScrollView(
                    padding: effectivePadding,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        gameContainer,
                        bottomSection,
                      ],
                    ),
                  ),
                )
              // Non-scrollable mode for Flame games - fullscreen on mobile
              : isMobile
                  // Mobile: No padding, fullscreen game
                  ? Column(
                      children: [
                        Expanded(child: gameContainer),
                        bottomSection,
                      ],
                    )
                  // Desktop: Centered with padding
                  : Padding(
                      padding: effectivePadding,
                      child: Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Expanded(child: gameContainer),
                            bottomSection,
                          ],
                        ),
                      ),
                    ),
        ),
      ),
    );
  }
}

/// Background pattern painter for game portal aesthetic
class _BackgroundPatternPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    const spacing = 60.0;
    final icons = ['♠', '♥', '♦', '♣', '★', '●', '▲', '■'];
    var iconIndex = 0;

    for (var y = 0.0; y < size.height; y += spacing) {
      for (var x = 0.0; x < size.width; x += spacing) {
        final textPainter = TextPainter(
          text: TextSpan(
            text: icons[iconIndex % icons.length],
            style: TextStyle(
              color: Colors.white.withValues(alpha: 0.03),
              fontSize: 20,
            ),
          ),
          textDirection: TextDirection.ltr,
        );
        textPainter.layout();
        textPainter.paint(canvas, Offset(x, y));
        iconIndex++;
      }
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
