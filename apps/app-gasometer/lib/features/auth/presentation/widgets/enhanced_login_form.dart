import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import '../../../../core/di/injection_container.dart' as di;
import '../providers/auth_provider.dart';
import 'rate_limit_info_widget.dart';

/// Formulário de login aprimorado com rate limiting de segurança
class EnhancedLoginForm extends StatefulWidget {

  const EnhancedLoginForm({
    super.key,
    this.onRegisterTap,
    this.onForgotPasswordTap,
  });
  final VoidCallback? onRegisterTap;
  final VoidCallback? onForgotPasswordTap;

  @override
  State<EnhancedLoginForm> createState() => _EnhancedLoginFormState();
}

class _EnhancedLoginFormState extends State<EnhancedLoginForm> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  
  bool _showPassword = false;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = di.getIt<AuthProvider>();
    
    return StatefulBuilder(
      builder: (context, setState) {
        return Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Rate Limiting Info
              FutureBuilder(
                future: authProvider.getRateLimitInfo(),
                builder: (context, snapshot) {
                  if (snapshot.hasData) {
                    return RateLimitInfoWidget(
                      rateLimitInfo: snapshot.data!,
                      onReset: kDebugMode 
                          ? () async {
                              await authProvider.resetRateLimit();
                              setState(() {}); // Rebuild to show updated info
                            }
                          : null,
                    );
                  }
                  return const SizedBox.shrink();
                },
              ),
              
              const SizedBox(height: 16),
              
              // Email Field
              TextFormField(
                controller: _emailController,
                keyboardType: TextInputType.emailAddress,
                textInputAction: TextInputAction.next,
                decoration: const InputDecoration(
                  labelText: 'Email',
                  prefixIcon: Icon(Icons.email_outlined),
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Por favor, insira seu email';
                  }
                  if (!value.contains('@')) {
                    return 'Email inválido';
                  }
                  return null;
                },
              ),
              
              const SizedBox(height: 16),
              
              // Password Field
              TextFormField(
                controller: _passwordController,
                obscureText: !_showPassword,
                textInputAction: TextInputAction.done,
                decoration: InputDecoration(
                  labelText: 'Senha',
                  prefixIcon: const Icon(Icons.lock_outlined),
                  suffixIcon: IconButton(
                    icon: Icon(
                      _showPassword ? Icons.visibility_off : Icons.visibility,
                    ),
                    onPressed: () => setState(() => _showPassword = !_showPassword),
                  ),
                  border: const OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Por favor, insira sua senha';
                  }
                  if (value.length < 6) {
                    return 'Senha deve ter pelo menos 6 caracteres';
                  }
                  return null;
                },
                onFieldSubmitted: (_) => _handleLogin(authProvider),
              ),
              
              const SizedBox(height: 8),
              
              // Forgot Password
              Align(
                alignment: Alignment.centerRight,
                child: TextButton(
                  onPressed: widget.onForgotPasswordTap,
                  child: const Text('Esqueci minha senha'),
                ),
              ),
              
              const SizedBox(height: 16),
              
              // Login Button
              FutureBuilder(
                future: authProvider.canAttemptLogin(),
                builder: (context, snapshot) {
                  final canAttempt = snapshot.data ?? true;
                  
                  return ElevatedButton(
                    onPressed: canAttempt && !authProvider.isLoading 
                        ? () => _handleLogin(authProvider)
                        : null,
                    child: authProvider.isLoading
                        ? const SizedBox(
                            height: 20,
                            width: 20,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : const Text('Entrar'),
                  );
                },
              ),
              
              // Error Message
              if (authProvider.errorMessage != null) ...[
                const SizedBox(height: 16),
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.errorContainer,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        Icons.error_outline,
                        color: Theme.of(context).colorScheme.error,
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          authProvider.errorMessage!,
                          style: TextStyle(
                            color: Theme.of(context).colorScheme.onErrorContainer,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
              
              const SizedBox(height: 24),
              
              // Register Link
              if (widget.onRegisterTap != null)
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text('Não tem uma conta? '),
                    TextButton(
                      onPressed: widget.onRegisterTap,
                      child: const Text('Criar conta'),
                    ),
                  ],
                ),
            ],
          ),
        );
      },
    );
  }

  Future<void> _handleLogin(AuthProvider authProvider) async {
    if (!_formKey.currentState!.validate()) return;
    
    // Verifica rate limiting antes de tentar login
    final canAttempt = await authProvider.canAttemptLogin();
    if (!canAttempt) {
      // O provider já mostrará a mensagem de erro apropriada
      return;
    }
    
    await authProvider.login(
      _emailController.text.trim(),
      _passwordController.text,
    );
  }
}