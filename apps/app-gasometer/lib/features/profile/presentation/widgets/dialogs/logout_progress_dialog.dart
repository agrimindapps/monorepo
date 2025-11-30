import 'dart:async';

import 'package:flutter/material.dart';

import '../../../../../core/theme/design_tokens.dart';

/// Dialog de progresso durante o logout
class LogoutProgressDialog extends StatefulWidget {
  const LogoutProgressDialog({super.key});

  @override
  State<LogoutProgressDialog> createState() => _LogoutProgressDialogState();
}

class _LogoutProgressDialogState extends State<LogoutProgressDialog>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  int _currentStepIndex = 0;
  Timer? _timer;

  static const _progressSteps = [
    'Limpando dados locais...',
    'Removendo configurações...',
    'Finalizando logout...',
  ];

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );
    _animationController.forward();
    _startProgressSteps();
  }

  @override
  void dispose() {
    _timer?.cancel();
    _animationController.dispose();
    super.dispose();
  }

  void _startProgressSteps() {
    _timer = Timer.periodic(const Duration(milliseconds: 600), (timer) {
      if (mounted) {
        setState(() => _currentStepIndex = (_currentStepIndex + 1) % _progressSteps.length);
      } else {
        timer.cancel();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    const primaryColor = GasometerDesignTokens.colorPrimary;

    return FadeTransition(
      opacity: _fadeAnimation,
      child: Dialog(
        backgroundColor: Colors.transparent,
        child: Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: theme.colorScheme.surface,
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(color: Colors.black.withValues(alpha: 0.3), blurRadius: 20, offset: const Offset(0, 10)),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              _buildIcon(primaryColor),
              const SizedBox(height: 24),
              Text('Saindo da Conta',
                  style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold, color: theme.colorScheme.onSurface),
                  textAlign: TextAlign.center),
              const SizedBox(height: 16),
              const SizedBox(width: 40, height: 40, child: CircularProgressIndicator(valueColor: AlwaysStoppedAnimation<Color>(primaryColor))),
              const SizedBox(height: 20),
              AnimatedSwitcher(
                duration: const Duration(milliseconds: 300),
                child: Text(_progressSteps[_currentStepIndex],
                    key: ValueKey<int>(_currentStepIndex),
                    style: theme.textTheme.bodyMedium?.copyWith(color: theme.colorScheme.onSurface.withValues(alpha: 0.7)),
                    textAlign: TextAlign.center),
              ),
              const SizedBox(height: 16),
              _buildInfoBox(theme),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildIcon(Color primaryColor) {
    return Container(
      width: 64,
      height: 64,
      decoration: BoxDecoration(color: primaryColor.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(32)),
      child: RotationTransition(
        turns: _animationController,
        child: Icon(Icons.logout, size: 32, color: primaryColor),
      ),
    );
  }

  Widget _buildInfoBox(ThemeData theme) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: theme.colorScheme.primaryContainer,
        borderRadius: GasometerDesignTokens.borderRadius(GasometerDesignTokens.radiusButton),
      ),
      child: Row(
        children: [
          Icon(Icons.info_outline, color: theme.colorScheme.primary, size: 20),
          const SizedBox(width: 8),
          Expanded(
            child: Text('Aguarde enquanto processamos sua saída',
                style: TextStyle(fontSize: 14, color: theme.colorScheme.onPrimaryContainer)),
          ),
        ],
      ),
    );
  }
}
