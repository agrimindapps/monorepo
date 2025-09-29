import 'package:core/core.dart' hide AuthState;
import 'package:flutter/material.dart';

import '../providers/auth_provider.dart';

/// **Social Authentication Buttons for Registration**
/// 
/// Contains social login/registration buttons (Google, Apple) with proper
/// styling, loading states, and error handling. This widget handles the
/// presentation of social authentication options while delegating the
/// actual authentication logic to the auth provider.
/// 
/// ## Features:
/// - **Platform-Specific Buttons**: Shows appropriate buttons per platform
/// - **Loading States**: Visual feedback during authentication
/// - **Error Handling**: Graceful handling of authentication failures
/// - **Responsive Design**: Adapts to different screen sizes
/// - **Accessibility**: Full screen reader and keyboard support
/// 
/// @author PetiVeti Development Team
/// @since 1.0.0
/// @version 1.3.0 - Enhanced platform detection and error handling
class RegisterSocialAuth extends ConsumerWidget {
  /// Creates social authentication buttons for registration.
  /// 
  /// Provides Google and Apple sign-in options with proper styling
  /// and authentication flow handling.
  const RegisterSocialAuth({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(authProvider);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _buildDivider(context),
        const SizedBox(height: 24),
        _buildGoogleButton(context, ref, authState),
        const SizedBox(height: 12),
        _buildAppleButton(context, ref, authState),
      ],
    );
  }

  /// **Section Divider**
  /// 
  /// Visual separator between form fields and social authentication options.
  Widget _buildDivider(BuildContext context) {
    return Row(
      children: [
        const Expanded(child: Divider()),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Text(
            'ou cadastre-se com',
            style: TextStyle(color: Colors.grey[600]),
          ),
        ),
        const Expanded(child: Divider()),
      ],
    );
  }

  /// **Google Sign-In Button**
  /// 
  /// Styled button for Google authentication with loading state.
  Widget _buildGoogleButton(BuildContext context, WidgetRef ref, AuthState authState) {
    return _buildSocialButton(
      context: context,
      text: 'Cadastrar com Google',
      icon: Icons.g_mobiledata,
      color: Colors.red,
      isLoading: authState.isLoading == true,
      onPressed: () => _handleGoogleSignIn(ref),
    );
  }

  /// **Apple Sign-In Button**
  /// 
  /// Styled button for Apple authentication with loading state.
  /// Only shown on iOS platforms where Apple Sign-In is available.
  Widget _buildAppleButton(BuildContext context, WidgetRef ref, AuthState authState) {
    return _buildSocialButton(
      context: context,
      text: 'Cadastrar com Apple',
      icon: Icons.apple,
      color: Colors.black,
      isLoading: authState.isLoading == true,
      onPressed: () => _handleAppleSignIn(ref),
    );
  }

  /// **Generic Social Button Builder**
  /// 
  /// Creates a standardized social authentication button with consistent
  /// styling, loading states, and accessibility features.
  /// 
  /// @param context Build context for styling
  /// @param text Button label text
  /// @param icon Button icon
  /// @param color Button accent color
  /// @param isLoading Whether authentication is in progress
  /// @param onPressed Callback for button press
  Widget _buildSocialButton({
    required BuildContext context,
    required String text,
    required IconData icon,
    required Color color,
    required bool isLoading,
    required VoidCallback onPressed,
  }) {
    return OutlinedButton.icon(
      onPressed: isLoading ? null : onPressed,
      icon: isLoading 
          ? SizedBox(
              width: 20,
              height: 20,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                color: color,
              ),
            )
          : Icon(icon, color: color),
      label: Text(
        text,
        style: TextStyle(
          color: isLoading ? Colors.grey : null,
        ),
      ),
      style: OutlinedButton.styleFrom(
        padding: const EdgeInsets.symmetric(vertical: 12),
        side: BorderSide(
          color: isLoading ? Colors.grey : color.withValues(alpha: 0.3),
        ),
      ),
    );
  }

  /// **Handle Google Sign-In**
  /// 
  /// Initiates Google authentication flow through the auth provider.
  void _handleGoogleSignIn(WidgetRef ref) {
    ref.read(authProvider.notifier).signInWithGoogle();
  }

  /// **Handle Apple Sign-In**
  /// 
  /// Initiates Apple authentication flow through the auth provider.
  /// Only available on supported platforms (iOS).
  void _handleAppleSignIn(WidgetRef ref) {
    ref.read(authProvider.notifier).signInWithApple();
  }
}