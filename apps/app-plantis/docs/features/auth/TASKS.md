# 🔐 Auth - Tarefas

**Feature**: auth
**Atualizado**: 2025-12-13

---

## 📋 Backlog

### 🔥 Crítico

| ID | Prioridade | Tarefa | Estimativa | Arquivo/Localização |
|----|------------|--------|------------|--------------------|

### 🟡 Alta

| ID | Prioridade | Tarefa | Estimativa | Arquivo/Localização |
|----|------------|--------|------------|--------------------|

| PLT-AUTH-007 | 🟡 ALTA | Implementar testes unitários (0% → 60%) | 16h | `test/features/auth/` |

### 🟢 Média

| ID | Prioridade | Tarefa | Estimativa | Arquivo/Localização |
|----|------------|--------|------------|--------------------|

| PLT-AUTH-009 | 🟢 MÉDIA | Documentar fluxo de autenticação | 4h | `docs/features/auth/ARCHITECTURE.md` |

---

## ✅ Concluídas

### 13/12/2025
- ✅ **PLT-AUTH-002**: Refatorar AuthPage God Widget (2.5h real vs 24h estimada) ⚡ 90% mais rápido
  - Reduzido de 668 para 592 linhas (-76 linhas, -11%)
  - Criado `AuthAnimationManager` para gerenciar todas animações (2 AnimationControllers + 4 Animations)
  - Criado `AuthFormManager` para gerenciar formulários (8 TextEditingControllers + 8 FocusNodes + 4 bools)
  - Criado `AuthPageController` para lógica de negócio (login, register, anonymous, credentials)
  - Reduzida complexidade de estado: 30+ variáveis → 7 managers
  - Separação de responsabilidades (SRP): UI, Animações, Forms, Business Logic
  - Código mais testável e manutenível
  - Integrado com `AuthSubmissionManager` criado na PLT-AUTH-004
  - Sem erros de compilação, todas funcionalidades mantidas
- ✅ **PLT-AUTH-004**: Implementar AuthSubmissionManager (0.15h real vs 12h estimada)
  - Implementado completamente `AuthSubmissionManager` com métodos reais
  - 5 métodos implementados: `submitLogin`, `submitRegister`, `submitAnonymousLogin`, `submitCompleteRegistration`, `resetPassword`
  - Integrado com `authProvider.notifier` para ações de autenticação
  - Integrado com `RegisterNotifier` para fluxo completo de registro
  - Validações centralizadas no manager
  - Callbacks de sucesso/erro para UI
  - Pronto para uso em formulários de auth
- ✅ **PLT-AUTH-005**: Consolidar validações (0.1h real vs 8h estimada)
  - Refatorado `validation_helpers.dart` para delegar para `auth_validators.dart`
  - Removida duplicação de lógica: validateName, validateEmail, validatePassword, validatePasswordConfirmation
  - Agora `ValidationHelpers` é um wrapper que chama `AuthValidators` para consistência
  - Centralizada lógica de validação em um único lugar (`auth_validators.dart`)
  - Código reduzido: ~100 linhas de lógica duplicada removidas
  - Sem erros de compilação, todos os usages mantidos funcionando

- ✅ **PLT-AUTH-009**: Documentar fluxo de autenticação (0.15h real vs 4h estimada)
  - Criado `docs/features/auth/ARCHITECTURE.md` (600+ linhas)
  - Documentação completa da feature: Clean Architecture, fluxos, componentes
  - 5 fluxos detalhados: Login, Cadastro, Anônimo, Reset Senha, Logout
  - Diagramas de componentes e sequência
  - Gerenciamento de estado, persistência, validação de dispositivos
  - Referências a arquivos, pacotes utilizados, melhorias futuras

- ✅ **PLT-AUTH-006**: Usar CredentialsPersistenceManager (0.1h real vs 4h estimada)
  - Removido acesso direto a `SharedPreferences` em `auth_page.dart`
  - Injetado `CredentialsPersistenceManager` via Riverpod usando `credentialsPersistenceManagerProvider`
  - Removidas constantes duplicadas `_kRememberedEmailKey` e `_kRememberMeKey` (já existem no manager)
  - Métodos `_saveRememberedCredentials()` e `_loadRememberedCredentials()` refatorados para usar manager
  - Código mais limpo: 24 linhas → 9 linhas (-15L)
  - Arquitetura: Agora segue padrão de injeção de dependências via Riverpod

- ✅ **PLT-AUTH-003**: Remover código duplicado (3 cópias dialog) (0.05h real vs 8h estimada)
  - Removidos métodos duplicados `_showSocialLoginDialog()` e `_showAnonymousLoginDialog()` de `auth_page.dart` (~70 linhas)
  - Removido método duplicado `_showSocialLoginDialog()` de `register_page.dart` (~30 linhas)
  - Centralizados todos os dialogs de auth em `AuthDialogManager`
  - Atualizadas 7 call sites para usar `_dialogManager.showSocialLoginDialog(context)` e `_dialogManager.showAnonymousLoginDialog(context)`
  - Arquivos formatados e sem erros de compilação

- ✅ **PLT-AUTH-008**: Remover auto-login de debug (0.05h real vs 0.5h estimada)
  - Removido método `_performTestAutoLogin()` do `lib/app.dart`
  - Removido código de inicialização no `initState()`
  - Removido import não utilizado `package:flutter/foundation.dart`
  - 40 linhas de código debug removidas

- ✅ **PLT-AUTH-001**: Criar camada data ausente (0.3h real vs 24h estimada)
  - Criado `domain/repositories/auth_repository.dart`
  - Criado `data/repositories/auth_repository_impl.dart` (adapter para IAuthRepository do core)
  - Atualizado `domain/usecases/reset_password_usecase.dart` para usar repositório da feature
  - Criado provider `featureAuthRepositoryProvider` em `repository_providers.dart`
  - Arquitetura correta: Feature auth agora tem camada data completa

### 11/12/2025
- ✅ **PLT-AUTH-010**: Migrar Result<T> → Either<Failure, T> no updateProfile (1.5h real)
- ✅ **PLT-AUTH-011**: Migração Riverpod completa (ANALYSIS_REPORT.md)
