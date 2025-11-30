import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class PromoNavigationBar extends StatelessWidget {
  const PromoNavigationBar({
    super.key,
    this.onNavigate,
    this.featuresKey,
    this.howItWorksKey,
    this.testimonialsKey,
    this.faqKey,
  });

  final void Function(GlobalKey)? onNavigate;
  final GlobalKey? featuresKey;
  final GlobalKey? howItWorksKey;
  final GlobalKey? testimonialsKey;
  final GlobalKey? faqKey;

  @override
  Widget build(BuildContext context) {
    final screenSize = MediaQuery.of(context).size;
    final isMobile = screenSize.width < 900;

    return ClipRRect(
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
        child: Container(
          color: const Color(0xFF064E3B).withValues(alpha: 0.8), // Emerald with opacity
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
      child: GestureDetector(
        onTap: () {},
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [Colors.green[400]!, Colors.teal[600]!],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: Colors.green.withValues(alpha: 0.3),
                    blurRadius: 12,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: const Icon(
                Icons.restaurant,
                color: Colors.white,
                size: 24,
              ),
            ),
            const SizedBox(width: 12),
            RichText(
              text: const TextSpan(
                children: [
                  TextSpan(
                    text: 'Nutri',
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.w900,
                      color: Colors.white,
                      letterSpacing: -0.5,
                    ),
                  ),
                  TextSpan(
                    text: 'Tuti',
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.w400,
                      color: Colors.white,
                      letterSpacing: -0.5,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _navigateToLogin(BuildContext context) {
    context.go('/login');
  }

  void _navigateToSection(GlobalKey? key) {
    if (key != null && onNavigate != null) {
      onNavigate!(key);
    }
  }

  void _showMobileMenu(BuildContext context) {
    showModalBottomSheet<void>(
      context: context,
      backgroundColor: const Color(0xFF064E3B),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => Container(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.grey[600],
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: 30),
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
            _buildMobileMenuItem(
              'FAQ',
              () => _navigateToSection(faqKey),
              context,
            ),
            const SizedBox(height: 30),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  Navigator.pop(context);
                  _navigateToLogin(context);
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green[400],
                  foregroundColor: Colors.black,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: const Text(
                  'Acessar Conta',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
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
        style: const TextStyle(
          color: Colors.white,
          fontWeight: FontWeight.w500,
          fontSize: 16,
        ),
      ),
      onTap: () {
        Navigator.pop(context);
        onTap();
      },
      trailing: Icon(Icons.arrow_forward_ios, size: 16, color: Colors.grey[400]),
    );
  }

  Widget _buildDesktopMenu(BuildContext context) {
    final screenSize = MediaQuery.of(context).size;
    final isSmallDesktop = screenSize.width < 1100;

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
            _buildNavItem(
              'FAQ',
              onTap: () => _navigateToSection(faqKey),
              isSmallDesktop: isSmallDesktop,
            ),
          ],
        ),
        SizedBox(width: isSmallDesktop ? 16 : 32),
        ElevatedButton(
          onPressed: () => _navigateToLogin(context),
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.green[400],
            foregroundColor: Colors.black,
            padding: EdgeInsets.symmetric(
              horizontal: isSmallDesktop ? 20 : 32,
              vertical: isSmallDesktop ? 16 : 20,
            ),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            elevation: 0,
          ),
          child: Text(
            'Acessar Conta',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: isSmallDesktop ? 14 : 16,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildMobileMenu(BuildContext context) {
    return IconButton(
      icon: const Icon(Icons.menu, color: Colors.white),
      onPressed: () => _showMobileMenu(context),
    );
  }

  Widget _buildNavItem(
    String title, {
    bool isActive = false,
    VoidCallback? onTap,
    bool isSmallDesktop = false,
  }) {
    return Container(
      margin: EdgeInsets.only(right: isSmallDesktop ? 16 : 32),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(8),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          child: Text(
            title,
            style: TextStyle(
              color: isActive ? Colors.green[300] : Colors.green[100],
              fontWeight: isActive ? FontWeight.bold : FontWeight.w500,
              fontSize: isSmallDesktop ? 14 : 16,
            ),
          ),
        ),
      ),
    );
  }
}
