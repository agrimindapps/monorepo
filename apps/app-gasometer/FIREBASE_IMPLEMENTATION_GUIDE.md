# Firebase Security Rules - App Gasometer
## Guia de Implementação e Configuração

### 📋 Resumo da Análise

O app-gasometer possui uma arquitetura sólida baseada em Clean Architecture com padrão offline-first. A análise identificou 6 entidades principais com diferentes níveis de criticidade de segurança.

### 🗄️ Estrutura de Dados Identificada

#### Entidades Principais:
1. **VehicleEntity** - Ativos valiosos (privado por usuário)
2. **FuelRecordEntity** - Dados financeiros críticos 
3. **ExpenseEntity** - Dados financeiros + auditoria
4. **MaintenanceEntity** - Histórico técnico preservado
5. **OdometerEntity** - Controle de quilometragem
6. **UserEntity** - Profile compartilhado entre apps

#### Padrão de Sincronização:
- **Offline-First**: Dados salvos no Hive primeiro
- **Background Sync**: Firebase sync não bloqueia UI
- **Conflict Resolution**: Timestamp + version control
- **Batch Operations**: Otimizado para dados financeiros

---

## 🔧 Configuração no Firebase Console

### 1. Deploy das Security Rules

```bash
# No diretório do projeto Firebase
cp apps/app-gasometer/firebase_security_rules.js firestore.rules

# Deploy das rules
firebase deploy --only firestore:rules

# Verificar deploy
firebase firestore:rules get
```

### 2. Estrutura de Collections Recomendada

```
📁 Firestore Database
├── 👤 users/{userId}                    # Dados compartilhados entre apps
├── 💳 subscriptions/{userId}            # Status RevenueCat (read-only)
├── 🚗 vehicles/{userId}/{vehicleId}     # Veículos do usuário
├── ⛽ fuel_records/{userId}/{recordId}  # Abastecimentos (dados financeiros)
├── 💰 expenses/{userId}/{expenseId}     # Gastos (dados financeiros)
├── 🔧 maintenance_records/{userId}/{maintenanceId}  # Manutenções
└── 📊 odometer_records/{userId}/{recordId}          # Registros odômetro
```

### 3. Configuração do Firebase Storage

```
📁 Storage Buckets
├── 👤 users/{userId}/profile/           # Avatars (compartilhado)
├── 🧾 gasometer/{userId}/{vehicleId}/receipts/     # Comprovantes
├── 🔧 gasometer/{userId}/{vehicleId}/maintenance/  # Docs manutenção
└── 🧪 dev/                             # Arquivos desenvolvimento
```

---

## 🔐 Características de Segurança Implementadas

### Validações por Entidade

#### 🚗 **Vehicles**
- ✅ Ownership validation (userId)
- ✅ Data type validation (year 1900-2030)
- ✅ Required fields enforcement
- ✅ Odometer progression validation
- ✅ Supported fuels array validation

#### ⛽ **Fuel Records** (Dados Financeiros Críticos)
- ✅ Vehicle ownership validation
- ✅ Financial data validation (liters > 0, prices ≥ 0)
- ✅ Timestamp validation (date ≤ now)
- ✅ Odometer progression check
- ✅ Geographic coordinates validation
- 🚫 **Imutabilidade**: vehicle_id não pode ser alterado

#### 💰 **Expenses** (Dados Financeiros + Auditoria)
- ✅ Vehicle ownership validation
- ✅ Amount validation (≥ 0)
- ✅ Expense type enum validation
- ✅ Receipt path validation
- ✅ Timestamp validation
- 🚫 **Imutabilidade**: vehicle_id não pode ser alterado

#### 🔧 **Maintenance Records**
- ✅ Vehicle ownership validation
- ✅ Cost validation (≥ 0)
- ✅ Type/Status enum validation
- ✅ Service date validation
- ✅ Next service date logic validation
- ✅ Workshop data validation
- ✅ Attachments path validation

#### 📊 **Odometer Records**
- ✅ Vehicle ownership validation
- ✅ Value validation (≥ 0)
- ✅ Registration date validation
- ✅ Sequential validation support

#### 👤 **Users & Subscriptions**
- ✅ Self-access only para profile
- ✅ Subscription read-only (backend apenas)
- ✅ Email/PII protection
- ✅ Compartilhamento seguro entre apps

---

## 🚨 Issues Críticos Identificados

### 1. **[SECURITY] Firebase Security Rules Desatualizadas**
**Status**: 🔴 Crítico | **Esforço**: 4 horas

**Problema**: Rules atuais têm hardcoded `gasometer_12c83_` e validações incompletas.

**Solução**: Implementar as novas rules fornecidas.

**Validação**:
```bash
# Testar com Firebase Emulator
firebase emulators:start --only firestore
# Executar testes de segurança
npm run test:security
```

### 2. **[ARCHITECTURE] Inconsistência Entity/Model**
**Status**: 🟡 Importante | **Esforço**: 3 horas

**Problema**: VehicleEntity usa BaseSyncEntity mas VehicleModel usa padrão antigo.

**Solução**: Migrar VehicleModel para BaseSyncModel pattern.

---

## 📈 Otimizações Recomendadas

### Configuração de Sync por Criticidade

```dart
// Configurações recomendadas para SyncConfig
final gasometerSyncConfig = SyncConfig(
  // Dados financeiros: sync mais frequente
  fuelRecordsSyncInterval: Duration(minutes: 5),
  expensesSyncInterval: Duration(minutes: 5),
  
  // Veículos: sync moderado
  vehiclesSyncInterval: Duration(minutes: 15),
  
  // Manutenções: sync menos frequente
  maintenanceSyncInterval: Duration(hours: 1),
  
  // Configurações gerais
  conflictStrategy: ConflictStrategy.timestamp,
  batchSize: 15, // Para dados financeiros críticos
  retryAttempts: 3,
  offlineQueueSize: 100,
);
```

### Índices Recomendados para Performance

```javascript
// Criar no Firebase Console > Firestore > Indexes
[
  {
    "collection": "fuel_records/{userId}",
    "fields": [
      {"field": "date", "order": "descending"},
      {"field": "vehicle_id", "order": "ascending"}
    ]
  },
  {
    "collection": "expenses/{userId}",
    "fields": [
      {"field": "date", "order": "descending"},
      {"field": "type", "order": "ascending"}
    ]
  },
  {
    "collection": "maintenance_records/{userId}",
    "fields": [
      {"field": "vehicle_id", "order": "ascending"},
      {"field": "service_date", "order": "descending"}
    ]
  }
]
```

---

## 🧪 Testes de Validação

### Testes de Security Rules

```bash
# Instalar Firebase CLI se necessário
npm install -g firebase-tools

# Inicializar emulators
firebase emulators:start --only firestore

# Executar testes de segurança (criar arquivo)
npm run test:firestore-rules
```

### Casos de Teste Críticos

1. **Ownership Validation**: Usuário não pode acessar dados de outro usuário
2. **Financial Data Integrity**: Validar que valores financeiros não podem ser negativos
3. **Vehicle Relationship**: Verificar que fuel_records só podem referenciar veículos do próprio usuário
4. **Timestamp Validation**: Datas futuras devem ser rejeitadas
5. **Cross-App Data**: Users/Subscriptions funcionam corretamente entre apps

---

## 🔄 Migração de Dados Existentes

### Script de Migração (se necessário)

```dart
// Para migrar dados existentes com estrutura antiga
Future<void> migrateExistingData() async {
  // 1. Backup dados existentes
  // 2. Migrar estrutura de hardcoded app ID para nova estrutura
  // 3. Validar integridade dos dados migrados
  // 4. Ativar novas security rules
}
```

---

## 📊 Monitoramento e Alertas

### Métricas Recomendadas

1. **Security Rule Violations**: Alertar quando rules são violadas
2. **Financial Data Anomalies**: Detectar valores suspeitos
3. **Sync Failures**: Monitorar falhas de sincronização
4. **Storage Usage**: Acompanhar uso de storage para anexos

### Dashboard Firebase

```
📊 Métricas Críticas:
├── 🔒 Security violations/day
├── 💰 Financial records created/day  
├── 🔄 Sync success rate
├── 📱 Active users
└── 💾 Storage usage
```

---

## ✅ Checklist de Implementação

### Fase 1: Preparação (1 dia)
- [ ] Backup dos dados existentes
- [ ] Review das novas security rules
- [ ] Setup do ambiente de teste
- [ ] Configuração dos emulators

### Fase 2: Deploy (2 horas)
- [ ] Deploy das novas security rules
- [ ] Configuração dos índices
- [ ] Teste de conectividade
- [ ] Validação básica

### Fase 3: Validação (4 horas)
- [ ] Testes de security rules
- [ ] Testes de funcionalidade
- [ ] Testes de performance
- [ ] Testes cross-app (users/subscriptions)

### Fase 4: Monitoramento (contínuo)
- [ ] Setup de alertas
- [ ] Dashboard de métricas
- [ ] Documentação para o time
- [ ] Plano de rollback se necessário

---

## 🆘 Troubleshooting

### Problemas Comuns

1. **Permission Denied**: Verificar se userId no documento == auth.uid
2. **Invalid Data**: Validar todos os campos obrigatórios
3. **Timestamp Issues**: Usar serverTimestamp() quando apropriado
4. **Storage Issues**: Verificar limites de tamanho e tipos de arquivo

### Rollback Plan

```bash
# Se necessário reverter
git checkout HEAD~1 firestore.rules
firebase deploy --only firestore:rules
```

---

Este guia fornece uma implementação completa e segura das Firebase Security Rules para o app-gasometer, com foco em proteger dados financeiros críticos enquanto mantém a funcionalidade cross-app do monorepo.