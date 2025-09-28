# Guia de Execução da Migração do UnifiedSyncManager

## 📋 Visão Geral

Este guia detalha como executar a migração gradual do **UnifiedSyncManager** (arquitetura legacy) para a nova **arquitetura SOLID** com app-specific sync services.

A migração foi projetada para ser **zero-downtime** e permite rollback completo caso necessário.

## 🏗️ Arquitetura da Migração

### Componentes Principais

1. **LegacySyncBridge** - Ponte que roteia chamadas entre legacy e nova arquitetura
2. **AppMigrationHelper** - Gerencia migração individual de cada app  
3. **MigrationCLI** - Interface para executar comandos de migração
4. **SyncFeatureFlags** - Feature flags para controlar qual arquitetura usar

### Apps Suportados

- **gasometer** - Controle de veículos
- **plantis** - Cuidado de plantas  
- **receituagro** - Diagnósticos agrícolas
- **petiveti** - Cuidado de pets

## 🚀 Execução Passo a Passo

### Pré-requisitos

```dart
// Inicializar a CLI de migração
await MigrationCLI.instance.initialize();
```

### Passo 1: Verificar Status Geral

```dart
// Ver status atual de todos os apps
final status = await MigrationCLI.instance.commandStatus();
print(status);
```

**Output Esperado:**
```json
{
  "migration_cli_version": "1.0.0",
  "timestamp": "2025-09-28T...",
  "feature_flags": {
    "use_new_sync_orchestrator": false,
    "enabled_apps": []
  },
  "apps": {
    "gasometer": {
      "current_architecture": "legacy",
      "migration_completed": false,
      "feature_flag_enabled": false,
      "last_sync": "2025-09-28T...",
      "total_syncs": 42,
      "success_rate": "95.2%"
    }
  },
  "summary": {
    "total_apps": 4,
    "migrated_apps": 0,
    "pending_migration": 4
  }
}
```

### Passo 2: Verificar Compatibilidade de um App

```dart
// Verificar se o app está pronto para migração
final compatibility = await MigrationCLI.instance.commandCheck('gasometer');
print(compatibility);
```

**Output Esperado:**
```json
{
  "app": "gasometer",
  "service_id": "gasometer",
  "is_compatible": true,
  "connectivity_ok": true,
  "can_sync": true,
  "has_pending_data": false,
  "test_sync_successful": true,
  "migration_risks": [],
  "recommended_migration_time": "2025-09-29T03:00:00.000Z",
  "migration_steps": [
    "Verificar compatibilidade do app gasometer",
    "Fazer backup do estado atual",
    "Ativar feature flag para nova arquitetura",
    "Executar sync de teste com nova arquitetura",
    "Validar resultados do sync",
    "Confirmar migração ou fazer rollback"
  ],
  "recommendation": "HIGHLY RECOMMENDED - No risks detected, safe to migrate immediately"
}
```

### Passo 3: Executar Migração de Teste (Dry Run)

```dart
// Simular migração sem executar mudanças reais
final dryRun = await MigrationCLI.instance.commandMigrate(
  'gasometer', 
  dryRun: true
);
print(dryRun);
```

**Output Esperado:**
```json
{
  "app": "gasometer",
  "action": "migrate",
  "success": true,
  "dry_run": true,
  "duration_ms": 1250,
  "steps": [
    {
      "name": "backup_current_state",
      "description": "Backup do estado atual do UnifiedSyncManager (DRY RUN)",
      "status": "skipped",
      "timestamp": "2025-09-28T..."
    },
    {
      "name": "test_new_architecture", 
      "description": "Teste da nova arquitetura (DRY RUN)",
      "status": "skipped",
      "timestamp": "2025-09-28T..."
    }
  ],
  "next_steps": [
    "Dry run successful - ready for real migration",
    "Execute migration without dryRun flag",
    "Monitor app behavior after migration"
  ]
}
```

### Passo 4: Executar Migração Real

```dart
// Executar migração real
final migration = await MigrationCLI.instance.commandMigrate('gasometer');
print(migration);
```

**Output Esperado:**
```json
{
  "app": "gasometer",
  "action": "migrate", 
  "success": true,
  "dry_run": false,
  "duration_ms": 2100,
  "steps": [
    {
      "name": "backup_current_state",
      "description": "Backup do estado atual do UnifiedSyncManager",
      "status": "completed",
      "timestamp": "2025-09-28T..."
    },
    {
      "name": "enable_feature_flag",
      "description": "Feature flag ativada para gasometer", 
      "status": "completed",
      "timestamp": "2025-09-28T..."
    },
    {
      "name": "test_new_architecture",
      "description": "Teste da nova arquitetura SUCESSO",
      "status": "completed", 
      "timestamp": "2025-09-28T..."
    },
    {
      "name": "final_validation",
      "description": "Validação final da migração",
      "status": "completed",
      "timestamp": "2025-09-28T..."
    }
  ],
  "new_service_stats": {
    "service_id": "gasometer",
    "total_syncs": 1,
    "success_rate": "100.0%"
  },
  "next_steps": [
    "Migration completed successfully",
    "Monitor app sync behavior", 
    "Consider migrating other apps",
    "Plan UnifiedSyncManager removal after all apps migrated"
  ]
}
```

### Passo 5: Verificar Status Pós-Migração

```dart
// Confirmar que migração foi bem sucedida
final postStatus = await MigrationCLI.instance.commandStatus();
print(postStatus['apps']['gasometer']);
```

**Output Esperado:**
```json
{
  "current_architecture": "new",
  "migration_completed": true,
  "feature_flag_enabled": true,
  "last_sync": "2025-09-28T...",
  "total_syncs": 1,
  "success_rate": "100.0%"
}
```

## 🔄 Rollback (Se Necessário)

```dart
// Fazer rollback para arquitetura legacy
final rollback = await MigrationCLI.instance.commandRollback('gasometer');
print(rollback);
```

**Output Esperado:**
```json
{
  "app": "gasometer",
  "action": "rollback",
  "success": true,
  "message": "App gasometer rolled back to legacy UnifiedSyncManager",
  "timestamp": "2025-09-28T..."
}
```

## 🎛️ Controle de Feature Flags

### Ativar Feature Flags Globalmente

```dart
// Ativar nova arquitetura para todos os apps com flag ativada
final enable = await MigrationCLI.instance.commandEnableFlags();
print(enable);
```

### Desativar Feature Flags Globalmente  

```dart
// Desativar nova arquitetura - todos voltam para legacy
final disable = await MigrationCLI.instance.commandDisableFlags();
print(disable);
```

## 📊 Monitoramento Durante Migração

### Verificar Logs

```dart
// Durante a migração, logs são emitidos para debugging
// Usar developer.log com name: 'MigrationCLI', 'AppMigrationHelper', etc.
```

### Testar Sync Após Migração

```dart
// Testar sync do app migrado usando LegacySyncBridge
final syncResult = await LegacySyncBridge.instance.forceSyncApp('gasometer');
print(syncResult);
```

## 🔧 Cenários de Migração

### Cenário 1: Migração Gradual (Recomendado)

1. Migrar **gasometer** primeiro (menor complexidade)
2. Migrar **plantis** (teste com fotos/imagens)  
3. Migrar **receituagro** (grande volume de dados estáticos)
4. Migrar **petiveti** por último

### Cenário 2: Migração Simultânea

```dart
// Ativar feature flags globalmente
await MigrationCLI.instance.commandEnableFlags();

// Migrar todos os apps
for (final app in ['gasometer', 'plantis', 'receituagro', 'petiveti']) {
  final result = await MigrationCLI.instance.commandMigrate(app);
  if (!result['success']) {
    // Rollback se algum falhar
    await MigrationCLI.instance.commandRollback(app);
  }
}
```

### Cenário 3: Migração Forçada (Para apps com problemas)

```dart
// Migrar mesmo com riscos detectados
final migration = await MigrationCLI.instance.commandMigrate(
  'problematic_app',
  force: true
);
```

## ⚠️ Tratamento de Erros

### Erros Comuns e Soluções

#### 1. App não compatível
```json
{
  "error": "App not compatible for migration. Use --force to override.",
  "compatibility_check": {
    "migration_risks": ["Possui dados pendentes de sincronização"]
  }
}
```
**Solução:** Executar sync antes da migração ou usar `force: true`

#### 2. Teste de nova arquitetura falhou
```json
{
  "steps": [
    {
      "name": "test_new_architecture",
      "status": "failed",
      "error": "New architecture sync failed"
    }
  ]
}
```
**Solução:** Verificar logs, corrigir problemas e tentar novamente

#### 3. Feature flag não ativada
```json
{
  "current_architecture": "legacy",
  "feature_flag_enabled": false
}
```
**Solução:** Ativar feature flags globalmente primeiro

## 🗑️ Remoção Final do UnifiedSyncManager

**⚠️ APENAS APÓS TODOS OS APPS MIGRADOS:**

1. Verificar que todos os apps estão usando nova arquitetura
2. Remover imports do UnifiedSyncManager dos apps
3. Deprecar classe UnifiedSyncManager
4. Remover UnifiedSyncManager em release futura

## 📱 Integração nos Apps

### Como usar no App

```dart
// No app (ex: gasometer), substituir:
// UnifiedSyncManager.instance.forceSyncApp('gasometer')

// Por:
LegacySyncBridge.instance.forceSyncApp('gasometer')

// O LegacySyncBridge automaticamente roteia para nova ou legacy arquitetura
// baseado nas feature flags, sem quebrar código existente
```

### Exemplo de Integração Completa

```dart
class GasometerSyncManager {
  static Future<void> performSync() async {
    try {
      // Usar bridge que automaticamente escolhe arquitetura
      final result = await LegacySyncBridge.instance.forceSyncApp('gasometer');
      
      result.fold(
        (failure) => print('Sync failed: ${failure.message}'),
        (success) => print('Sync completed successfully'),
      );
      
    } catch (e) {
      print('Sync error: $e');
    }
  }
}
```

## 🆘 Ajuda e Debug

```dart
// Ver comandos disponíveis
final help = MigrationCLI.instance.commandHelp();
print(help);

// Ver status detalhado de um app específico
final appStatus = await LegacySyncBridge.instance.getAppSyncStatus('gasometer');
print(appStatus);

// Ver status de todos os apps no bridge
final allStatus = LegacySyncBridge.instance.getAllAppsStatus();
print(allStatus);
```

---

**✅ Migração Zero-Downtime Completa**

Este sistema permite migração gradual e segura do UnifiedSyncManager legacy para a nova arquitetura SOLID, com possibilidade de rollback a qualquer momento e sem interrupção do funcionamento dos apps.