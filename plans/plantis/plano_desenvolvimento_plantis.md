# Plano de Desenvolvimento - App Plantis (Monorepo)

## 📋 Visão Geral do Projeto

### Objetivo
Desenvolver um aplicativo de gerenciamento de plantas domésticas seguindo os princípios SOLID, sem GetX, integrado ao monorepo existente e aproveitando o package core compartilhado.

### Stack Tecnológica
- **Framework**: Flutter
- **Gerenciamento de Estado**: Provider + ChangeNotifier
- **Injeção de Dependência**: GetIt
- **Persistência Local**: Hive (já disponível no core)
- **Backend**: Firebase (Auth, Firestore, Storage)
- **Arquitetura**: Clean Architecture + SOLID

### Localização no Monorepo
- **App**: `apps/app-plantis/`
- **Core Compartilhado**: `packages/core/`
- **Assets Compartilhados**: `packages/shared_assets/` (futuro)

---

## 🏗️ Arquitetura SOLID

### Estrutura de Pastas Proposta

```
apps/app-plantis/
├── lib/
│   ├── main.dart
│   ├── app.dart
│   ├── app_module.dart                    # Configuração de DI
│   │
│   ├── core/                              # Core específico do app
│   │   ├── constants/
│   │   │   ├── app_constants.dart
│   │   │   ├── route_constants.dart
│   │   │   └── storage_keys.dart
│   │   ├── di/
│   │   │   ├── injection_container.dart   # GetIt setup
│   │   │   └── modules/
│   │   │       ├── data_module.dart
│   │   │       ├── domain_module.dart
│   │   │       └── presentation_module.dart
│   │   ├── router/
│   │   │   ├── app_router.dart
│   │   │   └── route_guards.dart
│   │   ├── theme/
│   │   │   ├── app_theme.dart
│   │   │   ├── colors.dart
│   │   │   └── typography.dart
│   │   └── utils/
│   │       ├── validators.dart
│   │       └── formatters.dart
│   │
│   ├── features/                         # Features seguindo Clean Architecture
│   │   ├── auth/                        # Feature de autenticação
│   │   │   ├── data/
│   │   │   │   ├── datasources/
│   │   │   │   │   └── auth_datasource.dart
│   │   │   │   ├── models/
│   │   │   │   │   └── user_model.dart
│   │   │   │   └── repositories/
│   │   │   │       └── auth_repository_impl.dart
│   │   │   ├── domain/
│   │   │   │   ├── entities/
│   │   │   │   │   └── user.dart
│   │   │   │   ├── repositories/
│   │   │   │   │   └── auth_repository.dart
│   │   │   │   └── usecases/
│   │   │   │       ├── login_usecase.dart
│   │   │   │       └── logout_usecase.dart
│   │   │   └── presentation/
│   │   │       ├── providers/
│   │   │       │   └── auth_provider.dart
│   │   │       ├── pages/
│   │   │       │   └── login_page.dart
│   │   │       └── widgets/
│   │   │           └── login_form.dart
│   │   │
│   │   ├── plants/                      # Feature principal - Plantas
│   │   │   ├── data/
│   │   │   │   ├── datasources/
│   │   │   │   │   ├── local/
│   │   │   │   │   │   └── plants_local_datasource.dart
│   │   │   │   │   └── remote/
│   │   │   │   │       └── plants_remote_datasource.dart
│   │   │   │   ├── models/
│   │   │   │   │   ├── plant_model.dart
│   │   │   │   │   └── plant_config_model.dart
│   │   │   │   └── repositories/
│   │   │   │       └── plants_repository_impl.dart
│   │   │   ├── domain/
│   │   │   │   ├── entities/
│   │   │   │   │   ├── plant.dart
│   │   │   │   │   └── plant_config.dart
│   │   │   │   ├── repositories/
│   │   │   │   │   └── plants_repository.dart
│   │   │   │   └── usecases/
│   │   │   │       ├── add_plant_usecase.dart
│   │   │   │       ├── get_plants_usecase.dart
│   │   │   │       ├── update_plant_usecase.dart
│   │   │   │       └── delete_plant_usecase.dart
│   │   │   └── presentation/
│   │   │       ├── providers/
│   │   │       │   ├── plants_list_provider.dart
│   │   │       │   ├── plant_details_provider.dart
│   │   │       │   └── plant_form_provider.dart
│   │   │       ├── pages/
│   │   │       │   ├── plants_list_page.dart
│   │   │       │   ├── plant_details_page.dart
│   │   │       │   └── plant_form_page.dart
│   │   │       └── widgets/
│   │   │           ├── plant_card.dart
│   │   │           ├── plant_grid_item.dart
│   │   │           └── empty_plants_widget.dart
│   │   │
│   │   ├── spaces/                      # Feature de Espaços
│   │   │   ├── data/
│   │   │   ├── domain/
│   │   │   └── presentation/
│   │   │
│   │   ├── tasks/                       # Feature de Tarefas
│   │   │   ├── data/
│   │   │   ├── domain/
│   │   │   └── presentation/
│   │   │
│   │   ├── comments/                    # Feature de Comentários
│   │   │   ├── data/
│   │   │   ├── domain/
│   │   │   └── presentation/
│   │   │
│   │   └── premium/                     # Feature Premium
│   │       ├── data/
│   │       ├── domain/
│   │       └── presentation/
│   │
│   └── shared/                          # Componentes compartilhados do app
│       ├── widgets/
│       │   ├── app_scaffold.dart
│       │   ├── bottom_navigation.dart
│       │   └── loading_overlay.dart
│       └── services/
│           ├── image_service.dart
│           └── notification_service.dart
```

---

## 🔌 Integração com Core Package

### Utilização do Core Existente

```dart
// Entidades base do Core
import 'package:core/domain/entities/base_entity.dart';
import 'package:core/domain/entities/base_sync_entity.dart';

// Services do Core
import 'package:core/infrastructure/services/hive_storage_service.dart';
import 'package:core/infrastructure/services/firebase_auth_service.dart';
import 'package:core/infrastructure/services/sync_firebase_service.dart';

// UseCases compartilhados
import 'package:core/domain/usecases/auth/login_usecase.dart';
```

### Extensões das Entidades Base

```dart
// Plant entity estendendo BaseSyncEntity
class Plant extends BaseSyncEntity {
  final String name;
  final String? species;
  final String? spaceId;
  final PlantConfig? config;
  
  Plant({
    required super.id,
    required super.createdAt,
    required super.updatedAt,
    required this.name,
    this.species,
    this.spaceId,
    this.config,
    super.isDeleted,
    super.needsSync,
  });
}
```

---

## 📱 Módulos Principais

### 1. Módulo de Autenticação
**Responsabilidade**: Gerenciar login, logout e estado de autenticação

#### Implementação:
```dart
// Provider de Autenticação
class AuthProvider extends ChangeNotifier {
  final LoginUseCase _loginUseCase;
  final LogoutUseCase _logoutUseCase;
  
  User? _currentUser;
  bool _isLoading = false;
  
  User? get currentUser => _currentUser;
  bool get isLoading => _isLoading;
  bool get isAuthenticated => _currentUser != null;
  
  Future<void> login(String email, String password) async {
    _isLoading = true;
    notifyListeners();
    
    final result = await _loginUseCase(
      LoginParams(email: email, password: password)
    );
    
    result.fold(
      (failure) => _handleError(failure),
      (user) {
        _currentUser = user;
        notifyListeners();
      }
    );
    
    _isLoading = false;
    notifyListeners();
  }
}
```

### 2. Módulo de Plantas
**Responsabilidade**: CRUD completo de plantas

#### Camadas:

##### Domain Layer
```dart
// Entity
class Plant {
  final String id;
  final String name;
  final String? species;
  final DateTime? plantingDate;
  final String? imageBase64;
  final PlantConfig? config;
}

// Repository Interface
abstract class PlantsRepository {
  Future<Either<Failure, List<Plant>>> getPlants();
  Future<Either<Failure, Plant>> addPlant(Plant plant);
  Future<Either<Failure, void>> updatePlant(Plant plant);
  Future<Either<Failure, void>> deletePlant(String id);
}

// Use Case
class GetPlantsUseCase implements UseCase<List<Plant>, NoParams> {
  final PlantsRepository repository;
  
  GetPlantsUseCase(this.repository);
  
  @override
  Future<Either<Failure, List<Plant>>> call(NoParams params) {
    return repository.getPlants();
  }
}
```

##### Data Layer
```dart
// Model
class PlantModel extends Plant {
  PlantModel({required super.id, required super.name});
  
  factory PlantModel.fromJson(Map<String, dynamic> json) {
    return PlantModel(
      id: json['id'],
      name: json['name'],
    );
  }
  
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
    };
  }
}

// Repository Implementation
class PlantsRepositoryImpl implements PlantsRepository {
  final PlantsLocalDataSource localDataSource;
  final PlantsRemoteDataSource remoteDataSource;
  final NetworkInfo networkInfo;
  
  @override
  Future<Either<Failure, List<Plant>>> getPlants() async {
    try {
      if (await networkInfo.isConnected) {
        final remotePlants = await remoteDataSource.getPlants();
        await localDataSource.cachePlants(remotePlants);
        return Right(remotePlants);
      } else {
        final localPlants = await localDataSource.getPlants();
        return Right(localPlants);
      }
    } catch (e) {
      return Left(CacheFailure());
    }
  }
}
```

##### Presentation Layer
```dart
// Provider
class PlantsListProvider extends ChangeNotifier {
  final GetPlantsUseCase _getPlantsUseCase;
  final AddPlantUseCase _addPlantUseCase;
  
  List<Plant> _plants = [];
  bool _isLoading = false;
  String? _errorMessage;
  
  List<Plant> get plants => _plants;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  
  Future<void> loadPlants() async {
    _isLoading = true;
    notifyListeners();
    
    final result = await _getPlantsUseCase(NoParams());
    
    result.fold(
      (failure) {
        _errorMessage = _mapFailureToMessage(failure);
      },
      (plants) {
        _plants = plants;
        _errorMessage = null;
      }
    );
    
    _isLoading = false;
    notifyListeners();
  }
}
```

### 3. Módulo de Espaços
**Responsabilidade**: Gerenciar locais onde as plantas estão

### 4. Módulo de Tarefas
**Responsabilidade**: Sistema de lembretes e cuidados

### 5. Módulo Premium
**Responsabilidade**: Controle de funcionalidades premium

---

## 🔧 Configuração de Dependências (GetIt)

```dart
// injection_container.dart
final sl = GetIt.instance;

Future<void> init() async {
  // Features
  _initAuth();
  _initPlants();
  _initSpaces();
  _initTasks();
  
  // Core
  _initCore();
  
  // External
  await _initExternal();
}

void _initPlants() {
  // Providers
  sl.registerFactory(
    () => PlantsListProvider(
      getPlantsUseCase: sl(),
      addPlantUseCase: sl(),
    ),
  );
  
  // Use cases
  sl.registerLazySingleton(() => GetPlantsUseCase(sl()));
  sl.registerLazySingleton(() => AddPlantUseCase(sl()));
  
  // Repository
  sl.registerLazySingleton<PlantsRepository>(
    () => PlantsRepositoryImpl(
      localDataSource: sl(),
      remoteDataSource: sl(),
      networkInfo: sl(),
    ),
  );
  
  // Data sources
  sl.registerLazySingleton<PlantsLocalDataSource>(
    () => PlantsLocalDataSourceImpl(sl()),
  );
  
  sl.registerLazySingleton<PlantsRemoteDataSource>(
    () => PlantsRemoteDataSourceImpl(sl()),
  );
}
```

---

## 🚀 Roadmap de Desenvolvimento

### Fase 1: Fundação (Semana 1-2) ✅ CONCLUÍDA
- [x] Estruturação do projeto no monorepo
- [x] Configuração de dependências base
- [x] Setup de temas e design system
- [x] Configuração de rotas e navegação
- [x] Integração com core package

**Tarefas:**
1. ✅ Criar estrutura de pastas
2. ✅ Configurar GetIt para DI
3. ✅ Implementar tema e cores
4. ✅ Setup do router
5. ✅ Criar app scaffold base

**Status Atual (11/08/2025):**
- Projeto base configurado com Flutter + Clean Architecture
- Sistema de rotas com GoRouter implementado
- Design system completo com cores, tipografia e temas
- Bottom navigation funcional
- Login mock implementado
- Testes básicos funcionando

### Fase 2: Autenticação (Semana 3) ✅ CONCLUÍDA
- [x] Implementar login/logout
- [x] Gerenciamento de sessão
- [x] Guards de rotas
- [x] Tela de perfil

**Tarefas:**
1. ✅ Criar AuthProvider com UseCases do core
2. ✅ Implementar LoginPage funcional
3. ✅ Configurar Firebase Auth via core package
4. ✅ Adicionar route guards com persistência
5. ✅ Criar ProfilePage completa
6. ✅ Implementar RegisterPage com validações
7. ✅ Stream de authentication state

**Status Atual (11/08/2025):**
- Autenticação real via Firebase Auth
- Persistência de sessão automática
- Login/logout funcionais
- Tela de registro completa com validações
- Tela de perfil com informações do usuário
- Route guards protegendo páginas privadas
- Integração total com core package

### Fase 3: Core Features - Plantas (Semana 4-5) ✅ CONCLUÍDA
- [x] CRUD de plantas
- [x] Lista com modos de visualização
- [x] Detalhes da planta
- [x] Formulário de criação/edição

**Tarefas:**
1. ✅ Implementar domain layer (entities, repos, usecases)
2. ✅ Implementar data layer (models, datasources)
3. ✅ Criar PlantsListProvider
4. ✅ Desenvolver UI da lista
5. ✅ Criar formulário de plantas

**Status Atual (11/08/2025):**
- Clean Architecture completa para plantas implementada
- CRUD completo com validações
- PlantsProvider com gerenciamento de estado reativo
- Sistema de use cases com AddPlantUseCase e UpdatePlantUseCase
- Repository pattern com cache local (Hive) e sync remoto (Firebase)
- Entidades Plant e PlantConfig completas
- Integração total com package core (failures, base entities)
- Dependency injection configurada

### Fase 4: Espaços (Semana 6) ✅ CONCLUÍDA
- [x] CRUD de espaços
- [x] Sistema completo de espaços
- [x] UI completa com formulários
- [x] Integração com Clean Architecture

**Tarefas:**
1. ✅ Criar domain layer (entities, repos, usecases)
2. ✅ Implementar data layer (models, datasources)
3. ✅ Criar SpacesProvider para gerenciamento de estado
4. ✅ Implementar UI da lista de espaços
5. ✅ Criar formulário completo de espaços
6. ✅ Configurar tipos e configurações ambientais

**Status Atual (11/08/2025):**
- Clean Architecture completa para espaços implementada
- CRUD completo com validações (nome, temperatura, umidade)
- 9 tipos de espaços (sala, varanda, jardim, escritório, etc.)
- Sistema de configurações ambientais (temperatura, umidade, luz, ventilação)
- SpacesProvider e SpaceFormProvider com estado reativo
- UI responsiva com grid/list view e busca funcional
- Formulário detalhado com validações em tempo real
- Repository pattern com offline-first (Hive + Firebase)
- Dependency injection configurada

### Fase 5: Sistema de Tarefas (Semana 7-8)
- [ ] Criar tarefas para plantas
- [ ] Sistema de notificações
- [ ] Histórico de cuidados
- [ ] Dashboard de tarefas

**Tarefas:**
1. Implementar TasksProvider
2. Criar sistema de notificações locais
3. Desenvolver UI de tarefas
4. Implementar histórico

### Fase 6: Comentários e Detalhes (Semana 9)
- [ ] Sistema de comentários
- [ ] Upload de imagens
- [ ] Configurações de cuidados
- [ ] Tabs na página de detalhes

**Tarefas:**
1. Adicionar CommentsProvider
2. Implementar upload de imagens
3. Criar tabs de detalhes
4. Desenvolver configurações

### Fase 7: Premium e Monetização (Semana 10)
- [ ] Integração RevenueCat
- [ ] Limite de plantas free
- [ ] Features premium
- [ ] Tela de upgrade

**Tarefas:**
1. Configurar RevenueCat
2. Implementar PremiumProvider
3. Adicionar limitações
4. Criar UI de upgrade

### Fase 8: Polish e Otimização (Semana 11-12)
- [ ] Animações e transições
- [ ] Otimização de performance
- [ ] Testes unitários
- [ ] Testes de integração
- [ ] Dark mode

**Tarefas:**
1. Adicionar animações
2. Otimizar queries
3. Escrever testes
4. Implementar dark mode
5. Performance profiling

---

## 🧪 Estratégia de Testes

### Testes Unitários
```dart
// test/features/plants/domain/usecases/get_plants_test.dart
void main() {
  late GetPlantsUseCase useCase;
  late MockPlantsRepository mockRepository;
  
  setUp(() {
    mockRepository = MockPlantsRepository();
    useCase = GetPlantsUseCase(mockRepository);
  });
  
  test('should get plants from repository', () async {
    // arrange
    final plants = [Plant(id: '1', name: 'Cacto')];
    when(mockRepository.getPlants())
        .thenAnswer((_) async => Right(plants));
    
    // act
    final result = await useCase(NoParams());
    
    // assert
    expect(result, Right(plants));
    verify(mockRepository.getPlants());
    verifyNoMoreInteractions(mockRepository);
  });
}
```

### Testes de Widget
```dart
// test/features/plants/presentation/widgets/plant_card_test.dart
void main() {
  testWidgets('PlantCard displays plant information', (tester) async {
    final plant = Plant(id: '1', name: 'Cacto', species: 'Cactaceae');
    
    await tester.pumpWidget(
      MaterialApp(
        home: PlantCard(plant: plant),
      ),
    );
    
    expect(find.text('Cacto'), findsOneWidget);
    expect(find.text('Cactaceae'), findsOneWidget);
  });
}
```

### Testes de Integração
```dart
// integration_test/plants_flow_test.dart
void main() {
  testWidgets('Complete plant creation flow', (tester) async {
    app.main();
    await tester.pumpAndSettle();
    
    // Navigate to plants
    await tester.tap(find.byIcon(Icons.local_florist));
    await tester.pumpAndSettle();
    
    // Tap add button
    await tester.tap(find.byType(FloatingActionButton));
    await tester.pumpAndSettle();
    
    // Fill form
    await tester.enterText(find.byKey(Key('plant_name')), 'Cacto');
    await tester.tap(find.text('Salvar'));
    await tester.pumpAndSettle();
    
    // Verify plant was added
    expect(find.text('Cacto'), findsOneWidget);
  });
}
```

---

## 📊 Métricas de Qualidade

### Code Coverage
- Mínimo: 80% de cobertura
- Crítico: 95% para domain layer
- Desejável: 90% para presentation layer

### Performance Metrics
- App startup: < 2s
- Lista de plantas (100 items): < 16ms frame time
- Navegação entre telas: < 300ms
- Sync de dados: < 5s

### Padrões de Código
- Análise estática: `flutter analyze` sem warnings
- Formatação: `dart format` aplicado
- Linting: Regras do `analysis_options.yaml`
- Documentação: Comentários em métodos públicos

---

## 🔄 Sincronização e Offline-First

### Estratégia de Sync
1. **Cache Local**: Hive para persistência
2. **Queue de Operações**: Operações offline enfileiradas
3. **Sync Automático**: Ao recuperar conexão
4. **Conflict Resolution**: Last-write-wins por padrão

### Implementação
```dart
class SyncManager {
  final HiveStorageService _localStorage;
  final FirebaseService _remoteService;
  final Queue<SyncOperation> _pendingOperations;
  
  Future<void> syncData() async {
    if (!await _networkInfo.isConnected) {
      return;
    }
    
    // Process pending operations
    while (_pendingOperations.isNotEmpty) {
      final operation = _pendingOperations.removeFirst();
      await _processOperation(operation);
    }
    
    // Pull latest data
    await _pullRemoteChanges();
  }
}
```

---

## 🎨 Design System

### Tokens de Design
```dart
class PlantisDesignTokens {
  // Colors
  static const primaryColor = Color(0xFF20B2AA);
  static const secondaryColor = Color(0xFF98D8C8);
  static const errorColor = Color(0xFFE74C3C);
  static const successColor = Color(0xFF27AE60);
  
  // Spacing
  static const spacingXS = 4.0;
  static const spacingS = 8.0;
  static const spacingM = 16.0;
  static const spacingL = 24.0;
  static const spacingXL = 32.0;
  
  // Typography
  static const headingLarge = TextStyle(
    fontSize: 28,
    fontWeight: FontWeight.bold,
  );
  
  static const bodyMedium = TextStyle(
    fontSize: 16,
    fontWeight: FontWeight.normal,
  );
}
```

---

## 📈 Monitoramento e Analytics

### Eventos Rastreados
- User journey: Login, Signup, Logout
- Feature usage: Add plant, Complete task
- Errors: Crashes, API failures
- Performance: Screen load times

### Implementação
```dart
class AnalyticsService {
  final FirebaseAnalytics _analytics;
  
  void trackEvent(String name, Map<String, dynamic>? parameters) {
    _analytics.logEvent(name: name, parameters: parameters);
  }
  
  void trackScreenView(String screenName) {
    _analytics.setCurrentScreen(screenName: screenName);
  }
}
```

---

## 🚢 Deploy e CI/CD

### Pipeline de CI/CD
1. **Build**: Compilação para iOS/Android
2. **Test**: Testes unitários e widgets
3. **Analyze**: Análise estática
4. **Deploy**: Upload para stores

### GitHub Actions
```yaml
name: CI/CD Pipeline

on:
  push:
    branches: [main, develop]
  pull_request:
    branches: [main]

jobs:
  test:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v2
      - uses: subosito/flutter-action@v2
      - run: flutter pub get
      - run: flutter analyze
      - run: flutter test
      - run: flutter test --coverage
```

---

## 📝 Notas de Atualização

**Última atualização**: ${new Date().toISOString()}
**Status**: Em desenvolvimento
**Próxima revisão**: Após conclusão da Fase 1

### Changelog
- v0.1.0: Estrutura inicial e planejamento
- v0.2.0: Definição de arquitetura SOLID
- v0.3.0: Integração com monorepo

---

## 👥 Equipe e Responsabilidades

### Desenvolvimento
- **Arquitetura**: Definição de padrões e estrutura
- **Features**: Implementação dos módulos
- **UI/UX**: Design e experiência do usuário
- **QA**: Testes e garantia de qualidade

### Comunicação
- **Daily**: Sincronização diária
- **Sprint Planning**: Planejamento quinzenal
- **Retrospective**: Análise e melhorias

---

## 🔗 Links e Recursos

### Documentação
- [Flutter Documentation](https://flutter.dev/docs)
- [Provider Package](https://pub.dev/packages/provider)
- [GetIt Package](https://pub.dev/packages/get_it)
- [Clean Architecture](https://blog.cleancoder.com/uncle-bob/2012/08/13/the-clean-architecture.html)

### Ferramentas
- [Melos](https://melos.invertase.dev/) - Monorepo management
- [Firebase Console](https://console.firebase.google.com)
- [RevenueCat Dashboard](https://app.revenuecat.com)

---

---

## 📊 Status de Desenvolvimento

### Progresso Geral: 70% ✅

**Última Atualização**: 11 de Agosto de 2025

### Fases Concluídas:
- ✅ **Fase 1 - Fundação**: 100% concluída
  - Estrutura do projeto
  - Configuração de dependências
  - Design system
  - Sistema de rotas
  - Setup inicial
  
- ✅ **Fase 2 - Autenticação**: 100% concluída
  - Firebase Auth integração
  - Login/logout funcionais
  - Registro com validações
  - Persistência de sessão
  - Route guards
  - Tela de perfil completa
  
- ✅ **Fase 3 - Core Features (Plants)**: 100% concluída
  - Clean Architecture completa implementada
  - CRUD de plantas com validações
  - Use cases (Add, Update, Delete, Get)
  - Repository pattern (offline-first)
  - Providers com estado reativo
  - Integração com Firebase e Hive

- ✅ **Fase 5 - UI Plants List**: 100% concluída
  - Lista de plantas com grid e tile views
  - Sistema de busca funcional
  - Filtros por espaço
  - Empty states e loading states
  - Plant cards responsivos
  - Navegação completa

- ✅ **Fase 6 - Plant Details Page**: 100% concluída
  - Tela de detalhes completa
  - Informações básicas e configurações
  - Histórico de cuidados
  - Botões de ação (editar, excluir)
  - Provider dedicado para detalhes
  - Design Material 3

- ✅ **Fase 7 - Plant Form Page**: 100% concluída
  - Formulário multi-step completo
  - Validação em tempo real
  - Configurações de cuidado
  - Preferências ambientais
  - Modo add/edit integrado
  - PlantFormProvider implementado

- ✅ **Fase 4 - Sistema de Espaços**: 100% concluída
  - Clean Architecture completa implementada
  - CRUD de espaços com validações
  - 9 tipos de espaços (sala, varanda, jardim, etc.)
  - Configurações ambientais (temperatura, umidade, luz)
  - SpacesProvider e SpaceFormProvider
  - UI responsiva com grid/list view e busca
  - Formulário detalhado com validações
  - Repository pattern offline-first

### Próximos Passos:
1. **Desenvolver sistema de tarefas** (Fase 5 - lembretes e cuidados) ⬅️ **PRÓXIMO**
2. **Adicionar comentários e upload de imagens** (Fase 6)
3. **Implementar funcionalidades premium** (Fase 7 - limites e upgrades)
4. **Polish e otimizações finais** (Fase 8 - animações, testes, dark mode)

### Arquivos Principais Criados:
```
lib/
├── app.dart                     # App principal
├── main.dart                    # Entry point
├── core/
│   ├── theme/                   # Design system completo
│   ├── router/                  # Sistema de rotas com Provider integration
│   └── di/                      # Injeção de dependências GetIt
├── features/
│   ├── auth/                    # Autenticação (Firebase completa)
│   │   ├── domain/entities/     # (removidas - usando core)
│   │   └── presentation/        # Login, Register, Profile
│   ├── plants/                  # Sistema completo de plantas
│   │   ├── domain/
│   │   │   ├── entities/        # Plant, PlantConfig
│   │   │   ├── repositories/    # PlantsRepository interface
│   │   │   └── usecases/        # CRUD use cases completos
│   │   ├── data/
│   │   │   ├── datasources/     # Local (Hive) + Remote (Firebase)
│   │   │   ├── models/          # PlantModel, PlantConfigModel
│   │   │   └── repositories/    # PlantsRepositoryImpl
│   │   └── presentation/
│   │       ├── providers/       # PlantsProvider, PlantDetailsProvider, PlantFormProvider
│   │       ├── pages/          # PlantsListPage, PlantDetailsPage, PlantFormPage
│   │       └── widgets/        # PlantCard, PlantFormWidgets (multi-step)
│   ├── spaces/                  # Sistema completo de espaços
│   │   ├── domain/
│   │   │   ├── entities/        # Space, SpaceConfig, SpaceType
│   │   │   ├── repositories/    # SpacesRepository interface
│   │   │   └── usecases/        # CRUD use cases completos
│   │   ├── data/
│   │   │   ├── datasources/     # Local (Hive) + Remote (Firebase)
│   │   │   ├── models/          # SpaceModel, SpaceConfigModel
│   │   │   └── repositories/    # SpacesRepositoryImpl
│   │   └── presentation/
│   │       ├── providers/       # SpacesProvider, SpaceFormProvider
│   │       ├── pages/          # SpacesListPage, SpaceFormPage
│   │       └── widgets/        # SpaceCard, SpaceListTile, EmptySpacesWidget
│   └── tasks/                   # Tarefas (placeholders)
└── shared/
    └── widgets/                 # MainScaffold, BottomNavigation
```

### Como Testar:
1. `cd apps/app-plantis`
2. `flutter pub get`
3. `flutter analyze` (deve retornar sem erros)
4. `flutter test` (todos os testes devem passar)
5. **Sistema Completo Funcional**: 
   - Registre uma conta com email válido
   - Faça login com as credenciais
   - **Sistema de Plantas**:
     - Adicione plantas: Use o formulário multi-step
     - Visualize lista: Grid/tile view com busca
     - Veja detalhes: Tela completa com informações
     - Edite plantas: Use o mesmo formulário
   - **Sistema de Espaços**:
     - Crie espaços: Use o formulário com configurações ambientais
     - Visualize lista: Grid/tile view com busca por tipo
     - Configure temperatura, umidade, luz, ventilação
     - 9 tipos diferentes de espaços disponíveis
   - **Teste navegação**: Entre todas as telas
   - **Teste persistência**: Logout/login mantém dados

---

**Este documento será atualizado conforme o progresso do desenvolvimento.**