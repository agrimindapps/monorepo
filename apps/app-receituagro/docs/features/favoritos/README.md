# ⭐ Favoritos Feature

## 📋 Descrição

Feature que permite aos usuários favoritar defensivos, pragas e culturas para acesso rápido.

---

## 🎯 Regras de Negócio

### Favoritos
1. **Tipos suportados**: Defensivos, Pragas, Culturas
2. **Persistência**: Local (Drift) + Sync (Firebase)
3. **Limite**: Sem limite de favoritos
4. **Unicidade**: Um item só pode ser favoritado uma vez por usuário

### Sincronização
1. **Offline-first**: Funciona sem internet
2. **Sync automático**: Sincroniza quando há conexão
3. **Conflitos**: Last-write-wins

### UI/UX
1. **Toggle rápido**: Ícone de coração em listas
2. **Feedback visual**: Animação ao favoritar
3. **Lista dedicada**: Tela de favoritos agrupados por tipo

---

## 🏗️ Arquitetura

```
lib/features/favoritos/
├── data/
│   ├── repositories/
│   │   └── favoritos_repository_simplified.dart
│   └── services/
│       └── favoritos_sync_service.dart
│
├── domain/
│   ├── entities/
│   │   └── favorito_entity.dart
│   └── usecases/
│       ├── add_favorito_usecase.dart
│       ├── remove_favorito_usecase.dart
│       └── get_favoritos_usecase.dart
│
└── presentation/
    ├── pages/
    │   └── favoritos_page.dart
    ├── providers/
    │   └── favoritos_providers.dart
    └── widgets/
        └── favoritos_tabs_widget.dart
```

---

## ⚠️ Status Atual

**Health Score**: 7/10

### Problemas Identificados
- [ ] Código deprecated em `favoritos_repository_simplified.dart`
- [ ] Métodos legacy não utilizados
- [ ] Sync service com TODOs pendentes

---

## 📁 Arquivos Principais

- `lib/features/favoritos/data/repositories/favoritos_repository_simplified.dart`
- `lib/features/favoritos/presentation/pages/favoritos_page.dart`
- `lib/features/favoritos/presentation/providers/favoritos_providers.dart`
- `lib/database/drift/tables/favoritos_table.dart`
