# Drift Web Setup - Guia Completo

## 🔍 Requisitos para Web Support

Para que Drift funcione na web, é necessário:

### 1. Assets no pubspec.yaml
```yaml
flutter:
  uses-material-design: true
  assets:
    - web/sqlite3.wasm  # ✅ OBRIGATÓRIO
```

### 2. Arquivos na pasta web/
```
web/
├── sqlite3.wasm       # ✅ Arquivo WASM (gerado pelo build)
├── drift_worker.dart  # ✅ Worker script (compilado para .js)
└── index.html         # ✅ HTML principal
```

### 3. Configuração correta de URIs
```dart
// ✅ CORRETO - Com "/" no início
sqlite3Uri: Uri.parse('/sqlite3.wasm'),
driftWorkerUri: Uri.parse('/drift_worker.dart.js'),

// ❌ ERRADO - Sem "/" causa TypeError
sqlite3Uri: Uri.parse('sqlite3.wasm'),  // Falha!
```

## 🐛 Erros Comuns e Soluções

### Erro: "TypeError: WebAssembly.instantiate(): Import #0 "a": module is not an object or function"

**Causa**: URIs incorretas ou assets não declarados

**Soluções**:
1. Verificar `pubspec.yaml` - `web/sqlite3.wasm` deve estar em `assets:`
2. Verificar `drift_worker.dart` - URIs devem começar com `/`
3. Executar `flutter clean` antes de rebuild
4. Limpar cache do navegador (Ctrl+Shift+Delete)

### Erro: "Cannot find module 'drift_worker.dart.js'"

**Causa**: drift_worker.dart não foi compilado para JavaScript

**Solução**:
```bash
flutter clean
flutter pub get
flutter build web --debug  # Força recompilação
```

### Erro: "Failed to fetch resource"

**Causa**: Files not being served from correct path

**Verificar**:
1. arquivo `web/sqlite3.wasm` existe (>600KB)
2. Servidor está rodando na porta correta
3. CORS está configurado se necessário

## ✅ Checklist de Implementação

- [ ] `assets: - web/sqlite3.wasm` no pubspec.yaml
- [ ] `Uri.parse('/sqlite3.wasm')` no drift config (com /)
- [ ] `Uri.parse('/drift_worker.dart.js')` no drift config (com /)
- [ ] Arquivo `web/sqlite3.wasm` existe (>600KB)
- [ ] Arquivo `web/drift_worker.dart` existe
- [ ] `flutter clean` executado
- [ ] `flutter pub get` executado

## 🚀 Teste Local

```bash
# 1. Limpar tudo
flutter clean && flutter pub get

# 2. Build web
flutter build web --debug

# 3. Rodar em web
flutter run -d web

# 4. Verificar console (F12 > Console)
# Procurar por:
# ✅ "🔧 Initializing Drift WASM database"
# ✅ "✅ Drift WASM database initialized successfully"
```

## 🛡️ Fallback a Firestore (Optional)

Se WASM não funcionar em produção, use Firestore como fallback:

```dart
// future implementation
class DatabaseAdapter {
  static Future<QueryExecutor> getExecutor({
    required String databaseName,
    bool allowWebFallback = true,
  }) async {
    try {
      // Tenta Drift WASM
      return await _getDriftExecutor(databaseName);
    } catch (e) {
      if (allowWebFallback && kIsWeb) {
        // Fallback para Firestore em web
        return _getFirestoreExecutor(databaseName);
      }
      rethrow;
    }
  }
}
```

## 📚 Documentação Oficial

- [Drift Web Documentation](https://drift.simonbinder.eu/web/)
- [WASM / IndexedDB Setup](https://drift.simonbinder.eu/web/)
- [Flutter Web Best Practices](https://flutter.dev/docs/get-started/web)

## 🔗 Referências no Monorepo

- **Config Web**: `packages/core/lib/services/drift_disabled/drift_database_config_web.dart`
- **Config Mobile**: `packages/core/lib/services/drift_disabled/drift_database_config_mobile.dart`
- **Base Database**: `packages/core/lib/services/drift_disabled/base_drift_database.dart`
- **App Gasometer**: `apps/app-gasometer/pubspec.yaml` e `web/drift_worker.dart`
