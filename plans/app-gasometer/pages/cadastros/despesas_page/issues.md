# Issues e Melhorias - Módulo de Despesas (Gasômetro)

## 📋 Índice Geral

### 🔴 Complexidade ALTA (7 issues)
1. [REFACTOR] - Reestruturação do controller proxy problemático
2. [BUG] - Gestão inadequada do ciclo de vida dos controllers GetX
3. [REFACTOR] - Duplicação de lógica entre controller e model
4. [SECURITY] - Ausência de validação adequada de estados críticos
5. [OPTIMIZE] - Processamento ineficiente de dados agrupados mensalmente
6. [REFACTOR] - Separação inadequada de responsabilidades no controller
7. [BUG] - Dependência circular e acoplamento forte entre repositórios

### 🟡 Complexidade MÉDIA (5 issues)
8. [REFACTOR] - Lógica de formatação espalhada entre componentes
9. [OPTIMIZE] - Carousel sem otimização para grandes datasets
10. [TODO] - Sistema de cache ausente para dados estáticos
11. [REFACTOR] - Extensão customizada misturada com lógica de negócio
12. [STYLE] - Inconsistências no padrão de nomenclatura de métodos

### 🟢 Complexidade BAIXA (6 issues)
13. [DOC] - Documentação ausente nos métodos públicos
14. [REFACTOR] - Métodos utilitários poderiam ser extraídos para helpers
15. [OPTIMIZE] - Rebuild desnecessário em operações de estado
16. [STYLE] - Magic numbers e strings hardcoded
17. [TEST] - Ausência de testes unitários para lógica de negócio
18. [REFACTOR] - Model com responsabilidades mistas

---

## 🔴 Complexidade ALTA

### 1. [REFACTOR] - Reestruturação do controller proxy problemático

**Status:** 🔴 Pendente | **Execução:** Complexa | **Risco:** Alto | **Benefício:** Alto

**Descrição:** DespesasPageController atua como proxy para DespesasListaController, 
criando camada desnecessária de abstração que gera overhead e dificulta 
manutenção. O controller principal delega praticamente todas as operações 
para outro controller, violando princípios de arquitetura limpa.

**Prompt de Implementação:**
```
Refatore a arquitetura removendo o padrão proxy problemático. Integre 
diretamente as funcionalidades necessárias no DespesasPageController 
ou crie services específicos. Implemente injeção de dependência adequada 
e remova a dependência circular entre controllers. Mantenha interfaces 
claras e responsabilidades bem definidas.
```

**Dependências:** DespesasPageController, DespesasListaController, 
DespesasRepository, VeiculosRepository, sistema de injeção de dependência

**Validação:** Controller funciona independentemente, não há delegação 
desnecessária, performance melhora, e código fica mais manutenível

---

### 2. [BUG] - Gestão inadequada do ciclo de vida dos controllers GetX

**Status:** 🔴 Pendente | **Execução:** Moderada | **Risco:** Alto | **Benefício:** Alto

**Descrição:** Método _ensureRepositoriesRegistered registra controllers 
como permanent sem estratégia de cleanup, causando vazamentos de memória. 
Controllers são registrados condicionalmente mas nunca removidos, 
acumulando instâncias desnecessárias.

**Prompt de Implementação:**
```
Implemente gestão adequada do ciclo de vida dos controllers GetX. Remova 
flag permanent desnecessária, implemente cleanup automático no dispose, 
e use padrão de inicialização lazy loading. Adicione verificações de 
integridade e logs para debugging do gerenciamento de memória.
```

**Dependências:** DespesasPageController, sistema de injeção GetX, 
dispose methods dos widgets

**Validação:** Não há vazamentos de memória, controllers são limpos 
adequadamente, e inicialização é eficiente

---

### 3. [REFACTOR] - Duplicação de lógica entre controller e model

**Status:** 🔴 Pendente | **Execução:** Moderada | **Risco:** Médio | **Benefício:** Alto

**Descrição:** DespesasPageModel e DespesasPageController possuem métodos 
duplicados como generateMonthsList, getDespesasForMonth, e cálculos 
estatísticos. Essa duplicação gera inconsistências e dificulta manutenção 
do código.

**Prompt de Implementação:**
```
Consolide lógica duplicada movendo cálculos complexos para o model e 
mantendo apenas coordenação de UI no controller. Crie interfaces claras 
entre model e controller. Implemente factory methods no model para 
operações complexas e remova duplicação de código.
```

**Dependências:** DespesasPageModel, DespesasPageController, métodos 
de formatação e cálculo

**Validação:** Não há duplicação de lógica, model concentra regras de 
negócio, e controller foca apenas em coordenação

---

### 4. [SECURITY] - Ausência de validação adequada de estados críticos

**Status:** 🔴 Pendente | **Execução:** Moderada | **Risco:** Alto | **Benefício:** Alto

**Descrição:** Sistema não valida adequadamente estados críticos como 
veículo selecionado válido, dados corrompidos no cache, ou falhas de 
sincronização. Try-catch genérico apenas loga erros sem tratamento 
específico ou recuperação.

**Prompt de Implementação:**
```
Implemente validação robusta de estados críticos com recuperação 
automática. Adicione verificação de integridade de dados, validação 
de veículo selecionado, e tratamento específico para diferentes tipos 
de erro. Crie sistema de fallback para estados inválidos.
```

**Dependências:** Sistema de validação, error handling, recovery mechanisms

**Validação:** Estados inválidos são detectados e corrigidos, sistema 
se recupera automaticamente de falhas, e usuário recebe feedback adequado

---

### 5. [OPTIMIZE] - Processamento ineficiente de dados agrupados mensalmente

**Status:** 🔴 Pendente | **Execução:** Complexa | **Risco:** Médio | **Benefício:** Alto

**Descrição:** Método generateMonthsList processa datas múltiplas vezes 
com conversões DateFormat caros. Carousel é reconstruído completamente 
a cada mudança, causando performance ruim com muitos meses de dados.

**Prompt de Implementação:**
```
Otimize processamento de dados mensais implementando cache de datas 
processadas, lazy loading de meses, e builder pattern para carousel. 
Pré-calcule intervalos de meses e use estruturas otimizadas para 
buscas rápidas por período. Implemente pagination virtual no carousel.
```

**Dependências:** Sistema de cache, algoritmos de processamento otimizados, 
carousel controller

**Validação:** Performance melhora significativamente com grandes datasets, 
cache funciona corretamente, e dados permanecem consistentes

---

### 6. [REFACTOR] - Separação inadequada de responsabilidades no controller

**Status:** 🔴 Pendente | **Execução:** Moderada | **Risco:** Médio | **Benefício:** Alto

**Descrição:** DespesasPageController mistura responsabilidades de formatação 
de dados, gerenciamento de UI, lógica de negócio, e coordenação de carousel. 
Viola princípio de responsabilidade única tornando código difícil de testar 
e manter.

**Prompt de Implementação:**
```
Separe responsabilidades em services especializados: FormatterService 
para formatação, UIStateService para gerenciamento de estado, 
CarouselService para lógica do carousel, e StatisticsService para 
cálculos. Mantenha controller focado apenas em coordenação.
```

**Dependências:** Services a serem criados, sistema de injeção de dependência, 
interfaces de comunicação entre services

**Validação:** Controller tem responsabilidade única, services são testáveis 
independentemente, e código fica modular

---

### 7. [BUG] - Dependência circular e acoplamento forte entre repositórios

**Status:** 🔴 Pendente | **Execução:** Moderada | **Risco:** Alto | **Benefício:** Alto

**Descrição:** Controller depende diretamente de múltiplos repositórios 
e de outro controller, criando acoplamento forte. _ensureRepositoriesRegistered 
força registro de dependências violando inversão de controle.

**Prompt de Implementação:**
```
Implemente inversão de dependência adequada usando interfaces e injeção 
de dependência. Remova acoplamento direto entre repositórios, use 
mediator pattern para comunicação entre componentes, e implemente 
factory para criação de dependências.
```

**Dependências:** Sistema de injeção de dependência, interfaces, 
mediator pattern, factory methods

**Validação:** Dependências são injetadas corretamente, não há acoplamento 
forte, e sistema é facilmente testável

---

## 🟡 Complexidade MÉDIA

### 8. [REFACTOR] - Lógica de formatação espalhada entre componentes

**Status:** 🔴 Pendente | **Execução:** Moderada | **Risco:** Baixo | **Benefício:** Médio

**Descrição:** Métodos de formatação como formatCurrency, formatDateHeader, 
formatDay estão no controller quando deveriam estar em service dedicado. 
Extensão CustomStringExtension está misturada com lógica de negócio.

**Prompt de Implementação:**
```
Extraia toda lógica de formatação para FormatterService dedicado. 
Mova extensões para arquivo separado de utilities. Crie interface 
padronizada para formatação de datas, moedas, e textos. Implemente 
cache para formatações custosas.
```

**Dependências:** FormatterService a ser criado, arquivo de extensions, 
sistema de cache para formatação

**Validação:** Formatação está centralizada, performance melhora com cache, 
e código fica mais organizado

---

### 9. [OPTIMIZE] - Carousel sem otimização para grandes datasets

**Status:** 🔴 Pendente | **Execução:** Moderada | **Risco:** Baixo | **Benefício:** Médio

**Descrição:** CarouselSlider constrói todas as páginas simultaneamente 
independentemente da quantidade. Não há lazy loading ou virtualização, 
causando problemas de performance e memória com muitos meses.

**Prompt de Implementação:**
```
Implemente lazy loading no carousel construindo apenas páginas visíveis 
e adjacentes. Use PageView com virtualização, cache inteligente de 
widgets construídos, e cleanup automático de páginas distantes. 
Adicione loading indicators para transições.
```

**Dependências:** PageView customizado, sistema de cache de widgets, 
loading indicators

**Validação:** Performance permanece boa independente do número de meses, 
memória é gerenciada eficientemente, e UX não é comprometida

---

### 10. [TODO] - Sistema de cache ausente para dados estáticos

**Status:** 🔴 Pendente | **Execução:** Moderada | **Risco:** Baixo | **Benefício:** Médio

**Descrição:** Dados como lista de meses, estatísticas calculadas, e 
formatações são recalculados a cada rebuild. Sistema não persiste 
dados processados causando reprocessamento desnecessário.

**Prompt de Implementação:**
```
Implemente sistema de cache em memória para dados estáticos e calculados. 
Use cache LRU para dados dinâmicos, persista estatísticas processadas, 
e invalide cache automaticamente quando dados fonte mudam. Adicione 
métricas de hit/miss do cache.
```

**Dependências:** Sistema de cache (LRU, in-memory), cache invalidation, 
métricas de performance

**Validação:** Dados são cachados adequadamente, performance melhora 
significativamente, e cache é invalidado corretamente

---

### 11. [REFACTOR] - Extensão customizada misturada com lógica de negócio

**Status:** 🔴 Pendente | **Execução:** Simples | **Risco:** Baixo | **Benefício:** Médio

**Descrição:** CustomStringCapitalize extension está definida no mesmo 
arquivo do controller principal, violando separação de responsabilidades 
e dificultando reutilização em outros módulos.

**Prompt de Implementação:**
```
Mova todas as extensions para arquivo dedicado em core/extensions/. 
Organize extensions por categoria (string, date, number), documente 
adequadamente, e torne-as disponíveis globalmente através de barrel 
export. Adicione testes unitários para extensions.
```

**Dependências:** Estrutura de pastas core/extensions/, testes unitários

**Validação:** Extensions são reutilizáveis, bem documentadas, testadas, 
e organizadas adequadamente

---

### 12. [STYLE] - Inconsistências no padrão de nomenclatura de métodos

**Status:** 🔴 Pendente | **Execução:** Simples | **Risco:** Baixo | **Benefício:** Médio

**Descrição:** Mistura entre português e inglês em nomes de métodos, 
snake_case e camelCase inconsistente, e alguns métodos com nomes pouco 
descritivos como toggleHeader sem contexto claro.

**Prompt de Implementação:**
```
Padronize nomenclatura seguindo convenções Dart/Flutter consistentemente. 
Use camelCase para métodos, nomes descritivos em inglês, e prefixos 
adequados (_private, get, set, calculate). Refatore nomes ambíguos 
e documente padrões adotados.
```

**Dependências:** Refatoração de nomes, documentação de padrões, 
verificação de breaking changes

**Validação:** Nomenclatura está consistente, código é mais legível, 
e padrões são claros para desenvolvedores

---

## 🟢 Complexidade BAIXA

### 13. [DOC] - Documentação ausente nos métodos públicos

**Status:** 🔴 Pendente | **Execução:** Simples | **Risco:** Baixo | **Benefício:** Baixo

**Descrição:** Métodos públicos não possuem documentação adequada explicando 
parâmetros, retorno, e comportamento esperado. Especialmente crítico para 
métodos como generateMonthsList e calcularEstatisticasMensais.

**Prompt de Implementação:**
```
Adicione documentação completa usando dartdoc format para todos os métodos 
públicos. Inclua descrição, parâmetros, valores de retorno, exceptions 
possíveis, e exemplos de uso. Generate documentation e configure CI 
para verificar cobertura de documentação.
```

**Dependências:** Configuração dartdoc, CI para verificação de documentação

**Validação:** Todos os métodos públicos estão documentados, documentação 
é gerada corretamente, e CI valida cobertura

---

### 14. [REFACTOR] - Métodos utilitários poderiam ser extraídos para helpers

**Status:** 🔴 Pendente | **Execução:** Simples | **Risco:** Baixo | **Benefício:** Baixo

**Descrição:** Métodos como getTipoIcon, formatDay, formatWeekday são 
utilitários que poderiam ser extraídos para classes helper dedicadas, 
melhorando reusabilidade e organização do código.

**Prompt de Implementação:**
```
Extraia métodos utilitários para helpers específicos: DateHelper, 
IconHelper, FormatHelper. Organize em core/helpers/ com testes unitários. 
Mantenha apenas lógica específica do domínio no controller e use helpers 
para operações genéricas.
```

**Dependências:** Estrutura core/helpers/, testes unitários para helpers

**Validação:** Helpers são reutilizáveis, bem testados, e controller 
fica mais focado na lógica específica

---

### 15. [OPTIMIZE] - Rebuild desnecessário em operações de estado

**Status:** 🔴 Pendente | **Execução:** Simples | **Risco:** Baixo | **Benefício:** Baixo

**Descrição:** Algumas operações de estado triggeram rebuilds desnecessários 
da UI. Por exemplo, toggleHeader() poderia ser otimizado para afetar 
apenas widgets específicos ao invés de rebuild completo.

**Prompt de Implementação:**
```
Otimize rebuilds usando ValueNotifier para estados específicos, 
Obx granular para widgets isolados, e evite updates desnecessários 
do estado global. Implemente shouldRebuild conditions onde apropriado 
e use const constructors para widgets estáticos.
```

**Dependências:** Refatoração de widgets para granularidade, const constructors

**Validação:** Rebuilds são minimizados, performance da UI melhora, 
e updates são granulares

---

### 16. [STYLE] - Magic numbers e strings hardcoded

**Status:** 🔴 Pendente | **Execução:** Simples | **Risco:** Baixo | **Benefício:** Baixo

**Descrição:** Código contém magic numbers como índices de carousel, 
strings hardcoded para locale ('pt_BR'), e valores fixos sem constantes 
nomeadas, dificultando manutenção e internacionalização.

**Prompt de Implementação:**
```
Extraia magic numbers e strings para constantes nomeadas. Crie arquivo 
de constantes para valores de configuração, use sistema de localização 
para strings, e documente significado de valores numéricos. Organize 
constantes por categoria.
```

**Dependências:** Arquivo de constantes, sistema de localização

**Validação:** Não há magic numbers, strings são localizáveis, e valores 
têm significado claro através de constantes nomeadas

---

### 17. [TEST] - Ausência de testes unitários para lógica de negócio

**Status:** 🔴 Pendente | **Execução:** Simples | **Risco:** Baixo | **Benefício:** Médio

**Descrição:** Lógica crítica como generateMonthsList, cálculos de estatísticas, 
e formatação de dados não possui testes unitários, aumentando risco de 
regressões e dificultando refatoração segura.

**Prompt de Implementação:**
```
Implemente testes unitários abrangentes para toda lógica de negócio. 
Teste edge cases, cenários de erro, e comportamentos esperados. 
Configure coverage reports e estabeleça threshold mínimo de cobertura. 
Use mocks para dependências externas.
```

**Dependências:** Framework de testes, mocks, coverage tools, CI configuration

**Validação:** Cobertura de testes atende threshold estabelecido, 
todos os cenários críticos são testados, e CI valida testes

---

### 18. [REFACTOR] - Model com responsabilidades mistas

**Status:** 🔴 Pendente | **Execução:** Simples | **Risco:** Baixo | **Benefício:** Médio

**Descrição:** DespesasPageModel mistura dados de estado (loading, showHeader) 
com lógica de negócio (generateMonthsList, cálculos). Deveria focar apenas 
em representação de dados e delegar cálculos para services.

**Prompt de Implementação:**
```
Separe model em StateModel (para estado UI) e DataModel (para dados de 
negócio). Mova lógica de cálculo para services dedicados, mantenha 
apenas properties e métodos simples no model. Implemente pattern 
de composition entre models.
```

**Dependências:** Separação de models, services para cálculos, composition pattern

**Validação:** Models têm responsabilidades bem definidas, cálculos 
são delegados apropriadamente, e código fica mais testável

---

## 🔧 Comandos Rápidos

Para solicitar implementação específica, use:
- `Executar #[número]` - Para que a IA implemente uma issue específica
- `Detalhar #[número]` - Para obter prompt mais detalhado sobre implementação
- `Focar [complexidade]` - Para trabalhar apenas com issues de uma complexidade
- `Agrupar [tipo]` - Para executar todas as issues de um tipo
- `Validar #[número]` - Para que a IA revise implementação concluída

## 📋 Priorização Sugerida

**Ordem de implementação recomendada:**
1. Issues #2, #4, #7 (problemas críticos de arquitetura)
2. Issues #1, #3, #6 (refatoração estrutural)
3. Issues #5, #9 (otimizações de performance)
4. Issues #8, #10, #11 (melhorias de organização)
5. Issues #12-18 (refinamentos e documentação)

**Relacionamentos entre issues:**
- #1 relacionado com #3, #6, #7 (arquitetura)
- #8 relacionado com #11, #14 (organização de código)
- #5 relacionado com #9, #10 (performance)
- #13, #17 complementam todas as outras (qualidade)
