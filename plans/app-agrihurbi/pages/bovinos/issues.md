# Issues e Melhorias - Módulo Bovinos

## 📋 Índice Geral

### 🔴 Complexidade ALTA (6 issues)
1. ✅ [REFACTOR] - Unificar arquitetura entre StatefulWidget e Provider
2. ✅ [BUG] - Modelo de dados duplicado e incompatível entre páginas
3. ✅ [SECURITY] - Ausência de validação e segurança no upload de imagens
4. ✅ [BUG] - Cast incorreto entre BovinoModel e BovinoClass
5. [REFACTOR] - Navegação manual sem GetX router e argumentos
6. [OPTIMIZE] - Performance sem lazy loading e paginação

### 🟡 Complexidade MÉDIA (3 issues)
7. [TODO] - Implementar funcionalidades de busca e filtros
8. ✅ [FIXME] - Melhorar tratamento de erros e feedback
9. ✅ [TODO] - Adicionar validação robusta de formulários
10. [STYLE] - Padronizar componentes visuais e responsividade
11. ✅ [BUG] - Estado não reativo entre componentes
12. ✅ [REFACTOR] - Separar lógica de upload de imagens
13. ✅ [TODO] - Implementar sistema de categorias e classificação
14. [TEST] - Adicionar testes unitários e integração

### 🟢 Complexidade BAIXA (6 issues)
15. [STYLE] - Melhorar mensagens de feedback e UX
16. [TODO] - Adicionar animações e transições
17. [FIXME] - Corrigir acessibilidade e responsividade
18. [DOC] - Documentar estrutura e fluxo de dados
19. [TODO] - Implementar pull-to-refresh
20. [STYLE] - Padronizar espaçamentos e cores

---

## 🔴 Complexidade ALTA

### 1. [REFACTOR] - Unificar arquitetura entre StatefulWidget e Provider

**Status:** ✅ Concluído | **Execução:** Complexa | **Risco:** Alto | **Benefício:** Alto

**Descrição:** O módulo mistura StatefulWidget puro com Provider de forma inconsistente. Lista usa ChangeNotifier + Provider, cadastro usa StatefulWidget com setState manual, e detalhes usa ValueNotifier. Isso causa problemas de sincronização, performance, e manutenção difícil.

**Prompt de Implementação:**

Refatore todo o módulo bovinos para usar arquitetura GetX consistente. Converta todas as páginas para GetView, substitua ChangeNotifier/ValueNotifier por GetxController com estado reativo (.obs), implemente bindings apropriados para injeção de dependências, e configure navegação com Get.to() e argumentos estruturados. Mantenha todas as funcionalidades existentes mas com estado reativo e sincronização automática.

**Dependências:** Todos os controllers, páginas, navegação, bindings

**Validação:** Verificar se todas as páginas usam GetView, estado é reativo, navegação funciona com argumentos, e dados sincronizam automaticamente

---

### 2. [BUG] - Modelo de dados duplicado e incompatível entre páginas

**Status:** ✅ Concluído | **Execução:** Complexa | **Risco:** Alto | **Benefício:** Alto

**Descrição:** Existem dois modelos diferentes: BovinoModel (cadastro) e BovinoClass (lista/detalhes/repository). Os campos não coincidem (nomeComum vs nome_comum, idReg vs id), serialização é diferente, e isso causa bugs de mapeamento e perda de dados entre páginas.

**Prompt de Implementação:**

Unifique todo o módulo para usar apenas BovinoClass do repositório global. Remova BovinoModel completamente, atualize todas as referencias no cadastro, implemente mapeamento consistente de campos (camelCase para frontend, snake_case para backend), configure serialização/deserialização correta, e garanta que todos os campos necessários existam em BovinoClass.

**Dependências:** BovinoModel, BovinoClass, BovinosCadastroController, widgets, repository

**Validação:** Verificar se apenas BovinoClass é usado, campos mapeiam corretamente, e dados fluem entre páginas sem perda

---

### 3. [SECURITY] - Ausência de validação e segurança no upload de imagens

**Status:** ✅ Concluído | **Execução:** Moderada | **Risco:** Alto | **Benefício:** Alto

**Descrição:** O upload de imagens não possui validações de segurança, verificação de tipos de arquivo, limites de tamanho, ou tratamento de falhas. Método _uploadImages() tem try-catch básico mas permite upload de arquivos potencialmente maliciosos e oferece experiência ruim em falhas.

**Prompt de Implementação:**

Implemente sistema robusto de validação de imagens incluindo verificação de magic numbers para tipos válidos (JPEG, PNG, WebP), limites de tamanho por arquivo e total, sanitização de nomes de arquivo, detecção de conteúdo suspeito, e validação de dimensões. Adicione retry automático com backoff exponencial, progress indicators detalhados, tratamento de timeouts de rede, e rollback automático em falhas parciais.

**Dependências:** BovinosCadastroController, StorageService, validação de arquivos, progress UI

**Validação:** Testar upload com arquivos inválidos, verificar rejeição de tipos proibidos, confirmar retry em falhas, e validar progress feedback

---

### 4. [BUG] - Cast incorreto entre BovinoModel e BovinoClass

**Status:** ✅ Concluído | **Execução:** Moderada | **Risco:** Alto | **Benefício:** Alto

**Descrição:** No método salvarRegistro() linha 103, há cast direto `bovino as BovinoClass` onde bovino é BovinoModel. Isso causa runtime exception porque os tipos são incompatíveis. O método get() também retorna BovinoClass mas é castado para BovinoModel na linha 33.

**Prompt de Implementação:**

Corrija os casts incorretos implementando conversores apropriados entre os modelos ou removendo a duplicação. Se mantiver ambos os modelos temporariamente, crie métodos toBovinoClass() em BovinoModel e fromBovinoClass() em BovinoClass. Melhor ainda, unifique para usar apenas BovinoClass como descrito no issue #2. Atualize initializeData() e salvarRegistro() para usar tipos corretos.

**Dependências:** BovinoModel, BovinoClass, BovinosCadastroController, métodos de conversão

**Validação:** Executar fluxo de cadastro/edição completo e verificar que não há runtime exceptions

---

### 5. [REFACTOR] - Navegação manual sem GetX router e argumentos

**Status:** 🔴 Pendente | **Execução:** Moderada | **Risco:** Médio | **Benefício:** Alto

**Descrição:** Navegação usa Navigator.push() manual com idReg passado via construtor. Não há sincronização automática entre páginas, lista não atualiza após edições, e não há estrutura de argumentos. Isso causa estado desatualizado e experiência inconsistente.

**Prompt de Implementação:**

Refatore navegação para usar Get.to() com argumentos estruturados, implemente Get.back(result: data) para retornar resultados de edições, configure sincronização automática da lista usando ever() ou workers para escutar mudanças no repository, adicione refresh automático após operações CRUD, e implemente bindings apropriados para gerenciar ciclo de vida dos controllers.

**Dependências:** Todas as páginas, controllers, navegação, bindings

**Validação:** Verificar se lista atualiza após edições, navegação funciona com argumentos, e estado sincroniza entre páginas

---

### 6. [OPTIMIZE] - Performance sem lazy loading e paginação

**Status:** 🔴 Pendente | **Execução:** Complexa | **Risco:** Baixo | **Benefício:** Alto

**Descrição:** Lista carrega todos os bovinos de uma vez usando getAll(), não há paginação, imagens não são cacheadas, e ListView usa physics: NeverScrollableScrollPhysics(). Com muitos registros, isso causa lentidão, alto uso de memória, e experiência ruim.

**Prompt de Implementação:**

Implemente lazy loading com paginação automática no repository (limit/offset), adicione cache inteligente de imagens usando cached_network_image, otimize ListView.builder removendo NeverScrollableScrollPhysics e adicionando estimatedItemExtent, configure skeleton loading durante carregamento inicial, implemente infinite scroll para carregar mais registros automaticamente, e adicione refresh incremental.

**Dependências:** BovinosListaController, BovinosRepository, cache de imagens, ListView otimizado

**Validação:** Testar performance com muitos registros, verificar uso de memória, e confirmar carregamento progressivo

---

## 🟡 Complexidade MÉDIA

### 7. [TODO] - Implementar funcionalidades de busca e filtros

**Status:** 🔴 Pendente | **Execução:** Moderada | **Risco:** Baixo | **Benefício:** Alto

**Descrição:** Lista não possui busca por nome comum, país de origem, ou filtros por tipo de animal. Com muitos bovinos cadastrados, fica difícil encontrar registros específicos rapidamente.

**Prompt de Implementação:**

Adicione barra de busca no topo da lista com pesquisa em tempo real por nomeComum e paisOrigem. Implemente filtros por tipoAnimal, status, e características. Configure debounce na busca para performance, adicione chips de filtros ativos, botão para limpar todos os filtros, histórico de buscas recentes, e filtros avançados com range de datas. Use RxList filtering reativo para atualizações instantâneas.

**Dependências:** BovinosListaController, interface de busca, filtros UI, debounce

**Validação:** Testar busca por texto, filtros combinados, performance com muitos registros, e UX de filtros

---

### 8. [FIXME] - Melhorar tratamento de erros e feedback

**Status:** ✅ Concluído | **Execução:** Simples | **Risco:** Baixo | **Benefício:** Médio

**Descrição:** Mensagens de erro são genéricas ("Erro ao carregar dados", "Erro ao salvar registro"), não há feedback específico para diferentes falhas (rede, validação, permissão), loading states são inconsistentes, e usuário não tem clareza sobre o que aconteceu.

**Prompt de Implementação:**

Implemente sistema de mensagens específicas para cada tipo de erro (falha de rede, erro de validação, permissão negada, timeout, etc.), adicione loading states detalhados com texto explicativo ("Carregando bovinos...", "Salvando registro..."), configure snackbars com ações apropriadas (retry, dismiss, detalhes), implemente feedback visual para sucessos com ícones e cores, e adicione logs estruturados para debugging.

**Dependências:** Todos os controllers, sistema de mensagens, UI feedback, logging

**Validação:** Testar diferentes cenários de erro e verificar mensagens apropriadas para cada situação

---

### 9. [TODO] - Adicionar validação robusta de formulários

**Status:** ✅ Concluído | **Execução:** Simples | **Risco:** Baixo | **Benefício:** Médio

**Descrição:** Formulário atual usa apenas formKey.validate() básico. Falta validação específica para campos como nomeComum (caracteres especiais, tamanho), paisOrigem (países válidos), características (formato estruturado), e não há validação de duplicatas.

**Prompt de Implementação:**

Implemente validações específicas para cada campo incluindo regex para nomeComum (letras, espaços, hífen), lista de países válidos para paisOrigem, limites de caracteres para características, validação de formato para tipoAnimal, verificação de duplicatas por nomeComum, sanitização de entrada removendo caracteres perigosos, e feedback visual em tempo real com cores e ícones.

**Dependências:** BovinoFormContent, validadores customizados, listas de países, regex patterns

**Validação:** Testar todos os tipos de entrada inválida e verificar mensagens de erro específicas

---

### 10. [STYLE] - Padronizar componentes visuais e responsividade

**Status:** 🔴 Pendente | **Execução:** Moderada | **Risco:** Baixo | **Benefício:** Médio

**Descrição:** Componentes não seguem design system consistente, não há responsividade para tablets, espaçamentos são inconsistentes entre widgets, cores são hardcoded, e layouts não adaptam para diferentes orientações.

**Prompt de Implementação:**

Padronize todos os componentes seguindo design system consistente, implemente layouts responsivos usando LayoutBuilder para diferentes tamanhos de tela, configure breakpoints para tablet e desktop, use tokens de design para cores e espaçamentos, crie componentes reutilizáveis (cards, botões, inputs), e adicione adaptação automática para orientação portrait/landscape.

**Dependências:** Todos os widgets, sistema de design, layout responsivo, tokens de cores

**Validação:** Testar em diferentes dispositivos e orientações, verificar consistência visual em todo o módulo

---

### 11. [BUG] - Estado não reativo entre componentes

**Status:** ✅ Concluído | **Execução:** Moderada | **Risco:** Médio | **Benefício:** Alto

**Descrição:** Cadastro usa setState() manual, causando renderizações desnecessárias e estado não sincronizado. Mudanças em images e imageMiniatura requerem setState() explícito, e não há reatividade automática entre form fields e modelo.

**Prompt de Implementação:**

Converta todo o estado para reativo usando GetX (.obs), substitua setState() por reatividade automática, implemente Obx() widgets para atualizações precisas, configure two-way binding entre form fields e modelo usando TextEditingController.text.obs, adicione workers para side effects, e remova setState() calls manuais.

**Dependências:** BovinosCadastroController, widgets de cadastro, form fields, reatividade GetX

**Validação:** Verificar se mudanças de estado atualizam UI automaticamente sem setState() manual

---

### 12. [REFACTOR] - Separar lógica de upload de imagens

**Status:** ✅ Concluído | **Execução:** Moderada | **Risco:** Baixo | **Benefício:** Médio

**Descrição:** Lógica de upload está misturada no controller principal, não é reutilizável para outros módulos, tem tratamento básico de erros, e dificulta testes unitários. Método _uploadImages() deveria ser um serviço separado.

**Prompt de Implementação:**

Extraia lógica de upload para UploadService dedicado (similar ao implementado para equinos), implemente interface para upload de múltiplas imagens com progress callbacks, adicione retry automático com backoff exponencial, configure timeout configurável, implemente rollback em falhas parciais, torne o serviço reutilizável para outros módulos, e separe responsabilidades entre controller e service.

**Dependências:** BovinosCadastroController, UploadService, StorageService, progress callbacks

**Validação:** Verificar se upload funciona, é reutilizável, tem tratamento robusto de erros, e progress é reportado

---

### 13. [TODO] - Implementar sistema de categorias e classificação

**Status:** ✅ Concluído | **Execução:** Complexa | **Risco:** Baixo | **Benefício:** Alto

**Descrição:** Bovinos não possuem categorização por raça (Nelore, Angus, Holstein, etc.), classificação por aptidão (corte, leite, dupla aptidão), tags para características específicas, ou organização hierárquica. Dificulta busca e organização especializada.

**Prompt de Implementação:**

Implemente sistema de categorias hierárquicas para raças bovinas, adicione classificação por aptidão (corte, leite, dupla aptidão), crie tags para características especiais (resistência ao calor, alta produção, etc.), configure interface para seleção múltipla de categorias, implemente filtros especializados por raça e aptidão, adicione sugestões de categorias baseadas em características, e atualize modelo de dados com novos campos.

**Dependências:** Modelo de dados, interface de categorias, filtros especializados, taxonomia bovina

**Validação:** Verificar se categorização funciona, filtros especializados, e organização hierárquica

---

### 14. [TEST] - Adicionar testes unitários e integração

**Status:** 🔴 Pendente | **Execução:** Complexa | **Risco:** Baixo | **Benefício:** Alto

**Descrição:** Módulo não possui testes automatizados, dificultando refatorações seguras, detecção de regressões, e garantia de qualidade. Controllers, repository, e widgets críticos precisam de cobertura de testes.

**Prompt de Implementação:**

Implemente suíte completa de testes unitários para todos os controllers, adicione testes para BovinosRepository com mocks do Supabase, teste cenários de erro e sucesso em upload de imagens, crie testes de widget para componentes principais, configure mocks para dependências externas (ImagePicker, StorageService), teste validações de formulário, e adicione testes de integração para fluxos completos. Configure pipeline CI para execução automática.

**Dependências:** Framework de testes, mocks, pipeline CI/CD, cobertura de código

**Validação:** Atingir cobertura mínima de 80% e validar todos os cenários críticos

---

## 🟢 Complexidade BAIXA

### 15. [STYLE] - Melhorar mensagens de feedback e UX

**Status:** 🔴 Pendente | **Execução:** Simples | **Risco:** Baixo | **Benefício:** Médio

**Descrição:** Mensagens são genéricas e não orientam ação ("Erro ao carregar dados"), não há feedback específico para contexto bovino, loading states não informam progresso específico, e usuário não tem clareza sobre próximos passos.

**Prompt de Implementação:**

Melhore todas as mensagens com contexto específico ("Erro ao carregar lista de bovinos", "Bovino cadastrado com sucesso"), adicione ícones temáticos (🐄 para bovinos), configure durações adequadas para diferentes tipos de snackbar, implemente mensagens de confirmação para ações críticas (exclusão), adicione indicadores de progresso específicos ("Salvando dados do bovino...", "Enviando imagens..."), e inclua dicas de ação quando apropriado.

**Dependências:** Sistema de mensagens, ícones temáticos, feedback contextual

**Validação:** Revisar todas as mensagens em diferentes cenários e verificar clareza contextual

---

### 16. [TODO] - Adicionar animações e transições

**Status:** 🔴 Pendente | **Execução:** Simples | **Risco:** Baixo | **Benefício:** Baixo

**Descrição:** Navegação é abrupta sem transições suaves, lista não tem animações de entrada/saída de itens, imagens aparecem instantaneamente, e interface parece estática. Impacta percepção de qualidade e fluidez.

**Prompt de Implementação:**

Adicione animações de transição personalizadas para navegação entre páginas com slide appropriate, implemente animações de lista com staggered animations para entrada de itens, configure hero animations para imagens de bovinos, adicione micro-interações em botões e cards com scale/ripple effects, implemente fade in para carregamento de imagens, e garanta que animações sejam performáticas e possam ser desabilitadas para acessibilidade.

**Dependências:** Sistema de navegação, animações customizadas, hero widgets, performance

**Validação:** Verificar fluidez, performance das animações, e opção de desabilitar

---

### 17. [FIXME] - Corrigir acessibilidade e responsividade

**Status:** 🔴 Pendente | **Execução:** Simples | **Risco:** Baixo | **Benefício:** Médio

**Descrição:** Componentes não possuem labels para leitores de tela, não há suporte para high contrast, navegação por teclado não funciona adequadamente, e não adapta para diferentes tamanhos de fonte do sistema.

**Prompt de Implementação:**

Adicione Semantics widgets apropriados com labels descritivos para cada elemento interativo, configure labels para leitores de tela com contexto bovino ("Imagem do bovino", "Editar dados do animal"), implemente suporte para high contrast e dynamic font scaling, teste com TalkBack/VoiceOver para Android/iOS, garanta que ordem de navegação seja lógica e intuitiva, adicione tooltips onde necessário, e implemente keyboard shortcuts para ações comuns.

**Dependências:** Widgets existentes, framework de acessibilidade, testes com screen readers

**Validação:** Testar com leitores de tela, high contrast, e diferentes tamanhos de fonte

---

### 18. [DOC] - Documentar estrutura e fluxo de dados

**Status:** 🔴 Pendente | **Execução:** Simples | **Risco:** Baixo | **Benefício:** Baixo

**Descrição:** Falta documentação sobre estrutura de dados bovinos, fluxo entre páginas, relacionamentos entre modelos, schema do Supabase, e guia para novos desenvolvedores contribuírem com o módulo.

**Prompt de Implementação:**

Crie documentação técnica incluindo diagrama da estrutura de dados BovinoClass, fluxo de navegação entre páginas com estados, explicação dos relacionamentos entre modelos, schema detalhado da tabela agri_bovinos no Supabase, guia de contribuição para o módulo, exemplos de uso dos controllers, e comentários inline nos códigos mais complexos. Documente também o sistema de upload e storage.

**Dependências:** Estrutura existente, templates de documentação, schemas do database

**Validação:** Revisar documentação com desenvolvedor externo ao projeto

---

### 19. [TODO] - Implementar pull-to-refresh

**Status:** 🔴 Pendente | **Execução:** Simples | **Risco:** Baixo | **Benefício:** Médio

**Descrição:** Lista não permite atualização manual dos dados via gesto pull-to-refresh. Usuários precisam usar o botão refresh manual (que só aparece em development) ou sair e voltar para recarregar informações.

**Prompt de Implementação:**

Adicione RefreshIndicator à lista de bovinos com ação de reload automático chamando loadBovinos(), configure indicador visual apropriado com cores do tema, implemente feedback tátil (HapticFeedback.mediumImpact), integre com controller existente mantendo estado de loading, adicione debounce para evitar múltiplas chamadas simultâneas, e mostre feedback de sucesso quando apropriado.

**Dependências:** BovinosListaPage, BovinosListaController, RefreshIndicator

**Validação:** Testar gesto pull-to-refresh e verificar atualização dos dados

---

### 20. [STYLE] - Padronizar espaçamentos e cores

**Status:** 🔴 Pendente | **Execução:** Simples | **Risco:** Baixo | **Benefício:** Baixo

**Descrição:** Espaçamentos são inconsistentes entre componentes (8.0, 10, 5), cores são hardcoded em alguns lugares (Colors.red, Colors.green), e não há sistema de design unificado com outros módulos.

**Prompt de Implementação:**

Crie constantes para espaçamentos padronizados (AppSpacing.small = 8.0, medium = 16.0, large = 24.0), configure paleta de cores centralizada (AppColors.success, error, primary), remova todas as cores hardcoded substituindo por tokens do tema, implemente design tokens reutilizáveis para toda a aplicação, garanta consistência visual com outros módulos (equinos, bulas), e use ThemeExtensions para customizações específicas.

**Dependências:** Sistema de design global, constantes de estilo, theme extensions

**Validação:** Verificar consistência visual em todo o módulo e alinhamento com outros módulos

---

## 🔧 Comandos Rápidos

Para solicitar implementação específica, use:
- `Executar #[número]` - Para que a IA implemente uma issue específica
- `Detalhar #[número]` - Para obter prompt mais detalhado sobre implementação
- `Focar [complexidade]` - Para trabalhar apenas com issues de uma complexidade
- `Agrupar [tipo]` - Para executar todas as issues de um tipo
- `Validar #[número]` - Para que a IA revise implementação concluída

### Priorização Sugerida
1. **Crítico:** Issues #1, #2, #3, #4 (arquitetura, modelos, segurança, casts)
2. **Alto Impacto:** Issues #5, #6, #11 (navegação, performance, reatividade)
3. **Funcionalidades:** Issues #7, #13 (busca, categorias)
4. **Melhorias:** Issues #8, #9, #10, #12 (validação, UI, upload)
5. **Qualidade:** Issues #14, #17, #18 (testes, acessibilidade, docs)
6. **Polish:** Issues #15, #16, #19, #20 (animações, feedback, estilo)