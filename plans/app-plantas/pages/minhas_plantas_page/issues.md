# Issues e Melhorias - minhas_plantas_page

## 📋 Índice Geral

### 🔴 Complexidade ALTA (7 issues)
1. ✅ [REFACTOR] - Resolver herança problemática de PlantasController
2. [OPTIMIZE] - Implementar cache inteligente para FutureBuilder repetitivo
3. ✅ [BUG] - Corrigir rebuild excessivo em PlantCardWidget
4. ✅ [REFACTOR] - Consolidar lógica duplicada entre constants e design tokens
5. [PERFORMANCE] - Otimizar carregamento assíncrono de tarefas pendentes
6. ✅ [REFACTOR] - Separar responsabilidades do controller complexo
7. ✅ [FIXME] - Resolver inconsistências na gestão de estado reativo

### 🟡 Complexidade MÉDIA (5 issues)
8. [TODO] - Implementar funcionalidades avançadas de visualização
9. [TODO] - Adicionar sistema de filtros e ordenação inteligente
10. [OPTIMIZE] - Melhorar performance com lazy loading e virtualização
11. [TODO] - Implementar sistema de seleção múltipla
12. ✅ [REFACTOR] - Padronizar widgets com design system consistente

### 🟢 Complexidade BAIXA (5 issues pendentes, 2 concluídas)
13. ✅ [DEPRECATED] - Remover código legacy e métodos obsoletos
14. [STYLE] - Melhorar acessibilidade e responsividade
15. ✅ [FIXME] - Corrigir strings hardcoded sem internacionalização
16. [TODO] - Implementar animações e micro-interações
17. [DOC] - Documentar arquitetura de widgets especializados
18. [TEST] - Implementar testes para components complexos

---

## 🔴 Complexidade ALTA

### 1. [REFACTOR] - Resolver herança problemática de PlantasController

**Status:** ✅ Concluído | **Execução:** Complexa | **Risco:** Alto | **Benefício:** Alto

**Descrição:** MinhasPlantasController herda de PlantasController mas adiciona apenas
poucos métodos. Herança cria acoplamento desnecessário e dificulta manutenção.
Controller pai tem responsabilidades muito amplas.

**Prompt de Implementação:**

Refatore arquitetura de controllers:  
- Substitua herança por composição usando services especializados
- Crie PlantasService para lógica de negócio reutilizável
- MinhasPlantasController deve ter apenas responsabilidades específicas da view
- Implemente interfaces claras para comunicação entre components
- Use dependency injection para desacoplar controllers
- Mantenha estado local isolado por funcionalidade

**Dependências:** minhas_plantas_controller.dart, plantas_controller.dart,
plantas_service.dart (novo), dependency_injection.dart

**Validação:** Verificar que MinhasPlantasController não herda de outro controller
e que funcionalidade permanece inalterada

---

### 2. [OPTIMIZE] - Implementar cache inteligente para FutureBuilder repetitivo

**Status:** 🔴 Pendente | **Execução:** Complexa | **Risco:** Médio | **Benefício:** Alto

**Descrição:** Cada PlantCardWidget executa FutureBuilder individual para carregar
tarefas pendentes, causando múltiplas queries desnecessárias e impacto significativo
na performance da lista.

**Prompt de Implementação:**

Implemente sistema de cache para tarefas:
- Cache centralizado de tarefas pendentes por planta com TTL
- Pre-loading de tarefas para todas as plantas visíveis
- Invalidação seletiva quando tarefas são atualizadas
- Background refresh para manter dados sincronizados
- Fallback para dados cached em caso de erro de rede
- Batch loading para otimizar queries de banco

**Dependências:** plant_card_widget.dart, minhas_plantas_controller.dart,
cache_service.dart (novo), task_cache_manager.dart (novo)

**Validação:** Medir queries de banco antes e depois, verificar que performance
da lista melhora significativamente

---

### 3. [BUG] - Corrigir rebuild excessivo em PlantCardWidget

**Status:** ✅ Concluído | **Execução:** Moderada | **Risco:** Alto | **Benefício:** Alto

**Descrição:** PlantCardWidget reconstrói completamente a cada mudança de estado
do controller, incluindo FutureBuilder que reexecuta desnecessariamente. Causa
lag visível em listas grandes.

**Prompt de Implementação:**

Otimize rebuilds do PlantCardWidget:
- Use keys específicas para evitar reconstrução desnecessária
- Separe estado local do widget do estado global
- Implemente memoization para widgets caros
- Use const constructors onde possível
- Evite closures que capturam contexto desnecessário
- Profile com Flutter Inspector para validar otimizações

**Dependências:** plant_card_widget.dart, task_status_widget.dart,
plant_header_widget.dart

**Validação:** Usar Flutter Inspector para confirmar redução de rebuilds
e medir performance em listas com 50+ plantas

---

### 4. [REFACTOR] - Consolidar lógica duplicada entre constants e design tokens

**Status:** ✅ Concluído | **Execução:** Complexa | **Risco:** Médio | **Benefício:** Alto

**Descrição:** MinhasPlantasConstants duplica muita lógica de PlantasDesignTokens
e mantém código deprecated. Há inconsistências entre diferentes métodos de
obter cores e estilos.

**Prompt de Implementação:**

Consolide sistema de design tokens:
- Remova toda duplicação entre constants e design tokens globais
- Use apenas PlantasDesignTokens como fonte única de verdade
- Elimine métodos deprecated e fallbacks legados
- Padronize nomenclatura e estrutura com sistema global
- Implemente factory methods específicos do módulo se necessário
- Garanta consistência visual em ambos os temas

**Dependências:** minhas_plantas_constants.dart, plantas_design_tokens.dart,
theme_extensions.dart, todos os widgets que usam constants

**Validação:** Verificar que não há warnings de deprecated e que visual
permanece consistente após refatoração

---

### 5. [PERFORMANCE] - Otimizar carregamento assíncrono de tarefas pendentes

**Status:** 🔴 Pendente | **Execução:** Complexa | **Risco:** Médio | **Benefício:** Alto

**Descrição:** Sistema atual carrega tarefas pendentes individualmente para cada
planta, criando gargalo de performance. Não há otimização de carregamento nem
estratégia de priorização.

**Prompt de Implementação:**

Otimize carregamento de tarefas implementando:
- Batch loading de tarefas para múltiplas plantas simultaneamente
- Lazy loading baseado em scroll position da lista
- Priorização de carregamento para plantas visíveis
- Background prefetch para plantas próximas do viewport
- Debounce para evitar requests excessivos durante scroll
- Pooling de conexões para otimizar I/O

**Dependências:** plantas_controller.dart, simple_task_service.dart,
plant_card_widget.dart, task_loading_service.dart (novo)

**Validação:** Medir tempo de carregamento inicial e scroll performance
com diferentes quantidades de plantas

---

### 6. [REFACTOR] - Separar responsabilidades do controller complexo

**Status:** ✅ Concluído | **Execução:** Complexa | **Risco:** Alto | **Benefício:** Alto

**Descrição:** PlantasController base tem muitas responsabilidades misturadas:
gestão de estado, carregamento de dados, navegação, busca e filtros. Viola
princípio de responsabilidade única.

**Implementação Realizada:**

Refatoração completa com separação de responsabilidades:
- ✅ **PlantasStateService**: Gestão de estado reativo centralizada com singleton pattern
- ✅ **PlantasDataService**: Serviço especializado para carregamento e sincronização de dados
- ✅ **PlantasSearchService**: Lógica de busca, filtros e sugestões com histórico
- ✅ **PlantasTaskService**: Operações com tarefas e conversão de modelos para compatibilidade
- ✅ **PlantasNavigationService**: Coordenação de navegação com singleton pattern
- ✅ **PlantasController**: Refatorado para composição usando todos os services especializados
- ✅ **Dependency Injection**: Inicialização automática de services com Get.put()
- ✅ **Delegate Methods**: Métodos legados mantidos para compatibilidade, delegando para services

**Dependências:** plantas_controller.dart (refatorado), 
services/plantas_state_service.dart, services/plantas_data_service.dart,
services/plantas_search_service.dart, services/plantas_task_service.dart,
services/plantas_navigation_service.dart

**Validação:** ✅ Controller principal com 138 linhas, cada service com responsabilidade específica, 
arquitetura baseada em composição em vez de herança, mantém compatibilidade total

---

### 7. [FIXME] - Resolver inconsistências na gestão de estado reativo

**Status:** ✅ Concluído | **Execução:** Moderada | **Risco:** Alto | **Benefício:** Alto

**Descrição:** Estado reativo é inconsistente entre plantas, plantasComTarefas
e outros observables. Mudanças nem sempre são propagadas corretamente para
todos os consumers.

**Prompt de Implementação:**

Padronize gestão de estado reativo:
- Single source of truth para dados de plantas
- Sincronização automática entre diferentes views dos dados
- Computed properties para estado derivado
- Propagação consistente de mudanças
- Transaction-based updates para evitar estados intermediários
- Error boundaries para falhas de sincronização

**Dependências:** plantas_controller.dart, minhas_plantas_controller.dart,
todos os widgets que observam estado

**Validação:** Verificar que mudanças são propagadas consistentemente
e não há dessincronia entre diferentes observables

---

## 🟡 Complexidade MÉDIA

### 8. [TODO] - Implementar funcionalidades avançadas de visualização

**Status:** 🔴 Pendente | **Execução:** Moderada | **Risco:** Baixo | **Benefício:** Alto

**Descrição:** Sistema atual tem apenas visualização básica em lista/grid.
Funcionalidades avançadas como agrupamento, categorização e layouts customizados
melhorariam significativamente a experiência do usuário.

**Prompt de Implementação:**

Implemente visualizações avançadas incluindo:
- Agrupamento por espaço, espécie ou status de cuidados
- Layout de timeline mostrando cronologia de cuidados
- Visualização de calendário com tarefas por data
- Cards expandíveis com informações detalhadas
- Densidade de visualização ajustável (compacta/detalhada)
- Personalização de layout salva por usuário

**Dependências:** minhas_plantas_view.dart, plant_card_widget.dart,
view_mode_service.dart (novo), layout_widgets/ (nova pasta)

**Validação:** Testar diferentes modos de visualização e verificar que
preferências são mantidas entre sessões

---

### 9. [TODO] - Adicionar sistema de filtros e ordenação inteligente

**Status:** 🔴 Pendente | **Execução:** Moderada | **Risco:** Baixo | **Benefício:** Alto

**Descrição:** Sistema de busca atual é básico, sem filtros avançados ou
ordenação inteligente. Para usuários com muitas plantas, funcionalidades
avançadas são essenciais para organização.

**Prompt de Implementação:**

Implemente sistema de filtros robusto:
- Filtros por espaço, espécie, status de saúde e data de plantio
- Ordenação múltipla com critérios combinados
- Filtros salvos como favoritos para reutilização
- Busca semântica com sugestões inteligentes
- Filtros rápidos baseados em uso frequente
- Interface intuitiva com chips removíveis

**Dependências:** minhas_plantas_controller.dart, minhas_plantas_view.dart,
filter_service.dart (novo), filter_widgets/ (nova pasta)

**Validação:** Testar combinações complexas de filtros e verificar que
resultados são relevantes e rápidos

---

### 10. [OPTIMIZE] - Melhorar performance com lazy loading e virtualização

**Status:** 🔴 Pendente | **Execução:** Moderada | **Risco:** Baixo | **Benefício:** Médio

**Descrição:** Lista carrega todas as plantas de uma vez, causando problemas
de performance com grandes coleções. Lazy loading e virtualização são necessários
para escalabilidade.

**Prompt de Implementação:**

Implemente lazy loading otimizado:
- Virtualização de lista para grandes quantidades de plantas
- Paginação inteligente baseada em scroll
- Skeleton loading durante carregamento incremental
- Preload de próximas páginas baseado em velocidade de scroll
- Cache de itens renderizados para scroll reverso
- Otimização de memória com garbage collection de itens fora do viewport

**Dependências:** minhas_plantas_view.dart, plant_card_widget.dart,
virtualization_service.dart (novo)

**Validação:** Testar performance com centenas de plantas e verificar que
scroll permanece fluido

---

### 11. [TODO] - Implementar sistema de seleção múltipla

**Status:** 🔴 Pendente | **Execução:** Moderada | **Risco:** Baixo | **Benefício:** Médio

**Descrição:** Usuários com muitas plantas precisam de operações em lote como
remoção múltipla, atualização em massa ou organização por categorias. Sistema
atual requer operações individuais.

**Prompt de Implementação:**

Adicione seleção múltipla com operações em lote:
- Modo de seleção com checkboxes visuais
- Actions bar com operações disponíveis para seleção
- Remoção em lote com confirmação inteligente
- Atualização em massa de propriedades comuns
- Exportação de dados selecionados
- Desfazer operações em lote acidentais

**Dependências:** minhas_plantas_view.dart, plant_card_widget.dart,
selection_service.dart (novo), batch_operations_service.dart (novo)

**Validação:** Testar operações em lote com diferentes quantidades de plantas
e verificar que confirmações são adequadas

---

### 12. [REFACTOR] - Padronizar widgets com design system consistente

**Status:** ✅ Concluído | **Execução:** Moderada | **Risco:** Baixo | **Benefício:** Médio

**Descrição:** Widgets têm estilos inconsistentes entre si e com outros módulos.
Alguns usam hardcoded values, outros design tokens, criando inconsistência
visual.

**Implementação Realizada:**

Padronização completa dos widgets com design system:
- ✅ **TaskItemWidget**: Substituído cores hardcoded por PlantasDesignTokens.cores(), dimensões por design tokens, textStyles consistentes
- ✅ **NoPlantsWidget**: Eliminado valores hardcoded de cores, espaçamentos e tipografia, usando sistema de design adaptável ao tema
- ✅ **NoResultsWidget**: Cores, dimensões e estilos padronizados com design tokens, container de dica usando tokens semânticos
- ✅ **PlantCardWidget**: Removido static constants hardcoded, usando dimensões e elevações do design system
- ✅ **TaskStatusWidget**: Containers de status usando cores semânticas (sucessoClaro, avisoClaro), dimensões e textStyles consistentes
- ✅ **PlantHeaderWidget**: Refatorado para usar design tokens, eliminado referências ao MinhasPlantasConstants deprecated
- ✅ **PlantActionsMenu**: Ícones, cores e espaçamentos usando design tokens, eliminado valores hardcoded
- ✅ **PlantGridCardWidget**: Padronizado com design tokens, componente de status compacto usando sistema semântico

**Dependências:** task_item_widget.dart, no_plants_widget.dart, no_results_widget.dart,
plant_card_widget.dart, task_status_widget.dart, plant_header_widget.dart,
plant_actions_menu.dart, plant_grid_card_widget.dart, plantas_design_tokens.dart

**Validação:** ✅ Todos os widgets usam apenas PlantasDesignTokens, eliminados valores hardcoded,
consistência visual garantida entre temas claro/escuro, espaçamentos e tipografia padronizados

---

## 🟢 Complexidade BAIXA

### 13. [DEPRECATED] - Remover código legacy e métodos obsoletos

**Status:** ✅ Concluído | **Execução:** Simples | **Risco:** Baixo | **Benefício:** Médio

**Descrição:** MinhasPlantasConstants tem múltiplos métodos deprecated e maps
legados que não são mais utilizados. Limpeza é necessária para manter
código base saudável.

**Implementação Realizada:**
- ✅ Removido método `corPrimaria()` redundante que apenas delegava para PlantasDesignTokens
- ✅ Widgets atualizados para usar `MinhasPlantasConstants.cores(context)['primaria']` diretamente
- ✅ Substituída toda lógica duplicada por delegação para PlantasDesignTokens
- ✅ Arquitetura consolidada eliminando duplicação entre constants e design tokens
- ✅ Constants já otimizados usando composição em vez de herança problemática
- ✅ Verificação confirmou ausência de código deprecated adicional

**Dependências:** minhas_plantas_constants.dart, plant_header_widget.dart, plant_grid_card_widget.dart

**Validação:** ✅ Método redundante removido, widgets funcionando corretamente, arquitetura melhorada

---

### 14. [STYLE] - Melhorar acessibilidade e responsividade

**Status:** 🔴 Pendente | **Execução:** Simples | **Risco:** Baixo | **Benefício:** Médio

**Descrição:** Interface não segue completamente guidelines de acessibilidade.
Layout não se adapta adequadamente a diferentes tamanhos de tela, especialmente
em modo paisagem e tablets.

**Prompt de Implementação:**

Melhore acessibilidade e responsividade:
- Semantic labels adequados para screen readers
- Contraste mínimo WCAG AA em todos os elementos
- Tamanhos de toque seguindo Material Design guidelines
- Layout responsivo para diferentes orientações
- Navegação por teclado fluida entre cards
- Feedback háptico para ações importantes

**Dependências:** minhas_plantas_view.dart, todos os widgets da pasta,
minhas_plantas_constants.dart

**Validação:** Testar com TalkBack/VoiceOver ativado e diferentes tamanhos
de tela para verificar acessibilidade adequada

---

### 15. [FIXME] - Corrigir strings hardcoded sem internacionalização

**Status:** ✅ Concluído | **Execução:** Simples | **Risco:** Baixo | **Benefício:** Baixo

**Descrição:** Apesar de MinhasPlantasConstants centralizar strings, elas ainda
estão hardcoded em português, impedindo internacionalização futura. Alguns
widgets têm strings inline.

**Prompt de Implementação:**

Implemente internacionalização adequada:
- Extrair todas as strings para sistema de i18n do Flutter
- Substituir MinhasPlantasConstants.textos por chaves de localização
- Corrigir strings inline em PlantActionsMenu e outros widgets
- Implementar pluralização correta para contadores
- Adicionar contexto adequado para tradutores
- Preparar estrutura para múltiplos idiomas

**Dependências:** minhas_plantas_constants.dart, plant_actions_menu.dart,
task_status_widget.dart, sistema de i18n do app

**Validação:** Verificar que todas as strings vêm de sistema de tradução
e mudança de idioma funciona corretamente

---

### 16. [TODO] - Implementar animações e micro-interações

**Status:** 🔴 Pendente | **Execução:** Simples | **Risco:** Baixo | **Benefício:** Baixo

**Descrição:** Interface tem animações básicas ou ausentes. Micro-interações
e transições suaves melhorariam significativamente a percepção de qualidade
e engajamento do usuário.

**Prompt de Implementação:**

Adicione animações e micro-interações:
- Hero transitions para navegação entre plantas
- Animações de loading com skeleton em cards
- Micro-feedback para toques e interactions
- Transições suaves entre modos de visualização
- Animações de entrada/saída para cards em listas
- Configurações para reduzir motion se necessário

**Dependências:** plant_card_widget.dart, minhas_plantas_view.dart,
animation_constants.dart (novo)

**Validação:** Verificar que animações são fluidas e não causam jank
em dispositivos mais lentos

---

### 17. [DOC] - Documentar arquitetura de widgets especializados

**Status:** 🔴 Pendente | **Execução:** Simples | **Risco:** Baixo | **Benefício:** Baixo

**Descrição:** Não há documentação sobre arquitetura de widgets especializada
utilizada, padrões de composição ou como estender funcionalidades. Dificulta
manutenção e onboarding.

**Prompt de Implementação:**

Crie documentação abrangente incluindo:
- README específico do módulo explicando arquitetura de widgets  
- Diagramas de composição entre widgets especializados
- Exemplos de como criar novos tipos de cards
- Documentação de props e callbacks de cada widget
- Padrões de estado management entre widgets
- Style guide para manter consistência visual

**Dependências:** Todos os widgets da pasta, documentation/

**Validação:** Verificar que desenvolvedor novo consegue criar widgets
similares baseado apenas na documentação

---

### 18. [TEST] - Implementar testes para components complexos

**Status:** 🔴 Pendente | **Execução:** Simples | **Risco:** Baixo | **Benefício:** Médio

**Descrição:** Módulo não possui testes automatizados, especialmente para
widgets complexos como PlantCardWidget que tem lógica assíncrona. Testes
são críticos para garantir qualidade.

**Prompt de Implementação:**

Implemente testes abrangentes incluindo:
- Widget tests para todos os components principais
- Testes de integração para fluxos completos
- Mock tests para FutureBuilder em PlantCardWidget  
- Golden tests para consistência visual
- Testes de acessibilidade automatizados
- Performance tests para scroll de listas grandes

**Dependências:** Todos os widgets e controllers, test/, mockito,
flutter_test, golden_toolkit

**Validação:** Executar testes e verificar coverage mínimo de 80% para
widgets críticos com lógica complexa

---

## 🔧 Comandos Rápidos

Para solicitar implementação específica, use:
- `Executar #[número]` - Para que a IA implemente uma issue específica
- `Detalhar #[número]` - Para obter prompt mais detalhado sobre implementação
- `Focar [complexidade]` - Para trabalhar apenas com issues de uma complexidade
- `Agrupar [tipo]` - Para executar todas as issues de um tipo
- `Validar #[número]` - Para que a IA revise implementação concluída

📋 Template de Acompanhamento

Todas as issues estão marcadas como:
- Status: 🔴 Pendente
- Data: 2025-07-30 (identificação inicial)
- Responsável: A definir

🔄 Priorização sugerida dentro de cada complexidade:
1. BUG, FIXME (críticos)
2. REFACTOR, OPTIMIZE (melhorias estruturais)
3. TODO (novas funcionalidades)
4. DEPRECATED, STYLE, DOC, TEST (polimento)