# 📖 Guias de Desenvolvimento

**app-receituagro**

---

## 📁 Guias Disponíveis

| Guia | Descrição |
|------|-----------|
| [COMMENTING.md](./COMMENTING.md) | Padrões e boas práticas para comentários no código |
| [PATTERNS.md](./PATTERNS.md) | Design patterns utilizados (Strategy, etc.) |

---

## 🎯 Padrões do Projeto

### State Management
- **Riverpod 3.0** com code generation (`@riverpod`)
- **AsyncNotifier** para estados assíncronos
- **Providers derivados** para valores computados

### Arquitetura
- **Clean Architecture** (Presentation/Domain/Data)
- **Repository Pattern** (Drift local + Firebase remote)
- **SOLID Principles**

### Database
- **Drift** (SQLite type-safe)
- **Offline-first** com sync

### Error Handling
- **Either<Failure, T>** (dartz)
- **AsyncValue** para estados de loading/error

---

## 🔗 Links Úteis

- [STATUS.md](../STATUS.md) - Dashboard do projeto
- [Core README](../features/core/README.md) - Infraestrutura
- [Monorepo CLAUDE.md](../../../../CLAUDE.md) - Padrões globais
