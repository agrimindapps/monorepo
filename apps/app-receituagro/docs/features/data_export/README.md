# 📤 Data Export Feature

## 📋 Descrição

Feature para exportação de dados do usuário (LGPD compliance).

---

## 🎯 Regras de Negócio

### Export
1. **Formatos** - JSON, CSV
2. **Escopo** - Dados do usuário (favoritos, comentários, histórico)
3. **LGPD** - Direito de portabilidade de dados

### Dados Exportáveis
- Favoritos
- Comentários
- Histórico de acessos
- Preferências

---

## 🏗️ Arquitetura

```
lib/features/data_export/
├── data/
│   └── services/
│       └── data_export_service.dart
│
├── domain/
│   └── usecases/
│       └── export_user_data_usecase.dart
│
└── presentation/
    └── pages/
```

---

## 📁 Arquivos Principais

- `lib/features/data_export/data/services/data_export_service.dart`
