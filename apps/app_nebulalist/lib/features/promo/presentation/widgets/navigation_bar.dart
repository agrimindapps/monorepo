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
    final isMobile = screenSize.width < 800;

    return Container(
      color: Colors.white.withValues(alpha: 0.95),
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
                gradient: const LinearGradient(
                  colors: [Color(0xFF673AB7), Color(0xFF3F51B5)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(8),
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFF673AB7).withValues(alpha: 0.3),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: const Icon(
                Icons.checklist,
                color: Colors.white,
                size: 24,
              ),
            ),
            const SizedBox(width: 12),
            RichText(
              text: const TextSpan(
                children: [
                  TextSpan(
                    text: 'Nebula',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w900,
                      color: Color(0xFF673AB7),
                      letterSpacing: -0.5,
                    ),
                  ),
                  TextSpan(
                    text: 'List',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w400,
                      color: Color(0xFF673AB7),
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
                color: Colors.grey[300],
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
            _buildMobileMenuItem(
              'FAQ',
              () => _navigateToSection(faqKey),
              context,
            ),
            const SizedBox(height: 20),
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
        style: TextStyle(color: Colors.grey[800], fontWeight: FontWeight.w500),
      ),
      onTap: () {
        Navigator.pop(context);
        onTap();
      },
      trailing: const Icon(Icons.arrow_forward_ios, size: 16),
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
            _buildNavItem(
              'FAQ',
              onTap: () => _navigateToSection(faqKey),
              isSmallDesktop: isSmallDesktop,
            ),
          ],
        ),
        SizedBox(width: isSmallDesktop ? 12 : 24),
        OutlinedButton(
          onPressed: () => _navigateToLogin(context),
          style: OutlinedButton.styleFrom(
            foregroundColor: const Color(0xFF673AB7),
            side: const BorderSide(color: Color(0xFF673AB7)),
            padding: EdgeInsets.symmetric(
              horizontal: isSmallDesktop ? 12 : 20,
              vertical: isSmallDesktop ? 8 : 12,
            ),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
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
            foregroundColor: const Color(0xFF673AB7),
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
                    ? const Color(0xFF673AB7).withAlpha((0.1 * 255).round())
                    : Colors.transparent,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Text(
            title,
            style: TextStyle(
              color: isActive ? const Color(0xFF673AB7) : Colors.grey[800],
              fontWeight: isActive ? FontWeight.bold : FontWeight.normal,
              fontSize: isSmallDesktop ? 13 : 15,
            ),
          ),
        ),
      ),
    );
  }
}
