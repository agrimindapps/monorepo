// screens/offline_settings_screen.dart - Tela de configurações offline

// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

// Project imports:
import '../../../core/services/sync_firebase_service.dart';
import '../providers/sync_provider.dart';

class OfflineSettingsScreen extends StatelessWidget {
  const OfflineSettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Configurações Offline'),
        backgroundColor: Colors.blue,
      ),
      body: Consumer<SyncProvider>(
        builder: (context, syncProvider, child) {
          return SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildConnectionStatus(syncProvider),
                const SizedBox(height: 24),
                _buildOfflineMode(context, syncProvider),
                const SizedBox(height: 24),
                _buildSyncSection(context, syncProvider),
                const SizedBox(height: 24),
                _buildCacheStats(syncProvider),
                const SizedBox(height: 24),
                _buildDataManagement(context, syncProvider),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildConnectionStatus(SyncProvider syncProvider) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Status da Conexão',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Icon(
                  syncProvider.isOnline ? Icons.wifi : Icons.wifi_off,
                  color: syncProvider.isOnline ? Colors.green : Colors.red,
                ),
                const SizedBox(width: 8),
                Text(
                  syncProvider.isOnline ? 'Online' : 'Offline',
                  style: TextStyle(
                    color: syncProvider.isOnline ? Colors.green : Colors.red,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
            if (syncProvider.lastSyncTime != null) ...[
              const SizedBox(height: 8),
              Text(
                'Última sincronização: ${_formatDateTime(syncProvider.lastSyncTime!)}',
                style: TextStyle(color: Colors.grey[600], fontSize: 12),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildOfflineMode(BuildContext context, SyncProvider syncProvider) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Modo Offline',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            const Text(
              'No modo offline, todas as mudanças são salvas localmente e sincronizadas quando voltar online.',
              style: TextStyle(color: Colors.grey),
            ),
            const SizedBox(height: 16),
            SwitchListTile(
              title: const Text('Ativar Modo Offline'),
              subtitle: Text(
                syncProvider.isOfflineMode
                    ? 'Dados salvos apenas localmente'
                    : 'Sincronização automática ativada',
              ),
              value: syncProvider.isOfflineMode,
              onChanged: (value) => syncProvider.toggleOfflineMode(value),
              contentPadding: EdgeInsets.zero,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSyncSection(BuildContext context, SyncProvider syncProvider) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Sincronização',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),

            // Status da sincronização
            _buildSyncStatus(syncProvider),
            const SizedBox(height: 16),

            // Itens pendentes
            if (syncProvider.pendingSyncItems > 0) ...[
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.orange[50],
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.orange[200]!),
                ),
                child: Row(
                  children: [
                    Icon(Icons.sync_problem, color: Colors.orange[700]),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        '${syncProvider.pendingSyncItems} itens aguardando sincronização',
                        style: TextStyle(color: Colors.orange[700]),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
            ],

            // Botão de sincronização
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: syncProvider.isOnline &&
                        syncProvider.syncStatus != SyncStatus.syncing
                    ? () => syncProvider.syncAll()
                    : null,
                icon: syncProvider.syncStatus == SyncStatus.syncing
                    ? const SizedBox(
                        width: 16,
                        height: 16,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Icon(Icons.sync),
                label: Text(
                  syncProvider.syncStatus == SyncStatus.syncing
                      ? 'Sincronizando...'
                      : 'Sincronizar Agora',
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSyncStatus(SyncProvider syncProvider) {
    Color statusColor;
    IconData statusIcon;
    String statusText;

    switch (syncProvider.syncStatus) {
      case SyncStatus.offline:
        statusColor = Colors.grey;
        statusIcon = Icons.sync_disabled;
        statusText = 'Offline';
        break;
      case SyncStatus.localOnly:
        statusColor = Colors.orange;
        statusIcon = Icons.cloud_off;
        statusText = 'Apenas Local';
        break;
      case SyncStatus.syncing:
        statusColor = Colors.blue;
        statusIcon = Icons.sync;
        statusText = 'Sincronizando...';
        break;
    }

    return Row(
      children: [
        Icon(statusIcon, color: statusColor),
        const SizedBox(width: 8),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                statusText,
                style: TextStyle(
                  color: statusColor,
                  fontWeight: FontWeight.w500,
                ),
              ),
              if (syncProvider.errorMessage != null) ...[
                const SizedBox(height: 4),
                Text(
                  syncProvider.errorMessage!,
                  style: const TextStyle(
                    color: Colors.red,
                    fontSize: 12,
                  ),
                ),
              ],
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildCacheStats(SyncProvider syncProvider) {
    final stats = syncProvider.getCacheStats();

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Estatísticas do Cache',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            ...stats.entries.map((entry) {
              String label;
              switch (entry.key) {
                case 'tasks':
                  label = 'Tarefas em cache';
                  break;
                case 'taskLists':
                  label = 'Listas em cache';
                  break;
                case 'users':
                  label = 'Usuários em cache';
                  break;
                case 'pendingSync':
                  label = 'Itens pendentes';
                  break;
                case 'unsyncedTasks':
                  label = 'Tarefas não sincronizadas';
                  break;
                case 'unsyncedLists':
                  label = 'Listas não sincronizadas';
                  break;
                default:
                  label = entry.key;
              }

              return Padding(
                padding: const EdgeInsets.symmetric(vertical: 4),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(label),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 2,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.blue[100],
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        entry.value.toString(),
                        style: TextStyle(
                          color: Colors.blue[700],
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
              );
            }),
          ],
        ),
      ),
    );
  }

  Widget _buildDataManagement(BuildContext context, SyncProvider syncProvider) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Gerenciamento de Dados',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: OutlinedButton.icon(
                onPressed: () => _showClearCacheDialog(context, syncProvider),
                icon: const Icon(Icons.clear_all, color: Colors.red),
                label: const Text(
                  'Limpar Cache Local',
                  style: TextStyle(color: Colors.red),
                ),
                style: OutlinedButton.styleFrom(
                  side: const BorderSide(color: Colors.red),
                ),
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'Atenção: Isso removerá todos os dados salvos localmente. '
              'Certifique-se de que tudo foi sincronizado antes.',
              style: TextStyle(
                color: Colors.grey,
                fontSize: 12,
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showClearCacheDialog(BuildContext context, SyncProvider syncProvider) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Limpar Cache'),
        content: const Text(
          'Tem certeza que deseja limpar todo o cache local?\n\n'
          'Todos os dados não sincronizados serão perdidos.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancelar'),
          ),
          TextButton(
            onPressed: () async {
              Navigator.of(context).pop();
              await syncProvider.clearAllData();
              if (context.mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Cache limpo com sucesso!'),
                  ),
                );
              }
            },
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Limpar'),
          ),
        ],
      ),
    );
  }

  String _formatDateTime(DateTime dateTime) {
    final now = DateTime.now();
    final difference = now.difference(dateTime);

    if (difference.inMinutes < 1) {
      return 'Agora mesmo';
    } else if (difference.inHours < 1) {
      return '${difference.inMinutes} min atrás';
    } else if (difference.inDays < 1) {
      return '${difference.inHours} h atrás';
    } else {
      return DateFormat('dd/MM/yyyy HH:mm').format(dateTime);
    }
  }
}
