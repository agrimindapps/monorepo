# Issues e Melhorias - Despesas Page

## 📋 Índice Geral

### 🔴 Complexidade ALTA (4 issues)
1. [REFACTOR] - Controller sobrecarregado com múltiplas responsabilidades
2. [REFACTOR] - Modelo mutável violando princípios de estado imutável
3. [OPTIMIZE] - Duplicação excessiva de lógica entre Service e FilterService
4. [BUG] - Filtragem de dados executada no Model ao invés do Service

### 🟡 Complexidade MÉDIA (8 issues)  
5. [HACK] - Sincronização manual problemática entre controllers
6. [OPTIMIZE] - Utils locais duplicando funcionalidade de utils centralizados
7. [FIXME] - Hardcoded constraints de UI sem responsividade
8. [TEST] - Ausência completa de testes unitários e integração
9. [SECURITY] - Dados sensíveis em debug prints sem filtro
10. [REFACTOR] - Dependências implícitas entre services dificultando manutenção
11. [OPTIMIZE] - Operações custosas executadas na thread principal
12. [STYLE] - Inconsistências de nomenclatura entre português e inglês

### 🟢 Complexidade BAIXA (6 issues)
13. [TODO] - Implementar export para PDF deixado como stub
14. [STYLE] - Magic numbers espalhados sem constantes nomeadas
15. [DOC] - Documentação ausente em métodos complexos
16. [NOTE] - Logging básico insuficiente para debugging
17. [DEPRECATED] - Import de utils centralizado mas usado apenas parcialmente
18. [TODO] - Implementar paginação para listas grandes

---

## 🔴 Complexidade ALTA

### 1. [REFACTOR] - Controller sobrecarregado com múltiplas responsabilidades

**Status:** 🔴 Pendente | **Execução:** Complexa | **Risco:** Alto | **Benefício:** Alto

**Descrição:** DespesasPageController possui 437 linhas com responsabilidades misturadas:
gerenciamento de estado, lógica de negócio, formatação, filtros, estatísticas,
exportação e navegação mensal. Viola princípio Single Responsibility drasticamente.

**Prompt de Implementação:**

Refatore controller aplicando padrão de responsabilidades únicas:
- DespesasPageController: apenas gerenciamento de estado e interação com view
- DespesasBusinessController: lógica de negócio e cálculos
- DespesasExportController: funcionalidades de exportação
- DespesasNavigationController: navegação temporal e filtros
Use GetX Bindings para injeção de dependência e comunicação entre controllers.
Implemente padrão Mediator para coordenação entre diferentes controllers.

**Dependências:** controllers/despesas_page_controller.dart, criar novos controllers,
services/despesas_service.dart, services/despesas_filter_service.dart

**Validação:** Controller principal < 200 linhas, responsabilidades bem separadas,
comunicação eficiente entre controllers, testes unitários passando

---

### 2. [REFACTOR] - Modelo mutável violando princípios de estado imutável

**Status:** 🔴 Pendente | **Execução:** Moderada | **Risco:** Médio | **Benefício:** Alto

**Descrição:** DespesasPageModel possui métodos que mutam estado diretamente
(addDespesa, updateDespesa, setSearchText) ao invés de retornar novas instâncias.
Mistura dados com lógica de filtros, violando separação de responsabilidades.

**Prompt de Implementação:**

Refatore modelo para imutabilidade completa:
- Remova todos os métodos que mutam estado diretamente
- Implemente copyWith consistente para todas as propriedades
- Mova lógica de filtros para DespesasFilterService
- Use freezed package para garantir imutabilidade em compile-time
- Crie factory constructors para estados comuns
- Implemente equals e hashCode adequados

**Dependências:** models/despesas_page_model.dart, services/despesas_filter_service.dart,
freezed, json_annotation

**Validação:** Modelo completamente imutável, lógica de filtros movida para service,
testes de imutabilidade passando, performance mantida

---

### 3. [OPTIMIZE] - Duplicação excessiva de lógica entre Service e FilterService

**Status:** 🔴 Pendente | **Execução:** Moderada | **Risco:** Baixo | **Benefício:** Alto

**Descrição:** DespesasService delega sistematicamente operações para DespesasFilterService,
criando camada desnecessária. Métodos como groupByTipo, sortByDate, filterByDateRange
são apenas proxies sem valor agregado.

**Prompt de Implementação:**

Consolide funcionalidades eliminando duplicação:
- Refatore DespesasService para focar em operações de domínio (CRUD, cálculos)
- Mova toda lógica de filtros e ordenação para DespesasFilterService
- Elimine métodos proxy que apenas delegam sem transformação
- Crie interfaces claras para cada service definindo responsabilidades
- Use composition ao invés de delegation onde apropriado
- Implemente padrão Strategy para diferentes tipos de filtros

**Dependências:** services/despesas_service.dart, services/despesas_filter_service.dart,
controllers/despesas_page_controller.dart

**Validação:** Zero duplicação de lógica, interfaces bem definidas,
performance melhorada, responsabilidades claras

---

### 4. [BUG] - Filtragem de dados executada no Model ao invés do Service

**Status:** 🔴 Pendente | **Execução:** Moderada | **Risco:** Médio | **Benefício:** Alto

**Descrição:** DespesasPageModel contém método _updateFilteredDespesas com lógica
de filtros hardcoded, enquanto existe DespesasFilterService dedicado. Causa
inconsistência e dificulta testes e manutenção.

**Prompt de Implementação:**

Mova toda lógica de filtros para camada de service apropriada:
- Remova _updateFilteredDespesas do model
- Use DespesasFilterService.applyFilters em todas as operações de filtro
- Refatore controller para chamar service ao invés de model
- Implemente filtros compostos usando padrão Specification
- Adicione cache de resultados filtrados para performance
- Crie testes unitários para validar consistência de filtros

**Dependências:** models/despesas_page_model.dart, services/despesas_filter_service.dart,
controllers/despesas_page_controller.dart

**Validação:** Filtros funcionando consistentemente via service,
model sem lógica de negócio, testes cobrindo cenários de filtros

---

## 🟡 Complexidade MÉDIA

### 5. [HACK] - Sincronização manual problemática entre controllers

**Status:** 🔴 Pendente | **Execução:** Moderada | **Risco:** Médio | **Benefício:** Médio

**Descrição:** View executa _checkAndLoadDataIfNeeded com lógica manual para
sincronizar seleção de animal entre AnimalPageController e DespesasPageController.
Approach frágil e propenso a bugs.

**Prompt de Implementação:**

Implemente sincronização automática entre controllers:
- Use GetX reactive programming para observar mudanças automaticamente
- Crie AnimalSelectionService como fonte única de verdade
- Implemente padrão Observer para notificações automáticas
- Use Ever() do GetX para reagir a mudanças de estado
- Remova lógica manual de sincronização da view
- Adicione debounce para evitar múltiplas atualizações

**Dependências:** views/despesas_page_view.dart, controllers/despesas_page_controller.dart,
../../animal_page/controllers/animal_page_controller.dart

**Validação:** Sincronização automática funcionando, código manual removido,
performance otimizada, testes de integração validando sincronização

---

### 6. [OPTIMIZE] - Utils locais duplicando funcionalidade de utils centralizados

**Status:** 🔴 Pendente | **Execução:** Simples | **Risco:** Baixo | **Benefício:** Médio

**Descrição:** DespesasUtils reimplementa formatação de datas, valores e outras
funções já disponíveis em utils centralizados. Import de centralized_utils
usado apenas parcialmente em getTipoIcon.

**Prompt de Implementação:**

Consolide utils eliminando duplicação:
- Refatore para usar apenas utils centralizados
- Remova métodos duplicados como formatarData, formatarValor
- Migre funcionalidades específicas para utils centralizados
- Use extension methods para funcionalidades específicas do módulo
- Mantenha apenas lógica realmente específica de despesas_page
- Configure linter rules para detectar duplicação futura

**Dependências:** utils/despesas_utils.dart, ../../../../utils/despesas_utils.dart,
todos os arquivos que usam DespesasUtils

**Validação:** Duplicação eliminada, funcionalidade mantida,
performance igual ou melhor, imports limpos

---

### 7. [FIXME] - Hardcoded constraints de UI sem responsividade

**Status:** 🔴 Pendente | **Execução:** Simples | **Risco:** Baixo | **Benefício:** Médio

**Descrição:** View possui SizedBox com width fixo de 1020px, padding hardcoded,
sem adaptação para diferentes tamanhos de tela. Compromete experiência em
dispositivos menores.

**Prompt de Implementação:**

Implemente layout responsivo usando constraints adaptáveis:
- Use MediaQuery para obter dimensões da tela
- Implemente breakpoints para diferentes tamanhos (mobile, tablet, desktop)
- Use LayoutBuilder para adaptar layout baseado em constraints
- Configure padding e spacing proporcionais
- Teste em diferentes resoluções e orientações
- Use ScreenUtil ou similar para scaling consistente

**Dependências:** views/despesas_page_view.dart, flutter/material.dart

**Validação:** Layout adaptável funcionando em diferentes dispositivos,
UX consistente, sem overflow em telas pequenas

---

### 8. [TEST] - Ausência completa de testes unitários e integração

**Status:** 🔴 Pendente | **Execução:** Moderada | **Risco:** Alto | **Benefício:** Alto

**Descrição:** Módulo crítico de listagem de despesas sem nenhum teste
automatizado. Controller, services, utils e widgets não possuem cobertura.

**Prompt de Implementação:**

Implemente suite completa de testes:
- Testes unitários para controller, services, utils e models
- Testes de widget para DespesasPageView e componentes
- Testes de integração para fluxos de filtros e busca
- Mocks para repository e dependências externas
- Testes de performance para operações de filtros
- Coverage mínimo de 85% para código crítico

**Dependências:** flutter_test, mockito, build_runner, todos os arquivos do módulo

**Validação:** Coverage > 85%, todos os fluxos críticos testados,
CI/CD executando testes, documentação de testes

---

### 9. [SECURITY] - Dados sensíveis em debug prints sem filtro

**Status:** 🔴 Pendente | **Execução:** Simples | **Risco:** Médio | **Benefício:** Médio

**Descrição:** Controller e services usam debugPrint expondo potencialmente
dados sensíveis como IDs de animais, valores de despesas e informações pessoais
em logs de produção.

**Prompt de Implementação:**

Implemente logging seguro e estruturado:
- Substitua debugPrint por logger com níveis apropriados
- Implemente filtros para dados sensíveis em logs
- Use structured logging com contexto sem dados pessoais
- Configure diferentes níveis para debug/production
- Adicione correlation IDs para rastreamento
- Implemente log sanitization para compliance

**Dependências:** logger package, services/despesas_service.dart,
controllers/despesas_page_controller.dart

**Validação:** Logs estruturados sem dados sensíveis, diferentes ambientes
configurados, debugging eficiente mantido

---

### 10. [REFACTOR] - Dependências implícitas entre services dificultando manutenção

**Status:** 🔴 Pendente | **Execução:** Moderada | **Risco:** Médio | **Benefício:** Médio

**Descrição:** DespesasService cria instâncias de DespesasFilterService internamente,
criando acoplamento forte. Dificulta testes, injeção de dependências e
substituição de implementações.

**Prompt de Implementação:**

Implemente injeção de dependências adequada:
- Use constructor injection para todas as dependências de services
- Crie interfaces abstratas para cada service
- Implemente dependency injection container (get_it ou GetX Get.put)
- Configure binding patterns para lifecycle management  
- Use factory patterns onde apropriado
- Adicione testes com mocks para validar desacoplamento

**Dependências:** services/despesas_service.dart, services/despesas_filter_service.dart,
get_it ou GetX bindings

**Validação:** Dependências explícitas e injetáveis, testes com mocks funcionando,
acoplamento reduzido, flexibilidade melhorada

---

### 11. [OPTIMIZE] - Operações custosas executadas na thread principal

**Status:** 🔴 Pendente | **Execução:** Moderada | **Risco:** Baixo | **Benefício:** Médio

**Descrição:** Operações de filtros, ordenação e cálculos estatísticos executadas
síncronamente na UI thread. Pode causar janks com grandes volumes de dados.

**Prompt de Implementação:**

Otimize operações custosas usando background processing:
- Use compute() para operações CPU-intensivas
- Implemente Isolates para filtros complexos com muitos dados
- Adicione debounce para filtros em tempo real
- Use streaming para processamento progressivo
- Implemente cache para resultados de operações custosas
- Adicione indicadores de loading para operações demoradas

**Dependências:** flutter/foundation.dart (compute), dart:isolate,
services/despesas_filter_service.dart

**Validação:** UI responsiva durante operações custosas, performance
melhorada com grandes volumes, indicadores adequados

---

### 12. [STYLE] - Inconsistências de nomenclatura entre português e inglês

**Status:** 🔴 Pendente | **Execução:** Simples | **Risco:** Baixo | **Benefício:** Baixo

**Descrição:** Mistura inconsistente de nomes em português (formatarData, gerarListaMeses)
e inglês (getMonthsList, searchByDescription) sem padrão definido.

**Prompt de Implementação:**

Padronize nomenclatura seguindo convenções consistentes:
- Defina padrão: métodos em inglês, domínio em português
- Renomeie métodos seguindo camelCase inglês
- Mantenha nomes de domínio (despesa, animal) em português
- Configure analysis_options.yaml com regras de naming
- Use ferramentas de refactoring para renomeação em massa
- Documente convenções no README

**Dependências:** Todos os arquivos do módulo, analysis_options.yaml

**Validação:** Nomenclatura consistente em todo módulo, análise estática
limpa, convenções documentadas

---

## 🟢 Complexidade BAIXA

### 13. [TODO] - Implementar export para PDF deixado como stub

**Status:** 🔴 Pendente | **Execução:** Moderada | **Risco:** Baixo | **Benefício:** Baixo

**Descrição:** Método exportToPdf retorna Uint8List(0) vazio. Funcionalidade
prometida mas não implementada, pode confundir usuários.

**Prompt de Implementação:**

Implemente export para PDF ou remova método stub:
- Use pdf package para gerar PDFs com dados das despesas
- Crie template de PDF com cabeçalho, dados tabulares e rodapé
- Implemente formatação adequada para impressão
- Adicione parâmetros de customização (período, filtros)
- Ou remova método se funcionalidade não for necessária
- Adicione testes para validar formato PDF gerado

**Dependências:** pdf package, controllers/despesas_page_controller.dart

**Validação:** PDF gerado corretamente ou método removido,
testes validando funcionalidade

---

### 14. [STYLE] - Magic numbers espalhados sem constantes nomeadas

**Status:** 🔴 Pendente | **Execução:** Simples | **Risco:** Baixo | **Benefício:** Baixo

**Descrição:** Valores hardcoded como 1020, 300ms, 10, 7 days espalhados
pelo código sem constantes nomeadas explicativas.

**Prompt de Implementação:**

Extraia magic numbers para constantes nomeadas em DespesasPageConfig:
- Mova todos os valores hardcoded para config
- Use nomes descritivos explicando propósito
- Agrupe constantes por categoria (UI, timing, limits)
- Configure lint rules para detectar magic numbers
- Use const constructors para performance
- Documente valores específicos quando necessário

**Dependências:** config/despesas_page_config.dart, todos os arquivos com hardcoded values

**Validação:** Zero magic numbers no código, constantes bem nomeadas,
lint rules detectando novos casos

---

### 15. [DOC] - Documentação ausente em métodos complexos

**Status:** 🔴 Pendente | **Execução:** Simples | **Risco:** Baixo | **Benefício:** Baixo

**Descrição:** Métodos complexos como _generateMonthsBetween, applyFilters,
generateSummary sem documentação explicando lógica e parâmetros.

**Prompt de Implementação:**

Adicione documentação completa para métodos complexos:
- Use dartdoc para todos os métodos públicos
- Documente parâmetros, return values e side effects
- Adicione exemplos de uso para métodos não óbvios
- Explique algoritmos e lógica de negócio complexa
- Use @param, @return, @throws onde apropriado
- Configure dartdoc para gerar documentação automaticamente

**Dependências:** dartdoc, todos os arquivos com métodos complexos

**Validação:** 100% métodos públicos documentados, exemplos funcionais,
documentação gerada automaticamente

---

### 16. [NOTE] - Logging básico insuficiente para debugging

**Status:** 🔴 Pendente | **Execução:** Simples | **Risco:** Baixo | **Benefício:** Baixo

**Descrição:** Apenas debugPrint básico sem contexto, níveis ou estrutura.
Dificulta debugging em desenvolvimento e produção.

**Prompt de Implementação:**

Implemente logging estruturado e contextual:
- Use logger package com níveis apropriados (debug, info, warning, error)
- Adicione contexto estruturado para operações importantes
- Use correlation IDs para rastrear fluxos
- Configure diferentes outputs para dev/prod
- Implemente log rotation para persistência
- Adicione métricas básicas de performance

**Dependências:** logger package, uuid para correlation IDs

**Validação:** Logs estruturados em operações críticas, debugging
eficiente, métricas coletadas

---

### 17. [DEPRECATED] - Import de utils centralizado mas usado apenas parcialmente

**Status:** 🔴 Pendente | **Execução:** Simples | **Risco:** Baixo | **Benefício:** Baixo

**Descrição:** Import as centralized_utils usado apenas em getTipoIcon,
mantendo duplicação desnecessária no resto da classe.

**Prompt de Implementação:**

Complete migração para utils centralizados ou remova import unused:
- Migre todas as funções duplicadas para centralized_utils
- Remova implementações duplicadas locais
- Use import seletivo se apenas algumas funções necessárias
- Configure lint rules para detectar imports não utilizados
- Valide que funcionalidade permanece idêntica após migração

**Dependências:** utils/despesas_utils.dart, ../../../../utils/despesas_utils.dart

**Validação:** Import usado completamente ou removido, sem duplicação,
funcionalidade mantida

---

### 18. [TODO] - Implementar paginação para listas grandes

**Status:** 🔴 Pendente | **Execução:** Moderada | **Risco:** Baixo | **Benefício:** Baixo

**Descrição:** ListView carrega todos os itens de uma vez sem paginação.
Pode causar problemas de performance com muitas despesas.

**Prompt de Implementação:**

Implemente paginação lazy loading para otimizar performance:
- Use ListView.builder com lazy loading
- Implemente pagination no repository level
- Adicione indicadores de loading para próximas páginas
- Use infinite scroll ou pagination buttons conforme UX
- Configure page size baseado em performance testing
- Adicione cache para páginas já carregadas

**Dependências:** views/despesas_page_view.dart, repository/despesa_repository.dart

**Validação:** Paginação funcionando suavemente, performance melhorada
com grandes volumes, UX adequada

---

## 🔧 Comandos Rápidos

Para solicitar implementação específica, use:
- `Executar #[número]` - Para que a IA implemente uma issue específica
- `Detalhar #[número]` - Para obter prompt mais detalhado sobre implementação
- `Focar [complexidade]` - Para trabalhar apenas com issues de uma complexidade
- `Agrupar [tipo]` - Para executar todas as issues de um tipo
- `Validar #[número]` - Para que a IA revise implementação concluída

**Priorização sugerida:**
1. **Críticas:** Issues #1-4 (refatoração arquitetural)
2. **Importantes:** Issues #5-12 (qualidade e robustez)  
3. **Melhorias:** Issues #13-18 (polish e otimizações)

**Tempo estimado total:** 3-4 sprints de desenvolvimento  
**Impacto esperado:** Arquitetura mais limpa, performance melhorada, código mais testável