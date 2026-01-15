import 'package:app_agrihurbi/core/theme/design_tokens.dart';
import 'package:app_agrihurbi/core/validators/input_validators.dart';
import 'package:app_agrihurbi/features/auth/presentation/notifiers/auth_notifier.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Widget para formulário de recuperação de senha
class RecoveryFormWidget extends ConsumerStatefulWidget {
  const RecoveryFormWidget({
    super.key,
    required this.onBackToLogin,
  });

  final VoidCallback onBackToLogin;

  @override
  ConsumerState<RecoveryFormWidget> createState() => _RecoveryFormWidgetState();
}

class _RecoveryFormWidgetState extends ConsumerState<RecoveryFormWidget> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  bool _isLoading = false;
  String? _errorMessage;
  bool _successMessageShown = false;

  @override
  void dispose() {
    _emailController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(32),
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
                    Icons.lock_reset,
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
                        'Recuperar Senha',
                        style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: DesignTokens.textPrimaryColor,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Enviaremos um link para redefinir sua senha',
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: DesignTokens.textSecondaryColor,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 32),

            // Email Field
            TextFormField(
              controller: _emailController,
              keyboardType: TextInputType.emailAddress,
              enabled: !_isLoading,
              decoration: InputDecoration(
                labelText: 'E-mail',
                hintText: 'seu@email.com',
                prefixIcon: const Icon(Icons.email_outlined),
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
              ),
              validator: InputValidators.validateEmail,
            ),

            // Error Message
            if (_errorMessage != null) ...[
              const SizedBox(height: 16),
              _buildErrorMessage(_errorMessage!),
            ],

            // Success Message
            if (_successMessageShown) ...[
              const SizedBox(height: 16),
              _buildSuccessMessage(),
            ],

            const SizedBox(height: 24),

            // Submit Button
            ElevatedButton(
              onPressed: _isLoading ? null : _handleResetPassword,
              style: ElevatedButton.styleFrom(
                backgroundColor: DesignTokens.primaryColor,
                foregroundColor: DesignTokens.textLightColor,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                elevation: 2,
              ),
              child: _isLoading
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
                      'Enviar Link de Recuperação',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
            ),

            const SizedBox(height: 16),

            // Back to Login
            Center(
              child: TextButton.icon(
                onPressed: _isLoading ? null : widget.onBackToLogin,
                icon: const Icon(Icons.arrow_back_ios, size: 14),
                label: const Text('Voltar para o login'),
                style: TextButton.styleFrom(
                  foregroundColor: DesignTokens.primaryColor,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildErrorMessage(String message) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: DesignTokens.errorColor.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: DesignTokens.errorColor.withValues(alpha: 0.3),
        ),
      ),
      child: Row(
        children: [
          Icon(
            Icons.error_outline,
            color: DesignTokens.errorColor,
            size: 20,
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              message,
              style: TextStyle(
                color: DesignTokens.errorColor,
                fontSize: 14,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSuccessMessage() {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: DesignTokens.successColor.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: DesignTokens.successColor.withValues(alpha: 0.3),
        ),
      ),
      child: Row(
        children: [
          Icon(
            Icons.check_circle_outline,
            color: DesignTokens.successColor,
            size: 20,
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              'Email de recuperação enviado! Verifique sua caixa de entrada.',
              style: TextStyle(
                color: DesignTokens.successColor,
                fontSize: 14,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _handleResetPassword() async {
    final email = _emailController.text.trim();

    if (email.isEmpty) {
      setState(() {
        _errorMessage = 'Email é obrigatório';
        _successMessageShown = false;
      });
      return;
    }

    if (!_formKey.currentState!.validate()) {
      setState(() {
        _errorMessage = 'Email inválido';
        _successMessageShown = false;
      });
      return;
    }

    setState(() {
      _isLoading = true;
      _errorMessage = null;
      _successMessageShown = false;
    });

    try {
      final authNotifier = ref.read(authProvider.notifier);
      final result = await authNotifier.sendPasswordReset(email);

      if (!mounted) return;

      result.fold(
        (failure) {
          setState(() {
            _errorMessage = failure.message;
            _isLoading = false;
          });
        },
        (_) {
          setState(() {
            _successMessageShown = true;
            _isLoading = false;
          });
          // Volta para login após 3 segundos
          Future<void>.delayed(const Duration(seconds: 3), () {
            if (mounted) {
              widget.onBackToLogin();
            }
          });
        },
      );
    } catch (e) {
      if (mounted) {
        setState(() {
          _errorMessage = 'Erro ao enviar email de recuperação';
          _isLoading = false;
        });
      }
    }
  }
}
