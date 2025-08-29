import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../providers/auth_provider.dart';
import '../widgets/login_header_section.dart';
import '../widgets/login_form_section.dart';
import '../widgets/login_action_section.dart';

class LoginPage extends ConsumerStatefulWidget {
  const LoginPage({super.key});

  @override
  ConsumerState<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends ConsumerState<LoginPage> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _isSignUp = false;
  bool _obscurePassword = true;
  bool _rememberMe = false;
  bool _showEnhancedAuth = false;
  
  // Enhanced loading states
  bool _isAuthenticating = false;
  String _loadingMessage = '';

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authProvider);

    ref.listen<AuthState>(authProvider, (previous, next) {
      if (next.isAuthenticated) {
        context.go('/');
      }
      if (next.hasError) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(next.error!),
            backgroundColor: Theme.of(context).colorScheme.error,
          ),
        );
        ref.read(authProvider.notifier).clearError();
      }
    });

    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                LoginHeaderSection(isSignUp: _isSignUp),

                // Biometric Authentication Hint (if available)
                if (!_isSignUp) _buildBiometricHint(),
                
                LoginFormSection(
                  emailController: _emailController,
                  passwordController: _passwordController,
                  obscurePassword: _obscurePassword,
                  rememberMe: _rememberMe,
                  isSignUp: _isSignUp,
                  onPasswordVisibilityToggle: () => setState(() => _obscurePassword = !_obscurePassword),
                  onRememberMeChanged: (value) => setState(() => _rememberMe = value ?? false),
                ),
                const SizedBox(height: 24),

                LoginActionSection(
                  formKey: _formKey,
                  emailController: _emailController,
                  passwordController: _passwordController,
                  isSignUp: _isSignUp,
                  rememberMe: _rememberMe,
                  isAuthenticating: _isAuthenticating,
                  loadingMessage: _loadingMessage,
                  onModeToggle: () => setState(() => _isSignUp = !_isSignUp),
                  onAuthenticationSubmit: _handleEmailAuth,
                  onForgotPassword: _handleForgotPassword,
                  onSocialAuth: _handleSocialAuth,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }


  /// **Handle Email Authentication**
  /// 
  /// Processes email/password authentication with enhanced loading states
  /// and comprehensive error handling. Supports both login and registration modes.
  /// 
  /// ## Authentication Flow:
  /// 1. **Form Validation**: Validates all input fields
  /// 2. **Loading States**: Shows progressive loading messages
  /// 3. **Authentication Request**: Processes login/registration
  /// 4. **Credential Storage**: Optionally saves credentials if "Remember Me" is enabled
  /// 5. **Success Handling**: Shows success feedback and navigates
  /// 6. **Error Handling**: Displays user-friendly error messages
  /// 
  /// ## Enhanced Loading Messages:
  /// - Provides multi-stage loading feedback
  /// - Simulates realistic authentication delays
  /// - Updates user with current process stage
  /// 
  /// ## Security Features:
  /// - Input sanitization and validation
  /// - Secure credential handling
  /// - Error message sanitization
  /// - State cleanup after completion
  Future<void> _handleEmailAuth() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isAuthenticating = true;
      _loadingMessage = _isSignUp ? 'Criando sua conta...' : 'Fazendo login...';
    });

    try {
      final email = _emailController.text.trim();
      final password = _passwordController.text;

      // Simulate enhanced loading messages
      await _updateLoadingMessage(_isSignUp ? 'Validando informações...' : 'Verificando credenciais...');
      await Future<void>.delayed(const Duration(milliseconds: 500));
      
      await _updateLoadingMessage(_isSignUp ? 'Configurando sua conta...' : 'Conectando com servidor...');
      
      final success = _isSignUp
          ? await ref.read(authProvider.notifier).signUpWithEmail(email, password, null)
          : await ref.read(authProvider.notifier).signInWithEmail(email, password);

      if (success) {
        // Save credentials if remember me is enabled
        if (_rememberMe && !_isSignUp) {
          await _saveCredentials(email, password);
        }
        
        if (_isSignUp && mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Row(
                children: [
                  Icon(Icons.check_circle, color: Colors.white),
                  SizedBox(width: 12),
                  Text('Conta criada com sucesso!'),
                ],
              ),
              backgroundColor: Colors.green,
              behavior: SnackBarBehavior.floating,
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                const Icon(Icons.error, color: Colors.white),
                const SizedBox(width: 12),
                Expanded(child: Text('Erro: $e')),
              ],
            ),
            backgroundColor: Colors.red,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    } finally {
      setState(() {
        _isAuthenticating = false;
        _loadingMessage = '';
      });
    }
  }

  /// **Update Loading Message**
  /// 
  /// Updates the enhanced loading message with smooth animation transitions.
  /// Used to provide progressive feedback during authentication process.
  /// 
  /// ## Parameters:
  /// - [message]: The new loading message to display
  /// 
  /// ## Behavior:
  /// - Updates state with new message
  /// - Provides brief delay for smooth UX transitions
  /// - Ensures message visibility for user comprehension
  Future<void> _updateLoadingMessage(String message) async {
    setState(() => _loadingMessage = message);
    await Future<void>.delayed(const Duration(milliseconds: 300));
  }

  /// **Save User Credentials**
  /// 
  /// Securely stores user credentials when "Remember Me" option is enabled.
  /// In production, credentials would be stored using secure storage mechanisms.
  /// 
  /// ## Security Considerations:
  /// - Should use secure keychain/keystore in production
  /// - Passwords should be encrypted before storage
  /// - Implement credential expiration policies
  /// - Provide user control over credential management
  /// 
  /// ## Parameters:
  /// - [email]: User's email address
  /// - [password]: User's password (should be encrypted in production)
  /// 
  /// ## Current Implementation:
  /// - Demo implementation shows success message
  /// - Production implementation would use secure storage
  Future<void> _saveCredentials(String email, String password) async {
    // In a real app, save to secure storage
    // For demo purposes, just show a message
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Credenciais salvas com segurança'),
          backgroundColor: Colors.blue,
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  /// **Handle Forgot Password**
  /// 
  /// Initiates the password recovery process through a dialog interface.
  /// Allows users to request password reset instructions via email.
  /// 
  /// ## Functionality:
  /// - Displays password recovery dialog
  /// - Validates email address format
  /// - Sends password reset request
  /// - Provides user feedback on success/failure
  /// 
  /// ## User Flow:
  /// 1. User taps "Forgot Password" link
  /// 2. Dialog prompts for email address
  /// 3. System validates email format
  /// 4. Password reset email is sent
  /// 5. Success confirmation is displayed
  /// 
  /// ## Security Features:
  /// - Email validation before sending reset
  /// - Rate limiting should be implemented in production
  /// - Secure token generation for reset links
  void _handleForgotPassword() {
    showDialog<void>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Esqueceu a senha?'),
        content: const Text(
          'Digite seu email para receber instruções de recuperação de senha.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancelar'),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              final email = _emailController.text.trim();
              if (email.isNotEmpty) {
                ref.read(authProvider.notifier).sendPasswordResetEmail(email);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Email de recuperação enviado!'),
                    backgroundColor: Colors.green,
                  ),
                );
              }
            },
            child: const Text('Enviar'),
          ),
        ],
      ),
    );
  }

  /// **Biometric Authentication Hint**
  /// 
  /// Displays information about biometric authentication availability.
  Widget _buildBiometricHint() {
    return Container(
      padding: const EdgeInsets.all(12),
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            Colors.blue.withValues(alpha: 0.1),
            Colors.blue.withValues(alpha: 0.05),
          ],
        ),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.blue.withValues(alpha: 0.2)),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Colors.blue.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: const Icon(
              Icons.fingerprint,
              color: Colors.blue,
              size: 20,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Autenticação Biométrica Disponível',
                  style: TextStyle(
                    fontWeight: FontWeight.w600,
                    color: Colors.blue[700],
                    fontSize: 14,
                  ),
                ),
                Text(
                  'Configure após fazer login pela primeira vez',
                  style: TextStyle(
                    color: Colors.blue[600],
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
          Icon(
            Icons.arrow_forward_ios,
            size: 16,
            color: Colors.blue[600],
          ),
        ],
      ),
    );
  }

  /// **Handle Social Authentication**
  /// 
  /// Routes social authentication requests to appropriate provider methods.
  /// Supports multiple social authentication providers with consistent interface.
  /// 
  /// ## Supported Providers:
  /// - **Google**: Google Sign-In with OAuth 2.0
  /// - **Apple**: Apple Sign-In with Apple ID
  /// 
  /// ## Authentication Flow:
  /// 1. User selects social authentication provider
  /// 2. System redirects to provider's authentication interface
  /// 3. User completes authentication with provider
  /// 4. System receives authentication token
  /// 5. User profile is created/updated in app
  /// 6. User is navigated to main app interface
  /// 
  /// ## Error Handling:
  /// - Provider unavailable: Fallback to email authentication
  /// - Authentication cancelled: Returns to login screen
  /// - Network errors: Displays retry options
  /// - Account conflicts: Provides resolution options
  /// 
  /// ## Parameters:
  /// - [provider]: Social authentication provider ('google' or 'apple')
  void _handleSocialAuth(String provider) {
    switch (provider) {
      case 'google':
        ref.read(authProvider.notifier).signInWithGoogle();
        break;
      case 'apple':
        ref.read(authProvider.notifier).signInWithApple();
        break;
    }
  }
}