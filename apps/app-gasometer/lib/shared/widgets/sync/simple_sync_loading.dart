import 'dart:async';

import 'package:flutter/material.dart';

import '../../../core/theme/gasometer_colors.dart';

/// Loading simples para sincronização - versão otimizada seguindo padrão app-plantis
class SimpleSyncLoading extends StatefulWidget {
  final String message;
  final Duration? autoHideDuration;
  
  const SimpleSyncLoading({
    super.key,
    this.message = 'Sincronizando dados automotivos...',
    this.autoHideDuration,
  });

  @override
  State<SimpleSyncLoading> createState() => _SimpleSyncLoadingState();

  /// Mostra loading simples que desaparece automaticamente
  static void show(
    BuildContext context, {
    String? message,
    Duration? autoHideDuration = const Duration(seconds: 3),
  }) {
    showDialog<void>(
      context: context,
      barrierDismissible: false,
      barrierColor: Colors.black26,
      builder: (context) => SimpleSyncLoading(
        message: message ?? 'Sincronizando dados automotivos...',
        autoHideDuration: autoHideDuration,
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

class _SimpleSyncLoadingState extends State<SimpleSyncLoading> {
  Timer? _autoHideTimer;
  String _currentMessage = '';

  @override
  void initState() {
    super.initState();
    _currentMessage = widget.message;
    
    // Auto-hide após duração especificada (padrão app-plantis)
    if (widget.autoHideDuration != null) {
      _autoHideTimer = Timer(widget.autoHideDuration!, () {
        if (mounted && Navigator.canPop(context)) {
          Navigator.of(context).pop();
        }
      });
    }
  }

  @override
  void dispose() {
    _autoHideTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.ltr,
      child: Center(
        child: Material(
          color: Colors.transparent,
          child: Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.1),
                  blurRadius: 20,
                  spreadRadius: 2,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Ícone automotivo do Gasometer
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: GasometerColors.primary.withValues(alpha: 0.1),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.sync,
                    color: GasometerColors.primary,
                    size: 32,
                  ),
                ),
                const SizedBox(height: 20),
                
                // Loading indicator circular
                const SizedBox(
                  width: 24,
                  height: 24,
                  child: CircularProgressIndicator(
                    valueColor: AlwaysStoppedAnimation<Color>(GasometerColors.primary),
                    strokeWidth: 3,
                  ),
                ),
                const SizedBox(height: 16),
                
                // Mensagem estática (mais simples)
                Text(
                  _currentMessage,
                  style: const TextStyle(
                    fontSize: 16,
                    color: Colors.black87,
                    fontWeight: FontWeight.w500,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 8),
                
                // Submensagem contextual
                Text(
                  'Seus dados estarão atualizados em instantes',
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey.shade600,
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}