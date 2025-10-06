import 'package:core/core.dart';
import 'package:flutter/material.dart';
import 'package:core/core.dart' show GetIt;

import '../../domain/repositories/auth_repository.dart';

/// Widget para botões de login social
/// Segue o princípio da Responsabilidade Única
class SocialLoginButtonsWidget extends StatefulWidget {
  const SocialLoginButtonsWidget({super.key, this.onLoginSuccess});

  final VoidCallback? onLoginSuccess;

  @override
  State<SocialLoginButtonsWidget> createState() =>
      _SocialLoginButtonsWidgetState();
}

class _SocialLoginButtonsWidgetState extends State<SocialLoginButtonsWidget> {
  bool _isLoading = false;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        _buildSocialButton(
          context: context,
          icon: Icons.g_mobiledata,
          label: 'Google',
          color: Colors.red.shade600,
          backgroundColor: isDark ? Colors.grey[800]! : Colors.grey[100]!,
          onPressed: _isLoading ? null : () => _handleGoogleSignIn(context),
        ),
        const SizedBox(width: 16),
        _buildSocialButton(
          context: context,
          icon: Icons.apple,
          label: 'Apple',
          color: isDark ? Colors.white : Colors.black,
          backgroundColor: isDark ? Colors.grey[800]! : Colors.grey[100]!,
          onPressed: _isLoading ? null : () => _handleAppleSignIn(context),
        ),
        const SizedBox(width: 16),
        _buildSocialButton(
          context: context,
          icon: Icons.facebook,
          label: 'Facebook',
          color: Colors.blue.shade700,
          backgroundColor: isDark ? Colors.grey[800]! : Colors.grey[100]!,
          onPressed: _isLoading ? null : () => _handleFacebookSignIn(context),
        ),
      ],
    );
  }

  Future<void> _handleGoogleSignIn(BuildContext context) async {
    setState(() => _isLoading = true);

    try {
      // Get AuthRepository from GetIt (injectable)
      final authRepository = GetIt.I<AuthRepository>();
      final result = await authRepository.signInWithGoogle();

      if (!mounted) return;

      final messenger = ScaffoldMessenger.of(context);

      result.fold(
        (failure) {
          messenger.showSnackBar(
            SnackBar(
              content: Text(failure.message),
              backgroundColor: Colors.red,
            ),
          );
        },
        (_) {
          if (widget.onLoginSuccess != null) {
            widget.onLoginSuccess!();
          }
        },
      );
    } catch (e) {
      if (!mounted) return;

      final messenger = ScaffoldMessenger.of(context);
      messenger.showSnackBar(
        SnackBar(
          content: Text('Erro no login com Google: $e'),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  Future<void> _handleAppleSignIn(BuildContext context) async {
    setState(() => _isLoading = true);

    try {
      final authRepository = GetIt.I<AuthRepository>();
      final result = await authRepository.signInWithApple();

      if (!mounted) return;

      final messenger = ScaffoldMessenger.of(context);

      result.fold(
        (failure) {
          messenger.showSnackBar(
            SnackBar(
              content: Text(failure.message),
              backgroundColor: Colors.red,
            ),
          );
        },
        (_) {
          if (widget.onLoginSuccess != null) {
            widget.onLoginSuccess!();
          }
        },
      );
    } catch (e) {
      if (!mounted) return;

      final messenger = ScaffoldMessenger.of(context);
      messenger.showSnackBar(
        SnackBar(
          content: Text('Erro no login com Apple: $e'),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  Future<void> _handleFacebookSignIn(BuildContext context) async {
    setState(() => _isLoading = true);

    try {
      final authRepository = GetIt.I<AuthRepository>();
      final result = await authRepository.signInWithFacebook();

      if (!mounted) return;

      final messenger = ScaffoldMessenger.of(context);

      result.fold(
        (failure) {
          messenger.showSnackBar(
            SnackBar(
              content: Text(failure.message),
              backgroundColor: Colors.red,
            ),
          );
        },
        (_) {
          if (widget.onLoginSuccess != null) {
            widget.onLoginSuccess!();
          }
        },
      );
    } catch (e) {
      if (!mounted) return;

      final messenger = ScaffoldMessenger.of(context);
      messenger.showSnackBar(
        SnackBar(
          content: Text('Erro no login com Facebook: $e'),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  Widget _buildSocialButton({
    required BuildContext context,
    required IconData icon,
    required String label,
    required Color color,
    required Color backgroundColor,
    required VoidCallback? onPressed,
  }) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Tooltip(
      message:
          onPressed != null
              ? 'Login com $label'
              : 'Login com $label (Em breve)',
      child: OutlinedButton.icon(
        onPressed: onPressed,
        icon: Icon(
          icon,
          size: 20,
          color: onPressed != null ? color : color.withValues(alpha: 0.5),
        ),
        label: Text(
          label,
          style: TextStyle(
            color:
                onPressed != null
                    ? (isDark ? Colors.white : Colors.black87)
                    : (isDark ? Colors.grey[500] : Colors.grey[600]),
          ),
        ),
        style: OutlinedButton.styleFrom(
          backgroundColor: backgroundColor,
          side: BorderSide(
            color: isDark ? Colors.grey[700]! : Colors.grey[300]!,
          ),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        ),
      ),
    );
  }
}
