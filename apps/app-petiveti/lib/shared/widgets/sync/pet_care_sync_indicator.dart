import 'package:flutter/material.dart';
import 'package:core/core.dart';

import '../../../core/sync/petiveti_sync_service.dart';

/// Indicador de sincronização específico para pet care
/// Mostra status de sync com informações relevantes para cuidados de pets
class PetCareSyncIndicator extends StatefulWidget {
  const PetCareSyncIndicator({
    Key? key,
    this.showEmergencyStatus = true,
    this.compactMode = false,
    this.onEmergencyTap,
    this.onSyncTap,
  }) : super(key: key);

  /// Se deve mostrar status de emergência
  final bool showEmergencyStatus;


  /// Modo compacto (ícone apenas)
  final bool compactMode;

  /// Callback para tap em emergência
  final VoidCallback? onEmergencyTap;

  /// Callback para tap em sync
  final VoidCallback? onSyncTap;

  @override
  State<PetCareSyncIndicator> createState() => _PetCareSyncIndicatorState();
}

class _PetCareSyncIndicatorState extends State<PetCareSyncIndicator>
    with TickerProviderStateMixin {
  late AnimationController _pulseController;
  late AnimationController _rotationController;
  late Animation<double> _pulseAnimation;
  late Animation<double> _rotationAnimation;

  SyncStatus _currentStatus = SyncStatus.offline;
  EmergencySyncStatus? _emergencyStatus;
  bool _hasEmergencyData = false;

  @override
  void initState() {
    super.initState();

    // Configurar animações
    _pulseController = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    );
    _rotationController = AnimationController(
      duration: const Duration(seconds: 1),
      vsync: this,
    );

    _pulseAnimation = Tween<double>(begin: 0.8, end: 1.2).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );
    _rotationAnimation = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(parent: _rotationController, curve: Curves.linear),
    );

    // Inicializar listeners
    _setupListeners();
    _loadInitialStatus();
  }

  @override
  void dispose() {
    _pulseController.dispose();
    _rotationController.dispose();
    super.dispose();
  }

  /// Configura listeners de status
  void _setupListeners() {
    // Listener para status de sync geral
    UnifiedSyncManager.instance.globalSyncStatusStream.listen((statusMap) {
      final petivetiStatus = statusMap['petiveti'];
      if (petivetiStatus != null && mounted) {
        setState(() {
          _currentStatus = petivetiStatus;
        });
        _updateAnimations();
      }
    });

    // Listener para status de emergência
    if (widget.showEmergencyStatus) {
      PetivetiSyncService.instance.emergencyStatusStream.listen((emergencyStatus) {
        if (mounted) {
          setState(() {
            _emergencyStatus = emergencyStatus;
            _hasEmergencyData = emergencyStatus.isEmergencyMode;
          });
          _updateAnimations();
        }
      });
    }
  }

  /// Carrega status inicial
  void _loadInitialStatus() {
    _currentStatus = PetivetiSyncService.instance.currentStatus;
    _updateAnimations();
  }

  /// Atualiza animações baseado no status
  void _updateAnimations() {
    switch (_currentStatus) {
      case SyncStatus.syncing:
        _rotationController.repeat();
        _pulseController.stop();
        break;
      case SyncStatus.offline:
        _rotationController.stop();
        _pulseController.repeat(reverse: true);
        break;
      case SyncStatus.synced:
        _rotationController.stop();
        _pulseController.stop();
        _pulseController.reset();
        break;
      case SyncStatus.localOnly:
        _rotationController.stop();
        _pulseController.repeat(reverse: true);
        break;
      case SyncStatus.error:
        _rotationController.stop();
        _pulseController.repeat(reverse: true);
        break;
      case SyncStatus.conflict:
        _rotationController.stop();
        _pulseController.repeat(reverse: true);
        break;
    }

    // Animação especial para emergência
    if (_hasEmergencyData && _emergencyStatus?.priorityDataPending == true) {
      _pulseController.repeat(reverse: true);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (widget.compactMode) {
      return _buildCompactIndicator();
    } else {
      return _buildFullIndicator();
    }
  }

  /// Constrói indicador compacto
  Widget _buildCompactIndicator() {
    return GestureDetector(
      onTap: widget.onSyncTap,
      child: Container(
        padding: const EdgeInsets.all(8),
        child: AnimatedBuilder(
          animation: Listenable.merge([_pulseAnimation, _rotationAnimation]),
          builder: (context, child) {
            return Transform.scale(
              scale: _currentStatus == SyncStatus.offline || _hasEmergencyData
                  ? _pulseAnimation.value
                  : 1.0,
              child: Transform.rotate(
                angle: _currentStatus == SyncStatus.syncing
                    ? _rotationAnimation.value * 2 * 3.14159
                    : 0,
                child: Icon(
                  _getSyncIcon(),
                  color: _getSyncColor(context),
                  size: 20,
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  /// Constrói indicador completo
  Widget _buildFullIndicator() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: _getSyncColor(context).withOpacity(0.1),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: _getSyncColor(context).withOpacity(0.3),
          width: 1,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Ícone de sync animado
          AnimatedBuilder(
            animation: Listenable.merge([_pulseAnimation, _rotationAnimation]),
            builder: (context, child) {
              return Transform.scale(
                scale: _currentStatus == SyncStatus.offline || _hasEmergencyData
                    ? _pulseAnimation.value
                    : 1.0,
                child: Transform.rotate(
                  angle: _currentStatus == SyncStatus.syncing
                      ? _rotationAnimation.value * 2 * 3.14159
                      : 0,
                  child: Icon(
                    _getSyncIcon(),
                    color: _getSyncColor(context),
                    size: 16,
                  ),
                ),
              );
            },
          ),

          const SizedBox(width: 8),

          // Texto de status
          Text(
            _getSyncStatusText(),
            style: TextStyle(
              color: _getSyncColor(context),
              fontSize: 12,
              fontWeight: FontWeight.w500,
            ),
          ),

          // Indicador de emergência
          if (_hasEmergencyData && widget.showEmergencyStatus) ...[
            const SizedBox(width: 8),
            GestureDetector(
              onTap: widget.onEmergencyTap,
              child: Container(
                padding: const EdgeInsets.all(2),
                decoration: BoxDecoration(
                  color: Colors.red,
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.medical_services,
                  color: Colors.white,
                  size: 12,
                ),
              ),
            ),
          ],

        ],
      ),
    );
  }

  /// Obtém ícone de sync
  IconData _getSyncIcon() {
    if (_hasEmergencyData && _emergencyStatus?.priorityDataPending == true) {
      return Icons.priority_high;
    }

    switch (_currentStatus) {
      case SyncStatus.syncing:
        return Icons.sync;
      case SyncStatus.synced:
        return Icons.cloud_done;
      case SyncStatus.offline:
        return Icons.cloud_off;
      case SyncStatus.localOnly:
        return Icons.storage;
      case SyncStatus.error:
        return Icons.error;
      case SyncStatus.conflict:
        return Icons.warning;
    }
  }

  /// Obtém cor de sync
  Color _getSyncColor(BuildContext context) {
    final theme = Theme.of(context);

    if (_hasEmergencyData && _emergencyStatus?.priorityDataPending == true) {
      return Colors.red;
    }

    switch (_currentStatus) {
      case SyncStatus.syncing:
        return theme.primaryColor;
      case SyncStatus.synced:
        return Colors.green;
      case SyncStatus.offline:
        return Colors.orange;
      case SyncStatus.localOnly:
        return Colors.grey;
      case SyncStatus.error:
        return Colors.red;
      case SyncStatus.conflict:
        return Colors.orange;
    }
  }

  /// Obtém texto de status
  String _getSyncStatusText() {
    if (_hasEmergencyData && _emergencyStatus?.priorityDataPending == true) {
      return 'Emergência';
    }

    switch (_currentStatus) {
      case SyncStatus.syncing:
        return 'Sincronizando';
      case SyncStatus.synced:
        return 'Sincronizado';
      case SyncStatus.offline:
        return 'Offline';
      case SyncStatus.localOnly:
        return 'Local';
      case SyncStatus.error:
        return 'Erro';
      case SyncStatus.conflict:
        return 'Conflito';
    }
  }
}

/// Widget para mostrar detalhes de sincronização
class PetCareSyncDetailsSheet extends StatelessWidget {
  const PetCareSyncDetailsSheet({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Row(
            children: [
              Icon(
                Icons.pets,
                color: Theme.of(context).primaryColor,
              ),
              const SizedBox(width: 8),
              Text(
                'Status de Sincronização',
                style: Theme.of(context).textTheme.titleLarge,
              ),
              const Spacer(),
              IconButton(
                onPressed: () => Navigator.of(context).pop(),
                icon: const Icon(Icons.close),
              ),
            ],
          ),

          const SizedBox(height: 16),

          // Status geral
          _buildStatusCard(
            context,
            'Status Geral',
            PetivetiSyncService.instance.currentStatus,
            Icons.sync,
          ),

          const SizedBox(height: 12),

          // Status de entidades
          FutureBuilder<Map<String, dynamic>>(
            future: _loadEntityStats(),
            builder: (context, snapshot) {
              if (snapshot.hasData) {
                return _buildEntityStats(context, snapshot.data!);
              } else {
                return const Center(child: CircularProgressIndicator());
              }
            },
          ),

          const SizedBox(height: 16),

          // Ações
          Row(
            children: [
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: () => _forceSync(context),
                  icon: const Icon(Icons.refresh),
                  label: const Text('Sincronizar Agora'),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: () => _forceEmergencySync(context),
                  icon: const Icon(Icons.medical_services),
                  label: const Text('Sync Emergência'),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  /// Constrói card de status
  Widget _buildStatusCard(
    BuildContext context,
    String title,
    SyncStatus status,
    IconData icon,
  ) {
    Color color;
    String statusText;

    switch (status) {
      case SyncStatus.synced:
        color = Colors.green;
        statusText = 'Todos os dados sincronizados';
        break;
      case SyncStatus.syncing:
        color = Theme.of(context).primaryColor;
        statusText = 'Sincronizando dados...';
        break;
      case SyncStatus.offline:
        color = Colors.orange;
        statusText = 'Sem conexão - usando dados locais';
        break;
      case SyncStatus.localOnly:
        color = Colors.grey;
        statusText = 'Apenas dados locais';
        break;
      case SyncStatus.error:
        color = Colors.red;
        statusText = 'Erro na sincronização';
        break;
      case SyncStatus.conflict:
        color = Colors.orange;
        statusText = 'Conflito de dados';
        break;
    }

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Row(
        children: [
          Icon(icon, color: color),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    color: color,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  statusText,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: color,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  /// Constrói estatísticas de entidades
  Widget _buildEntityStats(BuildContext context, Map<String, dynamic> stats) {
    final entities = [
      {'name': 'Animais', 'icon': Icons.pets, 'key': 'animals'},
      {'name': 'Medicações', 'icon': Icons.medication, 'key': 'medications'},
      {'name': 'Consultas', 'icon': Icons.medical_services, 'key': 'appointments'},
      {'name': 'Peso', 'icon': Icons.monitor_weight, 'key': 'weights'},
      {'name': 'Configurações', 'icon': Icons.settings, 'key': 'settings'},
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Status por Categoria',
          style: Theme.of(context).textTheme.titleMedium,
        ),
        const SizedBox(height: 8),
        ...entities.map((entity) => _buildEntityRow(
          context,
          entity['name'] as String,
          entity['icon'] as IconData,
          stats[entity['key']] as Map<String, dynamic>? ?? {},
        )),
      ],
    );
  }

  /// Constrói linha de entidade
  Widget _buildEntityRow(
    BuildContext context,
    String name,
    IconData icon,
    Map<String, dynamic> entityStats,
  ) {
    final synced = entityStats['synced_count'] as int? ?? 0;
    final total = entityStats['total_count'] as int? ?? 0;
    final pending = total - synced;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Icon(icon, size: 20, color: Colors.grey[600]),
          const SizedBox(width: 12),
          Expanded(
            child: Text(name),
          ),
          if (pending > 0) ...[
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
              decoration: BoxDecoration(
                color: Colors.orange,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Text(
                '$pending pendente${pending > 1 ? 's' : ''}',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 10,
                ),
              ),
            ),
          ] else ...[
            Icon(
              Icons.check_circle,
              color: Colors.green,
              size: 16,
            ),
          ],
        ],
      ),
    );
  }

  /// Carrega estatísticas de entidades
  Future<Map<String, dynamic>> _loadEntityStats() async {
    // TODO: Implementar carregamento real de estatísticas
    // Por enquanto, retornar dados mock
    return {
      'animals': {'synced_count': 3, 'total_count': 3},
      'medications': {'synced_count': 2, 'total_count': 5},
      'appointments': {'synced_count': 1, 'total_count': 2},
      'weights': {'synced_count': 10, 'total_count': 12},
      'settings': {'synced_count': 1, 'total_count': 1},
    };
  }

  /// Força sincronização
  Future<void> _forceSync(BuildContext context) async {
    final result = await UnifiedSyncManager.instance.forceSyncApp('petiveti');

    if (context.mounted) {
      result.fold(
        (failure) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Erro ao sincronizar: ${failure.message}'),
              backgroundColor: Colors.red,
            ),
          );
        },
        (_) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Sincronização concluída com sucesso!'),
              backgroundColor: Colors.green,
            ),
          );
          Navigator.of(context).pop();
        },
      );
    }
  }

  /// Força sincronização de emergência
  Future<void> _forceEmergencySync(BuildContext context) async {
    final result = await PetivetiSyncService.instance.forceEmergencySync();

    if (context.mounted) {
      result.fold(
        (failure) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Erro na sincronização de emergência: ${failure.message}'),
              backgroundColor: Colors.red,
            ),
          );
        },
        (_) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Dados de emergência sincronizados!'),
              backgroundColor: Colors.green,
            ),
          );
          Navigator.of(context).pop();
        },
      );
    }
  }
}