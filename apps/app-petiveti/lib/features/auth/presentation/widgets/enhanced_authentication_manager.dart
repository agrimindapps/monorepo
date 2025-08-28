import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../providers/auth_provider.dart';

/// Enhanced authentication manager with biometric support and remember me
class EnhancedAuthenticationManager extends ConsumerStatefulWidget {
  final VoidCallback? onAuthenticationSuccess;
  final ValueChanged<String>? onAuthenticationError;

  const EnhancedAuthenticationManager({
    super.key,
    this.onAuthenticationSuccess,
    this.onAuthenticationError,
  });

  @override
  ConsumerState<EnhancedAuthenticationManager> createState() => _EnhancedAuthenticationManagerState();
}

class _EnhancedAuthenticationManagerState extends ConsumerState<EnhancedAuthenticationManager>
    with TickerProviderStateMixin {
  
  // Animation controllers
  late AnimationController _fadeController;
  late AnimationController _scaleController;
  late AnimationController _slideController;
  
  // Animations
  late Animation<double> _fadeAnimation;
  late Animation<double> _scaleAnimation;
  late Animation<Offset> _slideAnimation;
  
  // Biometric authentication state
  bool _biometricsAvailable = false;
  bool _biometricsEnabled = false;
  String _biometricType = '';
  
  // Remember me functionality
  bool _rememberMe = false;
  bool _hasStoredCredentials = false;
  
  // Loading states
  bool _isBiometricLoading = false;
  bool _isCheckingStoredAuth = true;
  
  @override
  void initState() {
    super.initState();
    _initializeAnimations();
    _checkBiometricAvailability();
    _checkStoredAuthentication();
  }

  void _initializeAnimations() {
    _fadeController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    
    _scaleController = AnimationController(
      duration: const Duration(milliseconds: 400),
      vsync: this,
    );
    
    _slideController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );
    
    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _fadeController,
      curve: Curves.easeInOut,
    ));
    
    _scaleAnimation = Tween<double>(
      begin: 0.8,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _scaleController,
      curve: Curves.elasticOut,
    ));
    
    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.3),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _slideController,
      curve: Curves.easeOutCubic,
    ));
    
    // Start animations
    _fadeController.forward();
    _scaleController.forward();
    _slideController.forward();
  }

  @override
  void dispose() {
    _fadeController.dispose();
    _scaleController.dispose();
    _slideController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final authState = ref.watch(authProvider);

    if (_isCheckingStoredAuth) {
      return _buildCheckingStoredAuthState(theme);
    }

    return AnimatedBuilder(
      animation: Listenable.merge([_fadeAnimation, _scaleAnimation, _slideAnimation]),
      builder: (context, child) {
        return FadeTransition(
          opacity: _fadeAnimation,
          child: ScaleTransition(
            scale: _scaleAnimation,
            child: SlideTransition(
              position: _slideAnimation,
              child: Card(
                elevation: 8,
                margin: const EdgeInsets.all(16),
                child: Padding(
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      _buildAuthenticationHeader(theme),
                      const SizedBox(height: 24),
                      
                      if (_biometricsAvailable && _hasStoredCredentials)
                        _buildBiometricAuthSection(theme, authState),
                      
                      if (_hasStoredCredentials && !authState.isLoading)
                        _buildStoredAuthSection(theme),
                      
                      _buildRememberMeSection(theme),
                      
                      const SizedBox(height: 16),
                      _buildAuthenticationOptions(theme, authState),
                    ],
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildCheckingStoredAuthState(ThemeData theme) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              color: theme.colorScheme.primary.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(40),
            ),
            child: const Center(
              child: CircularProgressIndicator(),
            ),
          ),
          const SizedBox(height: 24),
          Text(
            'Verificando autenticação salva...',
            style: theme.textTheme.titleMedium?.copyWith(
              color: Colors.grey[600],
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Isso pode levar alguns segundos',
            style: theme.textTheme.bodySmall?.copyWith(
              color: Colors.grey[500],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAuthenticationHeader(ThemeData theme) {
    return Column(
      children: [
        Container(
          width: 60,
          height: 60,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                theme.colorScheme.primary,
                theme.colorScheme.primary.withValues(alpha: 0.7),
              ],
            ),
            borderRadius: BorderRadius.circular(30),
          ),
          child: const Icon(
            Icons.security,
            color: Colors.white,
            size: 32,
          ),
        ),
        const SizedBox(height: 16),
        Text(
          'Autenticação Segura',
          style: theme.textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          'Escolha seu método preferido de autenticação',
          style: theme.textTheme.bodyMedium?.copyWith(
            color: Colors.grey[600],
          ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  Widget _buildBiometricAuthSection(ThemeData theme, AuthState authState) {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(bottom: 16),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  Colors.green.withValues(alpha: 0.1),
                  Colors.green.withValues(alpha: 0.05),
                ],
              ),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: Colors.green.withValues(alpha: 0.3),
              ),
            ),
            child: Column(
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: Colors.green.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Icon(
                        _getBiometricIcon(),
                        color: Colors.green,
                        size: 24,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Autenticação $_biometricType',
                            style: theme.textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.w600,
                              color: Colors.green[700],
                            ),
                          ),
                          Text(
                            'Acesso rápido e seguro',
                            style: theme.textTheme.bodySmall?.copyWith(
                              color: Colors.green[600],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                SizedBox(
                  width: double.infinity,
                  child: FilledButton.icon(
                    onPressed: _isBiometricLoading ? null : _authenticateWithBiometrics,
                    style: FilledButton.styleFrom(
                      backgroundColor: Colors.green,
                      padding: const EdgeInsets.symmetric(vertical: 12),
                    ),
                    icon: _isBiometricLoading
                        ? const SizedBox(
                            width: 16,
                            height: 16,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              valueColor: AlwaysStoppedAnimation(Colors.white),
                            ),
                          )
                        : Icon(_getBiometricIcon()),
                    label: Text(
                      _isBiometricLoading 
                          ? 'Autenticando...' 
                          : 'Usar $_biometricType',
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              const Expanded(child: Divider()),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Text(
                  'ou',
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: Colors.grey[500],
                  ),
                ),
              ),
              const Expanded(child: Divider()),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStoredAuthSection(ThemeData theme) {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.blue.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: Colors.blue.withValues(alpha: 0.2),
        ),
      ),
      child: Row(
        children: [
          Icon(
            Icons.account_circle,
            color: Colors.blue[600],
            size: 24,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Conta Salva',
                  style: theme.textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.w600,
                    color: Colors.blue[700],
                  ),
                ),
                Text(
                  'Suas credenciais estão salvas com segurança',
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: Colors.blue[600],
                  ),
                ),
              ],
            ),
          ),
          TextButton(
            onPressed: _clearStoredCredentials,
            child: const Text('Limpar'),
          ),
        ],
      ),
    );
  }

  Widget _buildRememberMeSection(ThemeData theme) {
    return SwitchListTile(
      contentPadding: EdgeInsets.zero,
      title: const Text('Lembrar de mim'),
      subtitle: const Text('Salvar credenciais para próximo acesso'),
      value: _rememberMe,
      onChanged: (value) {
        setState(() => _rememberMe = value);
      },
      secondary: Icon(
        Icons.remember_me,
        color: theme.colorScheme.primary,
      ),
    );
  }

  Widget _buildAuthenticationOptions(ThemeData theme, AuthState authState) {
    return Column(
      children: [
        if (authState.isLoading)
          _buildAdvancedLoadingIndicator(theme, authState),
        
        if (!authState.isLoading) ...[
          SizedBox(
            width: double.infinity,
            child: FilledButton.icon(
              onPressed: _authenticateWithStoredCredentials,
              icon: const Icon(Icons.login),
              label: const Text('Continuar com Conta Salva'),
              style: FilledButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 12),
              ),
            ),
          ),
          const SizedBox(height: 12),
          SizedBox(
            width: double.infinity,
            child: OutlinedButton.icon(
              onPressed: _showFullLoginForm,
              icon: const Icon(Icons.email),
              label: const Text('Usar Email e Senha'),
              style: OutlinedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 12),
              ),
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildAdvancedLoadingIndicator(ThemeData theme, AuthState authState) {
    return Container(
      padding: const EdgeInsets.all(20),
      child: Column(
        children: [
          Stack(
            alignment: Alignment.center,
            children: [
              CircularProgressIndicator(
                strokeWidth: 3,
                valueColor: AlwaysStoppedAnimation(theme.colorScheme.primary),
              ),
              Icon(
                Icons.security,
                color: theme.colorScheme.primary,
                size: 24,
              ),
            ],
          ),
          const SizedBox(height: 16),
          Text(
            _getLoadingMessage(),
            style: theme.textTheme.titleSmall?.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Verificando suas credenciais...',
            style: theme.textTheme.bodySmall?.copyWith(
              color: Colors.grey[600],
            ),
          ),
        ],
      ),
    );
  }

  // Helper Methods
  Future<void> _checkBiometricAvailability() async {
    try {
      // Simulate biometric check - in real implementation, use local_auth package
      await Future<void>.delayed(const Duration(milliseconds: 500));
      
      setState(() {
        _biometricsAvailable = true;
        _biometricsEnabled = true;
        _biometricType = 'Biométrica'; // Could be 'Face ID', 'Touch ID', 'Fingerprint'
      });
    } catch (e) {
      setState(() {
        _biometricsAvailable = false;
        _biometricsEnabled = false;
      });
    }
  }

  Future<void> _checkStoredAuthentication() async {
    try {
      // Simulate checking stored credentials
      await Future<void>.delayed(const Duration(seconds: 1));
      
      setState(() {
        _hasStoredCredentials = true; // Simulate having stored credentials
        _rememberMe = true;
        _isCheckingStoredAuth = false;
      });
      
      // If biometric is enabled and available, show biometric option
      if (_biometricsAvailable && _biometricsEnabled) {
        _showBiometricPrompt();
      }
    } catch (e) {
      setState(() {
        _hasStoredCredentials = false;
        _isCheckingStoredAuth = false;
      });
    }
  }

  Future<void> _authenticateWithBiometrics() async {
    setState(() => _isBiometricLoading = true);
    
    try {
      // Simulate biometric authentication
      await Future<void>.delayed(const Duration(seconds: 2));
      
      await HapticFeedback.lightImpact();
      
      // Simulate successful authentication
      final success = await ref.read(authProvider.notifier).signInWithEmail('stored@example.com', 'stored_password');
      
      if (success) {
        widget.onAuthenticationSuccess?.call();
        _showSuccessAnimation();
      } else {
        throw Exception('Autenticação biométrica falhou');
      }
    } catch (e) {
      widget.onAuthenticationError?.call('Erro na autenticação biométrica: $e');
      HapticFeedback.heavyImpact();
    } finally {
      setState(() => _isBiometricLoading = false);
    }
  }

  Future<void> _authenticateWithStoredCredentials() async {
    try {
      final success = await ref.read(authProvider.notifier).signInWithEmail('stored@example.com', 'stored_password');
      
      if (success) {
        widget.onAuthenticationSuccess?.call();
        _showSuccessAnimation();
      } else {
        throw Exception('Credenciais armazenadas inválidas');
      }
    } catch (e) {
      widget.onAuthenticationError?.call('Erro ao usar credenciais salvas: $e');
    }
  }

  void _clearStoredCredentials() {
    showDialog<void>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Limpar Credenciais'),
        content: const Text(
          'Isso removerá todas as informações de login salvas. Você precisará inserir suas credenciais novamente.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancelar'),
          ),
          FilledButton(
            onPressed: () {
              Navigator.pop(context);
              // Simulate clearing stored credentials
              setState(() {
                _hasStoredCredentials = false;
                _rememberMe = false;
                _biometricsEnabled = false;
              });
              
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Credenciais removidas com sucesso'),
                  backgroundColor: Colors.orange,
                ),
              );
            },
            style: FilledButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Limpar'),
          ),
        ],
      ),
    );
  }

  void _showBiometricPrompt() {
    if (!mounted) return;
    
    showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        icon: Icon(
          _getBiometricIcon(),
          size: 48,
          color: Colors.green,
        ),
        title: const Text('Autenticação Disponível'),
        content: Text(
          'Você pode usar $_biometricType para acessar sua conta de forma rápida e segura.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Agora Não'),
          ),
          FilledButton(
            onPressed: () {
              Navigator.pop(context);
              _authenticateWithBiometrics();
            },
            child: Text('Usar $_biometricType'),
          ),
        ],
      ),
    );
  }

  void _showFullLoginForm() {
    // Navigate to full login form
    Navigator.pop(context);
  }

  void _showSuccessAnimation() {
    HapticFeedback.mediumImpact();
    
    // Show success feedback
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Row(
          children: [
            Icon(Icons.check_circle, color: Colors.white),
            SizedBox(width: 12),
            Text('Autenticação realizada com sucesso!'),
          ],
        ),
        backgroundColor: Colors.green,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
      ),
    );
  }

  IconData _getBiometricIcon() {
    switch (_biometricType.toLowerCase()) {
      case 'face id':
        return Icons.face;
      case 'touch id':
      case 'fingerprint':
        return Icons.fingerprint;
      default:
        return Icons.security;
    }
  }

  String _getLoadingMessage() {
    final messages = [
      'Verificando credenciais...',
      'Conectando com servidor...',
      'Validando acesso...',
      'Preparando sua conta...',
    ];
    
    return messages[DateTime.now().second % messages.length];
  }
}