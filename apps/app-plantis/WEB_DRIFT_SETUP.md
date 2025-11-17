# Drift Web Setup - App Plantis

## Configuração do Drift para Web com WASM

Este documento explica como o Drift foi configurado para funcionar na versão web do app-plantis.

## Arquivos Necessários

### 1. sqlite3.wasm
- **Localização**: `web/sqlite3.wasm`
- **Descrição**: Módulo WebAssembly do SQLite3
- **Download**: https://github.com/simolus3/sqlite3.dart/releases/latest/download/sqlite3.wasm
- **Tamanho**: ~715KB
- **Content-Type**: `application/wasm` (importante para o servidor servir corretamente)

### 2. drift_worker.dart.js
- **Localização**: `web/drift_worker.dart.js`
- **Descrição**: Worker JavaScript que gerencia o banco de dados em background
- **Compilação**: 
  ```bash
  dart compile js -O4 -o web/drift_worker.dart.js web/drift_worker.dart
  ```
- **Código fonte**: `web/drift_worker.dart`

## Configuração no Core

O pacote `core` contém a configuração para web em:
- `packages/core/lib/services/drift_disabled/drift_database_config_web.dart`

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

## Estratégias de Armazenamento

O Drift escolhe automaticamente a melhor estratégia de armazenamento baseada nas APIs disponíveis:

1. **opfsShared** (melhor): Origin-Private FileSystem + Shared Workers
2. **opfsLocks**: Origin-Private FileSystem + COOP/COEP headers
3. **sharedIndexedDb**: IndexedDB + Shared Worker
4. **unsafeIndexedDb**: IndexedDB sem sincronização entre tabs (evitar)
5. **inMemory**: Na memória (sem persistência)

## Headers Opcionais (Para melhor performance)

Para habilitar a estratégia `opfsLocks` (melhor performance), adicione estes headers HTTP:

```
Cross-Origin-Opener-Policy: same-origin
Cross-Origin-Embedder-Policy: require-corp
```

### Durante o desenvolvimento:
```bash
flutter run -d chrome --web-header=Cross-Origin-Opener-Policy=same-origin --web-header=Cross-Origin-Embedder-Policy=require-corp
```

### Em produção:
Configure seu servidor web (nginx, Apache, Firebase Hosting, etc.) para adicionar esses headers.

**⚠️ ATENÇÃO**: Esses headers podem quebrar integrações com Google Auth e outros serviços que abrem popups. Teste cuidadosamente antes de habilitar em produção.

## Verificação dos Arquivos

Execute para verificar se os arquivos estão presentes:

```bash
ls -lh web/
# Deve mostrar:
# - sqlite3.wasm (~715KB)
# - drift_worker.dart.js (~356KB)
```

## Como Recompilar o Worker

Se precisar atualizar o worker:

```bash
cd /path/to/app-plantis
dart compile js -O4 -o web/drift_worker.dart.js web/drift_worker.dart
```

## Troubleshooting

### Erro: "Failed to fetch sqlite3.wasm"
- Verifique se `sqlite3.wasm` está em `web/`
- Verifique se o servidor está servindo com `Content-Type: application/wasm`

### Erro: "Failed to load drift_worker.dart.js"
- Verifique se o arquivo foi compilado corretamente
- Verifique os caminhos no `DriftDatabaseConfig`

### Banco não persiste entre recarregamentos
- Verifique qual implementação o Drift escolheu via `result.chosenImplementation`
- Se for `inMemory` ou `unsafeIndexedDb`, considere adicionar os headers COOP/COEP

### Performance lenta na web
- Habilite os headers COOP/COEP para usar `opfsLocks`
- Verifique se há queries ineficientes sendo executadas
- Use índices nas tabelas quando apropriado

## Referências

- Documentação oficial Drift Web: https://drift.simonbinder.eu/platforms/web/
- sqlite3.dart releases: https://github.com/simolus3/sqlite3.dart/releases
- Drift releases: https://github.com/simolus3/drift/releases

## Status Atual

✅ sqlite3.wasm baixado e configurado
✅ drift_worker.dart.js compilado
✅ DriftDatabaseConfig atualizado no core
✅ Pronto para uso na web

## Próximos Passos

1. Testar a aplicação web com:
   ```bash
   flutter run -d chrome
   ```

2. Verificar no console do navegador qual implementação foi escolhida

3. Testar persistência dos dados entre recarregamentos

4. (Opcional) Adicionar headers COOP/COEP para melhor performance
