# 🧪 Defensivos Feature

## 📋 Descrição

Feature principal do app - catálogo de defensivos agrícolas com informações detalhadas.

---

## 🎯 Regras de Negócio

### Defensivos
1. **Dados estáticos** - Base de dados de defensivos registrados
2. **Informações** - Nome, fabricante, tipo, aplicação, dosagem
3. **Relações** - Defensivo → Diagnósticos → Culturas/Pragas

### Agrupamento
1. **Por nome** - Ordem alfabética
2. **Por tipo** - Inseticida, fungicida, herbicida, etc.
3. **Por aplicação** - Foliar, solo, semente
4. **Strategy Pattern** - Implementado para extensibilidade

### Visualização
1. **Lista** - Com filtros e busca
2. **Detalhes** - Informações completas
3. **Favoritar** - Adicionar aos favoritos
4. **Comentar** - Adicionar notas pessoais

---

## 🏗️ Arquitetura

```
lib/features/defensivos/
├── data/
│   └── repositories/
│
├── domain/
│   ├── entities/
│   │   └── defensivo_entity.dart
│   ├── strategies/           # Strategy Pattern
│   │   ├── i_defensivo_grouping_strategy.dart
│   │   ├── by_nome_grouping.dart
│   │   └── by_tipo_grouping.dart
│   └── usecases/
│
└── presentation/
    ├── pages/
    │   ├── defensivos_page.dart
    │   └── detalhe_defensivo_page.dart
    ├── providers/
    └── widgets/
```

---

## ✅ Padrões Implementados

- [x] Strategy Pattern (agrupamento)
- [x] Clean Architecture
- [x] Riverpod providers
- [x] Offline-first

---

## 📁 Arquivos Principais

- `lib/features/defensivos/presentation/pages/defensivos_page.dart`
- `lib/features/defensivos/presentation/pages/detalhe_defensivo_page.dart`
- `lib/features/defensivos/domain/strategies/`
- `lib/database/repositories/defensivos_repository.dart`
