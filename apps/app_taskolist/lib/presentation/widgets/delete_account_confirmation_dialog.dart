import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

/// Dialog robusto para confirmação de exclusão de conta com múltiplos níveis de segurança
class DeleteAccountConfirmationDialog extends StatefulWidget {
  final String userEmail;
  final VoidCallback onConfirmed;

  const DeleteAccountConfirmationDialog({
    super.key,
    required this.userEmail,
    required this.onConfirmed,
  });

  @override
  State<DeleteAccountConfirmationDialog> createState() => _DeleteAccountConfirmationDialogState();
}

class _DeleteAccountConfirmationDialogState extends State<DeleteAccountConfirmationDialog>
    with SingleTickerProviderStateMixin {
  int _currentStep = 0;
  bool _isLoading = false;
  bool _hasReadWarnings = false;
  String _emailConfirmation = '';
  String _confirmationText = '';
  late AnimationController _warningAnimationController;
  late Animation<Color?> _warningColorAnimation;

  static const String _requiredConfirmationText = 'DELETAR CONTA';

  @override
  void initState() {
    super.initState();
    _warningAnimationController = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    )..repeat(reverse: true);
    
    _warningColorAnimation = ColorTween(
      begin: Colors.red[400],
      end: Colors.red[800],
    ).animate(_warningAnimationController);
  }

  @override
  void dispose() {
    _warningAnimationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      contentPadding: EdgeInsets.zero,
      content: Container(
        width: MediaQuery.of(context).size.width * 0.9,
        constraints: const BoxConstraints(maxWidth: 500, maxHeight: 600),
        child: _currentStep == 0 ? _buildWarningStep() : _buildConfirmationStep(),
      ),
    );
  }

  Widget _buildWarningStep() {
    return Container(
      padding: const EdgeInsets.all(24),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Header com ícone de aviso animado
          AnimatedBuilder(
            animation: _warningColorAnimation,
            builder: (context, child) {
              return Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: _warningColorAnimation.value?.withAlpha(30),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.warning_rounded,
                  size: 48,
                  color: _warningColorAnimation.value,
                ),
              );
            },
          ),
          
          const SizedBox(height: 16),
          
          // Título
          const Text(
            '⚠️ EXCLUSÃO PERMANENTE DE CONTA',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Colors.red,
            ),
            textAlign: TextAlign.center,
          ),
          
          const SizedBox(height: 24),
          
          // Lista de avisos
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.red[50],
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.red[200]!),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Esta ação é IRREVERSÍVEL e resultará em:',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: Colors.red,
                  ),
                ),
                const SizedBox(height: 12),
                _buildWarningItem('🗑️ Exclusão permanente da sua conta'),
                _buildWarningItem('📋 Perda de todas as suas tarefas e dados'),
                _buildWarningItem('📊 Perda de estatísticas e histórico'),
                _buildWarningItem('🔒 Perda de acesso ao aplicativo'),
                _buildWarningItem('❌ Impossibilidade de recuperar os dados'),
                const SizedBox(height: 12),
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.red[100],
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.info_outline, color: Colors.red),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          'Não há backup ou possibilidade de desfazer esta operação!',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: Colors.red[800],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          
          const SizedBox(height: 24),
          
          // Checkbox de confirmação de leitura
          CheckboxListTile(
            value: _hasReadWarnings,
            onChanged: (value) {
              setState(() {
                _hasReadWarnings = value ?? false;
              });
              if (value == true) {
                HapticFeedback.lightImpact();
              }
            },
            title: const Text(
              'Li e compreendo que esta ação é irreversível',
              style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
            ),
            activeColor: Colors.red,
            dense: true,
            controlAffinity: ListTileControlAffinity.leading,
          ),
          
          const SizedBox(height: 24),
          
          // Botões
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              // Cancelar
              Expanded(
                child: OutlinedButton(
                  onPressed: () => Navigator.of(context).pop(),
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    side: const BorderSide(color: Colors.grey),
                  ),
                  child: const Text(
                    'Cancelar',
                    style: TextStyle(color: Colors.grey),
                  ),
                ),
              ),
              
              const SizedBox(width: 16),
              
              // Continuar
              Expanded(
                child: ElevatedButton(
                  onPressed: _hasReadWarnings ? _proceedToConfirmation : null,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.red,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 12),
                  ),
                  child: const Text(
                    'Continuar',
                    style: TextStyle(fontWeight: FontWeight.w600),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildConfirmationStep() {
    final isEmailValid = _emailConfirmation.toLowerCase() == widget.userEmail.toLowerCase();
    final isTextValid = _confirmationText == _requiredConfirmationText;
    final canProceed = isEmailValid && isTextValid && !_isLoading;

    return Container(
      padding: const EdgeInsets.all(24),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Header
          Row(
            children: [
              IconButton(
                onPressed: () => setState(() => _currentStep = 0),
                icon: const Icon(Icons.arrow_back),
              ),
              const Expanded(
                child: Text(
                  'Confirmar Exclusão',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
              const SizedBox(width: 48), // Balance the back button
            ],
          ),
          
          const SizedBox(height: 24),
          
          // Instrução de confirmação
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.orange[50],
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.orange[200]!),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Para confirmar a exclusão, complete os campos abaixo:',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    const Icon(Icons.shield_outlined, color: Colors.orange),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'Esta verificação adicional garante que você tem certeza da sua decisão.',
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.orange[800],
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          
          const SizedBox(height: 24),
          
          // Campo 1: Digite seu email
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              RichText(
                text: TextSpan(
                  style: const TextStyle(fontSize: 14, color: Colors.black87),
                  children: [
                    const TextSpan(text: '1. Digite seu email ('),
                    TextSpan(
                      text: widget.userEmail,
                      style: const TextStyle(fontWeight: FontWeight.w600),
                    ),
                    const TextSpan(text: '):'),
                  ],
                ),
              ),
              const SizedBox(height: 8),
              TextField(
                onChanged: (value) => setState(() => _emailConfirmation = value),
                decoration: InputDecoration(
                  hintText: 'seu.email@exemplo.com',
                  border: const OutlineInputBorder(),
                  suffixIcon: isEmailValid
                      ? const Icon(Icons.check_circle, color: Colors.green)
                      : null,
                  errorText: _emailConfirmation.isNotEmpty && !isEmailValid
                      ? 'Email não confere'
                      : null,
                ),
                keyboardType: TextInputType.emailAddress,
                enabled: !_isLoading,
              ),
            ],
          ),
          
          const SizedBox(height: 20),
          
          // Campo 2: Digite o texto de confirmação
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              RichText(
                text: TextSpan(
                  style: const TextStyle(fontSize: 14, color: Colors.black87),
                  children: [
                    const TextSpan(text: '2. Digite exatamente: '),
                    TextSpan(
                      text: _requiredConfirmationText,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Colors.red,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 8),
              TextField(
                onChanged: (value) => setState(() => _confirmationText = value),
                decoration: InputDecoration(
                  hintText: _requiredConfirmationText,
                  border: const OutlineInputBorder(),
                  suffixIcon: isTextValid
                      ? const Icon(Icons.check_circle, color: Colors.green)
                      : null,
                  errorText: _confirmationText.isNotEmpty && !isTextValid
                      ? 'Texto deve ser exatamente "$_requiredConfirmationText"'
                      : null,
                ),
                enabled: !_isLoading,
                textCapitalization: TextCapitalization.characters,
              ),
            ],
          ),
          
          const SizedBox(height: 32),
          
          // Botões
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              // Cancelar
              Expanded(
                child: OutlinedButton(
                  onPressed: _isLoading ? null : () => Navigator.of(context).pop(),
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    side: const BorderSide(color: Colors.grey),
                  ),
                  child: const Text(
                    'Cancelar',
                    style: TextStyle(color: Colors.grey),
                  ),
                ),
              ),
              
              const SizedBox(width: 16),
              
              // Deletar Conta
              Expanded(
                child: ElevatedButton(
                  onPressed: canProceed ? _confirmDeletion : null,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.red,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 12),
                  ),
                  child: _isLoading
                      ? const SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                          ),
                        )
                      : const Text(
                          'DELETAR CONTA',
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildWarningItem(String text) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            margin: const EdgeInsets.only(top: 6),
            width: 6,
            height: 6,
            decoration: const BoxDecoration(
              color: Colors.red,
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              text,
              style: const TextStyle(
                fontSize: 14,
                height: 1.4,
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _proceedToConfirmation() {
    HapticFeedback.mediumImpact();
    setState(() {
      _currentStep = 1;
    });
  }

  void _confirmDeletion() async {
    if (!mounted) return;
    
    setState(() {
      _isLoading = true;
    });

    HapticFeedback.heavyImpact();
    
    // Pequeno delay para mostrar loading
    await Future.delayed(const Duration(milliseconds: 500));
    
    if (!mounted) return;
    
    Navigator.of(context).pop(); // Fechar dialog
    widget.onConfirmed(); // Executar ação
  }
}

/// Função helper para mostrar o dialog
Future<void> showDeleteAccountConfirmation({
  required BuildContext context,
  required String userEmail,
  required VoidCallback onConfirmed,
}) async {
  return showDialog<void>(
    context: context,
    barrierDismissible: false, // Não pode fechar clicando fora
    builder: (BuildContext context) {
      return DeleteAccountConfirmationDialog(
        userEmail: userEmail,
        onConfirmed: onConfirmed,
      );
    },
  );
}