import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../core/providers/realtime_sync_provider.dart';
import '../core/services/plantis_realtime_service.dart';
import '../core/widgets/sync_status_widget.dart';
import '../features/plants/domain/entities/plant.dart' as domain;
import '../features/plants/domain/usecases/add_plant_usecase.dart';
import '../features/plants/presentation/providers/plants_provider.dart';

/// Exemplo de como integrar e usar o sistema de real-time sync
/// Este arquivo serve como documentação e teste do sistema implementado
class RealtimeSyncExample extends StatefulWidget {
  const RealtimeSyncExample({super.key});

  @override
  State<RealtimeSyncExample> createState() => _RealtimeSyncExampleState();
}

class _RealtimeSyncExampleState extends State<RealtimeSyncExample> {
  @override
  void initState() {
    super.initState();
    _initializeRealtimeSync();
  }

  /// Inicializa o sistema de real-time sync
  Future<void> _initializeRealtimeSync() async {
    try {
      // O PlantisRealtimeService já é inicializado automaticamente
      // pelo RealtimeSyncProvider, mas você pode fazer verificações aqui

      final debugInfo = PlantisRealtimeService.instance.getDebugInfo();
      debugPrint('Real-time sync inicializado: $debugInfo');
    } catch (e) {
      debugPrint('Erro ao inicializar real-time sync: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Real-time Sync Example'),
        actions: const [
          // Widget de status na AppBar
          Padding(
            padding: EdgeInsets.only(right: 16.0),
            child: AppBarSyncStatus(),
          ),
        ],
      ),
      body: Column(
        children: [
          // Card de controle do real-time sync
          _buildSyncControlCard(),

          // Lista de plantas com real-time updates
          Expanded(
            child: _buildPlantsListWithRealtime(),
          ),
        ],
      ),
      floatingActionButton: _buildFloatingActionButtons(),
    );
  }

  /// Card com controles de sincronização
  Widget _buildSyncControlCard() {
    return Consumer<RealtimeSyncProvider>(
      builder: (context, syncProvider, child) {
        return Card(
          margin: const EdgeInsets.all(16),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Row(
                  children: [
                    Icon(Icons.sync, color: Colors.blue),
                    SizedBox(width: 8),
                    Text(
                      'Controle de Sincronização',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Spacer(),
                    SyncStatusIndicator(),
                  ],
                ),
                const SizedBox(height: 16),

                // Status atual
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.grey[100],
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        syncProvider.isRealtimeActive ? Icons.speed : Icons.schedule,
                        color: syncProvider.isRealtimeActive ? Colors.green : Colors.orange,
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(syncProvider.statusMessage),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 16),

                // Botões de ação
                Row(
                  children: [
                    ElevatedButton.icon(
                      onPressed: syncProvider.isOnline ? () => syncProvider.toggleRealtimeSync() : null,
                      icon: Icon(syncProvider.isRealtimeActive ? Icons.pause : Icons.play_arrow),
                      label: Text(syncProvider.isRealtimeActive ? 'Desativar' : 'Ativar'),
                    ),
                    const SizedBox(width: 8),
                    ElevatedButton.icon(
                      onPressed: syncProvider.isOnline ? () => syncProvider.forceSync() : null,
                      icon: const Icon(Icons.refresh),
                      label: const Text('Sync Manual'),
                    ),
                  ],
                ),

                // Informações de debug (apenas em debug mode)
                if (kDebugMode) ...[
                  const SizedBox(height: 16),
                  _buildDebugInfo(syncProvider),
                ],
              ],
            ),
          ),
        );
      },
    );
  }

  /// Informações de debug para desenvolvimento
  Widget _buildDebugInfo(RealtimeSyncProvider syncProvider) {
    return ExpansionTile(
      title: const Text('Debug Info'),
      leading: const Icon(Icons.bug_report),
      children: [
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: Colors.grey[200],
            borderRadius: BorderRadius.circular(4),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Real-time ativo: ${syncProvider.isRealtimeActive}'),
              Text('Online: ${syncProvider.isOnline}'),
              Text('Status: ${syncProvider.currentSyncStatus.name}'),
              Text('Mudanças pendentes: ${syncProvider.pendingChanges}'),
              Text('Última sincronização: ${syncProvider.lastSyncTime?.toString() ?? 'N/A'}'),
              const SizedBox(height: 8),

              // Botão para mostrar debug completo
              ElevatedButton(
                onPressed: () => _showFullDebugInfo(context, syncProvider),
                child: const Text('Debug Completo'),
              ),
            ],
          ),
        ),
      ],
    );
  }

  /// Lista de plantas com atualizações em tempo real
  Widget _buildPlantsListWithRealtime() {
    return Consumer<PlantsProvider>(
      builder: (context, plantsProvider, child) {
        if (plantsProvider.isLoading && plantsProvider.plants.isEmpty) {
          return const Center(
            child: CircularProgressIndicator(),
          );
        }

        if (plantsProvider.error != null) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.error, size: 64, color: Colors.red),
                const SizedBox(height: 16),
                Text(
                  plantsProvider.error!,
                  textAlign: TextAlign.center,
                  style: const TextStyle(color: Colors.red),
                ),
                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: () => plantsProvider.refreshPlants(),
                  child: const Text('Tentar Novamente'),
                ),
              ],
            ),
          );
        }

        if (plantsProvider.plants.isEmpty) {
          return const Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.local_florist, size: 64, color: Colors.grey),
                SizedBox(height: 16),
                Text(
                  'Nenhuma planta encontrada',
                  style: TextStyle(color: Colors.grey, fontSize: 16),
                ),
                SizedBox(height: 8),
                Text(
                  'Adicione uma planta para ver a sincronização em ação!',
                  style: TextStyle(color: Colors.grey),
                ),
              ],
            ),
          );
        }

        return RefreshIndicator(
          onRefresh: () => plantsProvider.refreshPlants(),
          child: ListView.builder(
            itemCount: plantsProvider.plants.length,
            itemBuilder: (context, index) {
              final plant = plantsProvider.plants[index] as domain.Plant;
              return Card(
                margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                child: ListTile(
                  leading: CircleAvatar(
                    backgroundColor: Colors.green,
                    child: Text(
                      plant.name.isNotEmpty ? plant.name[0].toUpperCase() : 'P',
                      style: const TextStyle(color: Colors.white),
                    ),
                  ),
                  title: Text(plant.name),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      if (plant.species?.isNotEmpty == true)
                        Text(plant.species!),
                      Text(
                        'Atualizada: ${_formatDateTime(plant.updatedAt ?? plant.createdAt ?? DateTime.now())}',
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey[600],
                        ),
                      ),
                    ],
                  ),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // Indicador de sync pendente
                      if (plant.isDirty) // Mostra laranja se precisa sync
                        Container(
                          width: 8,
                          height: 8,
                          decoration: const BoxDecoration(
                            shape: BoxShape.circle,
                            color: Colors.orange, // Laranja = pendente sync
                          ),
                        ),
                      const SizedBox(width: 8),
                      const Icon(Icons.chevron_right),
                    ],
                  ),
                  onTap: () => _showPlantDetails(context, plant),
                ),
              );
            },
          ),
        );
      },
    );
  }

  /// Botões de ação flutuantes
  Widget _buildFloatingActionButtons() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        // Botão para adicionar planta de teste
        if (kDebugMode)
          FloatingActionButton(
            heroTag: 'test_plant',
            onPressed: _addTestPlant,
            backgroundColor: Colors.orange,
            child: const Icon(Icons.add),
          ),
        const SizedBox(height: 16),

        // Botão para mostrar status de sync
        FloatingActionButton(
          heroTag: 'sync_status',
          onPressed: _showSyncStatus,
          child: const Icon(Icons.sync),
        ),
      ],
    );
  }

  /// Adiciona uma planta de teste para demonstrar o real-time sync
  Future<void> _addTestPlant() async {
    final plantsProvider = Provider.of<PlantsProvider>(context, listen: false);

    try {
      // Criar uma planta de teste
      final success = await plantsProvider.addPlant(
        const AddPlantParams(
          name: 'Planta Teste',
          species: 'Plantis Testicus',
          notes: 'Planta criada para testar sincronização em tempo real',
        ),
      );

      if (mounted) {
        if (success) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Planta de teste adicionada! Observe a sincronização em ação.'),
              backgroundColor: Colors.green,
            ),
          );
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Erro ao adicionar planta: ${plantsProvider.error}'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Erro inesperado: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  /// Mostra detalhes do status de sincronização
  void _showSyncStatus() {
    final syncProvider = Provider.of<RealtimeSyncProvider>(context, listen: false);
    showDialog<void>(
      context: context,
      builder: (context) => SyncDetailsDialog(syncProvider: syncProvider),
    );
  }

  /// Mostra informações completas de debug
  void _showFullDebugInfo(BuildContext context, RealtimeSyncProvider syncProvider) {
    final debugInfo = syncProvider.getDebugInfo();

    showDialog<void>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Debug Info Completo'),
        content: SingleChildScrollView(
          child: Text(
            debugInfo.toString(),
            style: const TextStyle(fontFamily: 'monospace', fontSize: 12),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Fechar'),
          ),
        ],
      ),
    );
  }

  /// Mostra detalhes de uma planta
  void _showPlantDetails(BuildContext context, domain.Plant plant) {
    showDialog<void>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(plant.name),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (plant.species?.isNotEmpty == true)
              Text('Espécie: ${plant.species}'),
            Text('ID: ${plant.id}'),
            Text('Criada: ${_formatDateTime(plant.createdAt ?? DateTime.now())}'),
            Text('Atualizada: ${_formatDateTime(plant.updatedAt ?? DateTime.now())}'),
            if (plant.notes?.isNotEmpty == true) ...[
              const SizedBox(height: 8),
              Text('Notas: ${plant.notes}'),
            ],
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Fechar'),
          ),
        ],
      ),
    );
  }

  String _formatDateTime(DateTime dateTime) {
    return '${dateTime.day}/${dateTime.month}/${dateTime.year} '
           '${dateTime.hour}:${dateTime.minute.toString().padLeft(2, '0')}';
  }
}

/// Widget de teste para demonstrar múltiplas instâncias
class MultiInstanceTestWidget extends StatelessWidget {
  const MultiInstanceTestWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Teste Múltiplas Instâncias'),
        actions: const [AppBarSyncStatus()],
      ),
      body: const Padding(
        padding: EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Teste de Múltiplas Instâncias',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 16),
            Text(
              'Para testar a sincronização em tempo real com múltiplas instâncias:',
              style: TextStyle(fontSize: 16),
            ),
            SizedBox(height: 16),
            Text('1. Abra este app em dois dispositivos ou emuladores'),
            Text('2. Faça login com a mesma conta em ambos'),
            Text('3. Ative o real-time sync em ambos (deve estar ativo por padrão)'),
            Text('4. Adicione, edite ou delete uma planta em um dispositivo'),
            Text('5. Observe as mudanças aparecerem automaticamente no outro'),
            SizedBox(height: 16),
            Text(
              'Indicadores a observar:',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            Text('• Status "Real-time" no widget de sync'),
            Text('• Notificações de sync nos eventos recentes'),
            Text('• Updates automáticos na lista de plantas'),
            Text('• Contadores de mudanças pendentes'),
            SizedBox(height: 16),
            Text(
              'Teste de conectividade:',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            Text('• Desconecte a internet em um dispositivo'),
            Text('• Faça mudanças offline'),
            Text('• Reconecte e observe a sincronização automática'),
          ],
        ),
      ),
    );
  }
}