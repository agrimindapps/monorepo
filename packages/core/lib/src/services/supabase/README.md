# Supabase Services - Core Package

Serviços reutilizáveis para integração com Supabase seguindo Clean Architecture e padrões do monorepo.

## 📦 Componentes

### 1. SupabaseConfigService

Serviço de configuração e inicialização do Supabase.

**Características:**
- Singleton pattern
- Validação de credenciais
- Environment-based configuration
- Teste de conexão
- Error handling com Either<Failure, T>

**Uso básico:**

```dart
import 'package:core/core.dart';

// Inicialização (geralmente no main.dart)
Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  final supabaseService = SupabaseConfigService.instance;

  final result = await supabaseService.initialize(
    url: const String.fromEnvironment('SUPABASE_URL'),
    anonKey: const String.fromEnvironment('SUPABASE_ANON_KEY'),
    environment: 'production',
    enableDebug: kDebugMode,
  );

  result.fold(
    (failure) => print('Erro ao inicializar Supabase: ${failure.message}'),
    (_) => print('Supabase inicializado com sucesso'),
  );

  runApp(MyApp());
}

// Acesso ao cliente
final client = SupabaseConfigService.instance.client;

// Teste de conexão
final connectionResult = await supabaseService.testConnection();
connectionResult.fold(
  (failure) => print('Falha na conexão: ${failure.message}'),
  (connected) => print('Conectado: $connected'),
);
```

**Environment Variables:**

Configure as variáveis de ambiente:

```bash
# No comando de build/run
flutter run --dart-define=SUPABASE_URL=https://your-project.supabase.co \
            --dart-define=SUPABASE_ANON_KEY=your-anon-key
```

Ou crie um arquivo `.env` (não commitado):
```
SUPABASE_URL=https://your-project.supabase.co
SUPABASE_ANON_KEY=your-anon-key
```

### 2. BaseSupabaseRepository

Repository base genérico para operações CRUD com Supabase.

**Características:**
- CRUD completo (Create, Read, Update, Delete)
- Cache opcional com TTL configurável
- Busca e filtragem
- Paginação
- Error handling com Either<Failure, T>
- Type-safe com generics

**Implementação de um Repository:**

```dart
import 'package:core/core.dart';

// 1. Model Supabase (Data layer)
class PlantModel {
  final String id;
  final String name;
  final String? species;
  final DateTime createdAt;
  final DateTime updatedAt;

  PlantModel({
    required this.id,
    required this.name,
    this.species,
    required this.createdAt,
    required this.updatedAt,
  });

  factory PlantModel.fromJson(Map<String, dynamic> json) => PlantModel(
        id: json['id'] as String,
        name: json['name'] as String,
        species: json['species'] as String?,
        createdAt: DateTime.parse(json['createdAt'] as String),
        updatedAt: DateTime.parse(json['updatedAt'] as String),
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'species': species,
        'createdAt': createdAt.toIso8601String(),
        'updatedAt': updatedAt.toIso8601String(),
      };
}

// 2. Entity (Domain layer) - pode ser o mesmo que Model
typedef PlantEntity = PlantModel;

// 3. Repository implementation
class PlantsRepository extends BaseSupabaseRepository<PlantModel, PlantEntity> {
  PlantsRepository(SupabaseClient client)
      : super(
          client: client,
          tableName: 'plants',
          idField: 'id', // campo ID na tabela
          enableCache: true, // habilita cache
          cacheDuration: Duration(minutes: 30),
        );

  @override
  PlantEntity toEntity(Map<String, dynamic> json) {
    return PlantModel.fromJson(json);
  }

  @override
  Map<String, dynamic> toJson(PlantEntity entity) {
    return entity.toJson();
  }

  // Métodos customizados (opcionais)
  Future<Either<Failure, List<PlantEntity>>> searchByName(String name) {
    return search(field: 'name', query: name);
  }

  Future<Either<Failure, List<PlantEntity>>> getActiveOnly() {
    return filter(filters: {'Status': 1});
  }
}

// 4. Uso do Repository
final client = SupabaseConfigService.instance.client;
final repository = PlantsRepository(client);

// Buscar todos
final allResult = await repository.getAll(orderBy: 'name', limit: 50);
allResult.fold(
  (failure) => print('Erro: ${failure.message}'),
  (plants) => print('Encontradas ${plants.length} plantas'),
);

// Buscar por ID
final byIdResult = await repository.getById('plant-123');
byIdResult.fold(
  (failure) => print('Erro: ${failure.message}'),
  (plant) => print('Planta: ${plant.name}'),
);

// Criar
final newPlant = PlantModel(
  id: 'new-id',
  name: 'Rosa',
  species: 'Rosa damascena',
  createdAt: DateTime.now(),
  updatedAt: DateTime.now(),
);

final createResult = await repository.create(newPlant);
createResult.fold(
  (failure) => print('Erro ao criar: ${failure.message}'),
  (plant) => print('Planta criada: ${plant.name}'),
);

// Atualizar
final updateResult = await repository.update('plant-123', newPlant);

// Deletar
final deleteResult = await repository.delete('plant-123');

// Buscar com filtros
final filterResult = await repository.filter(
  filters: {'Status': 1, 'species': 'Rosa damascena'},
  orderBy: 'name',
  limit: 20,
);

// Buscar com paginação
final pageResult = await repository.paginate(
  page: 1,
  pageSize: 10,
  orderBy: 'createdAt',
  ascending: false,
);

// Contar registros
final countResult = await repository.count(filters: {'Status': 1});
countResult.fold(
  (failure) => print('Erro: ${failure.message}'),
  (count) => print('Total de plantas ativas: $count'),
);
```

### 3. CacheService

Serviço de cache em memória e disco com TTL.

**Características:**
- Cache em memória (fast access)
- Cache em disco (persistent)
- TTL configurável
- Métricas (hit rate, miss rate)
- Invalidação por padrão

**Uso:**

```dart
import 'package:core/core.dart';

// Salvar no cache
await CacheService.set('my_key', {'data': 'value'}, ttl: Duration(minutes: 30));

// Recuperar do cache
final data = await CacheService.get<Map<String, dynamic>>('my_key');

// Cache-first strategy (busca cache, se não tiver faz fetch)
final plants = await CacheService.getOrFetch<List<Plant>>(
  'all_plants',
  () async => await repository.getAll(),
  ttl: Duration(minutes: 30),
);

// Remover do cache
await CacheService.remove('my_key');

// Limpar todo o cache
await CacheService.clear();

// Invalidar por padrão
await CacheService.invalidatePattern('plants_'); // Remove 'plants_*'

// Obter métricas
final metrics = CacheService.getMetrics();
print('Hit rate: ${metrics['hit_rate']}');
print('Total hits: ${metrics['hits']}');
print('Total misses: ${metrics['misses']}');

// TTL por tipo de dado
final ttl = CacheService.getTtlForType(CacheDataType.static); // 24h
final ttl = CacheService.getTtlForType(CacheDataType.normal); // 30min
final ttl = CacheService.getTtlForType(CacheDataType.critical); // 5min

// Extension helper
await 'my_key'.cacheSet({'data': 'value'});
final data = await 'my_key'.cacheGet<Map<String, dynamic>>();
await 'my_key'.cacheRemove();
```

### 4. Supabase Query Extensions

Extensions para facilitar queries no Supabase.

**Uso:**

```dart
import 'package:core/core.dart';

final client = SupabaseConfigService.instance.client;

// Busca com ILIKE
final results = await client
    .from('plants')
    .select()
    .searchByField('name', 'rosa');

// Filtrar registros ativos
final active = await client
    .from('plants')
    .select()
    .whereActive();

// Paginação
final page1 = await client
    .from('plants')
    .select()
    .paginate(page: 1, pageSize: 10);

// Busca em múltiplos campos
final results = await client
    .from('plants')
    .select()
    .searchInFields(['name', 'species'], 'rosa');

// Filtrar por range de datas
final recent = await client
    .from('plants')
    .select()
    .whereDateBetween(
      field: 'createdAt',
      start: DateTime.now().subtract(Duration(days: 7)),
      end: DateTime.now(),
    );

// Query helper
final results = await SupabaseQueryHelper.buildSearchQuery(
  query: client.from('plants').select(),
  searchTerm: 'rosa',
  searchFields: ['name', 'species'],
  filters: {'Status': 1},
  sortField: 'name',
  sortAscending: true,
  page: 1,
  pageSize: 20,
);
```

### 5. Supabase Failures

Tipos de falhas específicas para Supabase.

**Tipos disponíveis:**

```dart
// Connection failures
SupabaseConnectionFailure('Falha ao conectar')

// Not found
SupabaseNotFoundFailure('Plant')

// Server errors
SupabaseServerFailure('Erro no servidor')

// Auth errors
SupabaseAuthFailure('Token expirado')

// Parse errors
SupabaseParseFailure('JSON inválido')

// Timeout
SupabaseTimeoutFailure('Timeout excedido')

// Query errors
SupabaseQueryFailure('Query inválida')
```

**Extension para converter exceções:**

```dart
try {
  await client.from('plants').select();
} catch (e) {
  final failure = e.toSupabaseFailure();
  return Left(failure);
}
```

### 6. SecureLogger

Sistema de logging seguro que filtra informações sensíveis.

**Uso:**

```dart
import 'package:core/core.dart';

// Debug (apenas em desenvolvimento)
SecureLogger.debug('Carregando plantas', error: e);

// Info
SecureLogger.info('App iniciado');

// Warning
SecureLogger.warning('Cache expirado', error: e);

// Error
SecureLogger.error('Falha ao carregar', error: e, stackTrace: stackTrace);

// User-friendly error
final message = SecureLogger.getUserFriendlyError(exception);
showDialog(context, message);

// Extension
try {
  // ...
} catch (e) {
  e.logError('Erro ao salvar planta');
  e.logWarning('Cache pode estar desatualizado');
}
```

## 🔐 Segurança

### Boas Práticas

1. **NUNCA** hardcode credenciais no código
2. Use environment variables para configuração
3. Configure `.gitignore` para excluir arquivos de configuração:
   ```
   .env
   .env.local
   **/supabase_config.dart
   ```

4. Use o SecureLogger para evitar vazamento de informações sensíveis nos logs

### Environment Variables

**Recomendado:**

```dart
// ✅ CORRETO - usando environment variables
const supabaseUrl = String.fromEnvironment('SUPABASE_URL');
const supabaseKey = String.fromEnvironment('SUPABASE_ANON_KEY');

final result = await SupabaseConfigService.instance.initialize(
  url: supabaseUrl,
  anonKey: supabaseKey,
);
```

**NÃO faça:**

```dart
// ❌ ERRADO - credenciais hardcoded
final result = await SupabaseConfigService.instance.initialize(
  url: 'https://my-project.supabase.co',
  anonKey: 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9...',
);
```

## 🧪 Testing

### Repository Tests

```dart
import 'package:core/core.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

class MockSupabaseClient extends Mock implements SupabaseClient {}

void main() {
  late MockSupabaseClient mockClient;
  late PlantsRepository repository;

  setUp(() {
    mockClient = MockSupabaseClient();
    repository = PlantsRepository(mockClient);
  });

  test('should get all plants successfully', () async {
    // Arrange
    when(() => mockClient.from('plants').select())
        .thenAnswer((_) async => [
              {'id': '1', 'name': 'Rosa', 'createdAt': '2024-01-01', 'updatedAt': '2024-01-01'},
            ]);

    // Act
    final result = await repository.getAll();

    // Assert
    expect(result.isRight(), true);
    result.fold(
      (failure) => fail('Should not fail'),
      (plants) => expect(plants.length, 1),
    );
  });
}
```

## 📊 Performance

### Cache Strategy

O BaseSupabaseRepository inclui cache opcional que pode melhorar significativamente a performance:

```dart
// Sem cache (sempre busca do banco)
PlantsRepository(client, enableCache: false);

// Com cache (padrão: 30 minutos)
PlantsRepository(client, enableCache: true);

// Cache customizado
PlantsRepository(
  client,
  enableCache: true,
  cacheDuration: Duration(hours: 1),
);
```

**Métricas de cache:**

```dart
final metrics = CacheService.getMetrics();
print('Hit rate: ${metrics['hit_rate']}'); // Ex: 85.5%
```

### Paginação

Use paginação para grandes datasets:

```dart
// Carrega 10 itens por vez
final page1 = await repository.paginate(page: 1, pageSize: 10);
final page2 = await repository.paginate(page: 2, pageSize: 10);
```

## 🔄 Migração de Código Existente

### Antes (código app-specific)

```dart
// apps/receituagro_web/lib/services/supabase_service.dart
class SupabaseService {
  Future<void> initializeSupabase() async {
    await Supabase.initialize(url: '...', anonKey: '...');
  }
}

// apps/receituagro_web/lib/repository/cultura_repository.dart
class CulturaRepository {
  final SupabaseClient _client = Supabase.instance.client;

  Future<List<Cultura>> getAllCulturas() async {
    final response = await _client.from('culturas').select();
    return response.map((json) => Cultura.fromJson(json)).toList();
  }
}
```

### Depois (usando Core)

```dart
import 'package:core/core.dart';

// Inicialização
final result = await SupabaseConfigService.instance.initialize(
  url: const String.fromEnvironment('SUPABASE_URL'),
  anonKey: const String.fromEnvironment('SUPABASE_ANON_KEY'),
);

// Repository
class CulturaRepository extends BaseSupabaseRepository<CulturaModel, CulturaEntity> {
  CulturaRepository(SupabaseClient client)
      : super(
          client: client,
          tableName: 'culturas',
          enableCache: true,
        );

  @override
  CulturaEntity toEntity(Map<String, dynamic> json) => CulturaModel.fromJson(json);

  @override
  Map<String, dynamic> toJson(CulturaEntity entity) => entity.toJson();
}

// Uso
final repository = CulturaRepository(SupabaseConfigService.instance.client);
final result = await repository.getAll();
result.fold(
  (failure) => print('Erro: ${failure.message}'),
  (culturas) => print('Carregadas ${culturas.length} culturas'),
);
```

## 📝 Exemplo Completo

Ver implementação de referência em:
- `apps/receituagro_web` - Exemplo de uso com web
- Testes em `packages/core/test/services/supabase/`

## 🆘 Troubleshooting

### Erro: Supabase não inicializado

```dart
// ❌ Erro
final client = SupabaseConfigService.instance.client;
// StateError: Supabase não foi inicializado

// ✅ Solução
await SupabaseConfigService.instance.initialize(...);
final client = SupabaseConfigService.instance.client;
```

### Erro: Environment variable vazia

```dart
// Verifica se a variável está definida
const url = String.fromEnvironment('SUPABASE_URL', defaultValue: '');
if (url.isEmpty) {
  throw Exception('SUPABASE_URL não configurada');
}
```

### Cache não está funcionando

```dart
// Verifica se o cache está habilitado
PlantsRepository(client, enableCache: true); // ✅

// Verifica métricas
final metrics = CacheService.getMetrics();
print(metrics); // {'hits': 0, 'misses': 10} - cache não está sendo usado
```

## 🚀 Próximos Passos

1. Adicione autenticação Supabase ao Core (SupabaseAuthService)
2. Adicione suporte a Storage do Supabase (SupabaseStorageService)
3. Adicione suporte a Realtime do Supabase (SupabaseRealtimeService)
4. Adicione suporte a Edge Functions (SupabaseFunctionsService)

## 📚 Referências

- [Supabase Flutter Documentation](https://supabase.com/docs/reference/dart)
- [Clean Architecture](https://blog.cleancoder.com/uncle-bob/2012/08/13/the-clean-architecture.html)
- [Either<Failure, T> Pattern](https://pub.dev/packages/dartz)
