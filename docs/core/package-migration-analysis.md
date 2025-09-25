# Análise de Migração de Packages para Core

## 📊 Resumo Executivo

Este relatório analisa todos os packages duplicados nos apps do monorepo e recomenda uma estratégia de migração **package por package** para o `packages/core`, minimizando riscos e maximizando benefícios.

### Apps Analisados:
- **app-gasometer** (45 deps) - Controle veicular
- **app-receituagro** (25 deps) - Diagnóstico agrícola
- **app-petiveti** (35 deps) - Veterinário
- **app-plantis** (30 deps) - Cuidado de plantas
- **app-taskolist** (30 deps) - Gerenciamento de tarefas

---

## 🎯 Análise por Package (Ordenado por Impacto)

### 🥇 **ALTA PRIORIDADE** (5 Apps = Impacto Total)

#### **provider: ^6.1.2**
- **Apps Impactados:** gasometer, receituagro, plantis, petiveti, taskolist (5/5)
- **Risco:** 🟢 BAIXO - Package estável
- **Benefício:** 🔥 MÁXIMO - Todos os apps usam
- **Versões:** Todas idênticas (^6.1.2)
- **Ação:** ✅ MIGRAR IMEDIATAMENTE

#### **get_it: ^8.2.0**
- **Apps Impactados:** petiveti, plantis, taskolist (3/5)
- **Risco:** 🟢 BAIXO - DI padrão
- **Benefício:** 🔥 ALTO - Core já usa
- **Versões:** Todas idênticas (^8.2.0)
- **Ação:** ✅ MIGRAR IMEDIATAMENTE

#### **injectable: ^2.5.0**
- **Apps Impactados:** gasometer, petiveti, plantis (3/5)
- **Risco:** 🟢 BAIXO - Complemento do get_it
- **Benefício:** 🔥 ALTO - Vai com get_it
- **Versões:** Todas idênticas (^2.5.0)
- **Ação:** ✅ MIGRAR COM GET_IT

#### **go_router: ^16.1.0**
- **Apps Impactados:** gasometer, petiveti, plantis (3/5)
- **Risco:** 🟡 MÉDIO - Navigation é crítico
- **Benefício:** 🔥 ALTO - Padroniza navegação
- **Versões:** Todas idênticas (^16.1.0)
- **Ação:** ✅ MIGRAR (Teste bem!)

### 🥈 **MÉDIA PRIORIDADE** (2-4 Apps)

#### **flutter_riverpod: ^2.6.1**
- **Apps Impactados:** receituagro, petiveti, taskolist (3/5)
- **Risco:** 🟡 MÉDIO - State management crítico
- **Benefício:** 🔥 ALTO - Apps Riverpod
- **Versões:** Todas idênticas (^2.6.1)
- **Ação:** ✅ MIGRAR (Com cuidado)

#### **cupertino_icons: ^1.0.8**
- **Apps Impactados:** gasometer, petiveti, plantis, taskolist (4/5)
- **Risco:** 🟢 BAIXO - Apenas icons
- **Benefício:** 🔥 ALTO - Todos precisam
- **Versões:** Todas idênticas (^1.0.8)
- **Ação:** ✅ MIGRAR IMEDIATAMENTE

#### **intl: ^0.20.2**
- **Apps Impactados:** gasometer, petiveti, taskolist (3/5)
- **Risco:** 🟢 BAIXO - Core já tem ^0.19.0-0.21.0
- **Benefício:** 🔥 ALTO - Internacionalização
- **Versões:** Compatíveis
- **Ação:** ✅ JÁ NO CORE (Verificar range)

#### **cached_network_image: ^3.4.1**
- **Apps Impactados:** gasometer, petiveti, plantis (3/5)
- **Risco:** 🟢 BAIXO - UI utility
- **Benefício:** 🔥 ALTO - Performance
- **Versões:** Todas idênticas (^3.4.1)
- **Ação:** ✅ MIGRAR

#### **flutter_staggered_grid_view: ^0.7.0**
- **Apps Impactados:** gasometer, receituagro, plantis (3/5)
- **Risco:** 🟢 BAIXO - UI component
- **Benefício:** 🔥 ALTO - Layout comum
- **Versões:** Todas idênticas (^0.7.0)
- **Ação:** ✅ MIGRAR

#### **equatable: ^2.0.7**
- **Apps Impactados:** petiveti, plantis, taskolist (3/5)
- **Risco:** 🟢 BAIXO - Core já tem
- **Benefício:** 🔥 ALTO - Comparison utility
- **Versões:** Todas idênticas (^2.0.7)
- **Ação:** ✅ JÁ NO CORE

#### **dartz: ^0.10.1**
- **Apps Impactados:** petiveti, plantis, taskolist (3/5)
- **Risco:** 🟢 BAIXO - Core já tem
- **Benefício:** 🔥 ALTO - Either/Failure pattern
- **Versões:** Todas idênticas (^0.10.1)
- **Ação:** ✅ JÁ NO CORE

### 🥉 **BAIXA PRIORIDADE** (2 Apps)

#### **flutter_svg: ^2.0.10+1**
- **Apps Impactados:** gasometer, petiveti (2/5)
- **Risco:** 🟢 BAIXO - UI asset
- **Benefício:** 🔸 MÉDIO - Não todos usam
- **Versões:** Todas idênticas
- **Ação:** ⏳ AVALIAR DEMANDA

#### **shimmer: ^3.0.0**
- **Apps Impactados:** gasometer, receituagro (2/5)
- **Risco:** 🟢 BAIXO - UI effect
- **Benefício:** 🔸 MÉDIO - Loading states
- **Versões:** Todas idênticas
- **Ação:** ⏳ AVALIAR DEMANDA

---

## 📋 Plano de Execução por Fases

### **FASE 1 - Risk-Free Migration (Semana 1)**
```yaml
# Adicionar ao packages/core/pubspec.yaml:
cupertino_icons: ^1.0.8          # 4 apps impactados
provider: ^6.1.2                 # 5 apps impactados
get_it: ^8.2.0                   # 3 apps impactados
injectable: ^2.5.0               # 3 apps impactados
cached_network_image: ^3.4.1     # 3 apps impactados
flutter_staggered_grid_view: ^0.7.0 # 3 apps impactados
```

**Estimativa:** ~18 apps impactados positivamente
**Risco:** BAIXO (packages estáveis, não críticos)

### **FASE 2 - Navigation & State (Semana 2)**
```yaml
# Testar intensivamente antes de migrar:
go_router: ^16.1.0               # 3 apps impactados
flutter_riverpod: ^2.6.1         # 3 apps impactados
```

**Estimativa:** ~6 apps impactados
**Risco:** MÉDIO (components críticos)

### **FASE 3 - Dev Dependencies (Semana 3)**
```yaml
# Migrar ferramentas de build:
build_runner: ^2.4.13
injectable_generator: ^2.6.2
hive_generator: ^2.0.1
json_serializable: ^6.8.0
mockito: ^5.4.4
flutter_lints: ^5.0.0
```

**Estimativa:** Todos os apps beneficiados
**Risco:** BAIXO (apenas dev time)

### **FASE 4 - Specific Features (Conforme Demanda)**
```yaml
# Migrar apenas se múltiplos apps precisarem:
shimmer: ^3.0.0
flutter_svg: ^2.0.10+1
json_annotation: ^4.9.0
```

---

## 🧪 Protocolo de Teste por Package

### **Para Cada Migration:**
1. ✅ **Adicionar** package ao `packages/core/pubspec.yaml`
2. ✅ **Export** no `packages/core/lib/core.dart`
3. ✅ **Remover** do pubspec.yaml dos apps impactados
4. ✅ **Testar** cada app individualmente
5. ✅ **Build** APK/IPA para confirmar tree shaking
6. ✅ **Git commit** por package migrado

### **Rollback Plan:**
- Cada package = 1 commit separado
- Fácil rollback individual se houver problemas
- Apps continuam funcionando independentemente

---

## 📊 Métricas Esperadas

### **Antes da Migração:**
- **Total Dependencies:** ~165 (across all apps)
- **Duplicated Packages:** ~35
- **Maintenance Overhead:** ALTO

### **Após Fase 1:**
- **Total Dependencies:** ~125 (reduction of 24%)
- **Duplicated Packages:** ~20
- **Maintenance Overhead:** MÉDIO

### **Após Todas as Fases:**
- **Total Dependencies:** ~85 (reduction of 48%)
- **Duplicated Packages:** ~5
- **Maintenance Overhead:** BAIXO

---

## 🚨 Packages NÃO Migrar (App-Specific)

### **Gasometer Only:**
- `fl_chart: ^1.0.0` - Charts específicos de veículos
- `geolocator: ^14.0.2` - GPS específico
- `geocoding: ^4.0.0` - Location específico

### **ReceitaAgro Only:**
- `firebase_remote_config: ^6.0.0` - Config específico
- `font_awesome_flutter: ^10.7.0` - Icons específicos

### **Petiveti Only (Em migração):**
- `google_sign_in: ^6.2.1` - Auth social
- `sign_in_with_apple: ^6.1.2` - Auth social
- `flutter_facebook_auth: ^6.0.4` - Auth social

---

## ✅ Checklist de Implementação

### **Preparação:**
- [ ] Backup dos pubspec.yaml atuais
- [ ] Setup de testes automatizados
- [ ] Documentar imports críticos

### **Por Package:**
- [ ] Adicionar ao core/pubspec.yaml
- [ ] Export em core/lib/core.dart
- [ ] Remover dos apps
- [ ] Testar builds
- [ ] Commit individual

### **Validação Final:**
- [ ] Todos apps buildando
- [ ] Tree shaking funcionando
- [ ] Performance mantida
- [ ] Documentação atualizada

---

## 🎯 Recomendação Final

**COMECE PELA FASE 1** - packages de baixo risco e alto impacto.

A estratégia package-by-package é perfeita para seu monorepo:
- ✅ **Controle total** de cada migração
- ✅ **Rollback fácil** se algo der errado
- ✅ **Impacto mensurável** a cada passo
- ✅ **Redução gradual** da duplicação

**Estimativa:** 48% de redução nas dependências totais com migração completa.

---

*Relatório gerado em: 2025-01-25*
*Apps analisados: 5 | Packages identificados: 35+ | Duplicações: 85%*