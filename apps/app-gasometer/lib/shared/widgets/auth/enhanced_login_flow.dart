import 'dart:async';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme/loading_design_tokens.dart';
import '../loading/intelligent_loading.dart';
import '../loading/skeleton_loading.dart';
import '../transitions/smooth_page_transition.dart';

/// Widget que gerencia o fluxo completo de login melhorado
/// Combina IntelligentLoading, SkeletonLoading e navegação suave
class EnhancedLoginFlow extends StatefulWidget {
  const EnhancedLoginFlow({
    super.key,
    this.onLoginStart,
    this.onLoginComplete,
    this.destinationRoute = '/vehicles',
    this.showSkeletonPreview = true,
    this.skeletonDuration = const Duration(milliseconds: 2000),
    this.customSteps,
    this.primaryColor,
  });
  final VoidCallback? onLoginStart;
  final VoidCallback? onLoginComplete;
  final String destinationRoute;
  final bool showSkeletonPreview;
  final Duration skeletonDuration;
  final List<LoadingStepConfig>? customSteps;
  final Color? primaryColor;

  /// Factory para fluxo de login padrão para veículos
  static EnhancedLoginFlow vehicles({
    Key? key,
    VoidCallback? onLoginStart,
    VoidCallback? onLoginComplete,
    Color? primaryColor,
  }) {
    return EnhancedLoginFlow(
      key: key,
      onLoginStart: onLoginStart,
      onLoginComplete: onLoginComplete,
      destinationRoute: '/vehicles',
      primaryColor: primaryColor,
    );
  }

  /// Factory para fluxo personalizado
  static EnhancedLoginFlow custom({
    Key? key,
    required String destinationRoute,
    required List<LoadingStepConfig> steps,
    VoidCallback? onLoginStart,
    VoidCallback? onLoginComplete,
    bool showSkeletonPreview = true,
    Color? primaryColor,
  }) {
    return EnhancedLoginFlow(
      key: key,
      destinationRoute: destinationRoute,
      customSteps: steps,
      onLoginStart: onLoginStart,
      onLoginComplete: onLoginComplete,
      showSkeletonPreview: showSkeletonPreview,
      primaryColor: primaryColor,
    );
  }

  @override
  State<EnhancedLoginFlow> createState() => _EnhancedLoginFlowState();
}

class _EnhancedLoginFlowState extends State<EnhancedLoginFlow> {
  LoginFlowPhase _currentPhase = LoginFlowPhase.intelligent;
  Timer? _phaseTimer;

  @override
  void initState() {
    super.initState();
    widget.onLoginStart?.call();
    _startFlow();
  }

  @override
  void dispose() {
    _phaseTimer?.cancel();
    super.dispose();
  }

  void _startFlow() {
    setState(() {
      _currentPhase = LoginFlowPhase.intelligent;
    });
  }

  void _onIntelligentLoadingComplete() {
    if (!mounted) return;

    if (widget.showSkeletonPreview) {
      setState(() {
        _currentPhase = LoginFlowPhase.skeleton;
      });
      _phaseTimer = Timer(widget.skeletonDuration, () {
        if (mounted) {
          _completeFlow();
        }
      });
    } else {
      _completeFlow();
    }
  }

  void _completeFlow() {
    if (!mounted) return;
    setState(() {
      _currentPhase = LoginFlowPhase.navigation;
    });
    widget.onLoginComplete?.call();
    Timer(const Duration(milliseconds: 500), () {
      if (mounted) {
        context.go(widget.destinationRoute);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: SafeArea(child: _buildCurrentPhase()),
    );
  }

  Widget _buildCurrentPhase() {
    switch (_currentPhase) {
      case LoginFlowPhase.intelligent:
        return _buildIntelligentPhase();

      case LoginFlowPhase.skeleton:
        return _buildSkeletonPhase();

      case LoginFlowPhase.navigation:
        return _buildNavigationPhase();
    }
  }

  Widget _buildIntelligentPhase() {
    return Center(
      child: Container(
        constraints: const BoxConstraints(maxWidth: 400),
        margin: const EdgeInsets.all(LoadingDesignTokens.spacingLg),
        child: IntelligentLoading(
          steps: widget.customSteps ?? LoadingDesignTokens.loginSteps,
          primaryColor: widget.primaryColor,
          onComplete: _onIntelligentLoadingComplete,
        ),
      ),
    );
  }

  Widget _buildSkeletonPhase() {
    Widget skeletonContent;
    if (widget.destinationRoute.contains('/vehicles')) {
      skeletonContent = const VehiclesSkeleton(
        vehicleCount: 3,
        showStats: true,
      );
    } else {
      skeletonContent = SkeletonLoading.list(itemCount: 5);
    }

    return SmoothPageTransition.fadeSlide(
      child: Column(
        children: [_buildSkeletonHeader(), Expanded(child: skeletonContent)],
      ),
    );
  }

  Widget _buildNavigationPhase() {
    return SmoothPageTransition.fade(
      child: Center(
        child: Container(
          padding: const EdgeInsets.all(LoadingDesignTokens.spacingXl),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: 80,
                height: 80,
                decoration: BoxDecoration(
                  color: LoadingDesignTokens.successColor.withValues(
                    alpha: 0.1,
                  ),
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: LoadingDesignTokens.successColor,
                    width: 2,
                  ),
                ),
                child: const Icon(
                  Icons.check_circle_outline,
                  size: 48,
                  color: LoadingDesignTokens.successColor,
                ),
              ),

              const SizedBox(height: LoadingDesignTokens.spacingLg),
              Text(
                'Tudo pronto!',
                style: LoadingDesignTokens.titleTextStyle.copyWith(
                  color: Theme.of(context).colorScheme.onSurface,
                ),
              ),

              const SizedBox(height: LoadingDesignTokens.spacingSm),

              Text(
                'Redirecionando...',
                style: LoadingDesignTokens.bodyTextStyle.copyWith(
                  color: Theme.of(
                    context,
                  ).colorScheme.onSurface.withValues(alpha: 0.7),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSkeletonHeader() {
    final colors = LoadingDesignTokens.getColorScheme(context);

    return Container(
      padding: const EdgeInsets.all(LoadingDesignTokens.spacingMd),
      decoration: BoxDecoration(
        color: colors.surface,
        boxShadow: [
          BoxShadow(
            color: colors.onSurface.withValues(alpha: 0.1),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          SizedBox(
            width: 16,
            height: 16,
            child: CircularProgressIndicator(
              strokeWidth: 2,
              valueColor: AlwaysStoppedAnimation(
                widget.primaryColor ?? colors.primary,
              ),
            ),
          ),

          const SizedBox(width: LoadingDesignTokens.spacingMd),
          Expanded(
            child: Text(
              'Preparando sua página...',
              style: LoadingDesignTokens.bodyTextStyle.copyWith(
                color: colors.onSurface,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// Overlay para exibir o fluxo de login melhorado
class EnhancedLoginFlowOverlay {
  /// Mostra o fluxo de login como overlay de tela cheia
  static Future<void> show(
    BuildContext context, {
    String destinationRoute = '/vehicles',
    List<LoadingStepConfig>? customSteps,
    bool showSkeletonPreview = true,
    Duration skeletonDuration = const Duration(milliseconds: 2000),
    Color? primaryColor,
    VoidCallback? onLoginStart,
    VoidCallback? onLoginComplete,
  }) async {
    final completer = Completer<void>();

    late OverlayEntry overlayEntry;

    overlayEntry = OverlayEntry(
      builder:
          (context) => Material(
            child: EnhancedLoginFlow(
              destinationRoute: destinationRoute,
              customSteps: customSteps,
              showSkeletonPreview: showSkeletonPreview,
              skeletonDuration: skeletonDuration,
              primaryColor: primaryColor,
              onLoginStart: onLoginStart,
              onLoginComplete: () {
                onLoginComplete?.call();
                overlayEntry.remove();
                if (!completer.isCompleted) {
                  completer.complete();
                }
              },
            ),
          ),
    );

    Overlay.of(context).insert(overlayEntry);

    return completer.future;
  }

  /// Mostra fluxo específico para veículos
  static Future<void> showVehiclesFlow(
    BuildContext context, {
    Color? primaryColor,
    VoidCallback? onLoginStart,
    VoidCallback? onLoginComplete,
  }) {
    return show(
      context,
      destinationRoute: '/vehicles',
      primaryColor: primaryColor,
      onLoginStart: onLoginStart,
      onLoginComplete: onLoginComplete,
    );
  }
}

/// Widget para substituir a tela de login existente
class EnhancedLoginPage extends StatelessWidget {
  const EnhancedLoginPage({
    super.key,
    this.destinationRoute = '/vehicles',
    this.customSteps,
    this.showSkeletonPreview = true,
    this.primaryColor,
  });
  final String destinationRoute;
  final List<LoadingStepConfig>? customSteps;
  final bool showSkeletonPreview;
  final Color? primaryColor;

  @override
  Widget build(BuildContext context) {
    return EnhancedLoginFlow(
      destinationRoute: destinationRoute,
      customSteps: customSteps,
      showSkeletonPreview: showSkeletonPreview,
      primaryColor: primaryColor,
    );
  }
}

/// Controller para gerenciar o fluxo de login melhorado
class EnhancedLoginFlowController {
  factory EnhancedLoginFlowController() {
    _instance ??= EnhancedLoginFlowController._internal();
    return _instance!;
  }

  EnhancedLoginFlowController._internal();
  static EnhancedLoginFlowController? _instance;

  /// Inicia fluxo de login melhorado após autenticação
  static Future<void> startAfterAuth(
    BuildContext context, {
    String destinationRoute = '/vehicles',
    List<LoadingStepConfig>? customSteps,
    bool showSkeletonPreview = true,
    Color? primaryColor,
    VoidCallback? onComplete,
  }) async {
    await Navigator.of(context).push(
      PageRouteBuilder<void>(
        pageBuilder:
            (context, animation, secondaryAnimation) => EnhancedLoginFlow(
              destinationRoute: destinationRoute,
              customSteps: customSteps,
              showSkeletonPreview: showSkeletonPreview,
              primaryColor: primaryColor,
              onLoginComplete: onComplete,
            ),
        transitionDuration: LoadingDesignTokens.normalDuration,
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          return FadeTransition(opacity: animation, child: child);
        },
        fullscreenDialog: true,
      ),
    );
  }

  /// Integra com navegação GoRouter
  static void integrateWithGoRouter(
    BuildContext context, {
    required VoidCallback onAuthSuccess,
    String destinationRoute = '/vehicles',
    Color? primaryColor,
  }) {
    startAfterAuth(
      context,
      destinationRoute: destinationRoute,
      primaryColor: primaryColor,
      onComplete: onAuthSuccess,
    );
  }
}

/// Utilitários para integração com AuthProvider
class AuthFlowIntegration {
  static void handleAuthSuccess(
    BuildContext context, {
    required bool isSignUp,
    String vehiclesRoute = '/vehicles',
    Color? primaryColor,
  }) {
    final destinationRoute =
        isSignUp ? '$vehiclesRoute?first_access=true' : vehiclesRoute;

    EnhancedLoginFlowController.startAfterAuth(
      context,
      destinationRoute: destinationRoute,
      primaryColor: primaryColor,
      onComplete: () {},
    );
  }

  static void integrateWithAuthProvider(
    BuildContext context, {
    required VoidCallback originalOnSuccess,
    String destinationRoute = '/vehicles',
    Color? primaryColor,
  }) {
    originalOnSuccess();
    EnhancedLoginFlowController.startAfterAuth(
      context,
      destinationRoute: destinationRoute,
      primaryColor: primaryColor,
    );
  }
}

/// Fases do fluxo de login melhorado
enum LoginFlowPhase {
  intelligent, // Loading inteligente com etapas
  skeleton, // Preview skeleton da página destino
  navigation, // Finalização e navegação
}
