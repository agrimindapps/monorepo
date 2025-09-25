# Relatório de Migração: Provider ^6.1.2

## 📊 Análise de Impacto

### **Apps Impactados:**
- ✅ **app-gasometer** - Versão: ^6.1.2
- ✅ **app-receituagro** - Versão: ^6.1.2
- ✅ **app-petiveti** - Versão: any (via comment)
- ✅ **app-plantis** - Versão: ^6.1.5
- ✅ **app-taskolist** - Não listado diretamente (usa Riverpod)

**Total:** 4/5 apps usam diretamente + 1 potencial

### **Uso Atual Identificado:**
```yaml
# gasometer/pubspec.yaml
provider: ^6.1.2

# receituagro/pubspec.yaml
provider: ^6.1.2

# petiveti/pubspec.yaml
provider: any  # For local provider usage alongside Riverpod

# plantis/pubspec.yaml
provider: ^6.1.5
```

### **Status no Core:**
❌ **NÃO EXISTE** no packages/core/pubspec.yaml

---

## 🔍 Análise Técnica

### **Compatibilidade de Versões:**
- **Range requerido:** ^6.1.2 - ^6.1.5
- **Versão recomendada para Core:** `^6.1.5`
- **Conflitos:** ❌ NENHUM - todas compatíveis

### **Dependências do Provider:**
```yaml
dependencies:
  flutter: sdk
  nested: ^1.0.0
  collection: ^1.15.0
```
- ✅ Todas já disponíveis no Flutter SDK

### **Imports Típicos nos Apps:**
```dart
// Padrão encontrado nos apps:
import 'package:provider/provider.dart';

// Uso comum:
Consumer<SomeProvider>()
context.read<SomeProvider>()
context.watch<SomeProvider>()
ChangeNotifierProvider()
```

---

## 🎯 Plano de Migração

### **Passo 1: Adicionar ao Core**
```yaml
# packages/core/pubspec.yaml
dependencies:
  provider: ^6.1.5  # Versão mais alta compatível
```

### **Passo 2: Export no Core**
```dart
// packages/core/lib/core.dart
export 'package:provider/provider.dart';
```

### **Passo 3: Remover dos Apps (Por Ordem de Simplicidade)**

#### **3.1. app-gasometer (PRIMEIRO - Mais simples)**
```yaml
# REMOVER de gasometer/pubspec.yaml:
# provider: ^6.1.2
```

#### **3.2. app-receituagro (SEGUNDO)**
```yaml
# REMOVER de app-receituagro/pubspec.yaml:
# provider: ^6.1.2
```

#### **3.3. app-plantis (TERCEIRO)**
```yaml
# REMOVER de app-plantis/pubspec.yaml:
# provider: ^6.1.5
```

#### **3.4. app-petiveti (ÚLTIMO - Mais complexo)**
```yaml
# REMOVER de app-petiveti/pubspec.yaml:
# provider: any  # For local provider usage alongside Riverpod
```

### **Passo 4: Atualizar Imports (Opcional)**
```dart
// DE:
import 'package:provider/provider.dart';

// PARA (se quiser padronizar):
import 'package:core/core.dart';
```

---

## 🧪 Plano de Teste

### **Testes por App:**

#### **app-gasometer:**
```bash
cd apps/app-gasometer
flutter clean
flutter pub get
flutter analyze
flutter test
flutter build apk --debug
```

#### **app-receituagro:**
```bash
cd apps/app-receituagro
flutter clean
flutter pub get
flutter analyze
flutter test
flutter build apk --debug
```

#### **app-plantis:**
```bash
cd apps/app-plantis
flutter clean
flutter pub get
flutter analyze
flutter test
flutter build apk --debug
```

#### **app-petiveti:**
```bash
cd apps/app-petiveti
flutter clean
flutter pub get
flutter analyze
flutter test
flutter build apk --debug
```

### **Pontos de Atenção Durante Testes:**
- ✅ **ChangeNotifiers** funcionando
- ✅ **Consumer widgets** renderizando
- ✅ **context.read/watch** funcionando
- ✅ **MultiProvider** funcionando
- ✅ **ProxyProvider** funcionando (se usado)

---

## ⚠️ Riscos e Mitigações

### **Riscos Identificados:**

#### **🟢 BAIXO RISCO: Versão Compatibility**
- **Problema:** Diferença de versões (6.1.2 vs 6.1.5)
- **Mitigação:** Versões são compatíveis (minor versions)
- **Validação:** Testar funcionalidades críticas

#### **🟢 BAIXO RISCO: Import Paths**
- **Problema:** Apps podem ter imports customizados
- **Mitigação:** Provider não requer imports customizados
- **Validação:** Compilação limpa = imports OK

#### **🟡 MÉDIO RISCO: app-petiveti (Riverpod + Provider)**
- **Problema:** Usa Provider + Riverpod juntos
- **Mitigação:** Provider apenas para compatibilidade local
- **Validação:** Testar state management híbrido

### **Rollback Plan:**
```bash
# Se algo der errado, reverter commit específico:
git revert <commit-hash-provider-migration>

# Ou restaurar pubspec.yaml original de um app específico:
git checkout HEAD~1 -- apps/app-gasometer/pubspec.yaml
```

---

## 📈 Benefícios Esperados

### **Manutenibilidade:**
- ✅ **Uma fonte da verdade** para versão do Provider
- ✅ **Updates centralizados**
- ✅ **Consistência** entre apps

### **Redução de Duplicação:**
- **Antes:** 4-5 declarações independentes
- **Depois:** 1 declaração no core
- **Economia:** ~80% redução

### **Tree Shaking:**
- ✅ Apps que não usam Provider não incluem no bundle
- ✅ Apps que usam mantêm funcionalidade idêntica

---

## ✅ Critérios de Sucesso

### **Pré-Migração:**
- [ ] Provider ^6.1.5 adicionado ao core
- [ ] Export configurado em core.dart
- [ ] Tests do core passando

### **Por App Migrado:**
- [ ] pubspec.yaml limpo (sem provider)
- [ ] flutter pub get sem errors
- [ ] flutter analyze limpo
- [ ] flutter test passando
- [ ] Build APK/IPA sucesso
- [ ] App funcional em device/simulator

### **Pós-Migração:**
- [ ] Todos os 4-5 apps buildando
- [ ] Funcionalidades Provider mantidas
- [ ] Performance mantida
- [ ] Bundle size não aumentado

---

## 🚀 Cronograma Sugerido

### **Dia 1: Preparação**
- [ ] Adicionar provider ao core
- [ ] Testar core build
- [ ] Setup exports

### **Dia 2: Migração apps simples**
- [ ] Migrar app-gasometer
- [ ] Migrar app-receituagro
- [ ] Testes intensivos

### **Dia 3: Migração apps complexos**
- [ ] Migrar app-plantis
- [ ] Migrar app-petiveti (cuidado extra)
- [ ] Validação final

### **Dia 4: Validação completa**
- [ ] Testes em dispositivos reais
- [ ] Performance benchmarks
- [ ] Documentação

---

## 📋 Checklist de Execução

```bash
# FASE 1: Preparar Core
[ ] cd packages/core
[ ] Adicionar "provider: ^6.1.5" ao pubspec.yaml
[ ] Adicionar export ao core.dart
[ ] flutter pub get
[ ] flutter test

# FASE 2: Migrar Apps (um por vez)
[ ] cd apps/app-gasometer
[ ] Remover provider do pubspec.yaml
[ ] flutter clean && flutter pub get
[ ] flutter analyze
[ ] flutter test
[ ] flutter run (testar funcionamento)

# REPETIR para cada app...

# FASE 3: Validação Final
[ ] Todos apps buildando
[ ] Funcionalidades mantidas
[ ] Performance OK
[ ] Commit & Push
```

---

**Status:** 🟢 PRONTO PARA EXECUÇÃO
**Risco Geral:** BAIXO
**Impacto:** ALTO (4-5 apps)
**Tempo Estimado:** 2-3 dias