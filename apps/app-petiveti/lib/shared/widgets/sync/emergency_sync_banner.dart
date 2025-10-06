import 'package:flutter/material.dart';

import '../../../core/sync/petiveti_sync_service.dart';

/// Banner de sincronização de emergência
/// Aparece quando há dados médicos críticos que precisam ser sincronizados
class EmergencySyncBanner extends StatefulWidget {
  const EmergencySyncBanner({
    super.key,
    this.onDismiss,
    this.onEmergencySync,
    this.persistentMode = false,
  });

  /// Callback quando banner é descartado
  final VoidCallback? onDismiss;

  /// Callback para sync de emergência
  final VoidCallback? onEmergencySync;

  /// Se deve permanecer visível (modo persistente)
  final bool persistentMode;

  @override
  State<EmergencySyncBanner> createState() => _EmergencySyncBannerState();
}

class _EmergencySyncBannerState extends State<EmergencySyncBanner>
    with TickerProviderStateMixin {
  late AnimationController _pulseController;
  late AnimationController _slideController;
  late Animation<double> _pulseAnimation;
  late Animation<Offset> _slideAnimation;

  EmergencySyncStatus? _emergencyStatus;
  bool _isVisible = false;
  bool _isDismissed = false;

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      duration: const Duration(seconds: 1),
      vsync: this,
    );
    _slideController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );

    _pulseAnimation = Tween<double>(begin: 0.9, end: 1.1).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );
    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, -1),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _slideController, curve: Curves.easeOut));
    _setupEmergencyListener();
  }

  @override
  void dispose() {
    _pulseController.dispose();
    _slideController.dispose();
    super.dispose();
  }

  /// Configura listener para status de emergência
  void _setupEmergencyListener() {
    PetivetiSyncService.instance.emergencyStatusStream.listen((status) {
      if (mounted) {
        setState(() {
          _emergencyStatus = status;
        });
        _updateVisibility();
      }
    });
  }

  /// Atualiza visibilidade do banner
  void _updateVisibility() {
    final shouldShow = _shouldShowBanner();

    if (shouldShow && !_isVisible && !_isDismissed) {
      _showBanner();
    } else if (!shouldShow && _isVisible) {
      _hideBanner();
    }
  }

  /// Verifica se deve mostrar o banner
  bool _shouldShowBanner() {
    if (_emergencyStatus == null) return false;

    return _emergencyStatus!.isEmergencyMode &&
           (_emergencyStatus!.priorityDataPending ||
            !_emergencyStatus!.isEmergencyDataCurrent);
  }

  /// Mostra o banner
  void _showBanner() {
    setState(() => _isVisible = true);
    _slideController.forward();
    _pulseController.repeat(reverse: true);
  }

  /// Esconde o banner
  void _hideBanner() {
    _slideController.reverse().then((_) {
      if (mounted) {
        setState(() => _isVisible = false);
      }
    });
    _pulseController.stop();
  }

  /// Descarta o banner
  void _dismissBanner() {
    if (!widget.persistentMode) {
      setState(() => _isDismissed = true);
      _hideBanner();
      widget.onDismiss?.call();
    }
  }

  @override
  Widget build(BuildContext context) {
    if (!_isVisible) {
      return const SizedBox.shrink();
    }

    return SlideTransition(
      position: _slideAnimation,
      child: _buildBannerContent(),
    );
  }

  /// Constrói conteúdo do banner
  Widget _buildBannerContent() {
    return Container(
      margin: const EdgeInsets.all(16),
      child: AnimatedBuilder(
        animation: _pulseAnimation,
        builder: (context, child) {
          return Transform.scale(
            scale: _pulseAnimation.value,
            child: Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    Colors.red[600]!,
                    Colors.red[700]!,
                  ],
                ),
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: Colors.red.withValues(alpha: 0.3),
                    blurRadius: 8,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.2),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: const Icon(
                          Icons.medical_services,
                          color: Colors.white,
                          size: 24,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'EMERGÊNCIA - DADOS MÉDICOS',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 14,
                                fontWeight: FontWeight.bold,
                                letterSpacing: 0.5,
                              ),
                            ),
                            Text(
                              _getEmergencyMessage(),
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 12,
                              ),
                            ),
                          ],
                        ),
                      ),
                      if (!widget.persistentMode)
                        IconButton(
                          onPressed: _dismissBanner,
                          icon: const Icon(
                            Icons.close,
                            color: Colors.white,
                            size: 20,
                          ),
                        ),
                    ],
                  ),

                  const SizedBox(height: 12),
                  _buildEmergencyDetails(),

                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Expanded(
                        child: ElevatedButton.icon(
                          onPressed: _handleEmergencySync,
                          icon: const Icon(Icons.sync, size: 18),
                          label: const Text('Sincronizar Agora'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.white,
                            foregroundColor: Colors.red[700],
                            padding: const EdgeInsets.symmetric(vertical: 12),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      OutlinedButton.icon(
                        onPressed: _showEmergencyDetails,
                        icon: const Icon(Icons.info_outline, size: 18),
                        label: const Text('Detalhes'),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: Colors.white,
                          side: const BorderSide(color: Colors.white),
                          padding: const EdgeInsets.symmetric(vertical: 12),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  /// Constrói detalhes da emergência
  Widget _buildEmergencyDetails() {
    if (_emergencyStatus == null) return const SizedBox.shrink();

    final details = <Widget>[];

    if (_emergencyStatus!.priorityDataPending) {
      details.add(_buildDetailRow(
        Icons.priority_high,
        'Dados médicos críticos pendentes de sincronização',
      ));
    }

    if (!_emergencyStatus!.medicalDataSynced) {
      details.add(_buildDetailRow(
        Icons.cloud_off,
        'Informações médicas não sincronizadas',
      ));
    }

    if (!_emergencyStatus!.isEmergencyDataCurrent) {
      final lastSync = _emergencyStatus!.lastEmergencySync;
      final timeAgo = DateTime.now().difference(lastSync);
      details.add(_buildDetailRow(
        Icons.schedule,
        'Última sincronização: ${_formatDuration(timeAgo)} atrás',
      ));
    }

    return Column(
      children: details,
    );
  }

  /// Constrói linha de detalhe
  Widget _buildDetailRow(IconData icon, String text) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Row(
        children: [
          Icon(
            icon,
            color: Colors.white.withValues(alpha: 0.9),
            size: 16,
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              text,
              style: TextStyle(
                color: Colors.white.withValues(alpha: 0.9),
                fontSize: 12,
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// Obtém mensagem de emergência
  String _getEmergencyMessage() {
    if (_emergencyStatus == null) return '';

    if (_emergencyStatus!.priorityDataPending) {
      return 'Dados médicos críticos precisam ser sincronizados';
    } else if (!_emergencyStatus!.medicalDataSynced) {
      return 'Informações médicas não estão sincronizadas';
    } else if (!_emergencyStatus!.isEmergencyDataCurrent) {
      return 'Dados de emergência desatualizados';
    } else {
      return 'Verificação de dados médicos necessária';
    }
  }

  /// Manipula sincronização de emergência
  Future<void> _handleEmergencySync() async {
    showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (context) => const AlertDialog(
        content: Row(
          children: [
            CircularProgressIndicator(),
            SizedBox(width: 16),
            Text('Sincronizando dados de emergência...'),
          ],
        ),
      ),
    );

    try {
      final result = await PetivetiSyncService.instance.forceEmergencySync();

      if (mounted) {
        Navigator.of(context).pop(); // Fechar dialog de loading

        result.fold(
          (failure) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('Erro na sincronização: ${failure.message}'),
                backgroundColor: Colors.red,
                action: SnackBarAction(
                  label: 'Tentar Novamente',
                  textColor: Colors.white,
                  onPressed: _handleEmergencySync,
                ),
              ),
            );
          },
          (_) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Dados de emergência sincronizados com sucesso!'),
                backgroundColor: Colors.green,
              ),
            );
            if (!widget.persistentMode) {
              _dismissBanner();
            }
          },
        );
      }

      widget.onEmergencySync?.call();
    } catch (e) {
      if (mounted) {
        Navigator.of(context).pop(); // Fechar dialog de loading
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Erro inesperado: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  /// Mostra detalhes da emergência
  void _showEmergencyDetails() {
    showDialog<void>(
      context: context,
      builder: (context) => AlertDialog(
        title: Row(
          children: [
            Icon(Icons.medical_services, color: Colors.red[700]),
            const SizedBox(width: 8),
            const Text('Detalhes da Emergência'),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (_emergencyStatus != null) ...[
              _buildInfoRow('Modo Emergência', _emergencyStatus!.isEmergencyMode ? 'Ativo' : 'Inativo'),
              _buildInfoRow('Dados Médicos', _emergencyStatus!.medicalDataSynced ? 'Sincronizados' : 'Pendentes'),
              _buildInfoRow('Dados Prioritários', _emergencyStatus!.priorityDataPending ? 'Pendentes' : 'Atualizados'),
              _buildInfoRow('Última Sincronização', _formatDateTime(_emergencyStatus!.lastEmergencySync)),
              _buildInfoRow('Status Atual', _emergencyStatus!.isEmergencyDataCurrent ? 'Atualizado' : 'Desatualizado'),
            ],
            const SizedBox(height: 16),
            const Text(
              'Em caso de emergência, é crucial que todos os dados médicos do seu pet estejam sincronizados e acessíveis.',
              style: TextStyle(fontSize: 12, color: Colors.grey),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Fechar'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.of(context).pop();
              _handleEmergencySync();
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Sincronizar'),
          ),
        ],
      ),
    );
  }

  /// Constrói linha de informação
  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 120,
            child: Text(
              '$label:',
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(fontSize: 12),
            ),
          ),
        ],
      ),
    );
  }

  /// Formata duração
  String _formatDuration(Duration duration) {
    if (duration.inMinutes < 1) {
      return 'menos de 1 minuto';
    } else if (duration.inMinutes < 60) {
      return '${duration.inMinutes} minuto${duration.inMinutes > 1 ? 's' : ''}';
    } else if (duration.inHours < 24) {
      return '${duration.inHours} hora${duration.inHours > 1 ? 's' : ''}';
    } else {
      return '${duration.inDays} dia${duration.inDays > 1 ? 's' : ''}';
    }
  }

  /// Formata data e hora
  String _formatDateTime(DateTime dateTime) {
    final now = DateTime.now();
    final difference = now.difference(dateTime);

    if (difference.inMinutes < 1) {
      return 'Agora mesmo';
    } else if (difference.inMinutes < 60) {
      return '${difference.inMinutes} min atrás';
    } else if (difference.inHours < 24) {
      return '${difference.inHours}h atrás';
    } else {
      return '${dateTime.day}/${dateTime.month}/${dateTime.year} às ${dateTime.hour}:${dateTime.minute.toString().padLeft(2, '0')}';
    }
  }
}

/// Widget para mostrar status de emergência de forma persistente
class EmergencyStatusWidget extends StatelessWidget {
  const EmergencyStatusWidget({
    super.key,
    this.compact = false,
  });

  final bool compact;

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<EmergencySyncStatus>(
      stream: PetivetiSyncService.instance.emergencyStatusStream,
      builder: (context, snapshot) {
        if (!snapshot.hasData || !snapshot.data!.isEmergencyMode) {
          return const SizedBox.shrink();
        }

        final status = snapshot.data!;
        final isOutdated = !status.isEmergencyDataCurrent;
        final hasPending = status.priorityDataPending;

        if (!isOutdated && !hasPending) {
          return const SizedBox.shrink();
        }

        if (compact) {
          return _buildCompactStatus(context, status);
        } else {
          return _buildFullStatus(context, status);
        }
      },
    );
  }

  Widget _buildCompactStatus(BuildContext context, EmergencySyncStatus status) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: Colors.red,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(
            Icons.medical_services,
            color: Colors.white,
            size: 12,
          ),
          const SizedBox(width: 4),
          Text(
            status.priorityDataPending ? 'PENDENTE' : 'DESATUALIZADO',
            style: const TextStyle(
              color: Colors.white,
              fontSize: 10,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFullStatus(BuildContext context, EmergencySyncStatus status) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.red[50],
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.red[200]!),
      ),
      child: Row(
        children: [
          Icon(
            Icons.medical_services,
            color: Colors.red[700],
            size: 20,
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Status de Emergência',
                  style: TextStyle(
                    color: Colors.red[700],
                    fontWeight: FontWeight.bold,
                    fontSize: 12,
                  ),
                ),
                Text(
                  status.priorityDataPending
                    ? 'Dados críticos pendentes'
                    : 'Dados desatualizados',
                  style: TextStyle(
                    color: Colors.red[600],
                    fontSize: 11,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
