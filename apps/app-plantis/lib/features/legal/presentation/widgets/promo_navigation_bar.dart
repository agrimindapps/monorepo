import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../../core/router/app_router.dart';

class PromoNavigationBar extends StatelessWidget {
  const PromoNavigationBar({
    super.key,
    this.onNavigate,
    this.featuresKey,
    this.howItWorksKey,
    this.testimonialsKey,
    this.comingSoon = false,
    this.launchDate,
  });

  final void Function(GlobalKey)? onNavigate;
  final GlobalKey? featuresKey;
  final GlobalKey? howItWorksKey;
  final GlobalKey? testimonialsKey;
  final bool comingSoon;
  final DateTime? launchDate;

  @override
  Widget build(BuildContext context) {
    final screenSize = MediaQuery.of(context).size;
    final isMobile = screenSize.width < 800;

    return ClipRRect(
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
        child: Container(
          color: const Color(0xFF0F2F21).withValues(alpha: 0.8), // Deep Forest Green with opacity
          padding: EdgeInsets.symmetric(
            horizontal: isMobile ? 16 : screenSize.width * 0.08,
            vertical: 16,
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _buildLogo(),
              isMobile ? _buildMobileMenu(context) : _buildDesktopMenu(context),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildLogo() {
    return MouseRegion(
      cursor: SystemMouseCursors.click,
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFF10B981), Color(0xFF059669)], // Emerald Gradient
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFF10B981).withValues(alpha: 0.3),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: const Icon(Icons.eco, color: Colors.white, size: 24),
          ),
          const SizedBox(width: 12),
          RichText(
            text: TextSpan(
              children: [
                TextSpan(
                  text: 'Plan',
                  style: GoogleFonts.playfairDisplay(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                    letterSpacing: -0.5,
                  ),
                ),
                TextSpan(
                  text: 'tis',
                  style: GoogleFonts.playfairDisplay(
                    fontSize: 24,
                    fontWeight: FontWeight.w400,
                    color: const Color(0xFF10B981), // Emerald
                    letterSpacing: -0.5,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _navigateToLogin(BuildContext context) {
    context.go(AppRouter.login);
  }

  void _navigateToSection(GlobalKey? key) {
    if (key != null && onNavigate != null) {
      onNavigate!(key);
    }
  }

  void _showMobileMenu(BuildContext context) {
    showModalBottomSheet<void>(
      context: context,
      backgroundColor: const Color(0xFF0F2F21),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder:
          (context) => Container(
            padding: const EdgeInsets.all(20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
                const SizedBox(height: 20),
                _buildMobileMenuItem(
                  'Funcionalidades',
                  () => _navigateToSection(featuresKey),
                  context,
                ),
                _buildMobileMenuItem(
                  'Como Funciona',
                  () => _navigateToSection(howItWorksKey),
                  context,
                ),
                _buildMobileMenuItem(
                  'Depoimentos',
                  () => _navigateToSection(testimonialsKey),
                  context,
                ),
                const SizedBox(height: 20),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.pop(context);
                      _navigateToLogin(context);
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF10B981),
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: const Text(
                      'Entrar',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
    );
  }

  Widget _buildMobileMenuItem(
    String title,
    VoidCallback onTap,
    BuildContext context,
  ) {
    return ListTile(
      title: Text(
        title,
        style: GoogleFonts.inter(
          color: Colors.white,
          fontWeight: FontWeight.w500,
        ),
      ),
      onTap: () {
        Navigator.pop(context);
        onTap();
      },
      trailing: const Icon(Icons.arrow_forward_ios, size: 16, color: Colors.white54),
    );
  }

  Widget _buildDesktopMenu(BuildContext context) {
    final screenSize = MediaQuery.of(context).size;
    final isSmallDesktop = screenSize.width < 1000;

    return Row(
      children: [
        Row(
          children: [
            _buildNavItem(
              'Funcionalidades',
              onTap: () => _navigateToSection(featuresKey),
              isSmallDesktop: isSmallDesktop,
            ),
            _buildNavItem(
              'Como Funciona',
              onTap: () => _navigateToSection(howItWorksKey),
              isSmallDesktop: isSmallDesktop,
            ),
            _buildNavItem(
              'Depoimentos',
              onTap: () => _navigateToSection(testimonialsKey),
              isSmallDesktop: isSmallDesktop,
            ),
          ],
        ),
        SizedBox(width: isSmallDesktop ? 12 : 24),
        ElevatedButton(
          onPressed: () => _navigateToLogin(context),
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFF10B981), // Emerald
            foregroundColor: Colors.white,
            padding: EdgeInsets.symmetric(
              horizontal: isSmallDesktop ? 16 : 24,
              vertical: isSmallDesktop ? 12 : 16,
            ),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            elevation: 0,
          ),
          child: Text(
            'Entrar',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: isSmallDesktop ? 13 : 14,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildMobileMenu(BuildContext context) {
    return Row(
      children: [
        TextButton(
          onPressed: () => _navigateToLogin(context),
          style: TextButton.styleFrom(
            foregroundColor: Colors.white,
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          ),
          child: const Text(
            'Entrar',
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
          ),
        ),
        IconButton(
          icon: const Icon(Icons.menu),
          onPressed: () {
            _showMobileMenu(context);
          },
          tooltip: 'Menu',
          color: Colors.white,
        ),
      ],
    );
  }

  Widget _buildNavItem(
    String title, {
    bool isActive = false,
    VoidCallback? onTap,
    bool isSmallDesktop = false,
  }) {
    return Container(
      margin: EdgeInsets.only(right: isSmallDesktop ? 8 : 16),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(8),
        child: Container(
          padding: EdgeInsets.symmetric(
            horizontal: isSmallDesktop ? 10 : 16,
            vertical: isSmallDesktop ? 6 : 8,
          ),
          decoration: BoxDecoration(
            color:
                isActive
                    ? const Color(0xFF10B981).withValues(alpha: 0.1)
                    : Colors.transparent,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Text(
            title,
            style: GoogleFonts.inter(
              color: isActive ? const Color(0xFF10B981) : Colors.grey[300],
              fontWeight: isActive ? FontWeight.bold : FontWeight.w500,
              fontSize: isSmallDesktop ? 13 : 15,
            ),
          ),
        ),
      ),
    );
  }
}
