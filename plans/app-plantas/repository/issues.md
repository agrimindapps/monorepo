# Issues e Melhorias - Repository Layer

## 📋 Índice Geral

### 🔴 Complexidade CRÍTICA (0 issues pendentes / 8 concluídas)
### 🟡 Complexidade ALTA (4 issues pendentes / 8 concluídas)
### 🟠 Complexidade MÉDIA (10 issues pendentes / 6 concluídas)
### 🟢 Complexidade BAIXA (0 issues pendentes / 11 concluídas)

**Total: 47 issues identificadas | 32 concluídas**

---

## 🔴 Complexidade CRÍTICA

### 1. [ARCHITECTURE] - Padrão Singleton Inconsistente Entre Repositories

**Status:** 🟢 Concluído | **Execução:** Muito Complexa | **Risco:** Alto | **Benefício:** Alto
**Implementado em:** 07/08/2025 | **Arquivos modificados:** planta_config_repository.dart, tarefa_repository.dart, múltiplos services e controllers
**Observações:** Todos repositories agora seguem padrão singleton consistente, mantendo funcionalidade existente

**Descrição:** EspacoRepository e PlantaRepository usam singleton, mas PlantaConfigRepository 
e TarefaRepository não. Isso cria inconsistência arquitetural, problemas de estado 
compartilhado e dificuldade na testabilidade.

**Implementação Realizada:**

✅ **PlantaConfigRepository padronizado:**
   - Adicionado `static PlantaConfigRepository get instance`
   - Construtor tornado privado `PlantaConfigRepository._()`
   - Implementada inicialização única com flag `_isInitialized`
   - Registros de adapter mantidos para compatibilidade

✅ **TarefaRepository padronizado:**  
   - Adicionado `static TarefaRepository get instance`
   - Construtor tornado privado `TarefaRepository._()`
   - Implementada inicialização única com flag `_isInitialized`
   - Registros de adapter mantidos para compatibilidade

✅ **Atualizações de compatibilidade:**
   - PlantaRepository: Todas 11 instanciações atualizadas para `PlantaConfigRepository.instance`
   - Services: TaskOperationsService, SimpleTaskService, PlantManagementFacade atualizados
   - Controllers: PlantaDetalhesController atualizado
   - Services diversos: TarefasManagementService, PlantaCadastroService, etc. atualizados

✅ **Padrão consistente aplicado:**
   - Todos 4 repositories agora seguem mesmo pattern: `Repository.instance`
   - Construtores privados com `_()` para singleton enforcement
   - Inicialização única com lazy initialization thread-safe
   - Flag `_isInitialized` para evitar reinicializações

✅ **Validação de compatibilidade:**
   - Nenhuma instanciação direta restante (verificado via grep)
   - Análise estática sem erros críticos
   - Funcionalidade preservada com repositórios singleton

**Dependências resolvidas:** Todos controllers e services agora usam pattern singleton consistente

**Validação:** ✅ Todos repositories seguem mesmo pattern singleton, sem vazamentos de memória e com inicialização única thread-safe

---

### 2. [BUG] - Lógica de Cuidados de Plantas Quebrada

**Status:** 🟢 Concluído | **Execução:** Muito Complexa | **Risco:** Alto | **Benefício:** Alto
**Implementado em:** 06/08/2025 | **Arquivos modificados:** planta_repository.dart
**Observações:** Lógica completa implementada com integração real entre PlantaConfigRepository e SimpleTaskService

**Descrição:** PlantaRepository tem métodos placeholder que sempre retornam false 
(_precisaAgua, _precisaAdubo, etc.). Isso quebra completamente a funcionalidade 
principal do app - detectar quando plantas precisam de cuidados.

**Implementação Realizada:**

✅ **Integração completa com PlantaConfigRepository:**
   - `_precisaCuidado()` verifica se tipo de cuidado está ativo na configuração
   - `toggleAgua()` e `toggleAdubo()` implementados via PlantaConfigRepository
   - Configurações dinâmicas por planta respeitadas

✅ **Integração completa com SimpleTaskService:**  
   - `findPrecisaCuidadosHoje()` otimizado para usar tarefas pendentes diretamente
   - `findComTarefasAtrasadas()` implementado com consulta eficiente
   - Lógica baseada em tarefas reais, não em datas calculadas

✅ **Streams funcionais reativados:**
   - `watchComAguaAtiva()` implementado com consulta async por configuração
   - `watchPrecisaAguaHoje()` implementado usando `todayTasksStream`
   - Streams reativas para atualização em tempo real

✅ **Métodos de conclusão de tarefas:**
   - `completarRega()` e `completarAdubacao()` implementados
   - Integração com intervalos de configuração automática
   - Agendamento automático da próxima tarefa

✅ **Otimizações de performance:**
   - Uso de Sets para IDs únicos (O(1) lookup)
   - Consultas em lote para evitar N+1 queries  
   - Cache inteligente de configurações

**Dependências resolvidas:** PlantaConfigRepository, SimpleTaskService, TarefaModel

**Validação:** ✅ Aplicação agora detecta corretamente plantas que precisam de cuidados baseado em configurações reais e tarefas pendentes

---

### 3. [SECURITY] - Falta de Validação em Operações Críticas

**Status:** 🟢 Concluído | **Execução:** Complexa | **Risco:** Alto | **Benefício:** Alto
**Implementado em:** 07/08/2025 | **Arquivos modificados:** 8 arquivos (4 repositories + 4 validadores)
**Observações:** Sistema completo de validação implementado com Result pattern, factory methods e validação robusta em todos repositories

**Descrição:** Nenhum repository valida dados antes de operações create/update. 
Possível corrupção de dados, inserção de valores inválidos e problemas de 
sincronização com Firebase.

**Implementação Realizada:**

✅ **Sistema Result<T> Pattern implementado:**
   - Classe `Result<T>` com Success/Error variants
   - Error handling explícito sem exceptions
   - 10+ tipos de ValidationError específicos (RequiredField, InvalidFormat, OutOfRange, etc.)
   - Utilities para combinar e processar múltiplos resultados
   - Extensions para uso conveniente (ifSuccess, ifError, orElse, etc.)

✅ **Validadores específicos por repository:**
   - **EspacoValidator**: Validação de nome único, descrição, status ativo, datas
   - **PlantaValidator**: Validação de nome, espécie, espacoId válido, imagens, dados
   - **PlantaConfigValidator**: Validação de tipos de cuidado, intervalos, consistência
   - **TarefaValidator**: Validação de plantaId, tipoCuidado, datas, status, consistência

✅ **Factory methods para criação segura:**
   - **EspacoModelFactory**: create(), update(), duplicate() com validação
   - **PlantaModelFactory**: create(), update(), moveToEspaco(), addImage(), removeImage()
   - **PlantaConfigModelFactory**: createDefault(), create(), update() com configurações sensatas
   - **TarefaModelFactory**: create(), createForToday(), complete(), reschedule(), createNext()

✅ **Validações robustas implementadas:**

   **EspacoRepository:**
   - Nome obrigatório (1-100 chars), único, sem caracteres perigosos
   - Status ativo/inativo validado
   - Datas consistentes (não futuras, não muito antigas)
   - Descrição opcional até 500 chars

   **PlantaRepository:**
   - Nome obrigatório (1-100 chars)
   - EspacoId obrigatório e válido (espaço deve existir e estar ativo)
   - Espécie opcional até 100 chars
   - Máximo 10 imagens, paths válidos
   - FotoBase64 até 5MB, formato válido
   - Data cadastro não futura

   **PlantaConfigRepository:**
   - PlantaId obrigatório e válido (planta deve existir)
   - Intervalos entre 1-365 dias para cuidados ativos
   - Pelo menos um tipo de cuidado deve estar ativo
   - Consistência entre status ativo e intervalos configurados
   - Tipos de cuidado válidos: agua, adubo, banho_sol, inspecao_pragas, poda, replantar

   **TarefaRepository:**
   - PlantaId obrigatório e válido (planta deve existir)
   - TipoCuidado deve ser válido
   - DataExecucao não pode ser muito antiga/futura
   - DataConclusao obrigatória se tarefa concluída
   - DataConclusao >= dataExecucao
   - Observações até 1000 chars

✅ **Integration nos repositories:**
   - Todos métodos create/update validam dados antes de persistir
   - Validação de referências (espacoId, plantaId) com verificação de existência
   - Métodos legacy mantidos para compatibilidade
   - Error handling consistente com mensagens específicas
   - Prevenção de XSS com validação de caracteres perigosos

✅ **Arquivos criados:**
- `lib/app-plantas/repository/validation/result.dart`
- `lib/app-plantas/repository/validation/espaco_validator.dart`
- `lib/app-plantas/repository/validation/planta_validator.dart`
- `lib/app-plantas/repository/validation/planta_config_validator.dart`
- `lib/app-plantas/repository/validation/tarefa_validator.dart`

✅ **Arquivos modificados:**
- `lib/app-plantas/repository/espaco_repository.dart`
- `lib/app-plantas/repository/planta_repository.dart`
- `lib/app-plantas/repository/planta_config_repository.dart`
- `lib/app-plantas/repository/tarefa_repository.dart`

**Dependências resolvidas:** Result pattern, factory methods, cross-repository validation

**Validação:** ✅ Dados inválidos retornam erros específicos sem corromper banco. Referências são validadas. Prevenção de XSS implementada.

---

### 4. [PERFORMANCE] - N+1 Queries em Relacionamentos

**Status:** 🟢 Concluído | **Execução:** Complexa | **Risco:** Médio | **Benefício:** Alto
**Implementado em:** 07/08/2025 | **Arquivos modificados:** cache_manager.dart, query_optimizer.dart, planta_repository.dart, tarefa_repository.dart, simple_task_service.dart
**Observações:** Sistema completo de cache inteligente e otimização de queries implementado, reduzindo dramaticamente consultas N+1

**Descrição:** PlantaRepository.findPrecisaCuidadosHoje() executa findAll() para cada 
verificação de cuidado. TarefaRepository tem múltiplos métodos que fazem findAll() 
independentemente. Causa degradação de performance exponencial.

**Implementação Realizada:**

✅ **Sistema de Cache Inteligente Implementado:**
   - **CacheManager**: Cache completo com TTL configurável, invalidação automática
   - **CacheableRepository mixin**: Funcionalidades de cache transparentes para repositories
   - Cache baseado em timestamp com invalidação por patterns
   - Debouncing para evitar múltiplas execuções simultâneas
   - Cache para queries com filtros complexos
   - Operações batch otimizadas com lookup O(1)
   - Estatísticas e monitoramento de cache

✅ **QueryOptimizer para Resolver N+1:**
   - **findPlantasPrecisaCuidadosHoje()**: Reduzido de N+1 queries para apenas 2 queries
   - **findTarefasByDateCriteria()**: Uma única passada para todos critérios de data
   - **calcularEstatisticas()**: Estatísticas calculadas em uma única operação
   - Cache específico com TTL otimizado por tipo de operação
   - Processamento em memória eficiente com Set lookups O(1)
   - Invalidação automática baseada em streams

✅ **PlantaRepository Otimizado:**
   - `findPrecisaCuidadosHoje()`: Usa QueryOptimizer (2 queries vs N+1)
   - `findComTarefasAtrasadas()`: Mesmo resultado otimizado reutilizado
   - `getEstatisticas()`: Delegado para QueryOptimizer otimizado
   - `countByEspaco()`: Cache inteligente com invalidação automática
   - `findAll()`, `findById()`: Cache transparente com TTL configurável
   - `findByIds()`: Operação batch com cache inteligente
   - `findByEspaco()`, `findByNome()`: Cache por filtros
   - Invalidação automática em operações CRUD

✅ **TarefaRepository Otimizado:**
   - Todos métodos de filtro por data usam QueryOptimizer (1 query vs N)
   - `findParaHoje()`, `findFuturas()`, `findAtrasadas()`: Processamento único
   - `findPendentes()`, `findConcluidas()`: Same query, diferentes filtros
   - `findByPlanta()`: Cache específico por planta com TTL otimizado
   - `findByTipoCuidado()`: Cache por critério com invalidação inteligente
   - `getEstatisticas()`: Delegado para QueryOptimizer
   - Operações CRUD com invalidação automática de cache

✅ **Operações Batch Implementadas:**
   - **BatchOperationHelper**: Processamento em chunks configuráveis
   - `createBatch()`: Otimizado com delay entre chunks
   - `findByIds()`: Batch cache lookup com fallback inteligente
   - `removerPorPlanta()`: Remoção em lotes com invalidação
   - Combinação de listas sem duplicatas
   - Controle de delay para não sobrecarregar sistema

✅ **Cache com Invalidação Automática:**
   - Invalidação por patterns: `planta:*`, `tarefa:*`
   - Invalidação por tipo de operação: create, update, delete
   - Setup automático baseado em dataStreams
   - TTL configurável por tipo de query
   - Limpeza automática de cache expirado
   - Estatísticas de hit ratio e memory usage

✅ **Integração Completa:**
   - SimpleTaskService: Método `findAll()` delegado para repository otimizado
   - Todos repositories implementam `CacheableRepository` mixin
   - QueryOptimizer gerencia invalidação cross-repository
   - Cache transparente mantém APIs existentes
   - Configuração automática de invalidação via streams

**Performance Melhorias Alcançadas:**
- **PlantaRepository.findPrecisaCuidadosHoje()**: De N+1 queries → 2 queries
- **TarefaRepository métodos de data**: De N queries → 1 query
- **Estatísticas**: De múltiplas queries → 1 query única
- **Operações batch**: Chunks otimizados com delay configurável
- **Cache hit ratio**: TTL otimizado por tipo de operação

**Dependências resolvidas:** Cache layer, Batch operations, Stream-based invalidation

**Validação:** ✅ Queries N+1 eliminadas. Cache inteligente reduz chamadas ao Hive/Firebase. Performance otimizada para diferentes volumes de dados. Monitoramento implementado via CacheStats.

---

### 5. [REFACTOR] - Duplicação de Lógica de Data/Filtros

**Status:** 🟢 Concluído | **Execução:** Complexa | **Risco:** Médio | **Benefício:** Alto
**Implementado em:** 07/08/2025 | **Arquivos modificados:** tarefa_repository.dart + 2 novos arquivos de filtering
**Observações:** Sistema completo de filtros centralizados implementado com Strategy pattern, eliminando duplicação em 6 locais diferentes

**Descrição:** TarefaRepository tem lógica duplicada para filtrar por data (hoje, 
futuras, atrasadas) em streams e métodos async. Mesma lógica repetida em 6 locais 
diferentes aumenta risco de bugs e inconsistências.

**Implementação Realizada:**

✅ **TarefaFilterCriteria interface com Strategy pattern:**
   - Interface `TarefaFilterCriteria` para diferentes tipos de filtro
   - Implementações específicas: `TodayTasksCriteria`, `FutureTasksCriteria`, `OverdueTasksCriteria`
   - Critérios para tarefas pendentes, concluídas, por planta, por tipo de cuidado, por período
   - `CompositeCriteria` para combinar múltiplos filtros com AND/OR
   - Factory `TarefaFilterCriteriaFactory` com critérios singleton para performance

✅ **TarefaFilterService centralizado:**
   - Service singleton com método genérico `filterTasks()` usando Strategy pattern
   - Streams otimizados com debouncing e cache inteligente
   - Factory methods para filtros comuns: `findParaHoje()`, `findFuturas()`, `findAtrasadas()`
   - Métodos combinados frequentes: `findUrgentes()`, `findUrgentesForPlanta()`
   - Cache inteligente com invalidação automática e TTL configurável

✅ **TarefaQueryBuilder para consultas complexas:**
   - Builder pattern fluente: `query().paraHoje().forPlanta('123').findAll()`
   - Métodos encadeáveis: `paraHoje()`, `futuras()`, `atrasadas()`, `pendentes()`, `concluidas()`
   - Filtros por critério: `forPlanta()`, `forCareType()`, `forPeriod()`
   - Execução flexível: `findAll()`, `findAny()`, `findFirst()`, `count()`, `exists()`
   - Suporte a critérios customizados via `where()`

✅ **TarefaRepository refatorado:**
   - **Streams otimizados**: `watchParaHoje()`, `watchFuturas()`, `watchAtrasadas()` usam FilterService
   - **Métodos async otimizados**: `findParaHoje()`, `findFuturas()`, `findAtrasadas()` usam FilterService
   - Eliminação completa da duplicação de lógica nos 6 locais identificados
   - Novos métodos convenientes: `query()`, `findUrgentes()`, `processDateCriteria()`
   - Cache inteligente mantido + cache do FilterService para performance máxima

✅ **Sistema de cache otimizado:**
   - `TarefaDateCriteriaResult` para processamento batch otimizado (uma única passada)
   - Cache keys inteligentes baseados em critérios para evitar colisões
   - Integração com `OptimizedFiltering` mixin existente
   - Debouncing em streams para reduzir processamento desnecessário
   - Estatísticas de cache via `getCacheStats()` para monitoramento

✅ **Compatibilidade mantida:**
   - APIs públicas do TarefaRepository preservadas integralmente
   - Funcionalidade end-to-end mantida
   - Performance melhorada com cache centralizado
   - Comentários indicando uso avançado via TarefaFilterService.instance

✅ **Arquivos criados:**
- `lib/app-plantas/repository/filtering/tarefa_filter_criteria.dart`
- `lib/app-plantas/repository/filtering/tarefa_filter_service.dart`

✅ **Arquivos modificados:**
- `lib/app-plantas/repository/tarefa_repository.dart`

**Benefícios Alcançados:**
- **Eliminação de duplicação**: 6 locais com lógica duplicada reduzidos a implementações centralizadas
- **Consistência**: Lógica de filtros unificada entre streams e métodos async
- **Extensibilidade**: Novos critérios podem ser adicionados implementando interface
- **Performance**: Cache inteligente e processamento batch otimizado
- **Flexibilidade**: Builder pattern permite consultas complexas fluentes
- **Manutenibilidade**: Mudanças em critérios centralizadas em um local

**Dependências resolvidas:** Strategy pattern, Builder pattern, Cache centralizado, Factory methods

**Validação:** ✅ Duplicação eliminada mantendo API pública inalterada. Lógica de filtros consistente entre streams e métodos async. Funcionalidade end-to-end preservada. Facilita adição de novos tipos de filtro via Strategy pattern.

---

### 6. [ARCHITECTURE] - Acoplamento Forte com SimpleTaskService

**Status:** 🟢 Concluído | **Execução:** Complexa | **Risco:** Alto | **Benefício:** Alto
**Implementado em:** 07/08/2025 | **Arquivos modificados:** 5 arquivos criados + planta_repository.dart + simple_task_service.dart
**Observações:** Sistema completo de dependency injection implementado, eliminando acoplamento forte e habilitando testes isolados

**Descrição:** PlantaRepository importava e usava diretamente SimpleTaskService, violando 
princípio de inversão de dependência. Repository deveria depender de abstrações, 
não implementações concretas.

**Implementação Realizada:**

✅ **Interface ITaskService criada:**
   - Abstração completa para operações de tarefas
   - Todos métodos do SimpleTaskService abstraídos
   - Contratos claros para `findAll()`, `getTodayTasks()`, `completeTask()`, etc.
   - Streams abstraídos: `todayTasksStream`, `pendingTasksStream`, etc.
   - Permite implementações diferentes (produção, testes, mocks)

✅ **ServiceLocator implementado:**
   - Registry com lazy initialization
   - Suporte a singletons com thread-safety
   - `register<T>()`, `registerInstance<T>()`, `get<T>()` methods
   - Configuração separada para produção e testes
   - Cleanup automático com `disposeServices()`
   - Debug info com `getDebugInfo()`

✅ **SimpleTaskService refatorado:**
   - Implementa `ITaskService` interface
   - Todos métodos com `@override` annotation
   - Funcionalidade preservada integralmente
   - Compatibilidade mantida com código existente

✅ **PlantaRepository desacoplado:**
   - Removido import direto de `SimpleTaskService`
   - Adicionado import de `ITaskService` e `ServiceLocator`
   - Implementado getter `_getTaskService` com lazy loading
   - Todas chamadas `SimpleTaskService.instance.findAll()` → `_getTaskService.findAll()`
   - Factory method `createWithTaskService()` para testes

✅ **ServiceInitializer criado:**
   - `initializeProductionServices()` para setup padrão
   - `initializeTestServices()` para mocks
   - `validateServices()` para verificação de dependências
   - `getServicesStatus()` para debug information
   - Cleanup e reinicialização para hot reload

✅ **Documentação completa:**
   - README_DEPENDENCY_INJECTION.md com guia completo
   - Exemplos de uso em produção e testes
   - API reference para ServiceLocator e ServiceInitializer
   - Guia de migração de código legado

**Arquivos criados:**
- `lib/app-plantas/services/interfaces/i_task_service.dart`
- `lib/app-plantas/services/service_locator.dart`
- `lib/app-plantas/services/service_initializer.dart`
- `lib/app-plantas/services/README_DEPENDENCY_INJECTION.md`

**Arquivos modificados:**
- `lib/app-plantas/services/simple_task_service.dart`
- `lib/app-plantas/repository/planta_repository.dart`

**Dependências resolvidas:** Interface segregation, DI Container, factory methods para testes

**Validação:** ✅ PlantaRepository agora funciona com mocks para testes isolados. Eliminado import direto de SimpleTaskService. Sistema de dependency injection completo permite diferentes implementações via configuration.

---

### 7. [BUG] - Race Conditions em Inicialização

**Status:** 🟢 Concluído | **Execução:** Complexa | **Risco:** Alto | **Benefício:** Médio
**Implementado em:** 07/08/2025 | **Arquivos modificados:** initialization_manager.dart, 4 repositories
**Observações:** Sistema completo de inicialização thread-safe implementado com controle global de estado

**Descrição:** Múltiplos repositories com inicialização async podem causar race 
conditions. PlantaConfigRepository.findByPlantaId chama initialize() a cada busca, 
potencialmente causando múltiplas inicializações simultâneas.

**Implementação Realizada:**

✅ **InitializationManager centralizado criado:**
   - Singleton pattern para controle global de estado
   - Estados bem definidos: notStarted, initializing, completed, failed, timeout
   - Thread-safe com Completer pattern para cada repository
   - Sistema de resultado detalhado (InitializationResult)

✅ **Completer pattern para garantir inicialização única:**
   - Um Completer<InitializationResult> por repository
   - Primeira chamada inicia, outras aguardam completion
   - Thread-safe com verificação de status antes de inicializar
   - Aguardar async para repositories já sendo inicializados

✅ **Dependency graph para ordem correta:**
   - CommonRepositoryConfigs com dependências definidas:
     - EspacoRepository: sem dependências (primeiro)
     - PlantaRepository: depende de EspacoRepository
     - PlantaConfigRepository: depende de PlantaRepository
     - TarefaRepository: depende de PlantaRepository
   - Topological sort para calcular ordem de inicialização
   - Detecção de dependências circulares
   - Cache da ordem de inicialização para performance

✅ **Timeout e retry logic implementado:**
   - Timeout configurável por repository (10-15 segundos)
   - Retry com exponential backoff (até 3 tentativas)
   - Diferentes delays: 500ms, 1s, 1.5s
   - TimeoutException diferenciada de outros erros
   - Fallback para inicialização direta em caso de falha do manager

✅ **Correção do problema crítico no PlantaConfigRepository:**
   - `findByPlantaId()` CORRIGIDO: não chama mais initialize() a cada busca
   - Verificação de `_isInitialized` antes de chamar initialize()
   - `findActiveConfigs()` e `findByActiveCareType()` também corrigidos
   - Eliminação de inicializações repetitivas desnecessárias

✅ **Integração completa nos 4 repositories:**
   - Todos repositories registram configuração no InitializationManager
   - Padrão consistente: `_registerWithInitializationManager()`
   - Fallback seguro para inicialização direta
   - Preserve funcionalidade existente
   - Error handling robusto

✅ **Funcionalidades avançadas:**
   - `initializeAll()` para inicializar múltiplos repositories
   - `reinitialize()` para forçar nova inicialização
   - `waitForInitialization()` para aguardar repositories em progresso
   - `getStatistics()` para monitoramento e debug
   - Status checking: `isInitialized()`, `isInitializing()`, `hasFailed()`

**Arquivos criados:**
- `lib/app-plantas/repository/initialization_manager.dart`

**Arquivos modificados:**
- `lib/app-plantas/repository/espaco_repository.dart`
- `lib/app-plantas/repository/planta_repository.dart` 
- `lib/app-plantas/repository/planta_config_repository.dart`
- `lib/app-plantas/repository/tarefa_repository.dart`

**Dependências resolvidas:** Initialization manager, State management, Completer pattern, Dependency graph

**Validação:** ✅ Race conditions eliminadas. Inicialização thread-safe e única por repository. Dependency graph respeitado. Timeout e retry funcionais. PlantaConfigRepository.findByPlantaId() não faz mais múltiplas inicializações.

---

### 8. [FIXME] - Métodos TODO Comentados Quebram Funcionalidade

**Status:** 🟢 Concluído | **Execução:** Complexa | **Risco:** Alto | **Benefício:** Alto
**Implementado em:** 06/08/2025 | **Arquivos modificados:** planta_repository.dart
**Observações:** Todos os métodos TODO críticos implementados com integração completa aos services

**Descrição:** PlantaRepository tem 15+ métodos TODO comentados incluindo 
updateUltimaRega, toggleAgua, watchComAguaAtiva. Funcionalidades essenciais 
do app estão desabilitadas.

**Implementação Realizada:**

✅ **Métodos de conclusão de tarefas implementados:**
   - `completarBanhoSol()` - completar tarefa de banho de sol via SimpleTaskService
   - `completarInspecaoPragas()` - completar tarefa de inspeção de pragas
   - `completarPoda()` - completar tarefa de poda
   - `completarReplantio()` - completar tarefa de replantio
   - Integração completa com intervalos de configuração e agendamento automático

✅ **Métodos de toggle para todos os tipos de cuidado:**
   - `toggleBanhoSol()` - ativar/desativar banho de sol via PlantaConfigRepository
   - `toggleInspecaoPragas()` - ativar/desativar inspeção de pragas
   - `togglePoda()` - ativar/desativar poda
   - `toggleReplantio()` - ativar/desativar replantio
   - Integração com PlantaConfigRepository para gerenciamento de configurações

✅ **Streams reativas para todos os tipos de cuidado:**
   - `watchPrecisaBanhoSolHoje()` - plantas que precisam banho de sol hoje
   - `watchPrecisaInspecaoPragasHoje()` - plantas que precisam inspeção hoje
   - `watchPrecisaPodaHoje()` - plantas que precisam poda hoje
   - `watchPrecisaReplantioHoje()` - plantas que precisam replantio hoje
   - `watchComBanhoSolAtivo()` - plantas com banho de sol ativo
   - `watchComInspecaoPragasAtiva()` - plantas com inspeção ativa
   - `watchComPodaAtiva()` - plantas com poda ativa
   - `watchComReplantioAtivo()` - plantas com replantio ativo

✅ **Método de estatísticas implementado:**
   - `countByEspaco()` - contar plantas por espaço de forma otimizada

✅ **Otimizações implementadas:**
   - Uso de Sets para lookup O(1) em operações com IDs
   - Stream lifecycle management para evitar memory leaks
   - Integração eficiente com SimpleTaskService e PlantaConfigRepository
   - Cache inteligente para operações frequentes

**Dependências resolvidas:** PlantaConfigRepository, SimpleTaskService, stream management

**Validação:** ✅ Todas as funcionalidades de cuidados implementadas end-to-end com streams reativas e integração completa aos services

---

## 🟡 Complexidade ALTA

### 9. [REFACTOR] - Repository God Classes

**Status:** 🟢 Concluído | **Execução:** Complexa | **Risco:** Médio | **Benefício:** Alto
**Implementado em:** 07/08/2025 | **Arquivos modificados:** espaco_repository.dart, planta_repository.dart, tarefa_repository.dart + 7 novos services
**Observações:** Repositories refatorados seguindo Single Responsibility Principle, funcionalidades extraídas para services especializados

**Descrição:** EspacoRepository (252 linhas), PlantaRepository (300 linhas) e 
TarefaRepository (305 linhas) violam Single Responsibility Principle. Muitas 
responsabilidades em uma classe dificulta manutenção.

**Implementação Realizada:**

✅ **EspacoRepository refatorado (reduzido para ~180 linhas):**
   - CRUD básico mantido
   - Funcionalidades extraídas para:
     - **EspacoQueryService**: consultas complexas, paginação, filtros avançados
     - **EspacoStatisticsService**: estatísticas, relatórios e métricas
     - **EspacoCopyService**: duplicação com estratégias customizadas

✅ **PlantaRepository refatorado (reduzido para ~180 linhas):**
   - CRUD básico mantido
   - Funcionalidades extraídas para:
     - **PlantaCareQueryService**: streams de cuidados, queries baseadas em tarefas
     - **PlantaStatisticsService**: estatísticas avançadas, rankings, relatórios
     - **PlantaCareOperationsService**: conclusão de tarefas e toggles de cuidados

✅ **TarefaRepository refatorado (reduzido para ~150 linhas):**
   - CRUD básico mantido
   - Funcionalidades extraídas para:
     - **TarefaFilterService**: filtros complexos, paginação, consultas avançadas
     - **TarefaStatisticsService**: estatísticas detalhadas, tendências, produtividade

✅ **Services criados com responsabilidades únicas:**
   - Cada service tem função específica e bem definida
   - Interfaces limpas e reutilizáveis
   - Padrões como Strategy, Command e Factory aplicados
   - Exceções customizadas para error handling

✅ **Compatibilidade mantida:**
   - APIs públicas dos repositories preservadas
   - Métodos básicos ainda disponíveis com redirecionamento para services
   - Comments indicando onde usar services para funcionalidades avançadas
   - Funcionalidade end-to-end mantida

**Dependências resolvidas:** Services especializados implementados com injeção de dependência

**Validação:** ✅ Repositories agora focados em CRUD (150-180 linhas), funcionalidades avançadas em services especializados, Single Responsibility Principle aplicado

---

### 10. [PERFORMANCE] - Stream Operations Ineficientes

**Status:** 🟢 Concluído | **Execução:** Moderada | **Risco:** Médio | **Benefício:** Alto
**Implementado em:** 07/08/2025 | **Arquivos modificados:** optimized_stream_transformers.dart, espaco_repository.dart, planta_repository.dart, tarefa_filter_service.dart
**Observações:** Sistema completo de stream transformers implementado com cache inteligente, debounce e switchMap manual

**Descrição:** Streams em repositories fazem map() e where() em listas completas 
a cada evento. EspacoRepository.watchAtivos() e PlantaRepository.watchByEspaco() 
processam dados desnecessariamente.

**Implementação Realizada:**

✅ **OptimizedStreamTransformers criado:**
   - Sistema completo de cache inteligente para streams com TTL automático
   - Debounce implementado manualmente com Timer para controle granular
   - SwitchMap implementação manual para cancelar operações anteriores
   - Distinct automático com comparação customizável de listas/objetos
   - Cache invalidation baseado em hash de conteúdo
   - Cleanup automático de cache a cada 30 minutos

✅ **Stream Transformers especializados:**
   - **cachedDistinctList()**: Cache com distinct para listas com comparação otimizada
   - **debouncedDistinct()**: Debounce + distinct para streams individuais
   - **cachedFilter()**: Filtros com cache e invalidação automática por hash
   - **cachedMap()**: Map operations com cache para transformações custosas
   - **cachedWhereById()**: Busca otimizada por IDs usando Set lookups O(1)
   - **switchMapTransformer()**: Cancelamento de operações anteriores com cleanup

✅ **Transformers específicos por domain:**
   - **plantasByEspacoTransformer()**: Otimizado para filtro plantas por espaço
   - **espacosAtivoTransformer()**: Filtro otimizado para espaços ativos/inativos
   - **tarefasByPlantaTransformer()**: Filtro tarefas por planta com cache específico
   - **tarefasStatusTransformer()**: Status pendente/concluído com debounce reduzido

✅ **Extensions para facilitar uso:**
   - **Stream<List<T>>.cachedDistinct()**: Cache + distinct transparente
   - **Stream<List<T>>.cachedWhere()**: Filtros com cache automático
   - **Stream<List<T>>.cachedMapList()**: Map operations cached
   - **Stream<List<T>>.switchMapOptimized()**: SwitchMap com cancelamento manual
   - **Stream<T>.debouncedDistinct()**: Debounce + distinct para streams simples

✅ **Aplicação nos repositories:**

   **EspacoRepository otimizado:**
   - `watchAtivos()`: Cache key 'espacos_ativos', debounce 200ms
   - `watchInativos()`: Cache key 'espacos_inativos', debounce 200ms
   - Streams emitem apenas quando estado ativo realmente muda

   **PlantaRepository otimizado:**
   - `watchByEspaco()`: Cache key dinâmico 'plantas_espaco_$id', debounce 150ms
   - Filtro otimizado usando cache inteligente com invalidação por hash
   
   **TarefaFilterService otimizado:**
   - `filterStream()` refatorado para usar `cachedWhere()`
   - Integração com cache keys dos critérios existentes
   - Debounce configurável por tipo de filtro (150-300ms)
   - Cache compartilhado entre diferentes streams do mesmo critério

✅ **Sistema de gestão de recursos:**
   - Cleanup automático de timers de debounce
   - Gestão de subscriptions ativas para switchMap
   - Cache cleanup a cada 30 minutos
   - Dispose methods para limpeza completa
   - Estatísticas de cache via `getCacheStats()`

✅ **Performance melhorias alcançadas:**
   - **Distinct automático**: Streams não emitem valores duplicados desnecessariamente
   - **Cache inteligente**: Filtros não reprocessam dados idênticos
   - **Debounce otimizado**: Reduz processamento em streams de alta frequência
   - **Hash-based invalidation**: Cache invalidado apenas quando dados realmente mudam
   - **SwitchMap manual**: Operações anteriores canceladas automaticamente
   - **Timers gerenciados**: Sem vazamentos de Timer ou memory leaks

**Dependências resolvidas:** Stream optimization utilities, cache management, resource cleanup

**Validação:** ✅ Streams agora emitem apenas quando dados realmente mudaram. Cache inteligente elimina reprocessamento desnecessário. Debounce reduz frequência de emissões. SwitchMap cancela operações obsoletas. Sistema de cleanup previne memory leaks.

---

### 11. [ARCHITECTURE] - Mistura de Concerns em Repository

**Status:** 🟢 Concluído | **Execução:** Moderada | **Risco:** Médio | **Benefício:** Alto
**Implementado em:** 07/08/2025 | **Arquivos modificados:** 6 arquivos (3 novos services + 3 repositories refatorados)
**Observações:** Separação completa de responsabilidades implementada, repositories agora focam apenas em data access

**Descrição:** Repositories contém lógica de negócio (estatísticas, validações, 
transformações) que deveria estar em Services. Viola arquitetura em camadas.

**Implementação Realizada:**

✅ **BusinessRulesService criado:**
   - `existeEspacoComNome()`: Validação de unicidade de espaços
   - `existePlantaComNome()`: Validação de unicidade de plantas por espaço  
   - `podeExcluirEspaco()` / `podeExcluirPlanta()`: Regras de exclusão baseadas em dependências
   - `podeDesativarEspaco()`: Regras de desativação verificando tarefas pendentes
   - `calcularProximoCuidado()`: Lógica de agendamento baseada em configurações
   - `plantaPrecisaCuidadoHoje()`: Detecção de necessidade de cuidados
   - `devecriarTarefaAutomatica()`: Regras para criação automática de tarefas
   - `calcularPrioridadeTarefa()`: Algoritmo de priorização por tipo e atraso

✅ **ValidationService criado:**
   - `validateEspacoComplete()`: Validação completa de espaços (dados + negócio)
   - `validatePlantaComplete()`: Validação completa de plantas com verificação de espaço
   - `validatePlantaConfigComplete()`: Validação de configurações com regras de negócio
   - `validateTarefaComplete()`: Validação completa de tarefas
   - `validateEspacoDeletion()` / `validatePlantaDeletion()`: Validação de operações de exclusão
   - `validateAutomaticTaskCreation()`: Validação de criação automática
   - `validateBatch()`: Validação em lote para operações múltiplas
   - `validateBeforeSync()`: Validação antes de sincronização Firebase

✅ **StatisticsService criado:**
   - `getEspacoStatistics()`: Estatísticas básicas de espaços (movido de EspacoRepository)
   - `getPlantaStatistics()`: Estatísticas básicas de plantas (delegando para repository otimizado)
   - `getTarefaStatistics()`: Estatísticas básicas de tarefas (delegando para repository otimizado)
   - `getCompleteStatistics()`: Estatísticas completas coordenando todos os domínios
   - `getSummaryStatistics()`: Resumo para widgets e dashboard
   - `getProductivityStats()`: Métricas de produtividade e eficiência
   - `getPerformanceStats()`: Cálculos de pontualidade e eficiência

✅ **Repositories refatorados para data access only:**
   - **EspacoRepository**: `existeComNome()` e `getEstatisticas()` marcados @Deprecated
   - **PlantaRepository**: `getEstatisticas()` marcado @Deprecated  
   - **TarefaRepository**: `getEstatisticas()` marcado @Deprecated
   - Documentação atualizada indicando services apropriados para cada responsabilidade
   - Métodos legacy mantidos para compatibilidade durante migração

✅ **Arquitetura limpa implementada:**
   - Single Responsibility Principle aplicado
   - Separation of Concerns entre Data Access e Business Logic
   - Services especializados por domínio e responsabilidade
   - Validações centralizadas e reutilizáveis
   - Estatísticas coordenadas entre todos os domínios

✅ **Documentação completa:**
   - README_ARCHITECTURE_REFACTOR.md com guia completo da nova arquitetura
   - Mapeamento de responsabilidades por service
   - Exemplos de migração do código legacy para nova arquitetura
   - Plano de migração gradual com remoção dos métodos deprecated

**Arquivos criados:**
- `lib/app-plantas/services/domain/business_rules_service.dart`
- `lib/app-plantas/services/domain/validation_service.dart`
- `lib/app-plantas/services/domain/statistics_service.dart`
- `lib/app-plantas/services/domain/README_ARCHITECTURE_REFACTOR.md`

**Arquivos modificados:**
- `lib/app-plantas/repository/espaco_repository.dart`
- `lib/app-plantas/repository/planta_repository.dart`
- `lib/app-plantas/repository/tarefa_repository.dart`

**Dependências resolvidas:** Service layer design implementado, Business rules extraídas, Validation centralized

**Validação:** ✅ Repositories agora focam apenas em CRUD básico e queries simples. Lógica de negócio isolada em services especializados. Arquitetura em camadas respeitada. Métodos legacy deprecated para migração gradual.

---

### 12. [BUG] - Tratamento de Erros Inconsistente

**Status:** 🟢 Concluído | **Execução:** Moderada | **Risco:** Médio | **Benefício:** Alto
**Implementado em:** 07/08/2025 | **Arquivos modificados:** 8 arquivos criados + 3 repositories refatorados
**Observações:** Sistema completo de error handling implementado com RepositoryException hierarchy, logging estruturado e retry mechanism

**Descrição:** PlantaConfigRepository.findByPlantaId() usa try-catch que engole 
exceptions. TarefaRepository não trata erros em operações batch. Erros silenciosos 
dificultam debug.

**Implementação Realizada:**

✅ **RepositoryException Hierarchy Completa:**
   - **RepositoryException**: Classe base com contexto estruturado, timestamps e logging
   - **NetworkException**: Para falhas de conectividade com retry automático
   - **TimeoutException**: Para operações que excedem tempo limite
   - **DataAccessException**: Para erros de acesso a dados (Hive/Firebase)
   - **EntityNotFoundException**: Para entidades não encontradas
   - **BatchOperationException**: Para falhas em operações batch com estatísticas
   - **ValidationException**: Para erros de validação antes de persistir
   - **InvalidStateException**: Para estado inconsistente de repositories
   - **SyncException**: Para falhas de sincronização com sistemas externos
   - **DataConflictException**: Para conflitos de dados (unique constraints)
   - Utilities **RepositoryExceptions** com factory methods para criação rápida

✅ **Sistema de Logging Estruturado:**
   - **RepositoryLogger**: Logger específico com níveis (debug, info, warning, error, critical)
   - **LogEntry**: Entradas estruturadas com timestamp, context e exception details
   - **ConsoleLogOutput**: Integração com Flutter DevTools e console
   - **RepositoryLogManager**: Gerenciador global de loggers com configuração
   - **RepositoryLogUtils**: Utilities para contexto CRUD, batch e retry operations
   - Extensions para facilitar uso e métodos como `logOperation()` com timing

✅ **Retry Mechanism Robusto:**
   - **RetryConfig**: Configurações flexíveis (maxAttempts, backoff, jitter)
   - **RetryMechanism**: Execução com exponential backoff e circuit breaker
   - **RetryManager**: Gerenciador global com configurações predefinidas (network, fast, critical)
   - Predicados inteligentes para determinar se exception é retryable
   - Callbacks para monitoramento de tentativas
   - Timeout integration com retry automático

✅ **RepositoryErrorHandlingMixin Implementado:**
   - `executeWithErrorHandling()`: Wrapper para operações com error handling completo
   - `executeWithTimeoutAndRetry()`: Operações com timeout e retry automático
   - `executeCrudOperation()`: CRUD com logging estruturado e contexto
   - `executeBatchOperation()`: Batch operations com error handling especializado
   - `findInListSafely()`: Busca segura sem engolir exceptions inesperadas
   - Conversão automática de exceptions genéricas para RepositoryException

✅ **PlantaConfigRepository.findByPlantaId() Corrigido:**
   - Removido try-catch que engolia exceptions silenciosamente
   - Implementado `findInListSafely()` que diferencia StateError esperado de errors reais
   - Adicionado logging estruturado com contexto (plantaId, searchCriteria)
   - Integração completa com novo sistema via `executeCrudOperation()`

✅ **TarefaRepository Batch Operations Corrigidas:**
   - **createBatch()**: Refatorado com error handling robusto e retry automático
   - **removerPorPlanta()**: Operação batch com continue-on-error e logging detalhado
   - Contexto rico incluindo IDs das plantas, tipos de cuidado e estatísticas
   - Invalidação de cache apenas após sucesso completo
   - Tratamento individual de cada item com fallback graceful

✅ **Integração nos Repositories Principais:**
   - **TarefaRepository**: Mixin integrado com `repositoryName` getter
   - **PlantaConfigRepository**: Mixin integrado com operações refatoradas
   - **EspacoRepository**: Mixin integrado preparado para error handling
   - **PlantaRepository**: Mixin integrado preparado para error handling
   - Padrão consistente em todos repositories

✅ **Arquivos Criados:**
- `lib/app-plantas/repository/exceptions/repository_exceptions.dart`
- `lib/app-plantas/repository/logging/repository_logger.dart`
- `lib/app-plantas/repository/retry/retry_mechanism.dart`
- `lib/app-plantas/repository/error_handling/repository_error_handling_mixin.dart`

✅ **Arquivos Modificados:**
- `lib/app-plantas/repository/planta_config_repository.dart`
- `lib/app-plantas/repository/tarefa_repository.dart`
- `lib/app-plantas/repository/espaco_repository.dart`
- `lib/app-plantas/repository/planta_repository.dart`

**Benefícios Alcançados:**
- **Error Visibility**: Todos erros são logados com contexto estruturado
- **Retry Resilience**: Falhas temporárias são retentadas automaticamente
- **Debugging**: Logs estruturados facilitam identificação de problemas
- **Consistency**: Error handling padronizado em todos repositories
- **Observability**: Métricas e estatísticas de erros para monitoramento
- **Type Safety**: Hierarchy de exceptions específicas por tipo de erro

**Dependências resolvidas:** Error handling framework, logging system, retry mechanism, structured exception hierarchy

**Validação:** ✅ Exceptions não são mais engolidas silenciosamente. Batch operations têm error handling robusto. Sistema de logging estruturado implementado. Retry automático para falhas de network. Error handling consistente em todos repositories.

---

### 13. [PERFORMANCE] - Chamadas Desnecessárias ao Firebase

**Status:** 🟢 Concluído | **Execução:** Moderada | **Risco:** Médio | **Benefício:** Alto
**Implementado em:** 07/08/2025 | **Arquivos modificados:** 8 arquivos criados + planta_repository.dart + tarefa_repository.dart
**Observações:** Sistema completo de memoization e lazy evaluation implementado, reduzindo drasticamente chamadas desnecessárias

**Descrição:** PlantaRepository.getEstatisticas() faz múltiplas chamadas async 
desnecessárias. TarefaRepository.findParaHoje() recalcula data a cada chamada.

**Implementação Realizada:**

✅ **MemoizationManager Sistema Avançado:**
   - Sistema de cache inteligente com TTL configurável por categoria
   - Memoização com dependency tracking e invalidação automática
   - Debounce para operações frequentes evitando reprocessamento
   - Lazy evaluation transparente para computações custosas
   - Estatísticas de hit ratio e performance monitoring
   - Cleanup automático com configurações específicas por tipo

✅ **LazyEvaluationService Implementado:**
   - Lazy loaders especializados para estatísticas de plantas e tarefas
   - LazyDateQueries com cache diário para operações de data
   - Invalidação inteligente baseada em mudanças de dados
   - LazyStatisticsLoader genérico para diferentes tipos de dados
   - Avaliação sob demanda para plantas que precisam cuidado

✅ **StatisticsCacheService Avançado:**
   - Cache especializado por tipo: basic, aggregated, realtime, historical, derived
   - TTL configurável e recálculo automático em background
   - Warm-up de estatísticas importantes durante inicialização
   - Cache composito para estatísticas dependentes
   - Métricas de performance e monitoramento em tempo real

✅ **EnhancedQueryOptimizer com Índices:**
   - Índices em memória para lookup O(1) em plantas e tarefas
   - Query builder fluente com otimizações automáticas
   - Planos de query com estimativa de custo
   - Análise de performance e recomendações de otimização
   - Query parallelizada e uso de índices inteligente

✅ **OptimizationInitializer Centralizado:**
   - Inicialização coordenada de todos os serviços de otimização
   - Setup de invalidação automática baseada em streams
   - Warm-up de estatísticas críticas durante startup
   - Re-inicialização inteligente quando dados mudam
   - Debug info e performance metrics centralizadas

✅ **PlantaRepository.getEstatisticas() SUPER OTIMIZADO:**
   - Implementado cache composito com StatisticsCacheService
   - Uso do EnhancedQueryOptimizer para consultas otimizadas
   - Dependências rastreadas para invalidação precisa
   - TTL configurado para StatisticType.aggregated
   - Performance melhorada drasticamente para múltiplas chamadas

✅ **PlantaRepository.findPrecisaCuidadosHoje() OTIMIZADO:**
   - Memoização com dependency tracking (plantas, tarefas)
   - Lazy evaluation via LazyEvaluationService
   - Cache inteligente elimina recálculos desnecessários
   - Performance de O(N+1) para O(1) em chamadas subsequentes

✅ **TarefaRepository Queries de Data OTIMIZADAS:**
   - `findParaHoje()`: Lazy evaluation com cache diário
   - `findFuturas()`: Cache inteligente com TTL otimizado
   - `findAtrasadas()`: Lazy evaluation para máxima performance
   - Elimina recálculo de DateTime.now() a cada chamada
   - LazyDateQueries gerencia cache de data centralmente

✅ **Sistema de Invalidação Automática:**
   - Invalidação baseada em streams de dados
   - Dependency tracking entre plantas e tarefas
   - Categoria-specific invalidation para precisão
   - Setup automático durante inicialização dos repositories
   - Cleanup inteligente sem afetar performance

**Arquivos criados:**
- `lib/app-plantas/core/optimization/memoization_manager.dart`
- `lib/app-plantas/core/optimization/lazy_evaluation_service.dart`
- `lib/app-plantas/core/optimization/statistics_cache_service.dart`
- `lib/app-plantas/core/optimization/enhanced_query_optimizer.dart`
- `lib/app-plantas/core/optimization/optimization_initializer.dart`

**Arquivos modificados:**
- `lib/app-plantas/repository/planta_repository.dart`
- `lib/app-plantas/repository/tarefa_repository.dart`

**Performance Improvements Alcançadas:**
- **getEstatisticas()**: De múltiplas queries → cache composito com TTL inteligente
- **findParaHoje()**: De recálculo de data → lazy evaluation com cache diário  
- **findPrecisaCuidadosHoje()**: De N+1 queries → memoização com dependency tracking
- **Estatísticas agregadas**: Cache com warm-up automático e recálculo em background
- **Queries de data**: Lazy evaluation elimina DateTime.now() repetitivo
- **Hit ratio monitoring**: Métricas em tempo real para otimização contínua

**Dependências resolvidas:** Memoization pattern, Lazy evaluation, Statistics caching, Query optimization com índices

**Validação:** ✅ Chamadas ao Firebase/Hive reduzidas dramaticamente sem afetar funcionalidade. Sistema de cache inteligente com invalidação precisa. Lazy evaluation elimina computações desnecessárias. Performance monitoring mostra melhoria significativa em hit ratio.

---

### 14. [REFACTOR] - Métodos com Muitos Parâmetros

**Status:** 🟢 Concluído | **Execução:** Moderada | **Risco:** Baixo | **Benefício:** Médio
**Implementado em:** 07/08/2025 | **Arquivos modificados:** planta_config_repository.dart, espaco_repository.dart + 2 arquivos de patterns criados
**Observações:** Strategy pattern e Command pattern implementados com parameter objects, simplificando drasticamente métodos complexos

**Descrição:** PlantaConfigRepository.activateCareType() e updateCareInterval() 
usam switch cases longos. EspacoRepository.salvar() tem lógica condicional complexa.

**Implementação Realizada:**

✅ **Strategy Pattern para tipos de cuidado implementado:**
   - **CareTypeHandler abstract class**: Interface comum para todos os tipos de cuidado
   - **Handlers específicos**: WaterCareHandler, FertilizerCareHandler, SunBathCareHandler, PestInspectionCareHandler, PruningCareHandler, ReplantingCareHandler
   - **CareTypeHandlerFactory**: Factory pattern para obter handlers por tipo
   - **Intervalos padrão**: Cada handler define seu intervalo padrão sensato (7d água, 30d adubo, etc.)
   - **Validação centralizada**: Método validateInterval() comum a todos handlers
   - **Extensibilidade**: Novos tipos de cuidado podem ser adicionados facilmente

✅ **Command Pattern para operações de update:**
   - **UpdateCommand abstract class**: Interface comum para comandos com execute/undo
   - **ActivateCareTypeCommand**: Comando para ativar/desativar tipos de cuidado
   - **UpdateCareIntervalCommand**: Comando para atualizar intervalos
   - **UpdateEspacoCommand**: Comando para operações de update em espaços
   - **CreateEspacoCommand**: Comando para criação de espaços
   - **CommandExecutor**: Executor com suporte a batch, logging e undo
   - **Command history**: Histórico de comandos executados para auditoria

✅ **Parameter Objects implementados:**
   - **CareOperationParameters**: Para operações de cuidado (activate, interval, etc.)
   - **EspacoUpdateParameters**: Para atualizações de espaço com hasUpdates
   - **EspacoCreationParameters**: Para criação de espaços com factory methods
   - **Factory methods convenientes**: activate(), deactivate(), updateInterval(), basic()

✅ **PlantaConfigRepository refatorado:**
   - `activateCareType()`: Eliminou switch case, agora usa ActivateCareTypeCommand
   - `deactivateCareType()`: Eliminou switch case, agora usa ActivateCareTypeCommand
   - `updateCareInterval()`: Eliminou switch case, agora usa UpdateCareIntervalCommand
   - `executeCareOperation()`: Método genérico usando parameter objects
   - `activateMultipleCareTypes()`: Operação batch para múltiplos cuidados
   - `setupPlantCare()`: Método conveniente para configurar planta completa

✅ **EspacoRepository refatorado:**
   - `salvar()`: Lógica condicional complexa substituída por Commands
   - `criarEspaco()`: Método conveniente usando parameter objects
   - `atualizarEspaco()`: Método conveniente usando parameter objects
   - `criarMultiplosEspacos()`: Operação batch para múltiplos espaços
   - **Simplificação drástica**: CreateEspacoCommand e UpdateEspacoCommand encapsulam lógica

✅ **Benefícios alcançados:**
   - **Switch cases eliminados**: 6 switch cases longos substituídos por Strategy pattern
   - **Lógica condicional simplificada**: Command pattern encapsula complexidade
   - **Menos parâmetros**: Parameter objects agrupam parâmetros relacionados
   - **Extensibilidade**: Novos tipos de cuidado e operações facilmente adicionáveis
   - **Testabilidade**: Commands podem ser testados isoladamente
   - **Undo capability**: Comandos suportam reverter operações
   - **Batch operations**: Múltiplas operações podem ser executadas em sequência
   - **Auditoria**: Histórico de comandos executados para debug e monitoramento

✅ **Arquivos criados:**
- `lib/app-plantas/repository/patterns/care_type_handler.dart`
- `lib/app-plantas/repository/patterns/update_command.dart`

✅ **Arquivos modificados:**
- `lib/app-plantas/repository/planta_config_repository.dart`
- `lib/app-plantas/repository/espaco_repository.dart`

**Dependências resolvidas:** Strategy pattern, Command pattern, Parameter objects, Factory methods

**Validação:** ✅ Switch cases longos eliminados. Métodos com muitos parâmetros simplificados usando parameter objects. Lógica condicional complexa encapsulada em Commands. Extensibilidade facilitada através de patterns. Funcionalidade legacy mantida para compatibilidade.

---

### 15. [OPTIMIZE] - Memory Leaks em Streams

**Status:** 🟢 Concluído | **Execução:** Moderada | **Risco:** Médio | **Benefício:** Médio
**Implementado em:** 07/08/2025 | **Arquivos modificados:** stream_manager.dart, planta_care_query_service.dart, simple_task_service.dart, planta_config_repository.dart + 1 novo arquivo
**Observações:** Sistema completo de gerenciamento de streams implementado com WeakReference, dispose() methods e lifecycle management global

**Descrição:** Repositories criam streams mas não fornecem mecanismo de cleanup. 
PlantaRepository.watchPrecisaAduboHoje() usa asyncMap sem cancel logic.

**Implementação Realizada:**

✅ **StreamManager aprimorado com WeakReference:**
   - Adicionado suporte a WeakReference<StreamSubscription> para evitar vazamentos
   - Implementado sistema de keys para gerenciar subscriptions específicas
   - Melhor tratamento de dispose múltiplo com flag _isDisposed
   - Método cancelByKey() para cleanup seletivo de subscriptions
   - Error handling robusto durante dispose operations

✅ **StreamLifecycleManager mixin melhorado:**
   - Lazy initialization do StreamManager para otimizar recursos
   - Método createManagedAsyncMapStream() que substitui asyncMap sem cancel logic
   - Subscription management com keys específicas para tracking
   - Controle de estado _isStreamManagerDisposed para evitar operações após dispose
   - Debug info detalhado com contadores de weak references

✅ **PlantaCareQueryService refatorado:**
   - Substituição de asyncMap direto por createManagedAsyncMapStream()
   - Stream keys específicas para cada tipo de cuidado: 'plants_with_active_care_$careType'
   - Implementação de dispose() method com disposeStreams()
   - Método cancelStreamsForCareType() para cleanup seletivo
   - Debug info detalhado sobre streams gerenciadas

✅ **Dispose() methods implementados em todos repositories:**
   - **PlantaRepository**: dispose() já existia, aprimorado com stream management
   - **EspacoRepository**: dispose() já existia, aprimorado com stream management
   - **TarefaRepository**: dispose() já existia, aprimorado com stream management
   - **PlantaConfigRepository**: dispose() method implementado para consistência
   - **SimpleTaskService**: dispose() convertido para async para compatibilidade

✅ **StreamLifecycleManager global criado:**
   - Gerenciador centralizado para cleanup de toda aplicação
   - Métodos disposeAll(), disposeRepositories(), disposeServices()
   - Sistema de diagnóstico de memória com performMemoryDiagnostic()
   - Detecção automática de possíveis memory leaks (threshold: 50+ streams)
   - Debug info global com estatísticas consolidadas
   - Recomendações automáticas de ações baseadas no diagnóstico

✅ **Prevenção de memory leaks implementada:**
   - WeakReference evita referências circulares em subscriptions
   - StreamController com proper cleanup em onCancel
   - Managed asyncMap operations com lifecycle automático
   - Key-based subscription tracking para cleanup seletivo
   - Global cleanup coordinator para cenários de shutdown

**Arquivos criados:**
- `lib/app-plantas/core/streams/stream_lifecycle_manager.dart`

**Arquivos modificados:**
- `lib/app-plantas/core/streams/stream_manager.dart`
- `lib/app-plantas/services/domain/plants/planta_care_query_service.dart`
- `lib/app-plantas/services/domain/tasks/simple_task_service.dart`
- `lib/app-plantas/repository/planta_config_repository.dart`

**Dependências resolvidas:** Stream lifecycle management, WeakReference implementation, Global cleanup coordination

**Validação:** ✅ Memory profiler deve mostrar cleanup correto de streams. Todos asyncMap operations agora são gerenciados. WeakReference previne referências circulares. Global diagnostic detecta possíveis vazamentos. Dispose methods consistentes em todos repositories e services.

---

### 16. [ARCHITECTURE] - Dependência Circular Potencial

**Status:** 🟢 Concluído | **Execução:** Moderada | **Risco:** Médio | **Benefício:** Médio
**Implementado em:** 07/08/2025 | **Arquivos modificados:** 12 novos arquivos criados + atualizações em repositories e services
**Observações:** Sistema completo de dependency injection e event bus implementado, eliminando completamente potenciais dependências circulares

**Descrição:** PlantaRepository depende de SimpleTaskService que pode depender de 
outros repositories. Risco de dependências circulares conforme app cresce.

**Implementação Realizada:**

✅ **Mapeamento Completo de Dependências:**
   - Análise detalhada de todas dependências entre repositories e services
   - Identificação de potenciais ciclos: PlantaRepository ↔ SimpleTaskService
   - Mapeamento visual em `dependency_analysis.md` com riscos identificados
   - Estratégia definida para resolver dependências em fases

✅ **Interfaces para Abstração de Dependências:**
   - **IEspacoRepository**: Interface completa para EspacoRepository
   - **IPlantaRepository**: Interface completa para PlantaRepository  
   - **ITarefaRepository**: Interface completa para TarefaRepository
   - **IPlantaConfigRepository**: Interface completa para PlantaConfigRepository
   - **ITaskService**: Interface expandida com métodos para event handlers
   - Contratos claros definidos para todos métodos (CRUD, streams, business operations)

✅ **Enhanced Service Locator (DI Container):**
   - Registry avançado com metadata (dependencies, singleton, scope)
   - **Circular Dependency Detection**: Detecta ciclos automáticamente durante registration
   - **Dependency Graph Validation**: Valida integridade completa do grafo
   - **Ordered Initialization**: Inicialização automática respeitando ordem de dependências
   - **Lifecycle Management**: Initialize/dispose automático de todos services
   - **Test Configuration**: Setup fácil para mocks em ambiente de teste
   - **Debug Info**: Informações detalhadas para monitoring e troubleshooting

✅ **Event Bus para Comunicação Desacoplada:**
   - **Domain Events**: Hierarchy completa de eventos (EspacoEvent, PlantaEvent, TarefaEvent, PlantaConfigEvent)
   - **Publisher-Subscriber Pattern**: Comunicação assíncrona sem dependências diretas
   - **Event Handlers Automáticos**: 
     - EspacoRemovido → Remove plantas relacionadas
     - PlantaCriada → Cria configuração padrão
     - PlantaRemovida → Remove configurações e tarefas
     - TipoCuidadoAlterado → Gerencia tarefas futuras
     - TarefaConcluida → Agenda próxima tarefa
   - **Event Streaming**: Streams tipados para diferentes tipos de evento
   - **Error Handling**: Tratamento seguro de erros sem interromper outros handlers
   - **Statistics**: Contadores e métricas de eventos processados

✅ **Dependency Configuration Centralizada:**
   - **DependencyConfiguration**: Classe principal que orquestra toda configuração
   - **Production Setup**: Configuração automática para ambiente produção
   - **Test Setup**: Configuração com mocks para testes isolados  
   - **Event Handler Registration**: Setup automático de todos event handlers
   - **Health Checks**: Verificação de integridade das dependências
   - **Validation Integration**: Validação automática do grafo de dependências

✅ **SimpleTaskService Expandido:**
   - Implementação completa de novos métodos da interface ITaskService
   - `createTaskForPlantAndCareType()`: Criação específica via event handlers
   - `removeFutureTasksForPlantAndCareType()`: Limpeza automática de tarefas
   - `calculateNextTaskDate()`: Cálculo inteligente baseado em configurações
   - Integração completa com Event Bus para operações desacopladas

✅ **Arquitetura Event-Driven Implementada:**
   - Communication flow completamente assíncrono via eventos
   - Zero dependências diretas entre repositories
   - Extensibilidade facilitada para novos eventos e handlers
   - Separation of concerns bem definida entre layers

**Arquivos criados:**
- `core/interfaces/i_espaco_repository.dart`
- `core/interfaces/i_planta_repository.dart`
- `core/interfaces/i_tarefa_repository.dart`
- `core/interfaces/i_planta_config_repository.dart`
- `core/di/enhanced_service_locator.dart`
- `core/events/domain_event.dart`
- `core/events/event_bus.dart`
- `core/architecture/dependency_configuration.dart`
- `core/architecture/dependency_analysis.md`
- `core/architecture/README_CIRCULAR_DEPENDENCY_SOLUTION.md`

**Arquivos modificados:**
- `services/shared/interfaces/i_task_service.dart`
- `services/domain/tasks/simple_task_service.dart`

**Benefícios Alcançados:**
- **Zero Dependências Circulares**: Análise estática confirma ausência completa de ciclos
- **100% Testabilidade**: Todas dependências mockáveis via interfaces
- **Event-Driven Architecture**: Comunicação desacoplada elimina dependencies diretas
- **Extensibilidade**: Novos repositories e services facilmente integráveis
- **Robustez**: Validação automática previne problemas arquiteturais
- **Monitoramento**: Statistics e debug info para observability

**Dependências resolvidas:** Interface abstraction, DI Container, Event Bus, Domain Events, Circular dependency prevention

**Validação:** ✅ Análise estática confirma zero dependências circulares. Dependency graph validation automática retorna isValid=true. Event-driven communication elimina necessidade de dependências diretas. Health checks passam em todos cenários de teste.

---

### 17. [REFACTOR] - Duplicação de Código Entre Repositories

**Status:** 🟢 Concluído | **Execução:** Moderada | **Risco:** Baixo | **Benefício:** Médio
**Implementado em:** 2025-01-07 | **Arquivos criados:** base_repository.dart
**Observações:** BaseRepository<T> implementado com mixins especializados, eliminando duplicação

**Descrição:** Todos repositories têm métodos similares (initialize, findAll, 
streams) com implementações quase idênticas. Violação do DRY principle.

**Prompt de Implementação:**
Criar BaseRepository<T> abstract class. Extrair comportamentos comuns. 
Implementar generic repository pattern. Usar mixins para funcionalidades 
específicas.

**Dependências:** Generic repository design

**Validação:** ✅ Duplicação removida mantendo funcionalidade específica de cada repo.

✅ **Implementação realizada:**

✅ **BaseRepository<T extends BaseModel> criado:**
   - CRUD operations genéricas (findAll, findById, create, update, delete, createBatch)
   - Cache management integrado via CacheableRepository mixin
   - Stream lifecycle management via StreamLifecycleManager mixin
   - Error handling via RepositoryErrorHandlingMixin
   - Inicialização thread-safe via InitializationManager
   - Hooks para customização (onAfterInitialize, onItemCreated, onItemUpdated, onItemDeleted)

✅ **Mixins especializados criados:**
   - `PlantCareFunctionality<T>`: Para funcionalidades relacionadas a plantas
     - `watchByPlanta()`, `findByPlanta()`, `getPlantaId()`
   - `SpaceManagementFunctionality<T>`: Para funcionalidades de espaços
     - `watchAtivos()`, `watchInativos()`, `findAtivos()`, `isItemActive()`
   - `TaskManagementFunctionality<T>`: Para funcionalidades de tarefas
     - `watchPendentes()`, `watchConcluidas()`, `findPendentes()`, `findConcluidas()`, `isTaskCompleted()`

✅ **Repositories refatorados:**
   - **PlantaRepository**: Herda de `BaseRepository<PlantaModel>` + `PlantCareFunctionality`
   - **TarefaRepository**: Herda de `BaseRepository<TarefaModel>` + `PlantCareFunctionality` + `TaskManagementFunctionality`
   - **EspacoRepository**: Herda de `BaseRepository<EspacoModel>` + `SpaceManagementFunctionality`

✅ **Funcionalidades específicas mantidas:**
   - PlantaRepository: Métodos de cuidados, estatísticas otimizadas, integração com services
   - TarefaRepository: Filtros avançados, queries por data, integração com FilterService
   - EspacoRepository: Validações robustas, Command pattern, Result wrapper

✅ **Compatibilidade backwards:**
   - APIs públicas preservadas integralmente
   - Streams com nomes originais mantidos (`plantasStream`, `tarefasStream`, `espacosStream`)
   - Métodos legacy mantidos onde necessário
   - Singleton patterns preservados

✅ **Arquivos criados:**
- `lib/app-plantas/repository/base_repository.dart`

✅ **Arquivos modificados:**
- `lib/app-plantas/repository/planta_repository.dart`
- `lib/app-plantas/repository/tarefa_repository.dart`  
- `lib/app-plantas/repository/espaco_repository.dart`

**Benefícios Alcançados:**
- **Eliminação de duplicação**: Métodos CRUD, inicialização e streams centralizados
- **Reusabilidade**: Mixins permitem combinar funcionalidades conforme necessário
- **Manutenibilidade**: Mudanças em comportamentos comuns centralizadas em um local
- **Type Safety**: Generic repository pattern com type constraints
- **Extensibilidade**: Fácil adição de novos repositories usando BaseRepository
- **Performance**: Cache e stream management otimizados herdados automaticamente

**Dependências resolvidas:** Generic repository design, mixins especializados, type constraints

**Validação:** ✅ Duplicação de código eliminada entre repositories mantendo funcionalidades específicas. Generic repository pattern implementado com sucesso. Mixins permitem composição flexível de funcionalidades. Backward compatibility preservada.

---

### 18. [OPTIMIZE] - Consultas Não Otimizadas

**Status:** 🟢 Concluído | **Execução:** Moderada | **Risco:** Baixo | **Benefício:** Alto
**Implementado em:** 2025-08-07 | **Arquivos modificados:** SyncFirebaseService, PlantaRepository, EspacoRepository, FirebaseQueryOptimizer, SearchCacheService, FirebaseIndexManager
**Observações:** Sistema completo de otimização implementado com Firebase queries otimizadas, full-text search, cache inteligente de resultados e fallbacks para busca local. Inclui métodos setupOptimizedSearch() nos repositories para preparação inicial.

**Descrição:** findByNome() usa contains() em memória ao invés de queries 
otimizadas. Filtros poderiam ser feitos no banco para melhor performance.

**Prompt de Implementação:**
Implementar query optimization no SyncFirebaseService. Usar índices Firebase. 
Implementar full-text search quando aplicável. Cache resultados de busca frequentes.

**Dependências:** Database indexing, Search optimization

**Validação:** ✅ Buscas otimizadas implementadas com Firebase queries, cache inteligente e full-text search

---

### 19. [BUG] - Estados Inconsistentes em Operações Batch

**Status:** 🟢 Concluído | **Execução:** Moderada | **Risco:** Médio | **Benefício:** Médio
**Implementado em:** 2025-08-07 | **Arquivos modificados:** transaction_manager.dart, transactional_repository_mixin.dart, base_repository.dart, repository_exceptions.dart
**Observações:** Implementado sistema completo de transações atômicas com rollback automático, event sourcing para auditoria e compensating actions. createBatch() agora é transaction-safe com garantia all-or-nothing.

**Descrição:** createBatch() não é transaction-safe. Se uma operação falhar no meio, 
pode deixar dados em estado inconsistente entre Hive e Firebase.

**Prompt de Implementação:**
Implementar atomic operations com rollback. Usar transaction pattern. 
Adicionar compensating actions para failures. Implementar event sourcing 
para auditoria de mudanças.

**Dependências:** Transaction management, Event sourcing

**Validação:** Batch operations devem ser all-or-nothing, sem estados intermediários.

---

### 20. [REFACTOR] - String Magic Numbers

**Status:** 🟢 Concluído | **Execução:** Simples | **Risco:** Baixo | **Benefício:** Médio
**Implementado em:** 2025-08-07 | **Arquivos modificados:** care_type_const.dart, task_utils.dart, simple_task_service.dart, business_rules_service.dart, care_type_handler.dart, validators, controllers, care_type_service.dart
**Observações:** CareType enum criado com validações type-safe, refatoração de strings mágicas mantendo compatibilidade

**Descrição:** Strings como 'agua', 'adubo', 'banho_sol' hardcoded em múltiplos 
locais. PlantaConfigRepository tem switch cases com strings mágicas.

**Prompt de Implementação:**
Criar CareType enum ou constants class. Refatorar todos repositories para usar 
constantes. Implementar type-safe care type handling. Adicionar validation 
para care types válidos.

**Dependências:** Constants definition, Type safety

**Validação:** Eliminar todas strings mágicas relacionadas a tipos de cuidado.

---

## 🟠 Complexidade MÉDIA

### 21. [OPTIMIZE] - Datas Recalculadas Desnecessariamente

**Status:** 🟢 Concluído | **Execução:** Simples | **Risco:** Baixo | **Benefício:** Médio
**Implementado em:** 06/08/2025 | **Arquivos modificados:** date_utils.dart, tarefa_repository.dart
**Observações:** Criado DateUtils helper com cache inteligente, otimizados métodos de filtro por data

**Descrição:** TarefaRepository recalcula DateTime.now() e conversões de data 
múltiplas vezes nos mesmos métodos. Ineficiência desnecessária.

**Prompt de Implementação:**
Cachear DateTime.now() no início dos métodos. Criar DateUtils helper para 
conversões reutilizáveis. Implementar date computation optimization.

**Dependências:** DateUtils helper class

**Validação:** Reduzir chamadas DateTime.now() mantendo mesma funcionalidade.

---

### 22. [REFACTOR] - Métodos Muito Similares

**Status:** 🟢 Concluído | **Execução:** Simples | **Risco:** Baixo | **Benefício:** Médio
**Implementado em:** 2025-08-07 | **Arquivos modificados:** date_criteria_strategy.dart, lazy_evaluation_service.dart, tarefa_repository.dart

**Descrição:** TarefaRepository tem findParaHoje(), findFuturas(), findAtrasadas() 
com 90% do código duplicado. Diferem apenas no critério de comparação de data.

**Prompt de Implementação:**
Criar método genérico findByDateCriteria() que aceita função de filtro. 
Implementar factory methods para cada tipo. Usar Strategy pattern para 
critérios de filtro.

**Dependências:** Strategy pattern implementation ✅

**Validação:** Reduzir duplicação mantendo API pública inalterada ✅

**Observações:** 
- Criado DateCriteriaStrategy com implementações TodayCriteriaStrategy, OverdueCriteriaStrategy, FutureCriteriaStrategy
- Método genérico findByDateCriteria() implementado no TarefaRepository
- Factory methods refatorados para usar Strategy pattern internamente
- API pública mantida inalterada para backward compatibility
- Cache TTL otimizado per strategy para melhor performance

---

### 23. [STYLE] - Formatação Inconsistente

**Status:** 🟢 Concluído | **Execução:** Simples | **Risco:** Baixo | **Benefício:** Baixo
**Implementado em:** 2025-08-07 | **Arquivos modificados:** base_repository.dart, planta_config_repository.dart, planta_repository.dart, espaco_repository.dart, tarefa_repository.dart, exceptions/*.dart, logging/*.dart, patterns/*.dart, transaction/*.dart
**Observações:** Aplicado dart format, refatorados métodos longos do PlantaConfigRepository em submétodos, corrigida ordenação de imports, substituído debugPrint por logging estruturado, removidos imports não utilizados, corrigidos erros críticos de compilação

**Descrição:** Inconsistência em espaçamento, quebras de linha e indentação entre 
repositories. PlantaConfigRepository tem métodos muito longos.

**Prompt de Implementação:**
Aplicar dart format em todos arquivos. Quebrar métodos longos em submétodos. 
Padronizar nomenclatura e estrutura. Aplicar linter rules consistentemente.

**Dependências:** Dart formatting tools

**Validação:** Código deve passar em todas verificações do linter.

---

### 24. [OPTIMIZE] - Conversões de Tipo Redundantes

**Status:** 🟢 Concluído | **Execução:** Simples | **Risco:** Baixo | **Benefício:** Baixo
**Implementado em:** 06/08/2025 | **Arquivos modificados:** datetime_extensions.dart, tarefa_repository.dart
**Observações:** Criadas extensions para DateTime com cache inteligente, otimizadas conversões de data

**Descrição:** Múltiplas conversões DateTime para date only usando DateTime() 
constructor. Operação custosa repetida desnecessariamente.

**Prompt de Implementação:**
Criar extension methods para DateTime com dateOnly getter. Cachear conversões 
quando usado múltiplas vezes. Implementar date comparison utilities.

**Dependências:** DateTime extensions

**Validação:** Reduzir conversões DateTime mantendo mesma funcionalidade.

---

### 25. [REFACTOR] - Lógica de Negócio em Repository

**Status:** 🟢 Concluído | **Execução:** Moderada | **Risco:** Baixo | **Benefício:** Médio
**Implementado em:** 2025-08-07 | **Arquivos modificados:** espaco_repository.dart
**Observações:** Métodos duplicar() e duplicarLegacy() refatorados para delegar ao EspacoCopyService. Repository agora apenas faz data access sem business rules.

**Descrição:** EspacoRepository.duplicar() contém business rules sobre nome da 
cópia e status ativo. Repository deveria delegar para service.

**Prompt de Implementação:**
Mover lógica de duplicação para EspacoService. Repository deve apenas criar 
nova entidade com dados fornecidos. Implementar business rules separation.

**Dependências:** Service layer extraction

**Validação:** ✅ Repository não contém regras de negócio, apenas data access delegado ao EspacoCopyService.

---

### 26. [BUG] - Comparação de String Case Sensitive

**Status:** 🟢 Concluído | **Execução:** Simples | **Risco:** Baixo | **Benefício:** Baixo

**Descrição:** EspacoRepository.existeComNome() usa toLowerCase() mas pode haver 
problemas com caracteres acentuados e internacionalização.

**Prompt de Implementação:**
Usar comparison normalizada com Intl package. Implementar string comparison 
utilities que lidam com acentos e case sensitivity. Adicionar testes para 
casos edge.

**Dependências:** Intl package, String normalization

**Validação:** Comparison deve funcionar corretamente com acentos e caracteres especiais.

**Implementado em:** 2025-08-07 | **Arquivos modificados:** string_comparison_utils.dart, espaco_repository.dart, espaco_validator.dart, business_rules_service.dart, espaco_query_service.dart, espacos_service.dart

**Observações:** 
- Criado StringComparisonUtils com normalização robusta para caracteres acentuados
- Substituído toLowerCase() por comparação normalizada em todos os repositories e services
- Implementados testes edge cases para validação de funcionalidade
- Mantida compatibilidade com API existente através de correções pontuais
- Melhorada consistência em buscas, validações de unicidade e ordenação internacional

---

### 27. [OPTIMIZE] - Filtering em Memória vs Database

**Status:** 🟢 Concluído | **Execução:** Moderada | **Risco:** Baixo | **Benefício:** Médio
**Implementado em:** 06/08/2025 | **Arquivos modificados:** filtering_optimizer.dart, todos os repositories
**Observações:** Implementado sistema de cache inteligente para filtros com debouncing e invalidação automática

**Descrição:** watchAtivos() e similares fazem where() em memória. Com muitos 
dados, seria mais eficiente filtrar na fonte.

**Prompt de Implementação:**
Implementar filtering no SyncFirebaseService level. Usar Firebase queries onde 
possível. Manter cache local filtrado. Otimizar para casos de uso reais.

**Dependências:** Database query optimization

**Validação:** Filtros devem ser eficientes mesmo com milhares de registros.

---

### 28. [REFACTOR] - Hardcoded Default Values

**Status:** 🟢 Concluído | **Execução:** Simples | **Risco:** Baixo | **Benefício:** Baixo
**Implementado em:** 07/08/2025 | **Arquivos modificados:** default_spaces_config.dart, default_spaces_service.dart, espacos_translations.dart, espaco_repository.dart
**Observações:** Sistema completo implementado com configuração, i18n, SharedPreferences e preparação para configuração remota. Mantido fallback para compatibilidade.

**Descrição:** _criarEspacosPadrao() tem nomes hardcoded. Deveria ser configurável 
ou internacionalizado.

**Prompt de Implementação:**
Criar configuration file para valores default. Implementar i18n para strings. 
Permitir customização via SharedPreferences ou configuração remota.

**Dependências:** Configuration management, i18n

**Validação:** Defaults devem ser configuráveis e internationalizáveis.

---

### 29. [OPTIMIZE] - Unnecessary Object Creation

**Status:** 🟢 Concluído | **Execução:** Simples | **Risco:** Baixo | **Benefício:** Baixo
**Implementado em:** 06/08/2025 | **Arquivos modificados:** todos os repositories
**Observações:** Otimizada criação de objetos com lazy evaluation, cache de strings e operações combinadas

**Descrição:** Criação de objetos temporários em loops e streams. toList() 
chamado desnecessariamente em alguns casos.

**Prompt de Implementação:**
Otimizar object creation. Usar lazy iterables onde aplicável. Implementar 
object pooling para casos críticos. Profile memory allocation.

**Dependências:** Performance optimization

**Validação:** Memory profiler deve mostrar menos allocation pressure.

---

### 30. [REFACTOR] - Complex Conditional Logic

**Status:** 🟢 Concluído | **Execução:** Moderada | **Risco:** Baixo | **Benefício:** Médio
**Implementado em:** 07/08/2025 | **Arquivos modificados:** care_need_checker.dart (novo), lazy_evaluation_service.dart, planta_repository.dart
**Observações:** Lógica refatorada para Chain of Responsibility pattern com 6 checkers modulares: CriticalConditionChecker, UrgentCareChecker, OverdueTaskChecker, TodayTaskChecker, PeriodicCareChecker, AbandonedPlantChecker

**Descrição:** PlantaRepository.findPrecisaCuidadosHoje() tem 6 condições OR 
concatenadas. Difícil de ler e manter.

**Prompt de Implementação:**
Refatorar para usar lista de checkers. Implementar CareNeedChecker interface. 
Usar chain of responsibility pattern. Tornar lógica mais modular.

**Dependências:** Design pattern implementation

**Validação:** ✅ Lógica refatorada é mais legível e extensível para novos tipos de cuidado. Chain of Responsibility permite adicionar novos checkers facilmente.

---

### 31. [BUG] - Null Safety Issues

**Status:** 🟢 Concluído | **Execução:** Simples | **Risco:** Médio | **Benefício:** Médio
**Implementado em:** 07/08/2025 | **Arquivos modificados:** planta_repository.dart, base_repository.dart, planta_model.dart, business_rules_service.dart, espaco_repository.dart
**Observações:** Corrigido problema no findByNome(), implementados late final para singletons, adicionados null object patterns no PlantaModel e assertions para invariants críticos

**Descrição:** PlantaRepository.findByNome() usa operador ?? false mas pode ter 
other null issues. Alguns null checks podem ser melhorados.

**Implementação Realizada:**

✅ **Null Safety Patterns Corrigidos:**
   - **PlantaRepository.findByNome()**: Removido `?? false` problemático, adicionada validação null safety explícita
   - **Late final para singletons**: Convertidos campos singleton para `late final` garantindo inicialização única
   - **Assertions críticas**: Adicionadas validações de invariants em métodos críticos (mover, adicionar/remover imagens)
   - **Null object patterns**: Implementados getters seguros no PlantaModel (safeImagePaths, safeComentarios, etc.)

✅ **BaseRepository Melhorado:**
   - **Assertions em CRUD**: Validações de parâmetros não-nulos em create, update, delete
   - **Late final SyncService**: Garantia de inicialização única e imutável
   - **Null object patterns**: Tratamento de listas vazias e logging de tentativas inválidas

✅ **BusinessRulesService Otimizado:**
   - **Late final repositories**: Inicialização única no constructor para thread safety
   - **Assertions de parâmetros**: Validação de strings não-vazias e IDs válidos
   - **Null safety em comparações**: Verificações explícitas de nomes válidos antes de comparações

✅ **PlantaModel Null Object Patterns:**
   - **Safe getters**: safeImagePaths, safeComentarios, safeNome, safeEspecie, safeObservacoes
   - **Validation helpers**: hasValidNome, hasImages, hasComentarios, hasObservacoes
   - **Constructor assertions**: Validação de invariants críticos (ID não-vazio, timestamps válidos)
   - **JSON serialization**: Garantia de listas não-nulas em toJson/fromJson

**Prompt de Implementação:**
Revisar todos null safety patterns. Usar late final onde apropriado. 
Implementar null object pattern onde faz sentido. Adicionar assertions 
para invariants.

**Dependências resolvidas:** Null safety best practices implementadas com late final, null object patterns e assertions

**Validação:** ✅ Código passa null safety analysis sem warnings. Padrões consistentes aplicados em todos os repositories e models.

---

### 32. [OPTIMIZE] - Stream Subscription Management

**Status:** 🟢 Concluído | **Execução:** Simples | **Risco:** Baixo | **Benefício:** Médio
**Implementado em:** 06/08/2025 | **Arquivos modificados:** stream_manager.dart, todos os repositories
**Observações:** Implementado StreamManager com lifecycle completo e mixin para gerenciamento automático

**Descrição:** asyncMap() em streams pode criar subscription leaks se não 
gerenciado corretamente. Falta cleanup em alguns casos.

**Prompt de Implementação:**
Implementar proper stream subscription lifecycle. Usar takeUntil patterns. 
Adicionar dispose methods onde necessário. Monitor subscription leaks.

**Dependências:** Stream lifecycle management

**Validação:** Não deve haver subscription leaks em memory profiler.

---

### 33. [REFACTOR] - Mixed Abstraction Levels

**Status:** 🟢 Concluído | **Execução:** Moderada | **Risco:** Baixo | **Benefício:** Alto
**Implementado em:** 07/08/2025 | **Arquivos criados:** repository_operations_facade.dart, repository_query_facade.dart, facades/README.md
**Arquivos modificados:** base_repository.dart, planta_repository.dart, tarefa_repository.dart, espaco_repository.dart

**Descrição:** Repositories misturam low-level data access com high-level business 
operations. Diferentes níveis de abstração na mesma classe.

**Prompt de Implementação:**
Separar operations por nível de abstração. Criar facade pattern para operations 
complexas. Manter repositories em consistent abstraction level.

**Dependências:** Architectural refactoring

**Validação:** ✅ Cada repository mantém consistent abstraction level (baixo nível apenas)
**Solução Implementada:**
- Criado RepositoryOperationsFacade para operações complexas cross-entity
- Criado RepositoryQueryFacade para queries avançadas e analytics
- Repositórios mantêm apenas operações CRUD básicas (low-level)
- Facades centralizam operações de alto nível (high-level)
- Métodos complexos deprecated nos repositórios com redirecionamento para facades
- Documentação completa da separação de abstrações
**Observações:** Implementação completa do facade pattern com cache inteligente e operações paralelas otimizadas

---

### 34. [OPTIMIZE] - Inefficient List Operations

**Status:** 🟢 Concluído | **Execução:** Simples | **Risco:** Baixo | **Benefício:** Baixo
**Implementado em:** 06/08/2025 | **Arquivos modificados:** collection_utils.dart, todos os repositories
**Observações:** Criadas utilities para operações de coleção otimizadas e extensions para early return

**Descrição:** where() seguido de toList() quando poderia usar efficient 
alternatives. Sort operations em streams que podem ser otimizadas.

**Prompt de Implementação:**
Otimizar list operations. Usar whereType quando aplicável. Implementar 
lazy evaluation onde possível. Cache sorted lists quando reusadas.

**Dependências:** Collection optimization

**Validação:** List operations devem ser mais eficientes especialmente em streams.

---

### 35. [REFACTOR] - Repository Responsibilities

**Status:** 🟢 Concluído | **Execução:** Moderada | **Risco:** Baixo | **Benefício:** Médio
**Implementado em:** 2025-01-27 | **Arquivos modificados:** 
- aspect_interface.dart (novo - sistema AOP core)
- logging_aspect.dart (novo - aspecto de logging)
- validation_aspect.dart (novo - aspecto de validação) 
- statistics_aspect.dart (novo - aspecto de estatísticas)
- aspect_manager.dart (novo - gerenciador de aspectos)
- aspect_aware_service_locator.dart (novo - DI com AOP)
- base_repository.dart (atualizado - suporte a aspectos)
- planta_repository.dart (atualizado - concerns externalizados)
- espaco_repository.dart (atualizado - concerns externalizados)

**Descrição:** Alguns repositories fazem logging, statistics, validation 
e outras responsabilidades que poderiam ser external concerns.

**Implementação Realizada:**
✅ Sistema completo de Aspect-Oriented Programming (AOP) implementado
✅ Dependency injection aprimorado com AspectAwareServiceLocator
✅ Cross-cutting concerns externalizados via aspectos:
  - LoggingAspect: Logging estruturado de operações com configuração flexível
  - ValidationAspect: Validação automática de entrada e saída com sanitização
  - StatisticsAspect: Coleta automática de métricas e performance monitoring
✅ RepositoryAspectManager para configuração dinâmica de aspectos
✅ BaseRepository atualizado com suporte nativo a AOP via mixin AspectAwareRepository
✅ PlantaRepository e EspacoRepository refatorados - concerns externalizados
✅ Configurações por ambiente (prod/dev/test/debug) para aspectos
✅ Hot-swapping de aspectos em runtime
✅ Interceptação transparente via proxy pattern

**Benefícios Alcançados:**
- Repositories focam exclusivamente em persistência de dados (Single Responsibility)
- Cross-cutting concerns aplicados de forma consistente e configurável
- Facilita testing com aspectos desabilitados
- Melhora manutenibilidade com separação clara de responsabilidades
- Performance monitoring automático sem poluir código de negócio
- Logging estruturado aplicado automaticamente
- Validação robusta aplicada em todas as operações
- Estatísticas coletadas automaticamente para análise de performance

**Dependências:** ✅ AOP patterns implementados, ✅ DI container aprimorado

**Validação:** ✅ Repositories focam apenas em data access, ✅ concerns externalizados via AOP

**Observações:** Sistema AOP permite adicionar novos aspectos facilmente (caching, security, audit trail) sem modificar código dos repositories existentes.

---

### 36. [STYLE] - Documentation Missing

**Status:** 🟠 Pendente | **Execução:** Simples | **Risco:** Baixo | **Benefício:** Baixo

**Descrição:** Falta documentação detalhada nos métodos públicos. Alguns 
comentários TODO que deveriam ser tracked formalmente.

**Prompt de Implementação:**
Adicionar dartdoc em todos métodos públicos. Documentar parameters, return 
values e exceptions. Converter TODOs em issues trackáveis.

**Dependências:** Documentation standards

**Validação:** dartdoc deve gerar documentação completa sem warnings.

---

## 🟢 Complexidade BAIXA

### 37. [STYLE] - Import Organization

**Status:** 🟢 Concluído | **Execução:** Simples | **Risco:** Baixo | **Benefício:** Baixo
**Implementado em:** 06/08/2025 | **Arquivos modificados:** espaco_repository.dart, planta_config_repository.dart, planta_repository.dart, tarefa_repository.dart
**Observações:** Imports organizados usando dart format, seguindo padrão dart, flutter, package, relative

**Descrição:** Imports não seguem ordem padrão Dart (dart, flutter, package, project). 
Alguns imports podem estar unused.

**Prompt de Implementação:**
Aplicar dart format e organize imports. Remover unused imports. Seguir 
effective dart style guide para import organization.

**Dependências:** Dart tooling

**Validação:** Imports devem seguir padrão: dart, flutter, package, relative.

---

### 38. [STYLE] - Method Naming Consistency

**Status:** 🟢 Concluído | **Execução:** Simples | **Risco:** Baixo | **Benefício:** Baixo
**Implementado em:** 06/08/2025 | **Arquivos modificados:** planta_config_repository.dart
**Observações:** Padronização de nomenclatura aplicada, removidos awaits desnecessários em return statements

**Descrição:** watchAtivos vs findAtivos naming inconsistency. watch* para streams 
e find* para futures nem sempre consistente.

**Prompt de Implementação:**
Padronizar nomenclature: watch* para streams, find* para futures, get* para 
synchronous. Renaming method mais consistency guidelines.

**Dependências:** Naming conventions

**Validação:** Nomenclature deve ser consistent across todos repositories.

---

### 39. [OPTIMIZE] - Unnecessary await Keywords

**Status:** 🟢 Concluído | **Execução:** Simples | **Risco:** Baixo | **Benefício:** Baixo
**Implementado em:** 06/08/2025 | **Arquivos modificados:** espaco_repository.dart, planta_config_repository.dart, planta_repository.dart
**Observações:** Removidos awaits desnecessários em return statements, melhorando performance

**Descrição:** Alguns métodos têm await desnecessários em return statements 
onde could return Future directly.

**Prompt de Implementação:**
Remover await desnecessários. Usar return direct future onde appropriate. 
Optimize async/await usage para better performance.

**Dependências:** Async optimization

**Validação:** Manter mesma API mas com less overhead.

---

### 40. [STYLE] - Variable Naming

**Status:** 🟢 Concluído | **Execução:** Simples | **Risco:** Baixo | **Benefício:** Baixo
**Implementado em:** 06/08/2025 | **Arquivos modificados:** planta_config_repository.dart
**Observações:** Variáveis renomeadas para nomes mais descritivos (existing -> existingConfig, updated -> updatedConfig)

**Descrição:** Algumas variáveis têm nomes genéricos como 'updated', 'existing' 
que poderiam ser mais descriptivas.

**Prompt de Implementação:**
Renomear variáveis para nomes mais descriptivos. Seguir dart naming conventions. 
Evitar abbreviations onde possible.

**Dependências:** Code review standards

**Validação:** Variáveis devem ter nomes self-documenting.

---

### 41. [OPTIMIZE] - Const Constructors

**Status:** 🟢 Concluído | **Execução:** Simples | **Risco:** Baixo | **Benefício:** Baixo
**Implementado em:** 06/08/2025 | **Arquivos modificados:** Todos os repositories
**Observações:** Const constructors já estavam sendo utilizados adequadamente (Duration, etc.)

**Descrição:** Duration objects e alguns outros poderiam ser const para 
performance optimization.

**Prompt de Implementação:**
Adicionar const keywords onde applicable. Optimize object creation with 
const constructors. Use static const para values que não change.

**Dependências:** Const optimization

**Validação:** Less object allocation sem functionality changes.

---

### 42. [STYLE] - Line Length

**Status:** 🟢 Concluído | **Execução:** Simples | **Risco:** Baixo | **Benefício:** Baixo
**Implementado em:** 06/08/2025 | **Arquivos modificados:** Todos os repositories
**Observações:** Linhas longas quebradas automaticamente pelo dart format

**Descrição:** Algumas linhas excedem 80-100 caracteres, afetando readability 
em different screen sizes.

**Prompt de Implementação:**
Break long lines following dart style guide. Use proper indentation. 
Configure IDE para show line length ruler.

**Dependências:** Code formatting

**Validação:** No lines should exceed 100 characters.

---

### 43. [REFACTOR] - Boolean Parameter Methods

**Status:** 🟢 Concluído | **Execução:** Simples | **Risco:** Baixo | **Benefício:** Baixo
**Implementado em:** 06/08/2025 | **Arquivos modificados:** espaco_repository.dart, tarefa_repository.dart
**Observações:** Criados métodos unificados setAtivo() e setConcluida() mantendo compatibilidade com ativar()/desativar() e marcarConcluida()/marcarPendente()

**Descrição:** ativar()/desativar() methods could be consolidated into 
setActive(bool active) para cleaner API.

**Prompt de Implementação:**
Consolidate boolean parameter methods. Create wrapper methods se necessário 
para backward compatibility. Simplify API surface.

**Dependências:** API design

**Validação:** Cleaner API mantendo mesma functionality.

---

### 44. [OPTIMIZE] - Early Returns

**Status:** 🟢 Concluído | **Execução:** Simples | **Risco:** Baixo | **Benefício:** Baixo
**Implementado em:** 06/08/2025 | **Arquivos modificados:** espaco_repository.dart, tarefa_repository.dart, planta_config_repository.dart
**Observações:** Implementados early returns para reduzir aninhamento e melhorar legibilidade

**Descrição:** Alguns métodos poderiam use early returns para reduce nesting 
e improve readability.

**Prompt de Implementação:**
Refactor nested conditionals para use early returns. Reduce cyclomatic 
complexity. Improve code flow readability.

**Dependências:** Refactoring patterns

**Validação:** Code should have less nesting e be more readable.

---

### 45. [STYLE] - Collection Literals

**Status:** 🟢 Concluído | **Execução:** Simples | **Risco:** Baixo | **Benefício:** Baixo
**Implementado em:** 06/08/2025 | **Arquivos modificados:** planta_repository.dart
**Observações:** Collection literals já estavam sendo usados corretamente, removido type annotation desnecessário

**Descrição:** Use List() constructor ao invés de [] literals em alguns places. 
Less efficient e less idiomatic.

**Prompt de Implementação:**
Replace List() constructors com [] literals onde appropriate. Use const 
literals para constant collections. Follow dart best practices.

**Dependências:** Dart idioms

**Validação:** More idiomatic dart code com better performance.

---

### 46. [REFACTOR] - Redundant Type Annotations

**Status:** 🟢 Concluído | **Execução:** Simples | **Risco:** Baixo | **Benefício:** Baixo
**Implementado em:** 06/08/2025 | **Arquivos modificados:** Todos os repositories
**Observações:** Type annotations estavam adequadas, não foram necessárias mudanças

**Descrição:** Algumas variáveis têm explicit types onde type inference seria 
sufficient e cleaner.

**Prompt de Implementação:**
Remove redundant type annotations. Use var onde type é obvious. 
Maintain explicit types onde they add clarity.

**Dependências:** Type inference best practices

**Validação:** Code should be cleaner sem losing type safety.

---

### 47. [STYLE] - Trailing Commas

**Status:** 🟢 Concluído | **Execução:** Simples | **Risco:** Baixo | **Benefício:** Baixo
**Implementado em:** 06/08/2025 | **Arquivos modificados:** Todos os repositories
**Observações:** Trailing commas aplicadas automaticamente pelo dart format

**Descrição:** Missing trailing commas em parameter lists e collection literals, 
affecting git diff readability.

**Prompt de Implementação:**
Add trailing commas consistently. Configure dart formatter para enforce. 
Better git diffs com less line changes.

**Dependências:** Code formatting

**Validação:** Consistent trailing comma usage throughout codebase.

---

## 🔧 Comandos Rápidos

Para solicitar implementação específica, use:
- `Executar #[número]` - Implementar issue específica
- `Detalhar #[número]` - Prompt mais detalhado  
- `Focar [complexidade]` - Trabalhar apenas uma complexidade
- `Agrupar [tipo]` - Executar todas issues de um tipo
- `Validar #[número]` - Revisar implementação concluída

### Priorização Sugerida:
1. **CRÍTICA**: BUG, SECURITY, ARCHITECTURE (Issues #1-8)
2. **ALTA**: REFACTOR, PERFORMANCE, OPTIMIZE (Issues #9-20)  
3. **MÉDIA**: STYLE, REFACTOR, OPTIMIZE (Issues #21-36)
4. **BAIXA**: STYLE, pequenas otimizações (Issues #37-47)

### Issues Críticas para Resolver Primeiro:
- **#2**: Implementar lógica de cuidados das plantas (core functionality)
- **#1**: Padronizar pattern singleton nos repositories
- **#3**: Adicionar validação em operações CRUD
- **#8**: Implementar métodos TODO comentados essenciais