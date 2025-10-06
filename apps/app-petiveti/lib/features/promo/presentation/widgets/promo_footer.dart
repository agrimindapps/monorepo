import 'package:flutter/material.dart';
import '../../../../shared/constants/splash_constants.dart';

class PromoFooter extends StatelessWidget {
  const PromoFooter({super.key});

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isMobile = screenWidth < 768;
    
    return Container(
      width: double.infinity,
      padding: EdgeInsets.symmetric(
        horizontal: isMobile ? 16 : 32,
        vertical: 40,
      ),
      color: const Color(0xFF2D2D2D), // Dark grey
      child: Column(
        children: [
          _buildFooterContent(context, isMobile),
          
          const SizedBox(height: 32),
          Container(
            height: 1,
            color: Colors.white.withValues(alpha: 0.2),
          ),
          
          const SizedBox(height: 24),
          _buildCopyright(context, isMobile),
        ],
      ),
    );
  }

  Widget _buildFooterContent(BuildContext context, bool isMobile) {
    if (isMobile) {
      return Column(
        children: [
          _buildBrandSection(),
          const SizedBox(height: 32),
          _buildLinksSection(),
          const SizedBox(height: 32),
          _buildSocialSection(),
        ],
      );
    }

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(flex: 2, child: _buildBrandSection()),
        
        const SizedBox(width: 40),
        Expanded(flex: 2, child: _buildLinksSection()),
        
        const SizedBox(width: 40),
        Expanded(flex: 1, child: _buildSocialSection()),
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
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: SplashColors.primaryColor,
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Icon(
                Icons.pets,
                color: Colors.white,
                size: 24,
              ),
            ),
            const SizedBox(width: 12),
            const Text(
              SplashConstants.appName,
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
          ],
        ),
        
        const SizedBox(height: 16),
        Text(
          SplashConstants.appDescription,
          style: TextStyle(
            fontSize: 14,
            color: Colors.white.withValues(alpha: 0.7),
            height: 1.5,
          ),
        ),
        
        const SizedBox(height: 16),
        Text(
          'Contato: suporte@petiveti.com',
          style: TextStyle(
            fontSize: 14,
            color: Colors.white.withValues(alpha: 0.7),
          ),
        ),
      ],
    );
  }

  Widget _buildLinksSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Links Úteis',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        
        const SizedBox(height: 16),
        
        ..._getFooterLinks().map((link) => Padding(
          padding: const EdgeInsets.only(bottom: 12),
          child: InkWell(
            onTap: () {
            },
            child: Text(
              link,
              style: TextStyle(
                fontSize: 14,
                color: Colors.white.withValues(alpha: 0.7),
                decoration: TextDecoration.none,
              ),
            ),
          ),
        )),
      ],
    );
  }

  Widget _buildSocialSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Siga-nos',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        
        const SizedBox(height: 16),
        Wrap(
          spacing: 16,
          runSpacing: 16,
          children: [
            _buildSocialIcon(Icons.facebook, 'Facebook'),
            _buildSocialIcon(Icons.alternate_email, 'Instagram'),
            _buildSocialIcon(Icons.chat, 'Twitter'),
            _buildSocialIcon(Icons.video_library, 'YouTube'),
          ],
        ),
      ],
    );
  }

  Widget _buildSocialIcon(IconData icon, String platform) {
    return InkWell(
      onTap: () {
      },
      child: Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: Colors.white.withValues(alpha: 0.2)),
        ),
        child: Icon(
          icon,
          color: Colors.white.withValues(alpha: 0.8),
          size: 20,
        ),
      ),
    );
  }

  Widget _buildCopyright(BuildContext context, bool isMobile) {
    return Column(
      children: [
        Text(
          '© 2025 ${SplashConstants.appName}. Todos os direitos reservados.',
          style: TextStyle(
            fontSize: 12,
            color: Colors.white.withValues(alpha: 0.6),
          ),
          textAlign: isMobile ? TextAlign.center : TextAlign.start,
        ),
        
        const SizedBox(height: 8),
        
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              'Política de Privacidade',
              style: TextStyle(
                fontSize: 12,
                color: Colors.white.withValues(alpha: 0.6),
                decoration: TextDecoration.underline,
              ),
            ),
            
            Text(
              ' • ',
              style: TextStyle(
                fontSize: 12,
                color: Colors.white.withValues(alpha: 0.6),
              ),
            ),
            
            Text(
              'Termos de Uso',
              style: TextStyle(
                fontSize: 12,
                color: Colors.white.withValues(alpha: 0.6),
                decoration: TextDecoration.underline,
              ),
            ),
          ],
        ),
      ],
    );
  }

  List<String> _getFooterLinks() {
    return [
      'Recursos',
      'Preços',
      'Blog',
      'Suporte',
      'Contato',
      'Sobre Nós',
    ];
  }
}