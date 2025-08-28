import 'package:flutter/material.dart';
import '../theme/colors.dart';

/// Enhanced loading overlay with contextual messages and accessibility support
class LoadingOverlay extends StatelessWidget {
  final Widget child;
  final bool isLoading;
  final String? message;
  final String? semanticLabel;
  final bool preventInteraction;
  final Color? overlayColor;
  final double opacity;

  const LoadingOverlay({
    super.key,
    required this.child,
    this.isLoading = false,
    this.message,
    this.semanticLabel,
    this.preventInteraction = true,
    this.overlayColor,
    this.opacity = 0.3,
  });

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        child,
        if (isLoading)
          Positioned.fill(
            child: Container(
              color: (overlayColor ?? Colors.black).withValues(alpha: opacity),
              child: preventInteraction
                  ? AbsorbPointer(
                      child: _buildLoadingContent(context),
                    )
                  : _buildLoadingContent(context),
            ),
          ),
      ],
    );
  }

  Widget _buildLoadingContent(BuildContext context) {
    return Center(
      child: Semantics(
        label: semanticLabel ?? message ?? 'Carregando',
        child: Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.2),
                blurRadius: 10,
                offset: const Offset(0, 5),
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const SizedBox(
                width: 32,
                height: 32,
                child: CircularProgressIndicator(
                  strokeWidth: 3,
                  valueColor: AlwaysStoppedAnimation<Color>(
                    PlantisColors.primary,
                  ),
                ),
              ),
              if (message != null) ...[
                const SizedBox(height: 16),
                Text(
                  message!,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: PlantisColors.textPrimary,
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

/// Specific loading overlay for authentication operations
class AuthLoadingOverlay extends StatelessWidget {
  final Widget child;
  final bool isLoading;
  final AuthOperation? currentOperation;

  const AuthLoadingOverlay({
    super.key,
    required this.child,
    this.isLoading = false,
    this.currentOperation,
  });

  @override
  Widget build(BuildContext context) {
    return LoadingOverlay(
      isLoading: isLoading,
      message: _getLoadingMessage(currentOperation),
      semanticLabel: _getSemanticLabel(currentOperation),
      child: child,
    );
  }

  String _getLoadingMessage(AuthOperation? operation) {
    if (operation == null) return 'Processando...';
    
    switch (operation) {
      case AuthOperation.signIn:
        return 'Fazendo login...';
      case AuthOperation.signUp:
        return 'Criando conta...';
      case AuthOperation.anonymous:
        return 'Entrando anonimamente...';
      case AuthOperation.logout:
        return 'Saindo...';
      case AuthOperation.passwordReset:
        return 'Enviando email...';
      default:
        return 'Processando...';
    }
  }

  String _getSemanticLabel(AuthOperation? operation) {
    if (operation == null) return 'Processando operação de autenticação';
    
    switch (operation) {
      case AuthOperation.signIn:
        return 'Fazendo login na sua conta';
      case AuthOperation.signUp:
        return 'Criando nova conta de usuário';
      case AuthOperation.anonymous:
        return 'Entrando no modo anônimo';
      case AuthOperation.logout:
        return 'Fazendo logout da conta';
      case AuthOperation.passwordReset:
        return 'Enviando email de recuperação de senha';
      default:
        return 'Processando operação de autenticação';
    }
  }
}

/// Specific loading overlay for purchase operations
class PurchaseLoadingOverlay extends StatelessWidget {
  final Widget child;
  final bool isLoading;
  final PurchaseOperation? currentOperation;

  const PurchaseLoadingOverlay({
    super.key,
    required this.child,
    this.isLoading = false,
    this.currentOperation,
  });

  @override
  Widget build(BuildContext context) {
    return LoadingOverlay(
      isLoading: isLoading,
      message: _getLoadingMessage(currentOperation),
      semanticLabel: _getSemanticLabel(currentOperation),
      child: child,
    );
  }

  String _getLoadingMessage(PurchaseOperation? operation) {
    if (operation == null) return 'Processando...';
    
    switch (operation) {
      case PurchaseOperation.purchase:
        return 'Processando compra...';
      case PurchaseOperation.restore:
        return 'Restaurando compras...';
      case PurchaseOperation.loadProducts:
        return 'Carregando produtos...';
      default:
        return 'Processando...';
    }
  }

  String _getSemanticLabel(PurchaseOperation? operation) {
    if (operation == null) return 'Processando operação de compra';
    
    switch (operation) {
      case PurchaseOperation.purchase:
        return 'Processando sua compra premium';
      case PurchaseOperation.restore:
        return 'Restaurando compras anteriores';
      case PurchaseOperation.loadProducts:
        return 'Carregando produtos disponíveis';
      default:
        return 'Processando operação de compra';
    }
  }
}

/// Authentication operations enum
enum AuthOperation {
  signIn,
  signUp,
  anonymous,
  logout,
  passwordReset,
}

/// Purchase operations enum
enum PurchaseOperation {
  purchase,
  restore,
  loadProducts,
}