import 'package:app_agrihurbi/core/theme/design_tokens.dart';
import 'package:app_agrihurbi/core/utils/error_handler.dart';
import 'package:app_agrihurbi/core/validators/input_validators.dart';
import 'package:app_agrihurbi/features/auth/presentation/notifiers/auth_notifier.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Widget para vincular conta anônima com email/senha
class AccountLinkingWidget extends ConsumerStatefulWidget {
  const AccountLinkingWidget({
    super.key,
    this.onLinkSuccess,
    this.onCancel,
  });

  final VoidCallback? onLinkSuccess;
  final VoidCallback? onCancel;

  @override
  ConsumerState<AccountLinkingWidget> createState() =>
      _AccountLinkingWidgetState();
}

class _AccountLinkingWidgetState extends ConsumerState<AccountLinkingWidget> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authProvider);

    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: DesignTokens.surfaceColor,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          mainAxisSize: MainAxisSize.min,
          children: [
            // Header
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: DesignTokens.primaryColor.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(
                    Icons.link,
                    color: DesignTokens.primaryColor,
                    size: 28,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Criar Conta',
                        style:
                            Theme.of(context).textTheme.headlineSmall?.copyWith(
                                  fontWeight: FontWeight.bold,
                                  color: DesignTokens.textPrimaryColor,
                                ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Vincule sua conta para salvar seus dados',
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                              color: DesignTokens.textSecondaryColor,
                            ),
                      ),
                    ],
                  ),
                ),
              ],
            ),

            const SizedBox(height: 24),

            // Info banner
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: DesignTokens.infoColor.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: DesignTokens.infoColor.withValues(alpha: 0.3),
                ),
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.info_outline,
                    color: DesignTokens.infoColor,
                    size: 20,
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      'Seus dados serão preservados após vincular sua conta.',
                      style: TextStyle(
                        color: DesignTokens.infoColor,
                        fontSize: 13,
                      ),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 24),

            // Name Field
            TextFormField(
              controller: _nameController,
              enabled: !authState.isLinkingAccount,
              decoration: _buildInputDecoration(
                label: 'Nome completo',
                hint: 'Seu nome',
                icon: Icons.person_outlined,
              ),
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return 'Nome é obrigatório';
                }
                if (value.trim().length < 2) {
                  return 'Nome deve ter pelo menos 2 caracteres';
                }
                return null;
              },
            ),

            const SizedBox(height: 16),

            // Email Field
            TextFormField(
              controller: _emailController,
              keyboardType: TextInputType.emailAddress,
              enabled: !authState.isLinkingAccount,
              decoration: _buildInputDecoration(
                label: 'E-mail',
                hint: 'seu@email.com',
                icon: Icons.email_outlined,
              ),
              validator: InputValidators.validateEmail,
            ),

            const SizedBox(height: 16),

            // Password Field
            TextFormField(
              controller: _passwordController,
              obscureText: _obscurePassword,
              enabled: !authState.isLinkingAccount,
              decoration: _buildInputDecoration(
                label: 'Senha',
                hint: 'Crie uma senha segura',
                icon: Icons.lock_outlined,
                suffixIcon: IconButton(
                  icon: Icon(
                    _obscurePassword
                        ? Icons.visibility_outlined
                        : Icons.visibility_off_outlined,
                  ),
                  onPressed: () {
                    setState(() {
                      _obscurePassword = !_obscurePassword;
                    });
                  },
                ),
              ),
              validator: PasswordValidator.validatePassword,
            ),

            const SizedBox(height: 16),

            // Confirm Password Field
            TextFormField(
              controller: _confirmPasswordController,
              obscureText: _obscureConfirmPassword,
              enabled: !authState.isLinkingAccount,
              decoration: _buildInputDecoration(
                label: 'Confirmar senha',
                hint: 'Repita a senha',
                icon: Icons.lock_outlined,
                suffixIcon: IconButton(
                  icon: Icon(
                    _obscureConfirmPassword
                        ? Icons.visibility_outlined
                        : Icons.visibility_off_outlined,
                  ),
                  onPressed: () {
                    setState(() {
                      _obscureConfirmPassword = !_obscureConfirmPassword;
                    });
                  },
                ),
              ),
              validator: (value) {
                if (value != _passwordController.text) {
                  return 'As senhas não coincidem';
                }
                return null;
              },
            ),

            const SizedBox(height: 24),

            // Submit Button
            ElevatedButton(
              onPressed:
                  authState.isLinkingAccount ? null : _handleLinkAccount,
              style: ElevatedButton.styleFrom(
                backgroundColor: DesignTokens.primaryColor,
                foregroundColor: DesignTokens.textLightColor,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                elevation: 2,
              ),
              child: authState.isLinkingAccount
                  ? const SizedBox(
                      height: 24,
                      width: 24,
                      child: CircularProgressIndicator(
                        strokeWidth: 2.5,
                        valueColor: AlwaysStoppedAnimation<Color>(
                          DesignTokens.textLightColor,
                        ),
                      ),
                    )
                  : const Text(
                      'Criar Conta',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
            ),

            const SizedBox(height: 12),

            // Cancel Button
            if (widget.onCancel != null)
              TextButton(
                onPressed:
                    authState.isLinkingAccount ? null : widget.onCancel,
                style: TextButton.styleFrom(
                  foregroundColor: DesignTokens.textSecondaryColor,
                ),
                child: const Text('Continuar como visitante'),
              ),
          ],
        ),
      ),
    );
  }

  InputDecoration _buildInputDecoration({
    required String label,
    required String hint,
    required IconData icon,
    Widget? suffixIcon,
  }) {
    return InputDecoration(
      labelText: label,
      hintText: hint,
      prefixIcon: Icon(icon),
      suffixIcon: suffixIcon,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: DesignTokens.borderColor),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: DesignTokens.borderColor),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(
          color: DesignTokens.primaryColor,
          width: 2,
        ),
      ),
      filled: true,
      fillColor: DesignTokens.backgroundColor,
    );
  }

  Future<void> _handleLinkAccount() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    final result = await ref.read(authProvider.notifier).linkAnonymousWithEmail(
          name: _nameController.text.trim(),
          email: _emailController.text.trim(),
          password: _passwordController.text,
        );

    if (!mounted) return;

    result.fold(
      (failure) {
        ErrorHandler.showErrorSnackbar(context, failure);
      },
      (user) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Conta criada com sucesso!'),
            backgroundColor: DesignTokens.successColor,
          ),
        );
        widget.onLinkSuccess?.call();
      },
    );
  }
}
