# Issues e Melhorias - Módulo AgriHurbi

## 📋 Índice Geral

| # | Status | Descrição |
|---|--------|-----------|
| 1 | 🔴 Pendente | REFACTOR - Arquitetura Híbrida Inconsistente entre Módulos |
| 2 | 🟢 Concluído | BUG - Controllers Duplicados e Estado Fragmentado |
| 3 | 🔴 Pendente | SECURITY - Hardcoded Admin ID no Repository |
| 4 | 🔴 Pendente | REFACTOR - Navegação Manual sem Padrão GetX |
| 5 | 🟢 Concluído | BUG - Repository Pattern Inconsistente |
| 6 | 🔴 Pendente | OPTIMIZE - Falta de Lazy Loading e Paginação |
| 7 | 🔴 Pendente | SECURITY - Upload de Imagens sem Validação |
| 8 | 🟢 Concluído | BUG - State Management Services com Singleton Incorreto |
| 9 | 🔴 Pendente | REFACTOR - Calculadoras sem Arquitetura Padronizada |
| 10 | 🔴 Pendente | REFACTOR - RSS Service com Problemas de Concorrência |
| 11 | 🔴 Pendente | BUG - Memory Leaks em Controllers |
| 12 | 🔴 Pendente | OPTIMIZE - Pluviômetro sem Otimização de Queries |
| 13 | 🔴 Pendente | SECURITY - Falta de Rate Limiting e Proteção DDoS |
| 14 | 🔴 Pendente | REFACTOR - Módulo Desorganizado sem Separação de Concerns |
| 15 | 🔴 Pendente | BUG - Widgets sem Keys Causando Rebuild Issues |
| 16 | 🔴 Pendente | REFACTOR - Services sem Interface Contracts |
| 17 | 🔴 Pendente | BUG - Error Handling Fragmentado |
| 18 | 🔴 Pendente | REFACTOR - Dependências Circulares entre Services |
| 19 | ⏸️ Pausado | TODO - Implementar Sistema de Notificações |
| 20 | 🟡 Pendente | REFACTOR - Formulários sem Padrão de Validação |
| 21 | 🟡 Pendente | FIXME - Responsividade Quebrada em Tablets |
| 22 | ⏸️ Pausado | TODO - Adicionar Modo Offline Completo |
| 23 | 🟡 Pendente | REFACTOR - Comentários e Documentação Inconsistentes |
| 24 | ⏸️ Pausado | TODO - Implementar Testes Automatizados |
| 25 | 🟡 Pendente | FIXME - Performance de Listas sem Otimização |
| 26 | ⏸️ Pausado | TODO - Sistema de Busca e Filtros Avançados |
| 27 | 🟡 Pendente | REFACTOR - Migração de Assets sem Organização |
| 28 | 🟡 Pendente | FIXME - Deep Links e Navigation 2.0 |
| 29 | ⏸️ Pausado | TODO - Analytics e Tracking |
| 30 | 🟡 Pendente | REFACTOR - Configurações sem Persistência |
| 31 | 🟡 Pendente | FIXME - Tratamento de Imagens sem Compressão |
| 32 | ⏸️ Pausado | TODO - Exportação de Dados |
| 33 | 🟡 Pendente | REFACTOR - Código Morto e Não Utilizado |
| 34 | ⏸️ Pausado | TEST - Testes de Integração para Fluxos Críticos |
| 35 | ⏸️ Pausado | TEST - Testes de Widget para Componentes |
| 36 | 🟡 Pendente | REFACTOR - Constantes Hardcoded |
| 37 | 🟡 Pendente | FIXME - Localização e Internacionalização |
| 38 | 🟡 Pendente | REFACTOR - Uso Inconsistente de Async/Await |
| 39 | ⏸️ Pausado | TODO - Dashboard com Métricas e KPIs |
| 40 | 🟡 Pendente | REFACTOR - Acoplamento Forte entre Camadas |
| 41 | ✅ Concluído | STYLE - Padronização de Cores e Tema |
| 42 | ✅ Concluído | DOC - README do Módulo Ausente |
| 43 | ✅ Concluído | STYLE - Nomenclatura Inconsistente de Arquivos |
| 44 | ✅ Concluído | NOTE - Melhorar Mensagens de Loading |
| 45 | 🟢 Pendente | STYLE - Componentes sem Animações |
| 46 | 🟢 Pendente | DOC - Comentários TODO sem Tracking |
| 47 | ✅ Concluído | STYLE - Logs Debug em Produção |
| 48 | 🟢 Pendente | NOTE - Melhorar Feedback de Ações |
| 49 | 🟢 Pendente | STYLE - Formulários sem Auto-Save |
| 50 | 🟢 Pendente | DOC - API Documentation Ausente |
| 51 | 🟢 Pendente | STYLE - Inconsistência em Error Messages |
| 52 | 🟢 Pendente | NOTE - Considerar Migration para Null Safety Strict |
| 53 | 🟢 Pendente | STYLE - Magic Numbers sem Explicação |
| 54 | ✅ Concluído | DOC - Changelog e Versioning |
| 55 | 🟢 Pendente | STYLE - Código Comentado Desnecessário |

### Resumo por Complexidade

| Complexidade | Total | Categorias |
|-------------|-------|------------|
| 🔴 **ALTA** | 18 | REFACTOR (8), BUG (5), SECURITY (3), OPTIMIZE (2) |
| 🟡 **MÉDIA** | 22 | REFACTOR (10), TODO (6), FIXME (4), TEST (2) |
| 🟢 **BAIXA** | 15 | STYLE (7), DOC (5), NOTE (3) |

**Total de Issues:** 55

### 📊 Estatísticas por Tipo
- **REFACTOR:** 18 issues (32.7%)
- **BUG:** 5 issues (9.1%)
- **TODO:** 6 issues (10.9%)
- **STYLE:** 7 issues (12.7%)
- **SECURITY:** 3 issues (5.5%)
- **FIXME:** 4 issues (7.3%)
- **DOC:** 5 issues (9.1%)
- **OPTIMIZE:** 2 issues (3.6%)
- **TEST:** 2 issues (3.6%)
- **NOTE:** 3 issues (5.5%)

---

## 🔴 Complexidade ALTA

### 1. [REFACTOR] - Arquitetura Híbrida Inconsistente entre Módulos

**Status:** 🔴 Pendente | **Execução:** Muito Complexa | **Risco:** Alto | **Benefício:** Alto

**Descrição:** O módulo mistura diferentes padrões arquiteturais: StatefulWidget puro, ChangeNotifier com Provider, ValueNotifier, e GetX Controllers. Isso causa problemas graves de sincronização de estado, duplicação de lógica e dificuldade de manutenção.

**Prompt de Implementação:**
Unifique toda a arquitetura do módulo app-agrihurbi para usar exclusivamente GetX. Converta todos os StatefulWidgets para GetView, substitua ChangeNotifier/Provider por GetxController, implemente bindings apropriados, configure navegação GetX com rotas nomeadas, e garanta que todo estado seja reativo usando .obs. Mantenha funcionalidades existentes mas com arquitetura consistente.

**Dependências:** app-page.dart, mobile_page.dart, todos os controllers, pages, e navegação

**Validação:** Verificar se todos os widgets usam GetView, estado é reativo (.obs), navegação usa Get.to() ou rotas nomeadas, e não há mais uso de setState ou Provider

---

### 2. [BUG] - Controllers Duplicados e Estado Fragmentado

**Status:** 🔴 Pendente | **Execução:** Complexa | **Risco:** Alto | **Benefício:** Alto

**Descrição:** Existem múltiplos controllers para a mesma entidade (bovinos_controller.dart vazio, enhanced_bovinos_controller.dart, e controllers dentro de pastas específicas). Isso causa inconsistência de dados e dificulta rastreamento de bugs.

**Prompt de Implementação:**
Consolide todos os controllers de bovinos em um único EnhancedBovinosController. Remova bovinos_controller.dart vazio e controllers duplicados nas pastas específicas. Migre toda lógica para o controller unificado usando o UnifiedDataService. Atualize todas as referências nas views. Faça o mesmo para equinos, pluviômetros e medições.

**Dependências:** controllers/, pages/bovinos/, pages/equinos/, services/state_management/

**Validação:** Verificar se existe apenas um controller por entidade, todas as views usam o controller correto, e dados sincronizam corretamente

---

### 3. [SECURITY] - Hardcoded Admin ID no Repository

**Status:** 🔴 Pendente | **Execução:** Média | **Risco:** Alto | **Benefício:** Alto

**Descrição:** BovinosRepository tem ID de admin hardcoded ('seu_id_aqui') e validação de segurança fraca. Isso é uma vulnerabilidade crítica que permite acesso não autorizado.

**Prompt de Implementação:**
Remova o ID hardcoded do BovinosRepository. Implemente autenticação adequada usando Firebase Auth com roles/claims. Crie um AuthorizationService que valide permissões baseadas em claims do usuário. Configure regras de segurança no Supabase para validação server-side. Adicione middleware de autorização em todos os métodos de escrita.

**Dependências:** repository/bovinos_repository.dart, services/auth/, Supabase configuration

**Validação:** Verificar se não há IDs hardcoded, autorização funciona com claims, e operações não autorizadas são bloqueadas

---

### 4. [REFACTOR] - Navegação Manual sem Padrão GetX

**Status:** 🔴 Pendente | **Execução:** Complexa | **Risco:** Médio | **Benefício:** Alto

**Descrição:** MobilePageMain usa Navigator nativo com GlobalKeys em vez de GetX navigation. Isso impede uso de bindings, argumentos tipados e navegação reativa.

**Prompt de Implementação:**
Refatore MobilePageMain para usar GetX navigation. Remova GlobalKeys e Navigator nativo. Configure navegação com GetPages no router.dart. Use Get.offNamed() para navegação entre tabs. Implemente bindings para cada página principal. Configure argumentos tipados para passar dados entre telas.

**Dependências:** pages/mobile_page.dart, router.dart, todas as páginas principais

**Validação:** Verificar se navegação usa GetX, GlobalKeys foram removidos, e argumentos passam corretamente

---

### 5. [BUG] - Repository Pattern Inconsistente

**Status:** 🔴 Pendente | **Execução:** Complexa | **Risco:** Alto | **Benefício:** Alto

**Descrição:** Repositories têm APIs diferentes: BovinosRepository usa métodos diretos, EquinoRepository usa observables internos com mapEquinos.value. Isso causa confusão e bugs ao trocar entre entidades.

**Prompt de Implementação:**
Padronize todos os repositories com mesma interface. Crie uma interface abstrata IRepository<T> com métodos getAll(), get(id), save(item), update(item), delete(id). Implemente para cada entidade mantendo consistência. Remova observables internos dos repositories - deixe apenas no UnifiedDataService. Atualize UnifiedDataService para usar nova interface.

**Dependências:** repository/, services/state_management/unified_data_service.dart

**Validação:** Verificar se todos repositories implementam mesma interface e UnifiedDataService funciona corretamente

---

### 6. [OPTIMIZE] - Falta de Lazy Loading e Paginação

**Status:** 🔴 Pendente | **Execução:** Complexa | **Risco:** Médio | **Benefício:** Alto

**Descrição:** Todas as listas carregam dados completos de uma vez, causando problemas de performance com muitos registros. Não há paginação, lazy loading ou virtualização.

**Prompt de Implementação:**
Implemente paginação em todos os repositories usando offset/limit. Adicione infinite scroll com GetX nos controllers de lista. Use ListView.builder com itemExtent fixo para virtualização. Implemente cache de páginas no UnifiedDataService. Adicione indicadores de carregamento durante scroll. Configure pre-fetch de próxima página.

**Dependências:** repositories/, controllers de lista, widgets de lista

**Validação:** Verificar scroll infinito funciona, performance melhorou com muitos itens, e cache funciona

---

### 7. [SECURITY] - Upload de Imagens sem Validação

**Status:** 🔴 Pendente | **Execução:** Média | **Risco:** Alto | **Benefício:** Alto

**Descrição:** Services de upload (bovino_upload_service.dart) não validam tipo, tamanho ou conteúdo de arquivos. Permite upload de arquivos maliciosos ou excessivamente grandes.

**Prompt de Implementação:**
Adicione validação completa no upload: verificar MIME type real (não só extensão), limitar tamanho (max 5MB), validar dimensões de imagem, sanitizar nomes de arquivo, verificar conteúdo com image_validation_service. Implemente compressão automática se necessário. Adicione rate limiting por usuário.

**Dependências:** services/bovino_upload_service.dart, services/image_validation_service.dart

**Validação:** Testar upload com arquivos inválidos, grandes, e maliciosos - todos devem ser bloqueados

---

### 8. [BUG] - State Management Services com Singleton Incorreto

**Status:** 🔴 Pendente | **Execução:** Média | **Risco:** Alto | **Benefício:** Alto

**Descrição:** UnifiedDataService e AgrihurbiStateManager usam singleton pattern manual em vez de GetX service. Isso pode causar múltiplas instâncias e estado inconsistente.

**Prompt de Implementação:**
Converta UnifiedDataService e AgrihurbiStateManager para usar GetxService corretamente. Remova singleton manual. Use Get.put() com permanent: true no AgrihurbiServiceLocator. Garanta que Get.find() sempre retorna mesma instância. Adicione verificação de inicialização no onInit().

**Dependências:** services/state_management/

**Validação:** Verificar se apenas uma instância existe, Get.find() funciona, e estado persiste

---

### 9. [REFACTOR] - Calculadoras sem Arquitetura Padronizada

**Status:** 🔴 Pendente | **Execução:** Complexa | **Risco:** Médio | **Benefício:** Alto

**Descrição:** Calculadoras em pages/calc/ têm arquiteturas diferentes: algumas usam MVC, outras apenas controller, sem padrão de validação ou tratamento de erro.

**Prompt de Implementação:**
Crie arquitetura padronizada para calculadoras: BaseCalculatorController abstrato com validação, cálculo e reset. BaseCalculatorModel com interface comum. BaseCalculatorView com layout padrão. Implemente tratamento de erro centralizado. Use herança para cada calculadora específica. Padronize validação de inputs numéricos.

**Dependências:** pages/calc/

**Validação:** Verificar se todas calculadoras seguem mesmo padrão e validações funcionam

---

### 10. [REFACTOR] - RSS Service com Problemas de Concorrência

**Status:** 🔴 Pendente | **Execução:** Complexa | **Risco:** Alto | **Benefício:** Médio

**Descrição:** RSSService tem controle manual de concorrência (_currentRequests) que não é thread-safe. Cache manual pode causar memory leaks. Debounce manual é propenso a bugs.

**Prompt de Implementação:**
Refatore RSSService para usar Stream com debounce nativo do RxDart. Use compute() para parsing em isolate. Implemente cache com flutter_cache_manager. Use Pool de conexões limitado com dio. Adicione cancelamento de requests pendentes. Implemente retry com backoff exponencial.

**Dependências:** services/rss_service.dart

**Validação:** Testar múltiplas requisições simultâneas, verificar memory leaks, e performance

---

### 11. [BUG] - Memory Leaks em Controllers

**Status:** 🔴 Pendente | **Execução:** Média | **Risco:** Alto | **Benefício:** Alto

**Descrição:** Controllers não fazem dispose adequado de TextEditingControllers, FocusNodes e listeners. Isso causa memory leaks significativos.

**Prompt de Implementação:**
Audite todos os controllers e adicione dispose() completo. Dispose todos TextEditingControllers, FocusNodes, ScrollControllers, e AnimationControllers. Cancele todas subscriptions e timers. Use GetX workers em vez de listeners manuais. Implemente mixin AutoDisposeMixin para garantir cleanup.

**Dependências:** Todos os controllers

**Validação:** Usar Flutter Inspector para verificar se não há leaks após navegação

---

### 12. [OPTIMIZE] - Pluviômetro sem Otimização de Queries

**Status:** 🔴 Pendente | **Execução:** Complexa | **Risco:** Médio | **Benefício:** Alto

**Descrição:** Medições de pluviômetro carregam todos os dados e fazem filtering/sorting no cliente. Com muitas medições, isso causa lentidão severa.

**Prompt de Implementação:**
Mova filtering e sorting para queries do Supabase. Use índices apropriados no banco. Implemente agregações no servidor para estatísticas. Use views materializadas para dados frequentes. Adicione cache de resultados calculados. Implemente paginação por período (mês/ano).

**Dependências:** repository/medicoes_repository.dart, pages/pluviometro/

**Validação:** Testar com 10k+ medições, verificar performance de carregamento e cálculos

---

### 13. [SECURITY] - Falta de Rate Limiting e Proteção DDoS

**Status:** 🔴 Pendente | **Execução:** Complexa | **Risco:** Alto | **Benefício:** Alto

**Descrição:** Não há rate limiting em operações sensíveis como upload, criação de registros ou chamadas de API externas.

**Prompt de Implementação:**
Implemente rate limiting por usuário usando flutter_rate_limiter. Configure limites: 10 uploads/min, 50 creates/min, 100 reads/min. Adicione circuit breaker para APIs externas. Implemente exponential backoff em retries. Cache agressivo para leituras. Adicione monitoring de uso abusivo.

**Dependências:** services/, repositories/

**Validação:** Testar limites com requisições em massa, verificar se bloqueio funciona

---

### 14. [REFACTOR] - Módulo Desorganizado sem Separação de Concerns

**Status:** 🔴 Pendente | **Execução:** Muito Complexa | **Risco:** Alto | **Benefício:** Alto

**Descrição:** Estrutura de pastas mistura features, sem clear separation. Calculadoras, CRUD e ferramentas estão no mesmo nível sem organização domain-driven.

**Prompt de Implementação:**
Reorganize módulo em features: core/ (shared), features/livestock/ (bovinos, equinos), features/calculators/, features/pluviometer/, features/news/. Cada feature com próprio data/, domain/, presentation/. Centralize shared em core/. Configure barrel exports. Atualize imports.

**Dependências:** Toda estrutura do módulo

**Validação:** Verificar se imports funcionam, navegação mantida, e código mais organizado

---

### 15. [BUG] - Widgets sem Keys Causando Rebuild Issues

**Status:** 🔴 Pendente | **Execução:** Média | **Risco:** Médio | **Benefício:** Alto

**Descrição:** Listas e formulários não usam Keys apropriadas, causando perda de estado em rebuilds e problemas de performance.

**Prompt de Implementação:**
Adicione ValueKey em todos os itens de lista usando ID único. Use GlobalKey em formulários que precisam manter estado. Implemente AutomaticKeepAliveClientMixin em tabs. Use Key em AnimatedSwitcher e Hero widgets. Configure unique keys em GridView items.

**Dependências:** Todos os widgets de lista e formulários

**Validação:** Verificar se estado persiste em rebuilds e navegação entre tabs

---

### 16. [REFACTOR] - Services sem Interface Contracts

**Status:** 🔴 Pendente | **Execução:** Complexa | **Risco:** Médio | **Benefício:** Alto

**Descrição:** Services em interfaces/ definem interfaces mas implementações não as usam consistentemente. Dificulta testing e mocking.

**Prompt de Implementação:**
Enforce todas as interfaces. Todo service deve implementar explicitamente sua interface. Use dependency injection com interfaces, não implementações concretas. Configure GetX bindings para resolver interfaces. Adicione factory pattern para criação. Facilite mocking em testes.

**Dependências:** services/interfaces/, todas implementações de services

**Validação:** Verificar se todas implementações seguem interfaces e DI funciona

---

### 17. [BUG] - Error Handling Fragmentado

**Status:** 🔴 Pendente | **Execução:** Complexa | **Risco:** Alto | **Benefício:** Alto

**Descrição:** Cada parte do app trata erros diferentemente. Alguns usam try-catch, outros Result pattern, alguns ignoram erros.

**Prompt de Implementação:**
Implemente Result<T> pattern consistentemente. Crie AppException hierarquia com tipos específicos. Use ErrorHandlerService em todo lugar. Configure global error boundary. Adicione logging estruturado. Implemente user-friendly error messages. Configure crash reporting.

**Dependências:** Todos os services, repositories e controllers

**Validação:** Simular vários tipos de erro e verificar tratamento consistente

---

### 18. [REFACTOR] - Dependências Circulares entre Services

**Status:** 🔴 Pendente | **Execução:** Complexa | **Risco:** Alto | **Benefício:** Alto

**Descrição:** UnifiedDataService depende de StateManager que pode depender de DataService, criando dependências circulares potenciais.

**Prompt de Implementação:**
Refatore para eliminar dependências circulares. Use event bus pattern para comunicação entre services. Implemente mediator pattern. Services devem depender apenas de interfaces. Use lazy initialization onde necessário. Configure dependency graph validation.

**Dependências:** services/state_management/

**Validação:** Verificar se não há imports circulares e inicialização funciona

---

## 🟡 Complexidade MÉDIA

### 19. [TODO] - Implementar Sistema de Notificações

**Status:** 🟡 Pendente | **Execução:** Moderada | **Risco:** Médio | **Benefício:** Alto

**Descrição:** Não há sistema de notificações para alertas de medições, lembretes de tarefas ou avisos importantes.

**Prompt de Implementação:**
Implemente NotificationService com Flutter Local Notifications. Configure scheduled notifications para medições periódicas. Adicione push notifications com FCM para alertas importantes. Crie preferências de notificação por usuário. Implemente in-app notifications com overlay.

**Dependências:** Novo service de notificações, configuração FCM

**Validação:** Testar notificações locais e push em iOS/Android

---

### 20. [REFACTOR] - Formulários sem Padrão de Validação

**Status:** 🟡 Pendente | **Execução:** Moderada | **Risco:** Médio | **Benefício:** Médio

**Descrição:** Cada formulário implementa validação própria, causando inconsistência e duplicação de código.

**Prompt de Implementação:**
Crie FormValidationMixin com validações comuns. Implemente Validators class com métodos estáticos. Use flutter_form_builder para formulários complexos. Configure máscaras de input consistentes. Adicione validação em tempo real com debounce. Centralize mensagens de erro.

**Dependências:** Todos os formulários

**Validação:** Testar validações em todos os formulários

---

### 21. [FIXME] - Responsividade Quebrada em Tablets

**Status:** 🟡 Pendente | **Execução:** Moderada | **Risco:** Médio | **Benefício:** Médio

**Descrição:** Layout assume apenas mobile ou desktop (>800px), mas não funciona bem em tablets.

**Prompt de Implementação:**
Implemente breakpoints apropriados: mobile (<600), tablet (600-1200), desktop (>1200). Use LayoutBuilder com adaptive layouts. Configure GridView com crossAxisCount adaptativo. Ajuste fontes e espaçamentos por breakpoint. Teste em iPad e tablets Android.

**Dependências:** app-page.dart, mobile_page.dart, desktop_page.dart

**Validação:** Testar em diferentes tamanhos de tela e orientações

---

### 22. [TODO] - Adicionar Modo Offline Completo

**Status:** 🟡 Pendente | **Execução:** Complexa | **Risco:** Médio | **Benefício:** Alto

**Descrição:** App tem Hive mas não implementa offline-first adequadamente. Não há sync automático ou conflict resolution.

**Prompt de Implementação:**
Implemente offline-first com Hive cache. Configure sync queue para operações offline. Adicione conflict resolution com last-write-wins ou user choice. Implemente background sync. Mostre indicador de modo offline. Cache imagens localmente.

**Dependências:** repositories/, services/sync/

**Validação:** Testar operações offline e sync quando reconectar

---

### 23. [REFACTOR] - Comentários e Documentação Inconsistentes

**Status:** 🟡 Pendente | **Execução:** Simples | **Risco:** Baixo | **Benefício:** Médio

**Descrição:** Código tem mix de comentários em português e inglês, alguns desatualizados, sem padrão de documentação.

**Prompt de Implementação:**
Padronize todos os comentários em português. Use /// para documentação de API. Adicione exemplos de uso em métodos públicos. Documente parâmetros e retornos. Remova comentários obsoletos. Adicione README.md por feature.

**Dependências:** Todos os arquivos

**Validação:** Verificar se documentação está completa e consistente

---

### 24. [TODO] - Implementar Testes Automatizados

**Status:** 🟡 Pendente | **Execução:** Complexa | **Risco:** Baixo | **Benefício:** Alto

**Descrição:** Não há testes unitários, widgets ou integração. Código não é testável devido a acoplamento.

**Prompt de Implementação:**
Configure estrutura de testes. Adicione testes unitários para models e services. Implemente widget tests para componentes principais. Configure integration tests para fluxos críticos. Use mockito para mocking. Aim para 70% coverage. Configure CI/CD.

**Dependências:** test/, configuração CI

**Validação:** Executar test suite e verificar coverage

---

### 25. [FIXME] - Performance de Listas sem Otimização

**Status:** 🟡 Pendente | **Execução:** Moderada | **Risco:** Médio | **Benefício:** Médio

**Descrição:** Listas usam ListView simples sem otimizações, causando jank com muitos itens.

**Prompt de Implementação:**
Use ListView.builder sempre. Implemente itemExtent ou prototypeItem para altura fixa. Adicione cacheExtent apropriado. Use RepaintBoundary em itens complexos. Implemente image caching com cached_network_image. Adicione shimmer loading.

**Dependências:** Todos os widgets de lista

**Validação:** Medir FPS com muitos itens, verificar smoothness

---

### 26. [TODO] - Sistema de Busca e Filtros Avançados

**Status:** 🟡 Pendente | **Execução:** Moderada | **Risco:** Baixo | **Benefício:** Alto

**Descrição:** Busca é básica apenas por nome. Faltam filtros avançados, ordenação e busca por múltiplos campos.

**Prompt de Implementação:**
Implemente SearchService com full-text search. Adicione filtros por categoria, data, status. Implemente ordenação multi-critério. Use algolia ou elasticsearch para busca avançada. Adicione search suggestions e histórico.

**Dependências:** services/search/, UI de filtros

**Validação:** Testar busca com diferentes critérios e performance

---

### 27. [REFACTOR] - Migração de Assets sem Organização

**Status:** 🟡 Pendente | **Execução:** Simples | **Risco:** Baixo | **Benefício:** Médio

**Descrição:** Assets em assets/ sem organização. Apenas leiame.txt presente. Imagens podem estar hardcoded ou em CDN.

**Prompt de Implementação:**
Organize assets/ em images/, icons/, fonts/. Migre imagens do CDN para local quando apropriado. Configure asset generation com flutter_gen. Otimize imagens com webp. Adicione splash screen e app icon adequados.

**Dependências:** assets/, pubspec.yaml

**Validação:** Verificar se todos assets carregam corretamente

---

### 28. [FIXME] - Deep Links e Navigation 2.0

**Status:** 🟡 Pendente | **Execução:** Complexa | **Risco:** Médio | **Benefício:** Médio

**Descrição:** App não suporta deep links ou Navigation 2.0, dificultando compartilhamento e navegação web.

**Prompt de Implementação:**
Implemente deep linking com uni_links. Configure Navigation 2.0 para web support. Adicione URL parsing para rotas. Implemente back button handling apropriado. Configure app links para iOS/Android.

**Dependências:** router.dart, configuração nativa

**Validação:** Testar deep links em iOS/Android e navegação web

---

### 29. [TODO] - Analytics e Tracking

**Status:** 🟡 Pendente | **Execução:** Moderada | **Risco:** Baixo | **Benefício:** Alto

**Descrição:** Não há analytics para entender uso do app, identificar problemas ou melhorar UX.

**Prompt de Implementação:**
Integre Firebase Analytics ou Mixpanel. Trackear eventos principais: navegação, CRUD operations, erros. Implemente user properties. Configure conversion tracking. Adicione performance monitoring. Respeite LGPD/GDPR.

**Dependências:** Novo analytics service

**Validação:** Verificar eventos no dashboard de analytics

---

### 30. [REFACTOR] - Configurações sem Persistência

**Status:** 🟡 Pendente | **Execução:** Simples | **Risco:** Baixo | **Benefício:** Médio

**Descrição:** Settings não são persistidas. Preferências do usuário se perdem ao reiniciar app.

**Prompt de Implementação:**
Implemente SettingsService com SharedPreferences. Persista tema, idioma, unidades de medida, notificações. Use GetX reactive para atualizar UI automaticamente. Adicione export/import de configurações. Sincronize com conta do usuário.

**Dependências:** services/settings/, pages/settings_page.dart

**Validação:** Verificar se configurações persistem após restart

---

### 31. [FIXME] - Tratamento de Imagens sem Compressão

**Status:** 🟡 Pendente | **Execução:** Moderada | **Risco:** Médio | **Benefício:** Médio

**Descrição:** Upload de imagens não faz compressão, desperdiçando bandwidth e storage.

**Prompt de Implementação:**
Implemente compressão automática com flutter_image_compress. Redimensione baseado no uso (thumbnail, display, original). Configure qualidade adaptativa. Converta para WebP quando suportado. Implemente lazy loading de imagens.

**Dependências:** services/image_service.dart, upload services

**Validação:** Comparar tamanho de imagens antes/depois, verificar qualidade

---

### 32. [TODO] - Exportação de Dados

**Status:** 🟡 Pendente | **Execução:** Moderada | **Risco:** Baixo | **Benefício:** Médio

**Descrição:** Usuários não podem exportar seus dados (relatórios, medições, inventário).

**Prompt de Implementação:**
Implemente ExportService com múltiplos formatos: PDF (relatórios), Excel (tabelas), CSV (dados brutos). Use pdf package para gerar PDFs. Configure templates para relatórios. Adicione share functionality. Implemente backup completo.

**Dependências:** services/export/, UI de exportação

**Validação:** Exportar dados em diferentes formatos e verificar integridade

---

### 33. [REFACTOR] - Código Morto e Não Utilizado

**Status:** 🟡 Pendente | **Execução:** Simples | **Risco:** Baixo | **Benefício:** Médio

**Descrição:** bovinos_controller.dart está vazio, pode haver outros arquivos não utilizados.

**Prompt de Implementação:**
Faça auditoria completa de código não utilizado. Remova arquivos vazios e imports não usados. Delete código comentado antigo. Remova features flags antigas. Use dart analyze e coverage para identificar dead code.

**Dependências:** Todo o módulo

**Validação:** Verificar se build continua funcionando após limpeza

---

### 34. [TEST] - Testes de Integração para Fluxos Críticos

**Status:** 🟡 Pendente | **Execução:** Complexa | **Risco:** Baixo | **Benefício:** Alto

**Descrição:** Fluxos críticos como CRUD de bovinos e medições não têm testes automatizados.

**Prompt de Implementação:**
Implemente integration tests para: cadastro/edição/deleção de bovinos, registro de medições, cálculos principais. Use integration_test package. Configure test fixtures. Mocke serviços externos. Adicione screenshots em falhas.

**Dependências:** integration_test/

**Validação:** Executar testes em dispositivos reais

---

### 35. [TEST] - Testes de Widget para Componentes

**Status:** 🟡 Pendente | **Execução:** Moderada | **Risco:** Baixo | **Benefício:** Médio

**Descrição:** Componentes reutilizáveis não têm widget tests, dificultando refatorações.

**Prompt de Implementação:**
Adicione widget tests para todos os componentes em widgets/. Teste diferentes estados e interações. Use golden tests para regressão visual. Configure pump and settle apropriadamente. Mocke dependências externas.

**Dependências:** test/widgets/

**Validação:** Executar widget tests e verificar coverage

---

### 36. [REFACTOR] - Constantes Hardcoded

**Status:** 🟡 Pendente | **Execução:** Simples | **Risco:** Baixo | **Benefício:** Médio

**Descrição:** Valores como timeouts, limites e configurações estão hardcoded no código.

**Prompt de Implementação:**
Extraia todas as constantes para arquivos dedicados em constants/. Agrupe por domínio. Use environment variables para valores sensíveis. Configure feature flags. Centralize configurações de API.

**Dependências:** constants/, todo código com valores hardcoded

**Validação:** Verificar se app funciona com constantes externalizadas

---

### 37. [FIXME] - Localização e Internacionalização

**Status:** 🟡 Pendente | **Execução:** Complexa | **Risco:** Baixo | **Benefício:** Médio

**Descrição:** App está hardcoded em português sem suporte a outros idiomas.

**Prompt de Implementação:**
Implemente i18n com flutter_localizations. Extraia todos os strings para arb files. Configure fallback para português. Adicione seletor de idioma. Suporte datas e números localizados. Teste com pelo menos inglês.

**Dependências:** l10n/, todos os strings hardcoded

**Validação:** Trocar idioma e verificar se tudo traduz

---

### 38. [REFACTOR] - Uso Inconsistente de Async/Await

**Status:** 🟡 Pendente | **Execução:** Simples | **Risco:** Médio | **Benefício:** Médio

**Descrição:** Alguns métodos usam then/catchError, outros async/await, sem padrão claro.

**Prompt de Implementação:**
Padronize todo código assíncrono para usar async/await com try-catch. Remova then/catchError chains. Configure linter para enforçar. Adicione timeouts apropriados. Trate todos os erros adequadamente.

**Dependências:** Todo código assíncrono

**Validação:** Verificar se não há warnings do linter

---

### 39. [TODO] - Dashboard com Métricas e KPIs

**Status:** 🟡 Pendente | **Execução:** Moderada | **Risco:** Baixo | **Benefício:** Alto

**Descrição:** Não há dashboard consolidado mostrando métricas importantes do negócio.

**Prompt de Implementação:**
Crie DashboardPage com cards de métricas: total de animais, medições do mês, alertas pendentes. Use charts_flutter para gráficos. Implemente período selecionável. Adicione drill-down para detalhes. Cache cálculos pesados.

**Dependências:** pages/dashboard/, services/statistics/

**Validação:** Verificar se métricas calculam corretamente

---

### 40. [REFACTOR] - Acoplamento Forte entre Camadas

**Status:** 🟡 Pendente | **Execução:** Complexa | **Risco:** Médio | **Benefício:** Alto

**Descrição:** Views acessam repositories diretamente, controllers conhecem detalhes de implementação.

**Prompt de Implementação:**
Implemente clean architecture apropriada. Views só conhecem controllers. Controllers usam use cases. Use cases chamam repositories através de interfaces. Injete dependências. Facilite testing e manutenção.

**Dependências:** Reestruturação completa

**Validação:** Verificar se camadas estão desacopladas

---

## 🟢 Complexidade BAIXA

### 41. [STYLE] - Padronização de Cores e Tema

**Status:** ✅ Concluído | **Execução:** Simples | **Risco:** Baixo | **Benefício:** Médio
**Implementado em:** 2025-08-07 | **Arquivos modificados:** theme/agrihurbi_theme.dart, widgets/custom_green_appbar.dart, pages/mobile_page.dart, widgets/appbar_widget.dart
**Observações:** Criado sistema de tema centralizado AgrihurbiTheme baseado no ShadcnStyle, substituindo cores hardcoded por constantes nomeadas

**Descrição:** Cores hardcoded (Color(0xFF4CAF50)) em vez de tema centralizado.

**Prompt de Implementação:**
Crie ThemeData customizado com ColorScheme apropriado. Defina cores primárias e secundárias. Use Theme.of(context).colorScheme sempre. Configure dark theme. Adicione tema específico para agricultura.

**Dependências:** Theme configuration, todos os widgets

**Validação:** Verificar consistência visual e dark mode

---

### 42. [DOC] - README do Módulo Ausente

**Status:** ✅ Concluído | **Execução:** Simples | **Risco:** Baixo | **Benefício:** Médio
**Implementado em:** 2025-08-07 | **Arquivos modificados:** README.md
**Observações:** Criado README completo com documentação de arquitetura, funcionalidades, instalação e guias de desenvolvimento

**Descrição:** Não há documentação explicando propósito, estrutura e uso do módulo.

**Prompt de Implementação:**
Crie README.md na raiz do módulo explicando: propósito, features principais, arquitetura, como executar, como contribuir. Adicione diagramas de arquitetura. Documente APIs principais. Inclua screenshots.

**Dependências:** README.md

**Validação:** Verificar se documentação está clara e completa

---

### 43. [STYLE] - Nomenclatura Inconsistente de Arquivos

**Status:** ✅ Concluído | **Execução:** Simples | **Risco:** Baixo | **Benefício:** Baixo
**Implementado em:** 2025-08-07 | **Arquivos modificados:** medicoes_models.dart, pluviometros_models.dart, app_page.dart, router.dart
**Observações:** Renomeados arquivos com prefixos numéricos e kebab-case para snake_case padrão. Atualizadas referências principais

**Descrição:** Mix de snake_case e kebab-case, alguns com números prefix (30_medicoes_models.dart).

**Prompt de Implementação:**
Padronize todos os arquivos para snake_case. Remova prefixos numéricos desnecessários. Renomeie seguindo convenções Dart. Atualize todos os imports. Configure linter para enforçar.

**Dependências:** Todos os arquivos e imports

**Validação:** Verificar se não há import errors

---

### 44. [NOTE] - Melhorar Mensagens de Loading

**Status:** ✅ Concluído | **Execução:** Simples | **Risco:** Baixo | **Benefício:** Baixo
**Implementado em:** 2025-08-07 | **Arquivos modificados:** widgets/loading_widgets.dart, widgets/commodity_improved_widget.dart
**Observações:** Criado sistema completo de loading contextual com AgrihurbiLoading e placeholders específicos para diferentes operações

**Descrição:** Loading mostra apenas CircularProgressIndicator sem contexto.

**Prompt de Implementação:**
Adicione mensagens contextuais durante loading ("Carregando bovinos...", "Sincronizando dados..."). Use shimmer effect para listas. Mostre progresso quando possível. Adicione timeout com retry option.

**Dependências:** Todos os loading states

**Validação:** Verificar UX durante operações longas

---

### 45. [STYLE] - Componentes sem Animações

**Status:** ✅ Concluído | **Execução:** Simples | **Risco:** Baixo | **Benefício:** Baixo
**Implementado em:** 2025-08-07 | **Arquivos modificados:** widgets/animations.dart, widgets/weather_animated_widget.dart, widgets/commodities_animated_widget.dart, widgets/animated_page_header.dart
**Observações:** Criado sistema completo de animações com widgets padronizados (AnimatedFadeIn, AnimatedScaleIn, AnimatedListBuilder), exemplos práticos implementados nos widgets principais

**Descrição:** Transições abruptas sem animações, diminuindo percepção de qualidade.

**Prompt de Implementação:**
Adicione AnimatedContainer em cards expansíveis. Use Hero animations em navegação de imagens. Implemente fade transitions. Adicione slide animations em listas. Configure durações apropriadas.

**Dependências:** Widgets interativos

**Validação:** Verificar suavidade das animações

---

### 46. [DOC] - Comentários TODO sem Tracking

**Status:** ✅ Concluído | **Execução:** Simples | **Risco:** Baixo | **Benefício:** Baixo
**Implementado em:** 2025-08-07 | **Arquivos modificados:** TODO_TRACKING.md
**Observações:** Scan completo realizado, identificados 8 TODOs críticos não trackados, criado sistema de tracking com classificação por prioridade. 84% dos TODOs já estavam trackados no sistema de issues

**Descrição:** Podem existir // TODO comments perdidos no código sem tracking adequado.

**Prompt de Implementação:**
Faça scan de todos // TODO, // FIXME, // HACK comments. Converta para issues no sistema de tracking. Remova comments obsoletos. Configure IDE para destacar. Use better_todo extension.

**Dependências:** Todo o código

**Validação:** Verificar se não há TODOs perdidos

---

### 47. [STYLE] - Logs Debug em Produção

**Status:** ✅ Concluído | **Execução:** Simples | **Risco:** Baixo | **Benefício:** Médio
**Implementado em:** 2025-08-07 | **Arquivos modificados:** services/log_service.dart, services/weather_service.dart
**Observações:** Criado LogService robusto com níveis, controle de produção e logs contextuais específicos para AgriHurbi

**Descrição:** debugPrint usado extensivamente, será visível em produção.

**Prompt de Implementação:**
Crie LogService com níveis (debug, info, warning, error). Use kDebugMode para condicionar logs. Configure logger package. Adicione log to file em produção. Implemente remote logging para erros.

**Dependências:** Todo código com debugPrint

**Validação:** Verificar logs em release mode

---

### 48. [NOTE] - Melhorar Feedback de Ações

**Status:** 🟢 Pendente | **Execução:** Simples | **Risco:** Baixo | **Benefício:** Médio

**Descrição:** Ações como salvar/deletar têm feedback mínimo ao usuário.

**Prompt de Implementação:**
Adicione SnackBars com ações de desfazer. Use loading overlays durante processamento. Mostre progresso em operações longas. Adicione haptic feedback. Confirme ações destrutivas com dialog.

**Dependências:** Todos os action handlers

**Validação:** Testar feedback em diferentes ações

---

### 49. [STYLE] - Formulários sem Auto-Save

**Status:** 🟢 Pendente | **Execução:** Moderada | **Risco:** Baixo | **Benefício:** Médio

**Descrição:** Usuário perde dados se sair de formulário sem salvar.

**Prompt de Implementação:**
Implemente auto-save com debounce de 2 segundos. Salve drafts localmente. Mostre indicador de "Salvando...". Avise ao tentar sair com mudanças não salvas. Restaure draft ao retornar.

**Dependências:** Todos os formulários

**Validação:** Testar perda de dados em diferentes cenários

---

### 50. [DOC] - API Documentation Ausente

**Status:** 🟢 Pendente | **Execução:** Simples | **Risco:** Baixo | **Benefício:** Médio

**Descrição:** Services e repositories não têm documentação de API adequada.

**Prompt de Implementação:**
Adicione dartdoc comments em todos os métodos públicos. Documente parâmetros com @param. Explique return values. Adicione exemplos de uso. Gere documentação com dartdoc. Publique em GitHub Pages.

**Dependências:** Todos os services e repositories

**Validação:** Gerar e revisar documentação

---

### 51. [STYLE] - Inconsistência em Error Messages

**Status:** 🟢 Pendente | **Execução:** Simples | **Risco:** Baixo | **Benefício:** Baixo

**Descrição:** Mensagens de erro variam em tom e formato.

**Prompt de Implementação:**
Padronize todas as mensagens de erro. Use tom amigável e explicativo. Sugira ações corretivas. Evite jargão técnico. Centralize strings em error_messages.dart. Adicione códigos de erro para suporte.

**Dependências:** Todo tratamento de erro

**Validação:** Revisar todas as mensagens de erro

---

### 52. [NOTE] - Considerar Migration para Null Safety Strict

**Status:** 🟢 Pendente | **Execução:** Complexa | **Risco:** Médio | **Benefício:** Médio

**Descrição:** Código usa null safety mas pode ter pontos com late ou ! unsafe.

**Prompt de Implementação:**
Audite todo uso de late e ! operator. Substitua por null checks explícitos. Use ?? e ?. operators. Configure strict mode no analysis_options. Elimine todos os warnings.

**Dependências:** Todo o código

**Validação:** Executar com --no-sound-null-safety deve falhar

---

### 53. [STYLE] - Magic Numbers sem Explicação

**Status:** 🟢 Pendente | **Execução:** Simples | **Risco:** Baixo | **Benefício:** Baixo

**Descrição:** Números como 800 (breakpoint) hardcoded sem explicação.

**Prompt de Implementação:**
Extraia magic numbers para constantes nomeadas. Adicione comentários explicativos. Use enums para valores relacionados. Configure linter para detectar. Documente unidades (px, ms, etc).

**Dependências:** Todo código com números hardcoded

**Validação:** Verificar se código está mais legível

---

### 54. [DOC] - Changelog e Versioning

**Status:** ✅ Concluído | **Execução:** Simples | **Risco:** Baixo | **Benefício:** Médio
**Implementado em:** 2025-08-07 | **Arquivos modificados:** CHANGELOG.md
**Observações:** Criado CHANGELOG completo seguindo Keep a Changelog e Semantic Versioning, incluindo roadmap e guias de migração

**Descrição:** Não há tracking de mudanças ou versionamento do módulo.

**Prompt de Implementação:**
Crie CHANGELOG.md seguindo Keep a Changelog. Implemente semantic versioning. Adicione version badge no README. Configure auto-changelog generation. Tag releases no git.

**Dependências:** CHANGELOG.md, pubspec.yaml

**Validação:** Verificar se changelog reflete mudanças

---

### 55. [STYLE] - Código Comentado Desnecessário

**Status:** 🟢 Pendente | **Execução:** Simples | **Risco:** Baixo | **Benefício:** Baixo

**Descrição:** Pode haver código comentado antigo que deveria ser removido.

**Prompt de Implementação:**
Remova todo código comentado. Se for importante, mova para documentação. Use git history para código antigo. Configure linter para detectar. Limpe imports não usados.

**Dependências:** Todo o código

**Validação:** Verificar se não há código comentado

---

## 🔧 Comandos Rápidos

Para solicitar implementação específica, use:
- `Executar #[número]` - Implementar issue específica
- `Executar ALTA` - Focar em issues de alta complexidade
- `Executar SECURITY` - Priorizar issues de segurança
- `Executar REFACTOR` - Trabalhar refatorações
- `Executar TODO` - Implementar funcionalidades pendentes
- `Validar #[número]` - Revisar implementação concluída
- `Detalhar #[número]` - Obter prompt mais detalhado

## 📊 Priorização Sugerida

### Fase 1 - Crítico (Issues de Segurança e Bugs)
- #3 [SECURITY] - Hardcoded Admin ID
- #7 [SECURITY] - Upload sem Validação  
- #13 [SECURITY] - Falta Rate Limiting
- #2 [BUG] - Controllers Duplicados
- #5 [BUG] - Repository Pattern Inconsistente
- #8 [BUG] - Singleton Incorreto
- #11 [BUG] - Memory Leaks
- #15 [BUG] - Widgets sem Keys
- #17 [BUG] - Error Handling Fragmentado

### Fase 2 - Arquitetura (Refatorações Estruturais)
- #1 [REFACTOR] - Arquitetura Híbrida
- #4 [REFACTOR] - Navegação Manual
- #9 [REFACTOR] - Calculadoras sem Padrão
- #14 [REFACTOR] - Módulo Desorganizado
- #16 [REFACTOR] - Services sem Interfaces
- #18 [REFACTOR] - Dependências Circulares
- #40 [REFACTOR] - Acoplamento Forte

### Fase 3 - Performance e Features
- #6 [OPTIMIZE] - Lazy Loading
- #12 [OPTIMIZE] - Queries Pluviômetro
- #19 [TODO] - Sistema de Notificações
- #22 [TODO] - Modo Offline
- #26 [TODO] - Busca Avançada
- #30 [TODO] - Analytics

### Fase 4 - Qualidade e Manutenção
- #24 [TODO] - Testes Automatizados
- #34 [TEST] - Testes de Integração
- #35 [TEST] - Widget Tests
- #23 [REFACTOR] - Documentação
- #42 [DOC] - README
- #50 [DOC] - API Documentation

### Fase 5 - Polish e UX
- #21 [FIXME] - Responsividade
- #25 [FIXME] - Performance Listas
- #31 [FIXME] - Compressão Imagens
- #41 [STYLE] - Tema Centralizado
- #45 [STYLE] - Animações
- #48 [NOTE] - Feedback Melhorado

## 📈 Métricas de Sucesso

- **Cobertura de Testes:** Alcançar 70% de coverage
- **Performance:** Manter 60 FPS em listas com 1000+ itens
- **Segurança:** Zero vulnerabilidades críticas
- **Manutenibilidade:** Reduzir complexidade ciclomática em 40%
- **UX:** Reduzir tempo de carregamento inicial em 50%
- **Estabilidade:** <0.1% crash rate