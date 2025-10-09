import 'dart:async';

import 'package:core/core.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/theme/design_tokens.dart';

/// Dialog stateful para confirmação de exclusão de conta
class AccountDeletionDialog extends StatefulWidget {
  const AccountDeletionDialog({super.key});

  @override
  State<AccountDeletionDialog> createState() => _AccountDeletionDialogState();
}

class _AccountDeletionDialogState extends State<AccountDeletionDialog> {
  final TextEditingController _confirmationController = TextEditingController();
  bool _isConfirmationValid = false;

  @override
  void initState() {
    super.initState();
    _confirmationController.addListener(_validateConfirmation);
  }

  @override
  void dispose() {
    _confirmationController.dispose();
    super.dispose();
  }

  void _validateConfirmation() {
    setState(() {
      _isConfirmationValid =
          _confirmationController.text.trim().toUpperCase() == 'CONCORDO';
    });
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      shape: RoundedRectangleBorder(
        borderRadius: GasometerDesignTokens.borderRadius(
          GasometerDesignTokens.radiusDialog,
        ),
      ),
      title: Row(
        children: [
          Icon(
            Icons.warning,
            color: Theme.of(context).colorScheme.error,
            size: 28,
          ),
          const SizedBox(width: 12),
          Text(
            'Excluir Conta',
            style: TextStyle(
              color: Theme.of(context).colorScheme.error,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Esta ação é irreversível e resultará em:',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: Theme.of(context).colorScheme.onSurface,
            ),
          ),
          const SizedBox(height: 16),
          _buildDeletionItem(
            context,
            Icons.delete_forever,
            'Exclusão permanente de todos os seus dados',
          ),
          _buildDeletionItem(
            context,
            Icons.history,
            'Perda do histórico de atividades',
          ),
          _buildDeletionItem(
            context,
            Icons.cloud_off,
            'Impossibilidade de recuperar informações',
          ),
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.primaryContainer,
              borderRadius: GasometerDesignTokens.borderRadius(
                GasometerDesignTokens.radiusButton,
              ),
            ),
            child: Row(
              children: [
                Icon(
                  Icons.info_outline,
                  color: Theme.of(context).colorScheme.primary,
                  size: 20,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'Esta ação não pode ser desfeita',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                      color: Theme.of(context).colorScheme.onPrimaryContainer,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),
          Text(
            'Para confirmar, digite CONCORDO abaixo:',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: Theme.of(context).colorScheme.onSurface,
            ),
          ),
          const SizedBox(height: 8),
          TextField(
            controller: _confirmationController,
            decoration: InputDecoration(
              hintText: 'Digite CONCORDO para confirmar',
              border: OutlineInputBorder(
                borderRadius: GasometerDesignTokens.borderRadius(
                  GasometerDesignTokens.radiusButton,
                ),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: GasometerDesignTokens.borderRadius(
                  GasometerDesignTokens.radiusButton,
                ),
                borderSide: BorderSide(
                  color: Theme.of(context).colorScheme.primary,
                  width: 2,
                ),
              ),
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 12,
                vertical: 14,
              ),
            ),
            textCapitalization: TextCapitalization.characters,
            inputFormatters: [UpperCaseTextFormatter()],
            style: TextStyle(
              fontSize: 16,
              color: Theme.of(context).colorScheme.onSurface,
            ),
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: Text(
            'Cancelar',
            style: TextStyle(
              color: Theme.of(
                context,
              ).colorScheme.onSurface.withValues(alpha: 0.7),
            ),
          ),
        ),
        ElevatedButton(
          onPressed:
              _isConfirmationValid
                  ? () {
                    Navigator.of(context).pop();
                    context.go('/account-deletion');
                  }
                  : null,
          style: ElevatedButton.styleFrom(
            backgroundColor:
                _isConfirmationValid
                    ? Theme.of(context).colorScheme.error
                    : Theme.of(
                      context,
                    ).colorScheme.onSurface.withValues(alpha: 0.12),
            foregroundColor:
                _isConfirmationValid
                    ? Colors.white
                    : Theme.of(
                      context,
                    ).colorScheme.onSurface.withValues(alpha: 0.38),
            shape: RoundedRectangleBorder(
              borderRadius: GasometerDesignTokens.borderRadius(
                GasometerDesignTokens.radiusButton,
              ),
            ),
          ),
          child: const Text('Excluir Conta'),
        ),
      ],
    );
  }

  /// Constrói item de informação sobre exclusão
  Widget _buildDeletionItem(BuildContext context, IconData icon, String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        children: [
          Icon(icon, color: Theme.of(context).colorScheme.error, size: 20),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              text,
              style: TextStyle(
                fontSize: 14,
                color: Theme.of(context).colorScheme.onSurface,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// Dialog de progresso durante o logout
class LogoutProgressDialog extends StatefulWidget {
  const LogoutProgressDialog({super.key});

  @override
  State<LogoutProgressDialog> createState() => _LogoutProgressDialogState();
}

class _LogoutProgressDialogState extends State<LogoutProgressDialog>
    with TickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;

  final List<String> _progressSteps = [
    'Limpando dados locais...',
    'Removendo configurações...',
    'Finalizando logout...',
  ];

  int _currentStepIndex = 0;

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
    _animationController.dispose();
    super.dispose();
  }

  void _startProgressSteps() {
    Timer.periodic(const Duration(milliseconds: 600), (timer) {
      if (mounted) {
        setState(() {
          _currentStepIndex = (_currentStepIndex + 1) % _progressSteps.length;
        });
      } else {
        timer.cancel();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

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
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.3),
                blurRadius: 20,
                offset: const Offset(0, 10),
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 64,
                height: 64,
                decoration: BoxDecoration(
                  color: GasometerDesignTokens.colorPrimary.withValues(
                    alpha: 0.1,
                  ),
                  borderRadius: BorderRadius.circular(32),
                ),
                child: RotationTransition(
                  turns: _animationController,
                  child: Icon(
                    Icons.logout,
                    size: 32,
                    color: GasometerDesignTokens.colorPrimary,
                  ),
                ),
              ),

              const SizedBox(height: 24),
              Text(
                'Saindo da Conta',
                style: theme.textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: theme.colorScheme.onSurface,
                ),
                textAlign: TextAlign.center,
              ),

              const SizedBox(height: 16),
              SizedBox(
                width: 40,
                height: 40,
                child: CircularProgressIndicator(
                  valueColor: AlwaysStoppedAnimation<Color>(
                    GasometerDesignTokens.colorPrimary,
                  ),
                ),
              ),

              const SizedBox(height: 20),
              AnimatedSwitcher(
                duration: const Duration(milliseconds: 300),
                child: Text(
                  _progressSteps[_currentStepIndex],
                  key: ValueKey<int>(_currentStepIndex),
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: theme.colorScheme.onSurface.withValues(alpha: 0.7),
                  ),
                  textAlign: TextAlign.center,
                ),
              ),

              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: theme.colorScheme.primaryContainer,
                  borderRadius: GasometerDesignTokens.borderRadius(
                    GasometerDesignTokens.radiusButton,
                  ),
                ),
                child: Row(
                  children: [
                    Icon(
                      Icons.info_outline,
                      color: theme.colorScheme.primary,
                      size: 20,
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'Aguarde enquanto processamos sua saída',
                        style: TextStyle(
                          fontSize: 14,
                          color: theme.colorScheme.onPrimaryContainer,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Dialog stateful para confirmação de limpeza de dados
class DataClearDialog extends ConsumerStatefulWidget {
  const DataClearDialog({super.key});

  @override
  ConsumerState<DataClearDialog> createState() => _DataClearDialogState();
}

class _DataClearDialogState extends ConsumerState<DataClearDialog> {
  final TextEditingController _confirmationController = TextEditingController();
  bool _isConfirmationValid = false;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _confirmationController.addListener(_validateConfirmation);
  }

  @override
  void dispose() {
    _confirmationController.dispose();
    super.dispose();
  }

  void _validateConfirmation() {
    setState(() {
      _isConfirmationValid =
          _confirmationController.text.trim().toUpperCase() == 'LIMPAR';
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return AlertDialog(
      shape: RoundedRectangleBorder(
        borderRadius: GasometerDesignTokens.borderRadius(
          GasometerDesignTokens.radiusDialog,
        ),
      ),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 64,
            height: 64,
            decoration: BoxDecoration(
              color: GasometerDesignTokens.colorWarning.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(32),
            ),
            child: const Icon(
              Icons.delete_sweep,
              size: 32,
              color: GasometerDesignTokens.colorWarning,
            ),
          ),

          const SizedBox(height: 20),
          const Text(
            'Limpar Dados do App',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: GasometerDesignTokens.colorWarning,
            ),
            textAlign: TextAlign.center,
          ),

          const SizedBox(height: 16),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Esta ação limpará todos os dados em todos seus dispositivos:',
                style: TextStyle(
                  fontSize: 14,
                  color: theme.colorScheme.onSurface,
                ),
              ),
              const SizedBox(height: 16),
              _buildClearItem(
                context,
                Icons.directions_car,
                'Todos os seus veículos',
              ),
              _buildClearItem(
                context,
                Icons.local_gas_station,
                'Todos os abastecimentos',
              ),
              _buildClearItem(context, Icons.build, 'Todas as manutenções'),
              _buildClearItem(
                context,
                Icons.attach_money,
                'Todas as despesas registradas',
              ),
              const SizedBox(height: 16),
              const Row(
                children: [
                  Icon(
                    Icons.warning,
                    color: GasometerDesignTokens.colorWarning,
                    size: 16,
                  ),
                  SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'Esta ação não pode ser desfeita',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                        color: GasometerDesignTokens.colorWarning,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              Text(
                'Para confirmar, digite LIMPAR abaixo:',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: theme.colorScheme.onSurface,
                ),
              ),
              const SizedBox(height: 8),
              TextField(
                controller: _confirmationController,
                enabled: !_isLoading,
                decoration: InputDecoration(
                  hintText: 'Digite LIMPAR para confirmar',
                  border: OutlineInputBorder(
                    borderRadius: GasometerDesignTokens.borderRadius(
                      GasometerDesignTokens.radiusButton,
                    ),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: GasometerDesignTokens.borderRadius(
                      GasometerDesignTokens.radiusButton,
                    ),
                    borderSide: BorderSide(
                      color: GasometerDesignTokens.colorWarning,
                      width: 2,
                    ),
                  ),
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 14,
                  ),
                ),
                textCapitalization: TextCapitalization.characters,
                inputFormatters: [UpperCaseTextFormatter()],
                style: TextStyle(
                  fontSize: 16,
                  color: theme.colorScheme.onSurface,
                ),
              ),
            ],
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: _isLoading ? null : () => Navigator.of(context).pop(),
          child: Text(
            'Cancelar',
            style: TextStyle(
              color: theme.colorScheme.onSurface.withValues(alpha: 0.7),
            ),
          ),
        ),
        ElevatedButton(
          onPressed:
              _isConfirmationValid && !_isLoading
                  ? () async {
                    setState(() {
                      _isLoading = true;
                    });

                    try {
                      // TODO: Implement data clearing logic
                      await Future<void>.delayed(const Duration(seconds: 2));
                      if (mounted) {
                        Navigator.of(context).pop();
                      }
                    } catch (e) {
                      // Handle error
                    } finally {
                      if (mounted) {
                        setState(() {
                          _isLoading = false;
                        });
                      }
                    }
                  }
                  : null,
          style: ElevatedButton.styleFrom(
            backgroundColor:
                _isConfirmationValid && !_isLoading
                    ? GasometerDesignTokens.colorWarning
                    : theme.colorScheme.onSurface.withValues(alpha: 0.12),
            foregroundColor:
                _isConfirmationValid && !_isLoading
                    ? Colors.white
                    : theme.colorScheme.onSurface.withValues(alpha: 0.38),
            shape: RoundedRectangleBorder(
              borderRadius: GasometerDesignTokens.borderRadius(
                GasometerDesignTokens.radiusButton,
              ),
            ),
          ),
          child:
              _isLoading
                  ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(color: Colors.white),
                  )
                  : const Text('Limpar Dados'),
        ),
      ],
    );
  }

  /// Constrói item de informação sobre limpeza
  Widget _buildClearItem(BuildContext context, IconData icon, String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        children: [
          Icon(icon, color: GasometerDesignTokens.colorWarning, size: 20),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              text,
              style: TextStyle(
                fontSize: 14,
                color: Theme.of(context).colorScheme.onSurface,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// Formatter que converte automaticamente o texto para uppercase
class UpperCaseTextFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    return newValue.copyWith(text: newValue.text.toUpperCase());
  }
}
