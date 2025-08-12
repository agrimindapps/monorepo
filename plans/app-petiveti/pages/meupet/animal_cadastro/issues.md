# Issues e Melhorias - Animal Cadastro

## 📋 Índice Geral

### 🔴 Complexidade ALTA (4 issues)
1. [REFACTOR] - Separar lógica de negócio do controller para services
2. [TODO] - Implementar sistema de auditoria para mudanças nos animais
3. [OPTIMIZE] - Implementar lazy loading e paginação para listas grandes
4. [SECURITY] - Implementar sanitização e validação adicional de dados

### 🟡 Complexidade MÉDIA (6 issues)
5. [BUG] - Corrigir inconsistência entre estados do formulário
6. [REFACTOR] - Melhorar arquitetura de gerenciamento de estado
7. [TODO] - Adicionar cache local para dados de formulário
8. [OPTIMIZE] - Otimizar renderização de widgets com Obx
9. [TODO] - Implementar modo offline para formulários
10. [STYLE] - Padronizar nomenclatura de métodos e variáveis

### 🟢 Complexidade BAIXA (5 issues)
11. [FIXME] - Remover TODOs pendentes e substituir por logging adequado
12. [DOC] - Documentar constantes e métodos públicos
13. [TEST] - Adicionar testes unitários para validações
14. [STYLE] - Remover código deprecated e atualizar dependências
15. [TODO] - Adicionar feedback visual para estados de carregamento

---

## 🔴 Complexidade ALTA

### 1. [REFACTOR] - Separar lógica de negócio do controller para services

**Status:** 🔴 Pendente | **Execução:** Complexa | **Risco:** Médio | **Benefício:** Alto

**Descrição:** O AnimalFormController possui muita lógica de negócio misturada com 
lógica de apresentação. Métodos como _persistAnimalUsingService, _trackFormChanges 
e validações deveriam estar em services separados para melhor separação de 
responsabilidades e testabilidade.

**Prompt de Implementação:**

Refatore o AnimalFormController movendo lógica de negócio para services apropriados. 
Crie AnimalBusinessService para regras de negócio, FormStateManagerService para 
gerenciamento de estado, e mantenha no controller apenas lógica de coordenação 
entre UI e services. Preserve toda funcionalidade existente e adicione injeção 
de dependência adequada.

**Dependências:** controllers/animal_form_controller.dart, services/*, 
models/animal_form_state.dart

**Validação:** Testar que todas as funcionalidades de criação e edição continuam 
funcionando corretamente após refatoração

### 2. [TODO] - Implementar sistema de auditoria para mudanças nos animais

**Status:** 🔴 Pendente | **Execução:** Complexa | **Risco:** Baixo | **Benefício:** Alto

**Descrição:** Não existe rastreamento de quem fez alterações nos dados dos 
animais nem quando foram feitas. Implementar sistema de auditoria permitirá 
histórico completo de mudanças, essencial para aplicações veterinárias.

**Prompt de Implementação:**

Implemente sistema de auditoria que registre todas as operações de criação, 
edição e exclusão de animais. Crie modelo AuditLog com campos: timestamp, 
userId, action, entityId, oldValues, newValues. Integre nos services de criação 
e atualização. Adicione serviço para consultar histórico de mudanças.

**Dependências:** models/*, services/animal_creation_service.dart, 
repository/animal_repository.dart

**Validação:** Verificar que cada operação gera registro de auditoria correto 
e que histórico pode ser consultado

### 3. [OPTIMIZE] - Implementar lazy loading e paginação para listas grandes

**Status:** 🔴 Pendente | **Execução:** Complexa | **Risco:** Médio | **Benefício:** Alto

**Descrição:** O sistema carrega todos os animais de uma vez, o que pode causar 
problemas de performance com muitos registros. Implementar paginação e lazy 
loading melhorará significativamente a experiência do usuário.

**Prompt de Implementação:**

Implemente sistema de paginação no repository e services. Modifique getAnimais() 
para aceitar parâmetros de página e tamanho. Crie PaginatedResult model. 
Implemente lazy loading nos widgets de lista. Adicione controles de navegação 
entre páginas e loading states apropriados.

**Dependências:** repository/animal_repository.dart, services/*, views/*, 
widgets/*

**Validação:** Testar carregamento incremental funciona corretamente e performance 
melhora com datasets grandes

### 4. [SECURITY] - Implementar sanitização e validação adicional de dados

**Status:** 🔴 Pendente | **Execução:** Complexa | **Risco:** Alto | **Benefício:** Alto

**Descrição:** Embora existam validações básicas, faltam sanitização contra 
injection attacks, validação de tamanho de arquivos de foto, e verificação 
de tipos MIME. Necessário fortalecer segurança de dados.

**Prompt de Implementação:**

Implemente sanitização robusta em AnimalValidationService: escape de caracteres 
especiais, validação de MIME types para fotos, limite de tamanho de arquivos, 
regex para prevenir injection. Adicione rate limiting para submissions. 
Crie SecurityService para centralizar validações de segurança.

**Dependências:** services/animal_validation_service.dart, widgets/photo_picker_*, 
services/animal_creation_service.dart

**Validação:** Testar que dados maliciosos são rejeitados e funcionalidade 
normal continua funcionando

---

## 🟡 Complexidade MÉDIA

### 5. [BUG] - Corrigir inconsistência entre estados do formulário

**Status:** 🔴 Pendente | **Execução:** Moderada | **Risco:** Médio | **Benefício:** Alto

**Descrição:** Existe inconsistência entre formState.value.isLoading e outros 
estados de carregamento no controller. Linha 195-197 em animal_form_controller.dart 
mostra lógica confusa de reset de estados que pode deixar UI em estado inconsistente.

**Prompt de Implementação:**

Revise lógica de gerenciamento de estado no AnimalFormController. Consolide 
todos os estados de loading, error e success em uma única fonte de verdade. 
Remova propriedades duplicadas como isLoading vs formState.isLoading. Garanta 
que transições de estado sejam atômicas e consistentes.

**Dependências:** controllers/animal_form_controller.dart, models/animal_form_state.dart, 
views/animal_form_view.dart

**Validação:** Verificar que UI sempre reflete corretamente o estado atual 
do formulário sem inconsistências

### 6. [REFACTOR] - Melhorar arquitetura de gerenciamento de estado

**Status:** 🔴 Pendente | **Execução:** Moderada | **Risco:** Médio | **Benefício:** Alto

**Descrição:** Uso misto de Rx variables e state objects cria complexidade 
desnecessária. Controller tem responsabilidades demais misturando UI state, 
business logic e data management.

**Prompt de Implementação:**

Refatore para usar padrão mais limpo de gerenciamento de estado. Considere 
BLoC ou similar para separar state management de UI controllers. Centralize 
state management em uma classe dedicada. Simplifique interface do controller 
focando apenas em bridge entre UI e business logic.

**Dependências:** controllers/animal_form_controller.dart, views/animal_form_view.dart, 
models/animal_form_state.dart

**Validação:** Estado permanece consistente e reativo, mas com arquitetura 
mais simples e testável

### 7. [TODO] - Adicionar cache local para dados de formulário

**Status:** 🔴 Pendente | **Execução:** Moderada | **Risco:** Baixo | **Benefício:** Médio

**Descrição:** Formulário perde dados se usuário navegar acidentalmente para 
fora. Implementar cache local permitirá recuperar dados não salvos e melhorar 
experiência do usuário.

**Prompt de Implementação:**

Implemente sistema de cache local que salva automaticamente dados do formulário 
durante edição. Use SharedPreferences ou similar. Adicione recuperação automática 
ao inicializar formulário. Implemente limpeza de cache após submit bem-sucedido. 
Adicione UI para recuperar dados não salvos.

**Dependências:** controllers/animal_form_controller.dart, services/form_state_service.dart, 
views/animal_form_view.dart

**Validação:** Dados são preservados entre sessões e podem ser recuperados 
após fechamento acidental

### 8. [OPTIMIZE] - Otimizar renderização de widgets com Obx

**Status:** 🔴 Pendente | **Execução:** Moderada | **Risco:** Baixo | **Benefício:** Médio

**Descrição:** Alguns Obx widgets rebuildam desnecessariamente. Widget tree 
inteiro é wrapped em Obx quando apenas partes específicas precisam ser reativas. 
Isso causa rebuilds desnecessários e impacta performance.

**Prompt de Implementação:**

Otimize uso de Obx wrappers movendo-os apenas para widgets que realmente 
precisam ser reativos. Separe partes estáticas do formulário de partes 
dinâmicas. Use GetBuilder onde apropriado. Implemente shouldRebuild conditions 
para evitar rebuilds desnecessários.

**Dependências:** views/animal_form_view.dart, widgets/*, controllers/animal_form_controller.dart

**Validação:** Formulário mantém responsividade mas com menos rebuilds 
desnecessários, melhorando performance

### 9. [TODO] - Implementar modo offline para formulários

**Status:** 🔴 Pendente | **Execução:** Moderada | **Risco:** Médio | **Benefício:** Alto

**Descrição:** Aplicação não funciona offline. Para contexto veterinário móvel, 
é essencial poder preencher formulários sem conexão e sincronizar depois.

**Prompt de Implementação:**

Implemente modo offline que permite criar e editar animais sem conexão. 
Use database local como SQLite. Adicione queue de sincronização para enviar 
dados quando conexão for restaurada. Implemente conflict resolution para 
dados editados offline e online simultaneamente.

**Dependências:** repository/animal_repository.dart, services/*, models/*, 
novo OfflineSyncService

**Validação:** Formulários funcionam offline e dados são sincronizados 
corretamente quando conexão retorna

### 10. [STYLE] - Padronizar nomenclatura de métodos e variáveis

**Status:** 🔴 Pendente | **Execução:** Moderada | **Risco:** Baixo | **Benefício:** Médio

**Descrição:** Mistura de nomenclatura em português e inglês. Algumas variáveis 
usam padrões diferentes como _controllerTag vs formKey. Falta consistência 
na naming convention através do código.

**Prompt de Implementação:**

Padronize nomenclatura seguindo convenções Dart/Flutter. Defina se usará 
português ou inglês para domain objects e mantenha consistência. Renomeie 
métodos e variáveis para seguir camelCase padrão. Atualize documentação 
refletindo novos nomes.

**Dependências:** Todos os arquivos do módulo animal_cadastro

**Validação:** Código segue nomenclatura consistente e mantém funcionalidade

---

## 🟢 Complexidade BAIXA

### 11. [FIXME] - Remover TODOs pendentes e substituir por logging adequado

**Status:** 🔴 Pendente | **Execução:** Simples | **Risco:** Baixo | **Benefício:** Baixo

**Descrição:** Existem TODOs nas linhas 258-259 e 264-265 do animal_form_controller.dart 
que referenciam implementação de logging service e error handling service 
adequados ao invés de debugPrint.

**Prompt de Implementação:**

Substitua debugPrint por sistema de logging adequado. Crie LoggingService 
com diferentes níveis (debug, info, warning, error). Implemente ErrorHandlingService 
para tratamento centralizado de erros. Remova comentários TODO após implementação.

**Dependências:** controllers/animal_form_controller.dart, novo LoggingService, 
novo ErrorHandlingService

**Validação:** Logs são gerados corretamente e TODOs foram removidos

### 12. [DOC] - Documentar constantes e métodos públicos

**Status:** 🔴 Pendente | **Execução:** Simples | **Risco:** Baixo | **Benefício:** Médio

**Descrição:** Falta documentação em dart doc format para métodos públicos 
em services e controllers. Constants em animal_form_constants.dart precisam 
de documentação explicando uso e propósito.

**Prompt de Implementação:**

Adicione documentação dart doc (///) para todos os métodos públicos, 
constantes e classes. Inclua exemplos de uso onde apropriado. Documente 
parâmetros, retornos e exceptions. Gere documentação HTML para verificar 
completude.

**Dependências:** Todos os arquivos .dart do módulo

**Validação:** Documentação é gerada corretamente e cobre todos os elementos 
públicos

### 13. [TEST] - Adicionar testes unitários para validações

**Status:** 🔴 Pendente | **Execução:** Simples | **Risco:** Baixo | **Benefício:** Alto

**Descrição:** AnimalValidationService não possui testes unitários cobrindo 
casos edge de validação. Lógica crítica de sanitização e parsing de peso 
precisa de cobertura de testes.

**Prompt de Implementação:**

Crie testes unitários abrangentes para AnimalValidationService cobrindo todos 
os métodos de validação, sanitização e parsing. Teste casos válidos, inválidos 
e edge cases. Inclua testes para diferentes locales e formatos de entrada.

**Dependências:** services/animal_validation_service.dart, 
test/animal_validation_service_test.dart (novo)

**Validação:** Testes passam e cobrem pelo menos 90% do código de validação

### 14. [STYLE] - Remover código deprecated e atualizar dependências

**Status:** 🔴 Pendente | **Execução:** Simples | **Risco:** Baixo | **Benefício:** Médio

**Descrição:** AnimalFormConstants contém muitas constantes marcadas como 
@Deprecated que devem ser removidas após migração completa para novos nomes. 
Classes e métodos deprecated aumentam confusão do código.

**Prompt de Implementação:**

Remova todas as constantes, classes e métodos marcados como @Deprecated em 
animal_form_constants.dart e outros arquivos. Verifique que nenhum código 
ainda usa versões deprecated. Atualize imports e referências para usar novas 
versões.

**Dependências:** constants/animal_form_constants.dart, todos arquivos que 
importam estas constantes

**Validação:** Código compila sem warnings de deprecated e funcionalidade 
permanece inalterada

### 15. [TODO] - Adicionar feedback visual para estados de carregamento

**Status:** 🔴 Pendente | **Execução:** Simples | **Risco:** Baixo | **Benefício:** Médio

**Descrição:** Formulário mostra apenas mensagens de erro/sucesso mas não 
tem feedback visual durante states de validating e loading. UX seria melhor 
com indicadores visuais apropriados.

**Prompt de Implementação:**

Adicione indicadores visuais para estados de carregamento: progress indicator 
durante validação, loading overlay durante submit, disabled state nos campos 
durante processing. Use formState para controlar visibilidade destes elementos.

**Dependências:** views/animal_form_view.dart, models/animal_form_state.dart

**Validação:** Estados de loading são visualmente claros e não permitem 
interação durante processing

---

## 🔧 Comandos Rápidos

Para solicitar implementação específica, use:
- `Executar #[número]` - Para que a IA implemente uma issue específica
- `Detalhar #[número]` - Para obter prompt mais detalhado sobre implementação  
- `Focar [complexidade]` - Para trabalhar apenas com issues de uma complexidade
- `Agrupar [tipo]` - Para executar todas as issues de um tipo
- `Validar #[número]` - Para que a IA revise implementação concluída