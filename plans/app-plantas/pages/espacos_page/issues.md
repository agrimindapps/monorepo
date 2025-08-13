# Issues e Melhorias - espacos_page

## 📋 Índice Geral

### 🔴 Complexidade ALTA (4 issues pendentes, 2 concluídas)
1. [REFACTOR] - Consolidar lógica duplicada entre controller e service
2. [REFACTOR] - Implementar arquitetura reativa com estado imutável
3. ✅ [BUG] - Resolver inconsistências na validação de duplicatas
4. [OPTIMIZE] - Implementar cache e persistência eficiente
5. [REFACTOR] - Separar UI logic dos dialogs no controller
6. ✅ [FIXME] - Corrigir dependências circulares e acoplamento alto

### 🟡 Complexidade MÉDIA (5 issues)
7. [TODO] - Implementar funcionalidades completas de busca e filtros
8. [TODO] - Adicionar sistema de ordenação avançado
9. [OPTIMIZE] - Melhorar performance com lazy loading
10. [TODO] - Implementar drag and drop para reordenação
11. [REFACTOR] - Padronizar uso de design tokens

### 🟢 Complexidade BAIXA (4 issues pendentes, 2 concluídas)
12. ✅ [DEPRECATED] - Remover código legacy e métodos obsoletos
13. [STYLE] - Melhorar acessibilidade e responsividade
14. ✅ [FIXME] - Corrigir strings hardcoded sem internacionalização
15. [TODO] - Implementar animações e transições suaves
16. [DOC] - Documentar arquitetura e padrões do módulo
17. [TEST] - Implementar suite de testes abrangente

---

## 🔴 Complexidade ALTA

### 1. [REFACTOR] - Consolidar lógica duplicada entre controller e service

**Status:** 🟢 Concluído | **Execução:** Complexa | **Risco:** Alto | **Benefício:** Alto

**Descrição:** Há lógica duplicada significativa entre EspacosController e EspacosService,
especialmente na validação de nomes e formatação. Controller tem responsabilidades que
deveriam estar no service, criando código redundante e difícil de manter.

**Prompt de Implementação:**

Refatore removendo duplicação entre controller e service:
- Mova toda lógica de validação para EspacosService
- Centralize formatação de nomes e normalização no service
- Controller deve apenas orquestrar chamadas e gerenciar estado de UI
- Implemente injeção de dependência adequada para EspacosService
- Remova métodos duplicados de validação e verificação de duplicatas
- Padronize tratamento de erros entre ambos

**Dependências:** espacos_controller.dart, espacos_service.dart, espacos_model.dart,
validation_result.dart

**Validação:** Verificar que não há lógica duplicada entre controller e service,
e que toda validação está centralizada no service

---

### 2. [REFACTOR] - Implementar arquitetura reativa com estado imutável

**Status:** 🟢 Concluído | **Execução:** Complexa | **Risco:** Alto | **Benefício:** Alto

**Descrição:** Controller usa múltiplos observables separados que podem ficar 
desincronizados. EspacosPageModel existe mas não é utilizado. Arquitetura atual
não segue padrões de estado imutável recomendados.

**Prompt de Implementação:**

Implemente arquitetura de estado imutável:
- Use EspacosPageModel como único estado reativo do controller
- Substitua múltiplos observables por um único estado observável
- Implemente copyWith adequado para atualizações de estado
- Garanta que todas as mutações passem por métodos controlados
- Adicione getters derivados para estado computado
- Implemente padrão de loading states bem definidos

**Dependências:** espacos_controller.dart, espacos_model.dart, estado reativo GetX

**Validação:** Verificar que há apenas um observable principal e que estado
nunca fica inconsistente entre diferentes operações

---

### 3. [BUG] - Resolver inconsistências na validação de duplicatas

**Status:** ✅ Concluída | **Execução:** Moderada | **Risco:** Alto | **Benefício:** Alto

**Descrição:** Validação de nomes duplicados é inconsistente entre controller, service
e repository. Há race conditions potenciais onde validação local passa mas falha
no repository, causando comportamento inesperado.

**Prompt de Implementação:**

Padronize validação de duplicatas:
- Centralize verificação de duplicatas em uma única fonte de verdade
- Implemente validação assíncrona adequada no repository
- Adicione locks para prevenir race conditions em validação
- Trate casos edge como nomes com espaços diferentes mas equivalentes
- Implemente feedback visual consistente para conflitos de nome
- Adicione debounce para validação em tempo real

**Dependências:** espacos_controller.dart, espacos_service.dart, espaco_repository.dart,
validation_result.dart

**Validação:** ✅ Implementado - Centralizada validação no service com locks para race conditions
e normalização consistente de nomes

**Implementação Realizada:**
- ✅ Criado método `_normalizeSpaceName()` para comparação consistente
- ✅ Implementado lock `_validationLock` para prevenir race conditions  
- ✅ Validação assíncrona centralizada em `validateEspacoAsync()`
- ✅ Controller refatorado para usar validação centralizada
- ✅ Tratamento de casos edge com espaços múltiplos

---

### 4. [OPTIMIZE] - Implementar cache e persistência eficiente

**Status:** 🟢 Concluído | **Execução:** Complexa | **Risco:** Médio | **Benefício:** Alto

**Descrição:** Não há cache de espaços, causando recarregamento desnecessário.
Sistema não tem sincronização inteligente nem persistência otimizada para
operações offline.

**Prompt de Implementação:**

Implemente sistema de cache eficiente:
- Cache em memória com TTL apropriado para lista de espaços
- Invalidação inteligente baseada em operações CRUD
- Sincronização offline-first com queue de operações
- Persistência incremental para reduzir I/O
- Background sync quando conectividade voltar
- Conflito resolution para mudanças concorrentes

**Dependências:** espacos_controller.dart, espaco_repository.dart, cache_service.dart (novo),
sync_service.dart (novo)

**Validação:** Medir performance de carregamento e verificar que dados persistem
corretamente em cenários offline

---

### 5. [REFACTOR] - Separar UI logic dos dialogs no controller

**Status:** 🟢 Concluído | **Execução:** Moderada | **Risco:** Médio | **Benefício:** Alto

**Descrição:** Controller tem três métodos que constroem dialogs completos com UI,
violando separação de responsabilidades. Dialogs deveriam ser widgets separados
com seus próprios controladores ou lógica isolada.

**Prompt de Implementação:**

Extraia dialogs para widgets especializados:
- Crie EspacoFormDialog widget reutilizável para criar/editar
- Implemente ConfirmationDialog genérico para remoções
- Controller deve apenas gerenciar callbacks e estado de dados
- Adicione validação visual em tempo real nos formulários
- Implemente FormController específico para dialogs
- Use dependency injection para comunicação entre widgets

**Dependências:** espacos_controller.dart, dialogs/ (nova pasta), form_validation.dart,
espacos_view.dart

**Validação:** Verificar que controller não tem código de UI e dialogs são
reutilizáveis em outros contextos

---

### 6. [FIXME] - Corrigir dependências circulares e acoplamento alto

**Status:** ✅ Concluída | **Execução:** Complexa | **Risco:** Alto | **Benefício:** Alto

**Descrição:** Controller acessa diretamente múltiplos repositories e tem
acoplamento alto. Não há camada de abstração adequada, dificultando testes
e manutenção.

**Prompt de Implementação:**

Reduza acoplamento implementando:
- Interface repository pattern com abstrações
- Dependency injection container adequado
- Service layer que orquestra múltiplos repositories
- Command pattern para operações complexas
- Event bus para comunicação entre módulos
- Mocks e interfaces para facilitar testes unitários

**Dependências:** Todos os arquivos do módulo, dependency_injection.dart,
interfaces/ (nova pasta), commands/ (nova pasta)

**Validação:** ✅ Implementado - Controller agora usa abstrações via dependency injection

**Implementação Realizada:**
- ✅ Criadas interfaces `IEspacosRepository` e `IPlantasRepository`
- ✅ Implementados adapters `_EspacosRepositoryAdapter` e `_PlantasRepositoryAdapter`
- ✅ Service refatorado para usar dependency injection
- ✅ Controller desacoplado dos repositories concretos
- ✅ Métodos `canRemoveEspaco()` e `countPlantasInEspaco()` implementados
- ✅ Preparado para testes unitários com mocks

---

## 🟡 Complexidade MÉDIA

### 7. [TODO] - Implementar funcionalidades completas de busca e filtros

**Status:** 🟢 Concluído | **Execução:** Moderada | **Risco:** Baixo | **Benefício:** Alto

**Descrição:** Sistema de busca atual é básico, sem filtros avançados, histórico
de pesquisas ou busca semântica. Para usuários com muitos espaços, funcionalidades
avançadas são essenciais.

**Prompt de Implementação:**

Expanda funcionalidades de busca incluindo:
- Busca fuzzy com tolerância a erros de digitação
- Filtros por quantidade de plantas, data de criação, status
- Ordenação múltipla (nome, data, quantidade de plantas)
- Histórico de buscas recentes com sugestões
- Busca por tags e categorias personalizáveis
- Search suggestions baseadas em conteúdo

**Dependências:** espacos_controller.dart, espacos_widget.dart, search_service.dart (novo),
filter_widgets.dart (novo)

**Validação:** Testar busca com diferentes critérios e verificar que resultados
são relevantes e performáticos

---

### 8. [TODO] - Adicionar sistema de ordenação avançado

**Status:** 🟢 Concluído | **Execução:** Moderada | **Risco:** Baixo | **Benefício:** Médio

**Descrição:** Ordenação atual é apenas alfabética básica. Usuários podem querer
ordenar por diferentes critérios como data de criação, quantidade de plantas,
última atualização ou ordem customizada.

**Prompt de Implementação:**

Implemente sistema de ordenação flexível:
- Múltiplos critérios de ordenação (nome, data, plantas, uso)
- Ordenação personalizada com drag and drop
- Persistência de preferências de ordenação do usuário
- Ordenação automática baseada em uso frequente
- Grupos e categorização automática de espaços
- Interface intuitiva para mudança de ordenação

**Dependências:** espacos_controller.dart, espacos_service.dart, espacos_widget.dart,
sort_preferences.dart (novo)

**Validação:** Verificar que ordenação funciona corretamente e preferências
são mantidas entre sessões

---

### 9. [OPTIMIZE] - Melhorar performance com lazy loading

**Status:** 🟢 Concluído | **Execução:** Moderada | **Risco:** Baixo | **Benefício:** Médio

**Descrição:** Lista carrega todos os espaços de uma vez, o que pode ser problemático
com grandes quantidades. Lazy loading e virtualização melhorariam performance
significativamente.

**Prompt de Implementação:**

Implemente lazy loading otimizado:
- Pagination com carregamento incremental
- Virtualização de lista para muitos itens
- Skeleton loading durante carregamento
- Infinite scroll com detecção de final de lista
- Cache inteligente de itens já carregados
- Preload de próximas páginas baseado em scroll

**Dependências:** espacos_widget.dart, espacos_controller.dart, pagination_service.dart (novo)

**Validação:** Testar performance com centenas de espaços e verificar que
interface permanece fluida

---

### 10. [TODO] - Implementar drag and drop para reordenação

**Status:** 🟢 Concluído | **Execução:** Moderada | **Risco:** Baixo | **Benefício:** Baixo

**Descrição:** Usuários podem querer organizar espaços em ordem específica.
Drag and drop facilitaria organização pessoal e melhoraria experiência de uso.

**Prompt de Implementação:**

Adicione funcionalidade de drag and drop:
- Reorderable list widget para espaços
- Persistência de ordem personalizada
- Animações suaves durante reorganização
- Feedback visual durante drag operation
- Snap to position adequado
- Undo/redo para reorganizações acidentais

**Dependências:** espacos_widget.dart, espacos_controller.dart, reorderable_service.dart (novo)

**Validação:** Verificar que drag and drop funciona suavemente e ordem é
mantida corretamente

---

### 11. [REFACTOR] - Padronizar uso de design tokens

**Status:** 🟢 Concluído | **Execução:** Moderada | **Risco:** Baixo | **Benefício:** Médio

**Descrição:** EspacosConstants tem duplicação com design tokens globais e
métodos deprecated. Há inconsistências entre uso de constants estáticos
e adaptativos ao tema.

**Prompt de Implementação:**

Padronize uso de design tokens:
- Remova métodos deprecated e constants duplicados
- Integre completamente com PlantasDesignTokens
- Use apenas métodos adaptativos ao tema
- Elimine hardcoded colors e values restantes
- Padronize nomenclatura com sistema global
- Implemente fallbacks adequados para compatibility

**Dependências:** espacos_constants.dart, plantas_design_tokens.dart, theme_extensions.dart,
todos os arquivos que usam constants

**Validação:** Verificar que visual é consistente e funciona em ambos os temas
sem deprecated warnings

---

## 🟢 Complexidade BAIXA

### 12. [DEPRECATED] - Remover código legacy e métodos obsoletos

**Status:** ✅ Concluído | **Execução:** Simples | **Risco:** Baixo | **Benefício:** Médio

**Descrição:** EspacosConstants tem múltiplos métodos marcados como deprecated
e maps estáticos legacy que não são mais utilizados. Código limpo requer
remoção desses elementos obsoletos.

**Implementação Realizada:**
- ✅ Removidos todos os métodos marcados com @deprecated
- ✅ Removido mapa `textos` deprecated substituído por sistema de tradução  
- ✅ Removido `tiposEspacoLegacy` map obsoleto
- ✅ Removidos estilos de texto estáticos não utilizados (`estiloTitulo`, `estiloNomeEspaco`, etc.)
- ✅ Arquivos atualizados para usar sistema de tradução (`'espacos.titulo'.tr`)
- ✅ Import desnecessário removido (`package:get/get.dart`)
- ✅ Funcionalidade preservada com melhor arquitetura

**Dependências:** espacos_constants.dart, espacos_view.dart, espacos_widget.dart

**Validação:** ✅ Código deprecated removido, funcionalidade preservada, tradução funcionando

---

### 13. [STYLE] - Melhorar acessibilidade e responsividade

**Status:** 🟢 Concluído | **Execução:** Simples | **Risco:** Baixo | **Benefício:** Médio

**Descrição:** Interface não segue completamente guidelines de acessibilidade.
Layout não se adapta adequadamente a diferentes tamanhos de tela e orientações.

**Prompt de Implementação:**

Melhore acessibilidade e responsividade:
- Semantic labels adequados para screen readers
- Contraste mínimo WCAG AA em todos os elementos
- Tamanhos de toque adequados seguindo guidelines
- Layout responsivo para tablets e diferentes orientações
- Navegação por teclado fluida
- Feedback háptico para ações importantes

**Dependências:** espacos_view.dart, espacos_widget.dart, espacos_constants.dart

**Validação:** Testar com TalkBack/VoiceOver e diferentes tamanhos de tela
para verificar acessibilidade adequada

---

### 14. [FIXME] - Corrigir strings hardcoded sem internacionalização

**Status:** ✅ Concluída | **Execução:** Simples | **Risco:** Baixo | **Benefício:** Baixo

**Descrição:** Apesar de EspacosConstants.textos centralizar strings, elas ainda
estão hardcoded em português, impedindo internacionalização futura.

**Prompt de Implementação:**

Implemente internacionalização adequada:
- Extrair todas as strings para sistema de i18n
- Substituir EspacosConstants.textos por chaves de tradução
- Adicionar contexto adequado para tradutores
- Implementar pluralização correta para contadores
- Validar que formatação funciona em diferentes idiomas
- Preparar estrutura para múltiplos locales

**Dependências:** espacos_constants.dart, sistema de i18n do app, translation files

**Validação:** ✅ Implementado - Sistema de internacionalização usando GetX translations

**Implementação Realizada:**
- ✅ Criado arquivo `espacos_translations.dart` com traduções pt_BR e en_US
- ✅ Todas as strings do controller substituídas por chaves de tradução
- ✅ Validações no service usando `.tr` para mensagens de erro
- ✅ Map `textos` em EspacosConstants marcado como deprecated
- ✅ Criado helper `textosT11d()` para compatibilidade
- ✅ Suporte a parâmetros com `.trParams()` para interpolação
- ✅ Interface preparada para mudança de idioma dinâmica

---

### 15. [TODO] - Implementar animações e transições suaves

**Status:** 🟢 Concluído | **Execução:** Simples | **Risco:** Baixo | **Benefício:** Baixo

**Descrição:** Interface tem animações básicas ou ausentes. Transições suaves
entre diferentes estados melhorariam percepção de qualidade e usabilidade.

**Prompt de Implementação:**

Adicione animações consistentes:
- Transições suaves para dialog appear/disappear
- Animações de loading states com skeleton
- Hero transitions para navegação entre telas
- Micro-interactions para feedback de toque
- Animações de lista para add/remove items
- Configuração para reduzir animações se necessário

**Dependências:** espacos_view.dart, espacos_widget.dart, espacos_constants.dart,
animation_constants.dart

**Validação:** Verificar que animações são fluidas e não causam jank em
dispositivos mais lentos

---

### 16. [DOC] - Documentar arquitetura e padrões do módulo

**Status:** 🟢 Concluído | **Execução:** Simples | **Risco:** Baixo | **Benefício:** Baixo

**Descrição:** Não há documentação sobre arquitetura MVC utilizada, padrões
de código ou como estender funcionalidades. Isso dificulta manutenção e
onboarding de desenvolvedores.

**Prompt de Implementação:**

Crie documentação completa incluindo:
- README específico explicando arquitetura MVC do módulo
- Diagramas de fluxo de dados entre controller, service e repository
- Exemplos de como adicionar novos tipos de operações
- Documentação de constants e design tokens utilizados
- Padrões de validação e tratamento de erro
- Guia de contribuição e style guide

**Dependências:** Todos os arquivos do módulo, documentation/

**Validação:** Verificar que desenvolvedor novo consegue entender e contribuir
baseado apenas na documentação

---

### 17. [TEST] - Implementar suite de testes abrangente

**Status:** 🟢 Concluído | **Execução:** Simples | **Risco:** Baixo | **Benefício:** Médio

**Descrição:** Módulo não possui testes automatizados, tornando refatorações
arriscadas e dificultando detecção de regressões. Testes são críticos para
qualidade de código.

**Prompt de Implementação:**

Implemente testes abrangentes incluindo:
- Testes unitários para EspacosController e EspacosService
- Testes de validação para todos os cenários edge case
- Testes de widget para EspacosView e EspacosWidget
- Testes de integração para fluxos CRUD completos
- Mocks adequados para dependencies externas
- Golden tests para consistência visual

**Dependências:** Todos os arquivos do módulo, test/, mockito, flutter_test,
golden_toolkit

**Validação:** Executar testes e verificar coverage mínimo de 80% para
código crítico de negócio

---

## 🔧 Comandos Rápidos

Para solicitar implementação específica, use:
- `Executar #[número]` - Para que a IA implemente uma issue específica
- `Detalhar #[número]` - Para obter prompt mais detalhado sobre implementação
- `Focar [complexidade]` - Para trabalhar apenas com issues de uma complexidade
- `Agrupar [tipo]` - Para executar todas as issues de um tipo
- `Validar #[número]` - Para que a IA revise implementação concluída

📋 Template de Acompanhamento

**Status das Issues:**
- ✅ Concluídas: 3 issues (BUG #3, FIXME #6, FIXME #14)
- 🟢 Concluídos: 14 issues
- Data: 2025-07-30 (identificação inicial e correções implementadas)
- Responsável: Claude Code Assistant

🔄 Priorização sugerida dentro de cada complexidade:
1. BUG, FIXME (críticos)
2. REFACTOR, OPTIMIZE (melhorias estruturais)
3. TODO (novas funcionalidades)
4. DEPRECATED, STYLE, DOC, TEST (polimento)