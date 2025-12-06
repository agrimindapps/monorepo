# Issues e Melhorias - Módulo Água

## 📋 Índice Geral

### 🔴 Complexidade ALTA (4 issues)
1. [BUG] - Erro de firstWhere sem orElse em agua_repository.dart
2. [SECURITY] - Credenciais Firebase expostas e logs de debug
3. [REFACTOR] - Reestruturação da arquitetura do repositório
4. [OPTIMIZE] - Implementação de cache inteligente para registros

### 🟡 Complexidade MÉDIA (6 issues)  
5. [FIXME] - Validação ausente para entrada de dados
6. [TODO] - Sistema de notificações para lembretes de hidratação
7. [REFACTOR] - Separação de responsabilidades no controller
8. [TEST] - Cobertura de testes unitários inexistente
9. [TODO] - Funcionalidade de exportação de dados
10. [OPTIMIZE] - Performance na atualização de progresso diário

### 🟢 Complexidade BAIXA (5 issues)
11. [STYLE] - Padronização de nomenclatura e formatação
12. [DOC] - Documentação de métodos públicos
13. [FIXME] - Magic numbers em constantes nomeadas
14. [TODO] - Melhorias na UI de calendário
15. [DEPRECATED] - Uso de métodos obsoletos do connectivity

---

## 🔴 Complexidade ALTA

### 1. [BUG] - Erro de firstWhere sem orElse em agua_repository.dart

**Status:** 🔴 Pendente | **Execução:** Complexa | **Risco:** Alto | **Benefício:** Alto

**Descrição:** O método get() na linha 51 do AguaRepository usa firstWhere sem 
orElse, causando StateError quando o item não é encontrado. Isso pode quebrar 
o app ao buscar um registro inexistente.

**Prompt de Implementação:**

Corrija o método get() no arquivo agua_repository.dart substituindo firstWhere 
por firstWhereOrNull ou adicionando orElse. Implemente tratamento de erro 
adequado retornando null quando registro não encontrado. Adicione validação 
de entrada para evitar busca com ID inválido.

**Dependências:** controllers/agua_controller.dart (métodos que chamam get)

**Validação:** Testar busca de registro inexistente sem crash da aplicação

---

### 2. [SECURITY] - Credenciais Firebase expostas e logs de debug

**Status:** 🔴 Pendente | **Execução:** Moderada | **Risco:** Alto | **Benefício:** Alto

**Descrição:** Logs de debug com print() expõem informações sensíveis. Falta 
configuração adequada de segurança para regras do Firestore. Credenciais 
podem estar expostas no código.

**Prompt de Implementação:**

Substitua todos os print() por logging adequado usando package:logging. 
Configure diferentes níveis de log para desenvolvimento e produção. Revise 
regras de segurança do Firestore para acesso controlado. Implemente 
autenticação adequada antes de operações no Firebase.

**Dependências:** Configuração global do app, regras Firestore

**Validação:** Verificar ausência de logs sensíveis em produção e segurança 
das regras Firestore

---

### 3. [REFACTOR] - Reestruturação da arquitetura do repositório

**Status:** 🔴 Pendente | **Execução:** Muito Complexa | **Risco:** Médio | **Benefício:** Alto

**Descrição:** O repositório mistura responsabilidades de persistência local, 
sincronização com Firebase e gerenciamento de preferências. Violação do 
princípio de responsabilidade única.

**Prompt de Implementação:**

Divida AguaRepository em três classes: LocalRepository para Hive, 
CloudRepository para Firebase, e PreferencesRepository para SharedPreferences. 
Crie uma classe AguaSyncService para orquestrar sincronização. Implemente 
padrão Repository com interface comum. Mantenha compatibilidade com controller 
existente.

**Dependências:** controllers/agua_controller.dart, todos os widgets que usam 
dados

**Validação:** Todas as funcionalidades mantidas após refatoração, código 
mais modular e testável

---

### 4. [OPTIMIZE] - Implementação de cache inteligente para registros

**Status:** 🔴 Pendente | **Execução:** Complexa | **Risco:** Baixo | **Benefício:** Alto

**Descrição:** Operações repetidas de abertura do Hive box e consultas 
desnecessárias ao banco. Falta estratégia de cache para melhorar performance 
com grandes volumes de dados.

**Prompt de Implementação:**

Implemente sistema de cache em memória para registros frequentemente 
acessados. Crie estratégia de invalidação baseada em tempo e modificações. 
Mantenha box Hive aberto durante ciclo de vida do app. Implemente lazy loading 
para listas grandes com paginação.

**Dependências:** models/beber_agua_model.dart, widgets de listagem

**Validação:** Melhoria mensurável no tempo de carregamento e responsividade 
da UI

---

## 🟡 Complexidade MÉDIA

### 5. [FIXME] - Validação ausente para entrada de dados

**Status:** 🔴 Pendente | **Execução:** Moderada | **Risco:** Médio | **Benefício:** Alto

**Descrição:** Diálogos de meta e quantidade não validam entrada do usuário. 
Valores negativos, zero ou muito altos podem causar comportamento inesperado 
no sistema.

**Prompt de Implementação:**

Adicione validação nos TextFields dos diálogos com regras: quantidade entre 
1ml e 5000ml, meta entre 500ml e 10000ml. Implemente feedback visual para 
entrada inválida. Adicione formatação automática de texto numérico. Previna 
submissão com dados inválidos.

**Dependências:** views/agua_page.dart, widgets/agua_cadastro_widget.dart

**Validação:** Impossibilidade de inserir dados inválidos e feedback claro 
ao usuário

---

### 6. [TODO] - Sistema de notificações para lembretes de hidratação

**Status:** 🔴 Pendente | **Execução:** Moderada | **Risco:** Baixo | **Benefício:** Alto

**Descrição:** Método scheduleReminders() no controller está vazio. Sistema 
de lembretes seria valioso para encorajar hidratação regular dos usuários.

**Prompt de Implementação:**

Implemente notificações locais usando flutter_local_notifications. Permita 
configurar intervalos personalizados (30min, 1h, 2h). Adicione configurações 
para horário de início/fim dos lembretes. Inclua mensagens motivacionais 
variadas. Respeite configurações de não perturbar do usuário.

**Dependências:** Permissões de notificação, configurações do usuário

**Validação:** Notificações funcionando conforme configurado pelo usuário

---

### 7. [REFACTOR] - Separação de responsabilidades no controller

**Status:** 🔴 Pendente | **Execução:** Moderada | **Risco:** Baixo | **Benefício:** Médio

**Descrição:** AguaController concentra muitas responsabilidades: UI state, 
business logic, data management. Dificulta manutenção e teste do código.

**Prompt de Implementação:**

Extraia lógica de negócio para AguaService. Mantenha apenas state management 
no controller. Crie AguaStatisticsService para cálculos. Implemente 
AguaAchievementService para sistema de conquistas. Use injeção de dependência 
para services no controller.

**Dependências:** Criação de novos services, ajuste em views

**Validação:** Controller mais limpo, lógica de negócio reutilizável e testável

---

### 8. [TEST] - Cobertura de testes unitários inexistente

**Status:** 🔴 Pendente | **Execução:** Moderada | **Risco:** Baixo | **Benefício:** Alto

**Descrição:** Módulo não possui testes automatizados. Dificulta refatorações 
seguras e detecção precoce de bugs. Qualidade do código comprometida.

**Prompt de Implementação:**

Crie testes unitários para models, controller e repository. Use mockito para 
mockar dependências externas. Teste cenários de sucesso e falha. Implemente 
testes de widget para componentes UI. Configure pipeline de CI com cobertura 
mínima de 80%.

**Dependências:** Configuração de ambiente de teste, packages de teste

**Validação:** Cobertura de testes acima de 80% e testes passando

---

### 9. [TODO] - Funcionalidade de exportação de dados

**Status:** 🔴 Pendente | **Execução:** Moderada | **Risco:** Baixo | **Benefício:** Médio

**Descrição:** Usuários podem querer exportar histórico de hidratação para 
análise externa ou backup. Funcionalidade agregaria valor ao módulo.

**Prompt de Implementação:**

Implemente exportação em formatos CSV e PDF. Inclua filtros por período 
(semana, mês, ano). Adicione gráficos no PDF com estatísticas resumidas. 
Permita compartilhamento via email ou salvamento local. Crie UI intuitiva 
para seleção de formato e período.

**Dependências:** Packages para PDF e CSV, sistema de arquivos

**Validação:** Exportação funcionando com dados corretos nos formatos 
especificados

---

### 10. [OPTIMIZE] - Performance na atualização de progresso diário

**Status:** 🔴 Pendente | **Execução:** Moderada | **Risco:** Baixo | **Benefício:** Médio

**Descrição:** Método updateTodayProgress faz múltiplas operações síncronas 
com SharedPreferences a cada registro. Pode causar lentidão com uso intenso.

**Prompt de Implementação:**

Implemente cache em memória para progresso do dia atual. Atualize 
SharedPreferences de forma assíncrona em batch. Use Timer para persistir 
dados periodicamente. Otimize cálculos de data evitando conversões repetidas.

**Dependências:** controllers/agua_controller.dart

**Validação:** Melhoria perceptível na velocidade de registro de novos dados

---

## 🟢 Complexidade BAIXA

### 11. [STYLE] - Padronização de nomenclatura e formatação

**Status:** 🔴 Pendente | **Execução:** Simples | **Risco:** Baixo | **Benefício:** Baixo

**Descrição:** Inconsistências na nomenclatura de variáveis e métodos. Alguns 
nomes em português, outros em inglês. Formatação inconsistente entre arquivos.

**Prompt de Implementação:**

Padronize nomenclatura para inglês em toda codebase. Aplique dart format em 
todos os arquivos. Ajuste nomes de variáveis para convenções do Dart. 
Configure linter rules mais restritivas para manter padrão.

**Dependências:** Todos os arquivos do módulo

**Validação:** Código formatado consistentemente sem warnings do linter

---

### 12. [DOC] - Documentação de métodos públicos

**Status:** 🔴 Pendente | **Execução:** Simples | **Risco:** Baixo | **Benefício:** Médio

**Descrição:** Métodos públicos não possuem documentação adequada. Dificulta 
compreensão e manutenção do código por outros desenvolvedores.

**Prompt de Implementação:**

Adicione dartdoc comments para todos os métodos públicos das classes. Inclua 
descrição, parâmetros e valor de retorno. Documente comportamentos especiais 
e exceções. Configure geração automática de documentação.

**Dependências:** Nenhuma

**Validação:** Documentação gerada automaticamente sem erros

---

### 13. [FIXME] - Magic numbers em constantes nomeadas

**Status:** 🔴 Pendente | **Execução:** Simples | **Risco:** Baixo | **Benefício:** Baixo

**Descrição:** Valores como 2000.0 (meta padrão), 41 (type adapter), larguras 
fixas aparecem como números mágicos no código. Reduz legibilidade.

**Prompt de Implementação:**

Extraia números mágicos para constantes nomeadas. Crie classe AguaConstants 
com valores padrão. Use constantes semanticamente nomeadas em todo código. 
Agrupe constantes relacionadas logicamente.

**Dependências:** Todos os arquivos que usam valores hardcoded

**Validação:** Ausência de números mágicos no código, uso de constantes 
nomeadas

---

### 14. [TODO] - Melhorias na UI de calendário

**Status:** 🔴 Pendente | **Execução:** Simples | **Risco:** Baixo | **Benefício:** Médio

**Descrição:** Calendário atual é básico e pode ser melhorado com indicadores 
visuais de progresso diário, cores para metas atingidas e navegação melhorada.

**Prompt de Implementação:**

Adicione indicadores visuais no calendário para dias com registros. Use cores 
diferentes para dias com meta atingida/não atingida. Implemente tooltip com 
quantidade consumida ao passar sobre data. Adicione navegação rápida por mês/ano.

**Dependências:** widgets/agua_calendar_card.dart

**Validação:** Calendário visualmente mais informativo e interativo

---

### 15. [DEPRECATED] - Uso de métodos obsoletos do connectivity

**Status:** 🔴 Pendente | **Execução:** Simples | **Risco:** Baixo | **Benefício:** Baixo

**Descrição:** Método checkConnectivity() usado pode estar deprecated em 
versões mais recentes do package connectivity_plus.

**Prompt de Implementação:**

Atualize para versão mais recente do connectivity_plus. Substitua métodos 
deprecated por equivalentes atuais. Implemente stream de conectividade para 
monitoramento contínuo. Teste compatibilidade com diferentes versões do Flutter.

**Dependências:** pubspec.yaml

**Validação:** Uso de APIs atuais sem warnings de deprecated

---

## 🔧 Comandos Rápidos

Para solicitar implementação específica, use:
- `Executar #[número]` - Para que a IA implemente uma issue específica
- `Detalhar #[número]` - Para obter prompt mais detalhado sobre implementação
- `Focar [complexidade]` - Para trabalhar apenas com issues de uma complexidade
- `Agrupar [tipo]` - Para executar todas as issues de um tipo
- `Validar #[número]` - Para que a IA revise implementação concluída