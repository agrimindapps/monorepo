# 🐛 Pragas Feature

## 📋 Descrição

Feature de catálogo de pragas agrícolas.

---

## 🎯 Regras de Negócio

### Pragas
1. **Dados estáticos** - Base de pragas cadastradas
2. **Informações** - Nome científico, nome popular, descrição
3. **Relações** - Praga → Culturas afetadas → Defensivos indicados

### Visualização
1. **Lista** - Todas as pragas
2. **Detalhes** - Informações e defensivos
3. **Por cultura** - Pragas de uma cultura específica

---

## 📁 Arquivos Principais

- `lib/features/pragas/presentation/pages/pragas_page.dart`
- `lib/features/pragas/presentation/pages/detalhe_praga_page.dart`
- `lib/database/repositories/pragas_repository.dart`
