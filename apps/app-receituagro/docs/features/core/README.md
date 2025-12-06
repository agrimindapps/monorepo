# 🔧 Core - Infraestrutura

## 📋 Descrição

Módulo central com serviços compartilhados, providers base, database e utilitários.

---

## 🎯 Responsabilidades

### Providers Base
- AuthProvider e derivados
- Providers de serviços (analytics, device, etc.)
- Dependency injection via Riverpod

### Database (Drift)
- Tabelas e DAOs
- Migrations
- Sync adapters

### Services
- Analytics (Firebase + custom)
- Device identity
- Premium status
- Data cleanup

### Navigation
- Router configuration
- Premium guards
- Deep linking

---

## 🏗️ Estrutura

```
lib/core/
├── providers/
│   ├── auth_notifier.dart
│   ├── auth_state.dart
│   ├── auth_providers.dart
│   ├── core_providers.dart
│   └── ...
│
├── services/
│   ├── analytics_service.dart
│   ├── device_identity_service.dart
│   ├── premium_service.dart (⚠️)
│   └── ...
│
├── data/
│   ├── repositories/
│   └── models/
│
├── navigation/
│   ├── app_router.dart
│   └── premium_guards.dart
│
└── di/
    └── injection_container.dart
```

---

## ⚠️ Status Atual

**Health Score**: 7/10

### Problemas Identificados
- [ ] Migração Hive→Drift incompleta
- [ ] Serviços deprecated (premium_service, data_integrity_service)
- [ ] TODOs pendentes em vários arquivos
- [ ] user_data_repository.dart com métodos Hive

### Migração Riverpod
- [x] 100% completo
- [x] Todos os notifiers usando AsyncNotifier
- [x] Code generation ativo

---

## 📁 Arquivos Críticos

### Providers
- `lib/core/providers/auth_notifier.dart` ✅
- `lib/core/providers/core_providers.dart`
- `lib/core/providers/domain_providers.dart`

### Services (⚠️ Revisar)
- `lib/core/services/premium_service.dart` - deprecated
- `lib/core/services/data_integrity_service.dart` - deprecated
- `lib/core/data/repositories/user_data_repository.dart` - Hive methods

### Database
- `lib/database/receituagro_database.dart`
- `lib/database/drift/` - Tabelas Drift
