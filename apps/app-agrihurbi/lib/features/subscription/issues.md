# Issues e Melhorias - Feature Subscription App AgriHurbi

## 📋 Índice Geral

### 🔴 Complexidade ALTA (5 issues)
### 🟡 Complexidade MÉDIA (8 issues)
### 🟢 Complexidade BAIXA (4 issues)

**TOTAL: 17 Issues Identificadas**

---

## 📊 RESUMO EXECUTIVO DA ANÁLISE

### ✅ **STATUS GERAL ATUAL**
A feature Subscription do app_agrihurbi apresenta uma **arquitetura sólida** seguindo Clean Architecture, mas possui **issues críticas** que impedem funcionamento completo:

**Pontos Fortes:**
- Domain layer bem estruturado com entities completas
- Repository pattern corretamente implementado
- Provider com gestão de estado adequada
- Separação clara de responsabilidades

**Problemas Críticos Identificados:**
- **Dependency injection incompleto** (ManagePaymentMethods não definido)
- **Imports de dependências faltantes** em múltiplos arquivos
- **Implementações simplificadas** em repository (métodos stub)
- **Hive type ID conflicts potenciais** com outros features

---

## 🔴 Complexidade ALTA

### 1. [DEPENDENCY] - ManagePaymentMethods Não Implementado

**Status:** 🔴 Pendente | **Execução:** Muito Complexa | **Risco:** Alto | **Benefício:** Alto

**Descrição:** SubscriptionProvider requer ManagePaymentMethods que não foi implementado, causando falha de dependency injection e impossibilitando compilação.

**Prompt de Implementação:**
Implemente a classe ManagePaymentMethods seguindo o padrão dos demais use cases. Crie o arquivo manage_subscription.dart completo incluindo todas as classes de use case necessárias (ManagePaymentMethods, CheckFeatureAccess, ManageTrial, GetSubscriptionPlans, ManagePromoCodes) que estão sendo importadas mas não existem.

**Dependências:** 
- /features/subscription/domain/usecases/manage_subscription.dart
- /features/subscription/presentation/providers/subscription_provider.dart
- /core/di/injection_container.dart

**Validação:** Provider deve injetar dependências sem erros e compilação deve funcionar

---

### 2. [ARCHITECTURE] - Repository Implementations Incompletas

**Status:** 🔴 Pendente | **Execução:** Muito Complexa | **Risco:** Alto | **Benefício:** Alto

**Descrição:** SubscriptionRepositoryImpl tem múltiplos métodos com implementações simplificadas (return const Right([]) ou Left(ServerFailure)) tornando funcionalidades críticas não funcionais.

**Prompt de Implementação:**
Complete a implementação de todos os métodos em SubscriptionRepositoryImpl. Remova implementações stub e implemente lógica real para: getSubscriptionHistory, getInvoices, downloadInvoice, addPaymentMethod, updatePaymentMethod, startFreeTrial, comparePlans, removePromoCode, getActiveDiscounts, getNotifications, markNotificationAsRead, updateNotificationPreferences.

**Dependências:**
- /features/subscription/data/repositories/subscription_repository_impl.dart
- /features/subscription/data/datasources/subscription_remote_datasource.dart

**Validação:** Todos métodos do repository devem ter implementação funcional

---

### 3. [HIVE] - Conflitos Potenciais de Type IDs

**Status:** 🔴 Pendente | **Execução:** Complexa | **Risco:** Alto | **Benefício:** Alto

**Descrição:** Subscription models usam type IDs 16-22 que podem conflitar com outros features. Precisa verificação global e possível reassignment.

**Prompt de Implementação:**
Audite todos os type IDs do Hive no projeto app_agrihurbi. Crie um registry central de type IDs para evitar conflitos. Reassigne os IDs da subscription se necessário (16: SubscriptionModel, 17: SubscriptionTierModel, 18: SubscriptionStatusModel, 19: BillingPeriodModel, 20: PremiumFeatureModel, 21: PaymentMethodModel, 22: PaymentTypeModel) e regenere os adaptadores.

**Dependências:**
- /features/subscription/data/models/subscription_model.dart
- /features/subscription/data/models/subscription_model.g.dart
- Verificação global de Hive adapters

**Validação:** Executar build_runner e garantir que não há conflitos de type ID

---

### 4. [INITIALIZATION] - Hive Box Initialization Não Integrada

**Status:** 🔴 Pendente | **Execução:** Complexa | **Risco:** Alto | **Benefício:** Alto

**Descrição:** SubscriptionLocalDataSource.initialize() não está sendo chamado na inicialização do app, causando crash ao tentar acessar boxes não abertos.

**Prompt de Implementação:**
Integre a inicialização dos boxes Hive do subscription no fluxo de inicialização principal do app. Adicione SubscriptionLocalDataSource.initialize() no core/utils/hive_initializer.dart e garanta que os adapters sejam registrados antes de abrir os boxes.

**Dependências:**
- /features/subscription/data/datasources/subscription_local_datasource.dart
- /core/utils/hive_initializer.dart
- /main.dart

**Validação:** App deve inicializar sem erros relacionados aos Hive boxes

---

### 5. [INJECTION] - Provider Injection Configuration Missing

**Status:** 🔴 Pendente | **Execução:** Complexa | **Risco:** Alto | **Benefício:** Alto

**Descrição:** SubscriptionProvider está anotado como @injectable mas não há configuração no injection_container.dart para registrar todas suas dependências.

**Prompt de Implementação:**
Configure a injeção de dependência completa para SubscriptionProvider no injection_container.dart. Registre todas as classes: SubscriptionRepository, SubscriptionLocalDataSource, SubscriptionRemoteDataSource, e todos os use cases. Garanta que a configuração segue o padrão LazySingleton consistente.

**Dependências:**
- /core/di/injection_container.dart
- /features/subscription/presentation/providers/subscription_provider.dart

**Validação:** GetIt deve resolver SubscriptionProvider sem erros de dependência

---

## 🟡 Complexidade MÉDIA

### 6. [NETWORKING] - Error Handling Limitado em Remote DataSource

**Status:** 🟡 Pendente | **Execução:** Moderada | **Risco:** Médio | **Benefício:** Alto

**Descrição:** SubscriptionRemoteDataSource captura apenas genérico Exception, não diferencia tipos de erro HTTP (404, 401, 500, etc.).

**Prompt de Implementação:**
Aprimore o error handling em SubscriptionRemoteDataSource para capturar e tratar diferentes tipos de erro HTTP. Implemente tratamento específico para status codes 401 (unauthorized), 404 (not found), 422 (validation), 500 (server error) e timeouts.

**Dependências:** /features/subscription/data/datasources/subscription_remote_datasource.dart

**Validação:** Diferentes status HTTP devem gerar failures específicas

---

### 7. [CACHING] - Cache Strategy Simplificada

**Status:** 🟡 Pendente | **Execução:** Moderada | **Risco:** Médio | **Benefício:** Médio

**Descrição:** Sistema de cache local não tem TTL, invalidação inteligente ou sincronização automática com dados remotos.

**Prompt de Implementação:**
Implemente estratégia de cache mais robusta no SubscriptionLocalDataSource. Adicione TTL (Time To Live), invalidação automática, e sincronização periódica. Considere cache de subscription plans e feature usage com timestamps.

**Dependências:** /features/subscription/data/datasources/subscription_local_datasource.dart

**Validação:** Cache deve invalidar automaticamente dados antigos

---

### 8. [VALIDATION] - Input Validation Ausente

**Status:** 🟡 Pendente | **Execução:** Moderada | **Risco:** Médio | **Benefício:** Médio

**Descrição:** Use cases e repository não validam inputs antes de processar (tier válidos, payment method format, promo codes, etc.).

**Prompt de Implementação:**
Adicione validação robusta de inputs nos use cases. Valide SubscriptionTier values, PaymentMethod format, promo code format, billing periods válidos, e dados de subscription creation. Retorne ValidationFailure para inputs inválidos.

**Dependências:** /features/subscription/domain/usecases/manage_subscription.dart

**Validação:** Inputs inválidos devem retornar ValidationFailure apropriada

---

### 9. [TESTING] - Testes Unitários Ausentes

**Status:** 🟡 Pendente | **Execução:** Moderada | **Risco:** Médio | **Benefício:** Alto

**Descrição:** Feature subscription não possui testes unitários para use cases, repository implementation, ou provider logic.

**Prompt de Implementação:**
Crie suíte completa de testes unitários para subscription feature. Inclua testes para ManageSubscription use case, SubscriptionRepositoryImpl, SubscriptionProvider, e data sources. Use mocking para dependencies.

**Dependências:** Criar pasta test/features/subscription/ com estrutura similar

**Validação:** Todos testes devem passar com coverage > 80%

---

### 10. [MONITORING] - Analytics e Logging Ausentes

**Status:** 🟡 Pendente | **Execução:** Moderada | **Risco:** Baixo | **Benefício:** Médio

**Descrição:** Não há tracking de eventos de subscription (upgrade, cancel, payment failures) nem logging estruturado para debugging.

**Prompt de Implementação:**
Implemente analytics tracking para eventos de subscription usando Firebase Analytics ou similar. Adicione logging estruturado em operations críticas. Track: subscription_created, subscription_upgraded, subscription_canceled, payment_failed, feature_accessed.

**Dependências:** Integration com analytics service existente

**Validação:** Eventos devem aparecer no dashboard de analytics

---

### 11. [PERFORMANCE] - Feature Usage Query Optimization

**Status:** 🟡 Pendente | **Execução:** Moderada | **Risco:** Baixo | **Benefício:** Médio

**Descrição:** getFeatureUsage() faz query individual no Hive para cada feature check, podendo ser otimizado com batch loading.

**Prompt de Implementação:**
Otimize queries de feature usage implementando batch loading e in-memory cache. Pre-load feature usage data durante subscription load e mantenha cache local atualizado.

**Dependências:** /features/subscription/data/datasources/subscription_local_datasource.dart

**Validação:** Redução significativa no número de queries individuais

---

### 12. [UX] - Subscription Status Messages

**Status:** 🟡 Pendente | **Execução:** Moderada | **Risco:** Baixo | **Benefício:** Médio

**Descrição:** Provider tem mensagens hardcoded em português, não suporta internacionalização e algumas mensagens são genéricas.

**Prompt de Implementação:**
Extraia todas as strings de mensagem para sistema de localização. Crie mensagens mais específicas e contextuais para diferentes scenarios de subscription (trial expiring, payment failed, upgrade successful, etc.).

**Dependências:** Sistema de i18n do app

**Validação:** Mensagens devem ser localizadas e contextuais

---

### 13. [SECURITY] - Payment Data Handling

**Status:** 🟡 Pendente | **Execução:** Moderada | **Risco:** Médio | **Benefício:** Alto

**Descrição:** PaymentMethod data pode conter informações sensíveis que precisam ser tratadas com criptografia local.

**Prompt de Implementação:**
Implemente criptografia para dados sensíveis de payment methods no cache local. Use encrypted Hive box ou criptografia de campo para dados como lastFourDigits e brand. Adicione data obfuscation.

**Dependências:** /features/subscription/data/datasources/subscription_local_datasource.dart

**Validação:** Dados sensíveis devem estar criptografados no storage local

---

## 🟢 Complexidade BAIXA

### 14. [STYLE] - Code Documentation

**Status:** 🟢 Pendente | **Execução:** Simples | **Risco:** Baixo | **Benefício:** Baixo

**Descrição:** Algumas classes e métodos não possuem documentação Dart adequada, principalmente nos data sources.

**Prompt de Implementação:**
Adicione documentação Dart completa para todas as classes públicas e métodos. Use formato /// com exemplos quando apropriado. Focus em SubscriptionLocalDataSource e SubscriptionRemoteDataSource.

**Dependências:** Arquivos da feature subscription

**Validação:** dart doc deve gerar documentação sem warnings

---

### 15. [OPTIMIZATION] - Enum Extensions

**Status:** 🟢 Pendente | **Execução:** Simples | **Risco:** Baixo | **Benefício:** Baixo

**Descrição:** Enums como SubscriptionTier, SubscriptionStatus poderiam ter extensions com métodos úteis para UI.

**Prompt de Implementação:**
Crie extensions para enums de subscription com métodos utilitários como: isActive, isPaid, color, icon, description. Facilite uso em UI components.

**Dependências:** /features/subscription/domain/entities/subscription_entity.dart

**Validação:** Extensions devem facilitar uso dos enums na UI

---

### 16. [REFACTOR] - Subscription Model JSON Handling

**Status:** 🟢 Pendente | **Execução:** Simples | **Risco:** Baixo | **Benefício:** Baixo

**Descrição:** fromJson() methods usam try-catch inline que pode ser extraído para utility methods mais robustos.

**Prompt de Implementação:**
Extraia parsing JSON logic para utility methods reutilizáveis. Crie helpers para parse date, parse enum, parse nullable fields. Torne código mais limpo e testável.

**Dependências:** /features/subscription/data/models/subscription_model.dart

**Validação:** JSON parsing deve ser mais robusto e reutilizável

---

### 17. [NAMING] - Method Naming Consistency

**Status:** 🟢 Pendente | **Execução:** Simples | **Risco:** Baixo | **Benefício:** Baixo

**Descrição:** Alguns métodos usam nomenclatura inconsistente (getCurrentSubscription vs loadSubscription, hasFeatureAccess vs hasAccess).

**Prompt de Implementação:**
Padronize nomenclatura de métodos em toda a feature. Use: get* para queries síncronas, load* para queries assíncronas, has* para boolean checks, manage* para operations.

**Dependências:** Toda a feature subscription

**Validação:** Nomenclatura deve seguir padrões consistentes

---

## 🔧 Comandos Rápidos

Para solicitar implementação específica, use:
- `Executar #[número]` - Implementar issue específica
- `Detalhar #[número]` - Prompt mais detalhado  
- `Focar [complexidade]` - Trabalhar apenas uma complexidade
- `Agrupar [tipo]` - Executar todas issues de um tipo
- `Validar #[número]` - Revisar implementação concluída

## 📋 ROADMAP DE CORREÇÕES PRIORITÁRIAS

### **FASE 1 - CRÍTICAS (Ordem de Execução)**
1. **Issue #1** - ManagePaymentMethods Implementation 
2. **Issue #5** - Provider Injection Configuration
3. **Issue #4** - Hive Box Initialization
4. **Issue #3** - Type ID Conflicts Resolution

### **FASE 2 - FUNCIONALIDADES**
5. **Issue #2** - Repository Implementations 
6. **Issue #6** - Error Handling Enhancement
7. **Issue #8** - Input Validation

### **FASE 3 - QUALIDADE**
8. **Issue #9** - Unit Testing
9. **Issue #7** - Cache Strategy
10. **Issue #13** - Security Enhancement

**DEPENDÊNCIAS ENTRE CORREÇÕES:**
- Issue #1 deve ser resolvida antes de #5
- Issue #4 deve ser resolvida antes de testar funcionamento
- Issue #2 depende de #1 estar funcionando
- Issues #6,#7,#8 podem ser paralelas após FASE 1

**ESTIMATIVA TOTAL:** ~40-50 horas de desenvolvimento
**IMPACT RATING:** 🔴 ALTO - Feature subscription está 70% não funcional