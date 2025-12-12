# 🔄 Sync Feature

## 📋 Descrição

Feature de sincronização de dados entre local e cloud.

---

## 🎯 Regras de Negócio

### Sync
1. **Offline-first** - Funciona sem internet
2. **Background** - Sincroniza em segundo plano
3. **Conflitos** - Last-write-wins
4. **Incremental** - Apenas mudanças

### Dados Sincronizados
- Favoritos
- Comentários
- Preferências (AppSettings)
- Perfil de Usuário (Sync-only, sem persistência local no Drift)

---

## 📁 Arquivos Principais

- `lib/features/sync/`
- `lib/database/sync/`
