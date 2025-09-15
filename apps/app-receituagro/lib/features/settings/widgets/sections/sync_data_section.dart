import 'dart:async';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../core/providers/auth_provider.dart';
import '../../../../core/services/manual_sync_service.dart';
import '../../../../core/services/sync_rate_limiter.dart';
import '../../constants/settings_design_tokens.dart';

/// Seção de sincronização de dados na ProfilePage
/// Mostra status, estatísticas e controles de sincronização manual
class SyncDataSection extends StatefulWidget {
  const SyncDataSection({super.key});

  @override
  State<SyncDataSection> createState() => _SyncDataSectionState();
}

class _SyncDataSectionState extends State<SyncDataSection> {
  StreamSubscription<ManualSyncStatus>? _statusSubscription;
  StreamSubscription<SyncRateLimitState>? _rateLimitSubscription;
  
  ManualSyncService? _syncService;
  ManualSyncStatus? _currentStatus;
  Map<String, dynamic>? _syncStats;
  bool _isLoadingStats = false;

  @override
  void initState() {
    super.initState();
    _initializeSyncService();
  }

  @override
  void dispose() {
    _statusSubscription?.cancel();
    _rateLimitSubscription?.cancel();
    super.dispose();
  }

  /// Inicializa o serviço de sincronização manual
  /// TODO: Integrar com dependency injection quando estiver disponível
  void _initializeSyncService() {
    // Por enquanto, não temos DI configurado
    // Quando implementado, usar GetIt ou Provider para obter ManualSyncService
    _loadSyncStats();
  }

  /// Carrega estatísticas de sincronização
  Future<void> _loadSyncStats() async {
    if (!mounted) return;
    
    setState(() {
      _isLoadingStats = true;
    });

    try {
      // Mock data enquanto serviço não está integrado
      await Future<void>.delayed(const Duration(milliseconds: 500));
      
      if (mounted) {
        setState(() {
          _syncStats = {
            'favoritos_count': 12,
            'comentarios_count': 8,
            'last_sync_text': 'Há 2 horas',
            'can_sync_now': true,
            'sync_service_ready': true,
          };
          _isLoadingStats = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _syncStats = {
            'favoritos_count': 0,
            'comentarios_count': 0,
            'sync_service_ready': false,
            'error': e.toString(),
          };
          _isLoadingStats = false;
        });
      }
    }
  }

  /// Executa sincronização manual
  Future<void> _performManualSync() async {
    if (_syncService == null) {
      _showMessage('Serviço de sincronização não disponível', isError: true);
      return;
    }

    try {
      final result = await _syncService!.performManualSync();
      
      if (result.isSuccess) {
        _showMessage('Sincronização concluída com sucesso!');
        _loadSyncStats(); // Atualizar estatísticas
      } else {
        switch (result.type) {
          case ManualSyncResultType.rateLimited:
            _showMessage(result.message, isError: true);
            break;
          case ManualSyncResultType.alreadyInProgress:
            _showMessage('Sincronização já em andamento');
            break;
          case ManualSyncResultType.error:
            _showMessage('Erro: ${result.message}', isError: true);
            break;
          default:
            _showMessage('Erro desconhecido', isError: true);
        }
      }
    } catch (e) {
      _showMessage('Erro inesperado: $e', isError: true);
    }
  }

  /// Mostra mensagem para o usuário
  void _showMessage(String message, {bool isError = false}) {
    if (!mounted) return;
    
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: isError ? Colors.red : Colors.green,
        duration: Duration(seconds: isError ? 4 : 2),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final authProvider = context.watch<ReceitaAgroAuthProvider>();
    
    // Só mostra seção para usuários autenticados
    if (!authProvider.isAuthenticated || authProvider.isAnonymous) {
      return const SizedBox.shrink();
    }

    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Row(
              children: [
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: SettingsDesignTokens.primaryColor.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Icon(
                    Icons.sync,
                    color: SettingsDesignTokens.primaryColor,
                    size: 20,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Sincronização de Dados',
                        style: theme.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      Text(
                        'Seus favoritos e comentários na nuvem',
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: theme.colorScheme.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            
            const SizedBox(height: 16),
            
            // Status de sincronização
            _buildSyncStatus(),
            
            const SizedBox(height: 16),
            
            // Estatísticas
            _buildSyncStats(),
            
            const SizedBox(height: 16),
            
            // Botão de sincronização
            _buildSyncButton(),
          ],
        ),
      ),
    );
  }

  /// Status da sincronização
  Widget _buildSyncStatus() {
    final theme = Theme.of(context);
    
    if (_syncStats == null || _isLoadingStats) {
      return Row(
        children: [
          const SizedBox(
            width: 16,
            height: 16,
            child: CircularProgressIndicator(strokeWidth: 2),
          ),
          const SizedBox(width: 8),
          Text(
            'Carregando status...',
            style: theme.textTheme.bodySmall,
          ),
        ],
      );
    }

    final hasError = _syncStats!.containsKey('error');
    final lastSync = _syncStats!['last_sync_text'] as String? ?? 'Nunca sincronizado';
    final serviceReady = _syncStats!['sync_service_ready'] as bool? ?? false;

    IconData statusIcon;
    Color statusColor;
    String statusText;

    if (hasError) {
      statusIcon = Icons.error_outline;
      statusColor = Colors.red;
      statusText = 'Erro na sincronização';
    } else if (!serviceReady) {
      statusIcon = Icons.warning_outlined;
      statusColor = Colors.orange;
      statusText = 'Serviço indisponível';
    } else {
      statusIcon = Icons.check_circle_outline;
      statusColor = Colors.green;
      statusText = 'Sincronizado';
    }

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: statusColor.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: statusColor.withValues(alpha: 0.3),
          width: 1,
        ),
      ),
      child: Row(
        children: [
          Icon(statusIcon, color: statusColor, size: 20),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  statusText,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.w500,
                    color: statusColor,
                  ),
                ),
                Text(
                  'Última sincronização: $lastSync',
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  /// Estatísticas de dados sincronizados
  Widget _buildSyncStats() {
    final theme = Theme.of(context);
    
    if (_syncStats == null || _isLoadingStats) {
      return const SizedBox.shrink();
    }

    final favoritosCount = _syncStats!['favoritos_count'] as int? ?? 0;
    final comentariosCount = _syncStats!['comentarios_count'] as int? ?? 0;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: theme.colorScheme.outline.withValues(alpha: 0.3),
          width: 1,
        ),
      ),
      child: Row(
        children: [
          Expanded(
            child: _buildStatItem(
              icon: Icons.favorite_outline,
              label: 'Favoritos',
              count: favoritosCount,
              theme: theme,
            ),
          ),
          Container(
            width: 1,
            height: 40,
            color: theme.colorScheme.outline.withValues(alpha: 0.3),
          ),
          Expanded(
            child: _buildStatItem(
              icon: Icons.comment_outlined,
              label: 'Comentários',
              count: comentariosCount,
              theme: theme,
            ),
          ),
        ],
      ),
    );
  }

  /// Item individual de estatística
  Widget _buildStatItem({
    required IconData icon,
    required String label,
    required int count,
    required ThemeData theme,
  }) {
    return Column(
      children: [
        Icon(
          icon,
          color: SettingsDesignTokens.primaryColor,
          size: 20,
        ),
        const SizedBox(height: 4),
        Text(
          count.toString(),
          style: theme.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.bold,
            color: SettingsDesignTokens.primaryColor,
          ),
        ),
        Text(
          label,
          style: theme.textTheme.bodySmall?.copyWith(
            color: theme.colorScheme.onSurfaceVariant,
          ),
        ),
      ],
    );
  }

  /// Botão de sincronização manual
  Widget _buildSyncButton() {
    final theme = Theme.of(context);
    
    final canSync = _syncStats?['can_sync_now'] as bool? ?? false;
    final isLoading = _currentStatus?.isInProgress ?? false;
    final serviceReady = _syncStats?['sync_service_ready'] as bool? ?? false;

    return SizedBox(
      width: double.infinity,
      child: ElevatedButton.icon(
        onPressed: (canSync && serviceReady && !isLoading) 
            ? _performManualSync 
            : null,
        icon: isLoading 
            ? const SizedBox(
                width: 16,
                height: 16,
                child: CircularProgressIndicator(strokeWidth: 2),
              )
            : const Icon(Icons.sync),
        label: Text(
          isLoading 
              ? 'Sincronizando...'
              : !canSync 
                  ? 'Aguarde para sincronizar'
                  : !serviceReady
                      ? 'Serviço indisponível'
                      : 'Forçar Sincronização',
        ),
        style: ElevatedButton.styleFrom(
          backgroundColor: SettingsDesignTokens.primaryColor,
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(vertical: 12),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
        ),
      ),
    );
  }
}