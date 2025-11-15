# Diagnóstico: Erro WASM no app-gasometer Web

## 🔍 Análise do Erro

**Erro Original**:
```
TypeError: WebAssembly.instantiate(): Import #0 "a": module is not an object or function
```

**Stack Trace**: Aponta para `vehicle_repository_drift_impl.dart:44`

## 🏥 Diagnóstico Sistemático

### 1. Assets Configuration (CRÍTICO)
- ✅ **Status**: CORRIGIDO
- **Mudança**: Ativar `web/sqlite3.wasm` no pubspec.yaml
- **Por quê**: Flutter precisa compilar e servir o arquivo WASM

### 2. Database Configuration
- **Arquivo**: `packages/core/lib/services/drift_disabled/drift_database_config_web.dart`
- **Status**: Verificado ✅
- **Configuração**:
  ```dart
  sqlite3Uri: Uri.parse('/sqlite3.wasm'),      // Web server root
  driftWorkerUri: Uri.parse('/drift_worker.dart.js'), // Web server root
  ```

### 3. Worker Script (drift_worker.dart)
- **Arquivo**: `apps/app-gasometer/web/drift_worker.dart`
- **Status**: Alinhado com receituagro (que funciona)
- **Configuração**:
  ```dart
  sqlite3Uri: Uri.parse('sqlite3.wasm'),  // Relativo ao worker
  ```

## 🔧 Correção Aplicada

### Change 1: Ativar Assets
```yaml
# pubspec.yaml
flutter:
  assets:
    - web/sqlite3.wasm
```

### Change 2: Sincronizar URIs
- `drift_database_config_web.dart`: `/sqlite3.wasm` (absoluto, serve pelo web root)
- `drift_worker.dart`: `sqlite3.wasm` (relativo, serve do worker)
- Isso é correto porque:
  - Main app carrega de root: `/sqlite3.wasm`
  - Worker carrega do seu contexto: `sqlite3.wasm`

## ✅ Validação Necessária

### Build Step
```bash
cd apps/app-gasometer
flutter clean
flutter pub get
flutter build web --debug 2>&1 | tee build.log
```

**Verificar no build.log**:
- Nenhum erro de assets
- Arquivo web/build/sqlite3.wasm existe (>600KB)
- Arquivo web/build/drift_worker.dart.js existe

### Runtime Step
```bash
flutter run -d web  # Abra DevTools (F12)
```

**Verificar no Console (F12 > Console)**:
```
✅ "📱 Detected: Web platform - using WASM + IndexedDB"
✅ "🔧 Initializing Drift WASM database: gasometer_drift.db"
❌ Não deve ter: "Failed to initialize"
```

### Network Step (F12 > Network)
```
GET /sqlite3.wasm         → 200 OK (600KB+)
GET /drift_worker.dart.js → 200 OK
```

## 🚨 Se Ainda Falhar

### Possível Causa 1: Web Server Configuration
```
❌ Servidor não serve static files com tipo correto
✅ Solução: Configurar CORS e Content-Type headers
```

### Possível Causa 2: Browser Cache
```
❌ Browser usando versão antiga do arquivo
✅ Solução: Limpar cache (Ctrl+Shift+Delete) e hard refresh (Ctrl+F5)
```

### Possível Causa 3: WASM Support
```
❌ Browser antigo sem suporte a WASM
✅ Solução: Implementar fallback (veja DRIFT_WEB_SETUP.md)
```

## 📋 Checklist Final

- [x] Assets declarados no pubspec.yaml
- [x] URIs configuradas corretamente
- [x] Sincronizado com receituagro pattern
- [ ] Build validado (`flutter build web --debug`)
- [ ] Runtime validado (`flutter run -d web`)
- [ ] Network verificado (DevTools > Network)
- [ ] Console verificado (DevTools > Console)

## 🔗 Referências

- Core Config: `packages/core/lib/services/drift_disabled/drift_database_config_web.dart`
- Worker: `apps/app-gasometer/web/drift_worker.dart`
- Setup Guide: `packages/core/lib/services/drift_disabled/DRIFT_WEB_SETUP.md`
- Adapter: `packages/core/lib/services/drift_disabled/database_executor_adapter.dart`

## 🎯 Próximo Passo

Executar validação de build e runtime para confirmar se problema está resolvido.
