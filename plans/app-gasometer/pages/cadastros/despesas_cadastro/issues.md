# Issues e Melhorias - index.dart

## 📋 Índice Geral

### 🔴 Complexidade ALTA (6 issues)
1. [REFACTOR] - Reestruturar gestão de estado do controller
2. [BUG] - Corrigir race condition no gerenciamento de controller
3. [OPTIMIZE] - Implementar cache para dados de veículos
4. [SECURITY] - Validar entrada de dados contra XSS/injeção
5. [REFACTOR] - Extrair lógica de formatação para service
6. [TODO] - Implementar enum para tipos de despesa

### 🟡 Complexidade MÉDIA (8 issues)
7. [FIXME] - Corrigir validação de odômetro inconsistente
8. [TODO] - Adicionar feedback visual para operações assíncronas
9. [OPTIMIZE] - Melhorar performance dos text formatters
10. [REFACTOR] - Separar responsabilidades do form model
11. [TODO] - Implementar validação offline/online
12. [STYLE] - Padronizar espaçamento e layout dos componentes
13. [TODO] - Adicionar suporte para diferentes moedas
14. [TEST] - Implementar testes unitários para validators

### 🟢 Complexidade BAIXA (7 issues)
15. [DOC] - Adicionar documentação para métodos públicos
16. [STYLE] - Remover código comentado desnecessário
17. [TODO] - Melhorar mensagens de erro para usuário
18. [OPTIMIZE] - Otimizar imports desnecessários
19. [TODO] - Adicionar tooltips para campos do formulário
20. [STYLE] - Padronizar nomenclatura de métodos
21. [TODO] - Implementar modo escuro para o formulário

---

## 🔴 Complexidade ALTA

### 1. [REFACTOR] - Reestruturar gestão de estado do controller

**Status:** 🔴 Pendente | **Execução:** Complexa | **Risco:** Alto | **Benefício:** Alto

**Descrição:** O controller possui muitas responsabilidades e gerencia estados 
reativos de forma redundante. Há duplicação entre campos individuais e o formModel, 
causando overhead desnecessário e potenciais inconsistências.

**Prompt de Implementação:**
```
Refatore o DespesaCadastroFormController para usar apenas o formModel como fonte 
única de verdade. Remova os campos reativos individuais (veiculoId, tipo, descricao, 
etc.) mantendo apenas o Rx<DespesaCadastroFormModel>. Ajuste todos os métodos para 
trabalhar diretamente com o formModel e atualize a view para usar apenas o formModel. 
Mantenha a funcionalidade de validação e formatação intacta.
```

**Dependências:** despesas_cadastro_form_controller.dart, despesas_cadastro_form_view.dart

**Validação:** Confirmar que todas as funcionalidades de edição, validação e 
formatação continuam funcionando corretamente

### 2. [BUG] - Corrigir race condition no gerenciamento de controller

**Status:** 🔴 Pendente | **Execução:** Complexa | **Risco:** Alto | **Benefício:** Alto

**Descrição:** Existe uma race condition entre a inicialização do controller e 
o carregamento dos dados do veículo. O método initializeWithDespesa pode ser 
chamado antes do controller estar completamente inicializado.

**Prompt de Implementação:**
```
Implemente um sistema de inicialização assíncrona no DespesaCadastroFormController 
que garanta que o controller esteja completamente inicializado antes de processar 
dados de despesa. Adicione um RxBool isInitialized e faça com que initializeWithDespesa 
aguarde a inicialização completa. Implemente timeout para evitar travamentos.
```

**Dependências:** despesas_cadastro_form_controller.dart, despesas_cadastro_widget.dart

**Validação:** Testar abertura rápida de múltiplos diálogos de edição e confirmar 
que não há erro de estado

### 3. [OPTIMIZE] - Implementar cache para dados de veículos

**Status:** 🔴 Pendente | **Execução:** Complexa | **Risco:** Médio | **Benefício:** Alto

**Descrição:** O controller faz chamadas desnecessárias ao repository para carregar 
dados de veículos que já foram carregados anteriormente, causando lentidão e 
consumo desnecessário de recursos.

**Prompt de Implementação:**
```
Implemente um sistema de cache no DespesaCadastroFormController para dados de 
veículos. Crie um Map<String, VeiculoCar> para armazenar veículos já carregados, 
com TTL de 5 minutos. Adicione métodos para invalidar cache quando necessário e 
implemente fallback para chamadas de repository quando cache expira.
```

**Dependências:** despesas_cadastro_form_controller.dart, veiculos_repository.dart

**Validação:** Monitorar redução de chamadas ao repository e melhoria na 
responsividade do formulário

### 4. [SECURITY] - Validar entrada de dados contra XSS/injeção

**Status:** 🔴 Pendente | **Execução:** Moderada | **Risco:** Alto | **Benefício:** Alto

**Descrição:** Os campos de entrada não possuem validação contra caracteres 
perigosos ou tentativas de injeção de código, principalmente no campo descrição 
que aceita texto livre.

**Prompt de Implementação:**
```
Implemente validação de segurança em todos os campos de entrada do formulário. 
Crie um validator que detecte e sanitize caracteres perigosos como scripts, 
SQL injection patterns e caracteres de controle. Adicione whitelist para 
caracteres permitidos em cada campo e implemente escape para caracteres especiais.
```

**Dependências:** despesas_cadastro_form_controller.dart, despesas_cadastro_form_model.dart

**Validação:** Testar entrada de scripts maliciosos e confirmar que são 
bloqueados ou sanitizados

### 5. [REFACTOR] - Extrair lógica de formatação para service

**Status:** 🔴 Pendente | **Execução:** Moderada | **Risco:** Médio | **Benefício:** Alto

**Descrição:** O controller possui muita lógica de formatação de dados que deveria 
estar em um service separado para reutilização e manutenibilidade.

**Prompt de Implementação:**
```
Crie um FormatterService que contenha todos os métodos de formatação: 
formatCurrency, formatDate, formatTime, parseAndSetValor, parseAndSetOdometro. 
Refatore o controller para usar este service e implemente singleton pattern. 
Adicione configuração de locale e métodos para diferentes formatos de data/moeda.
```

**Dependências:** despesas_cadastro_form_controller.dart, novo arquivo formatter_service.dart

**Validação:** Confirmar que todas as formatações continuam funcionando e que 
o service pode ser reutilizado em outros controllers

### 6. [TODO] - Implementar enum para tipos de despesa

**Status:** 🔴 Pendente | **Execução:** Moderada | **Risco:** Médio | **Benefício:** Alto

**Descrição:** O sistema usa strings hardcoded para tipos de despesa, o que 
dificulta manutenção e pode causar erros de digitação. Relacionado com comentário 
TODO existente no modelo de dados.

**Prompt de Implementação:**
```
Crie um enum TipoDespesa com todos os tipos existentes em DespesaConstants. 
Implemente extensões para o enum com métodos de conversão para string, ícones 
e localização. Refatore todo o sistema para usar o enum em vez de strings, 
incluindo modelo de dados, controller, view e constants.
```

**Dependências:** despesas_constants.dart, despesas_cadastro_form_model.dart, 
despesas_cadastro_form_controller.dart, despesas_cadastro_form_view.dart

**Validação:** Confirmar que todos os tipos de despesa aparecem corretamente 
e que não há quebras de compatibilidade

---

## 🟡 Complexidade MÉDIA

### 7. [FIXME] - Corrigir validação de odômetro inconsistente

**Status:** 🔴 Pendente | **Execução:** Moderada | **Risco:** Médio | **Benefício:** Médio

**Descrição:** A validação do odômetro permite apenas 1 casa decimal no formatter 
mas valida valores com mais casas decimais, causando inconsistência na experiência 
do usuário.

**Prompt de Implementação:**
```
Padronize a validação e formatação do odômetro para trabalhar consistentemente 
com 1 casa decimal. Ajuste o FilteringTextInputFormatter e os métodos de 
validação para garantir que aceitem e validem apenas valores com 1 casa decimal. 
Implemente arredondamento automático quando necessário.
```

**Dependências:** despesas_cadastro_form_controller.dart, despesas_cadastro_form_view.dart

**Validação:** Testar entrada de valores com múltiplas casas decimais e confirmar 
comportamento consistente

### 8. [TODO] - Adicionar feedback visual para operações assíncronas

**Status:** 🔴 Pendente | **Execução:** Moderada | **Risco:** Baixo | **Benefício:** Alto

**Descrição:** Durante operações como carregamento de veículo e salvamento de 
despesa, o usuário não recebe feedback visual adequado sobre o progresso da operação.

**Prompt de Implementação:**
```
Implemente indicadores visuais de carregamento no formulário. Adicione shimmer 
ou skeleton loading para carregamento de veículo, loading indicator no botão 
de submit e desabilite campos durante operações assíncronas. Use o estado 
isLoading existente para controlar visibilidade dos indicadores.
```

**Dependências:** despesas_cadastro_form_view.dart, despesas_cadastro_widget.dart

**Validação:** Confirmar que indicadores aparecem durante operações assíncronas 
e desaparecem corretamente

### 9. [OPTIMIZE] - Melhorar performance dos text formatters

**Status:** 🔴 Pendente | **Execução:** Moderada | **Risco:** Baixo | **Benefício:** Médio

**Descrição:** Os formatters de texto fazem múltiplas operações de string em 
tempo real, causando lag durante digitação rápida em dispositivos com menos 
recursos.

**Prompt de Implementação:**
```
Otimize os métodos parseAndSetValor e parseAndSetOdometro implementando debounce 
para evitar processamento excessivo. Use regex pré-compiladas para melhor 
performance e implemente cache para valores já formatados. Adicione throttling 
para chamadas de setState.
```

**Dependências:** despesas_cadastro_form_controller.dart

**Validação:** Testar digitação rápida em dispositivos menos potentes e medir 
melhoria na responsividade

### 10. [REFACTOR] - Separar responsabilidades do form model

**Status:** 🔴 Pendente | **Execução:** Moderada | **Risco:** Médio | **Benefício:** Médio

**Descrição:** O DespesaCadastroFormModel tem muitas responsabilidades, incluindo 
validação, conversão de dados e lógica de negócio, violando o princípio de 
responsabilidade única.

**Prompt de Implementação:**
```
Refatore o DespesaCadastroFormModel separando responsabilidades. Crie um 
DespesaValidator para validações, um DespesaConverter para conversões de dados 
e mantenha no model apenas dados e estado. Implemente interfaces claras para 
cada responsabilidade e ajuste o controller para usar os novos components.
```

**Dependências:** despesas_cadastro_form_model.dart, despesas_cadastro_form_controller.dart

**Validação:** Confirmar que todas as validações e conversões continuam funcionando 
após refatoração

### 11. [TODO] - Implementar validação offline/online

**Status:** 🔴 Pendente | **Execução:** Moderada | **Risco:** Baixo | **Benefício:** Médio

**Descrição:** O sistema não distingue entre validações que podem ser feitas 
offline e aquelas que precisam de conectividade, causando frustração quando 
usuário está sem internet.

**Prompt de Implementação:**
```
Implemente sistema de validação em duas camadas: validações offline (formato, 
obrigatoriedade, ranges) e validações online (verificação de odômetro, 
duplicatas). Adicione indicadores visuais para mostrar status de conectividade 
e permita salvar rascunhos quando offline.
```

**Dependências:** despesas_cadastro_form_controller.dart, despesas_cadastro_form_model.dart

**Validação:** Testar funcionalidade com e sem conexão de internet

### 12. [STYLE] - Padronizar espaçamento e layout dos componentes

**Status:** 🔴 Pendente | **Execução:** Simples | **Risco:** Baixo | **Benefício:** Médio

**Descrição:** O formulário possui espaçamentos inconsistentes entre campos e 
seções, prejudicando a harmonia visual e experiência do usuário.

**Prompt de Implementação:**
```
Padronize todos os espaçamentos do formulário usando um sistema de design 
consistente. Defina constantes para espaçamentos padrão (pequeno, médio, grande) 
e aplique consistentemente entre campos, seções e margens. Use o ShadcnStyle 
como base para padronização.
```

**Dependências:** despesas_cadastro_form_view.dart

**Validação:** Confirmar que o formulário apresenta espaçamento visualmente 
harmonioso e consistente

### 13. [TODO] - Adicionar suporte para diferentes moedas

**Status:** 🔴 Pendente | **Execução:** Moderada | **Risco:** Baixo | **Benefício:** Baixo

**Descrição:** O sistema está hardcoded para Real brasileiro, limitando uso 
em outros países ou para usuários que registram despesas em moeda estrangeira.

**Prompt de Implementação:**
```
Implemente suporte para múltiplas moedas no formulário de despesas. Adicione 
dropdown para seleção de moeda, ajuste formatação de valores dinamicamente 
e implemente conversão automática para moeda base. Use biblioteca de 
internacionalização para símbolos de moeda corretos.
```

**Dependências:** despesas_cadastro_form_controller.dart, despesas_cadastro_form_view.dart, 
despesas_cadastro_form_model.dart

**Validação:** Testar formatação correta para diferentes moedas e conversões

### 14. [TEST] - Implementar testes unitários para validators

**Status:** 🔴 Pendente | **Execução:** Moderada | **Risco:** Baixo | **Benefício:** Alto

**Descrição:** Os métodos de validação não possuem testes unitários, aumentando 
risco de regressões e dificultando manutenção futura.

**Prompt de Implementação:**
```
Crie testes unitários completos para todos os métodos de validação do controller: 
validateTipo, validateDescricao, validateValor, validateOdometro. Teste casos 
de sucesso, falha e edge cases. Implemente também testes para métodos de 
formatação e parsing de valores.
```

**Dependências:** despesas_cadastro_form_controller.dart, novo arquivo de teste

**Validação:** Executar testes e confirmar cobertura de 100% dos métodos de validação

---

## 🟢 Complexidade BAIXA

### 15. [DOC] - Adicionar documentação para métodos públicos

**Status:** 🔴 Pendente | **Execução:** Simples | **Risco:** Baixo | **Benefício:** Médio

**Descrição:** Métodos públicos das classes não possuem documentação adequada, 
dificultando manutenção e compreensão do código por outros desenvolvedores.

**Prompt de Implementação:**
```
Adicione documentação Dart (///) para todos os métodos públicos das classes 
DespesaCadastroFormController, DespesaCadastroFormModel e DespesaCadastroWidget. 
Inclua descrição do propósito, parâmetros, retorno e exemplos quando apropriado. 
Siga padrões de documentação Dart.
```

**Dependências:** Todos os arquivos do módulo

**Validação:** Confirmar que documentação aparece corretamente no IDE e 
ferramentas de análise

### 16. [STYLE] - Remover código comentado desnecessário

**Status:** 🔴 Pendente | **Execução:** Simples | **Risco:** Baixo | **Benefício:** Baixo

**Descrição:** Existe código comentado no arquivo de modelo que pode ser removido 
para melhorar limpeza do código.

**Prompt de Implementação:**
```
Revise todos os arquivos do módulo e remova comentários de código morto que 
não servem mais propósito. Mantenha apenas comentários TODO, FIXME e documentação 
útil. Organize comentários restantes para melhor legibilidade.
```

**Dependências:** Todos os arquivos do módulo

**Validação:** Confirmar que apenas comentários úteis permanecem no código

### 17. [TODO] - Melhorar mensagens de erro para usuário

**Status:** 🔴 Pendente | **Execução:** Simples | **Risco:** Baixo | **Benefício:** Médio

**Descrição:** Mensagens de erro de validação são técnicas demais e não orientam 
adequadamente o usuário sobre como corrigir problemas.

**Prompt de Implementação:**
```
Reescreva todas as mensagens de erro dos validators para serem mais amigáveis 
e informativas. Use linguagem simples, evite termos técnicos e forneça 
orientações claras sobre como corrigir o erro. Implemente mensagens contextuais 
baseadas no tipo de erro específico.
```

**Dependências:** despesas_cadastro_form_controller.dart, despesas_constants.dart

**Validação:** Testar todos os cenários de erro e confirmar que mensagens são 
claras e úteis

### 18. [OPTIMIZE] - Otimizar imports desnecessários

**Status:** 🔴 Pendente | **Execução:** Simples | **Risco:** Baixo | **Benefício:** Baixo

**Descrição:** Alguns arquivos podem ter imports não utilizados ou imports 
que poderiam ser otimizados, afetando performance de compilação.

**Prompt de Implementação:**
```
Revise todos os imports em todos os arquivos do módulo. Remova imports não 
utilizados, organize imports por categorias (dart, flutter, packages, relative) 
e verifique se há imports redundantes. Use ferramentas de análise estática 
para identificar imports desnecessários.
```

**Dependências:** Todos os arquivos do módulo

**Validação:** Confirmar que aplicação compila sem warnings e que todos os 
imports são necessários

### 19. [TODO] - Adicionar tooltips para campos do formulário

**Status:** 🔴 Pendente | **Execução:** Simples | **Risco:** Baixo | **Benefício:** Médio

**Descrição:** Campos do formulário não possuem ajuda contextual para usuários 
que podem não entender completamente o propósito de cada campo.

**Prompt de Implementação:**
```
Adicione tooltips informativos para todos os campos do formulário. Inclua 
explicações sobre formato esperado, exemplos de preenchimento e dicas de uso. 
Implemente tooltips que apareçam ao tocar em ícones de ajuda próximos aos 
campos.
```

**Dependências:** despesas_cadastro_form_view.dart

**Validação:** Confirmar que tooltips aparecem corretamente e fornecem informações 
úteis

### 20. [STYLE] - Padronizar nomenclatura de métodos

**Status:** 🔴 Pendente | **Execução:** Simples | **Risco:** Baixo | **Benefício:** Baixo

**Descrição:** Alguns métodos não seguem convenções de nomenclatura Dart 
consistentes, prejudicando legibilidade e manutenibilidade.

**Prompt de Implementação:**
```
Revise nomenclatura de todos os métodos para seguir padrões Dart: camelCase, 
verbos descritivos, nomes que expressam claramente a intenção. Renomeie métodos 
inconsistentes e atualize todas as referências. Documente padrões de nomenclatura 
adotados.
```

**Dependências:** Todos os arquivos do módulo

**Validação:** Confirmar que todos os métodos seguem padrões consistentes de 
nomenclatura

### 21. [TODO] - Implementar modo escuro para o formulário

**Status:** 🔴 Pendente | **Execução:** Simples | **Risco:** Baixo | **Benefício:** Médio

**Descrição:** O formulário não se adapta ao modo escuro do sistema, prejudicando 
experiência do usuário que prefere temas escuros.

**Prompt de Implementação:**
```
Implemente suporte completo ao modo escuro no formulário. Ajuste cores de 
fundo, texto, bordas e ícones para seguir tema escuro do sistema. Use Theme.of(context) 
para detectar tema atual e aplicar cores apropriadas. Teste em ambos os modos.
```

**Dependências:** despesas_cadastro_form_view.dart, shadcn_style.dart

**Validação:** Testar formulário em modo claro e escuro confirmando boa 
legibilidade em ambos

---

## 🔧 Comandos Rápidos

Para solicitar implementação específica, use:
- `Executar #[número]` - Para que a IA implemente uma issue específica
- `Detalhar #[número]` - Para obter prompt mais detalhado sobre implementação
- `Focar [complexidade]` - Para trabalhar apenas com issues de uma complexidade
- `Agrupar [tipo]` - Para executar todas as issues de um tipo
- `Validar #[número]` - Para que a IA revise implementação concluída

## 📊 Métricas de Priorização

**Ordem sugerida de implementação:**
1. Issues de SECURITY e BUG (críticas)
2. Issues de REFACTOR que impactam arquitetura
3. Issues de OPTIMIZE para performance
4. Issues de TODO para funcionalidades
5. Issues de STYLE e DOC para manutenibilidade

**Relacionamentos entre issues:**
- #1 e #10 estão relacionadas (refatoração de responsabilidades)
- #5 e #9 podem ser implementadas juntas (formatação)
- #6 e #17 compartilham dependências (constants)
- #12 e #21 são melhorias visuais complementares
