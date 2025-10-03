# Migration Example: maintenances_provider.dart → maintenances_notifier.dart

## 📁 Arquivos Criados

### 1. **maintenances_state.dart** - Estado Imutável
```dart
class MaintenancesState extends Equatable {
  const MaintenancesState({
    this.maintenances = const [],
    this.filteredMaintenances = const [],
    this.isLoading = false,
    this.errorMessage,
    // ... filters
    this.sortBy = 'serviceDate',
    this.sortAscending = false,
    this.stats = const {},
  });

  // Computed properties
  bool get hasActiveFilters => ...;
  bool get hasData => filteredMaintenances.isNotEmpty;

  // CopyWith pattern
  MaintenancesState copyWith({...}) {...}
  MaintenancesState clearError() {...}
  MaintenancesState clearFilters() {...}
}
```

### 2. **maintenances_notifier.dart** - Riverpod Notifier
```dart
@riverpod
class MaintenancesNotifier extends _$MaintenancesNotifier {
  @override
  MaintenancesState build() {
    _repository = getIt<MaintenanceRepository>();
    _formatter = MaintenanceFormatterService();
    _getVehicleById = getIt<GetVehicleById>();

    _repository.initialize();
    loadMaintenances();

    return const MaintenancesState();
  }

  // CRUD operations
  Future<void> loadMaintenances() async {...}
  Future<bool> addMaintenance(MaintenanceFormModel formModel) async {...}
  Future<bool> updateMaintenance(MaintenanceFormModel formModel) async {...}
  Future<bool> removeMaintenance(String maintenanceId) async {...}

  // Filters
  void filterByVehicle(String? vehicleId) {...}
  void filterByType(MaintenanceType? type) {...}
  void filterByStatus(MaintenanceStatus? status) {...}
  void search(String query) {...}
  void clearFilters() {...}

  // Sorting
  void setSortBy(String field, {bool? ascending}) {...}

  // Reports & Analytics
  Future<Map<String, dynamic>> getMaintenanceReport(String id) async {...}
  Map<String, dynamic> getStatsByPeriod(DateTime start, DateTime end) {...}
}
```

## 🔄 Migração de Uso na UI

### ❌ ANTES (Provider + ChangeNotifier)
```dart
class MaintenancesPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Consumer<MaintenancesProvider>(
      builder: (context, provider, child) {
        if (provider.isLoading) {
          return const Center(child: CircularProgressIndicator());
        }

        if (provider.error != null) {
          return ErrorView(
            message: provider.error!,
            onRetry: provider.loadMaintenances,
          );
        }

        return ListView.builder(
          itemCount: provider.maintenances.length,
          itemBuilder: (context, index) {
            final maintenance = provider.maintenances[index];
            return MaintenanceCard(maintenance: maintenance);
          },
        );
      },
    );
  }
}
```

### ✅ DEPOIS (Riverpod + ConsumerWidget)
```dart
class MaintenancesPage extends ConsumerWidget {
  const MaintenancesPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(maintenancesNotifierProvider);

    if (state.isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (state.hasError) {
      return ErrorView(
        message: state.errorMessage!,
        onRetry: () {
          ref.read(maintenancesNotifierProvider.notifier).refresh();
        },
      );
    }

    if (state.isEmpty) {
      return const EmptyState(message: 'Nenhuma manutenção cadastrada');
    }

    return ListView.builder(
      itemCount: state.filteredMaintenances.length,
      itemBuilder: (context, index) {
        final maintenance = state.filteredMaintenances[index];
        return MaintenanceCard(maintenance: maintenance);
      },
    );
  }
}
```

## 🎯 Exemplos de Uso Específicos

### 1. **Filtros**
```dart
// Filtro por veículo
ElevatedButton(
  onPressed: () {
    ref.read(maintenancesNotifierProvider.notifier)
        .filterByVehicle(vehicleId);
  },
  child: const Text('Filtrar'),
)

// Filtro por status
DropdownButton<MaintenanceStatus>(
  value: state.selectedStatus,
  onChanged: (status) {
    ref.read(maintenancesNotifierProvider.notifier)
        .filterByStatus(status);
  },
  items: MaintenanceStatus.values.map((s) =>
    DropdownMenuItem(value: s, child: Text(s.displayName))
  ).toList(),
)

// Busca de texto
TextField(
  onChanged: (query) {
    ref.read(maintenancesNotifierProvider.notifier).search(query);
  },
  decoration: const InputDecoration(
    hintText: 'Buscar manutenções...',
  ),
)

// Limpar filtros
IconButton(
  icon: const Icon(Icons.clear),
  onPressed: state.hasActiveFilters
      ? () => ref.read(maintenancesNotifierProvider.notifier).clearFilters()
      : null,
)
```

### 2. **Ordenação**
```dart
PopupMenuButton<String>(
  onSelected: (field) {
    ref.read(maintenancesNotifierProvider.notifier)
        .setSortBy(field);
  },
  itemBuilder: (context) => [
    const PopupMenuItem(value: 'serviceDate', child: Text('Data')),
    const PopupMenuItem(value: 'cost', child: Text('Custo')),
    const PopupMenuItem(value: 'type', child: Text('Tipo')),
    const PopupMenuItem(value: 'odometer', child: Text('Odômetro')),
  ],
)
```

### 3. **CRUD Operations**
```dart
// Add
Future<void> _addMaintenance() async {
  final formModel = MaintenanceFormModel.initial(vehicleId, userId);

  final success = await ref
      .read(maintenancesNotifierProvider.notifier)
      .addMaintenance(formModel);

  if (success) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Manutenção adicionada')),
    );
  }
}

// Update
Future<void> _updateMaintenance(MaintenanceEntity maintenance) async {
  final formModel = MaintenanceFormModel.fromMaintenanceEntity(maintenance);

  final success = await ref
      .read(maintenancesNotifierProvider.notifier)
      .updateMaintenance(formModel);

  if (success) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Manutenção atualizada')),
    );
  }
}

// Delete
Future<void> _deleteMaintenance(String id) async {
  final confirmed = await showDialog<bool>(
    context: context,
    builder: (context) => const ConfirmDialog(),
  );

  if (confirmed == true) {
    final success = await ref
        .read(maintenancesNotifierProvider.notifier)
        .removeMaintenance(id);

    if (success) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Manutenção removida')),
      );
    }
  }
}
```

### 4. **Estatísticas**
```dart
class MaintenanceStatsWidget extends ConsumerWidget {
  const MaintenanceStatsWidget({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(maintenancesNotifierProvider);
    final stats = state.stats;

    if (stats.isEmpty) {
      return const SizedBox.shrink();
    }

    return Column(
      children: [
        StatCard(
          label: 'Total de Registros',
          value: stats['totalRecords'].toString(),
        ),
        StatCard(
          label: 'Custo Total',
          value: stats['totalCostFormatted'],
        ),
        StatCard(
          label: 'Custo Médio',
          value: stats['averageCostFormatted'],
        ),
        StatCard(
          label: 'Custo Mensal',
          value: stats['monthlyCostFormatted'],
        ),
        // Status breakdown
        Text('Concluídas: ${stats['completedCount']}'),
        Text('Pendentes: ${stats['pendingCount']}'),
        Text('Em Andamento: ${stats['inProgressCount']}'),
      ],
    );
  }
}
```

### 5. **Relatórios**
```dart
class MaintenanceReportButton extends ConsumerWidget {
  final String maintenanceId;

  const MaintenanceReportButton({
    super.key,
    required this.maintenanceId,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return ElevatedButton(
      onPressed: () async {
        final report = await ref
            .read(maintenancesNotifierProvider.notifier)
            .getMaintenanceReport(maintenanceId);

        if (context.mounted) {
          showDialog(
            context: context,
            builder: (context) => MaintenanceReportDialog(report: report),
          );
        }
      },
      child: const Text('Ver Relatório'),
    );
  }
}
```

## 📊 Comparação de Features

| Feature | Provider (Antes) | Riverpod (Depois) |
|---------|------------------|-------------------|
| **State Management** | ChangeNotifier + notifyListeners() | Immutable State + copyWith() |
| **Loading State** | Manual boolean flags | Built into state |
| **Error Handling** | String? error | String? errorMessage |
| **Filters** | Manual properties + notifyListeners | Immutable state + copyWith |
| **Statistics** | Map<String, dynamic> | Map<String, dynamic> (same) |
| **Computed Props** | Getters no provider | Getters no state |
| **Disposal** | Manual via ChangeNotifier | Auto-dispose (Riverpod) |
| **Testing** | Mock ChangeNotifier | ProviderContainer (no widgets!) |
| **Type Safety** | Runtime errors | Compile-time safety |

## ✅ Vantagens da Migração

1. **Estado Imutável**: Menos bugs, mais previsível
2. **Type Safety**: Erros em compile-time
3. **Auto-dispose**: Sem memory leaks
4. **Testabilidade**: ProviderContainer sem widgets
5. **Computed Properties**: No state (hasActiveFilters, hasData, isEmpty)
6. **Code Generation**: Provider gerado automaticamente
7. **DevTools**: Melhor suporte para debugging

## 🔧 DI (GetIt) - Mantido

```dart
// Injeção via GetIt (mantido igual)
@override
MaintenancesState build() {
  _repository = getIt<MaintenanceRepository>();
  _formatter = MaintenanceFormatterService();
  _getVehicleById = getIt<GetVehicleById>();

  return const MaintenancesState();
}
```

## 📦 Dependências

```yaml
dependencies:
  flutter_riverpod: ^2.6.1
  riverpod_annotation: ^2.6.1

dev_dependencies:
  riverpod_generator: ^2.6.1
  build_runner: ^2.4.6
```

## 🚀 Build Runner

```bash
dart run build_runner build --delete-conflicting-outputs
```

## ✅ Resultado Final

- ✅ **maintenances_state.dart** - Estado imutável com Equatable
- ✅ **maintenances_notifier.dart** - Notifier com @riverpod
- ✅ **maintenances_notifier.g.dart** - Code generation OK
- ✅ **0 analyzer errors** nos arquivos migrados
- ✅ **CRUD completo** (load, add, update, delete)
- ✅ **Filtros** (veículo, tipo, status, período, busca)
- ✅ **Ordenação** (6 campos diferentes)
- ✅ **Estatísticas** calculadas automaticamente
- ✅ **Relatórios** e análises
- ✅ **DI com GetIt** mantido
- ✅ **Padrão Riverpod v2** seguido

---

**Status**: ✅ Migração COMPLETA - Fase 3.3 de 8 concluída!
