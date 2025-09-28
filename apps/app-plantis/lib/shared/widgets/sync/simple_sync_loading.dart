import 'dart:async';

import 'package:core/core.dart';
import 'package:flutter/material.dart';

import '../../../core/theme/plantis_colors.dart';
import '../../../features/auth/presentation/providers/auth_provider.dart'
    as local_auth;

/// Loading simples para sincronização que aparece e some automaticamente
class SimpleSyncLoading extends StatefulWidget {
  final String message;

  const SimpleSyncLoading({super.key, this.message = 'Sincronizando dados...'});

  /// Mostra loading simples que desaparece automaticamente quando sync termina
  static void show(BuildContext context, {String? message}) {
    showDialog<void>(
      context: context,
      barrierDismissible: false,
      barrierColor: Colors.black26,
      builder:
          (context) =>
              SimpleSyncLoading(message: message ?? 'Sincronizando dados...'),
    );
  }

  /// Remove loading se estiver visível
  static void hide(BuildContext context) {
    if (Navigator.canPop(context)) {
      Navigator.of(context).pop();
    }
  }

  @override
  State<SimpleSyncLoading> createState() => _SimpleSyncLoadingState();
}

class _SimpleSyncLoadingState extends State<SimpleSyncLoading> {
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

  /// Monitora automaticamente o estado da sincronização
  void _startListeningToSync() {
    final authProvider = context.read<local_auth.AuthProvider>();

    // Verificar periodicamente se a sincronização terminou
    _syncSubscription = Stream<void>.periodic(
      const Duration(milliseconds: 500),
    ).listen((_) {
      if (!mounted) return;

      // Atualizar mensagem se mudou
      if (_currentMessage != authProvider.syncMessage) {
        setState(() {
          _currentMessage = authProvider.syncMessage;
        });
      }

      // Fechar automaticamente quando sincronização termina
      if (!authProvider.isSyncInProgress) {
        _autoClose();
      }
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
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.1),
                blurRadius: 10,
                spreadRadius: 2,
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(
                  PlantisColors.primary,
                ),
                strokeWidth: 3,
              ),
              const SizedBox(height: 16),
              Text(
                _currentMessage,
                style: const TextStyle(fontSize: 16, color: Colors.black87),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
