import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/errors/failures.dart';
import '../../../core/theme/app_colors.dart';
import '../../providers/auth_providers.dart';
import '../home_page.dart';
import 'register_page.dart';

class LoginPage extends ConsumerStatefulWidget {
  const LoginPage({super.key});

  @override
  ConsumerState<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends ConsumerState<LoginPage> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _isPasswordVisible = false;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
  }


  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _handleLogin() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      await ref.read(authNotifierProvider.notifier).signInWithEmailAndPassword(
        _emailController.text.trim(),
        _passwordController.text,
      );
      // Navegação será tratada pelo listener
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
        _showErrorSnackBar(_getErrorMessage(e));
      }
    }
  }

  Future<void> _handleAnonymousLogin() async {
    setState(() => _isLoading = true);
    
    try {
      await ref.read(authNotifierProvider.notifier).signInAnonymously();
      // Navegação será tratada pelo listener
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
        _showErrorSnackBar('Erro no login anônimo: ${_getErrorMessage(e)}');
      }
    }
  }

  Future<void> _handleDemoLogin() async {
    setState(() => _isLoading = true);
    
    try {
      // Primeiro tenta login com conta demo
      await ref.read(authNotifierProvider.notifier).signInWithEmailAndPassword(
        'demo@taskmanager.com',
        'demo123456',
      );
      // Navegação será tratada pelo listener
    } catch (e) {
      // Se conta demo não existe, cria login anônimo
      try {
        await ref.read(authNotifierProvider.notifier).signInAnonymously();
        // Navegação será tratada pelo listener
      } catch (e2) {
        if (mounted) {
          setState(() => _isLoading = false);
          _showErrorSnackBar('Erro ao acessar modo demo: ${_getErrorMessage(e2)}');
        }
      }
    }
  }

  Future<void> _handleGoogleLogin() async {
    setState(() => _isLoading = true);
    
    try {
      await ref.read(authNotifierProvider.notifier).signInWithGoogle();
      // Navegação será tratada pelo listener
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
        _showInfoSnackBar('Login com Google não disponível ainda');
      }
    }
  }

  Future<void> _handleForgotPassword() async {
    if (_emailController.text.trim().isEmpty) {
      _showWarningSnackBar('Digite seu email primeiro');
      return;
    }

    setState(() => _isLoading = true);

    try {
      await ref.read(authNotifierProvider.notifier).sendPasswordResetEmail(
        _emailController.text.trim(),
      );
      
      if (mounted) {
        setState(() => _isLoading = false);
        _showSuccessSnackBar('Email de redefinição enviado!');
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
        _showErrorSnackBar('Erro ao enviar email: ${_getErrorMessage(e)}');
      }
    }
  }

  Future<void> _showAnonymousLoginDialog() async {
    final bool? confirmed = await showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        final theme = Theme.of(context);
        final isDarkMode = theme.brightness == Brightness.dark;
        
        return Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          backgroundColor: Colors.transparent,
          child: Container(
            constraints: const BoxConstraints(maxWidth: 420),
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: AppColors.primaryColor.withAlpha(77),
                width: 1,
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withAlpha(26),
                  blurRadius: 20,
                  offset: const Offset(0, 8),
                ),
                BoxShadow(
                  color: AppColors.primaryColor.withAlpha(51),
                  blurRadius: 15,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Header with icon and title
                Row(
                  children: [
                    Container(
                      width: 48,
                      height: 48,
                      decoration: BoxDecoration(
                        color: AppColors.primaryColor,
                        borderRadius: BorderRadius.circular(12),
                        boxShadow: [
                          BoxShadow(
                            color: AppColors.primaryColor.withAlpha(102),
                            blurRadius: 12,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: const Icon(
                        Icons.visibility_off_rounded,
                        color: Colors.white,
                        size: 24,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Text(
                        'Login Anônimo',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 20,
                          color: AppColors.textPrimary,
                          letterSpacing: 0.5,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 24),
                
                // Content
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'O Login Anônimo permite que você:',
                      style: TextStyle(
                        fontWeight: FontWeight.w600,
                        fontSize: 16,
                        color: AppColors.textPrimary,
                        letterSpacing: 0.3,
                      ),
                    ),
                    const SizedBox(height: 16),
                    
                    // Benefits list
                    _buildBenefitItem(
                      icon: Icons.check_circle_rounded,
                      text: 'Use todas as funcionalidades do app',
                      color: AppColors.success,
                    ),
                    const SizedBox(height: 12),
                    _buildBenefitItem(
                      icon: Icons.check_circle_rounded,
                      text: 'Não precisa fornecer dados pessoais',
                      color: AppColors.success,
                    ),
                    const SizedBox(height: 12),
                    _buildBenefitItem(
                      icon: Icons.check_circle_rounded,
                      text: 'Acesso instantâneo e privado',
                      color: AppColors.success,
                    ),
                    const SizedBox(height: 20),
                    
                    // Warning container
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: AppColors.warning.withAlpha(26),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: AppColors.warning.withAlpha(77),
                        ),
                      ),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Container(
                            padding: const EdgeInsets.all(4),
                            decoration: BoxDecoration(
                              color: AppColors.warning.withAlpha(51),
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: Icon(
                              Icons.warning_amber_rounded,
                              color: AppColors.warning,
                              size: 16,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Text(
                              'Atenção: Seus dados serão perdidos quando você sair do app',
                              style: TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.w500,
                                color: AppColors.textSecondary,
                                height: 1.3,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                
                const SizedBox(height: 28),
                
                // Action buttons
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    TextButton(
                      onPressed: () => Navigator.of(context).pop(false),
                      style: TextButton.styleFrom(
                        foregroundColor: AppColors.textSecondary,
                        textStyle: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                        ),
                        padding: const EdgeInsets.symmetric(
                          horizontal: 20,
                          vertical: 12,
                        ),
                      ),
                      child: const Text('Cancelar'),
                    ),
                    const SizedBox(width: 12),
                    ElevatedButton.icon(
                      onPressed: () => Navigator.of(context).pop(true),
                      icon: const Icon(Icons.login_rounded, size: 18),
                      label: const Text('Continuar'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primaryColor,
                        foregroundColor: Colors.white,
                        elevation: 8,
                        shadowColor: AppColors.primaryColor.withAlpha(102),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        padding: const EdgeInsets.symmetric(
                          horizontal: 20,
                          vertical: 12,
                        ),
                        textStyle: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          letterSpacing: 0.5,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );

    if (confirmed == true) {
      await _handleAnonymousLogin();
    }
  }

  void _navigateToRegister() {
    Navigator.of(context).push(
      MaterialPageRoute(builder: (context) => const RegisterPage()),
    );
  }

  String _getErrorMessage(dynamic error) {
    if (error is Failure) {
      return error.message;
    }
    return error.toString();
  }

  void _showErrorSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: AppColors.error,
      ),
    );
  }

  void _showSuccessSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: AppColors.success,
      ),
    );
  }

  void _showWarningSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: AppColors.warning,
      ),
    );
  }

  void _showInfoSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: AppColors.info,
      ),
    );
  }

  Widget _buildBenefitItem({
    required IconData icon,
    required String text,
    required Color color,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: const EdgeInsets.all(2),
          decoration: BoxDecoration(
            color: color.withAlpha(26),
            borderRadius: BorderRadius.circular(6),
          ),
          child: Icon(
            icon,
            color: color,
            size: 16,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Text(
            text,
            style: TextStyle(
              fontSize: 14,
              color: AppColors.textSecondary,
              height: 1.2,
            ),
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    // Setup auth listener inside build method
    ref.listen<AsyncValue<dynamic>>(authNotifierProvider, (previous, next) {
      next.when(
        data: (user) {
          if (user != null && mounted) {
            Navigator.of(context).pushReplacement(
              MaterialPageRoute(builder: (context) => const HomePage()),
            );
          }
        },
        loading: () {},
        error: (error, stack) {},
      );
    });

    // Verifica se já está autenticado
    final authState = ref.watch(authNotifierProvider);

    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const SizedBox(height: 40),
                
                // Logo/Título
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: AppColors.primaryColor.withAlpha(26),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.task_alt,
                    size: 60,
                    color: AppColors.primaryColor,
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  'Task Manager',
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: AppColors.primaryColor,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Entre para gerenciar suas tarefas',
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                    color: Colors.grey[600],
                  ),
                ),
                const SizedBox(height: 48),

                // Campo Email
                TextFormField(
                  controller: _emailController,
                  keyboardType: TextInputType.emailAddress,
                  enabled: !_isLoading,
                  decoration: const InputDecoration(
                    labelText: 'Email',
                    contentPadding: EdgeInsets.symmetric(
                      horizontal: 20,
                      vertical: 16,
                    ),
                    prefixIcon: Icon(Icons.email_outlined),
                    border: OutlineInputBorder(),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Por favor, insira seu email';
                    }
                    if (!value.contains('@')) {
                      return 'Por favor, insira um email válido';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),

                // Campo Senha
                TextFormField(
                  controller: _passwordController,
                  obscureText: !_isPasswordVisible,
                  enabled: !_isLoading,
                  decoration: InputDecoration(
                    labelText: 'Senha',
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 20,
                      vertical: 16,
                    ),
                    prefixIcon: const Icon(Icons.lock_outlined),
                    suffixIcon: IconButton(
                      icon: Icon(
                        _isPasswordVisible ? Icons.visibility : Icons.visibility_off,
                      ),
                      onPressed: () {
                        setState(() {
                          _isPasswordVisible = !_isPasswordVisible;
                        });
                      },
                    ),
                    border: const OutlineInputBorder(),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Por favor, insira sua senha';
                    }
                    if (value.length < 6) {
                      return 'A senha deve ter pelo menos 6 caracteres';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 24),

                // Botão de Login
                ElevatedButton(
                  onPressed: _isLoading ? null : _handleLogin,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primaryColor,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: _isLoading
                      ? const SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: Colors.white,
                          ),
                        )
                      : const Text('Entrar', style: TextStyle(fontSize: 16)),
                ),
                const SizedBox(height: 12),
                
                // Link esqueceu senha
                TextButton(
                  onPressed: _isLoading ? null : _handleForgotPassword,
                  child: const Text('Esqueceu a senha?'),
                ),
                const SizedBox(height: 16),

                // Link para registro
                TextButton(
                  onPressed: _isLoading ? null : _navigateToRegister,
                  child: const Text('Não tem uma conta? Registre-se'),
                ),

                // Divider
                const Row(
                  children: [
                    Expanded(child: Divider()),
                    Padding(
                      padding: EdgeInsets.symmetric(horizontal: 16),
                      child: Text('OU'),
                    ),
                    Expanded(child: Divider()),
                  ],
                ),
                const SizedBox(height: 24),
                
                // Botões de login social
                OutlinedButton.icon(
                  onPressed: _isLoading ? null : _handleGoogleLogin,
                  icon: const Icon(Icons.login, color: Colors.red),
                  label: const Text('Continuar com Google'),
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    side: const BorderSide(color: Colors.grey),
                  ),
                ),
                const SizedBox(height: 12),
                
                // Botão de login anônimo/convidado
                OutlinedButton.icon(
                  onPressed: _isLoading ? null : _handleAnonymousLogin,
                  icon: const Icon(Icons.person_outline, color: AppColors.info),
                  label: const Text('Entrar como convidado'),
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    side: const BorderSide(color: AppColors.info),
                  ),
                ),
                const SizedBox(height: 12),
                
                // Botão de login anônimo
                ElevatedButton.icon(
                  onPressed: _isLoading ? null : _showAnonymousLoginDialog,
                  icon: const Icon(Icons.visibility_off_rounded),
                  label: const Text('Login Anônimo'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primaryColor,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    elevation: 4,
                    shadowColor: AppColors.primaryColor.withAlpha(77),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                ),
                
                const SizedBox(height: 24),
                
                // Informação sobre login anônimo
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: AppColors.info.withAlpha(26),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: AppColors.info.withAlpha(77)),
                  ),
                  child: const Row(
                    children: [
                      Icon(Icons.info_outline, color: AppColors.info, size: 20),
                      SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          'O login anônimo permite usar o app sem fornecer dados pessoais',
                          style: TextStyle(fontSize: 12),
                        ),
                      ),
                    ],
                  ),
                ),
                
                const SizedBox(height: 40),
              ],
            ),
          ),
        ),
      ),
    );
  }
}