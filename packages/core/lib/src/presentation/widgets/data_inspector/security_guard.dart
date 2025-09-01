import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import '../../theme/data_inspector_theme.dart';

/// Security guard widget that prevents access to data inspector in production builds
/// Inspired by app-plantis implementation with enhanced visual design
class SecurityGuard extends StatelessWidget {
  /// Child widget to protect (typically DataInspectorPage)
  final Widget child;
  
  /// Override to allow access even in release builds (use with caution)
  final bool forceAllow;
  
  /// Custom theme for the security screen
  final DataInspectorTheme? theme;
  
  /// App name for customized messaging
  final String? appName;

  const SecurityGuard({
    super.key,
    required this.child,
    this.forceAllow = false,
    this.theme,
    this.appName,
  });

  @override
  Widget build(BuildContext context) {
    // Allow access in debug mode or when forced
    if (kDebugMode || forceAllow) {
      return child;
    }

    // Block access in release builds with dramatic UI
    return _buildSecurityBlockScreen(context);
  }

  Widget _buildSecurityBlockScreen(BuildContext context) {
    final inspectorTheme = theme ?? DataInspectorTheme.developer(
      primaryColor: Colors.red,
      accentColor: Colors.redAccent,
    );
    
    final app = appName ?? 'App';

    return Theme(
      data: inspectorTheme.themeData,
      child: Scaffold(
        backgroundColor: Colors.black,
        body: Container(
          decoration: BoxDecoration(
            gradient: RadialGradient(
              center: Alignment.center,
              radius: 1.5,
              colors: [
                Colors.red.withValues(alpha: 0.1),
                Colors.black,
                Colors.black,
              ],
            ),
          ),
          child: SafeArea(
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // Dramatic icon animation
                  TweenAnimationBuilder<double>(
                    tween: Tween(begin: 0.0, end: 1.0),
                    duration: const Duration(milliseconds: 1000),
                    builder: (context, value, child) {
                      return Transform.scale(
                        scale: 0.8 + (0.2 * value),
                        child: Container(
                          padding: const EdgeInsets.all(24),
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            border: Border.all(
                              color: Colors.red.withValues(alpha: 0.3),
                              width: 2,
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.red.withValues(alpha: 0.3),
                                blurRadius: 20,
                                spreadRadius: 2,
                              ),
                            ],
                          ),
                          child: Icon(
                            Icons.security,
                            size: 80,
                            color: Colors.red.withValues(alpha: 0.8),
                          ),
                        ),
                      );
                    },
                  ),
                  
                  const SizedBox(height: 32),
                  
                  // Primary message
                  TweenAnimationBuilder<double>(
                    tween: Tween(begin: 0.0, end: 1.0),
                    duration: const Duration(milliseconds: 1500),
                    builder: (context, value, child) {
                      return Opacity(
                        opacity: value,
                        child: Text(
                          'ACESSO NEGADO',
                          style: TextStyle(
                            fontSize: 28,
                            fontWeight: FontWeight.bold,
                            color: Colors.red.withValues(alpha: 0.9),
                            letterSpacing: 2,
                            shadows: [
                              Shadow(
                                color: Colors.red.withValues(alpha: 0.5),
                                blurRadius: 10,
                              ),
                            ],
                          ),
                          textAlign: TextAlign.center,
                        ),
                      );
                    },
                  ),
                  
                  const SizedBox(height: 16),
                  
                  // Subtitle
                  TweenAnimationBuilder<double>(
                    tween: Tween(begin: 0.0, end: 1.0),
                    duration: const Duration(milliseconds: 2000),
                    builder: (context, value, child) {
                      return Opacity(
                        opacity: value,
                        child: Text(
                          'INSPETOR DE DADOS',
                          style: TextStyle(
                            fontSize: 16,
                            color: Colors.white.withValues(alpha: 0.7),
                            letterSpacing: 1,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      );
                    },
                  ),
                  
                  const SizedBox(height: 48),
                  
                  // Security message
                  TweenAnimationBuilder<double>(
                    tween: Tween(begin: 0.0, end: 1.0),
                    duration: const Duration(milliseconds: 2500),
                    builder: (context, value, child) {
                      return Opacity(
                        opacity: value,
                        child: Container(
                          margin: const EdgeInsets.symmetric(horizontal: 32),
                          padding: const EdgeInsets.all(20),
                          decoration: BoxDecoration(
                            border: Border.all(
                              color: Colors.red.withValues(alpha: 0.3),
                              width: 1,
                            ),
                            borderRadius: BorderRadius.circular(12),
                            color: Colors.red.withValues(alpha: 0.05),
                          ),
                          child: Column(
                            children: [
                              Icon(
                                Icons.warning,
                                color: Colors.orange.withValues(alpha: 0.8),
                                size: 32,
                              ),
                              const SizedBox(height: 16),
                              Text(
                                'Esta ferramenta contém dados sensíveis e só está disponível em builds de desenvolvimento.',
                                style: TextStyle(
                                  fontSize: 14,
                                  color: Colors.white.withValues(alpha: 0.8),
                                  height: 1.4,
                                ),
                                textAlign: TextAlign.center,
                              ),
                              const SizedBox(height: 12),
                              Text(
                                'Para acessar o inspetor de dados, execute o $app em modo debug.',
                                style: TextStyle(
                                  fontSize: 12,
                                  color: Colors.white.withValues(alpha: 0.6),
                                  height: 1.3,
                                ),
                                textAlign: TextAlign.center,
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                  
                  const SizedBox(height: 48),
                  
                  // Back button
                  TweenAnimationBuilder<double>(
                    tween: Tween(begin: 0.0, end: 1.0),
                    duration: const Duration(milliseconds: 3000),
                    builder: (context, value, child) {
                      return Opacity(
                        opacity: value,
                        child: ElevatedButton.icon(
                          onPressed: () => Navigator.of(context).pop(),
                          icon: const Icon(Icons.arrow_back),
                          label: const Text('VOLTAR'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.grey.shade800,
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(
                              horizontal: 24,
                              vertical: 12,
                            ),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                  
                  const SizedBox(height: 32),
                  
                  // Debug info
                  if (kDebugMode)
                    TweenAnimationBuilder<double>(
                      tween: Tween(begin: 0.0, end: 1.0),
                      duration: const Duration(milliseconds: 3500),
                      builder: (context, value, child) {
                        return Opacity(
                          opacity: value,
                          child: Container(
                            margin: const EdgeInsets.symmetric(horizontal: 32),
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: Colors.green.withValues(alpha: 0.1),
                              border: Border.all(
                                color: Colors.green.withValues(alpha: 0.3),
                                width: 1,
                              ),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(
                                  Icons.bug_report,
                                  color: Colors.green.withValues(alpha: 0.8),
                                  size: 16,
                                ),
                                const SizedBox(width: 8),
                                Text(
                                  'DEBUG MODE ATIVO',
                                  style: TextStyle(
                                    fontSize: 10,
                                    color: Colors.green.withValues(alpha: 0.8),
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// Development-only access widget that shows a warning but allows access
/// Useful for development builds where you want access but still show a warning
class DevelopmentAccessGuard extends StatefulWidget {
  final Widget child;
  final DataInspectorTheme? theme;
  final String? appName;
  
  const DevelopmentAccessGuard({
    super.key,
    required this.child,
    this.theme,
    this.appName,
  });

  @override
  State<DevelopmentAccessGuard> createState() => _DevelopmentAccessGuardState();
}

class _DevelopmentAccessGuardState extends State<DevelopmentAccessGuard> {
  bool _warningDismissed = false;

  @override
  Widget build(BuildContext context) {
    if (_warningDismissed || !kDebugMode) {
      return widget.child;
    }

    return _buildWarningScreen();
  }

  Widget _buildWarningScreen() {
    final inspectorTheme = widget.theme ?? DataInspectorTheme.developer(
      primaryColor: Colors.orange,
      accentColor: Colors.orangeAccent,
    );
    
    final app = widget.appName ?? 'App';

    return Theme(
      data: inspectorTheme.themeData,
      child: Scaffold(
        backgroundColor: Colors.black,
        body: Container(
          decoration: BoxDecoration(
            gradient: RadialGradient(
              center: Alignment.center,
              radius: 1.5,
              colors: [
                Colors.orange.withValues(alpha: 0.1),
                Colors.black,
                Colors.black,
              ],
            ),
          ),
          child: SafeArea(
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.developer_mode,
                    size: 64,
                    color: Colors.orange.withValues(alpha: 0.8),
                  ),
                  
                  const SizedBox(height: 24),
                  
                  Text(
                    'MODO DESENVOLVEDOR',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Colors.orange.withValues(alpha: 0.9),
                      letterSpacing: 1,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  
                  const SizedBox(height: 32),
                  
                  Container(
                    margin: const EdgeInsets.symmetric(horizontal: 32),
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      border: Border.all(
                        color: Colors.orange.withValues(alpha: 0.3),
                        width: 1,
                      ),
                      borderRadius: BorderRadius.circular(12),
                      color: Colors.orange.withValues(alpha: 0.05),
                    ),
                    child: Column(
                      children: [
                        Icon(
                          Icons.info,
                          color: Colors.blue.withValues(alpha: 0.8),
                          size: 32,
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'Você está prestes a acessar o Inspetor de Dados do $app.',
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.white.withValues(alpha: 0.8),
                            height: 1.4,
                          ),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 12),
                        Text(
                          'Esta ferramenta permite visualizar e modificar dados locais. Use com cuidado.',
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.white.withValues(alpha: 0.6),
                            height: 1.3,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  ),
                  
                  const SizedBox(height: 32),
                  
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      ElevatedButton.icon(
                        onPressed: () => Navigator.of(context).pop(),
                        icon: const Icon(Icons.arrow_back),
                        label: const Text('CANCELAR'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.grey.shade800,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(
                            horizontal: 20,
                            vertical: 12,
                          ),
                        ),
                      ),
                      
                      const SizedBox(width: 16),
                      
                      ElevatedButton.icon(
                        onPressed: () {
                          setState(() {
                            _warningDismissed = true;
                          });
                        },
                        icon: const Icon(Icons.arrow_forward),
                        label: const Text('CONTINUAR'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.orange,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(
                            horizontal: 20,
                            vertical: 12,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}