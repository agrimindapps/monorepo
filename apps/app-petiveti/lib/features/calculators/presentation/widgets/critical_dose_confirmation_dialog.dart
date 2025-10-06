import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

/// Dialog de confirmação dupla para doses críticas
/// 
/// Implementa sistema de segurança médica com confirmação obrigatória
/// para doses próximas aos limites tóxicos ou com condições críticas
class CriticalDoseConfirmationDialog extends StatefulWidget {
  final List<String> warnings;
  final String medicationName;
  final double calculatedDose;
  final String unit;
  final String? recommendedAction;

  const CriticalDoseConfirmationDialog({
    super.key,
    required this.warnings,
    required this.medicationName,
    required this.calculatedDose,
    required this.unit,
    this.recommendedAction,
  });

  @override
  State<CriticalDoseConfirmationDialog> createState() => _CriticalDoseConfirmationDialogState();
}

class _CriticalDoseConfirmationDialogState extends State<CriticalDoseConfirmationDialog>
    with TickerProviderStateMixin {
  bool _firstConfirmation = false;
  bool _secondConfirmation = false;
  bool _veterinarianConfirmation = false;
  bool _understandRisks = false;
  
  late AnimationController _pulseController;
  late Animation<double> _pulseAnimation;
  
  int _countdownSeconds = 10;
  bool _canProceed = false;

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      duration: const Duration(seconds: 1),
      vsync: this,
    );
    
    _pulseAnimation = Tween<double>(
      begin: 0.8,
      end: 1.2,
    ).animate(CurvedAnimation(
      parent: _pulseController,
      curve: Curves.easeInOut,
    ));
    
    _pulseController.repeat(reverse: true);
    _startCountdown();
  }

  void _startCountdown() {
    Future.doWhile(() async {
      await Future<void>.delayed(const Duration(seconds: 1));
      if (mounted) {
        setState(() {
          _countdownSeconds--;
        });
        
        if (_countdownSeconds <= 0) {
          setState(() {
            _canProceed = true;
          });
          return false;
        }
        return true;
      }
      return false;
    });
  }

  @override
  void dispose() {
    _pulseController.dispose();
    super.dispose();
  }

  bool get _allConfirmationsChecked => 
      _firstConfirmation && 
      _secondConfirmation && 
      _veterinarianConfirmation && 
      _understandRisks;

  bool get _canConfirm => _allConfirmationsChecked && _canProceed;

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) async {
        if (!didPop) {
          final shouldPop = await _showExitConfirmation(context);
          if (shouldPop && context.mounted) {
            Navigator.of(context).pop(false);
          }
        }
      },
      child: AlertDialog(
        backgroundColor: Colors.red.shade50,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
          side: BorderSide(color: Colors.red.shade400, width: 2),
        ),
        title: AnimatedBuilder(
          animation: _pulseAnimation,
          builder: (context, child) {
            return Transform.scale(
              scale: _pulseAnimation.value,
              child: Row(
                children: [
                  Icon(
                    Icons.warning_amber_rounded,
                    color: Colors.red.shade800,
                    size: 32,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      'CONFIRMAÇÃO CRÍTICA NECESSÁRIA',
                      style: TextStyle(
                        color: Colors.red.shade800,
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
            );
          },
        ),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildDoseInfoCard(),
              const SizedBox(height: 16),
              _buildWarningsSection(),
              const SizedBox(height: 16),
              if (widget.recommendedAction != null)
                _buildRecommendationCard(),
              const SizedBox(height: 16),
              _buildConfirmationSection(),
              const SizedBox(height: 16),
              if (!_canProceed) _buildCountdownSection(),
            ],
          ),
        ),
        actions: [
          TextButton.icon(
            onPressed: () => Navigator.of(context).pop(false),
            icon: const Icon(Icons.cancel_outlined),
            label: const Text('CANCELAR'),
            style: TextButton.styleFrom(
              foregroundColor: Colors.grey.shade700,
            ),
          ),
          ElevatedButton.icon(
            onPressed: _canConfirm ? () => _handleProceedConfirmation() : null,
            icon: _canConfirm 
                ? const Icon(Icons.check_circle) 
                : Icon(Icons.lock, color: Colors.grey.shade400),
            label: Text(_canConfirm 
                ? 'PROSSEGUIR COM CAUTELA' 
                : _canProceed 
                    ? 'CONFIRMAR TODAS AS OPÇÕES'
                    : 'AGUARDE $_countdownSeconds s'),
            style: ElevatedButton.styleFrom(
              backgroundColor: _canConfirm 
                  ? Colors.orange.shade600 
                  : Colors.grey.shade300,
              foregroundColor: _canConfirm 
                  ? Colors.white 
                  : Colors.grey.shade600,
              elevation: _canConfirm ? 4 : 0,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDoseInfoCard() {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.orange.shade100,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.orange.shade300),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'DOSE CALCULADA:',
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.bold,
              color: Colors.orange.shade800,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            '${widget.medicationName}: ${widget.calculatedDose.toStringAsFixed(2)} ${widget.unit}',
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildWarningsSection() {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.red.shade100,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.red.shade300),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.error_outline,
                color: Colors.red.shade700,
                size: 20,
              ),
              const SizedBox(width: 8),
              Text(
                'ALERTAS CRÍTICOS:',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: Colors.red.shade800,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          ...widget.warnings.map((warning) => Padding(
            padding: const EdgeInsets.only(bottom: 4),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(
                  Icons.warning_amber_rounded,
                  color: Colors.red.shade600,
                  size: 16,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    warning,
                    style: const TextStyle(fontSize: 14),
                  ),
                ),
              ],
            ),
          )),
        ],
      ),
    );
  }

  Widget _buildRecommendationCard() {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.blue.shade50,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.blue.shade300),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.medical_information_outlined,
                color: Colors.blue.shade700,
                size: 20,
              ),
              const SizedBox(width: 8),
              Text(
                'RECOMENDAÇÃO:',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: Colors.blue.shade800,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            widget.recommendedAction!,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildConfirmationSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'CONFIRMAÇÕES OBRIGATÓRIAS:',
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.bold,
            color: Colors.grey.shade800,
          ),
        ),
        const SizedBox(height: 12),
        
        _buildConfirmationCheckbox(
          'Li e compreendi todos os alertas críticos acima',
          _firstConfirmation,
          (value) => setState(() => _firstConfirmation = value ?? false),
        ),
        
        _buildConfirmationCheckbox(
          'Confirmo que consultei um veterinário especialista',
          _veterinarianConfirmation,
          (value) => setState(() => _veterinarianConfirmation = value ?? false),
        ),
        
        _buildConfirmationCheckbox(
          'Entendo os riscos e assumo total responsabilidade',
          _understandRisks,
          (value) => setState(() => _understandRisks = value ?? false),
        ),
        
        _buildConfirmationCheckbox(
          'Confirmo dupla verificação dos cálculos de dosagem',
          _secondConfirmation,
          (value) => setState(() => _secondConfirmation = value ?? false),
        ),
      ],
    );
  }

  Widget _buildConfirmationCheckbox(
    String text,
    bool value,
    ValueChanged<bool?> onChanged,
  ) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        children: [
          SizedBox(
            width: 24,
            height: 24,
            child: Checkbox(
              value: value,
              onChanged: _canProceed ? onChanged : null,
              activeColor: Colors.red.shade600,
              checkColor: Colors.white,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              text,
              style: TextStyle(
                fontSize: 13,
                color: _canProceed ? Colors.black87 : Colors.grey.shade600,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCountdownSection() {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.amber.shade50,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.amber.shade300),
      ),
      child: Row(
        children: [
          Icon(
            Icons.timer_outlined,
            color: Colors.amber.shade700,
            size: 20,
          ),
          const SizedBox(width: 8),
          Text(
            'Período de reflexão obrigatório: $_countdownSeconds segundos',
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: Colors.amber.shade800,
            ),
          ),
        ],
      ),
    );
  }

  void _handleProceedConfirmation() {
    HapticFeedback.heavyImpact();
    debugPrint('CRÍTICO: Usuário prosseguiu com dose crítica após confirmações múltiplas');
    debugPrint('Medicamento: ${widget.medicationName}');
    debugPrint('Dose: ${widget.calculatedDose} ${widget.unit}');
    debugPrint('Avisos: ${widget.warnings.join('; ')}');
    
    Navigator.of(context).pop(true);
  }

  Future<bool> _showExitConfirmation(BuildContext context) async {
    final result = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Cancelar Confirmação?'),
        content: const Text(
          'Tem certeza que deseja cancelar? Esta é uma verificação de segurança importante.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Continuar Verificação'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.of(context).pop(true),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.grey.shade600,
            ),
            child: const Text('Sim, Cancelar'),
          ),
        ],
      ),
    );
    
    return result ?? false;
  }
}

/// Widget auxiliar para exibir informações de dose crítica de forma compacta
class CriticalDoseAlert extends StatelessWidget {
  final String message;
  final VoidCallback? onPressed;
  final bool isBlocking;

  const CriticalDoseAlert({
    super.key,
    required this.message,
    this.onPressed,
    this.isBlocking = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: isBlocking ? Colors.red.shade50 : Colors.orange.shade50,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: isBlocking ? Colors.red.shade300 : Colors.orange.shade300,
          width: 1.5,
        ),
      ),
      child: Row(
        children: [
          Icon(
            isBlocking ? Icons.block : Icons.warning_amber_rounded,
            color: isBlocking ? Colors.red.shade700 : Colors.orange.shade700,
            size: 24,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              message,
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: isBlocking ? Colors.red.shade800 : Colors.orange.shade800,
              ),
            ),
          ),
          if (onPressed != null)
            IconButton(
              onPressed: onPressed,
              icon: Icon(
                Icons.info_outline,
                color: isBlocking ? Colors.red.shade600 : Colors.orange.shade600,
              ),
            ),
        ],
      ),
    );
  }
}