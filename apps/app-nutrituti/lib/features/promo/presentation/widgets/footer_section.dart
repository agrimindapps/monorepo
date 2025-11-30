import 'package:flutter/material.dart';

class FooterSection extends StatelessWidget {
  const FooterSection({super.key});

  @override
  Widget build(BuildContext context) {
    final screenSize = MediaQuery.of(context).size;
    final isMobile = screenSize.width < 900;

    return Container(
      padding: EdgeInsets.symmetric(
        vertical: 60,
        horizontal: isMobile ? 20 : screenSize.width * 0.08,
      ),
      decoration: const BoxDecoration(
        color: Color(0xFF0F172A), // Deep Navy
      ),
      child: Column(
        children: [
          isMobile ? _buildMobileFooter() : _buildDesktopFooter(),
          const SizedBox(height: 40),
          Divider(color: Colors.grey[800], height: 1),
          const SizedBox(height: 40),
          _buildBottomBar(isMobile),
        ],
      ),
    );
  }

  Widget _buildDesktopFooter() {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(flex: 2, child: _buildBrandSection()),
        Expanded(child: _buildLinkSection('Produto', ['Funcionalidades', 'Preços', 'Roadmap', 'Changelog'])),
        Expanded(child: _buildLinkSection('Empresa', ['Sobre', 'Blog', 'Carreiras', 'Contato'])),
        Expanded(child: _buildLinkSection('Legal', ['Privacidade', 'Termos', 'Cookies', 'Licenças'])),
        Expanded(child: _buildLinkSection('Suporte', ['FAQ', 'Documentação', 'Comunidade', 'Status'])),
      ],
    );
  }

  Widget _buildMobileFooter() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildBrandSection(),
        const SizedBox(height: 40),
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(child: _buildLinkSection('Produto', ['Funcionalidades', 'Preços'])),
            Expanded(child: _buildLinkSection('Empresa', ['Sobre', 'Contato'])),
          ],
        ),
        const SizedBox(height: 30),
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(child: _buildLinkSection('Legal', ['Privacidade', 'Termos'])),
            Expanded(child: _buildLinkSection('Suporte', ['FAQ', 'Documentação'])),
          ],
        ),
      ],
    );
  }

  Widget _buildBrandSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
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
              ),
              child: const Icon(
                Icons.restaurant,
                color: Colors.white,
                size: 24,
              ),
            ),
            const SizedBox(width: 12),
            const Text(
              'NutriTuti',
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
          ],
        ),
        const SizedBox(height: 20),
        Text(
          'Transformando a forma como você cuida da sua alimentação e saúde.',
          style: TextStyle(
            color: Colors.grey[400],
            height: 1.6,
          ),
        ),
        const SizedBox(height: 24),
        Row(
          children: [
            _buildSocialButton(Icons.alternate_email),
            const SizedBox(width: 12),
            _buildSocialButton(Icons.camera_alt),
            const SizedBox(width: 12),
            _buildSocialButton(Icons.smart_display),
            const SizedBox(width: 12),
            _buildSocialButton(Icons.link),
          ],
        ),
      ],
    );
  }

  Widget _buildSocialButton(IconData icon) {
    return Container(
      width: 40,
      height: 40,
      decoration: BoxDecoration(
        color: Colors.grey[800],
        borderRadius: BorderRadius.circular(10),
      ),
      child: Icon(icon, color: Colors.grey[400], size: 20),
    );
  }

  Widget _buildLinkSection(String title, List<String> links) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: 16,
          ),
        ),
        const SizedBox(height: 20),
        ...links.map((link) => Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: Text(
                link,
                style: TextStyle(
                  color: Colors.grey[400],
                  fontSize: 14,
                ),
              ),
            )),
      ],
    );
  }

  Widget _buildBottomBar(bool isMobile) {
    if (isMobile) {
      return Column(
        children: [
          Text(
            '© 2024 NutriTuti. Todos os direitos reservados.',
            style: TextStyle(
              color: Colors.grey[500],
              fontSize: 14,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _buildStoreButton('App Store', Icons.apple),
              const SizedBox(width: 12),
              _buildStoreButton('Google Play', Icons.android),
            ],
          ),
        ],
      );
    }

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          '© 2024 NutriTuti. Todos os direitos reservados.',
          style: TextStyle(
            color: Colors.grey[500],
            fontSize: 14,
          ),
        ),
        Row(
          children: [
            _buildStoreButton('App Store', Icons.apple),
            const SizedBox(width: 12),
            _buildStoreButton('Google Play', Icons.android),
          ],
        ),
      ],
    );
  }

  Widget _buildStoreButton(String store, IconData icon) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.grey[800],
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: Colors.white, size: 20),
          const SizedBox(width: 8),
          Text(
            store,
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.w500,
              fontSize: 14,
            ),
          ),
        ],
      ),
    );
  }
}
