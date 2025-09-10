import 'package:flutter/material.dart';

import '../di/injection_container.dart';
import '../interfaces/i_premium_service.dart';

/// Widget de controle para testar funcionalidades premium
/// Permite ativar/desativar licença teste facilmente durante desenvolvimento
class PremiumTestControlsWidget extends StatefulWidget {
  final bool showInProduction;
  
  const PremiumTestControlsWidget({
    super.key,
    this.showInProduction = false,
  });

  @override
  State<PremiumTestControlsWidget> createState() => _PremiumTestControlsWidgetState();
}

class _PremiumTestControlsWidgetState extends State<PremiumTestControlsWidget> {
  final IPremiumService _premiumService = sl<IPremiumService>();
  bool _isProcessing = false;

  @override
  Widget build(BuildContext context) {
    // Em produção, só mostra se explicitamente permitido
    if (!widget.showInProduction && const bool.fromEnvironment('dart.vm.product')) {
      return const SizedBox.shrink();
    }

    return Container(
      margin: const EdgeInsets.all(8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.grey.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.grey.withOpacity(0.3)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            children: [
              const Icon(Icons.developer_mode, size: 20),
              const SizedBox(width: 8),
              Text(
                'Controles de Teste Premium',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: Colors.grey[700],
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          StreamBuilder<bool>(
            stream: _premiumService.premiumStatusStream,
            initialData: _premiumService.isPremium,
            builder: (context, snapshot) {
              final isPremium = snapshot.data ?? false;
              
              return Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  // Status atual
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: isPremium ? Colors.green : Colors.orange,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      isPremium ? 'PREMIUM ATIVO' : 'FREE USER',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  
                  // Botão ativar
                  if (!isPremium)
                    ElevatedButton.icon(
                      onPressed: _isProcessing ? null : _activateTestSubscription,
                      icon: _isProcessing 
                          ? const SizedBox(
                              width: 16,
                              height: 16,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            )
                          : const Icon(Icons.diamond, size: 16),
                      label: const Text('Ativar'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.green,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                      ),
                    ),
                  
                  // Botão desativar
                  if (isPremium)
                    ElevatedButton.icon(
                      onPressed: _isProcessing ? null : _removeTestSubscription,
                      icon: _isProcessing 
                          ? const SizedBox(
                              width: 16,
                              height: 16,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            )
                          : const Icon(Icons.cancel, size: 16),
                      label: const Text('Desativar'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.red,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                      ),
                    ),
                ],
              );
            },
          ),
        ],
      ),
    );
  }

  Future<void> _activateTestSubscription() async {
    if (_isProcessing) return;

    setState(() {
      _isProcessing = true;
    });

    try {
      await _premiumService.generateTestSubscription();
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('✅ Licença teste ativada com sucesso!'),
            backgroundColor: Colors.green,
            duration: Duration(seconds: 2),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('❌ Erro ao ativar licença teste: $e'),
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 3),
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isProcessing = false;
        });
      }
    }
  }

  Future<void> _removeTestSubscription() async {
    if (_isProcessing) return;

    setState(() {
      _isProcessing = true;
    });

    try {
      await _premiumService.removeTestSubscription();
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('🔓 Licença teste removida com sucesso!'),
            backgroundColor: Colors.orange,
            duration: Duration(seconds: 2),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('❌ Erro ao remover licença teste: $e'),
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 3),
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isProcessing = false;
        });
      }
    }
  }
}