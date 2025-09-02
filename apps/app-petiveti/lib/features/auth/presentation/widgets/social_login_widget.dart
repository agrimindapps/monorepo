import 'package:flutter/material.dart';

/// Social login widget following SRP
/// 
/// Single responsibility: Handle social authentication options
class SocialLoginWidget extends StatelessWidget {
  final bool isLoading;
  final void Function(String) onSocialAuth;
  final VoidCallback onAnonymousLogin;

  const SocialLoginWidget({
    super.key,
    required this.isLoading,
    required this.onSocialAuth,
    required this.onAnonymousLogin,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        const SizedBox(height: 32),
        const Row(
          children: [
            Expanded(child: Divider()),
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 16),
              child: Text(
                'ou continue com',
                style: TextStyle(
                  color: Colors.grey,
                  fontSize: 14,
                ),
              ),
            ),
            Expanded(child: Divider()),
          ],
        ),
        const SizedBox(height: 20),
        
        _buildSocialButtons(),
        
        const SizedBox(height: 16),
        
        _buildAnonymousButton(),
      ],
    );
  }

  Widget _buildSocialButtons() {
    return Row(
      children: [
        Expanded(
          child: _buildSocialButton(
            icon: Icons.g_mobiledata,
            text: 'Google',
            onPressed: () => onSocialAuth('google'),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _buildSocialButton(
            icon: Icons.apple,
            text: 'Apple',
            onPressed: () => onSocialAuth('apple'),
          ),
        ),
      ],
    );
  }

  Widget _buildSocialButton({
    required IconData icon,
    required String text,
    required VoidCallback onPressed,
  }) {
    return OutlinedButton.icon(
      onPressed: null, // Disabled for now
      icon: Icon(icon, size: 20),
      label: Text(text),
      style: OutlinedButton.styleFrom(
        padding: const EdgeInsets.symmetric(vertical: 12),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
      ),
    );
  }

  Widget _buildAnonymousButton() {
    return SizedBox(
      width: double.infinity,
      height: 45,
      child: OutlinedButton.icon(
        onPressed: isLoading ? null : onAnonymousLogin,
        icon: const Icon(Icons.person_outline, size: 18),
        label: const Text('Entrar Anonimamente'),
        style: OutlinedButton.styleFrom(
          foregroundColor: Colors.grey[600],
          side: BorderSide(color: Colors.grey[300]!),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
        ),
      ),
    );
  }
}