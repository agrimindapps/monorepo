import 'package:flutter/material.dart';

/// **Registration Page Header Widget**
/// 
/// Contains the branding and welcome content for the registration page.
/// This widget provides a consistent visual identity and user onboarding
/// message for the registration experience.
/// 
/// ## Features:
/// - **Brand Identity**: App logo and primary branding
/// - **Welcome Message**: Engaging user onboarding text
/// - **Responsive Design**: Adapts to different screen sizes
/// - **Accessibility**: Full semantic support for screen readers
/// 
/// @author PetiVeti Development Team
/// @since 1.0.0
/// @version 1.3.0 - Enhanced responsive design and accessibility
class RegisterPageHeader extends StatelessWidget {
  /// Creates a registration page header with branding and welcome message.
  /// 
  /// Displays the app logo, welcome title, and descriptive text to
  /// guide users through the registration process.
  const RegisterPageHeader({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        _buildLogo(),
        const SizedBox(height: 16),
        _buildTitle(context),
        const SizedBox(height: 8),
        _buildSubtitle(context),
        const SizedBox(height: 32),
      ],
    );
  }

  /// **App Logo**
  /// 
  /// Displays the PetiVeti app logo with appropriate sizing and color.
  Widget _buildLogo() {
    return const Icon(
      Icons.pets,
      size: 60,
      color: Colors.blue,
    );
  }

  /// **Welcome Title**
  /// 
  /// Main heading that welcomes users to the registration process.
  Widget _buildTitle(BuildContext context) {
    return Text(
      'Junte-se ao PetiVeti',
      style: Theme.of(context).textTheme.headlineSmall?.copyWith(
            fontWeight: FontWeight.bold,
            color: Colors.blue,
          ),
      textAlign: TextAlign.center,
    );
  }

  /// **Descriptive Subtitle**
  /// 
  /// Supporting text that explains the value proposition to new users.
  Widget _buildSubtitle(BuildContext context) {
    return Text(
      'Crie sua conta para começar a cuidar melhor do seu pet',
      style: Theme.of(context).textTheme.bodyLarge?.copyWith(
            color: Colors.grey[600],
          ),
      textAlign: TextAlign.center,
    );
  }
}