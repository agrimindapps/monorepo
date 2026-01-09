import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import 'category_menu.dart';

/// Layout wrapper for calculator pages matching the MiniGames portal style
/// Includes sidebar (on desktop), consistent dark theme, and proper spacing
class CalculatorPageLayout extends StatefulWidget {
  final String title;
  final String? subtitle;
  final Widget child;
  final Color? accentColor;
  final List<Widget>? actions;
  final Widget? bottomWidget;
  final IconData? icon;
  final double maxContentWidth;
  final String? currentCategory;
  
  const CalculatorPageLayout({
    super.key,
    required this.title,
    required this.child,
    this.subtitle,
    this.accentColor,
    this.actions,
    this.bottomWidget,
    this.icon,
    this.maxContentWidth = 800,
    this.currentCategory,
  });

  @override
  State<CalculatorPageLayout> createState() => _CalculatorPageLayoutState();
}

class _CalculatorPageLayoutState extends State<CalculatorPageLayout> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  // Core colors for dark theme
  static const _backgroundColor = Color(0xFF0F0F1A);
  static const _sidebarColor = Color(0xFF1A1A2E);
  static const _defaultAccent = Color(0xFF4CAF50); // Green for calculators

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isMobile = screenWidth < 800;
    final accentColor = widget.accentColor ?? _defaultAccent;

    return Scaffold(
      key: _scaffoldKey,
      backgroundColor: _backgroundColor,
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
      backgroundColor: _sidebarColor,
      child: _buildSidebarContent(context, accentColor, isDrawer: true),
    );
  }

  Widget _buildSidebar(BuildContext context, Color accentColor) {
    return ClipRRect(
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
        child: Container(
          width: 260,
          decoration: BoxDecoration(
            color: _sidebarColor.withValues(alpha: 0.85),
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
        // Header with logo - same height as main header
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
          decoration: BoxDecoration(
            border: Border(
              bottom: BorderSide(
                color: Colors.white.withValues(alpha: 0.1),
              ),
            ),
          ),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [accentColor, accentColor.withValues(alpha: 0.7)],
                  ),
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [
                    BoxShadow(
                      color: accentColor.withValues(alpha: 0.3),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: const Icon(
                  Icons.calculate_rounded,
                  color: Colors.white,
                  size: 24,
                ),
              ),
              const SizedBox(width: 14),
              const Text(
                'Calculei',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 0.5,
                ),
              ),
            ],
          ),
        ),

        // Current calculator info card
        Padding(
          padding: const EdgeInsets.all(16),
          child: Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: accentColor.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(14),
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
                      widget.icon ?? Icons.calculate,
                      color: accentColor,
                      size: 18,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      'Calculando',
                      style: TextStyle(
                        color: accentColor,
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 0.5,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                Text(
                  widget.title,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 17,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                if (widget.subtitle != null) ...[
                  const SizedBox(height: 4),
                  Text(
                    widget.subtitle!,
                    style: TextStyle(
                      color: Colors.white.withValues(alpha: 0.6),
                      fontSize: 13,
                    ),
                  ),
                ],
              ],
            ),
          ),
        ),

        // Category menu with back button and theme toggle
        Expanded(
          child: SingleChildScrollView(
            child: CategoryMenu(
              currentCategory: widget.currentCategory,
              closeDrawerOnTap: isDrawer,
              showBackToHome: true,
              themeToggleButton: _buildThemeToggle(),
            ),
          ),
        ),

        const SizedBox(height: 20),
      ],
    );
  }

  Widget _buildThemeToggle() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        // Import ThemeToggleButton if needed, or create simple icon button
        IconButton(
          icon: Icon(
            Icons.brightness_6,
            color: Colors.white.withValues(alpha: 0.7),
          ),
          onPressed: () {
            // Toggle theme - will be implemented with Riverpod provider
          },
          tooltip: 'Alternar Tema',
        ),
      ],
    );
  }

  Widget _buildHeader(BuildContext context, bool isMobile, Color accentColor) {
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: isMobile ? 12 : 20,
        vertical: 16,
      ),
      decoration: BoxDecoration(
        color: _sidebarColor.withValues(alpha: 0.95),
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
              icon: const Icon(Icons.menu_rounded, color: Colors.white),
              onPressed: () => _scaffoldKey.currentState?.openDrawer(),
              padding: EdgeInsets.zero,
              constraints: const BoxConstraints(minWidth: 40, minHeight: 40),
            ),
          
          IconButton(
            icon: const Icon(Icons.arrow_back_rounded, color: Colors.white),
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
          
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: accentColor.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              widget.icon ?? Icons.calculate_rounded,
              color: accentColor,
              size: 24,
            ),
          ),
          
          const SizedBox(width: 14),
          
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  widget.title,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
                if (widget.subtitle != null)
                  Text(
                    widget.subtitle!,
                    style: TextStyle(
                      color: Colors.white.withValues(alpha: 0.6),
                      fontSize: 13,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
              ],
            ),
          ),
          
          if (widget.actions != null) ...widget.actions!,
        ],
      ),
    );
  }

  Widget _buildContent(BuildContext context, Color accentColor) {
    return Container(
      decoration: const BoxDecoration(
        color: _backgroundColor,
      ),
      child: CustomPaint(
        painter: _CalculatorBackgroundPainter(accentColor: accentColor),
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Calculator container with max width
                Container(
                  constraints: BoxConstraints(
                    maxWidth: widget.maxContentWidth,
                  ),
                  decoration: BoxDecoration(
                    color: _sidebarColor.withValues(alpha: 0.6),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: accentColor.withValues(alpha: 0.2),
                      width: 1.5,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: accentColor.withValues(alpha: 0.08),
                        blurRadius: 30,
                        spreadRadius: 0,
                      ),
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.3),
                        blurRadius: 20,
                        offset: const Offset(0, 10),
                      ),
                    ],
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(20),
                    child: widget.child,
                  ),
                ),
                
                // Bottom widget (additional info, tips, etc)
                if (widget.bottomWidget != null) ...[
                  const SizedBox(height: 20),
                  Container(
                    constraints: BoxConstraints(
                      maxWidth: widget.maxContentWidth,
                    ),
                    child: widget.bottomWidget!,
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// Background pattern painter with calculator/math symbols
class _CalculatorBackgroundPainter extends CustomPainter {
  final Color accentColor;
  
  _CalculatorBackgroundPainter({required this.accentColor});

  @override
  void paint(Canvas canvas, Size size) {
    const spacing = 70.0;
    final symbols = ['+', '−', '×', '÷', '%', '=', '√', 'π', '∑', '∞'];
    var symbolIndex = 0;

    for (var y = 0.0; y < size.height; y += spacing) {
      for (var x = 0.0; x < size.width; x += spacing) {
        final textPainter = TextPainter(
          text: TextSpan(
            text: symbols[symbolIndex % symbols.length],
            style: TextStyle(
              color: Colors.white.withValues(alpha: 0.025),
              fontSize: 24,
              fontWeight: FontWeight.w300,
            ),
          ),
          textDirection: TextDirection.ltr,
        );
        textPainter
          ..layout()
          ..paint(canvas, Offset(x, y));
        symbolIndex++;
      }
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

/// Category accent colors for different calculator types
class CalculatorAccentColors {
  static const financial = Color(0xFF4CAF50);     // Green
  static const health = Color(0xFFE91E63);        // Pink
  static const construction = Color(0xFFFF9800);  // Orange
  static const agriculture = Color(0xFF8BC34A);   // Light green
  static const pet = Color(0xFF795548);           // Brown
  static const labor = Color(0xFF2196F3);         // Blue
  
  /// Get accent color by category name
  static Color fromCategory(String category) {
    switch (category.toLowerCase()) {
      case 'financeiro':
      case 'financial':
        return financial;
      case 'saúde':
      case 'health':
        return health;
      case 'construção':
      case 'construction':
        return construction;
      case 'agricultura':
      case 'agriculture':
        return agriculture;
      case 'pet':
      case 'veterinário':
        return pet;
      case 'trabalhista':
      case 'labor':
        return labor;
      default:
        return financial;
    }
  }
}
