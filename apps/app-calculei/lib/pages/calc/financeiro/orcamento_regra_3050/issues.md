# Issues - Orçamento Regra 50-30-20

## Índice Geral
- [Complexidade ALTA](#complexidade-alta) (4 issues)
- [Complexidade MÉDIA](#complexidade-média) (8 issues)
- [Complexidade BAIXA](#complexidade-baixa) (10 issues)

---

## Complexidade ALTA

### 1. [REFATORAÇÃO] Extrair lógica de validação para service dedicado
**Arquivo:** `controllers/orcamento_controller.dart`
**Problema:** Lógica de validação e conversão de valores está misturada com o
controller, violando o princípio da responsabilidade única.
**Solução:** Criar `OrcamentoValidationService` para centralizar validações,
conversões e regras de negócio.
**Benefício:** Facilita testes unitários, reutilização e manutenção.

### 2. [ARQUITETURA] Implementar padrão Repository para persistência
**Arquivo:** Todos os módulos
**Problema:** Não há persistência local dos dados ou histórico de cálculos.
**Solução:** Implementar `OrcamentoRepository` com SharedPreferences/Hive para
salvar histórico de cálculos e configurações do usuário.
**Benefício:** Melhora experiência do usuário com dados persistentes.

### 3. [FUNCIONALIDADE] Adicionar sistema de metas e acompanhamento
**Arquivo:** `models/orcamento_model.dart`
**Problema:** Falta funcionalidade para definir metas financeiras e acompanhar
evolução ao longo do tempo.
**Solução:** Expandir modelo para incluir metas mensais, progresso e alertas
automáticos quando metas são atingidas.
**Benefício:** Transforma calculadora em ferramenta de planejamento financeiro.

### 4. [PERFORMANCE] Implementar cálculos reativos com debounce
**Arquivo:** `controllers/orcamento_controller.dart`
**Problema:** Recalcula a cada mudança de campo, mesmo para valores
intermediários durante digitação.
**Solução:** Implementar debounce nos campos de entrada e cálculos reativos
automáticos após 500ms de inatividade.
**Benefício:** Melhora performance e experiência do usuário.

---

## Complexidade MÉDIA

### 5. [CÓDIGO] Eliminar duplicação de PieChartSectionData
**Arquivo:** `widgets/orcamento_result_widget.dart`
**Problema:** Configuração de gráfico ideal está duplicada em múltiplos locais
(linhas 141-174 e 189-222).
**Solução:** Extrair para método privado `_buildIdealChartSections()` ou
constante estática.
**Benefício:** Reduz código duplicado e facilita manutenção.

### 6. [USABILIDADE] Adicionar tooltips explicativos nos campos
**Arquivo:** `widgets/orcamento_form_widget.dart`
**Problema:** Usuários podem não entender diferença entre despesas essenciais
e não essenciais.
**Solução:** Adicionar tooltips com exemplos práticos (ex: "Despesas
Essenciais: aluguel, alimentação, transporte").
**Benefício:** Melhora usabilidade e educação financeira.

### 7. [VISUAL] Melhorar responsividade dos gráficos
**Arquivo:** `widgets/orcamento_result_widget.dart`
**Problema:** Gráficos têm tamanho fixo (200px) que pode não se adaptar bem a
todas as telas.
**Solução:** Implementar tamanho responsivo baseado em percentage da tela com
limites mínimos/máximos.
**Benefício:** Melhor experiência visual em diferentes dispositivos.

### 8. [FUNCIONALIDADE] Adicionar sugestões inteligentes de otimização
**Arquivo:** `models/orcamento_model.dart`
**Problema:** Análise atual é muito básica, não oferece sugestões concretas
de melhoria.
**Solução:** Implementar algoritmo que sugere redistribuição baseada nos
valores atuais (ex: "Reduza R$ 200 em despesas não essenciais").
**Benefício:** Torna ferramenta mais educativa e prática.

### 9. [ACESSIBILIDADE] Implementar suporte completo para screen readers
**Arquivo:** `widgets/orcamento_result_widget.dart`
**Problema:** Gráficos não são acessíveis para usuários com deficiência visual.
**Solução:** Adicionar Semantics widgets com descrições textuais dos dados
e usar cores com contraste adequado.
**Benefício:** Torna aplicação inclusiva e acessível.

### 10. [DADOS] Adicionar validação de limite máximo por categoria
**Arquivo:** `models/orcamento_model.dart`
**Problema:** Não há validação se soma das categorias excede 100% da renda.
**Solução:** Implementar validação que alerta quando distribuição ultrapassa
100% e sugere ajustes proporcionais.
**Benefício:** Evita configurações impossíveis e educa sobre limites.

### 11. [SEGURANÇA] Sanitizar entrada de dados monetários
**Arquivo:** `controllers/orcamento_controller.dart`
**Problema:** Conversão de string para double pode falhar com entradas
maliciosas ou formatação inesperada.
**Solução:** Implementar validação robusta com regex e tratamento de exceções
específicas para diferentes formatos monetários.
**Benefício:** Aumenta robustez e segurança da aplicação.

### 12. [PERFORMANCE] Otimizar reconstrução de widgets
**Arquivo:** `widgets/orcamento_result_widget.dart`
**Problema:** Widget reconstrói completamente a cada mudança, mesmo quando
apenas uma parte precisa ser atualizada.
**Solução:** Implementar Consumer seletivo ou separar em sub-widgets menores
com Selector do Provider.
**Benefício:** Melhora performance e suavidade das animações.

---

## Complexidade BAIXA

### 13. [CÓDIGO] Extrair cores hardcoded para constantes
**Arquivo:** `controllers/orcamento_controller.dart`
**Problema:** Cores dos gráficos estão hardcoded (Colors.blue, Colors.green,
Colors.orange).
**Solução:** Criar classe `OrcamentoColors` com constantes nomeadas
semânticamente.
**Benefício:** Facilita manutenção e tematização futura.

### 14. [NOMENCLATURA] Corrigir nome da classe página
**Arquivo:** `index.dart`
**Problema:** Nome da classe `OrcamentoRegra5030Page` tem ordem invertida
(deveria ser 50-30-20).
**Solução:** Renomear para `OrcamentoRegra503020Page` ou
`OrcamentoRegra502030Page`.
**Benefício:** Melhora clareza e consistência na nomenclatura.

### 15. [DOCUMENTAÇÃO] Adicionar comentários JSDoc nos métodos principais
**Arquivo:** `controllers/orcamento_controller.dart`
**Problema:** Métodos como `calcular()` e `avaliarSituacao()` não têm
documentação.
**Solução:** Adicionar comentários /// descrevendo parâmetros, retorno e
comportamento.
**Benefício:** Melhora manutenibilidade e onboarding de novos desenvolvedores.

### 16. [LOCALIZAÇÃO] Extrair strings hardcoded para arquivo de localização
**Arquivo:** Todos os arquivos
**Problema:** Textos estão hardcoded em português, dificultando
internacionalização.
**Solução:** Criar arquivo de strings localizadas e usar Flutter l10n.
**Benefício:** Prepara aplicação para múltiplos idiomas.

### 17. [VISUAL] Melhorar feedback visual durante cálculos
**Arquivo:** `widgets/orcamento_form_widget.dart`
**Problema:** Não há indicador de loading ou feedback visual durante o
processamento.
**Solução:** Adicionar CircularProgressIndicator no botão durante cálculo.
**Benefício:** Melhora percepção de responsividade da aplicação.

### 18. [FUNCIONALIDADE] Implementar função "Limpar Tudo"
**Arquivo:** `controllers/orcamento_controller.dart`
**Problema:** Função limpar() existe no controller mas não é facilmente
acessível na interface.
**Solução:** Adicionar botão "Limpar Tudo" visível na interface principal.
**Benefício:** Melhora usabilidade permitindo reset rápido.

### 19. [QUALIDADE] Adicionar validação de entrada em tempo real
**Arquivo:** `widgets/orcamento_form_widget.dart`
**Problema:** Validação só ocorre ao calcular, não durante a digitação.
**Solução:** Implementar validação em tempo real com mensagens de erro
inline.
**Benefício:** Melhora experiência do usuário com feedback imediato.

### 20. [FUNCIONALIDADE] Adicionar comparação com média nacional
**Arquivo:** `models/orcamento_model.dart`
**Problema:** Usuário não tem referência se seus gastos estão dentro da
média.
**Solução:** Incluir dados de referência da média nacional brasileira por
categoria.
**Benefício:** Fornece contexto e benchmarking para o usuário.

### 21. [CÓDIGO] Simplificar lógica de formatação de moeda
**Arquivo:** `controllers/orcamento_controller.dart`
**Problema:** Formatador de moeda é criado múltiplas vezes, podendo ser
estático.
**Solução:** Tornar formatadores estáticos ou usar singleton pattern.
**Benefício:** Pequena otimização de memória e performance.

### 22. [TESTES] Criar testes unitários para lógica de negócio
**Arquivo:** Todos os arquivos
**Problema:** Não há testes unitários para validar cálculos e lógica.
**Solução:** Implementar testes para métodos de cálculo, validação e
formatação.
**Benefício:** Aumenta confiabilidade e facilita refatorações futuras.

---

**Total de Issues:** 22 (4 alta + 8 média + 10 baixa complexidade)

**Prioridade de Implementação:**
1. Issues de complexidade ALTA (1-4) - Impacto significativo na arquitetura
2. Issues de usabilidade e visual (6,7,9) - Melhoria da experiência do usuário
3. Issues de código e manutenção (5,13,14) - Qualidade do código
4. Issues funcionais menores (18,20,22) - Melhorias incrementais