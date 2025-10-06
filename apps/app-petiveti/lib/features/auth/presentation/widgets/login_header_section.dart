import 'package:flutter/material.dart';

/// **Login Header Section Widget**
/// 
/// A specialized header widget for the login page that displays the app logo,
/// name, and contextual messaging based on the current authentication mode.
/// 
/// ## Key Features:
/// - **App Branding**: Displays app logo and name with consistent styling
/// - **Contextual Messaging**: Different messages for login vs registration
/// - **Responsive Design**: Adapts text sizes and spacing for different screens
/// - **Accessibility**: Semantic structure for screen readers
/// 
/// ## Visual Components:
/// - **Logo Icon**: Large, colored app icon (pets icon with blue theme)
/// - **App Name**: Bold, branded title text
/// - **Subtitle**: Context-sensitive subtitle text
/// 
/// ## Design Principles:
/// - **Brand Consistency**: Uses app-wide colors and typography
/// - **Visual Hierarchy**: Clear hierarchy from logo to app name to subtitle
/// - **Accessibility**: Proper semantic labels and heading structure
/// - **Responsiveness**: Scales appropriately on different screen sizes
/// 
/// @author PetiVeti Development Team
/// @since 1.1.0
class LoginHeaderSection extends StatelessWidget {
  /// Creates a login header section widget.
  /// 
  /// **Parameters:**
  /// - [isSignUp]: Whether the form is in sign-up mode (affects subtitle text)
  const LoginHeaderSection({
    super.key,
    required this.isSignUp,
  });

  /// Whether the form is currently in sign-up mode
  final bool isSignUp;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        _buildLogo(context),
        const SizedBox(height: 24),
        _buildAppName(context),
        const SizedBox(height: 8),
        _buildSubtitle(context),
        const SizedBox(height: 32),
      ],
    );
  }

  /// **App Logo Builder**
  /// 
  /// Creates the main app logo icon with consistent styling.
  Widget _buildLogo(BuildContext context) {
    return Semantics(
      label: 'Logo do PetiVeti',
      hint: 'Ícone principal do aplicativo para cuidados veterinários',
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.blue.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: Colors.blue.withValues(alpha: 0.2),
            width: 2,
          ),
        ),
        child: const Icon(
          Icons.pets,
          size: 60,
          color: Colors.blue,
        ),
      ),
    );
  }

  /// **App Name Builder**
  /// 
  /// Creates the app name title with branded styling.
  Widget _buildAppName(BuildContext context) {
    return Semantics(
      label: 'Nome do aplicativo PetiVeti',
      header: true,
      child: Text(
        'PetiVeti',
        style: Theme.of(context).textTheme.headlineMedium?.copyWith(
          fontWeight: FontWeight.bold,
          color: Colors.blue,
          letterSpacing: 1.2,
        ),
        textAlign: TextAlign.center,
      ),
    );
  }

  /// **Subtitle Builder**
  /// 
  /// Creates contextual subtitle text based on current mode.
  Widget _buildSubtitle(BuildContext context) {
    final subtitleText = isSignUp 
        ? 'Criar conta'
        : 'Faça login para continuar';

    return Semantics(
      label: 'Subtítulo da página de autenticação',
      hint: isSignUp 
          ? 'Página para criação de nova conta'
          : 'Página para login de usuários existentes',
      child: AnimatedSwitcher(
        duration: const Duration(milliseconds: 300),
        child: Text(
          subtitleText,
          key: ValueKey(subtitleText),
          style: Theme.of(context).textTheme.bodyLarge?.copyWith(
            color: Colors.grey[600],
            fontWeight: FontWeight.w500,
          ),
          textAlign: TextAlign.center,
        ),
      ),
    );
  }
}
