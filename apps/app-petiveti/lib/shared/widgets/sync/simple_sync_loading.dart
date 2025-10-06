import 'dart:async';

import 'package:core/core.dart';
import 'package:flutter/material.dart';

import '../../../core/theme/app_colors.dart';

/// Loading simples para sincronização que aparece e some automaticamente
/// Versão do PetiVeti adaptada do padrão usado nos outros apps
class SimpleSyncLoading extends ConsumerStatefulWidget {
  final String message;
  
  const SimpleSyncLoading({
    super.key,
    this.message = 'Sincronizando dados dos pets...',
  });

  @override
  ConsumerState<SimpleSyncLoading> createState() => _SimpleSyncLoadingState();

  /// Mostra loading simples que desaparece automaticamente quando sync termina
  static void show(BuildContext context, {String? message}) {
    showDialog<void>(
      context: context,
      barrierDismissible: false,
      barrierColor: Colors.black26,
      builder: (context) => SimpleSyncLoading(
        message: message ?? 'Sincronizando dados dos pets...',
      ),
    );
  }

  /// Remove loading se estiver visível
  static void hide(BuildContext context) {
    if (Navigator.canPop(context)) {
      Navigator.of(context).pop();
    }
  }
}

class _SimpleSyncLoadingState extends ConsumerState<SimpleSyncLoading>
    with TickerProviderStateMixin {
  StreamSubscription<void>? _syncSubscription;
  String _currentMessage = '';
  late AnimationController _animationController;
  late Animation<double> _pulseAnimation;

  @override
  void initState() {
    super.initState();
    _currentMessage = widget.message;
    _initializeAnimations();
    _startListeningToSync();
  }

  @override
  void dispose() {
    _syncSubscription?.cancel();
    _animationController.dispose();
    super.dispose();
  }

  void _initializeAnimations() {
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    )..repeat(reverse: true);
    
    _pulseAnimation = Tween<double>(
      begin: 0.8,
      end: 1.2,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    ));
  }

  /// Monitora automaticamente o estado da sincronização do PetiVeti
  void _startListeningToSync() {
    _syncSubscription = Stream<void>.periodic(const Duration(milliseconds: 500))
        .listen((_) {
      if (!mounted) return;
      Future.delayed(const Duration(seconds: 2), () {
        if (mounted) {
          _autoClose();
        }
      });
    });
  }

  /// Fecha automaticamente o loading
  void _autoClose() {
    _syncSubscription?.cancel();
    
    if (mounted && Navigator.canPop(context)) {
      Navigator.of(context).pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Material(
        color: Colors.transparent,
        child: Container(
          padding: const EdgeInsets.all(32),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.15),
                blurRadius: 25,
                spreadRadius: 3,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              AnimatedBuilder(
                animation: _pulseAnimation,
                builder: (context, child) {
                  return Transform.scale(
                    scale: _pulseAnimation.value,
                    child: Container(
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: AppColors.primary.withValues(alpha: 0.1),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.pets,
                        color: AppColors.primary,
                        size: 36,
                      ),
                    ),
                  );
                },
              ),
              const SizedBox(height: 24),
              const SizedBox(
                width: 28,
                height: 28,
                child: CircularProgressIndicator(
                  valueColor: AlwaysStoppedAnimation<Color>(AppColors.primary),
                  strokeWidth: 3.5,
                ),
              ),
              const SizedBox(height: 20),
              Text(
                _currentMessage,
                style: const TextStyle(
                  fontSize: 18,
                  color: AppColors.textPrimary,
                  fontWeight: FontWeight.w600,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 12),
              const Text(
                'Seus dados dos pets estarão atualizados em instantes',
                style: TextStyle(
                  fontSize: 15,
                  color: AppColors.textSecondary,
                  fontWeight: FontWeight.w400,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
