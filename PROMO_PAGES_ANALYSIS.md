# Análise de Páginas Promocionais - Monorepo Flutter

**Data:** 2025-10-01
**Objetivo:** Verificar implementação de páginas promocionais e lógica de roteamento Web vs Mobile

---

## 📊 Sumário Executivo

| App | Tem Promo? | Roteamento Web→Promo? | Roteamento Mobile→Login? | Status |
|-----|------------|----------------------|--------------------------|--------|
| **app-petiveti** | ✅ Sim (completo) | ✅ SIM | ✅ SIM | ✅ **CORRIGIDO** |
| **app-plantis** | ✅ Sim (completo) | ✅ SIM | ✅ SIM | ✅ CONFORME |
| **app-gasometer** | ✅ Sim (básico) | ✅ SIM | ✅ SIM | ✅ **CORRIGIDO** |
| **app-taskolist** | ✅ Sim (completo) | ✅ SIM | ✅ SIM | ✅ **CORRIGIDO** |
| **app-agrihurbi** | ✅ Sim (novo) | ✅ SIM | ✅ SIM | ✅ **CRIADO** |
| **app-receituagro** | ❌ NÃO | ✅ N/A (correto) | ✅ N/A (correto) | ✅ CONFORME |

---

## 📱 Análise Detalhada por App

### 1. ✅ app-petiveti (PetiVeti)

**Status:** ⚠️ PRECISA AJUSTE

**Estrutura:**
- ✅ Possui feature completa: `/features/promo/`
- ✅ PromoPage bem estruturada com seções completas
- ✅ Rota `/promo` configurada no router

**Problema Identificado:**
```dart
// app-petiveti/lib/core/router/app_router.dart:41
const initialRoute = '/splash';

// Linha 70: Redirect para promo quando não autenticado
if (!isAuthenticated && !isOnAuthPage && !isOnPromo) {
  return '/promo';
}
```

**Issue:**
- ❌ Sempre inicia em `/splash` (tanto Web quanto Mobile)
- ❌ Não diferencia plataforma na rota inicial
- ✅ Tem redirect para promo (bom), mas inicial errado

**Solução Necessária:**
```dart
// CORRIGIR para:
final initialRoute = kIsWeb ? '/promo' : '/splash';
```

---

### 2. ✅ app-plantis (Plantis)

**Status:** ✅ TOTALMENTE CONFORME

**Estrutura:**
- ✅ Possui PromotionalPage: `/features/legal/presentation/pages/promotional_page.dart`
- ✅ Possui LandingPage: `/features/home/pages/landing_page.dart`
- ✅ Widgets promocionais completos (header, features, carousel, CTA, etc.)

**Implementação Correta:**
```dart
// app-plantis/lib/core/router/app_router.dart:60
const initialLocation = kIsWeb ? promotional : login;
```

**✅ Perfeito!** Web vai para `/promotional`, Mobile vai para `/login`

---

### 3. ⚠️ app-gasometer (GasOMeter)

**Status:** ⚠️ PRECISA AJUSTE

**Estrutura:**
- ✅ Possui PromoPage: `/features/promo/presentation/pages/promo_page.dart`
- ✅ Widgets promocionais (header, features, statistics, testimonials, FAQ, footer, CTA)
- ❌ **NÃO está registrada no router!**

**Problema Identificado:**
```dart
// app-gasometer/lib/core/router/app_router.dart:22
const initialRoute = '/login';

// PromoPage existe mas NÃO aparece nas routes do GoRouter!
```

**Issues:**
1. ❌ Sempre inicia em `/login` (tanto Web quanto Mobile)
2. ❌ PromoPage criada mas não está no router
3. ❌ Não usa `kIsWeb` para diferenciar plataforma

**Solução Necessária:**
1. Adicionar rota `/promo` no GoRouter
2. Mudar initialRoute para: `kIsWeb ? '/promo' : '/login'`
3. Configurar redirect logic

---

### 4. ⚠️ app-taskolist (Task Manager)

**Status:** ⚠️ PRECISA AJUSTE

**Estrutura:**
- ✅ Possui PromotionalPage: `/features/premium/presentation/promotional_page.dart`
- ✅ Seções completas (Header, Features, HowItWorks, Testimonials, CTA, Footer)

**Problema Identificado:**
```dart
// app-taskolist/lib/main.dart:188
home: const PromotionalPage(),
```

**Issues:**
1. ❌ Sempre inicia em PromotionalPage (tanto Web quanto Mobile!)
2. ❌ Usa MaterialApp sem router (não usa GoRouter)
3. ❌ Não diferencia plataforma

**Solução Necessária:**
1. Implementar lógica condicional:
```dart
home: kIsWeb ? const PromotionalPage() : const LoginPage(),
```

---

### 5. ❌ app-agrihurbi (AgriHurbi)

**Status:** ❌ PÁGINA PROMOCIONAL FALTANDO

**Estrutura:**
- ❌ Não possui nenhuma página promocional
- ❌ Não possui landing page
- ❌ Nenhum arquivo relacionado encontrado

**Ação Necessária:**
- 🆕 **CRIAR** página promocional completa
- 🆕 Implementar rota `/promo`
- 🆕 Configurar `kIsWeb ? '/promo' : '/login'`

---

### 6. ✅ app-receituagro (ReceitaAgro)

**Status:** ✅ CONFORME (Não precisa de promo page)

**Análise:**
- ✅ Conforme requisito, este app **NÃO** deve ter página promocional
- ✅ Tem apenas onboarding interno
- ✅ Foco em funcionalidade, não em marketing

**✅ Status: Correto conforme especificação**

---

## ✅ IMPLEMENTAÇÕES CONCLUÍDAS

### 1. **app-gasometer** ✅ CORRIGIDO

**Alterações:**
- ✅ Adicionado import: `package:flutter/foundation.dart`
- ✅ Adicionado import da PromoPage
- ✅ Alterado initialRoute: `kIsWeb ? '/promo' : '/login'`
- ✅ Adicionada rota `/promo` no GoRouter
- ✅ Análise estática: 1 info (style)

**Arquivos Modificados:**
- `apps/app-gasometer/lib/core/router/app_router.dart`

---

### 2. **app-petiveti** ✅ CORRIGIDO

**Alterações:**
- ✅ Adicionado import: `package:flutter/foundation.dart`
- ✅ Alterado initialRoute: `kIsWeb ? '/promo' : '/splash'`
- ✅ Análise estática: 1 info (prefer_const)

**Arquivos Modificados:**
- `apps/app-petiveti/lib/core/router/app_router.dart`

---

### 3. **app-taskolist** ✅ CORRIGIDO

**Alterações:**
- ✅ Adicionado import: `features/auth/presentation/login_page.dart`
- ✅ Alterado home: `kIsWeb ? const PromotionalPage() : const LoginPage()`
- ✅ Análise estática: 6 issues (todos info de ordenação)

**Arquivos Modificados:**
- `apps/app-taskolist/lib/main.dart`

---

### 4. **app-agrihurbi** ✅ CRIADO DO ZERO

**Alterações:**
- ✅ Criada estrutura: `features/promo/presentation/pages/`
- ✅ Criada PromoPage completa (self-contained)
- ✅ Adicionado import no router
- ✅ Alterado initialRoute: `kIsWeb ? '/promo' : '/login'`
- ✅ Adicionada rota `/promo` no GoRouter
- ✅ Atualizado redirect logic para incluir promo
- ✅ Análise estática: 1 info (prefer_const)

**Arquivos Criados:**
- `apps/app-agrihurbi/lib/features/promo/presentation/pages/promo_page.dart`

**Arquivos Modificados:**
- `apps/app-agrihurbi/lib/core/router/app_router.dart`

**Seções da PromoPage:**
- ✅ Navigation Bar com logo e botão Login
- ✅ Hero Section com título e CTA
- ✅ Features Section (4 features)
- ✅ Statistics Section
- ✅ Call to Action final
- ✅ Footer

---

## 🎯 Status Final - TODOS CONFORMES

### ✅ Conformes Original

- **app-plantis** - Já estava correto
- **app-receituagro** - Não precisa promo (conforme requisito)

### ✅ Corrigidos/Criados

- **app-gasometer** - Integrado no router ✅
- **app-petiveti** - InitialRoute corrigido ✅
- **app-taskolist** - Lógica condicional adicionada ✅
- **app-agrihurbi** - PromoPage criada do zero ✅

---

## 🏗️ Template de Implementação

### Padrão para adicionar lógica Web vs Mobile:

```dart
import 'package:flutter/foundation.dart'; // para kIsWeb

// Opção 1: Com GoRouter
final initialLocation = kIsWeb ? '/promo' : '/login';

return GoRouter(
  initialLocation: initialLocation,
  routes: [
    GoRoute(
      path: '/promo',
      name: 'promo',
      builder: (context, state) => const PromoPage(),
    ),
    // ... outras rotas
  ],
);

// Opção 2: Com MaterialApp (sem router)
return MaterialApp(
  home: kIsWeb ? const PromoPage() : const LoginPage(),
  // ...
);
```

---

## 📈 Estatísticas ANTES vs DEPOIS

### ANTES da Implementação:
- **Total de Apps:** 6
- **Com Promo Page:** 3 (50%)
- **Sem Promo Page:** 3 (50%)
  - 1 correto (receituagro - não precisa)
  - 1 faltando (agrihurbi)
  - 1 incompleto (gasometer - não no router)
- **Com Roteamento Correto:** 1 (16.7%) - apenas plantis
- **Precisam Correção:** 3 (50%)
- **Precisam Criação:** 1 (16.7%)

### DEPOIS da Implementação:
- **Total de Apps:** 6
- **Com Promo Page:** 5 (83.3%) ✅
- **Sem Promo Page:** 1 (16.7%) - receituagro (conforme requisito) ✅
- **Com Roteamento Correto:** 5 (100% dos que precisam) ✅
- **Precisam Correção:** 0 ✅
- **Precisam Criação:** 0 ✅

**Taxa de Conformidade: 100% ✅**

---

## ✅ Checklist de Validação

Para cada app com promo page, validar:

- [ ] **Arquivo existe:** `/features/promo/presentation/pages/promo_page.dart`
- [ ] **Rota registrada:** GoRoute com path `/promo`
- [ ] **Web inicia em promo:** `kIsWeb ? '/promo' : ...`
- [ ] **Mobile inicia em login:** `kIsWeb ? ... : '/login'`
- [ ] **Seções completas:**
  - [ ] Header/Hero Section
  - [ ] Features Section
  - [ ] How It Works / Statistics
  - [ ] Testimonials (opcional)
  - [ ] FAQ Section
  - [ ] Call to Action
  - [ ] Footer

---

## 🔗 Arquivos de Referência

**Exemplo CORRETO (app-plantis):**
- Router: `/apps/app-plantis/lib/core/router/app_router.dart:60`
- PromoPage: `/apps/app-plantis/lib/features/legal/presentation/pages/promotional_page.dart`

**Exemplo COMPLETO (app-petiveti):**
- Feature: `/apps/app-petiveti/lib/features/promo/`
- Widgets: múltiplos componentes bem estruturados

**Exemplo para CRIAR (referência):**
- Usar estrutura do app-petiveti como base
- Adaptar conteúdo para cada app específico
