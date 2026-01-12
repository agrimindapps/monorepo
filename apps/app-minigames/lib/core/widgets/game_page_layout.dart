import 'package:flutter/material.dart';

import 'app_shell.dart';

/// Layout wrapper for game pages that uses AppShell for consistent structure
/// 
/// Includes sidebar (on desktop), consistent colors, and proper spacing.
/// This is a simplified wrapper around AppShell with game-specific content styling.
class GamePageLayout extends StatelessWidget {
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
  Widget build(BuildContext context) {
    return AppShell(
      pageTitle: title,
      accentColor: accentColor,
      actions: actions,
      showBackButton: true,
      showCurrentGameCard: true,
      instructions: instructions,
      child: _GameContent(
        accentColor: accentColor ?? const Color(0xFFFFD700),
        maxGameWidth: maxGameWidth,
        scrollable: scrollable,
        bottomWidget: bottomWidget,
        child: child,
      ),
    );
  }
}

/// Internal widget for game content with proper styling
class _GameContent extends StatelessWidget {
  final Color accentColor;
  final double maxGameWidth;
  final bool scrollable;
  final Widget? bottomWidget;
  final Widget child;

  const _GameContent({
    required this.accentColor,
    required this.maxGameWidth,
    required this.scrollable,
    this.bottomWidget,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isMobile = screenWidth < 800;
    
    // On mobile, use minimal/no padding and constraints for fullscreen
    final effectivePadding = isMobile 
        ? const EdgeInsets.all(8) 
        : const EdgeInsets.all(24);
    
    final effectiveMaxWidth = isMobile 
        ? screenWidth // Full width on mobile
        : maxGameWidth;
    
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
          child: child,
        ),
      ),
    );

    final bottomSection = bottomWidget != null
        ? Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              SizedBox(height: isMobile ? 8 : 16),
              Container(
                constraints: BoxConstraints(
                  maxWidth: effectiveMaxWidth,
                ),
                child: bottomWidget!,
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
          child: scrollable
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
