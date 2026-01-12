# 📋 Backlog Global - app-agrihurbi

**Atualizado**: 2026-01-12

---

## 🔴 Alta Prioridade - Novas Features

| ID | Feature | Estimativa | Documento | Status |
|----|---------|------------|-----------|--------|
| AGR-010 | **Caderno de Campo Digital** | 3-4 semanas | [CADERNO_DE_CAMPO.md](./CADERNO_DE_CAMPO.md) | 📝 Planejamento |
| AGR-013 | **Gestão de Pastagens** | 3-4 semanas | [GESTAO_DE_PASTAGENS.md](./GESTAO_DE_PASTAGENS.md) | 📝 Planejamento |

---

## 🟡 Média Prioridade - Migrações

| ID | Tarefa | Estimativa | Localização |
|----|--------|------------|-------------|
| AGR-001 | Migrar CacheManager para Riverpod | P | `lib/core/performance/cache_manager.dart` |
| AGR-002 | Migrar CalculatorProvider para Riverpod | P | `lib/features/calculators/presentation/providers/calculator_provider.dart` |

---

## 🟢 Baixa Prioridade

| ID | Tarefa | Estimativa | Detalhes |
|----|--------|------------|----------|
| AGR-003 | Completar documentação de features | M | 11 features |

---

## 📅 Roadmap de Features Agro

### Q1 2026
- [ ] **AGR-010** Caderno de Campo Digital (Jan-Fev)
- [ ] **AGR-011** Gestão de Safra (Fev-Mar)

### Q2 2026
- [ ] **AGR-012** Controle de Pragas e Doenças
- [ ] **AGR-013** Gestão de Pastagens

### Futuro
- [ ] **AGR-014** Estoque de Insumos
- [ ] **AGR-015** Monitoramento de Solo
- [ ] **AGR-016** Gestão de Máquinas
- [ ] **AGR-017** Controle Leiteiro
- [ ] **AGR-018** Análise Econômica

---

## ✅ Concluídas

### Janeiro 2026
| Data | Tarefa | Resultado |
|------|--------|-----------|
| 12/01 | Documentação Caderno de Campo | ✅ Backlog criado |
| 12/01 | Documentação Gestão de Pastagens | ✅ Backlog criado |

### Dezembro 2025
| Data | Tarefa | Resultado |
|------|--------|-----------|
| 06/12 | Criar sistema de gestão por feature | ✅ Estrutura criada |

---

## 📝 Notas

- 2 ChangeNotifiers restantes para migrar
- 85 @riverpod providers já implementados
- 97% Riverpod
- Feature de referência: `lib/features/pluviometer/` (Clean Architecture completa)
