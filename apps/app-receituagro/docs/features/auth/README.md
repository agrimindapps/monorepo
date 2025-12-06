# 🔐 Auth Feature

## 📋 Descrição

Feature responsável por todo o fluxo de autenticação do app ReceitaAgro.

---

## 🎯 Regras de Negócio

### Autenticação
1. **Login anônimo** - Usuário pode usar o app sem criar conta
2. **Login com email/senha** - Autenticação Firebase
3. **Upgrade de conta** - Usuário anônimo pode criar conta mantendo dados
4. **Logout** - Limpa dados premium e cria novo usuário anônimo

### Sessão
1. **Persistência** - Estado de auth mantido com `keepAlive: true`
2. **Device tracking** - Registra dispositivo no login
3. **Sync automático** - Sincroniza dados após autenticação

### Segurança
1. **Dados premium** - Limpos no logout para proteção
2. **Exclusão de conta** - Processo completo com limpeza de dados

---

## 🏗️ Arquitetura

```
lib/
├── core/providers/
│   ├── auth_notifier.dart      # AsyncNotifier principal
│   ├── auth_state.dart         # Estado imutável
│   └── auth_providers.dart     # Providers derivados
│
└── features/auth/
    └── presentation/
        ├── pages/
        │   └── login_page.dart
        └── notifiers/
            └── login_notifier.dart
```

---

## 📦 Providers

| Provider | Tipo | Descrição |
|----------|------|-----------|
| `authProvider` | AsyncNotifier | Estado principal de autenticação |
| `currentUserProvider` | Computed | Usuário atual (nullable) |
| `isAuthenticatedProvider` | Computed | Bool se está autenticado |
| `isLoadingProvider` | Computed | Bool se está carregando |
| `errorMessageProvider` | Computed | Mensagem de erro (nullable) |

---

## 🔄 Fluxo de Estados

```
Initial → Loading → Authenticated
                 → Anonymous
                 → Error
```

---

## ✅ Padrões Implementados

- [x] AsyncNotifier (Riverpod 3.0)
- [x] Code generation (@riverpod)
- [x] Estado imutável com copyWith
- [x] Providers derivados computados
- [x] Cleanup com ref.onDispose()

---

## 📁 Arquivos Relacionados

- `lib/core/providers/auth_notifier.dart`
- `lib/core/providers/auth_notifier.g.dart`
- `lib/core/providers/auth_state.dart`
- `lib/core/providers/auth_providers.dart`
- `lib/features/auth/presentation/pages/login_page.dart`
