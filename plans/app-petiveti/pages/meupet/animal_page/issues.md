# Issues e Melhorias - Animal Page

## 📋 Índice Geral

### 🔴 Complexidade ALTA (5 issues)
1. [REFACTOR] - Consolidar lógica duplicada entre services e controller
2. [OPTIMIZE] - Implementar virtualização para grandes listas de animais
3. [TODO] - Adicionar sistema de filtros avançados e pesquisa inteligente
4. [REFACTOR] - Separar responsabilidades do controller sobrecarregado
5. [SECURITY] - Implementar validação de autorização para operações críticas

### 🟡 Complexidade MÉDIA (7 issues)
6. [BUG] - Corrigir inconsistência no estado AnimalPageState não utilizado
7. [TODO] - Implementar cache e otimização de queries
8. [OPTIMIZE] - Melhorar performance de cálculos repetitivos
9. [REFACTOR] - Unificar formatação de datas e strings
10. [TODO] - Adicionar suporte a exportação de dados
11. [STYLE] - Padronizar tratamento de erros em toda aplicação
12. [TODO] - Implementar paginação e lazy loading

### 🟢 Complexidade BAIXA (6 issues)
13. [FIXME] - Remover TODOs pendentes no controller
14. [DOC] - Documentar services e utils adequadamente
15. [TEST] - Adicionar testes para cálculos e validações críticas
16. [STYLE] - Padronizar nomenclatura e estrutura de código
17. [OPTIMIZE] - Remover código duplicado entre utils
18. [TODO] - Melhorar feedback visual para estados de loading

---

## 🔴 Complexidade ALTA

### 1. [REFACTOR] - Consolidar lógica duplicada entre services e controller

**Status:** 🔴 Pendente | **Execução:** Complexa | **Risco:** Médio | **Benefício:** Alto

**Descrição:** Existe duplicação significativa de lógica entre AnimalCalculations, 
AnimalStatisticsService e métodos do controller. Cálculos de idade, peso e 
estatísticas estão espalhados em múltiplos arquivos causando inconsistências 
e dificultando manutenção.

**Prompt de Implementação:**

Refatore consolidando toda lógica de cálculos em AnimalCalculations. Remova 
métodos duplicados de AnimalStatisticsService que já existem em AnimalCalculations. 
No controller, substitua cálculos inline por chamadas ao service centralizado. 
Mantenha interfaces consistentes e documente dependências entre services.

**Dependências:** controllers/animal_page_controller.dart, 
services/animal_statistics_service.dart, utils/animal_calculations.dart

**Validação:** Funcionalidades de cálculo mantêm resultados consistentes 
com menos duplicação de código

### 2. [OPTIMIZE] - Implementar virtualização para grandes listas de animais

**Status:** 🔴 Pendente | **Execução:** Complexa | **Risco:** Médio | **Benefício:** Alto

**Descrição:** AnimalPageView renderiza todos os animais simultaneamente usando 
Column com map. Para coleções grandes (centenas de animais), isso causa 
problemas de performance e consumo de memória excessivo.

**Prompt de Implementação:**

Implemente ListView.builder ou similar para virtualização de lista. Adicione 
paginação no controller com parâmetros de página e tamanho. Implemente 
lazy loading que carrega mais dados conforme usuário rola a lista. Adicione 
indicadores de loading apropriados e mantenha posição de scroll.

**Dependências:** views/animal_page_view.dart, controllers/animal_page_controller.dart, 
services relacionados

**Validação:** Performance melhora significativamente com listas grandes 
e memória permanece controlada

### 3. [TODO] - Adicionar sistema de filtros avançados e pesquisa inteligente

**Status:** 🔴 Pendente | **Execução:** Complexa | **Risco:** Baixo | **Benefício:** Alto

**Descrição:** Sistema atual de filtros é limitado a tipos básicos. Falta 
filtros por idade, peso, datas, múltiplos critérios simultâneos. Pesquisa 
não tem sugestões automáticas nem busca fuzzy para correção de digitação.

**Prompt de Implementação:**

Expanda AnimalSearchService adicionando filtros por faixa de idade, peso, 
datas de cadastro. Implemente busca fuzzy com tolerância a erros de digitação. 
Adicione sistema de sugestões baseado em histórico. Crie UI para filtros 
avançados com chips removíveis. Implemente salvamento de filtros favoritos.

**Dependências:** services/animal_search_service.dart, views/animal_page_view.dart, 
controllers/animal_page_controller.dart, novo FilterWidget

**Validação:** Usuários conseguem filtrar e pesquisar animais com critérios 
complexos de forma intuitiva

### 4. [REFACTOR] - Separar responsabilidades do controller sobrecarregado

**Status:** 🔴 Pendente | **Execução:** Complexa | **Risco:** Alto | **Benefício:** Alto

**Descrição:** AnimalPageController possui mais de 480 linhas e múltiplas 
responsabilidades: gerenciamento de estado, operações CRUD, cálculos, 
formatação, navegação. Viola princípio de responsabilidade única.

**Prompt de Implementação:**

Divida controller em múltiplos serviços especializados: AnimalStateManager 
para gerenciamento de estado, AnimalBusinessService para regras de negócio, 
AnimalFormattingService para formatação. Controller deve apenas coordenar 
entre UI e services. Use injeção de dependência para facilitar testes.

**Dependências:** controllers/animal_page_controller.dart, novos services 
especializados, models/animal_page_state.dart

**Validação:** Controller reduzido para menos de 200 linhas mantendo 
funcionalidade completa

### 5. [SECURITY] - Implementar validação de autorização para operações críticas

**Status:** 🔴 Pendente | **Execução:** Complexa | **Risco:** Alto | **Benefício:** Alto

**Descrição:** Operação de exclusão de animais não tem validação de autorização 
adequada. SecurityService é chamado mas sem verificação real de permissões. 
Falta auditoria de operações críticas e validação de integridade de dados.

**Prompt de Implementação:**

Implemente sistema robusto de autorização verificando permissões antes de 
operações críticas. Adicione auditoria completa para CRUD operations. 
Implemente rate limiting para prevenir abuse. Adicione validação de 
integridade referencial antes de exclusões. Crie logs detalhados de segurança.

**Dependências:** controllers/animal_page_controller.dart, 
services/security_service.dart, novo AuditService

**Validação:** Operações críticas são executadas apenas por usuários 
autorizados com auditoria completa

---

## 🟡 Complexidade MÉDIA

### 6. [BUG] - Corrigir inconsistência no estado AnimalPageState não utilizado

**Status:** 🔴 Pendente | **Execução:** Moderada | **Risco:** Médio | **Benefício:** Alto

**Descrição:** AnimalPageState existe como model completo mas não é utilizado 
no controller. Controller usa Rx variables individuais ao invés do estado 
centralizado, causando complexidade desnecessária e possíveis inconsistências.

**Prompt de Implementação:**

Refatore controller para usar AnimalPageState como single source of truth. 
Substitua múltiplas Rx variables por um único Rx<AnimalPageState>. Atualize 
todos os getters para acessar estado através do model. Implemente transições 
de estado atômicas e consistentes.

**Dependências:** controllers/animal_page_controller.dart, 
models/animal_page_state.dart, views/animal_page_view.dart

**Validação:** Estado é gerenciado de forma consistente através do model 
unificado

### 7. [TODO] - Implementar cache e otimização de queries

**Status:** 🔴 Pendente | **Execução:** Moderada | **Risco:** Baixo | **Benefício:** Alto

**Descrição:** Dados são carregados do repository a cada operação sem cache. 
Filtros e pesquisas reprocessam lista completa sempre. Falta invalidação 
inteligente de cache e estratégias de otimização.

**Prompt de Implementação:**

Implemente camada de cache in-memory para animais e pesos. Adicione cache 
de resultados de filtros e pesquisas. Implemente invalidação seletiva quando 
dados são modificados. Adicione background refresh para manter dados atualizados. 
Use debouncing para queries frequentes.

**Dependências:** controllers/animal_page_controller.dart, novo CacheService, 
services existentes

**Validação:** Operações de listagem e filtros executam significativamente 
mais rápido

### 8. [OPTIMIZE] - Melhorar performance de cálculos repetitivos

**Status:** 🔴 Pendente | **Execução:** Moderada | **Risco:** Baixo | **Benefício:** Médio

**Descrição:** Cálculos de idade, estatísticas e formatações são executados 
repetidamente sem cache. Métodos como getAnimalAge são chamados múltiplas 
vezes para o mesmo animal causando overhead desnecessário.

**Prompt de Implementação:**

Implemente memoização para cálculos caros. Cache resultados de getAnimalAge, 
estatísticas e formatações por ID do animal. Adicione invalidação quando 
dados relevantes são atualizados. Use lazy evaluation para cálculos que 
podem não ser necessários.

**Dependências:** utils/animal_calculations.dart, 
services/animal_statistics_service.dart, novo MemoizationService

**Validação:** Cálculos repetitivos executam apenas uma vez e são cachados 
adequadamente

### 9. [REFACTOR] - Unificar formatação de datas e strings

**Status:** 🔴 Pendente | **Execução:** Moderada | **Risco:** Baixo | **Benefício:** Médio

**Descrição:** Formatação de datas e strings está espalhada entre controller, 
utils e services. Diferentes formatos são usados inconsistentemente causando 
confusão na interface do usuário.

**Prompt de Implementação:**

Centralize toda formatação em AnimalFormatters. Padronize formatos de data, 
peso, idade e outros valores. Adicione localização adequada para diferentes 
regiões. Substitua formatação inline por chamadas ao service centralizado. 
Adicione validação de formatos.

**Dependências:** utils/animal_formatters.dart, 
controllers/animal_page_controller.dart, views relacionadas

**Validação:** Formatação é consistente em toda aplicação usando padrões 
centralizados

### 10. [TODO] - Adicionar suporte a exportação de dados

**Status:** 🔴 Pendente | **Execução:** Moderada | **Risco:** Baixo | **Benefício:** Médio

**Descrição:** Não existe funcionalidade para exportar dados dos animais 
para CSV, PDF ou outros formatos. Usuários não conseguem fazer backup ou 
compartilhar informações facilmente.

**Prompt de Implementação:**

Implemente ExportService suportando CSV, PDF e JSON. Adicione opções de 
exportação de animais individuais ou coleção completa. Inclua filtros 
personalizáveis para dados a exportar. Adicione compartilhamento direto 
via email ou cloud storage. Implemente progress indicator para exports grandes.

**Dependências:** novo ExportService, controllers/animal_page_controller.dart, 
views/animal_page_view.dart

**Validação:** Usuários conseguem exportar dados em múltiplos formatos 
com sucesso

### 11. [STYLE] - Padronizar tratamento de erros em toda aplicação

**Status:** 🔴 Pendente | **Execução:** Moderada | **Risco:** Baixo | **Benefício:** Médio

**Descrição:** Tratamento de erros é inconsistente entre services. Alguns 
usam throw, outros retornam false, outros usam ErrorHandler. Falta 
padronização de mensagens de erro e códigos.

**Prompt de Implementação:**

Padronize tratamento de erros usando ErrorHandler consistentemente. Defina 
hierarquia clara de exceptions específicas do domínio. Centralize mensagens 
de erro com localização. Implemente recovery strategies uniformes. Adicione 
logging estruturado de erros.

**Dependências:** Todos os services, controllers/animal_page_controller.dart, 
utils/error_handler.dart

**Validação:** Erros são tratados consistentemente com mensagens claras 
para usuário

### 12. [TODO] - Implementar paginação e lazy loading

**Status:** 🔴 Pendente | **Execução:** Moderada | **Risco:** Médio | **Benefício:** Alto

**Descrição:** Sistema carrega todos os animais simultaneamente. Para usuários 
com muitos animais, isso impacta performance significativamente. Falta 
paginação no backend e frontend.

**Prompt de Implementação:**

Implemente paginação no repository level com parâmetros de offset/limit. 
Adicione lazy loading na UI que carrega próxima página automaticamente 
ao aproximar do fim. Mantenha posição de scroll e estado de filtros durante 
paginação. Adicione indicadores visuais apropriados.

**Dependências:** repository layer, controllers/animal_page_controller.dart, 
views/animal_page_view.dart

**Validação:** Grandes coleções são carregadas eficientemente sem impacto 
na performance

---

## 🟢 Complexidade BAIXA

### 13. [FIXME] - Remover TODOs pendentes no controller

**Status:** 🔴 Pendente | **Execução:** Simples | **Risco:** Baixo | **Benefício:** Baixo

**Descrição:** Existem TODOs nas linhas 125-127 e 131-132 referenciando 
implementação de lógica de animal selecionado no sync controller que 
precisam ser resolvidos ou removidos.

**Prompt de Implementação:**

Implemente lógica de persistência de animal selecionado usando SharedPreferences 
ou similar. Adicione métodos getSelectedAnimalId e setSelectedAnimalId no 
sync controller. Remova comentários TODO após implementação completa.

**Dependências:** controllers/animal_page_controller.dart, 
controllers/sync/sync_controllers.dart

**Validação:** Animal selecionado é persistido entre sessões e TODOs 
foram removidos

### 14. [DOC] - Documentar services e utils adequadamente

**Status:** 🔴 Pendente | **Execução:** Simples | **Risco:** Baixo | **Benefício:** Médio

**Descrição:** Services e utils carecem de documentação adequada. Métodos 
públicos não têm dart doc comments explicando parâmetros, retornos e 
comportamento esperado.

**Prompt de Implementação:**

Adicione documentação dart doc completa para todos os métodos públicos 
em AnimalSearchService, AnimalStatisticsService e AnimalCalculations. 
Inclua exemplos de uso, parâmetros esperados, valores de retorno e 
exceptions possíveis. Gere documentação HTML para verificação.

**Dependências:** services/animal_search_service.dart, 
services/animal_statistics_service.dart, utils/animal_calculations.dart

**Validação:** Documentação é gerada corretamente cobrindo todos os 
métodos públicos

### 15. [TEST] - Adicionar testes para cálculos e validações críticas

**Status:** 🔴 Pendente | **Execução:** Simples | **Risco:** Baixo | **Benefício:** Alto

**Descrição:** AnimalCalculations e AnimalStatisticsService contêm lógica 
crítica de cálculos veterinários sem cobertura de testes. Cálculos de 
idade, peso ideal e estatísticas precisam de validação.

**Prompt de Implementação:**

Crie testes unitários abrangentes para todos os métodos de cálculo. 
Teste casos extremos como animais muito jovens, muito velhos, pesos 
anômalos. Valide cálculos de idade em anos, meses e dias. Teste 
estatísticas com datasets variados.

**Dependências:** utils/animal_calculations.dart, 
services/animal_statistics_service.dart, novos arquivos de teste

**Validação:** Cobertura de testes atinge pelo menos 95% nos services 
críticos

### 16. [STYLE] - Padronizar nomenclatura e estrutura de código

**Status:** 🔴 Pendente | **Execução:** Simples | **Risco:** Baixo | **Benefício:** Médio

**Descrição:** Mistura de nomenclatura em português e inglês. Estrutura 
de métodos e organização de código varia entre services. Falta consistência 
nos padrões de codificação.

**Prompt de Implementação:**

Padronize nomenclatura seguindo convenções Dart. Organize métodos por 
funcionalidade relacionada. Padronize estrutura de classes com ordem 
consistente: construtores, getters, métodos públicos, métodos privados. 
Aplique formatting automático.

**Dependências:** Todos os arquivos do módulo animal_page

**Validação:** Código segue padrões consistentes de nomenclatura e 
estrutura

### 17. [OPTIMIZE] - Remover código duplicado entre utils

**Status:** 🔴 Pendente | **Execução:** Simples | **Risco:** Baixo | **Benefício:** Médio

**Descrição:** AnimalCalculations e AnimalStatisticsService têm métodos 
duplicados para cálculo de idade. Formatters podem ter sobreposição com 
lógica do controller.

**Prompt de Implementação:**

Identifique e consolide métodos duplicados. Mova funcionalidade comum 
para classes base ou utils compartilhados. Elimine redundâncias mantendo 
funcionalidade. Atualize imports e referências conforme necessário.

**Dependências:** utils/animal_calculations.dart, 
services/animal_statistics_service.dart, utils/animal_formatters.dart

**Validação:** Não existe código duplicado e funcionalidade é preservada

### 18. [TODO] - Melhorar feedback visual para estados de loading

**Status:** 🔴 Pendente | **Execução:** Simples | **Risco:** Baixo | **Benefício:** Médio

**Descrição:** Interface mostra apenas CircularProgressIndicator básico 
durante loading. Falta feedback específico para diferentes operações e 
estados mais informativos para usuário.

**Prompt de Implementação:**

Adicione indicadores específicos para diferentes operações: loading animais, 
loading pesos, deletando animal. Implemente skeleton loading para melhor 
experiência. Adicione mensagens contextuais e progress indicators onde 
apropriado. Use shimmer effects para carregamento.

**Dependências:** views/animal_page_view.dart, 
controllers/animal_page_controller.dart

**Validação:** Estados de loading são visualmente claros e informativos 
para cada operação

---

## 🔧 Comandos Rápidos

Para solicitar implementação específica, use:
- `Executar #[número]` - Para que a IA implemente uma issue específica
- `Detalhar #[número]` - Para obter prompt mais detalhado sobre implementação
- `Focar [complexidade]` - Para trabalhar apenas com issues de uma complexidade
- `Agrupar [tipo]` - Para executar todas as issues de um tipo
- `Validar #[número]` - Para que a IA revise implementação concluída