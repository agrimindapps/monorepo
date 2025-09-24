# Documentação dos Cálculos - App Calculei

Esta documentação contém todas as fórmulas matemáticas, algoritmos e lógicas de cálculo presentes no app-calculei, organizadas por módulos para facilitar a migração de código fonte.

## 📁 Estrutura da Documentação

### 🏢 **Cálculos Trabalhistas**
- [Horas Extras](./trabalhistas/horas-extras.md) - Cálculos de horas extras, adicionais noturnos e DSR
- [Férias](./trabalhistas/ferias.md) - Cálculos de férias, abono constitucional e pecuniário  
- [Salário Líquido](./trabalhistas/salario-liquido.md) - Descontos de INSS, IRRF e líquido
- [Décimo Terceiro](./trabalhistas/decimo-terceiro.md) - Cálculo do 13º salário integral e proporcional
- [Seguro Desemprego](./trabalhistas/seguro-desemprego.md) - Valores e parcelas do seguro desemprego

### 💰 **Cálculos Financeiros**
- [Juros Compostos](./financeiros/juros-compostos.md) - Capitalização e aportes mensais
- [Independência Financeira](./financeiros/independencia-financeira.md) - Regra dos 25x e simulações
- [Custo Real do Crédito](./financeiros/custo-real-credito.md) - Custo de oportunidade em financiamentos
- [Valor Futuro](./financeiros/valor-futuro.md) - Projeções de investimentos
- [À Vista vs Parcelado](./financeiros/vista-vs-parcelado.md) - Análise de melhor opção de pagamento
- [Reserva de Emergência](./financeiros/reserva-emergencia.md) - Cálculo de reservas de segurança
- [Orçamento 50/30/20](./financeiros/orcamento-regra-3050.md) - Distribuição de renda pessoal
- [Custo Efetivo Total (CET)](./financeiros/custo-efetivo-total.md) - Cálculo completo do CET

### 📊 **Constantes e Tabelas**
- [Tabelas Trabalhistas](./constantes/tabelas-trabalhistas.md) - INSS, IRRF, Salário Mínimo
- [Constantes Financeiras](./constantes/constantes-financeiras.md) - IOF, limites e validações

## 🎯 **Resumo Executivo**

| Categoria | Módulos | Fórmulas | Complexidade |
|-----------|---------|----------|--------------|
| Trabalhistas | 5 | 23 | Média/Alta |
| Financeiros | 8 | 24 | Alta |
| **Total** | **13** | **47** | **Média/Alta** |

## 🔧 **Informações Técnicas**

- **Arquitetura**: Clean Architecture com separação clara de responsabilidades
- **Padrões**: Services, Controllers, Models bem estruturados
- **Validações**: Completas com prevenção de overflow e verificação de limites
- **Atualizações**: Todas as tabelas e fórmulas estão atualizadas para 2024
- **Performance**: Cálculos otimizados e estateless

## 🚀 **Recomendações para Migração**

1. **Centralizar Constantes** - Mover tabelas para arquivo único compartilhado
2. **Extrair para Core Package** - Migrar lógica de cálculo para `packages/core`
3. **Testes Automatizados** - Implementar testes unitários para todas as fórmulas
4. **Formatação Unificada** - Service único para formatação de valores
5. **Validação Padronizada** - Service comum para validações de entrada

---

*Documentação gerada automaticamente pela análise do código fonte original*