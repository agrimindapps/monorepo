# Migração para UuidService do Core

O `UuidService` foi implementado no package `core` para centralizar a geração de UUIDs em todos os apps do monorepo.

## ✅ Benefícios

- ✅ Única dependência `uuid` gerenciada centralmente
- ✅ API consistente em todos os apps
- ✅ Métodos auxiliares convenientes (validação, formatação, etc)
- ✅ Injeção de dependência com GetIt
- ✅ Documentação completa

## 📋 Como Migrar

### Antes (import direto do uuid):
```dart
import 'package:uuid/uuid.dart';

class MeuService {
  final uuid = const Uuid();

  String gerarId() {
    return uuid.v4();
  }
}
```

### Depois (usando UuidService do core):
```dart
import 'package:core/core.dart';

class MeuService {
  final UuidService _uuidService;

  MeuService(this._uuidService);

  String gerarId() {
    return _uuidService.generate();
  }
}

// Ou usando GetIt diretamente
class OutroService {
  String gerarId() {
    return getIt<UuidService>().generate();
  }
}
```

## 🔧 Passos para Migração

### 1. Remover dependência `uuid` do pubspec.yaml do app

**Antes:**
```yaml
dependencies:
  uuid: ^4.5.1  # ❌ Remover esta linha
```

**Depois:**
```yaml
# ✅ Não precisa mais - vem do core
```

### 2. Atualizar imports

**Buscar e substituir:**
```dart
// ❌ Antes
import 'package:uuid/uuid.dart';

// ✅ Depois
import 'package:core/core.dart';
```

### 3. Substituir instâncias diretas do Uuid

**Antes:**
```dart
final uuid = const Uuid();
final id = uuid.v4();
```

**Depois (opção 1 - injetando o service):**
```dart
final uuidService = getIt<UuidService>();
final id = uuidService.generate();
```

**Depois (opção 2 - recebendo via construtor):**
```dart
class MeuController {
  final UuidService _uuidService;

  MeuController(this._uuidService);

  void criarItem() {
    final id = _uuidService.generate();
    // ...
  }
}
```

## 🎯 API do UuidService

### Métodos Principais

```dart
final uuidService = getIt<UuidService>();

// UUID v4 (aleatório) - mais comum
final id = uuidService.generate();
// '550e8400-e29b-41d4-a716-446655440000'

// UUID v4 compacto (sem hífens)
final compactId = uuidService.generateCompact();
// '550e8400e29b41d4a716446655440000'

// UUID v1 (baseado em timestamp)
final timestampId = uuidService.generateV1();

// UUID v5 (determinístico, baseado em namespace e nome)
final deterministicId = uuidService.generateV5(
  namespace: Uuid.NAMESPACE_URL,
  name: 'https://example.com',
);

// Gerar múltiplos IDs
final ids = uuidService.generateBatch(5);
// ['id1', 'id2', 'id3', 'id4', 'id5']
```

### Métodos de Validação

```dart
// Validar UUID formatado
final isValid = uuidService.isValid('550e8400-e29b-41d4-a716-446655440000');
// true

// Validar UUID compacto
final isValidCompact = uuidService.isValidCompact('550e8400e29b41d4a716446655440000');
// true
```

### Métodos de Formatação

```dart
// Formatar UUID compacto
final formatted = uuidService.format('550e8400e29b41d4a716446655440000');
// '550e8400-e29b-41d4-a716-446655440000'

// Remover formatação
final compact = uuidService.unformat('550e8400-e29b-41d4-a716-446655440000');
// '550e8400e29b41d4a716446655440000'
```

## 📝 Exemplos de Uso Real

### Exemplo 1: Repository com UUIDs
```dart
import 'package:core/core.dart';

@injectable
class BovineRepository {
  final UuidService _uuidService;

  BovineRepository(this._uuidService);

  Future<BovineEntity> createBovine(CreateBovineParams params) async {
    final id = _uuidService.generate();

    final bovine = BovineEntity(
      id: id,
      name: params.name,
      breed: params.breed,
      // ...
    );

    await _saveBovine(bovine);
    return bovine;
  }
}
```

### Exemplo 2: Form Provider
```dart
import 'package:core/core.dart';

class PlantFormProvider extends ChangeNotifier {
  final UuidService _uuidService;

  PlantFormProvider(this._uuidService);

  void createNewPlant() {
    final plant = Plant(
      id: _uuidService.generate(),
      name: _nameController.text,
      // ...
    );

    _savePlant(plant);
  }
}
```

### Exemplo 3: Uso direto com GetIt
```dart
import 'package:core/core.dart';

void handleCreateItem() {
  final id = getIt<UuidService>().generate();

  final item = Item(
    id: id,
    createdAt: DateTime.now(),
  );

  saveItem(item);
}
```

## 🔍 Verificação da Migração

Após migrar, verifique:

1. ✅ Remover `import 'package:uuid/uuid.dart';` de todos os arquivos
2. ✅ Remover `uuid` do `pubspec.yaml` do app
3. ✅ Executar `flutter pub get`
4. ✅ Executar `flutter analyze` para verificar erros
5. ✅ Testar a geração de IDs

## 🚀 Comando de Busca

Para encontrar todos os usos de UUID nos apps:

```bash
# Buscar imports diretos
grep -r "import 'package:uuid/uuid.dart'" apps/*/lib

# Buscar instâncias de Uuid()
grep -r "Uuid()" apps/*/lib

# Buscar .v4()
grep -r "\.v4()" apps/*/lib
```

## ❓ FAQ

**P: Preciso registrar o UuidService no DI do meu app?**
R: Não! Ele já está registrado automaticamente no `InjectionContainer` do core.

**P: Posso ainda acessar a biblioteca uuid diretamente se precisar?**
R: Sim, em casos extremos use `uuidService.uuid` para acessar a instância Uuid, mas prefira os métodos do service.

**P: O UuidService funciona em web?**
R: Sim, a biblioteca uuid funciona em todas as plataformas Flutter.
