# Troubleshooting Guide - Financial Sync Features
## App Gasometer - Resolução de Problemas Específicos

### 🎯 OVERVIEW

Este guia foca especificamente nos problemas relacionados às **features financeiras** do sistema de sincronização do app-gasometer, incluindo validação monetária, audit trail e resolução manual de conflitos.

---

## 💰 FINANCIAL VALIDATOR ISSUES

### 🔴 Problema: Valores Monetários Rejeitados Incorretamente

#### **Sintomas:**
- Valores válidos como "R$ 100,50" são rejeitados
- Mensagem de erro "Invalid monetary value"
- Impossível salvar despesas ou registros de combustível

#### **Diagnóstico:**
```dart
// Debug no Financial Validator
FinancialValidatorService.debugMode = true;

// Logs esperados:
I/flutter: [FinancialValidator] Input: "R$ 100,50"
I/flutter: [FinancialValidator] Parsed: 100.50
I/flutter: [FinancialValidator] Result: VALID ✅

// Logs problemáticos:
E/flutter: [FinancialValidator] Parse error: NumberFormatException
E/flutter: [FinancialValidator] Input rejected: "R$ 100,50"
```

#### **Soluções:**

**Solução 1: Verificar Locale Configuration**
```dart
// Em main_unified_sync.dart, verificar se está presente:
await initializeDateFormatting('pt_BR', null);

// Verificar NumberFormat:
final formatter = NumberFormat.currency(locale: 'pt_BR');
print('Formatter pattern: ${formatter.pattern}'); // Deve mostrar: ¤#,##0.00
```

**Solução 2: Reset Financial Validator**
```dart
// Adicionar em debug mode:
FinancialValidatorService.instance.reset();
await FinancialValidatorService.instance.initialize();
```

**Solução 3: Verificar Regex Patterns**
```bash
# Verificar se os patterns de validação estão corretos
flutter pub run build_runner build --delete-conflicting-outputs
```

### 🔴 Problema: Valores Negativos Aceitos

#### **Sintomas:**
- Valores como "-100,50" passam pela validação
- Despesas negativas são criadas
- Audit trail registra valores inválidos

#### **Diagnóstico:**
```dart
// Teste manual:
final result = FinancialValidatorService.validateAmount("-100.50");
print('Negative validation: $result'); // Deve ser: INVALID ❌
```

#### **Solução:**
```dart
// Verificar implementação em FinancialValidatorService:
bool _isValidAmount(double amount) {
  return amount > 0.0 && amount <= MAX_MONETARY_VALUE;
}
```

---

## 📊 AUDIT TRAIL ISSUES

### 🔴 Problema: Audit Trail Não Registra Mudanças

#### **Sintomas:**
- Modificações em dados financeiros não aparecem no histórico
- `getAuditTrail()` retorna lista vazia
- Nenhum log de audit no console

#### **Diagnóstico:**
```dart
// Verificar se AuditTrailService está ativo:
final isEnabled = AuditTrailService.instance.isEnabled;
print('Audit trail enabled: $isEnabled'); // Deve ser: true

// Verificar registros:
final entries = await AuditTrailService.instance.getAuditTrail('expense_123');
print('Audit entries: ${entries.length}'); // Deve ser > 0 após mudanças
```

#### **Soluções:**

**Solução 1: Verificar Inicialização**
```dart
// Em GasometerSyncConfig.configure():
// Verificar se está presente:
AuditTrailService.instance.initialize(
  enabledForTypes: [ExpenseEntity, FuelRecordEntity],
);
```

**Solução 2: Verificar Hive Box**
```dart
// Limpar e recriar audit trail box:
await Hive.deleteBoxFromDisk('audit_trail');
await AuditTrailService.instance.reinitialize();
```

**Solução 3: Debug Audit Recording**
```dart
// Adicionar logs detalhados:
AuditTrailService.debugMode = true;

// Logs esperados após mudança:
I/flutter: [AuditTrail] Recording change for expense_123
I/flutter: [AuditTrail] Before: {"amount": 100.0}
I/flutter: [AuditTrail] After: {"amount": 150.0}
I/flutter: [AuditTrail] Entry saved with ID: audit_456
```

### 🔴 Problema: Audit Trail Com Dados Corrompidos

#### **Sintomas:**
- Histórico mostra mudanças inconsistentes
- Timestamps incorretos
- User IDs ausentes ou inválidos

#### **Diagnóstico:**
```dart
// Verificar integridade dos dados:
final entries = await AuditTrailService.instance.getAuditTrail('expense_123');
for (final entry in entries) {
  print('Entry ID: ${entry.id}');
  print('Timestamp: ${entry.timestamp}');
  print('User ID: ${entry.userId}');
  print('Changes: ${entry.changes}');
  print('---');
}
```

#### **Soluções:**

**Solução 1: Rebuild Audit Trail**
```dart
// Recriar audit trail a partir dos dados existentes:
await AuditTrailService.instance.rebuildFromEntities();
```

**Solução 2: Verificar User Context**
```dart
// Garantir que user ID está disponível:
final userId = await AuthService.instance.getCurrentUserId();
if (userId == null) {
  print('ERROR: No user ID available for audit trail');
}
```

---

## ⚔️ MANUAL CONFLICT RESOLUTION ISSUES

### 🔴 Problema: UI de Resolução Não Aparece

#### **Sintomas:**
- Conflitos financeiros detectados mas não mostrados ao usuário
- Sync trava em "Resolving conflicts..."
- Dados ficam inconsistentes entre dispositivos

#### **Diagnóstico:**
```dart
// Verificar detecção de conflitos:
final conflicts = await ConflictDetectionService.instance.detectFinancialConflicts();
print('Active conflicts: ${conflicts.length}');

// Verificar configuração de strategy:
final config = GasometerSyncConfig.getEntityConfig<ExpenseEntity>();
print('Conflict strategy: ${config.conflictStrategy}'); // Deve ser: manual
```

#### **Soluções:**

**Solução 1: Verificar Route Configuration**
```dart
// Verificar se route para conflict resolution está registrada:
GoRouter(
  routes: [
    // ...
    GoRoute(
      path: '/conflict-resolution',
      builder: (context, state) => ConflictResolutionPage(),
    ),
  ],
)
```

**Solução 2: Forçar Exibição de Conflitos**
```dart
// Debug mode para forçar UI:
ConflictResolutionService.debugMode = true;
await ConflictResolutionService.instance.showPendingConflicts();
```

**Solução 3: Reset Conflict State**
```dart
// Limpar conflitos travados:
await ConflictResolutionService.instance.clearStalledConflicts();
```

### 🔴 Problema: Resolução Manual Não Salva

#### **Sintomas:**
- Usuário escolhe versão no UI mas mudança não persiste
- Conflito continua aparecendo após resolução
- Dados voltam ao estado anterior

#### **Diagnóstico:**
```dart
// Verificar se resolução está sendo salva:
ConflictResolutionService.onResolution = (conflictId, resolution) {
  print('Conflict $conflictId resolved: ${resolution.selectedVersion}');
  print('Persistence result: ${resolution.saved}'); // Deve ser: true
};
```

#### **Soluções:**

**Solução 1: Verificar Permissions**
```dart
// Verificar write permissions no Firestore:
// Rules devem permitir updates para dados financeiros
```

**Solução 2: Verificar Entity Validation**
```dart
// Garantir que versão resolvida passa validação:
final resolved = resolution.selectedVersion;
final isValid = await FinancialValidatorService.validate(resolved);
if (!isValid) {
  print('ERROR: Resolved version failed validation');
}
```

---

## 🔧 GENERAL FINANCIAL SYNC ISSUES

### 🔴 Problema: Sync Muito Lento para Dados Financeiros

#### **Sintomas:**
- Sync demora mais que 2 minutos para ≤50 registros financeiros
- App trava durante sync de despesas
- Timeout errors no console

#### **Diagnóstico:**
```dart
// Verificar batch sizes:
final config = GasometerSyncConfig.getEntityConfig<ExpenseEntity>();
print('Batch size: ${config.batchSize}'); // Deve ser: 15-25 para financial

// Verificar network performance:
final stopwatch = Stopwatch()..start();
await SyncService.instance.syncFinancialEntities();
stopwatch.stop();
print('Financial sync time: ${stopwatch.elapsedMilliseconds}ms');
```

#### **Soluções:**

**Solução 1: Ajustar Batch Size**
```dart
// Reduzir batch size para dados financeiros:
EntitySyncRegistration<ExpenseEntity>(
  batchSize: 10, // Reduzir de 15 para 10
  syncInterval: Duration(minutes: 3), // Mais frequente
);
```

**Solução 2: Implementar Sync Seletivo**
```dart
// Sincronizar apenas dados modificados:
await SyncService.instance.syncOnlyDirtyFinancialEntities();
```

### 🔴 Problema: Dados Financeiros Perdidos Durante Sync

#### **Sintomas:**
- Despesas ou registros de combustível desaparecem
- Valores monetários zerados após sync
- Audit trail mostra perdas de dados

#### **Diagnóstico:**
```bash
# Verificar logs de sync:
I/flutter: [Sync] Uploading expense_123: {amount: 100.50}
I/flutter: [Sync] Server response: 200 OK
I/flutter: [Sync] Local update: expense_123 marked as synced

# Logs problemáticos:
E/flutter: [Sync] Upload failed: expense_123
E/flutter: [Sync] Data integrity check failed
```

#### **Soluções:**

**Solução 1: Backup Before Sync**
```dart
// Implementar backup automático:
await FinancialBackupService.createBackup();
await SyncService.instance.syncWithBackup();
```

**Solução 2: Verificar Data Integrity**
```dart
// Adicionar verificação de integridade:
final integrityCheck = await DataIntegrityService.verifyFinancialData();
if (!integrityCheck.passed) {
  print('Data integrity issues detected:');
  for (final issue in integrityCheck.issues) {
    print('- ${issue.description}');
  }
}
```

---

## 🚨 EMERGENCY RECOVERY PROCEDURES

### 📁 Complete Financial Data Recovery

```bash
# PASSO 1: Parar sync imediatamente
flutter run --debug
# No debug console:
> SyncService.instance.stopAllSync()

# PASSO 2: Backup dados locais
> FinancialBackupService.createEmergencyBackup()

# PASSO 3: Verificar integridade local
> DataIntegrityService.fullCheck()

# PASSO 4: Recovery seletivo
> FinancialRecoveryService.recoverFromBackup(date: yesterday)

# PASSO 5: Restart com validação
> flutter restart
> SyncService.instance.syncWithValidation()
```

### 🔄 Reset Financial Validation System

```dart
// EMERGENCY RESET - Use apenas em casos extremos
await FinancialValidatorService.instance.emergencyReset();
await AuditTrailService.instance.emergencyReset();
await ConflictResolutionService.instance.clearAllConflicts();

// Reinicializar sistema:
await GasometerSyncConfig.configure();
```

---

## 📞 SUPPORT ESCALATION

### Quando Escalar para Suporte Técnico

1. **Data Loss**: Qualquer perda de dados financeiros
2. **Validation Bypass**: Valores inválidos passando pela validação
3. **Audit Trail Corruption**: Histórico de mudanças corrompido
4. **Sync Deadlock**: Sync travado por mais de 10 minutos
5. **Integrity Failures**: Falhas consistentes na verificação de integridade

### Informações Necessárias para Suporte

```
- Device Info: [iOS/Android version]
- App Version: [build number]
- User ID: [current user identifier]
- Error Logs: [complete console output]
- Data Samples: [examples of affected financial records]
- Sync Timeline: [when problem started]
- Recovery Attempts: [what was already tried]
```

---

**Guia compilado em:** 2025-09-22
**Última atualização:** System UnifiedSync v2.0
**Scope:** Financial features específicas
**Status:** ✅ Production-ready