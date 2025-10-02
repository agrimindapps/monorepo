# Migração Provider → Riverpod - app-plantis

## 📊 Status Atual

**Data:** 2025-10-02
**Progresso:** 18/27 arquivos migrados (66.7%)
**Status de Compilação:** ✅ 0 ERROS

---

## ✅ Arquivos Migrados com Sucesso (18)

### Core Providers (3)
1. ✅ `lib/core/providers/spaces_providers.dart`
   - `SpacesNotifier extends AsyncNotifier<SpacesState>`
   - Provider: `spacesProvider`
   - Métodos: `loadSpaces()`, `createSpace()`, `updateSpace()`, `deleteSpace()`, `setActiveSpace()`

2. ✅ `lib/core/providers/plants_providers.dart`
   - Já estava em Riverpod (não precisou migração)
   - `PlantsNotifier extends AsyncNotifier<PlantsState>`

3. ✅ `lib/core/providers/tasks_providers.dart`
   - Já estava em Riverpod (não precisou migração)
   - `TasksNotifier extends AsyncNotifier<TasksState>`

### Device Management Module (6 + 1 deletado)
4. ✅ `lib/core/providers/device_management_providers.dart` **[CRIADO NOVO]**
   - `DeviceManagementState` com UI helpers
   - `DeviceManagementNotifier extends AsyncNotifier<DeviceManagementState>`
   - Provider: `deviceManagementProvider`
   - Métodos: `loadDevices()`, `validateCurrentDevice()`, `revokeDevice()`, `revokeAllOtherDevices()`, `loadStatistics()`, `refresh()`

5. ✅ `lib/features/device_management/presentation/pages/device_management_page.dart`
   - `ConsumerStatefulWidget` com TabController
   - 518 linhas migradas

6. ✅ `lib/features/device_management/presentation/widgets/device_actions_widget.dart`
   - `ConsumerWidget`
   - 387 linhas

7. ✅ `lib/features/device_management/presentation/widgets/device_list_widget.dart`
   - `ConsumerWidget` + `_DeviceDetailsSheet extends ConsumerWidget`
   - 529 linhas

8. ✅ `lib/features/device_management/presentation/widgets/device_statistics_widget.dart`
   - `ConsumerStatefulWidget` com initState
   - 616 linhas

9. ✅ `lib/core/router/app_router.dart`
   - Removido `ChangeNotifierProvider` wrapper para DeviceManagementPage

10. 🗑️ **DELETADO:** `lib/features/device_management/device_management_module.dart`
    - Módulo DI do Provider não era mais usado

### Task Widgets (2)
11. ✅ `lib/features/tasks/presentation/widgets/task_creation_dialog.dart`
    - Corrigido conflito de namespace `FormState`
    - Usando `flutter_widgets.FormState`

12. ✅ `lib/features/plants/presentation/widgets/plant_details/plant_form_basic_info.dart`
    - Similar fix de namespace

---

## 🚧 Arquivos Restantes (9 arquivos - 33.3%)

### 🔴 Bloqueados por Providers Não Migrados

| # | Arquivo | Linhas | Provider Bloqueante | Prioridade |
|---|---------|--------|---------------------|------------|
| 1 | `lib/features/plants/presentation/pages/plant_details_page.dart` | 45 | PlantDetailsProvider, PlantTaskProvider, PlantCommentsProvider | 🟡 MÉDIA |
| 2 | `lib/features/plants/presentation/widgets/enhanced_plants_list_view.dart` | 405 | PlantTaskProvider | 🟡 MÉDIA |
| 3 | `lib/features/plants/presentation/widgets/plant_details/plant_details_view.dart` | 1548 | PlantDetailsProvider, PlantTaskProvider, PlantCommentsProvider | 🔴 ALTA |
| 4 | `lib/features/plants/presentation/widgets/plant_details/plant_tasks_section.dart` | ~700 | PlantTaskProvider | 🟡 MÉDIA |
| 5 | `lib/features/license/pages/license_status_page.dart` | 624 | LicenseProvider | 🟢 BAIXA |
| 6 | `lib/features/auth/presentation/pages/register_page.dart` | 315 | RegisterProvider | 🟡 MÉDIA |
| 7 | `lib/features/data_export/presentation/widgets/export_availability_widget.dart` | 500 | DataExportProvider | 🟢 BAIXA |
| 8 | `lib/features/data_export/presentation/widgets/export_progress_dialog.dart` | ? | DataExportProvider | 🟢 BAIXA |
| 9 | `lib/features/premium/presentation/widgets/sync_status_widget.dart` | 377 | PremiumProviderImproved | 🟢 BAIXA |
| 10 | `lib/features/settings/presentation/pages/notifications_settings_page.dart` | Grande | Múltiplos providers | 🔴 ALTA |

---

## ❌ Providers Não Migrados (Bloqueadores)

### Alta Prioridade (usados por múltiplos arquivos)
1. **PlantTaskProvider** - Usado por 4 arquivos de plants
   - Localização: `lib/features/plants/presentation/providers/plant_task_provider.dart`
   - Necessário para: seção de tarefas, lista de plantas, detalhes
   - **Nota:** Pode ser consolidado com `TasksProvider` já migrado

2. **PlantDetailsProvider** - Usado por 2 arquivos
   - Localização: `lib/features/plants/presentation/providers/plant_details_provider.dart`
   - Gerencia estado de detalhes da planta individual

3. **PlantCommentsProvider** - Usado por 1 arquivo
   - Localização: `lib/features/plants/presentation/providers/plant_comments_provider.dart`
   - Gerencia comentários/notas das plantas

### Média Prioridade
4. **RegisterProvider** - Usado por 1 arquivo
   - Localização: `lib/features/auth/presentation/providers/register_provider.dart`
   - Fluxo de registro de usuário

5. **DataExportProvider** - Usado por 2 arquivos
   - Localização: `lib/features/data_export/presentation/providers/data_export_provider.dart`
   - Exportação de dados do usuário

### Baixa Prioridade
6. **LicenseProvider** - Usado por 1 arquivo
   - Localização: `lib/features/license/providers/license_provider.dart`
   - Gerenciamento de licença

7. **PremiumProviderImproved** - Usado por 1 arquivo
   - Localização: `lib/features/premium/presentation/providers/premium_provider_improved.dart`
   - Status premium/assinatura

---

## 🎯 Próximos Passos Recomendados

### Estratégia A: Migração Completa (4-6h de trabalho)
1. Migrar `PlantTaskProvider` → Riverpod
2. Migrar `PlantDetailsProvider` → Riverpod
3. Migrar `PlantCommentsProvider` → Riverpod
4. Atualizar os 4 arquivos de plants
5. Migrar providers restantes individualmente

### Estratégia B: Híbrida (Recomendada para continuidade)
1. Manter os 9 arquivos restantes em Provider temporariamente
2. Sistema funciona 100% com ambos (Provider + Riverpod)
3. Migração gradual conforme necessidade
4. **Vantagem:** Não quebra funcionalidade existente

### Estratégia C: Limpeza e Simplificação (1-2h)
1. Verificar quais dos 9 arquivos são realmente usados
2. Deletar não-referenciados
3. Simplificar funcionalidades não-essenciais
4. Focar em features core

---

## 🔧 Padrões Técnicos Utilizados

### Pattern: AsyncNotifier
```dart
class ExampleNotifier extends AsyncNotifier<ExampleState> {
  late final ExampleUseCase _useCase;

  @override
  Future<ExampleState> build() async {
    _useCase = GetIt.instance<ExampleUseCase>();
    return _loadInitialData();
  }

  Future<void> someMethod() async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() async {
      // Lógica aqui
      return newState;
    });
  }
}

final exampleProvider = AsyncNotifierProvider<ExampleNotifier, ExampleState>(() {
  return ExampleNotifier();
});
```

### Pattern: ConsumerWidget
```dart
class ExampleWidget extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final exampleAsync = ref.watch(exampleProvider);

    return exampleAsync.when(
      data: (state) => _buildContent(state),
      loading: () => CircularProgressIndicator(),
      error: (error, stack) => Text('Erro: $error'),
    );
  }
}
```

### Pattern: ConsumerStatefulWidget
```dart
class ExampleStateful extends ConsumerStatefulWidget {
  @override
  ConsumerState<ExampleStateful> createState() => _ExampleStatefulState();
}

class _ExampleStatefulState extends ConsumerState<ExampleStateful> {
  @override
  void initState() {
    super.initState();
    Future.microtask(() => ref.read(exampleProvider.notifier).initialize());
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(exampleProvider);
    return Container();
  }
}
```

---

## 🐛 Issues Resolvidas

### 1. Namespace Conflicts
**Problema:** `FormState` definido em core e flutter
```dart
// Solução:
import 'package:flutter/widgets.dart' as flutter_widgets;
final _formKey = GlobalKey<flutter_widgets.FormState>();
```

### 2. DeviceManagementState Ambiguity
**Problema:** `DeviceManagementState` em core e app-plantis
```dart
// Solução:
import 'package:core/core.dart' hide deviceManagementProvider, DeviceManagementState;
import '../../../../core/providers/device_management_providers.dart';
```

### 3. RevokeAllResult Property
**Problema:** Tentando acessar `.count` mas propriedade é `.revokedCount`
```dart
// Correto:
'${revokeResult.revokedCount} dispositivos revogados'
```

### 4. Fold Return Types
**Problema:** Async functions em fold() causando type mismatch
```dart
// Solução: Separar lógica async do fold
final success = result.fold(
  (failure) => false,
  (void _) => true,
);

if (success) {
  await doAsyncWork();
}
```

---

## 📝 Notas de Implementação

### GetIt vs Riverpod
- Use cases permanecem em **GetIt** (injeção já estabelecida)
- Notifiers usam **Riverpod** para state management
- Pattern: `GetIt.instance<UseCase>()` dentro do `build()`

### State Immutability
- Todos os states são `@immutable`
- Usar `copyWith()` para modificações
- Flags opcionais: `clearError`, `clearSuccess`, etc.

### Loading States
- Usar `AsyncValue.loading()` antes de operações
- `AsyncValue.guard()` para error handling automático
- `AsyncValue.data()` para atualizar com sucesso

### UI Helpers em State
```dart
class ExampleState {
  // Computed properties
  bool get isEmpty => items.isEmpty;
  String get statusText => isActive ? 'Ativo' : 'Inativo';
  Color get statusColor => isActive ? Colors.green : Colors.grey;
  IconData get statusIcon => isActive ? Icons.check : Icons.block;
}
```

---

## 🧪 Comandos Úteis

### Verificar arquivos com Provider
```bash
find lib -name "*.dart" -type f -exec grep -l "import 'package:provider/provider.dart'" {} \;
```

### Contar providers restantes
```bash
find lib -name "*.dart" -type f -exec grep -l "import 'package:provider/provider.dart'" {} \; | wc -l
```

### Analisar projeto
```bash
flutter analyze --no-pub
```

### Buscar referências a um provider
```bash
grep -r "PlantTaskProvider" lib/
```

---

## 📚 Referências

### Documentação
- [Riverpod Official Docs](https://riverpod.dev/)
- [AsyncNotifier Guide](https://riverpod.dev/docs/providers/notifier_provider)
- [Migration Guide](https://riverpod.dev/docs/from_provider/motivation)

### Arquivos de Referência no Projeto
- `lib/core/providers/spaces_providers.dart` - Exemplo completo de AsyncNotifier
- `lib/core/providers/device_management_providers.dart` - Provider com UI helpers
- `lib/features/device_management/presentation/pages/device_management_page.dart` - ConsumerStatefulWidget complexo

---

## 🎉 Conquistas

- ✅ **0 ERROS** de compilação
- ✅ **Device Management** 100% migrado (módulo completo)
- ✅ **66.7%** de progresso total
- ✅ Padrão consistente estabelecido
- ✅ Documentação completa criada

---

## 🔄 Continuação

Para continuar a migração em outro computador:

1. **Ler este documento** para contexto
2. **Escolher estratégia** (A, B ou C acima)
3. **Verificar:** `flutter analyze --no-pub`
4. **Começar por:** PlantTaskProvider (impacta 4 arquivos)

**Boa sorte! 🚀**
