# Sistema de Sincronização Offline-First

Sistema completo de sincronização offline-first implementado no app-gasometer, baseado na arquitetura do app-plantas.

## Arquitetura

### Componentes Principais

1. **SyncQueue** - Gerencia fila de operações offline
2. **SyncOperations** - Processa operações com awareness de rede
3. **ConflictResolver** - Resolve conflitos entre dados local/remoto
4. **SyncService** - Orquestra todo o sistema de sincronização
5. **SyncStatusProvider** - Gerencia estado da UI

### Modelos e Interfaces

- **SyncQueueItem** - Item da fila com retry logic
- **ConflictData** - Dados de conflito com timestamps e versões
- **BaseSyncModel** - Modelo base para entidades sincronizáveis
- **ConflictResolutionStrategy** - Estratégias de resolução de conflitos

## Como Usar

### 1. Inicialização

O sistema é inicializado automaticamente no `main.dart`:

```dart
// No main.dart
final syncService = sl<SyncService>();
await syncService.initialize();
```

### 2. Adicionando Item à Fila

```dart
// Exemplo de uso em um repository
final syncService = sl<SyncService>();

await syncService.addToSyncQueue(
  modelType: 'VehicleModel',
  operation: SyncOperationType.create,
  data: vehicle.toJson(),
  userId: currentUser.id,
  priority: 1,
);
```

### 3. Provider para UI

```dart
// No widget tree
ChangeNotifierProvider(
  create: (context) => sl<SyncStatusProvider>(),
  child: MyApp(),
)

// Em um widget
Consumer<SyncStatusProvider>(
  builder: (context, syncProvider, child) {
    return SyncStatusWidget(
      showDetails: true,
      onTap: () => syncProvider.forceSyncNow(),
    );
  },
)
```

### 4. Widget de Status

```dart
// Widget completo de status
SyncStatusWidget(
  showDetails: true,
  onTap: () {
    // Ação ao tocar
  },
)

// Indicador compacto
SyncStatusIndicator(size: 24)
```

## Integração com Repositories

### Exemplo: Vehicle Repository

```dart
class VehicleRepositoryImpl implements VehicleRepository {
  final VehicleLocalDataSource localDataSource;
  final VehicleRemoteDataSource remoteDataSource;
  final SyncService syncService;

  @override
  Future<Either<Failure, Vehicle>> addVehicle(Vehicle vehicle) async {
    try {
      // 1. Salva localmente primeiro
      final localVehicle = await localDataSource.addVehicle(vehicle);
      
      // 2. Adiciona à fila de sincronização
      await syncService.addToSyncQueue(
        modelType: 'VehicleModel',
        operation: SyncOperationType.create,
        data: localVehicle.toJson(),
        userId: vehicle.userId,
        priority: 1,
      );
      
      return Right(localVehicle);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }
}
```

## Recursos Implementados

### ✅ Funcionalidades Principais

- [x] Fila persistente com Hive (TypeId: 100)
- [x] Retry automático com backoff exponencial
- [x] Awareness de conectividade de rede
- [x] Processamento por prioridades (Create > Update > Delete)
- [x] Resolução de conflitos com múltiplas estratégias
- [x] Stream-based status updates
- [x] Sincronização automática periódica (5 min)
- [x] Provider para gerenciamento de estado da UI
- [x] Widgets prontos para exibir status
- [x] Analytics integrado para monitoramento
- [x] Limpeza automática de itens sincronizados

### 📊 Estatísticas e Monitoramento

```dart
// Obtém estatísticas completas
final stats = syncService.getSyncStats();
/*
{
  'status': 'idle',
  'is_initialized': true,
  'auto_sync_enabled': true,
  'total': 5,
  'pending': 2,
  'synced': 3,
  'failed': 0,
  'retrying': 0,
  'current_status': 'wifi',
  'is_online': true,
  'is_processing_sync': false,
}
*/

// Monitora em tempo real
syncService.statusStream.listen((status) {
  print('Status: ${status.name}');
});

syncService.messageStream.listen((message) {
  print('Message: $message');
});
```

### 🔄 Estratégias de Conflito

1. **localWins** - Dados locais sempre ganham
2. **remoteWins** - Dados remotos sempre ganham
3. **newerWins** - Timestamp mais recente ganha
4. **versionWins** - Maior número de versão ganha
5. **merge** - Combina dados inteligentemente
6. **custom** - Lógica personalizada por tipo
7. **manual** - Resolução manual pelo usuário (TODO)

### 🔧 Configurações Avançadas

```dart
// Para sincronização automática
syncService.stopAutoSync(); // Para auto-sync
syncService._startAutoSync(); // Reinicia auto-sync

// Limpeza da fila
await syncService.clearSyncedItems(); // Remove sincronizados
await syncService.clearFailedItems(); // Remove falhados
await syncService.clearSyncQueue(); // Remove todos

// Força sincronização
await syncService.forceSyncNow();
```

## Arquivos Criados

### Core Sync
- `lib/core/sync/models/sync_queue_item.dart` - Item da fila
- `lib/core/sync/models/conflict_data.dart` - Dados de conflito
- `lib/core/sync/strategies/conflict_resolution_strategy.dart` - Estratégias
- `lib/core/sync/interfaces/i_sync_repository.dart` - Interface repository
- `lib/core/sync/interfaces/i_conflict_resolver.dart` - Interface resolver
- `lib/core/sync/services/sync_queue.dart` - Gerenciador da fila
- `lib/core/sync/services/conflict_resolver.dart` - Resolvedor de conflitos
- `lib/core/sync/services/sync_operations.dart` - Operações de sync
- `lib/core/sync/services/sync_service.dart` - Orquestrador principal

### UI Components  
- `lib/core/sync/presentation/providers/sync_status_provider.dart` - Provider
- `lib/core/sync/presentation/widgets/sync_status_widget.dart` - Widgets UI

### Base Models
- `lib/core/data/models/base_sync_model.dart` - Modelo base para sync

## Próximos Passos

### 🚧 TODOs Técnicos

1. **Integração com Repositories Reais**
   - Conectar SyncOperations com VehicleRepository
   - Conectar SyncOperations com FuelRepository
   - Conectar SyncOperations com MaintenanceRepository

2. **Conflitos Manuais**
   - Implementar UI para resolução manual
   - Criar sistema de notificações para conflitos

3. **Melhorias de Performance**
   - Batch operations para múltiplos itens
   - Compressão de dados na fila
   - Otimização de queries Hive

4. **Monitoramento Avançado**
   - Métricas de performance do sync
   - Dashboard de status do sync
   - Alertas para problemas persistentes

### 📱 Integração na UI

O sistema já está pronto para ser usado em qualquer parte do app:

```dart
// Em um AppBar
AppBar(
  actions: [
    SyncStatusIndicator(),
  ],
)

// Em uma página de configurações
SyncStatusWidget(
  showDetails: true,
  onTap: () => Navigator.push(context, SyncSettingsPage()),
)

// Em um drawer
ListTile(
  leading: SyncStatusIndicator(size: 20),
  title: Text('Sincronização'),
  subtitle: Consumer<SyncStatusProvider>(
    builder: (context, provider, _) => Text(provider.friendlyMessage),
  ),
)
```

## Dependências

O sistema utiliza as seguintes dependências já existentes no projeto:

- `hive` / `hive_flutter` - Armazenamento local persistente
- `connectivity_plus` - Monitoramento de conectividade
- `injectable` / `get_it` - Injeção de dependência
- `provider` - Gerenciamento de estado da UI
- `uuid` - Geração de IDs únicos

## Considerações de Performance

- ✅ Operações assíncronas não bloqueantes
- ✅ Processamento em background
- ✅ Debounce de 2s para evitar spam de sync
- ✅ Limit de 3 tentativas com backoff exponencial  
- ✅ Cleanup automático de itens antigos
- ✅ Índices otimizados no Hive para busca rápida

## Segurança

- ✅ Dados sensíveis não são logados
- ✅ Fila persistente criptografada pelo Hive
- ✅ Validação de dados antes da sincronização
- ✅ Timeout configurável para operações de rede
- ✅ Retry logic previne loops infinitos