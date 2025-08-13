// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:icons_plus/icons_plus.dart';

class FooterSection extends StatelessWidget {
  const FooterSection({super.key});

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final bool isSmallScreen = size.width < 800;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 60, horizontal: 20),
      color: Colors.green.shade900,
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 1200),
          child: Column(
            children: [
              isSmallScreen
                  ? _buildMobileFooterContent()
                  : _buildDesktopFooterContent(),
              const SizedBox(height: 40),
              const Divider(color: Colors.white30),
              const SizedBox(height: 20),
              _buildCopyright(context),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildMobileFooterContent() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        _buildLogo(),
        const SizedBox(height: 30),
        _buildAboutSection(),
        const SizedBox(height: 30),
        _buildLinksSection(),
        const SizedBox(height: 30),
        _buildContactSection(),
        const SizedBox(height: 30),
        _buildSocialLinks(),
      ],
    );
  }

  Widget _buildDesktopFooterContent() {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          flex: 3,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildLogo(),
              const SizedBox(height: 20),
              _buildAboutSection(),
              const SizedBox(height: 20),
              _buildSocialLinks(),
            ],
          ),
        ),
        Expanded(
          flex: 2,
          child: _buildLinksSection(),
        ),
        Expanded(
          flex: 2,
          child: _buildContactSection(),
        ),
      ],
    );
  }

  Widget _buildLogo() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(
            FontAwesome.leaf_solid,
            size: 24,
            color: Colors.green.shade700,
          ),
        ),
        const SizedBox(width: 12),
        const Text(
          'ReceiturAgro',
          style: TextStyle(
            color: Colors.white,
            fontSize: 24,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }

  Widget _buildAboutSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'O aplicativo completo para manejo de pragas, doenças e defensivos agrícolas. '
          'Desenvolvido com tecnologia de ponta para oferecer aos profissionais do campo '
          'um suporte técnico confiável.',
          style: TextStyle(
            color: Colors.white.withValues(alpha: 0.7),
            height: 1.6,
          ),
        ),
      ],
    );
  }

  Widget _buildLinksSection() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Links Rápidos',
            style: TextStyle(
              color: Colors.white,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 20),
          _buildLink('Início', Icons.home),
          _buildLink('Recursos', Icons.devices),
          _buildLink('Planos e Preços', Icons.attach_money),
          _buildLink('Blog', Icons.article),
          _buildLink('Sobre Nós', Icons.info),
          _buildLink('Contato', Icons.mail),
        ],
      ),
    );
  }

  Widget _buildLink(String text, IconData icon) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        children: [
          Icon(
            icon,
            size: 16,
            color: Colors.white.withValues(alpha: 0.6),
          ),
          const SizedBox(width: 8),
          Text(
            text,
            style: TextStyle(
              color: Colors.white.withValues(alpha: 0.7),
              fontSize: 14,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildContactSection() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Contato',
            style: TextStyle(
              color: Colors.white,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 20),
          _buildContactItem(
            Icons.email,
            'contato@receituragro.com.br',
          ),
          _buildContactItem(
            Icons.phone,
            '+55 (11) 9999-9999',
          ),
          _buildContactItem(
            Icons.location_on,
            'São Paulo, SP - Brasil',
          ),
        ],
      ),
    );
  }

  Widget _buildContactItem(IconData icon, String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        children: [
          Icon(
            icon,
            size: 16,
            color: Colors.white.withValues(alpha: 0.6),
          ),
          const SizedBox(width: 8),
          Text(
            text,
            style: TextStyle(
              color: Colors.white.withValues(alpha: 0.7),
              fontSize: 14,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSocialLinks() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        _buildSocialIcon(FontAwesome.facebook_f_brand),
        _buildSocialIcon(FontAwesome.twitter_brand),
        _buildSocialIcon(FontAwesome.instagram_brand),
        _buildSocialIcon(FontAwesome.linkedin_in_brand),
        _buildSocialIcon(FontAwesome.youtube_brand),
      ],
    );
  }

  Widget _buildSocialIcon(IconData icon) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 8),
      width: 36,
      height: 36,
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(18),
      ),
      child: Icon(
        icon,
        color: Colors.white,
        size: 16,
      ),
    );
  }

  Widget _buildCopyright(BuildContext context) {
    final currentYear = DateTime.now().year;

    return Column(
      children: [
        Text(
          '© $currentYear ReceiturAgro. Todos os direitos reservados.',
          style: TextStyle(
            color: Colors.white.withValues(alpha: 0.7),
            fontSize: 14,
          ),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 12),
        Wrap(
          alignment: WrapAlignment.center,
          spacing: 16,
          children: [
            Text(
              'Política de Privacidade',
              style: TextStyle(
                color: Colors.white.withValues(alpha: 0.7),
                fontSize: 12,
              ),
            ),
            Text(
              'Termos de Uso',
              style: TextStyle(
                color: Colors.white.withValues(alpha: 0.7),
                fontSize: 12,
              ),
            ),
            Text(
              'Cookies',
              style: TextStyle(
                color: Colors.white.withValues(alpha: 0.7),
                fontSize: 12,
              ),
            ),
          ],
        ),
      ],
    );
  }
}
