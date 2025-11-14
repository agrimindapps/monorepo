import 'dart:async';
import 'dart:ui' as ui;

import 'package:core/core.dart';
import 'package:flutter/material.dart';

import '../../../core/theme/gasometer_colors.dart';

/// Loading simples para sincronização que aparece e some automaticamente - padrão app-plantis
class SimpleSyncLoading extends ConsumerStatefulWidget {
  const SimpleSyncLoading({
    super.key,
    this.message = 'Sincronizando dados automotivos...',
  });
  final String message;

  /// Mostra loading simples que desaparece automaticamente quando sync termina
  static void show(BuildContext context, {String? message}) {
    showDialog<void>(
      context: context,
      barrierDismissible: false,
      barrierColor: Colors.black26,
      builder: (context) => SimpleSyncLoading(
        message: message ?? 'Sincronizando dados automotivos...',
      ),
    );
  }

  /// Remove loading se estiver visível
  static void hide(BuildContext context) {
    if (Navigator.canPop(context)) {
      Navigator.of(context).pop();
    }
  }

  @override
  ConsumerState<SimpleSyncLoading> createState() => _SimpleSyncLoadingState();
}

class _SimpleSyncLoadingState extends ConsumerState<SimpleSyncLoading> {
  StreamSubscription<void>? _syncSubscription;
  String _currentMessage = '';

  @override
  void initState() {
    super.initState();
    _currentMessage = widget.message;
    _startListeningToSync();
  }

  @override
  void dispose() {
    _syncSubscription?.cancel();
    super.dispose();
  }

  /// Monitora automaticamente o estado da sincronização usando UnifiedSyncProvider
  void _startListeningToSync() {
    _syncSubscription = Stream<void>.periodic(const Duration(seconds: 2))
        .listen((_) {
          if (!mounted) return;
          _autoClose();
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
    return Directionality(
      textDirection: ui.TextDirection.ltr,
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
                const SizedBox(
                  width: 24,
                  height: 24,
                  child: CircularProgressIndicator(
                    valueColor: AlwaysStoppedAnimation<Color>(
                      GasometerColors.primary,
                    ),
                    strokeWidth: 3,
                  ),
                ),
                const SizedBox(height: 16),
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
                Text(
                  'Seus dados estarão atualizados em instantes',
                  style: TextStyle(fontSize: 14, color: Colors.grey.shade600),
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
