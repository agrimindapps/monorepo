// Dart imports:
import 'dart:ui';

// Flutter imports:
import 'package:flutter/material.dart';

class PromoNavigationBar extends StatefulWidget {
  const PromoNavigationBar({super.key});

  @override
  State<PromoNavigationBar> createState() => _PromoNavigationBarState();
}

class _PromoNavigationBarState extends State<PromoNavigationBar> {
  bool _isMenuOpen = false;
  int _hoveredIndex = -1;
  final ScrollController _scrollController = ScrollController();
  bool _isScrolled = false;

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _scrollController.removeListener(_onScroll);
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (_scrollController.offset > 20 && !_isScrolled) {
      setState(() => _isScrolled = true);
    } else if (_scrollController.offset <= 20 && _isScrolled) {
      setState(() => _isScrolled = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final navbarWidget = ClipRRect(
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
          decoration: BoxDecoration(
            color: _isScrolled
                ? Colors.white.withValues(alpha: 0.95)
                : Colors.white.withValues(alpha: 0.8),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: _isScrolled ? 0.1 : 0.05),
                blurRadius: _isScrolled ? 10 : 5,
                offset: Offset(0, _isScrolled ? 4 : 2),
              ),
            ],
            border: Border(
              bottom: BorderSide(
                color: Colors.grey.withValues(alpha: _isScrolled ? 0.2 : 0.1),
                width: 1,
              ),
            ),
          ),
          child: SafeArea(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                // Logo com animação
                MouseRegion(
                  cursor: SystemMouseCursors.click,
                  onEnter: (_) => setState(() => _hoveredIndex = -2),
                  onExit: (_) => setState(() => _hoveredIndex = -1),
                  child: GestureDetector(
                    onTap: () {
                      // Scroll para o topo
                    },
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      transform: _hoveredIndex == -2
                          ? (Matrix4.identity()..scale(1.05))
                          : Matrix4.identity(),
                      child: Row(
                        children: [
                          AnimatedContainer(
                            duration: const Duration(milliseconds: 200),
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: _hoveredIndex == -2
                                  ? Theme.of(context)
                                      .primaryColor
                                      .withValues(alpha: 0.1)
                                  : Colors.transparent,
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Icon(
                              Icons.calculate,
                              color: Theme.of(context).primaryColor,
                              size: 24,
                            ),
                          ),
                          const SizedBox(width: 10),
                          Text(
                            'Calculei',
                            style: TextStyle(
                              color: Theme.of(context).primaryColor,
                              fontWeight: FontWeight.bold,
                              fontSize: 22,
                              letterSpacing: 0.5,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),

                // Menu para telas grandes
                LayoutBuilder(
                  builder: (context, constraints) {
                    if (MediaQuery.of(context).size.width > 800) {
                      return Row(
                        children: [
                          _buildNavItem('Recursos', 0),
                          _buildNavItem('Como funciona', 1),
                          _buildNavItem('Depoimentos', 2),
                          _buildNavItem('FAQ', 3),
                          const SizedBox(width: 16),
                          _buildDownloadButton(),
                        ],
                      );
                    } else {
                      return Row(
                        children: [
                          if (!_isMenuOpen) _buildDownloadButton(isSmall: true),
                          const SizedBox(width: 8),
                          IconButton(
                            icon: Icon(
                              _isMenuOpen ? Icons.close : Icons.menu,
                              color: Theme.of(context).primaryColor,
                            ),
                            onPressed: () {
                              setState(() {
                                _isMenuOpen = !_isMenuOpen;
                              });
                            },
                          ),
                        ],
                      );
                    }
                  },
                ),
              ],
            ),
          ),
        ),
      ),
    );

    return Column(
      children: [
        navbarWidget,
        if (_isMenuOpen && MediaQuery.of(context).size.width <= 800)
          _buildMobileMenu(),
      ],
    );
  }

  // Menu para dispositivos móveis
  Widget _buildMobileMenu() {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.1),
            blurRadius: 10,
            spreadRadius: 0,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        children: [
          _buildMobileNavItem('Recursos', 0),
          _buildMobileNavItem('Como funciona', 1),
          _buildMobileNavItem('Depoimentos', 2),
          _buildMobileNavItem('FAQ', 3),
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 24),
            child: _buildDownloadButton(fullWidth: true),
          ),
        ],
      ),
    );
  }

  // Item de navegação para desktop
  Widget _buildNavItem(String title, int index) {
    final isHovered = _hoveredIndex == index;

    return MouseRegion(
      cursor: SystemMouseCursors.click,
      onEnter: (_) => setState(() => _hoveredIndex = index),
      onExit: (_) => setState(() => _hoveredIndex = -1),
      child: GestureDetector(
        onTap: () {
          // Navegar para a seção
        },
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              AnimatedDefaultTextStyle(
                duration: const Duration(milliseconds: 200),
                style: TextStyle(
                  color: isHovered
                      ? Theme.of(context).primaryColor
                      : Colors.black87,
                  fontWeight: isHovered ? FontWeight.bold : FontWeight.normal,
                  fontSize: 16,
                ),
                child: Text(title),
              ),
              const SizedBox(height: 4),
              AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                height: 2,
                width: isHovered ? 20 : 0,
                decoration: BoxDecoration(
                  color: Theme.of(context).primaryColor,
                  borderRadius: BorderRadius.circular(1),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // Item de navegação para móvel
  Widget _buildMobileNavItem(String title, int index) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () {
          // Navegar para a seção
          setState(() {
            _isMenuOpen = false;
          });
        },
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 24),
          decoration: BoxDecoration(
            border: Border(
              bottom: BorderSide(
                color: Colors.grey.withValues(alpha: 0.2),
                width: 1,
              ),
            ),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                title,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                ),
              ),
              Icon(
                Icons.arrow_forward_ios,
                size: 14,
                color: Colors.grey[600],
              ),
            ],
          ),
        ),
      ),
    );
  }

  // Botão de download
  Widget _buildDownloadButton({bool isSmall = false, bool fullWidth = false}) {
    return MouseRegion(
      cursor: SystemMouseCursors.click,
      onEnter: (_) => setState(() => _hoveredIndex = 999),
      onExit: (_) => setState(() => _hoveredIndex = -1),
      child: GestureDetector(
        onTap: () {
          // Ação de download
        },
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          width: fullWidth ? double.infinity : null,
          padding: EdgeInsets.symmetric(
            horizontal: isSmall ? 12 : 20,
            vertical: isSmall ? 6 : 10,
          ),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                Theme.of(context).primaryColor,
                _hoveredIndex == 999
                    ? Theme.of(context).primaryColor.withBlue(
                        (Theme.of(context).primaryColor.blue + 40)
                            .clamp(0, 255))
                    : Theme.of(context).primaryColor.withBlue(
                        (Theme.of(context).primaryColor.blue + 20)
                            .clamp(0, 255)),
              ],
            ),
            borderRadius: BorderRadius.circular(isSmall ? 8 : 12),
            boxShadow: [
              BoxShadow(
                color: Theme.of(context)
                    .primaryColor
                    .withValues(alpha: _hoveredIndex == 999 ? 0.4 : 0.2),
                blurRadius: _hoveredIndex == 999 ? 12 : 8,
                offset: Offset(0, _hoveredIndex == 999 ? 4 : 2),
              ),
            ],
          ),
          child: Row(
            mainAxisSize: fullWidth ? MainAxisSize.max : MainAxisSize.min,
            mainAxisAlignment:
                fullWidth ? MainAxisAlignment.center : MainAxisAlignment.start,
            children: [
              Icon(
                Icons.download,
                color: Colors.white,
                size: isSmall ? 16 : 20,
              ),
              SizedBox(width: isSmall ? 6 : 8),
              Text(
                'Download',
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: isSmall ? 14 : 16,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
