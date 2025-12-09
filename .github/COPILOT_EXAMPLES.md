# 💡 Exemplos Práticos - GitHub Copilot

Exemplos reais de como usar os recursos do GitHub Copilot no dia a dia do desenvolvimento do monorepo.

## 📑 Índice

1. [Implementação de Features](#-implementação-de-features)
2. [Resolução de Bugs](#-resolução-de-bugs)
3. [Testes e TDD](#-testes-e-tdd)
4. [Refatoração](#-refatoração)
5. [Migração Riverpod](#-migração-riverpod)
6. [Performance](#-performance)
7. [Documentação](#-documentação)
8. [Cross-App Features](#-cross-app-features)

---

## 🏗️ Implementação de Features

### Exemplo 1: Sistema de Favoritos (Feature Simples)

**Cenário:** Adicionar sistema de favoritos ao app-plantis

**Workflow:**

#### Passo 1: Planejamento
```
@flutter-architect

Preciso implementar um sistema de favoritos em app-plantis onde:
- Usuários podem favoritar plantas
- Lista de favoritos sincroniza com Firebase
- Cache local com Drift
- Ícone de favorito nas plant cards
- Tela dedicada para favoritos

Como estruturar seguindo Clean Architecture?
```

**Resposta esperada do agente:**
- Estrutura de pastas (domain/data/presentation)
- Entidades e interfaces
- Use cases necessários
- Strategy de cache

---

#### Passo 2: Implementação

```
[Prompt: implementar_feature_completa]

Nome da Feature: Sistema de Favoritos
App Target: app-plantis
Descrição: Permite usuários marcarem plantas como favoritas com sincronização Firebase
Complexidade: Média
Cross-App: N
```

**Resultado:** Copilot gera toda a estrutura:

```
lib/features/favorites/
├── domain/
│   ├── entities/
│   │   └── favorite.dart
│   ├── repositories/
│   │   └── favorite_repository.dart
│   └── usecases/
│       ├── add_favorite.dart
│       ├── remove_favorite.dart
│       ├── get_favorites.dart
│       └── is_favorite.dart
├── data/
│   ├── models/
│   │   └── favorite_model.dart
│   ├── datasources/
│   │   ├── favorite_local_datasource.dart
│   │   └── favorite_remote_datasource.dart
│   └── repositories/
│       └── favorite_repository_impl.dart
└── presentation/
    ├── providers/
    │   └── favorite_provider.dart
    ├── pages/
    │   └── favorites_page.dart
    └── widgets/
        ├── favorite_button.dart
        └── favorite_card.dart
```

---

#### Passo 3: Testes

```
[Chat Mode: Testing & TDD]

Criar testes unitários completos para:
1. GetFavorites use case
2. AddFavorite use case
3. RemoveFavorite use case
4. FavoriteRepositoryImpl

Requisitos:
- Mocktail para mocks
- Arrange-Act-Assert
- Casos de sucesso e falha
- Cache fallback tests
```

**Resultado:** Copilot gera testes:

```dart
// test/features/favorites/domain/usecases/get_favorites_test.dart
import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

class MockFavoriteRepository extends Mock implements FavoriteRepository {}

void main() {
  late GetFavorites usecase;
  late MockFavoriteRepository mockRepository;

  setUp(() {
    mockRepository = MockFavoriteRepository();
    usecase = GetFavorites(mockRepository);
  });

  const tUserId = 'user-123';
  final tFavorites = [
    Favorite(
      id: '1',
      userId: tUserId,
      plantId: 'plant-1',
      createdAt: DateTime(2024, 1, 1),
    ),
  ];

  group('GetFavorites', () {
    test('should return list of favorites when repository succeeds', () async {
      // Arrange
      when(() => mockRepository.getFavorites(any()))
          .thenAnswer((_) async => Right(tFavorites));

      // Act
      final result = await usecase(tUserId);

      // Assert
      expect(result, Right(tFavorites));
      verify(() => mockRepository.getFavorites(tUserId)).called(1);
      verifyNoMoreInteractions(mockRepository);
    });

    test('should return CacheFailure when repository fails', () async {
      // Arrange
      final tFailure = CacheFailure('No cached favorites');
      when(() => mockRepository.getFavorites(any()))
          .thenAnswer((_) async => Left(tFailure));

      // Act
      final result = await usecase(tUserId);

      // Assert
      expect(result, Left(tFailure));
      verify(() => mockRepository.getFavorites(tUserId)).called(1);
    });
  });
}
```

---

#### Passo 4: Validação

```bash
# Build runner (gerar código Riverpod)
dart run build_runner build --delete-conflicting-outputs

# Analyzer
flutter analyze
# ✅ No issues found!

# Testes
flutter test
# ✅ All tests passed!

# Coverage
flutter test --coverage
# ✅ 85% coverage
```

---

### Exemplo 2: Sistema de Notificações (Feature Cross-App)

**Cenário:** Implementar notificações push para 3 apps

**Workflow:**

```
[Chat Mode: Monorepo Orchestrator]

Implementar sistema de notificações push que será usado em:
- app-plantis: Lembretes de rega
- app-gasometer: Manutenção de veículo
- app-petiveti: Consultas veterinárias

Requisitos:
- FCM (Firebase Cloud Messaging)
- Local notifications
- Scheduling
- Deep links
- Shared service no core package
```

**Resposta do Copilot:**

1. **Criar service compartilhado:**
```
[Prompt: criar_package_compartilhado]
Nome: notifications_service
Descrição: Service para notificações push e locais
Apps: app-plantis, app-gasometer, app-petiveti
```

2. **Estrutura gerada:**
```
packages/core/lib/notifications/
├── notification_service.dart          # Interface
├── fcm_notification_service.dart      # FCM implementation
├── local_notification_service.dart    # Local notifications
├── notification_scheduler.dart        # Scheduling
└── models/
    ├── notification.dart
    └── notification_payload.dart
```

3. **Implementação por app:**
```dart
// app-plantis/lib/features/plants/domain/usecases/schedule_watering_reminder.dart
class ScheduleWateringReminder {
  final NotificationService notificationService;
  
  Future<void> call(Plant plant) async {
    await notificationService.scheduleNotification(
      id: plant.id,
      title: 'Time to water ${plant.name}!',
      body: 'Don\'t forget to water your ${plant.species}',
      scheduledDate: plant.nextWateringDate,
      payload: {'plantId': plant.id, 'action': 'water'},
    );
  }
}
```

---

## 🐛 Resolução de Bugs

### Exemplo 3: Null Pointer Exception

**Cenário:** App crashando ao carregar lista de plantas

**Stack trace:**
```
══╡ EXCEPTION CAUGHT BY WIDGETS LIBRARY ╞═══════════════════════════════════════════════════════════
The following _CastError was thrown building PlantsList(dirty):
Null check operator used on a null value

The relevant error-causing widget was:
  PlantsList
```

**Workflow:**

```
[Chat Mode: Debugging Expert]

App crashando ao carregar lista de plantas.

Stack trace:
[colar stack trace completo aqui]

Código relevante:
[colar PlantsList widget]

Passos para reproduzir:
1. Abrir app
2. Navegar para "Minhas Plantas"
3. Crash imediato
```

**Análise do Copilot:**
```
ANÁLISE:
O erro ocorre porque o widget está usando null check operator (!)
em um valor que pode ser null.

CAUSA RAIZ:
Linha 45: final plant = plants[index]!;

O problema é que plants é um List<Plant?> mas está sendo tratado
como List<Plant>. Quando há um null na lista, o ! causa crash.

SOLUÇÃO:
1. Filtrar nulls antes de usar:
   final nonNullPlants = plants.whereType<Plant>().toList();

2. OU garantir que lista nunca tenha nulls no repository:
   return plants.where((p) => p != null).cast<Plant>().toList();

3. OU usar safe navigation:
   if (plants[index] != null) {
     final plant = plants[index]!;
     // ...
   }

RECOMENDAÇÃO:
Opção 2 é a melhor - garantir integridade de dados no repository.
```

**Correção:**
```
@flutter-code-fixer

Aplicar solução no repository:
[colar código do repository]

Garantir que getFavorites() nunca retorna lista com nulls.
```

**Teste de regressão:**
```
[Chat Mode: Testing & TDD]

Criar teste de regressão para garantir que repository nunca retorna nulls:

test('should filter out null values from database', () async {
  // Arrange
  when(() => localDataSource.getPlants())
      .thenAnswer((_) async => [plant1, null, plant2]);
  
  // Act
  final result = await repository.getPlants();
  
  // Assert
  result.fold(
    (failure) => fail('Should succeed'),
    (plants) {
      expect(plants.length, 2);
      expect(plants.any((p) => p == null), false);
    },
  );
});
```

---

### Exemplo 4: Memory Leak

**Cenário:** App ficando lento após uso prolongado

```
[Chat Mode: Performance Optimizer]

App-plantis ficando cada vez mais lento após 10-15 minutos de uso.
DevTools mostra aumento constante de memória.
Widgets rebuilding múltiplas vezes.

Suspeita: Stream listeners não sendo descartados.
```

**Análise do Copilot:**
```
DIAGNÓSTICO:
1. Verificar providers sem autoDispose
2. Checar StreamSubscriptions não canceladas
3. Validar listeners de animations

AÇÕES:
1. Rodar Memory Profiler no DevTools
2. Procurar por:
   - Providers que deveriam ser autoDispose
   - StreamControllers não fechados
   - AnimationControllers não disposed
```

**Correção:**
```dart
// ANTES: ❌
@riverpod
Stream<List<Plant>> plantsStream(PlantsStreamRef ref) {
  return repository.watchPlants();
}

// DEPOIS: ✅
@riverpod
Stream<List<Plant>> plantsStream(PlantsStreamRef ref) {
  final subscription = repository.watchPlants();
  
  ref.onDispose(() {
    subscription.cancel();
  });
  
  return subscription;
}
```

---

## 🧪 Testes e TDD

### Exemplo 5: TDD para novo Use Case

**Cenário:** Criar use case de busca de plantas (TDD)

```
[Chat Mode: Testing & TDD]

Implementar use case SearchPlants usando TDD.

Requisitos:
- Buscar por nome, espécie ou descrição
- Case insensitive
- Retornar lista ordenada por relevância
- Mínimo 2 caracteres para buscar

Primeiro: Criar testes (Red)
Depois: Implementar código (Green)
Por fim: Refatorar (Refactor)
```

**Fase RED (testes primeiro):**
```dart
// test/domain/usecases/search_plants_test.dart
void main() {
  late SearchPlants usecase;
  late MockPlantRepository mockRepository;

  setUp(() {
    mockRepository = MockPlantRepository();
    usecase = SearchPlants(mockRepository);
  });

  final tPlants = [
    Plant(id: '1', name: 'Rose', species: 'Rosa rubiginosa'),
    Plant(id: '2', name: 'Rosemary', species: 'Rosmarinus officinalis'),
    Plant(id: '3', name: 'Daisy', species: 'Bellis perennis'),
  ];

  group('SearchPlants', () {
    test('should return plants matching search query', () async {
      // Arrange
      when(() => mockRepository.searchPlants(any()))
          .thenAnswer((_) async => Right(tPlants.take(2).toList()));

      // Act
      final result = await usecase(SearchParams(query: 'rose'));

      // Assert
      expect(result, isA<Right>());
      result.fold(
        (failure) => fail('Should succeed'),
        (plants) {
          expect(plants.length, 2);
          expect(plants[0].name, 'Rose');
          expect(plants[1].name, 'Rosemary');
        },
      );
    });

    test('should return ValidationFailure when query is too short', () async {
      // Act
      final result = await usecase(SearchParams(query: 'r'));

      // Assert
      expect(result, Left(ValidationFailure('Query must be at least 2 characters')));
      verifyNever(() => mockRepository.searchPlants(any()));
    });

    test('should perform case insensitive search', () async {
      // Arrange
      when(() => mockRepository.searchPlants(any()))
          .thenAnswer((_) async => Right([tPlants[0]]));

      // Act
      final result = await usecase(SearchParams(query: 'ROSE'));

      // Assert
      expect(result, isA<Right>());
      verify(() => mockRepository.searchPlants('rose')).called(1);
    });

    test('should return empty list when no matches', () async {
      // Arrange
      when(() => mockRepository.searchPlants(any()))
          .thenAnswer((_) async => Right([]));

      // Act
      final result = await usecase(SearchParams(query: 'xyz'));

      // Assert
      expect(result, Right([]));
    });
  });
}
```

**Rodar testes (devem FALHAR):**
```bash
flutter test test/domain/usecases/search_plants_test.dart
# ❌ Testes falham (esperado - ainda não implementamos)
```

**Fase GREEN (implementar):**
```dart
// lib/domain/usecases/search_plants.dart
class SearchPlants implements UseCase<List<Plant>, SearchParams> {
  final PlantRepository repository;

  SearchPlants(this.repository);

  @override
  Future<Either<Failure, List<Plant>>> call(SearchParams params) async {
    // Validação
    if (params.query.length < 2) {
      return Left(ValidationFailure('Query must be at least 2 characters'));
    }

    // Normalizar query
    final normalizedQuery = params.query.toLowerCase().trim();

    // Buscar
    return await repository.searchPlants(normalizedQuery);
  }
}

class SearchParams {
  final String query;

  SearchParams({required this.query});
}
```

**Rodar testes novamente:**
```bash
flutter test test/domain/usecases/search_plants_test.dart
# ✅ All tests passed!
```

**Fase REFACTOR (melhorar):**
```
[Chat Mode: Refactoring Specialist]

Refatorar SearchPlants:
[colar código]

Melhorias desejadas:
- Extrair constantes (MIN_QUERY_LENGTH)
- Melhorar validação
- Adicionar logging
```

---

## ♻️ Refatoração

### Exemplo 6: Refatorar Widget Grande

**Cenário:** Widget de 300 linhas precisa ser refatorado

```
[Chat Mode: Refactoring Specialist]

Refatorar PlantDetailPage que tem 300+ linhas.

Problemas identificados:
- Múltiplas responsabilidades
- Lógica de negócio na UI
- Difícil de testar
- Muitos widgets aninhados

Objetivo:
- Separar em widgets menores
- Extrair lógica para provider
- Melhorar testabilidade
- Max 50 linhas por widget
```

**Análise do Copilot:**
```
ANÁLISE:
PlantDetailPage tem as seguintes responsabilidades:
1. Layout geral (Scaffold, AppBar)
2. Cabeçalho com imagem e nome
3. Informações da planta (cards)
4. Histórico de cuidados
5. Botões de ação
6. Lógica de favoritos
7. Lógica de edição

PLANO DE REFATORAÇÃO:
Criar widgets especializados:
- PlantHeader (imagem + nome)
- PlantInfoCards (informações)
- PlantCareHistory (histórico)
- PlantActionButtons (botões)

Extrair lógica:
- PlantDetailProvider (state management)
```

**Código refatorado:**
```dart
// ANTES: 300 linhas em um arquivo ❌

// DEPOIS: Separado em múltiplos widgets ✅

// plant_detail_page.dart (50 linhas)
class PlantDetailPage extends ConsumerWidget {
  final String plantId;

  const PlantDetailPage({super.key, required this.plantId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final plantAsync = ref.watch(plantDetailProvider(plantId));

    return Scaffold(
      appBar: AppBar(title: const Text('Plant Details')),
      body: plantAsync.when(
        data: (plant) => PlantDetailContent(plant: plant),
        loading: () => const LoadingIndicator(),
        error: (error, stack) => ErrorDisplay(error: error),
      ),
    );
  }
}

// widgets/plant_detail_content.dart (40 linhas)
class PlantDetailContent extends StatelessWidget {
  final Plant plant;

  const PlantDetailContent({super.key, required this.plant});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Column(
        children: [
          PlantHeader(plant: plant),
          PlantInfoCards(plant: plant),
          PlantCareHistory(plantId: plant.id),
          PlantActionButtons(plant: plant),
        ],
      ),
    );
  }
}

// widgets/plant_header.dart (35 linhas)
class PlantHeader extends StatelessWidget {
  final Plant plant;

  const PlantHeader({super.key, required this.plant});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 200,
      decoration: BoxDecoration(
        image: plant.imageUrl != null
            ? DecorationImage(
                image: NetworkImage(plant.imageUrl!),
                fit: BoxFit.cover,
              )
            : null,
      ),
      child: Align(
        alignment: Alignment.bottomLeft,
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Text(
            plant.name,
            style: Theme.of(context).textTheme.headlineMedium,
          ),
        ),
      ),
    );
  }
}

// ... outros widgets similares
```

**Validação:**
```bash
flutter analyze
# ✅ No issues found!

flutter test
# ✅ All tests passed!

# Verificar tamanho dos arquivos
wc -l lib/features/plants/presentation/pages/*.dart
# ✅ Todos < 50 linhas
```

---

## 🔄 Migração Riverpod

### Exemplo 7: Migrar ChangeNotifier para Riverpod

**Cenário:** Converter provider legado

**Código legado:**
```dart
// ANTES: ChangeNotifier (legado) ❌
class PlantsNotifier extends ChangeNotifier {
  final PlantRepository _repository;
  List<Plant> _plants = [];
  bool _isLoading = false;
  String? _error;

  List<Plant> get plants => _plants;
  bool get isLoading => _isLoading;
  String? get error => _error;

  PlantsNotifier(this._repository);

  Future<void> loadPlants() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final result = await _repository.getPlants();
      result.fold(
        (failure) {
          _error = failure.message;
        },
        (plants) {
          _plants = plants;
        },
      );
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}

// Provider registration
final plantsProvider = ChangeNotifierProvider<PlantsNotifier>((ref) {
  return PlantsNotifier(ref.read(plantRepositoryProvider));
});
```

**Migração:**
```
[Chat Mode: Riverpod Migration]

Migrar este ChangeNotifier para Riverpod code generation:
[colar código acima]

Requisitos:
- Usar @riverpod annotation
- AsyncValue<T> para state
- Auto-dispose
- Type-safe
```

**Resultado:**
```dart
// DEPOIS: Riverpod com code generation ✅
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'plants_provider.g.dart';

@riverpod
class Plants extends _$Plants {
  @override
  Future<List<Plant>> build() async {
    final repository = ref.read(plantRepositoryProvider);
    final result = await repository.getPlants();
    
    return result.fold(
      (failure) => throw Exception(failure.message),
      (plants) => plants,
    );
  }

  Future<void> refresh() async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() async {
      final repository = ref.read(plantRepositoryProvider);
      final result = await repository.getPlants();
      
      return result.fold(
        (failure) => throw Exception(failure.message),
        (plants) => plants,
      );
    });
  }
}
```

**Gerar código:**
```bash
dart run build_runner build --delete-conflicting-outputs
# ✅ Generated plants_provider.g.dart
```

**Atualizar widgets:**
```dart
// ANTES: Consumer antigo ❌
Consumer(
  builder: (context, ref, child) {
    final notifier = ref.watch(plantsProvider);
    
    if (notifier.isLoading) {
      return const LoadingIndicator();
    }
    
    if (notifier.error != null) {
      return ErrorDisplay(error: notifier.error!);
    }
    
    return PlantsList(plants: notifier.plants);
  },
)

// DEPOIS: AsyncValue.when ✅
Consumer(
  builder: (context, ref, child) {
    final plantsAsync = ref.watch(plantsProvider);
    
    return plantsAsync.when(
      data: (plants) => PlantsList(plants: plants),
      loading: () => const LoadingIndicator(),
      error: (error, stack) => ErrorDisplay(error: error.toString()),
    );
  },
)
```

---

## ⚡ Performance

### Exemplo 8: Otimizar Lista Lenta

**Cenário:** Lista de 200+ plantas renderizando lentamente

```
[Chat Mode: Performance Optimizer]

PlantsList com 200+ itens está lenta:
- Scroll travando
- Imagens carregando múltiplas vezes
- Build levando 500ms+

Código atual:
[colar código]
```

**Análise:**
```
PROBLEMAS IDENTIFICADOS:
1. Usando Column ao invés de ListView.builder
2. Imagens sem cache
3. Provider rebuilding toda lista
4. Sem lazy loading

SOLUÇÕES:
```

**Implementação:**
```dart
// ANTES: Lento ❌
class PlantsList extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final plants = ref.watch(plantsProvider);
    
    return SingleChildScrollView(
      child: Column(
        children: plants.map((plant) {
          return PlantCard(plant: plant); // Toda lista rebuilda
        }).toList(),
      ),
    );
  }
}

// DEPOIS: Otimizado ✅
class PlantsList extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final plantsAsync = ref.watch(plantsProvider);
    
    return plantsAsync.when(
      data: (plants) => ListView.builder(
        itemCount: plants.length,
        itemBuilder: (context, index) {
          final plant = plants[index];
          
          // Provider específico por item (melhor granularidade)
          return PlantCardItem(plantId: plant.id);
        },
      ),
      loading: () => const LoadingIndicator(),
      error: (error, stack) => ErrorDisplay(error: error.toString()),
    );
  }
}

// Widget otimizado com cache de imagem
class PlantCardItem extends ConsumerWidget {
  final String plantId;

  const PlantCardItem({super.key, required this.plantId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final plantAsync = ref.watch(plantByIdProvider(plantId));
    
    return plantAsync.when(
      data: (plant) => Card(
        child: ListTile(
          leading: CachedNetworkImage(
            imageUrl: plant.imageUrl ?? '',
            placeholder: (context, url) => const CircularProgressIndicator(),
            errorWidget: (context, url, error) => const Icon(Icons.error),
            cacheKey: plant.id,
            maxWidth: 50,
            maxHeight: 50,
          ),
          title: Text(plant.name),
          subtitle: Text(plant.species),
        ),
      ),
      loading: () => const SizedBox(height: 80, child: LoadingIndicator()),
      error: (_, __) => const SizedBox.shrink(),
    );
  }
}

// Provider por item (granularidade fina)
@riverpod
Future<Plant> plantById(PlantByIdRef ref, String plantId) async {
  final plants = await ref.watch(plantsProvider.future);
  return plants.firstWhere((p) => p.id == plantId);
}
```

**Resultado:**
```
ANTES:
- Build time: 500ms+
- Scroll: Travando
- Memory: 150MB
- Rebuilds: Toda lista

DEPOIS:
- Build time: <50ms ✅
- Scroll: Suave 60fps ✅
- Memory: 80MB ✅
- Rebuilds: Apenas itens visíveis ✅
```

---

## 📝 Documentação

### Exemplo 9: Documentar Feature Complexa

```
[Chat Mode: Documentation Master]

Criar documentação completa para o sistema de sincronização offline-first implementado em app-nebulalist.

Incluir:
- Visão geral da arquitetura
- Fluxo de sincronização
- Estratégias de conflict resolution
- Diagramas
- Exemplos de uso
- Troubleshooting

Salvar em: apps/app-nebulalist/docs/features/sync/
```

**Resultado gerado:**
```markdown
# Sistema de Sincronização Offline-First

## Visão Geral

O app-nebulalist implementa sincronização offline-first onde:
- Operações acontecem primeiro localmente (Hive)
- Sincronização com Firestore é best-effort
- Conflitos são resolvidos automaticamente
- Usuário nunca é bloqueado por rede

## Arquitetura

[Diagrama gerado pelo Copilot]

## Fluxo de Sincronização

### 1. Create
Local → Remote → Cache refresh

### 2. Update
Local → Remote → Merge conflicts → Cache

### 3. Delete
Local soft delete → Remote delete → Cleanup cache

## Código

### SyncService Interface
[Código com comentários]

### Uso
[Exemplos práticos]

## Troubleshooting
[Casos comuns e soluções]
```

---

## 🏢 Cross-App Features

### Exemplo 10: Extrair Código para Core

**Cenário:** 3 apps usam mesma lógica de autenticação

```
@monorepo-orchestrator

Identificar código duplicado de autenticação em:
- app-plantis
- app-gasometer
- app-petiveti

Extrair para packages/core mantendo compatibilidade.
```

**Análise do agente:**
```
CÓDIGO DUPLICADO IDENTIFICADO:

1. AuthService (85% similar entre apps)
2. LoginPage UI (70% similar)
3. UserModel (95% similar)
4. Token refresh logic (100% igual)

RECOMENDAÇÃO:
Extrair para core:
- packages/core/lib/auth/auth_service.dart
- packages/core/lib/auth/models/user.dart
- packages/core/lib/auth/token_manager.dart

Manter nos apps:
- LoginPage (UI varia por app)
- App-specific user extensions
```

**Implementação:**
```
[Prompt: criar_package_compartilhado]

Nome: auth_module
Descrição: Módulo compartilhado de autenticação com Firebase
Apps: app-plantis, app-gasometer, app-petiveti
```

**Migration strategy:**
```
Fase 1: Criar core module
Fase 2: Migrar app-plantis (menor)
Fase 3: Validar em produção
Fase 4: Migrar demais apps
```

---

## 📊 Métricas de Sucesso

Após implementar estes exemplos:

| Métrica | Antes | Depois | 
|---------|-------|--------|
| Tempo implementar feature | 3 dias | 1 dia |
| Bugs em produção | 15/mês | 3/mês |
| Test coverage | 45% | 85% |
| Code duplicação | 30% | 5% |
| Tempo onboarding novo dev | 2 semanas | 3 dias |

---

## 🎯 Próximos Passos

1. **Experimente os exemplos** acima no seu workflow
2. **Adapte para seu contexto** específico
3. **Documente seus próprios casos** de uso
4. **Compartilhe com o time** os melhores workflows

---

**💡 Dica:** Mantenha este arquivo como referência para copiar/colar comandos e adaptar para suas necessidades!

**📖 Ver também:**
- [COPILOT_GUIDE.md](COPILOT_GUIDE.md) - Documentação completa
- [QUICK_START_COPILOT.md](QUICK_START_COPILOT.md) - Referência rápida
