# 💬 Comentários Feature

## 📋 Descrição

Feature para adicionar comentários/anotações em defensivos, pragas e culturas.

---

## 🎯 Regras de Negócio

### Comentários
1. **Por contexto** - Vinculado a defensivo/praga/cultura específica
2. **Por usuário** - Cada usuário tem seus comentários
3. **Sincronização** - Local (Drift) + Cloud (Firebase)
4. **Privacidade** - Comentários são privados por usuário

### Limites
1. **Tamanho** - Máximo de caracteres por comentário
2. **Quantidade** - Múltiplos comentários por item

---

## 🏗️ Arquitetura

```
lib/features/comentarios/
├── data/
│   ├── repositories/
│   │   └── comentarios_drift_repository.dart
│   └── services/
│       └── comentarios_sync_service.dart
│
├── domain/
│   ├── entities/
│   │   └── comentario_entity.dart
│   ├── repositories/
│   │   ├── i_comentarios_read_repository.dart
│   │   └── i_comentarios_write_repository.dart
│   └── usecases/
│
└── presentation/
    ├── pages/
    │   └── comentarios_page.dart
    ├── providers/
    └── widgets/
```

---

## ✅ Padrões Implementados

- [x] Interface Segregation (ISP)
- [x] Read/Write repository separation
- [x] Clean Architecture
- [x] Riverpod providers

---

## 📁 Arquivos Principais

- `lib/features/comentarios/data/repositories/comentarios_drift_repository.dart`
- `lib/features/comentarios/presentation/pages/comentarios_page.dart`
- `lib/database/drift/tables/comentarios_table.dart`
