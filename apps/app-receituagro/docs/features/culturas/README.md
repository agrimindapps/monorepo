# 🌱 Culturas Feature

## 📋 Descrição

Feature de gerenciamento e visualização de culturas agrícolas.

---

## 🎯 Regras de Negócio

### Culturas
1. **Dados estáticos** - Carregados de JSON/assets
2. **Categorização** - Por tipo (grãos, frutas, hortaliças, etc.)
3. **Relações** - Culturas → Pragas → Defensivos

### Visualização
1. **Lista** - Todas as culturas disponíveis
2. **Detalhes** - Informações completas da cultura
3. **Pragas relacionadas** - Pragas que afetam a cultura

---

## 🏗️ Arquitetura

```
lib/features/culturas/
├── data/
│   └── repositories/
│
├── domain/
│   ├── entities/
│   │   └── cultura_entity.dart
│   └── usecases/
│
└── presentation/
    ├── pages/
    │   └── culturas_page.dart
    └── widgets/
```

---

## 📁 Arquivos Principais

- `lib/features/culturas/presentation/pages/culturas_page.dart`
- `lib/database/repositories/culturas_repository.dart`
- `assets/data/culturas.json`
