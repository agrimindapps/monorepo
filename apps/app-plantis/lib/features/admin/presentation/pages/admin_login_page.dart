import 'package:core/core.dart' hide FormState;
import 'package:flutter/material.dart';

/// Página de login administrativo do CantinhoVerde
/// 
/// Autenticação via Firebase com validação de email admin
class AdminLoginPage extends ConsumerStatefulWidget {
  const AdminLoginPage({super.key});

  @override
  ConsumerState<AdminLoginPage> createState() => _AdminLoginPageState();
}

class _AdminLoginPageState extends ConsumerState<AdminLoginPage> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _isLoading = false;
  bool _obscurePassword = true;
  String? _errorMessage;

  // Plantis theme colors
  static const _primaryColor = Color(0xFF4CAF50);
  static const _accentColor = Color(0xFF2E7D32);

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final screenSize = MediaQuery.of(context).size;
    final isMobile = screenSize.width < 600;

    return Scaffold(
      backgroundColor: isDark ? const Color(0xFF0D0D1E) : Colors.grey[50],
      body: Center(
        child: SingleChildScrollView(
          padding: EdgeInsets.all(isMobile ? 24 : 48),
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 440),
            child: Card(
              elevation: isDark ? 0 : 2,
              color: isDark ? const Color(0xFF1A1A2E) : Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
                side: isDark
                    ? BorderSide(color: Colors.white.withOpacity(0.1))
                    : BorderSide.none,
              ),
              child: Padding(
                padding: EdgeInsets.all(isMobile ? 24 : 40),
                child: Form(
                  key: _formKey,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      // Logo e título
                      _buildHeader(),
                      const SizedBox(height: 40),

                      // Email field
                      _buildEmailField(isDark),
                      const SizedBox(height: 20),

                      // Password field
                      _buildPasswordField(isDark),
                      const SizedBox(height: 12),

                      // Error message
                      if (_errorMessage != null) ...[
                        _buildErrorMessage(isDark),
                        const SizedBox(height: 16),
                      ],

                      const SizedBox(height: 8),

                      // Login button
                      _buildLoginButton(),

                      const SizedBox(height: 24),

                      // Info text
                      _buildInfoText(isDark),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Column(
      children: [
        // Logo
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: _primaryColor.withOpacity(0.1),
            shape: BoxShape.circle,
          ),
          child: const Icon(
            Icons.eco,
            size: 48,
            color: _primaryColor,
          ),
        ),
        const SizedBox(height: 20),

        // Title
        const Text(
          'CantinhoVerde',
          style: TextStyle(
            fontSize: 28,
            fontWeight: FontWeight.bold,
          ),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 8),

        // Subtitle
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
          decoration: BoxDecoration(
            color: _accentColor.withOpacity(0.1),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: _accentColor.withOpacity(0.3),
            ),
          ),
          child: const Text(
            'ADMIN PANEL',
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              letterSpacing: 1.5,
              color: _accentColor,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildEmailField(bool isDark) {
    return TextFormField(
      controller: _emailController,
      keyboardType: TextInputType.emailAddress,
      autofillHints: const [AutofillHints.email],
      enabled: !_isLoading,
      decoration: InputDecoration(
        labelText: 'Email',
        hintText: 'admin@example.com',
        prefixIcon: const Icon(Icons.email_outlined),
        filled: true,
        fillColor: isDark ? Colors.white.withOpacity(0.05) : Colors.grey[100],
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(
            color: isDark ? Colors.white.withOpacity(0.1) : Colors.grey[300]!,
          ),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: _primaryColor, width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.red[400]!),
        ),
      ),
      validator: (value) {
        if (value == null || value.trim().isEmpty) {
          return 'Email é obrigatório';
        }
        if (!value.contains('@')) {
          return 'Email inválido';
        }
        return null;
      },
    );
  }

  Widget _buildPasswordField(bool isDark) {
    return TextFormField(
      controller: _passwordController,
      obscureText: _obscurePassword,
      autofillHints: const [AutofillHints.password],
      enabled: !_isLoading,
      decoration: InputDecoration(
        labelText: 'Senha',
        hintText: '••••••••',
        prefixIcon: const Icon(Icons.lock_outline),
        suffixIcon: IconButton(
          icon: Icon(
            _obscurePassword ? Icons.visibility_outlined : Icons.visibility_off_outlined,
          ),
          onPressed: () {
            setState(() => _obscurePassword = !_obscurePassword);
          },
        ),
        filled: true,
        fillColor: isDark ? Colors.white.withOpacity(0.05) : Colors.grey[100],
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(
            color: isDark ? Colors.white.withOpacity(0.1) : Colors.grey[300]!,
          ),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: _primaryColor, width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.red[400]!),
        ),
      ),
      validator: (value) {
        if (value == null || value.isEmpty) {
          return 'Senha é obrigatória';
        }
        if (value.length < 6) {
          return 'Senha deve ter no mínimo 6 caracteres';
        }
        return null;
      },
      onFieldSubmitted: (_) => _handleLogin(),
    );
  }

  Widget _buildErrorMessage(bool isDark) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.red.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: Colors.red.withOpacity(0.3),
        ),
      ),
      child: Row(
        children: [
          Icon(
            Icons.error_outline,
            color: Colors.red[400],
            size: 20,
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              _errorMessage!,
              style: TextStyle(
                color: Colors.red[400],
                fontSize: 13,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLoginButton() {
    return SizedBox(
      height: 52,
      child: ElevatedButton(
        onPressed: _isLoading ? null : _handleLogin,
        style: ElevatedButton.styleFrom(
          backgroundColor: _primaryColor,
          foregroundColor: Colors.white,
          disabledBackgroundColor: _primaryColor.withOpacity(0.5),
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
        child: _isLoading
            ? const SizedBox(
                height: 20,
                width: 20,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                ),
              )
            : const Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.login, size: 20),
                  SizedBox(width: 8),
                  Text(
                    'Entrar',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
      ),
    );
  }

  Widget _buildInfoText(bool isDark) {
    return Text(
      'Acesso restrito apenas para administradores',
      style: TextStyle(
        fontSize: 12,
        color: isDark ? Colors.white54 : Colors.grey[600],
      ),
      textAlign: TextAlign.center,
    );
  }

  Future<void> _handleLogin() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: _emailController.text.trim(),
        password: _passwordController.text,
      );

      if (mounted) {
        context.go('/admin/dashboard');
      }
    } on FirebaseAuthException catch (e) {
      String message;
      switch (e.code) {
        case 'user-not-found':
          message = 'Usuário não encontrado';
          break;
        case 'wrong-password':
          message = 'Senha incorreta';
          break;
        case 'invalid-email':
          message = 'Email inválido';
          break;
        case 'user-disabled':
          message = 'Usuário desabilitado';
          break;
        case 'too-many-requests':
          message = 'Muitas tentativas. Tente novamente mais tarde';
          break;
        case 'invalid-credential':
          message = 'Credenciais inválidas';
          break;
        default:
          message = 'Erro ao fazer login: ${e.message}';
      }

      setState(() {
        _errorMessage = message;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _errorMessage = 'Erro inesperado: $e';
        _isLoading = false;
      });
    }
  }
}
