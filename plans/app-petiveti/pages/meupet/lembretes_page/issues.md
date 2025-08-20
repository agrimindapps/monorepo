# Issues e Melhorias - LembretesPageController

## 📋 Índice Geral

### 🔴 Complexidade ALTA (8 issues)
1. [REFACTOR] - Reestruturar lógica duplicada entre Controller e Model
2. [OPTIMIZE] - Otimizar consultas de dados e carregamento
3. [REFACTOR] - Consolidar arquivos Utils duplicados
4. [SECURITY] - Implementar validação e sanitização de dados
5. [REFACTOR] - Separar responsabilidades do Controller
6. [BUG] - Corrigir gerenciamento de estado reativo
7. [OPTIMIZE] - Implementar cache inteligente de dados
8. [REFACTOR] - Melhorar arquitetura de services

### 🟡 Complexidade MÉDIA (12 issues)  
9. [FIXME] - Resolver dependência circular em utils
10. [TODO] - Implementar filtros avançados de pesquisa
11. [OPTIMIZE] - Melhorar performance de formatação de datas
12. [REFACTOR] - Padronizar tratamento de erros
13. [TODO] - Adicionar paginação de dados
14. [STYLE] - Melhorar organização de imports
15. [REFACTOR] - Padronizar nomenclatura de métodos
16. [TODO] - Implementar analytics de uso
17. [OPTIMIZE] - Otimizar operações de ordenação
18. [TODO] - Adicionar funcionalidade de backup
19. [REFACTOR] - Consolidar widgets similares
20. [TODO] - Implementar notificações push

### 🟢 Complexidade BAIXA (10 issues)
21. [STYLE] - Padronizar documentação de métodos
22. [TODO] - Adicionar constantes para magic numbers
23. [STYLE] - Melhorar formatação de código
24. [TODO] - Implementar testes unitários
25. [FIXME] - Remover código comentado
26. [STYLE] - Padronizar mensagens de erro
27. [TODO] - Adicionar logs estruturados
28. [STYLE] - Melhorar nomes de variáveis
29. [TODO] - Implementar métricas de performance
30. [STYLE] - Padronizar espaçamento de código

---

## 🔴 Complexidade ALTA

### 1. [REFACTOR] - Reestruturar lógica duplicada entre Controller e Model

**Status:** 🔴 Pendente | **Execução:** Complexa | **Risco:** Alto | **Benefício:** Alto

**Descrição:** Controller possui lógica de formatação e cálculos que deveriam estar no Model ou Utils. Métodos como formatDateToString, isLembreteAtrasado duplicam funcionalidade já existente no Model.

**Prompt de Implementação:**
Refatore o LembretesPageController removendo toda lógica de formatação e cálculos, delegando para o Model ou Utils apropriados. Mantenha apenas lógica de controle de estado e navegação no Controller.

**Dependências:** 
- lembretes_page_controller.dart
- lembretes_page_model.dart
- lembretes_utils.dart

**Validação:** Controller deve ter apenas métodos de controle, sem lógica de negócio

---

### 2. [OPTIMIZE] - Otimizar consultas de dados e carregamento

**Status:** 🔴 Pendente | **Execução:** Complexa | **Risco:** Médio | **Benefício:** Alto

**Descrição:** Múltiplas consultas desnecessárias ao repositório. Método loadLembretes faz nova consulta sempre que chamado, mesmo sem mudanças nos parâmetros.

**Prompt de Implementação:**
Implemente cache inteligente no Controller que evite consultas desnecessárias ao repositório. Adicione debounce para mudanças de filtros e cache baseado em hash dos parâmetros de consulta.

**Dependências:**
- lembretes_page_controller.dart
- lembretes_service.dart
- lembrete_repository.dart

**Validação:** Redução significativa no número de consultas ao banco

---

### 3. [REFACTOR] - Consolidar arquivos Utils duplicados

**Status:** 🔴 Pendente | **Execução:** Complexa | **Risco:** Alto | **Benefício:** Alto

**Descrição:** Existem 3 arquivos utils com funcionalidades sobrepostas: lembretes_utils.dart, lembretes_utils_consolidated.dart e date_utils.dart. Isso gera confusão e duplicação de código.

**Prompt de Implementação:**
Consolide todos os utils em um único arquivo bem estruturado, removendo duplicações e organizando por categorias: formatação, validação, cálculos e helpers.

**Dependências:**
- utils/lembretes_utils.dart
- utils/lembretes_utils_consolidated.dart  
- utils/date_utils.dart
- Todos os arquivos que importam estes utils

**Validação:** Apenas um arquivo utils principal com funcionalidades organizadas

---

### 4. [SECURITY] - Implementar validação e sanitização de dados

**Status:** 🔴 Pendente | **Execução:** Complexa | **Risco:** Alto | **Benefício:** Alto

**Descrição:** Falta validação adequada de dados de entrada em métodos como searchLembretes, filtros de data e operações de CRUD. Dados não são sanitizados antes do processamento.

**Prompt de Implementação:**
Implemente validação robusta em todos os pontos de entrada de dados. Adicione sanitização para prevenir injection e dados malformados. Use o LembretesValidators de forma consistente.

**Dependências:**
- lembretes_page_controller.dart
- lembretes_validators.dart
- lembretes_service.dart

**Validação:** Todos os inputs validados e sanitizados antes do processamento

---

### 5. [REFACTOR] - Separar responsabilidades do Controller

**Status:** 🔴 Pendente | **Execução:** Complexa | **Risco:** Médio | **Benefício:** Alto

**Descrição:** Controller possui muitas responsabilidades: controle de estado, formatação, validação, exportação CSV, geração de meses. Viola princípio da responsabilidade única.

**Prompt de Implementação:**
Separe o Controller em múltiplos services especializados: LembretesStateManager, LembretesFormatService, LembretesExportService. Mantenha no Controller apenas coordenação entre services.

**Dependências:**
- lembretes_page_controller.dart
- Criar novos services especializados

**Validação:** Controller com responsabilidades bem definidas e services especializados

---

### 6. [BUG] - Corrigir gerenciamento de estado reativo

**Status:** 🔴 Pendente | **Execução:** Complexa | **Risco:** Alto | **Benefício:** Alto

**Descrição:** Updates no model não são sempre refletidos na UI. Uso inconsistente de _model.update() pode causar problemas de sincronização entre estado e interface.

**Prompt de Implementação:**
Refatore o sistema de estado para usar streams ou ValueNotifier de forma consistente. Garanta que todos os updates de estado sejam propagados corretamente para a UI.

**Dependências:**
- lembretes_page_controller.dart
- lembretes_page_model.dart
- lembretes_page_view.dart

**Validação:** Estado sempre sincronizado entre Model e UI

---

### 7. [OPTIMIZE] - Implementar cache inteligente de dados

**Status:** 🔴 Pendente | **Execução:** Complexa | **Risco:** Médio | **Benefício:** Alto

**Descrição:** Dados são recarregados desnecessariamente a cada navegação ou mudança de filtro. Falta sistema de cache que persista dados relevantes entre sessões.

**Prompt de Implementação:**
Implemente sistema de cache em múltiplas camadas: memória para dados recentes, disco para persistência, e invalidação inteligente baseada em timestamps de modificação.

**Dependências:**
- lembretes_service.dart
- lembretes_page_controller.dart
- Criar cache_service.dart

**Validação:** Redução significativa no tempo de carregamento de dados

---

### 8. [REFACTOR] - Melhorar arquitetura de services

**Status:** 🔴 Pendente | **Execução:** Complexa | **Risco:** Médio | **Benefício:** Alto

**Descrição:** LembretesService é muito simples e apenas envolve o Repository. Falta lógica de negócio, cache, e tratamento de erros específicos do domínio.

**Prompt de Implementação:**
Expanda o LembretesService para incluir lógica de negócio, cache, retry logic, e tratamento de erros específicos. Implemente padrão Repository + Service corretamente.

**Dependências:**
- lembretes_service.dart
- lembretes_filter_service.dart
- lembrete_repository.dart

**Validação:** Service com lógica de negócio robusta e separação clara de responsabilidades

---

## 🟡 Complexidade MÉDIA

### 9. [FIXME] - Resolver dependência circular em utils

**Status:** 🟡 Pendente | **Execução:** Moderada | **Risco:** Médio | **Benefício:** Médio

**Descrição:** Comentário no código indica "Import dinamico do utils para evitar dependência circular" nos métodos _getAvailableMonthsFromUtils.

**Prompt de Implementação:**
Reestruture as dependências entre utils para eliminar imports circulares. Extraia funcionalidades comuns para um utils base ou use injeção de dependência.

**Dependências:**
- lembretes_page_controller.dart
- utils/lembretes_utils.dart

**Validação:** Estrutura de imports limpa sem dependências circulares

---

### 10. [TODO] - Implementar filtros avançados de pesquisa

**Status:** 🟡 Pendente | **Execução:** Moderada | **Risco:** Baixo | **Benefício:** Alto

**Descrição:** Apenas busca simples por texto está implementada. Faltam filtros por data, tipo, status, e combinações múltiplas.

**Prompt de Implementação:**
Adicione interface de filtros avançados permitindo filtrar por múltiplos critérios: período de datas, tipos específicos, status (atrasado/pendente/concluído), e busca combinada.

**Dependências:**
- lembretes_filter_service.dart
- lembretes_page_controller.dart
- lembretes_page_view.dart

**Validação:** Interface de filtros funcionando com múltiplos critérios

---

### 11. [OPTIMIZE] - Melhorar performance de formatação de datas

**Status:** 🟡 Pendente | **Execução:** Moderada | **Risco:** Baixo | **Benefício:** Médio

**Descrição:** Formatação de datas é feita repetidamente sem cache. Métodos como formatDateToString são chamados várias vezes para os mesmos dados.

**Prompt de Implementação:**
Implemente cache para formatação de datas e lazy loading para strings formatadas. Use memoização para evitar formatações repetidas dos mesmos timestamps.

**Dependências:**
- lembretes_page_model.dart
- utils/date_utils.dart

**Validação:** Redução no tempo de formatação de grandes listas

---

### 12. [REFACTOR] - Padronizar tratamento de erros

**Status:** 🟡 Pendente | **Execução:** Moderada | **Risco:** Médio | **Benefício:** Médio

**Descrição:** Tratamento de erros inconsistente entre métodos. Alguns usam debugPrint, outros setError, alguns fazem rethrow sem contexto.

**Prompt de Implementação:**
Padronize tratamento de erros criando ErrorHandler centralizado com diferentes níveis de logging, notificação ao usuário, e estratégias de recuperação.

**Dependências:**
- lembretes_page_controller.dart
- lembretes_service.dart
- Criar error_handler.dart

**Validação:** Tratamento de erros consistente em toda a aplicação

---

### 13. [TODO] - Adicionar paginação de dados

**Status:** 🟡 Pendente | **Execução:** Moderada | **Risco:** Baixo | **Benefício:** Alto

**Descrição:** Todas as consultas carregam todos os registros. Para usuários com muitos lembretes, isso pode causar problemas de performance e memória.

**Prompt de Implementação:**
Implemente paginação lazy loading que carregue dados conforme necessário. Adicione scroll infinito na lista e mantenha apenas dados visíveis em memória.

**Dependências:**
- lembretes_service.dart
- lembretes_page_controller.dart
- lembretes_page_view.dart

**Validação:** Lista com paginação suportando grandes volumes de dados

---

### 14. [STYLE] - Melhorar organização de imports

**Status:** 🟡 Pendente | **Execução:** Simples | **Risco:** Baixo | **Benefício:** Baixo

**Descrição:** Imports não seguem padrão consistente. Mistura de imports relativos e absolutos, sem agrupamento lógico.

**Prompt de Implementação:**
Reorganize todos os imports seguindo padrão: dart core, packages externos, arquivos locais. Agrupe imports relacionados e use paths relativos consistentemente.

**Dependências:** Todos os arquivos da pasta lembretes_page

**Validação:** Imports organizados seguindo padrão estabelecido

---

### 15. [REFACTOR] - Padronizar nomenclatura de métodos

**Status:** 🟡 Pendente | **Execução:** Moderada | **Risco:** Baixo | **Benefício:** Médio

**Descrição:** Nomenclatura inconsistente: alguns métodos usam "get" outros não, alguns usam verbos em português outros em inglês.

**Prompt de Implementação:**
Padronize nomenclatura de métodos seguindo convenções Dart: verbos em inglês, sem prefixos desnecessários, nomes descritivos e consistentes.

**Dependências:** Todos os arquivos da pasta lembretes_page

**Validação:** Nomenclatura consistente em todos os métodos

---

### 16. [TODO] - Implementar analytics de uso

**Status:** 🟡 Pendente | **Execução:** Moderada | **Risco:** Baixo | **Benefício:** Médio

**Descrição:** Não há tracking de como usuários interagem com lembretes. Dados sobre uso poderiam melhorar UX.

**Prompt de Implementação:**
Adicione analytics para rastrear: lembretes mais criados, horários preferenciais, tipos mais usados, taxa de conclusão, e padrões de uso.

**Dependências:**
- lembretes_page_controller.dart
- Criar analytics_service.dart

**Validação:** Dashboard com métricas de uso de lembretes

---

### 17. [OPTIMIZE] - Otimizar operações de ordenação

**Status:** 🟡 Pendente | **Execução:** Moderada | **Risco:** Baixo | **Benefício:** Médio

**Descrição:** Listas são ordenadas toda vez que exibidas. Para listas grandes, isso pode ser custoso computacionalmente.

**Prompt de Implementação:**
Implemente ordenação lazy e cache de listas ordenadas. Use algoritmos mais eficientes para grandes volumes e ordenação incremental quando possível.

**Dependências:**
- lembretes_filter_service.dart
- lembretes_page_model.dart

**Validação:** Ordenação eficiente mesmo com grandes volumes de dados

---

### 18. [TODO] - Adicionar funcionalidade de backup

**Status:** 🟡 Pendente | **Execução:** Moderada | **Risco:** Baixo | **Benefício:** Alto

**Descrição:** Não há funcionalidade de backup/restore de lembretes. Usuários podem perder dados importantes.

**Prompt de Implementação:**
Implemente sistema de backup automático e manual para lembretes. Permita exportação em múltiplos formatos e importação de backups anteriores.

**Dependências:**
- lembretes_service.dart
- Criar backup_service.dart

**Validação:** Funcionalidade de backup/restore operacional

---

### 19. [REFACTOR] - Consolidar widgets similares

**Status:** 🟡 Pendente | **Execução:** Moderada | **Risco:** Baixo | **Benefício:** Médio

**Descrição:** Widgets como LembreteCard e NoDataMessage poderiam ser generalizados para reutilização em outras páginas.

**Prompt de Implementação:**
Extraia widgets específicos para widgets genéricos reutilizáveis. Mova para pasta shared/widgets e parametrize para diferentes contextos de uso.

**Dependências:**
- views/widgets/lembrete_card.dart
- views/widgets/no_data_message.dart

**Validação:** Widgets reutilizáveis em pasta compartilhada

---

### 20. [TODO] - Implementar notificações push

**Status:** 🟡 Pendente | **Execução:** Moderada | **Risco:** Médio | **Benefício:** Alto

**Descrição:** Lembretes não possuem notificações push. Usuários podem esquecer compromissos importantes.

**Prompt de Implementação:**
Integre sistema de notificações push que envie alertas baseados na data/hora dos lembretes. Permita configuração de antecedência e tipos de notificação.

**Dependências:**
- lembretes_page_controller.dart
- pet_notification_manager.dart

**Validação:** Notificações funcionando para lembretes agendados

---

## 🟢 Complexidade BAIXA

### 21. [STYLE] - Padronizar documentação de métodos

**Status:** 🟢 Pendente | **Execução:** Simples | **Risco:** Baixo | **Benefício:** Baixo

**Descrição:** Muitos métodos não possuem documentação ou possuem documentação inconsistente.

**Prompt de Implementação:**
Adicione documentação dartdoc para todos os métodos públicos, incluindo parâmetros, retorno, e exemplos de uso quando apropriado.

**Dependências:** Todos os arquivos da pasta lembretes_page

**Validação:** Todos os métodos públicos documentados

---

### 22. [TODO] - Adicionar constantes para magic numbers

**Status:** 🟢 Pendente | **Execução:** Simples | **Risco:** Baixo | **Benefício:** Baixo

**Descrição:** Valores como 30 dias, 1825 dias, 100 caracteres estão hardcoded no código.

**Prompt de Implementação:**
Extraia todos os números mágicos para constantes nomeadas em arquivo constants.dart com nomes descritivos e documentação.

**Dependências:** Todos os arquivos com números hardcoded

**Validação:** Ausência de números mágicos no código

---

### 23. [STYLE] - Melhorar formatação de código

**Status:** 🟢 Pendente | **Execução:** Simples | **Risco:** Baixo | **Benefício:** Baixo

**Descrição:** Inconsistências na formatação: espaçamento, quebras de linha, alinhamento de código.

**Prompt de Implementação:**
Aplique dart format em todos os arquivos e configure regras de linting mais rigorosas para manter formatação consistente.

**Dependências:** Todos os arquivos da pasta lembretes_page

**Validação:** Código formatado consistentemente

---

### 24. [TODO] - Implementar testes unitários

**Status:** 🟢 Pendente | **Execução:** Simples | **Risco:** Baixo | **Benefício:** Alto

**Descrição:** Não existem testes unitários para validar funcionalidades críticas dos lembretes.

**Prompt de Implementação:**
Crie suite de testes unitários cobrindo Controller, Model, Services e Utils. Foque em cenários críticos e edge cases.

**Dependências:** Criar arquivos de teste para cada componente

**Validação:** Cobertura de testes acima de 80%

---

### 25. [FIXME] - Remover código comentado

**Status:** 🟢 Pendente | **Execução:** Simples | **Risco:** Baixo | **Benefício:** Baixo

**Descrição:** Método _cancelarNotificacaoLembrete está vazio apenas com comentário TODO.

**Prompt de Implementação:**
Implemente ou remova métodos vazios e código comentado desnecessário. Mantenha apenas TODOs relevantes com prazo definido.

**Dependências:**
- lembretes_page_controller.dart

**Validação:** Código limpo sem métodos vazios ou comentários desnecessários

---

### 26. [STYLE] - Padronizar mensagens de erro

**Status:** 🟢 Pendente | **Execução:** Simples | **Risco:** Baixo | **Benefício:** Baixo

**Descrição:** Mensagens de erro não seguem padrão consistente de linguagem e formatação.

**Prompt de Implementação:**
Centralize todas as mensagens em arquivo constants e padronize tom, formato e nível de detalhamento das mensagens de erro.

**Dependências:**
- Todos os arquivos que exibem mensagens de erro

**Validação:** Mensagens de erro consistentes e centralizadas

---

### 27. [TODO] - Adicionar logs estruturados

**Status:** 🟢 Pendente | **Execução:** Simples | **Risco:** Baixo | **Benefício:** Médio

**Descrição:** Logging atual usa apenas debugPrint sem estrutura ou níveis apropriados.

**Prompt de Implementação:**
Implemente sistema de logging estruturado com diferentes níveis (debug, info, warning, error) e contexto adequado para debugging.

**Dependências:**
- Todos os arquivos que fazem logging

**Validação:** Sistema de logging estruturado implementado

---

### 28. [STYLE] - Melhorar nomes de variáveis

**Status:** 🟢 Pendente | **Execução:** Simples | **Risco:** Baixo | **Benefício:** Baixo

**Descrição:** Algumas variáveis têm nomes pouco descritivos como "e" para exceptions, "result" genérico.

**Prompt de Implementação:**
Renomeie variáveis para nomes mais descritivos e significativos que expressem claramente sua função no contexto.

**Dependências:** Todos os arquivos com nomes pouco descritivos

**Validação:** Variáveis com nomes claros e descritivos

---

### 29. [TODO] - Implementar métricas de performance

**Status:** 🟢 Pendente | **Execução:** Simples | **Risco:** Baixo | **Benefício:** Médio

**Descrição:** Não há medição de performance para operações críticas como carregamento e filtragem.

**Prompt de Implementação:**
Adicione medição de tempo para operações críticas e logging de métricas de performance para identificar gargalos.

**Dependências:**
- lembretes_page_controller.dart
- lembretes_service.dart

**Validação:** Métricas de performance sendo coletadas e analisadas

---

### 30. [STYLE] - Padronizar espaçamento de código

**Status:** 🟢 Pendente | **Execução:** Simples | **Risco:** Baixo | **Benefício:** Baixo

**Descrição:** Espaçamento inconsistente entre métodos, blocos de código e seções lógicas.

**Prompt de Implementação:**
Padronize espaçamento seguindo guia de estilo Dart: linha em branco entre métodos, espaçamento consistente em blocos lógicos.

**Dependências:** Todos os arquivos da pasta lembretes_page

**Validação:** Espaçamento consistente seguindo padrões estabelecidos

---

## 🚀 Comandos Rápidos para Solicitações Futuras

**Para refatorações principais:**
- "Refatore o LembretesPageController separando responsabilidades conforme issue #5"
- "Consolide os arquivos utils conforme issue #3"
- "Implemente cache inteligente conforme issue #2"

**Para melhorias de performance:**
- "Otimize consultas de dados conforme issue #2"
- "Implemente paginação conforme issue #13" 
- "Otimize formatação de datas conforme issue #11"

**Para correções de bugs:**
- "Corrija gerenciamento de estado reativo conforme issue #6"
- "Resolva dependência circular conforme issue #9"

**Para implementações de features:**
- "Adicione filtros avançados conforme issue #10"
- "Implemente notificações push conforme issue #20"
- "Adicione funcionalidade de backup conforme issue #18"

**Para melhorias de código:**
- "Padronize nomenclatura conforme issue #15"
- "Melhore tratamento de erros conforme issue #12"
- "Adicione testes unitários conforme issue #24"