# 📚 Documentação - app-receituagro

**Sistema de Gestão por Feature**

---

## 📊 Status Rápido

### Features Principais (4)
| Feature | Health |
|---------|--------|
| [defensivos](./features/defensivos/) | 8/10 |
| [pragas](./features/pragas/) | 8/10 |
| [culturas](./features/culturas/) | 8/10 |
| [diagnosticos](./features/diagnosticos/) | 8/10 |

### Features de Usuário (5)
| Feature | Health |
|---------|--------|
| [auth](./features/auth/) | 9/10 |
| [favoritos](./features/favoritos/) | 7/10 |
| [comentarios](./features/comentarios/) | 8/10 |
| [settings](./features/settings/) | 8/10 |
| [subscription](./features/subscription/) | 8/10 |

### Features Auxiliares (4)
| Feature | Health |
|---------|--------|
| [busca_avancada](./features/busca_avancada/) | 7/10 |
| [pragas_por_cultura](./features/pragas_por_cultura/) | 8/10 |
| [data_export](./features/data_export/) | 6/10 |
| [onboarding](./features/onboarding/) | 7/10 |

### Infraestrutura (6)
| Feature | Health |
|---------|--------|
| [core](./features/core/) | 7/10 |
| [analytics](./features/analytics/) | 8/10 |
| [monitoring](./features/monitoring/) | 7/10 |
| [navigation](./features/navigation/) | 8/10 |
| [sync](./features/sync/) | 7/10 |
| [release](./features/release/) | 8/10 |

👉 **[Ver Dashboard Completo](./STATUS.md)**

---

## 📁 Estrutura

```
docs/
├── README.md              # Você está aqui
├── STATUS.md              # Dashboard global
│
├── features/              # 📦 Documentação por feature
│   ├── auth/
│   │   ├── README.md      # Regras de negócio
│   │   └── TASKS.md       # Backlog + histórico
│   ├── favoritos/
│   ├── settings/
│   ├── subscription/
│   └── core/
│
├── backlog/               # 📋 Tarefas globais
│   └── README.md
│
└── guides/                # 📖 Guias de desenvolvimento
    ├── COMMENTING.md
    └── PATTERNS.md
```

---

## 🚀 Como Usar

### Ver status de uma feature
```
docs/features/{feature}/README.md  → Regras e arquitetura
docs/features/{feature}/TASKS.md   → Tarefas e histórico
```

### Criar nova tarefa
1. Abra `docs/features/{feature}/TASKS.md`
2. Adicione no Backlog com ID único (ex: `AUTH-004`)
3. Atualize `STATUS.md` se for prioridade alta

### Concluir tarefa
1. Mova de "Backlog" para "Concluídas" em `TASKS.md`
2. Adicione data e resultado
3. Atualize `STATUS.md`

---

## 🔗 Links Úteis

- [Monorepo CLAUDE.md](../../../CLAUDE.md) - Padrões globais
- [Guias](./guides/) - Comentários, Patterns
- [Core](./features/core/) - Infraestrutura

---

*Mantido por: Claude Code | Atualizado: 2025-12-05*
