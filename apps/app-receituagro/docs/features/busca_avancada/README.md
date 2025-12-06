# 🔍 Busca Avançada Feature

## 📋 Descrição

Feature de busca avançada com filtros para defensivos, pragas e culturas.

---

## 🎯 Regras de Negócio

### Busca
1. **Multi-termo** - Suporta múltiplas palavras
2. **Filtros** - Por tipo, cultura, praga
3. **Sugestões** - Autocomplete de termos
4. **Histórico** - Últimas buscas do usuário

### Filtros Disponíveis
- Tipo de defensivo
- Cultura alvo
- Praga alvo
- Status (ativo/inativo)

---

## 🏗️ Arquitetura

```
lib/features/busca_avancada/
├── presentation/
│   ├── pages/
│   │   └── busca_avancada_page.dart
│   └── widgets/
└── domain/
    └── usecases/
```

---

## 📁 Arquivos Principais

- `lib/features/busca_avancada/presentation/pages/busca_avancada_page.dart`
