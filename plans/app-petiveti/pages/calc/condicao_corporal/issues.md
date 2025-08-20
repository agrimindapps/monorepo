# Issues e Melhorias - condicao_corporal

## 📋 Índice Geral

### 🔴 Complexidade ALTA (4 issues)
1. [REFACTOR] - Service de notificações com implementação simulada
2. [SECURITY] - Serialização insegura de dados no NotificationService
3. [BUG] - Ausência de tratamento de contexto inválido
4. [OPTIMIZE] - ValueListenableBuilder desnecessariamente aninhados

### 🟡 Complexidade MÉDIA (3 issues)
5. [TODO] - Implementar notificações reais com flutter_local_notifications
6. [REFACTOR] - Lógica de cores hardcoded no controller
7. [STYLE] - Inconsistência na nomenclatura de métodos

### 🟢 Complexidade BAIXA (2 issues)
8. [DOC] - Documentação ausente nos services
9. [TEST] - Falta de validação de entrada nos widgets

---

## 🔴 Complexidade ALTA

### 1. [REFACTOR] - Service de notificações com implementação simulada

**Status:** 🔴 Pendente | **Execução:** Muito Complexa | **Risco:** Alto | **Benefício:** Alto

**Descrição:** O NotificationService possui uma implementação simulada que não fornece 
notificações reais aos usuários. Usa apenas SharedPreferences para persistir dados e 
dialogs para simular permissões. Isso quebra a expectativa do usuário e compromete a 
funcionalidade principal de lembretes.

**Prompt de Implementação:**

Refatore o NotificationService em condicao_corporal para implementar notificações reais. 
Integre com flutter_local_notifications, implemente scheduling real de notificações, 
mantenha compatibilidade com os dados já persistidos, adicione tratamento de permissões 
de sistema, e crie fallback para dispositivos que não suportam notificações. Mantenha 
a mesma interface pública dos métodos para não quebrar dependências.

**Dependências:** notification_service.dart, condicao_corporal_controller.dart, 
pubspec.yaml, configurações de permissões Android/iOS

**Validação:** Verificar que notificações aparecem no sistema, dados são mantidos 
após restart do app, permissões são solicitadas corretamente

---

### 2. [SECURITY] - Serialização insegura de dados no NotificationService

**Status:** 🔴 Pendente | **Execução:** Moderada | **Risco:** Médio | **Benefício:** Alto

**Descrição:** O método ReminderData.fromJson usa split de string simples sem validação 
adequada dos dados. Isso pode causar crashes se os dados estiverem corrompidos ou 
manipulados. Não há verificação de integridade nem tratamento de casos extremos como 
strings malformadas.

**Prompt de Implementação:**

Substitua o sistema de serialização atual por JSON seguro no ReminderData. Implemente 
validação rigorosa de todos os campos durante deserialização, adicione tratamento de 
exceções para dados corrompidos, migre dados existentes do formato string para JSON, 
e adicione checksums para verificar integridade dos dados salvos.

**Dependências:** notification_service.dart, SharedPreferences

**Validação:** Testar com dados corrompidos, verificar migração de dados antigos, 
confirmar que não há crashes com entradas inválidas

---

### 3. [BUG] - Ausência de tratamento de contexto inválido

**Status:** 🔴 Pendente | **Execução:** Moderada | **Risco:** Médio | **Benefício:** Alto

**Descrição:** Vários métodos no NotificationService e DialogService não verificam se 
o BuildContext ainda é válido antes de mostrar snackbars ou dialogs. Isso pode causar 
crashes quando widgets são desmontados durante operações assíncronas, especialmente 
em scheduleReminder e métodos de feedback.

**Prompt de Implementação:**

Adicione verificações context.mounted em todos os métodos que usam BuildContext após 
operações assíncronas. Implemente padrão de early return quando contexto é inválido, 
adicione logs de debug para rastrear casos de contexto inválido, e considere usar 
GlobalKey ou alternativas para casos críticos onde feedback é essencial.

**Dependências:** notification_service.dart, dialog_service.dart

**Validação:** Testar navegação rápida durante operações, verificar logs de contexto 
inválido, confirmar ausência de crashes

---

### 4. [OPTIMIZE] - ValueListenableBuilder desnecessariamente aninhados

**Status:** 🔴 Pendente | **Execução:** Moderada | **Risco:** Baixo | **Benefício:** Médio

**Descrição:** No index.dart há ValueListenableBuilder aninhados que escutam mudanças 
separadamente mas poderiam ser otimizados. Isso causa rebuilds desnecessários e 
complexidade de código. A cada mudança de espécie, ambos os builders são executados.

**Prompt de Implementação:**

Crie um Listenable combinado no controller que notifica quando qualquer valor relevante 
muda. Use AnimatedBuilder com múltiplos listenables ou implemente um ValueNotifier 
customizado que agrupe espécie e índice. Reduza a árvore de widgets eliminando 
aninhamento desnecessário e mantenha a mesma reatividade da interface.

**Dependências:** index.dart, condicao_corporal_controller.dart

**Validação:** Verificar que interface continua reativa, medir performance com 
flutter inspector, confirmar redução de rebuilds

---

## 🟡 Complexidade MÉDIA

### 5. [TODO] - Implementar notificações reais com flutter_local_notifications

**Status:** 🔴 Pendente | **Execução:** Moderada | **Risco:** Baixo | **Benefício:** Alto

**Descrição:** O sistema atual simula notificações mas não entrega valor real ao usuário. 
É necessário implementar notificações que realmente apareçam no sistema operacional 
para lembretes de reavaliação de condição corporal.

**Prompt de Implementação:**

Integre flutter_local_notifications no projeto. Configure permissões para Android e iOS, 
implemente scheduling de notificações recorrentes baseado nos intervalos definidos, 
adicione deep linking para abrir a calculadora quando notificação for tocada, e 
mantenha sincronização entre notificações agendadas e dados salvos localmente.

**Dependências:** pubspec.yaml, notification_service.dart, configurações nativas

**Validação:** Verificar notificações aparecem nos horários corretos, testar deep 
linking, confirmar funcionamento em background

---

### 6. [REFACTOR] - Lógica de cores hardcoded no controller

**Status:** 🔴 Pendente | **Execução:** Simples | **Risco:** Baixo | **Benefício:** Médio

**Descrição:** Os métodos getColorForIndice e getSelectedColorForIndice no controller 
possuem cores hardcoded que deveriam estar no design system ou em um service de tema. 
Isso dificulta manutenção e customização visual.

**Prompt de Implementação:**

Extraia as cores para uma classe de constantes ou integre com o sistema de design 
existente do app. Crie um ColorService ou use ShadcnStyle para definir cores baseadas 
no tema. Remove a responsabilidade de UI do controller mantendo apenas lógica de 
negócio. Considere suporte a tema escuro e claro.

**Dependências:** condicao_corporal_controller.dart, core/style/shadcn_style.dart

**Validação:** Verificar que cores continuam funcionais, testar em temas diferentes, 
confirmar remoção de UI logic do controller

---

### 7. [STYLE] - Inconsistência na nomenclatura de métodos

**Status:** 🔴 Pendente | **Execução:** Simples | **Risco:** Baixo | **Benefício:** Baixo

**Descrição:** Métodos no NotificationService misturam inglês e português 
(_showSuccessSnackBar vs scheduleReminder). Model também mistura idiomas em 
propriedades e métodos. Isso prejudica legibilidade e padronização do código.

**Prompt de Implementação:**

Padronize toda nomenclatura para português seguindo o padrão já estabelecido no 
projeto. Renomeie métodos privados como _mostrarSnackBarSucesso, propriedades do 
model para português, e mantenha consistência em todo o módulo. Use refactoring 
tools para garantir que todas as referências sejam atualizadas.

**Dependências:** notification_service.dart, condicao_corporal_model.dart

**Validação:** Verificar ausência de erros de compilação, confirmar consistência 
linguística, testar funcionalidades após renomeação

---

## 🟢 Complexidade BAIXA

### 8. [DOC] - Documentação ausente nos services

**Status:** 🔴 Pendente | **Execução:** Simples | **Risco:** Baixo | **Benefício:** Baixo

**Descrição:** DialogService e NotificationService não possuem documentação adequada 
dos métodos públicos. Faltam comentários explicando parâmetros, comportamentos 
esperados e casos de uso dos services.

**Prompt de Implementação:**

Adicione dartdoc comments em todos os métodos públicos dos services. Documente 
parâmetros, valores de retorno, exceções que podem ser lançadas, e exemplos de uso 
quando apropriado. Inclua informações sobre thread-safety e comportamento assíncrono 
dos métodos.

**Dependências:** dialog_service.dart, notification_service.dart

**Validação:** Verificar que documentação aparece no IDE, revisar clareza das 
explicações, confirmar cobertura de todos os métodos públicos

---

### 9. [TEST] - Falta de validação de entrada nos widgets

**Status:** 🔴 Pendente | **Execução:** Simples | **Risco:** Baixo | **Benefício:** Médio

**Descrição:** Widgets como InputCard não validam adequadamente entradas do usuário 
antes de chamar métodos do controller. Não há feedback visual para entradas inválidas 
nem prevenção de chamadas com dados inconsistentes.

**Prompt de Implementação:**

Adicione validação visual nos widgets de entrada. Implemente feedback imediato para 
seleções inválidas, desabilite botões quando dados estão incompletos, adicione 
tooltips explicativos para ajudar o usuário, e garanta que apenas dados válidos 
sejam enviados ao controller.

**Dependências:** widgets/input_card.dart, widgets/result_card.dart

**Validação:** Testar com entradas inválidas, verificar feedback visual adequado, 
confirmar prevenção de estados inconsistentes

---

## 🔧 Comandos Rápidos

Para solicitar implementação específica, use:
- `Executar #[número]` - Para que a IA implemente uma issue específica
- `Detalhar #[número]` - Para obter prompt mais detalhado sobre implementação  
- `Focar [complexidade]` - Para trabalhar apenas com issues de uma complexidade
- `Agrupar [tipo]` - Para executar todas as issues de um tipo
- `Validar #[número]` - Para que a IA revise implementação concluída