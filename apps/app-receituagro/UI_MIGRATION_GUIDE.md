# Guia de Migração de UI: Hive → Drift

## 📋 Índice

1. [Visão Geral](#visão-geral)
2. [Conversão Passo a Passo](#conversão-passo-a-passo)
3. [Exemplos Práticos](#exemplos-práticos)
4. [Providers Disponíveis](#providers-disponíveis)
5. [Troubleshooting](#troubleshooting)

---

## Visão Geral

A migração de Hive para Drift na UI envolve:
1. Trocar `ValueListenableBuilder` por `ConsumerWidget` + Riverpod
2. Usar streams reativos ao invés de observadores de box
3. Aproveitar JOINs para evitar múltiplas queries
4. Simplificar error handling e loading states

---

## Conversão Passo a Passo

### Passo 1: Trocar Widget Base

```dart
// ❌ ANTES
class MinhaLista extends StatelessWidget {
  const MinhaLista({super.key});

  @override
  Widget build(BuildContext context) {
    // ...
  }
}

// ✅ DEPOIS
class MinhaLista extends ConsumerWidget {
  const MinhaLista({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // ...
  }
}
```

### Passo 2: Substituir ValueListenableBuilder

```dart
// ❌ ANTES (Hive)
return ValueListenableBuilder<Box<DiagnosticoHive>>(
  valueListenable: Hive.box<DiagnosticoHive>('diagnosticos').listenable(),
  builder: (context, box, _) {
    final diagnosticos = box.values.toList();

    return ListView.builder(
      itemCount: diagnosticos.length,
      itemBuilder: (context, index) {
        final diag = diagnosticos[index];
        return ListTile(title: Text(diag.nomeDefensivo ?? ''));
      },
    );
  },
);

// ✅ DEPOIS (Drift + Riverpod)
final diagnosticosAsync = ref.watch(diagnosticosStreamProvider(userId));

return diagnosticosAsync.when(
  data: (diagnosticos) => ListView.builder(
    itemCount: diagnosticos.length,
    itemBuilder: (context, index) {
      final diag = diagnosticos[index];
      return ListTile(title: Text(diag.dsMax));
    },
  ),
  loading: () => const CircularProgressIndicator(),
  error: (err, _) => Text('Erro: $err'),
);
```

### Passo 3: Operações de CRUD

```dart
// ❌ ANTES (Hive)
final box = await Hive.openBox<DiagnosticoHive>('diagnosticos');
final diagnostico = DiagnosticoHive(...);
await box.add(diagnostico);
await box.close(); // Sempre esquecer de fechar!

// ✅ DEPOIS (Drift + Riverpod)
final repo = ref.read(diagnosticoRepositoryProvider);
final diagnostico = DiagnosticoData(...);
await repo.insert(diagnostico);
// Stream atualiza automaticamente a UI! 🎉
```

### Passo 4: Remover Imports Hive

```dart
// ❌ REMOVER
import 'package:hive/hive.dart';
import 'package:hive_flutter/hive_flutter.dart';
import '../../core/data/models/diagnostico_hive.dart';

// ✅ ADICIONAR
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../database/providers/database_providers.dart';
import '../../database/repositories/repositories.dart';
```

---

## Exemplos Práticos

### Exemplo 1: Lista Simples de Diagnósticos

```dart
class DiagnosticosList extends ConsumerWidget {
  const DiagnosticosList({super.key, required this.userId});

  final String userId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final diagnosticosAsync = ref.watch(diagnosticosStreamProvider(userId));

    return diagnosticosAsync.when(
      data: (diagnosticos) {
        if (diagnosticos.isEmpty) {
          return const Center(
            child: Text('Nenhum diagnóstico encontrado'),
          );
        }

        return ListView.builder(
          itemCount: diagnosticos.length,
          itemBuilder: (context, index) {
            final diag = diagnosticos[index];
            return Card(
              child: ListTile(
                title: Text(diag.dsMax),
                subtitle: Text('${diag.dsMin ?? ''} - ${diag.dsMax} ${diag.um}'),
                trailing: IconButton(
                  icon: const Icon(Icons.delete),
                  onPressed: () => _deleteDiagnostico(ref, diag.id),
                ),
              ),
            );
          },
        );
      },
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (error, stack) => Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error, size: 48, color: Colors.red),
            const SizedBox(height: 16),
            Text('Erro ao carregar: $error'),
          ],
        ),
      ),
    );
  }

  Future<void> _deleteDiagnostico(WidgetRef ref, int id) async {
    final repo = ref.read(diagnosticoRepositoryProvider);
    await repo.softDelete(id);
    // UI atualiza automaticamente via stream!
  }
}
```

### Exemplo 2: Lista com Dados Relacionados (JOIN)

```dart
class DiagnosticosEnrichedList extends ConsumerWidget {
  const DiagnosticosEnrichedList({super.key, required this.userId});

  final String userId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Este stream já traz defensivo + cultura + praga (1 query!)
    final diagnosticosAsync = ref.watch(
      diagnosticosEnrichedStreamProvider(userId),
    );

    return diagnosticosAsync.when(
      data: (diagnosticos) => ListView.builder(
        itemCount: diagnosticos.length,
        itemBuilder: (context, index) {
          final enriched = diagnosticos[index];
          final diag = enriched.diagnostico;
          final defensivo = enriched.defensivo;
          final cultura = enriched.cultura;
          final praga = enriched.praga;

          return Card(
            margin: const EdgeInsets.all(8),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    defensivo?.nome ?? 'Defensivo não identificado',
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      const Icon(Icons.agriculture, size: 16),
                      const SizedBox(width: 4),
                      Text('Cultura: ${cultura?.nome ?? 'N/A'}'),
                    ],
                  ),
                  Row(
                    children: [
                      const Icon(Icons.bug_report, size: 16),
                      const SizedBox(width: 4),
                      Text('Praga: ${praga?.nome ?? 'N/A'}'),
                    ],
                  ),
                  const Divider(),
                  Text('Dosagem: ${diag.dsMax} ${diag.um}'),
                  if (diag.epocaAplicacao != null)
                    Text('Época: ${diag.epocaAplicacao}'),
                ],
              ),
            ),
          );
        },
      ),
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (err, _) => Center(child: Text('Erro: $err')),
    );
  }
}
```

### Exemplo 3: Botão de Favorito

```dart
class FavoritoButton extends ConsumerWidget {
  const FavoritoButton({
    super.key,
    required this.userId,
    required this.tipo,
    required this.itemId,
    required this.itemData,
  });

  final String userId;
  final String tipo;
  final String itemId;
  final String itemData; // JSON cache

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isFavoritedAsync = ref.watch(
      isFavoritedProvider(
        userId: userId,
        tipo: tipo,
        itemId: itemId,
      ),
    );

    return isFavoritedAsync.when(
      data: (isFavorited) => IconButton(
        icon: Icon(
          isFavorited ? Icons.favorite : Icons.favorite_border,
          color: isFavorited ? Colors.red : Colors.grey,
        ),
        onPressed: () => _toggleFavorito(ref, isFavorited),
      ),
      loading: () => const IconButton(
        icon: Icon(Icons.favorite_border, color: Colors.grey),
        onPressed: null,
      ),
      error: (_, __) => const Icon(Icons.error, color: Colors.red),
    );
  }

  Future<void> _toggleFavorito(WidgetRef ref, bool isFavorited) async {
    final repo = ref.read(favoritoRepositoryProvider);

    if (isFavorited) {
      // Remover
      await repo.removeFavorito(userId, tipo, itemId);
    } else {
      // Adicionar
      await repo.insert(
        FavoritoData(
          id: 0,
          userId: userId,
          moduleName: 'receituagro',
          createdAt: DateTime.now(),
          isDirty: true,
          isDeleted: false,
          version: 1,
          tipo: tipo,
          itemId: itemId,
          itemData: itemData,
        ),
      );
    }

    // Invalida cache para refetch
    ref.invalidate(
      isFavoritedProvider(userId: userId, tipo: tipo, itemId: itemId),
    );
  }
}
```

### Exemplo 4: Formulário de Criar Diagnóstico

```dart
class CreateDiagnosticoForm extends ConsumerStatefulWidget {
  const CreateDiagnosticoForm({super.key, required this.userId});

  final String userId;

  @override
  ConsumerState<CreateDiagnosticoForm> createState() => _CreateDiagnosticoFormState();
}

class _CreateDiagnosticoFormState extends ConsumerState<CreateDiagnosticoForm> {
  final _formKey = GlobalKey<FormState>();
  int? _defensivoId;
  int? _culturaId;
  int? _pragaId;
  String _dsMax = '';
  String _um = 'L/ha';

  @override
  Widget build(BuildContext context) {
    return Form(
      key: _formKey,
      child: Column(
        children: [
          // TODO: Dropdowns para selecionar defensivo, cultura, praga
          TextFormField(
            decoration: const InputDecoration(labelText: 'Dosagem Máxima'),
            validator: (value) =>
                value?.isEmpty ?? true ? 'Campo obrigatório' : null,
            onSaved: (value) => _dsMax = value!,
          ),
          TextFormField(
            decoration: const InputDecoration(labelText: 'Unidade de Medida'),
            initialValue: _um,
            onSaved: (value) => _um = value!,
          ),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: _submit,
            child: const Text('Salvar'),
          ),
        ],
      ),
    );
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    _formKey.currentState!.save();

    final repo = ref.read(diagnosticoRepositoryProvider);

    final novoDiagnostico = DiagnosticoData(
      id: 0,
      userId: widget.userId,
      moduleName: 'receituagro',
      createdAt: DateTime.now(),
      isDirty: true,
      isDeleted: false,
      version: 1,
      defenisivoId: _defensivoId!,
      culturaId: _culturaId!,
      pragaId: _pragaId!,
      idReg: 'diag_${DateTime.now().millisecondsSinceEpoch}',
      dsMax: _dsMax,
      um: _um,
    );

    try {
      final id = await repo.insert(novoDiagnostico);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Diagnóstico criado com ID: $id')),
        );
        Navigator.of(context).pop();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Erro ao criar: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }
}
```

### Exemplo 5: Contador com FutureProvider

```dart
class DiagnosticosCountBadge extends ConsumerWidget {
  const DiagnosticosCountBadge({super.key, required this.userId});

  final String userId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final countAsync = ref.watch(diagnosticosCountProvider(userId));

    return countAsync.when(
      data: (count) => Badge(
        label: Text('$count'),
        child: const Icon(Icons.list),
      ),
      loading: () => const Badge(
        label: Text('...'),
        child: Icon(Icons.list),
      ),
      error: (_, __) => const Badge(
        label: Text('!'),
        backgroundColor: Colors.red,
        child: Icon(Icons.list),
      ),
    );
  }
}
```

---

## Providers Disponíveis

### Database Provider
```dart
@riverpod
ReceituagroDatabase database(Ref ref)
```

### Repository Providers
```dart
@riverpod
DiagnosticoRepository diagnosticoRepository(Ref ref)

@riverpod
FavoritoRepository favoritoRepository(Ref ref)

@riverpod
ComentarioRepository comentarioRepository(Ref ref)
```

### Stream Providers (Reactive)

#### Diagnósticos
```dart
@riverpod
Stream<List<DiagnosticoData>> diagnosticosStream(Ref ref, String userId)

@riverpod
Stream<List<DiagnosticoEnriched>> diagnosticosEnrichedStream(Ref ref, String userId)
```

#### Favoritos
```dart
@riverpod
Stream<List<FavoritoData>> favoritosStream(Ref ref, String userId)

@riverpod
Stream<List<FavoritoData>> favoritosByTypeStream(Ref ref, {String userId, String tipo})
```

#### Comentários
```dart
@riverpod
Stream<List<ComentarioData>> comentariosStream(Ref ref, String itemId)

@riverpod
Stream<List<ComentarioData>> comentariosUserStream(Ref ref, String userId)
```

### Future Providers (One-time fetch)

```dart
@riverpod
Future<List<DiagnosticoData>> diagnosticosRecent(Ref ref, {String userId, int limit})

@riverpod
Future<bool> isFavorited(Ref ref, {String userId, String tipo, String itemId})

@riverpod
Future<int> comentariosCount(Ref ref, String itemId)

@riverpod
Future<int> diagnosticosCount(Ref ref, String userId)

@riverpod
Future<Map<String, int>> favoritosCountByType(Ref ref, String userId)
```

---

## Troubleshooting

### Problema: "No provider found for X"

**Causa**: GetIt não encontrou o repositório

**Solução**:
```bash
dart run build_runner build --delete-conflicting-outputs
```

Depois verifique que `injection.config.dart` foi regenerado.

---

### Problema: Stream não atualiza UI

**Causa**: Usando `ref.read()` ao invés de `ref.watch()`

**Solução**:
```dart
// ❌ ERRADO
final diagnosticos = ref.read(diagnosticosStreamProvider(userId));

// ✅ CORRETO
final diagnosticos = ref.watch(diagnosticosStreamProvider(userId));
```

---

### Problema: "Bad state: Stream has already been listened to"

**Causa**: Tentando observar o mesmo stream duas vezes

**Solução**: Use um único `ref.watch()` e passe os dados para child widgets

---

### Problema: Foreign key constraint failed

**Causa**: Tentando inserir diagnóstico com IDs de defensivo/cultura/praga inválidos

**Solução**: Certifique-se que as tabelas estáticas foram populadas:
```dart
final culturas = await db.getAllCulturas();
if (culturas.isEmpty) {
  // Popular dados estáticos primeiro
}
```

---

### Problema: Dados não aparecem após migração

**Causa**: Migration tool ainda não foi executado

**Solução**:
```dart
final tool = HiveToDriftMigrationTool(
  hiveManager: getIt<IHiveManager>(),
  database: getIt<ReceituagroDatabase>(),
);

final result = await tool.migrate();
print(result.summary);
```

---

## Checklist de Conversão por Tela

- [ ] Trocar `StatelessWidget` → `ConsumerWidget`
- [ ] Adicionar `WidgetRef ref` ao `build()`
- [ ] Substituir `ValueListenableBuilder` por `ref.watch()`
- [ ] Adicionar `.when()` para loading/data/error
- [ ] Trocar operações de CRUD para usar repositórios
- [ ] Remover imports de Hive
- [ ] Remover `await Hive.openBox()` / `box.close()`
- [ ] Testar CRUD end-to-end
- [ ] Verificar loading states
- [ ] Verificar error handling
- [ ] Testar reatividade (mudanças refletem automaticamente)

---

## Benefícios da Migração

✅ **Type Safety**: Erros em compile-time
✅ **Performance**: JOINs ao invés de N+1 queries
✅ **Reactive UI**: Streams automáticos
✅ **Error Handling**: Built-in com `.when()`
✅ **Loading States**: Automáticos
✅ **No setState()**: Riverpod gerencia estado
✅ **Cache**: Automático via Riverpod
✅ **Foreign Keys**: Integridade referencial

---

**Última Atualização**: 2025-11-10
**Referências**:
- `lib/database/examples/ui_integration_example.dart`
- `lib/database/providers/database_providers.dart`
