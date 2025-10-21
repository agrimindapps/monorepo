# Issues e Melhorias - Módulo Exercícios

## 📋 Índice Geral

### 🔴 Complexidade ALTA (6 issues)
1. [BUG] - Lógica defeituosa de cálculo de dias consecutivos ✅
2. [SECURITY] - Dependência externa não autenticada em repository ✅
3. [REFACTOR] - Sobreposição de responsabilidades entre controllers ✅
4. [BUG] - Vazamento de memória em listeners não removidos ✅
5. [OPTIMIZE] - Performance ruim com recálculos desnecessários ✅
6. [REFACTOR] - Arquitetura inadequada para persistência de dados ✅

### 🟡 Complexidade MÉDIA (8 issues)  
7. [FIXME] - Validações inconsistentes entre controllers ✅
8. [TODO] - Sistema de conquistas incompleto e estático
9. [HACK] - Hardcoded de categorias sem configurabilidade
10. [OPTIMIZE] - Falta de cache para operações custosas
11. [TODO] - Funcionalidades de relatórios e estatísticas
12. [REFACTOR] - Acoplamento forte entre form e list controllers ✅
13. [TEST] - Ausência completa de testes automatizados
14. [FIXME] - Tratamento inadequado de exceções ✅

### 🟢 Complexidade BAIXA (6 issues)
15. [STYLE] - Comentários excessivos no código de produção
16. [DOC] - Documentação ausente em métodos públicos
17. [DEPRECATED] - Uso de debugPrint em production
18. [FIXME] - Magic numbers em validações e configurações
19. [TODO] - Melhorias de acessibilidade na UI
20. [OPTIMIZE] - Widgets desnecessários e rebuilds excessivos

---

## 🔴 Complexidade ALTA

### 1. [BUG] - Lógica defeituosa de cálculo de dias consecutivos

**Status:** 🟢 Concluído | **Execução:** Complexa | **Risco:** Alto | **Benefício:** Alto

**Descrição:** O método _verificarDiasConsecutivos() tem lógica problemática que 
pode incorretamente calcular sequências. Usa diferença absoluta sem considerar 
ordem temporal e pode falhar com fusos horários diferentes.

**Prompt de Implementação:**

Refatore completamente o algoritmo de streak. Use DateUtils.dateOnly() para 
comparações precisas de datas. Implemente lógica sequencial sem abs() que 
considera apenas progressão temporal. Adicione testes para casos edge como 
mudança de fuso horário, anos bissextos e virada de ano.

**Dependências:** controllers/exercicio_controller.dart, models/achievement_model.dart

**Validação:** Streak calculado corretamente em diferentes cenários temporais 
e timezone

---

### 2. [SECURITY] - Dependência externa não autenticada em repository

**Status:** 🟢 Concluído | **Execução:** Moderada | **Risco:** Alto | **Benefício:** Alto

**Descrição:** AtividadeFisicaRepository é usado sem validação ou autenticação 
adequada. Repository externo pode retornar dados maliciosos ou falhar 
silenciosamente comprometendo integridade dos dados de exercícios.

**Prompt de Implementação:**

Implemente validação rigorosa de dados retornados pelo AtividadeFisicaRepository. 
Adicione sanitização de entradas. Crie fallback local para categorias e 
exercícios. Implemente cache seguro e versionado. Adicione logs de auditoria 
para operações sensíveis.

**Dependências:** controllers/exercicio_form_controller.dart, repository externo

**Validação:** Sistema funciona mesmo com repository externo comprometido, 
dados sempre validados

---

### 3. [REFACTOR] - Sobreposição de responsabilidades entre controllers

**Status:** 🟢 Concluído | **Execução:** Muito Complexa | **Risco:** Médio | **Benefício:** Alto

**Descrição:** ExercicioController e ExercicioFormController têm 
responsabilidades sobrepostas. Ambos fazem CRUD, gerenciam estado e calculam 
estatísticas. Viola DRY e dificulta manutenção.

**Prompt de Implementação:**

Reestruture arquitetura separando responsabilidades claras. Crie ExercicioService 
para lógica de negócio, StatisticsService para cálculos, AchievementService 
para conquistas. Controllers devem apenas gerenciar estado de UI. Use injeção 
de dependência para desacoplar componentes.

**Dependências:** Todos os controllers, criação de novos services, views que 
dependem dos controllers

**Validação:** Arquitetura limpa com responsabilidades bem definidas, código 
reutilizável

---

### 4. [BUG] - Vazamento de memória em listeners não removidos

**Status:** 🟢 Concluído | **Execução:** Complexa | **Risco:** Alto | **Benefício:** Alto

**Descrição:** TextEditingController listeners em ExercicioFormController não 
são removidos adequadamente no onClose(). Listener 'ever' em ExercicioPage 
pode não ser cancelado causando vazamentos de memória.

**Prompt de Implementação:**

Implemente gestão adequada de lifecycle para todos os listeners. Use Worker 
do GetX com cancelamento automático. Adicione cleanup manual de 
TextEditingController listeners no onClose(). Implemente padrão Disposable 
para recursos que precisam de limpeza.

**Dependências:** controllers/exercicio_form_controller.dart, pages/exercicio_page.dart

**Validação:** Sem vazamentos de memória detectáveis em testes de stress, 
cleanup adequado

---

### 5. [OPTIMIZE] - Performance ruim com recálculos desnecessários

**Status:** 🟢 Concluído | **Execução:** Complexa | **Risco:** Médio | **Benefício:** Alto

**Descrição:** Métodos _calcularTotaisSemana() e _atualizarAchievements() são 
chamados repetidamente sem verificar se dados mudaram. _updateEventsMap() 
recria todo o mapa a cada mudança.

**Prompt de Implementação:**

Implemente memoização para cálculos custosos. Use computed observables que 
recalculam apenas quando dependências mudam. Adicione cache incremental para 
estatísticas. Otimize _updateEventsMap() para updates parciais. Use debouncing 
para operações frequentes.

**Dependências:** controllers/exercicio_controller.dart, pages/exercicio_page.dart

**Validação:** Performance significativamente melhorada em listas grandes, 
menos CPU usage

---

### 6. [REFACTOR] - Arquitetura inadequada para persistência de dados

**Status:** 🟢 Concluído | **Execução:** Muito Complexa | **Risco:** Médio | **Benefício:** Alto

**Descrição:** Sistema usa apenas Firebase sem persistência local. Falta 
sincronização offline, cache local e estratégia de conflito. Usuário perde 
dados sem conexão.

**Prompt de Implementação:**

Implemente arquitetura híbrida com Hive para cache local e Firebase para 
sincronização. Adicione estratégia offline-first com sync em background. 
Implemente resolução de conflitos para dados modificados offline. Crie 
versionamento de dados para migração segura.

**Dependências:** repository/exercicio_repository.dart, todos os models, 
configuração de banco local

**Validação:** App funciona offline, dados sincronizados automaticamente, 
sem perda de dados

---

## 🟡 Complexidade MÉDIA

### 7. [FIXME] - Validações inconsistentes entre controllers

**Status:** 🟢 Concluído | **Execução:** Moderada | **Risco:** Médio | **Benefício:** Alto

**Descrição:** ExercicioController aceita dados sem validação enquanto 
ExercicioFormController tem validação rigorosa. Inconsistência pode permitir 
dados inválidos no sistema dependendo do fluxo de entrada.

**Prompt de Implementação:**

Centralize validações em classe ValidationService reutilizável. Defina regras 
de negócio consistentes para todos os pontos de entrada. Implemente validação 
em camada de modelo e repository. Use decorators ou annotations para validação 
declarativa.

**Dependências:** Todos os controllers, models/exercicio_model.dart

**Validação:** Validação consistente independente do ponto de entrada de dados

---

### 8. [TODO] - Sistema de conquistas incompleto e estático

**Status:** 🔴 Pendente | **Execução:** Moderada | **Risco:** Baixo | **Benefício:** Alto

**Descrição:** Conquistas são hardcoded e limitadas. Não há persistência, 
progressão ou configurabilidade. Sistema atual é apenas visual sem valor 
funcional real.

**Prompt de Implementação:**

Crie sistema dinâmico de conquistas com configuração em JSON. Implemente 
persistência de progresso e desbloqueios. Adicione níveis, progressão e 
conquistas compostas. Crie notificações para novos achievements. Permita 
conquistas customizáveis pelo usuário.

**Dependências:** models/achievement_model.dart, novo service de achievements, 
persistência

**Validação:** Sistema de conquistas funcional com persistência e progressão

---

### 9. [HACK] - Hardcoded de categorias sem configurabilidade

**Status:** 🔴 Pendente | **Execução:** Moderada | **Risco:** Baixo | **Benefício:** Médio

**Descrição:** Categorias de exercício vêm de repository externo hardcoded. 
Não há configuração local, customização ou fallback caso repository falhe.

**Prompt de Implementação:**

Implemente sistema de categorias configurável localmente. Crie interface para 
usuário adicionar categorias customizadas. Adicione sincronização opcional 
com repository externo. Implemente cache local com fallback para categorias 
padrão. Permita importar/exportar configurações.

**Dependências:** controllers/exercicio_form_controller.dart, novo sistema de 
configuração

**Validação:** Usuário pode customizar categorias, sistema funciona sem 
dependência externa

---

### 10. [OPTIMIZE] - Falta de cache para operações custosas

**Status:** 🔴 Pendente | **Execução:** Moderada | **Risco:** Baixo | **Benefício:** Médio

**Descrição:** Dados de exercícios e estatísticas são recalculados a cada 
acesso. Operações como filtragem, ordenação e agregação são repetidas 
desnecessariamente.

**Prompt de Implementação:**

Implemente sistema de cache multinível com TTL. Use cache em memória para 
dados frequentes e cache em disco para dados persistentes. Adicione 
invalidação inteligente baseada em mudanças de dados. Implemente cache de 
resultado para queries complexas.

**Dependências:** Todos os controllers e repository, sistema de cache

**Validação:** Operações custosas executadas apenas quando necessário, 
response time melhorado

---

### 11. [TODO] - Funcionalidades de relatórios e estatísticas

**Status:** 🔴 Pendente | **Execução:** Moderada | **Risco:** Baixo | **Benefício:** Alto

**Descrição:** Sistema apenas mostra dados básicos. Falta análise de tendências, 
relatórios detalhados, comparações temporais e insights sobre performance.

**Prompt de Implementação:**

Implemente dashboard de estatísticas avançadas com gráficos interativos. 
Adicione análise de tendências, projeções e recomendações baseadas em dados. 
Crie relatórios exportáveis em PDF/CSV. Implemente comparações temporais e 
benchmarks pessoais.

**Dependências:** Novo módulo de relatórios, biblioteca de gráficos, analytics

**Validação:** Usuário tem insights valiosos sobre performance e progresso

---

### 12. [REFACTOR] - Acoplamento forte entre form e list controllers

**Status:** 🟢 Concluído | **Execução:** Moderada | **Risco:** Baixo | **Benefício:** Médio

**Descrição:** ExercicioFormController conhece e manipula diretamente 
ExercicioListController. Acoplamento dificulta testes e reutilização de 
componentes.

**Prompt de Implementação:**

Implemente comunicação via eventos ou streams entre controllers. Use padrão 
Observer ou EventBus para notificações. Crie interface comum para operações 
CRUD. Remova dependência direta entre controllers usando injeção de dependência.

**Dependências:** controllers/exercicio_form_controller.dart, 
controllers/exercicio_list_controller.dart

**Validação:** Controllers independentes, comunicação através de interfaces 
bem definidas

---

### 13. [TEST] - Ausência completa de testes automatizados

**Status:** 🔴 Pendente | **Execução:** Moderada | **Risco:** Baixo | **Benefício:** Alto

**Descrição:** Módulo complexo sem testes unitários, widgets ou integração. 
Dificulta refatorações e detecção de regressões. Qualidade não é garantida.

**Prompt de Implementação:**

Crie testes unitários para todos os controllers e models. Teste lógica de 
validação, cálculos e persistência. Implemente widget tests para componentes 
UI. Adicione integration tests para fluxos principais. Configure CI com 
cobertura mínima de 80%.

**Dependências:** Configuração de ambiente de teste, mocks para Firebase

**Validação:** Cobertura de testes acima de 80% e pipeline de CI passando

---

### 14. [FIXME] - Tratamento inadequado de exceções

**Status:** 🟢 Concluído | **Execução:** Moderada | **Risco:** Médio | **Benefício:** Médio

**Descrição:** Exceções são capturadas genericamente e apenas mostradas em 
snackbars. Não há logging, retry automático ou recuperação graceful de erros.

**Prompt de Implementação:**

Implemente hierarquia de exceções específicas para diferentes tipos de erro. 
Adicione retry automático para falhas temporárias. Crie estratégias de 
recuperação baseadas no tipo de erro. Implemente logging estruturado para 
debugging e monitoramento.

**Dependências:** Todos os controllers e repository, sistema de logging

**Validação:** Erros tratados apropriadamente com recuperação automática 
quando possível

---

## 🟢 Complexidade BAIXA

### 15. [STYLE] - Comentários excessivos no código de produção

**Status:** 🔴 Pendente | **Execução:** Simples | **Risco:** Baixo | **Benefício:** Baixo

**Descrição:** Arquivo exercicio_page.dart tem comentários extensivos de 
análise que não deveriam estar no código de produção. Reduz legibilidade e 
mantém informações desatualizadas.

**Prompt de Implementação:**

Remova todos os comentários de análise e TODO do código de produção. Mantenha 
apenas comentários essenciais para lógica complexa. Use dartdoc para 
documentação de API. Configure linter para detectar comentários excessivos.

**Dependências:** pages/exercicio_page.dart

**Validação:** Código limpo sem comentários de desenvolvimento, apenas 
documentação necessária

---

### 16. [DOC] - Documentação ausente em métodos públicos

**Status:** 🔴 Pendente | **Execução:** Simples | **Risco:** Baixo | **Benefício:** Médio

**Descrição:** Métodos públicos não possuem dartdoc adequado. Parâmetros, 
retornos e comportamentos não são documentados. Dificulta uso e manutenção.

**Prompt de Implementação:**

Adicione dartdoc completo para todos os métodos públicos. Documente parâmetros, 
retornos e efeitos colaterais. Inclua exemplos de uso quando apropriado. 
Configure geração automática de documentação. Use annotations para deprecation 
quando necessário.

**Dependências:** Todos os arquivos do módulo

**Validação:** Documentação gerada automaticamente sem warnings

---

### 17. [DEPRECATED] - Uso de debugPrint em production

**Status:** 🔴 Pendente | **Execução:** Simples | **Risco:** Baixo | **Benefício:** Baixo

**Descrição:** debugPrint() usado para logs não é adequado para produção. 
Logs podem vazar informações ou simplesmente não aparecer em release builds.

**Prompt de Implementação:**

Substitua debugPrint() por sistema de logging adequado usando package:logging. 
Configure diferentes níveis de log para debug/release. Implemente logs 
estruturados com contexto. Adicione configuração para envio de logs para 
serviços de monitoramento.

**Dependências:** Todos os controllers que usam debugPrint

**Validação:** Sistema de logging profissional sem debugPrint em produção

---

### 18. [FIXME] - Magic numbers em validações e configurações

**Status:** 🔴 Pendente | **Execução:** Simples | **Risco:** Baixo | **Benefício:** Baixo

**Descrição:** Valores como 720 (minutos), 30 (duração padrão), limites de 
caracteres aparecem hardcoded. Reduz flexibilidade e legibilidade.

**Prompt de Implementação:**

Extraia magic numbers para constantes nomeadas. Crie classe ExercicioConstants 
com valores de configuração. Use constantes semanticamente nomeadas em todo 
código. Permita configuração futura via settings ou arquivo de configuração.

**Dependências:** Todos os arquivos que usam valores hardcoded

**Validação:** Ausência de magic numbers, uso de constantes bem nomeadas

---

### 19. [TODO] - Melhorias de acessibilidade na UI

**Status:** 🔴 Pendente | **Execução:** Simples | **Risco:** Baixo | **Benefício:** Médio

**Descrição:** Widgets não possuem semantics adequados para leitores de tela. 
Contraste de cores pode ser insuficiente. Navegação por teclado não é suportada.

**Prompt de Implementação:**

Adicione Semantics widgets onde apropriado. Inclua labels descritivos para 
todos os controles interativos. Verifique contraste de cores para AA/AAA 
compliance. Adicione suporte para navegação por teclado. Teste com 
TalkBack/VoiceOver.

**Dependências:** pages/exercicio_page.dart e outros widgets de UI

**Validação:** App utilizável com leitor de tela e navegação por teclado

---

### 20. [OPTIMIZE] - Widgets desnecessários e rebuilds excessivos

**Status:** 🔴 Pendente | **Execução:** Simples | **Risco:** Baixo | **Benefício:** Baixo

**Descrição:** Alguns widgets fazem rebuild desnecessários. Obx() usado 
amplamente sem otimização. Falta uso de const constructors e keys apropriadas.

**Prompt de Implementação:**

Otimize uso de Obx() para observar apenas variáveis necessárias. Use const 
constructors onde possível. Adicione keys em widgets de lista para melhor 
performance. Implemente shouldRebuild customizado onde apropriado. Use 
AnimatedBuilder para animações.

**Dependências:** pages/exercicio_page.dart e outros widgets

**Validação:** Performance melhorada sem rebuilds desnecessários, menos CPU usage

---

## 🔧 Comandos Rápidos

Para solicitar implementação específica, use:
- `Executar #[número]` - Para que a IA implemente uma issue específica
- `Detalhar #[número]` - Para obter prompt mais detalhado sobre implementação
- `Focar [complexidade]` - Para trabalhar apenas com issues de uma complexidade
- `Agrupar [tipo]` - Para executar todas as issues de um tipo
- `Validar #[número]` - Para que a IA revise implementação concluída