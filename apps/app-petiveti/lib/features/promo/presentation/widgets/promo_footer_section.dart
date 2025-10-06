import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../domain/entities/promo_content.dart';

class PromoFooterSection extends StatelessWidget {
  final ContactInfo contactInfo;
  final ValueChanged<String> onStoreButtonPressed;
  final ValueChanged<String> onSocialPressed;

  const PromoFooterSection({
    super.key,
    required this.contactInfo,
    required this.onStoreButtonPressed,
    required this.onSocialPressed,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isMobile = MediaQuery.of(context).size.width < 768;
    
    return Container(
      width: double.infinity,
      color: theme.colorScheme.surfaceContainerHigh,
      padding: const EdgeInsets.all(24),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(32),
            decoration: BoxDecoration(
              color: theme.colorScheme.primary,
              borderRadius: BorderRadius.circular(16),
            ),
            child: Column(
              children: [
                Text(
                  'Pronto para começar?',
                  style: theme.textTheme.headlineMedium?.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                  textAlign: TextAlign.center,
                ),
                
                const SizedBox(height: 16),
                
                Text(
                  'Baixe o PetiVeti agora e transforme o cuidado com seu pet',
                  style: theme.textTheme.bodyLarge?.copyWith(
                    color: Colors.white.withValues(alpha: 0.9),
                  ),
                  textAlign: TextAlign.center,
                ),
                
                const SizedBox(height: 24),
                if (isMobile)
                  Column(
                    children: [
                      _buildStoreButton('App Store', Icons.apple, () {
                        onStoreButtonPressed('app_store');
                        _launchUrl(contactInfo.appStoreUrl);
                      }),
                      const SizedBox(height: 12),
                      _buildStoreButton('Google Play', Icons.android, () {
                        onStoreButtonPressed('google_play');
                        _launchUrl(contactInfo.googlePlayUrl);
                      }),
                    ],
                  )
                else
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      _buildStoreButton('App Store', Icons.apple, () {
                        onStoreButtonPressed('app_store');
                        _launchUrl(contactInfo.appStoreUrl);
                      }),
                      const SizedBox(width: 16),
                      _buildStoreButton('Google Play', Icons.android, () {
                        onStoreButtonPressed('google_play');
                        _launchUrl(contactInfo.googlePlayUrl);
                      }),
                    ],
                  ),
              ],
            ),
          ),
          
          const SizedBox(height: 48),
          if (isMobile) ...[
            _buildContactInfo(theme),
            const SizedBox(height: 32),
            _buildSocialLinks(theme),
          ] else ...[
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(child: _buildContactInfo(theme)),
                const SizedBox(width: 48),
                Expanded(child: _buildSocialLinks(theme)),
              ],
            ),
          ],
          
          const SizedBox(height: 32),
          Container(
            padding: const EdgeInsets.only(top: 24),
            decoration: BoxDecoration(
              border: Border(
                top: BorderSide(
                  color: theme.colorScheme.outline.withValues(alpha: 0.2),
                ),
              ),
            ),
            child: Column(
              children: [
                Text(
                  '© 2024 PetiVeti. Todos os direitos reservados.',
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
                  ),
                  textAlign: TextAlign.center,
                ),
                
                const SizedBox(height: 8),
                
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    TextButton(
                      onPressed: () => _launchUrl(contactInfo.privacyPolicyUrl),
                      child: Text(
                        'Política de Privacidade',
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: theme.colorScheme.primary,
                        ),
                      ),
                    ),
                    Text(
                      ' • ',
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
                      ),
                    ),
                    TextButton(
                      onPressed: () => _launchUrl(contactInfo.termsOfServiceUrl),
                      child: Text(
                        'Termos de Uso',
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: theme.colorScheme.primary,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStoreButton(String store, IconData icon, VoidCallback onPressed) {
    return ElevatedButton.icon(
      onPressed: onPressed,
      icon: Icon(icon),
      label: Text('Baixar na $store'),
      style: ElevatedButton.styleFrom(
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
      ),
    );
  }

  Widget _buildContactInfo(ThemeData theme) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Contato',
          style: theme.textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.bold,
            color: theme.colorScheme.onSurface,
          ),
        ),
        
        const SizedBox(height: 16),
        
        if (contactInfo.supportEmail.isNotEmpty) ...[
          _buildContactItem(
            theme,
            Icons.email,
            contactInfo.supportEmail,
            () => _launchUrl('mailto:${contactInfo.supportEmail}'),
          ),
          const SizedBox(height: 8),
        ],
        
        if (contactInfo.supportPhone.isNotEmpty) ...[
          _buildContactItem(
            theme,
            Icons.phone,
            contactInfo.supportPhone,
            () => _launchUrl('tel:${contactInfo.supportPhone}'),
          ),
          const SizedBox(height: 8),
        ],
        
        if (contactInfo.websiteUrl.isNotEmpty)
          _buildContactItem(
            theme,
            Icons.language,
            'Website',
            () => _launchUrl(contactInfo.websiteUrl),
          ),
      ],
    );
  }

  Widget _buildSocialLinks(ThemeData theme) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Redes Sociais',
          style: theme.textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.bold,
            color: theme.colorScheme.onSurface,
          ),
        ),
        
        const SizedBox(height: 16),
        
        Row(
          children: [
            if (contactInfo.facebookUrl.isNotEmpty)
              _buildSocialButton(theme, Icons.facebook, 'facebook', contactInfo.facebookUrl),
            if (contactInfo.instagramUrl.isNotEmpty)
              _buildSocialButton(theme, Icons.camera_alt, 'instagram', contactInfo.instagramUrl),
            if (contactInfo.twitterUrl.isNotEmpty)
              _buildSocialButton(theme, Icons.alternate_email, 'twitter', contactInfo.twitterUrl),
          ].expand((widget) => [widget, const SizedBox(width: 12)]).take(
            contactInfo.facebookUrl.isNotEmpty || contactInfo.instagramUrl.isNotEmpty || contactInfo.twitterUrl.isNotEmpty
                ? 2 * ([contactInfo.facebookUrl, contactInfo.instagramUrl, contactInfo.twitterUrl].where((url) => url.isNotEmpty).length) - 1
                : 0
          ).toList(),
        ),
      ],
    );
  }

  Widget _buildContactItem(ThemeData theme, IconData icon, String text, VoidCallback onPressed) {
    return GestureDetector(
      onTap: onPressed,
      child: Row(
        children: [
          Icon(
            icon,
            size: 16,
            color: theme.colorScheme.onSurface.withValues(alpha: 0.7),
          ),
          const SizedBox(width: 8),
          Text(
            text,
            style: theme.textTheme.bodyMedium?.copyWith(
              color: theme.colorScheme.onSurface.withValues(alpha: 0.8),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSocialButton(ThemeData theme, IconData icon, String platform, String url) {
    return GestureDetector(
      onTap: () {
        onSocialPressed(platform);
        _launchUrl(url);
      },
      child: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: theme.colorScheme.primary.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Icon(
          icon,
          size: 20,
          color: theme.colorScheme.primary,
        ),
      ),
    );
  }

  Future<void> _launchUrl(String url) async {
    if (url.isNotEmpty) {
      final uri = Uri.parse(url);
      if (await canLaunchUrl(uri)) {
        await launchUrl(uri);
      }
    }
  }
}
