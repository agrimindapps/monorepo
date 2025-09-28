import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../../core/di/injection_container.dart' as di;
import '../controllers/login_controller.dart';
import '../providers/auth_provider.dart';
import 'auth_button_widget.dart';
import 'auth_text_field_widget.dart';
import 'social_login_buttons_widget.dart';

/// Widget responsável apenas pelo formulário de login
/// Segue o princípio da Responsabilidade Única
class LoginFormWidget extends StatelessWidget {

  const LoginFormWidget({
    super.key,
    this.onLoginSuccess,
  });
  final VoidCallback? onLoginSuccess;

  @override
  Widget build(BuildContext context) {
    return Consumer<LoginController>(
      builder: (context, controller, child) {
        return Form(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Acesse sua conta para gerenciar seu consumo',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: Colors.grey[600],
                ),
              ),
              const SizedBox(height: 20),

              // Campo de email
              AuthTextFieldWidget(
                controller: controller.emailController,
                label: 'Email',
                hint: 'Insira seu email',
                prefixIcon: Icons.email_outlined,
                keyboardType: TextInputType.emailAddress,
                validator: controller.validateEmail,
                onFieldSubmitted: (_) {
                  // Focar no próximo campo
                },
              ),
              const SizedBox(height: 16),

              // Campo de senha
              AuthTextFieldWidget(
                controller: controller.passwordController,
                label: 'Senha',
                hint: 'Insira sua senha',
                prefixIcon: Icons.lock_outline,
                obscureText: controller.obscurePassword,
                suffixIcon: IconButton(
                  icon: Icon(
                    controller.obscurePassword
                        ? Icons.visibility_outlined
                        : Icons.visibility_off_outlined,
                  ),
                  onPressed: controller.togglePasswordVisibility,
                  tooltip: controller.obscurePassword
                      ? 'Mostrar senha'
                      : 'Ocultar senha',
                ),
                validator: controller.validatePassword,
                onFieldSubmitted: (_) => _handleLogin(context),
              ),
              const SizedBox(height: 12),

              // Lembrar-me e Esqueceu senha
              _buildRememberMeAndForgotPassword(context),

              // Mensagem de erro
              if (controller.errorMessage != null) ...[
                const SizedBox(height: 16),
                _buildErrorMessage(context, controller.errorMessage!),
              ] else if (kDebugMode && controller.authError != null) ...[
                // Debug: Mostrar erro do AuthProvider se não há erro no controller
                const SizedBox(height: 16),
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.orange.shade50,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.orange.shade200),
                  ),
                  child: Text(
                    'DEBUG - AuthProvider Error: ${controller.authError}',
                    style: TextStyle(
                      color: Colors.orange.shade700,
                      fontSize: 12,
                    ),
                  ),
                ),
              ],
              const SizedBox(height: 20),

              // Botão de login
              AuthButtonWidget(
                text: 'Entrar',
                isLoading: controller.isLoading,
                onPressed: () => _handleLogin(context),
              ),

              const SizedBox(height: 20),

              // Divider
              const Row(
                children: [
                  Expanded(child: Divider()),
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: 16.0),
                    child: Text(
                      'ou continue com',
                      style: TextStyle(
                        color: Colors.grey,
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                  Expanded(child: Divider()),
                ],
              ),
              const SizedBox(height: 16),

              // Botões de login social
              const SocialLoginButtonsWidget(),
              const SizedBox(height: 16),

              // Nota sobre login social
              Center(
                child: Text(
                  '* Opções de login social estarão disponíveis em breve',
                  style: TextStyle(
                    fontSize: 12,
                    fontStyle: FontStyle.italic,
                    color: Colors.grey[600],
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
              
              const SizedBox(height: 16),
              
              // Botão de modo anônimo
              _buildAnonymousLoginButton(context),
            ],
          ),
        );
      },
    );
  }

  Widget _buildRememberMeAndForgotPassword(BuildContext context) {
    return Consumer<LoginController>(
      builder: (context, controller, child) {
        return Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              children: [
                SizedBox(
                  height: 24,
                  width: 24,
                  child: Checkbox(
                    value: controller.rememberMe,
                    activeColor: Theme.of(context).primaryColor,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(4),
                    ),
                    onChanged: (_) => controller.toggleRememberMe(),
                  ),
                ),
                const SizedBox(width: 8),
                Text(
                  'Lembrar-me',
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey[700],
                  ),
                ),
              ],
            ),
            GestureDetector(
              onTap: controller.showRecoveryForm,
              child: Text(
                'Esqueceu sua senha?',
                style: TextStyle(
                  color: Theme.of(context).primaryColor,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildErrorMessage(BuildContext context, String message) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.red.shade50,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.red.shade200),
      ),
      child: Row(
        children: [
          Icon(
            Icons.error_outline,
            color: Colors.red.shade700,
            size: 20,
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              message,
              style: TextStyle(
                color: Colors.red.shade700,
                fontSize: 14,
              ),
            ),
          ),
          const SizedBox(width: 8),
          GestureDetector(
            onTap: () {
              final controller = context.read<LoginController>();
              controller.clearError();
            },
            child: Container(
              padding: const EdgeInsets.all(4),
              child: Icon(
                Icons.close,
                color: Colors.red.shade700,
                size: 16,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAnonymousLoginButton(BuildContext context) {
    final authProvider = di.getIt<AuthProvider>();
    
    return SizedBox(
      width: double.infinity,
      height: 48,
      child: OutlinedButton(
        onPressed: authProvider.isLoading
            ? null
            : () async {
                await authProvider.signInAnonymously();
                if (context.mounted && authProvider.isAuthenticated && onLoginSuccess != null) {
                  onLoginSuccess!();
                }
              },
            style: OutlinedButton.styleFrom(
              foregroundColor: Theme.of(context).primaryColor,
              side: BorderSide(
                color: Theme.of(context).primaryColor.withValues(alpha: 0.3),
              ),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: authProvider.isLoading
                ? SizedBox(
                    height: 20,
                    width: 20,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      valueColor: AlwaysStoppedAnimation<Color>(
                        Theme.of(context).primaryColor,
                      ),
                    ),
                  )
                : Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.person_outline,
                        size: 20,
                        color: Theme.of(context).primaryColor,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        'Continuar sem conta',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                          color: Theme.of(context).primaryColor,
                        ),
                      ),
                    ],
                  ),
        ),
      );
  }

  void _handleLogin(BuildContext context) async {
    if (kDebugMode) {
      print('🎯 LoginFormWidget: Chamando login simplificado - padrão app-plantis');
    }
    
    final controller = context.read<LoginController>();
    await controller.signInWithEmailAndSync();
    
    if (kDebugMode) {
      print('🎯 LoginFormWidget: Após login - autenticado: ${controller.isAuthenticated}, erro controller: ${controller.errorMessage}, erro auth: ${controller.authError}');
    }
    
    if (controller.isAuthenticated && onLoginSuccess != null) {
      onLoginSuccess!();
    }
  }
}