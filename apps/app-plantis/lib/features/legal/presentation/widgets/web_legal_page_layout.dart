import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../../core/router/app_router.dart';
import '../../domain/entities/legal_section.dart';

/// Modern web-first layout for legal pages
/// Follows promotional page design system
class WebLegalPageLayout extends StatefulWidget {
  final String title;
  final IconData headerIcon;
  final String headerTitle;
  final String headerSubtitle;
  final List<LegalSection> sections;
  final DateTime lastUpdated;
  final Color accentColor;
  final String footerTitle;
  final String footerDescription;
  final IconData? footerIcon;

  const WebLegalPageLayout({
    super.key,
    required this.title,
    required this.headerIcon,
    required this.headerTitle,
    required this.headerSubtitle,
    required this.sections,
    required this.lastUpdated,
    required this.accentColor,
    required this.footerTitle,
    required this.footerDescription,
    this.footerIcon,
  });

  @override
  State<WebLegalPageLayout> createState() => _WebLegalPageLayoutState();
}

class _WebLegalPageLayoutState extends State<WebLegalPageLayout> {
  final ScrollController _scrollController = ScrollController();
  bool _showScrollToTopButton = false;

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_scrollListener);
  }

  void _scrollListener() {
    if (_scrollController.offset >= 400) {
      if (!_showScrollToTopButton) {
        setState(() => _showScrollToTopButton = true);
      }
    } else {
      if (_showScrollToTopButton) {
        setState(() => _showScrollToTopButton = false);
      }
    }
  }

  void _scrollToTop() {
    _scrollController.animateTo(
      0,
      duration: const Duration(milliseconds: 500),
      curve: Curves.easeInOut,
    );
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final screenSize = MediaQuery.of(context).size;
    final isMobile = screenSize.width < 800;

    return Scaffold(
      backgroundColor: const Color(0xFF0A1F14), // Dark forest background
      body: Stack(
        children: [
          // Background gradient
          Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Color(0xFF0F2F21),
                  Color(0xFF0A1F14),
                ],
              ),
            ),
          ),
          // Content
          Column(
            children: [
              _buildNavigationBar(context, isMobile),
              Expanded(
                child: SingleChildScrollView(
                  controller: _scrollController,
                  child: Column(
                    children: [
                      _buildHeroSection(isMobile),
                      _buildContentSection(isMobile),
                      _buildFooterSection(context, isMobile),
                    ],
                  ),
                ),
              ),
            ],
          ),
          // Scroll to top button
          if (_showScrollToTopButton)
            Positioned(
              right: isMobile ? 16 : 32,
              bottom: isMobile ? 16 : 32,
              child: FloatingActionButton(
                onPressed: _scrollToTop,
                backgroundColor: widget.accentColor,
                foregroundColor: Colors.white,
                elevation: 8,
                child: const Icon(Icons.keyboard_arrow_up, size: 28),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildNavigationBar(BuildContext context, bool isMobile) {
    return ClipRRect(
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
        child: Container(
          color: const Color(0xFF0F2F21).withValues(alpha: 0.8),
          padding: EdgeInsets.symmetric(
            horizontal: isMobile ? 16 : MediaQuery.of(context).size.width * 0.08,
            vertical: 16,
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _buildLogo(),
              Row(
                children: [
                  if (!isMobile) ...[
                    _buildNavLink('Início', () => context.go(AppRouter.home)),
                    const SizedBox(width: 24),
                    _buildNavLink('Sobre', () {}),
                    const SizedBox(width: 24),
                  ],
                  TextButton.icon(
                    onPressed: () => context.go(AppRouter.home),
                    icon: const Icon(Icons.arrow_back, color: Color(0xFF10B981)),
                    label: Text(
                      isMobile ? 'Voltar' : 'Voltar ao App',
                      style: GoogleFonts.inter(
                        color: const Color(0xFF10B981),
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildLogo() {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                widget.accentColor,
                widget.accentColor.withValues(alpha: 0.7),
              ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(
                color: widget.accentColor.withValues(alpha: 0.3),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Icon(widget.headerIcon, color: Colors.white, size: 24),
        ),
        const SizedBox(width: 12),
        RichText(
          text: TextSpan(
            children: [
              TextSpan(
                text: 'Cantinho',
                style: GoogleFonts.playfairDisplay(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                  letterSpacing: -0.5,
                ),
              ),
              TextSpan(
                text: 'Verde',
                style: GoogleFonts.playfairDisplay(
                  fontSize: 24,
                  fontWeight: FontWeight.w400,
                  color: const Color(0xFF10B981),
                  letterSpacing: -0.5,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildNavLink(String text, VoidCallback onTap) {
    return MouseRegion(
      cursor: SystemMouseCursors.click,
      child: GestureDetector(
        onTap: onTap,
        child: Text(
          text,
          style: GoogleFonts.inter(
            color: Colors.white.withValues(alpha: 0.9),
            fontSize: 14,
            fontWeight: FontWeight.w500,
          ),
        ),
      ),
    );
  }

  Widget _buildHeroSection(bool isMobile) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.symmetric(
        horizontal: isMobile ? 24 : 80,
        vertical: isMobile ? 60 : 100,
      ),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            widget.accentColor.withValues(alpha: 0.1),
            widget.accentColor.withValues(alpha: 0.05),
          ],
        ),
      ),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 1200),
          child: Column(
            children: [
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: widget.accentColor.withValues(alpha: 0.15),
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: widget.accentColor.withValues(alpha: 0.3),
                    width: 2,
                  ),
                ),
                child: Icon(
                  widget.headerIcon,
                  size: isMobile ? 48 : 64,
                  color: widget.accentColor,
                ),
              ),
              const SizedBox(height: 24),
              Text(
                widget.headerTitle,
                style: GoogleFonts.playfairDisplay(
                  fontSize: isMobile ? 32 : 48,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                  height: 1.2,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),
              Text(
                widget.headerSubtitle,
                style: GoogleFonts.inter(
                  fontSize: isMobile ? 16 : 18,
                  color: Colors.white.withValues(alpha: 0.8),
                  height: 1.6,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 24),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 12,
                ),
                decoration: BoxDecoration(
                  color: const Color(0xFF1E3A2F).withValues(alpha: 0.5),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                    color: widget.accentColor.withValues(alpha: 0.3),
                  ),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.update,
                      size: 16,
                      color: widget.accentColor,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      'Última atualização: ${_getFormattedDate(widget.lastUpdated)}',
                      style: GoogleFonts.inter(
                        fontSize: 14,
                        color: Colors.white.withValues(alpha: 0.9),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildContentSection(bool isMobile) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.symmetric(
        horizontal: isMobile ? 24 : 80,
        vertical: isMobile ? 40 : 60,
      ),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 900),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: widget.sections.map((section) {
              return _buildSection(section, isMobile);
            }).toList(),
          ),
        ),
      ),
    );
  }

  Widget _buildSection(LegalSection section, bool isMobile) {
    return Container(
      margin: const EdgeInsets.only(bottom: 40),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            section.title,
            style: GoogleFonts.playfairDisplay(
              fontSize: isMobile ? 24 : 28,
              fontWeight: FontWeight.bold,
              color: widget.accentColor,
              height: 1.3,
            ),
          ),
          const SizedBox(height: 16),
          Container(
            width: double.infinity,
            padding: EdgeInsets.all(isMobile ? 20 : 28),
            decoration: BoxDecoration(
              color: const Color(0xFF1E3A2F).withValues(alpha: 0.3),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: widget.accentColor.withValues(alpha: 0.2),
              ),
            ),
            child: Text(
              section.content,
              style: GoogleFonts.inter(
                fontSize: isMobile ? 15 : 16,
                color: Colors.white.withValues(alpha: 0.9),
                height: 1.8,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFooterSection(BuildContext context, bool isMobile) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.symmetric(
        horizontal: isMobile ? 24 : 80,
        vertical: isMobile ? 40 : 60,
      ),
      decoration: BoxDecoration(
        color: const Color(0xFF0A1F14),
        border: Border(
          top: BorderSide(
            color: widget.accentColor.withValues(alpha: 0.2),
          ),
        ),
      ),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 900),
          child: Column(
            children: [
              if (widget.footerIcon != null)
                Icon(
                  widget.footerIcon,
                  size: isMobile ? 48 : 56,
                  color: widget.accentColor,
                ),
              if (widget.footerIcon != null) const SizedBox(height: 16),
              Text(
                widget.footerTitle,
                style: GoogleFonts.playfairDisplay(
                  fontSize: isMobile ? 24 : 28,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),
              Text(
                widget.footerDescription,
                style: GoogleFonts.inter(
                  fontSize: isMobile ? 15 : 16,
                  color: Colors.white.withValues(alpha: 0.7),
                  height: 1.6,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 32),
              Divider(color: Colors.white.withValues(alpha: 0.1)),
              const SizedBox(height: 24),
              Text(
                '© ${DateTime.now().year} CantinhoVerde. Todos os direitos reservados.',
                style: GoogleFonts.inter(
                  fontSize: 14,
                  color: Colors.white.withValues(alpha: 0.5),
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _getFormattedDate(DateTime date) {
    final months = [
      'janeiro', 'fevereiro', 'março', 'abril', 'maio', 'junho',
      'julho', 'agosto', 'setembro', 'outubro', 'novembro', 'dezembro',
    ];
    return '${date.day} de ${months[date.month - 1]} de ${date.year}';
  }
}
