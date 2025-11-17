# Drift Web WASM - Configuração Global do Monorepo

## Status Geral: ✅ Configuração Completa

A implementação do Drift para web com WASM foi aplicada com sucesso em 3 aplicações do monorepo.

## Apps Configurados

### ✅ app-plantis
- **Web files**: `apps/app-plantis/web/`
- **Database**: plantis_drift.db
- **Script**: `./apps/app-plantis/run_web.sh`
- **Docs**: `apps/app-plantis/DRIFT_WEB_SETUP.md`

### ✅ app-gasometer
- **Web files**: `apps/app-gasometer/web/`
- **Database**: gasometer_drift.db
- **Script**: `./apps/app-gasometer/run_web.sh`
- **Docs**: `apps/app-gasometer/DRIFT_WEB_SETUP.md`

### ✅ app-receituagro
- **Web files**: `apps/app-receituagro/web/`
- **Database**: receituagro_drift.db
- **Script**: `./apps/app-receituagro/run_web.sh`
- **Docs**: `apps/app-receituagro/DRIFT_WEB_SETUP.md`

## Arquivos Necessários (em cada app)

Cada app tem os seguintes arquivos em sua pasta `web/`:

1. **sqlite3.wasm** (716KB)
   - Módulo WebAssembly do SQLite3
   - Download: https://github.com/simolus3/sqlite3.dart/releases

2. **drift_worker.dart** (184B)
   - Código fonte do worker
   - Compilado para drift_worker.dart.js

3. **drift_worker.dart.js** (347KB)
   - Worker JavaScript compilado
   - Gerencia banco em background thread

## Configuração Central (Core Package)

A configuração está centralizada em:
```
packages/core/lib/services/drift_disabled/drift_database_config_web.dart
```

### Código de Configuração:
```dart
static QueryExecutor createExecutor({
  required String databaseName,
  bool logStatements = false,
}) {
  return LazyDatabase(() async {
    final result = await WasmDatabase.open(
      databaseName: databaseName,
      sqlite3Uri: Uri.parse('sqlite3.wasm'),
      driftWorkerUri: Uri.parse('drift_worker.dart.js'),
    );

    if (result.missingFeatures.isNotEmpty) {
      print('⚠️ Missing features: ${result.missingFeatures}');
    }

    return result.resolvedExecutor;
  });
}
```

## Como Executar Qualquer App

### Opção 1: Com headers otimizados (melhor performance)
```bash
cd apps/<app-name>
./run_web.sh
```

### Opção 2: Sem headers (mais compatível)
```bash
cd apps/<app-name>
flutter run -d chrome
```

### Opção 3: Build para produção
```bash
cd apps/<app-name>
flutter build web
```

## Headers HTTP Opcionais

Para melhor performance, adicione em produção:
```
Cross-Origin-Opener-Policy: same-origin
Cross-Origin-Embedder-Policy: require-corp
```

**Benefícios:**
- ✅ Habilita estratégia opfsLocks (mais rápida)
- ✅ Permite uso de SharedArrayBuffer
- ✅ Melhor performance geral

**Cuidados:**
- ⚠️ Pode quebrar Google Auth (popups)
- ⚠️ Safari 16 tem bug com workers
- ⚠️ Testar antes de usar em produção

## Estratégias de Armazenamento

O Drift escolhe automaticamente (ordem de preferência):

1. **opfsShared** ⭐⭐⭐⭐⭐
   - Origin-Private FileSystem + Shared Workers
   - Melhor performance
   - Apenas Firefox

2. **opfsLocks** ⭐⭐⭐⭐
   - Origin-Private FileSystem + Headers COOP/COEP
   - Excelente performance
   - Chrome, Firefox, Edge

3. **sharedIndexedDb** ⭐⭐⭐
   - IndexedDB + Shared Worker
   - Boa performance
   - Todos os navegadores modernos

4. **unsafeIndexedDb** ⚠️
   - IndexedDB sem sincronização entre tabs
   - Evitar se possível

5. **inMemory** ❌
   - Sem persistência
   - Apenas para fallback

## Compatibilidade de Navegadores

| Navegador | Estratégia Padrão | Performance |
|-----------|------------------|-------------|
| Firefox 114+ | opfsShared | ⭐⭐⭐⭐⭐ |
| Chrome 114+ | opfsLocks* | ⭐⭐⭐⭐ |
| Safari 16.2+ | sharedIndexedDb | ⭐⭐⭐ |
| Edge | opfsLocks* | ⭐⭐⭐⭐ |

\* Com headers COOP/COEP

## Verificação Rápida

Para verificar se os arquivos estão presentes:

```bash
# Plantis
ls -lh apps/app-plantis/web/ | grep -E '(sqlite3|drift_worker)'

# Gasometer
ls -lh apps/app-gasometer/web/ | grep -E '(sqlite3|drift_worker)'

# ReceitUagro
ls -lh apps/app-receituagro/web/ | grep -E '(sqlite3|drift_worker)'
```

Cada app deve mostrar:
- sqlite3.wasm (~716KB)
- drift_worker.dart (184B)
- drift_worker.dart.js (~347KB)
- drift_worker.dart.js.deps
- drift_worker.dart.js.map

## Recompilar Worker (se necessário)

Se precisar atualizar o worker de algum app:

```bash
cd apps/<app-name>
dart compile js -O4 -o web/drift_worker.dart.js web/drift_worker.dart
```

## Troubleshooting

### Erro: "Failed to fetch sqlite3.wasm"
- ✅ Verificar se arquivo existe em `web/`
- ✅ Verificar Content-Type: application/wasm

### Erro: "Failed to load drift_worker.dart.js"
- ✅ Verificar se foi compilado
- ✅ Verificar caminhos no DriftDatabaseConfig

### Dados não persistem
- ✅ Verificar estratégia escolhida (console)
- ✅ Se inMemory, adicionar headers COOP/COEP
- ✅ Verificar erros de CORS

### Performance lenta
- ✅ Adicionar headers COOP/COEP
- ✅ Verificar estratégia no console
- ✅ Otimizar queries SQL

## Aplicar em Novos Apps

Para adicionar Drift Web em outros apps do monorepo:

1. **Baixar sqlite3.wasm:**
   ```bash
   cd apps/<app-name>/web
   curl -L -o sqlite3.wasm https://github.com/simolus3/sqlite3.dart/releases/latest/download/sqlite3.wasm
   ```

2. **Criar drift_worker.dart:**
   ```dart
   import 'package:drift/wasm.dart';
   void main() => WasmDatabase.workerMainForOpen();
   ```

3. **Compilar worker:**
   ```bash
   dart compile js -O4 -o web/drift_worker.dart.js web/drift_worker.dart
   ```

4. **Criar run_web.sh:**
   - Copiar de qualquer app já configurado
   - Atualizar nome do app

5. **Documentar:**
   - Criar DRIFT_WEB_SETUP.md

## Referências

- **Documentação Drift Web**: https://drift.simonbinder.eu/platforms/web/
- **sqlite3.dart Releases**: https://github.com/simolus3/sqlite3.dart/releases
- **Drift Releases**: https://github.com/simolus3/drift/releases
- **Core Config**: `packages/core/lib/services/drift_disabled/drift_database_config_web.dart`

## Próximos Apps a Configurar

Apps que ainda não têm Drift Web configurado:
- [ ] app-calculei
- [ ] app-minigames
- [ ] app-nebulalist
- [ ] app-nutrituti
- [ ] app-petiveti
- [ ] app-taskolist
- [ ] app-termostecnicos
- [ ] app-agrihurbi

## Observações Importantes

1. **Todos os apps usam a mesma configuração** do pacote `core`
2. **Cada app tem seus próprios arquivos WASM** em `web/`
3. **O worker é idêntico** em todos os apps
4. **Headers COOP/COEP são opcionais** mas recomendados

---

**Data de Configuração**: 17 de novembro de 2025  
**Versão Drift**: 2.28.2  
**Versão sqlite3**: 0.4.1  
**Status**: ✅ 3 de 12 apps configurados
