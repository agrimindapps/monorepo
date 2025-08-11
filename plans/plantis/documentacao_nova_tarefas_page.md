# Documentação Técnica - Página Nova Tarefas (app-plantas)

## 📋 Visão Geral

A página **Nova Tarefas** é o centro de gerenciamento de tarefas de cuidado com plantas do aplicativo app-plantas. Funciona como um dashboard inteligente que organiza as tarefas por temporalidade, permitindo aos usuários visualizar, completar e gerenciar todas as atividades de cuidado de suas plantas de forma eficiente e contextualizada.

## 🏗️ Arquitetura da Página

### Estrutura de Arquivos

```
lib/app-plantas/pages/nova_tarefas_page/
├── bindings/
│   └── nova_tarefas_binding.dart             # Injeção de dependências GetX
├── controller/
│   └── nova_tarefas_controller.dart          # Controller principal de tarefas
├── services/
│   ├── care_type_service.dart                # Serviço de tipos de cuidado
│   └── date_formatting_service.dart          # Serviço de formatação de datas
├── views/
│   └── nova_tarefas_view.dart                # Interface principal da página
├── widgets/
│   ├── estatisticas_widget.dart              # Widget de estatísticas (futuro)
│   ├── tarefa_card_widget.dart               # Card individual de tarefa
│   └── tarefa_details_dialog.dart            # Dialog de detalhes da tarefa
├── issues.md                                 # Documentação de melhorias
└── index.dart                                # Arquivo de exportação
```

## 🎨 Interface Visual

### Layout Geral
A página utiliza um **Scaffold** com estrutura vertical organizada:
```dart
Column([
  _buildHeader(),           // Título + contador de tarefas
  _buildToggleButtons(),    // Toggle "Para hoje" / "Próximas"
  Expanded(
    child: _buildTasksList() // Lista contextual de tarefas
  )
])
```

### Cores e Sistema Visual
Utiliza **PlantasColors** para consistência visual:

#### Cores Principais:
```dart
PlantasColors = {
  'primaryColor': Color(0xFF20B2AA),     // Turquesa
  'backgroundColor': Color(0xFFF5F5F5),  // Fundo claro
  'surfaceColor': Color(0xFFFFFFFF),     // Superfícies/Cards
  'textColor': Color(0xFF000000DE),      // Texto principal
  'subtitleColor': Color(0xFF757575)     // Texto secundário
}
```

### Componentes Visuais

#### 1. **Header com Contador Dinâmico**
```dart
Row(
  children: [
    Text('Tarefas', fontSize: 28, fontWeight: bold),
    Container( // Badge contador dinâmico
      decoration: // Border + background primário
      child: Text('X tarefa(s)')
    )
  ]
)
```

#### 2. **Toggle de Visualização**
```dart
Row([
  GestureDetector( // "Para hoje"
    decoration: viewMode == 'hoje' 
      ? BoxDecoration(color: primaryColor, borderRadius: 16)
      : BoxDecoration(color: transparent)
    child: Row([
      Text('Para hoje'),
      _buildTabBadge(countTarefasHoje)
    ])
  ),
  GestureDetector( // "Próximas" 
    decoration: viewMode == 'proximas'
      ? BoxDecoration(color: primaryColor, borderRadius: 16) 
      : BoxDecoration(color: transparent)
    child: Row([
      Text('Próximas'),
      _buildTabBadge(countTarefasProximas)
    ])
  )
])
```

#### 3. **Lista Contextual de Tarefas**

##### **Modo "Para Hoje"**
```dart
ListView(
  sections: [
    // Seção Tarefas Pendentes
    if (tarefasPendentes.isNotEmpty) [
      _buildSectionHeader('Tarefas pendentes', count),
      ...tarefasPendentes.map(TarefaCardWidget)
    ],
    
    // Seção Tarefas Concluídas  
    if (tarefasConcluidas.isNotEmpty) [
      _buildSectionHeader('Tarefas concluídas', count),
      ...tarefasConcluidas.map(TarefaCardWidget(isCompleted: true))
    ]
  ]
)
```

##### **Modo "Próximas"**
```dart
ListView(
  groupedByDate: {
    'Hoje, 15 de Janeiro': [tasks...],
    'Amanhã, 16 de Janeiro': [tasks...], 
    'Segunda-feira, 20 de Janeiro': [tasks...]
  }
)
```

## 💾 Modelos e Estados

### TarefaModel (Entidade Principal)
```dart
class TarefaModel extends BaseModel {
  String plantaId;              // ID da planta relacionada
  String tipoCuidado;           // Tipo de cuidado ('agua', 'adubo', etc.)
  DateTime dataExecucao;        // Data prevista de execução
  bool concluida;               // Status de conclusão
  DateTime? dataConclusao;      // Data real de conclusão
  String? observacoes;          // Observações do usuário
  int intervaloDias;            // Intervalo para próxima tarefa
}
```

### Estados do Controller
```dart
// Estados reativos principais
var tarefasHoje = <TarefaModel>[].obs;           // Tarefas de hoje (pendentes)
var tarefasConcluidasHoje = <TarefaModel>[].obs; // Tarefas concluídas hoje
var tarefasProximas = <TarefaModel>[].obs;       // Tarefas futuras
var tarefasAtrasadas = <TarefaModel>[].obs;      // Tarefas vencidas

// Estados de controle
var isLoading = false.obs;                       // Loading
var viewMode = 'hoje'.obs;                       // Modo de visualização
var selectedTabIndex = 0.obs;                    // Tab ativa (futuro)
```

### Estatísticas Computadas
```dart
Map<String, int> get estatisticas => {
  'hoje': tarefasHoje.length,
  'proximas': tarefasProximas.length,  
  'atrasadas': tarefasAtrasadas.length,
  'total': tarefasHoje.length + tarefasProximas.length + tarefasAtrasadas.length
}
```

## ⚙️ Funcionalidades

### 1. **Visualização Dual Contextual**
- **Modo "Para Hoje"**: Foco nas tarefas do dia atual
  - Seção "Tarefas pendentes" (ainda não realizadas)
  - Seção "Tarefas concluídas" (já realizadas hoje)
  - Visual diferenciado para tarefas concluídas
- **Modo "Próximas"**: Visão temporal das próximas tarefas
  - Agrupamento automático por data
  - Headers contextuais ("Hoje", "Amanhã", "Segunda-feira")
  - Ordenação cronológica

### 2. **Gerenciamento de Tarefas**
- **Visualizar Detalhes**: Tap no card → Dialog completo
- **Completar Tarefa**: Dialog com seleção de data de conclusão
- **Reagendar Tarefa**: Modificar data de execução
- **Cancelar Tarefa**: Marcar como não necessária

### 3. **Sistema de Estados Visuais**
- **Estados Vazios Contextuais**:
  - "Nenhuma tarefa para hoje! 🎉" (modo hoje)
  - "Nenhuma tarefa próxima 📅" (modo próximas)
- **Loading**: Indicador centralizado durante carregamento
- **RefreshIndicator**: Pull-to-refresh em ambos os modos

### 4. **Carregamento Inteligente**
- **Carregamento Paralelo**: Múltiplas consultas simultâneas
- **Defensive Programming**: Verificações de controller registrado
- **Error Handling**: Tratamento robusto de exceções

### 5. **Formatação Inteligente de Datas**
- **Relativa**: "Hoje", "Amanhã", "Em 3 dias"
- **Absoluta**: "Segunda-feira, 15 de Janeiro" 
- **Contextual**: Adapta formato conforme proximidade

## 🔧 Lógica de Negócio (Controller)

### NovaTarefasController
**Responsabilidade**: Orchestração de dados de tarefas e interações de UI

#### Inicialização:
```dart
@override
void onInit() {
  super.onInit();
  _initializeService();  // Inicializar SimpleTaskService
}

Future<void> _initializeService() async {
  await SimpleTaskService.instance.initialize();
  carregarTarefas();  // Carregar dados iniciais
}
```

#### Carregamento Paralelo:
```dart
Future<void> carregarTarefas() async {
  final results = await Future.wait([
    SimpleTaskService.instance.getTodayTasks(),         // Tarefas hoje
    SimpleTaskService.instance.getTodayCompletedTasks(), // Concluídas hoje
    SimpleTaskService.instance.getUpcomingTasks(),      // Próximas
    SimpleTaskService.instance.getOverdueTasks(),       // Atrasadas
  ]);
  
  // Atualização atômica de todos os estados
  tarefasHoje.value = results[0];
  tarefasConcluidasHoje.value = results[1];
  tarefasProximas.value = results[2];
  tarefasAtrasadas.value = results[3];
}
```

#### Operações de Tarefa:
```dart
// Conclusão com data personalizada
marcarTarefaConcluidaComData(tarefa, intervaloDias, dataConclusao)

// Reagendamento
reagendarTarefa(tarefa, novaData) 

// Cancelamento (sem gerar próxima)
cancelarTarefa(tarefa)
```

### Estados de Feedback:
- **Success**: Snackbar verde com detalhes da ação
- **Error**: Snackbar vermelho com mensagem específica
- **Loading**: Estados individuais por operação

## 🛠️ Serviços Especializados

### CareTypeService
**Responsabilidade**: Padronização de tipos de cuidado

#### Funcionalidades Principais:
```dart
// Nomenclatura consistente
getName(tipoCuidado) -> String      // "Regar", "Fertilizar"
getNoun(tipoCuidado) -> String      // "Água", "Fertilizante"  

// Visual consistency
getIcon(tipoCuidado) -> IconData    // Icons específicos
getSemanticColor(tipoCuidado) -> Color  // Cores semânticas

// Configurações
getDefaultInterval(tipoCuidado) -> int    // Intervalos padrão
getDescription(tipoCuidado) -> String     // Descrições detalhadas
```

#### Mapeamentos Semânticos:
```dart
'agua' -> {
  nome: 'Regar',
  substantivo: 'Água', 
  icone: Icons.water_drop,
  cor: Color(0xFF2196F3),  // Azul
  intervalo: 1
}

'adubo' -> {
  nome: 'Fertilizar',
  substantivo: 'Fertilizante',
  icone: Icons.grass, 
  cor: Color(0xFF4CAF50),  // Verde
  intervalo: 7
}
```

### DateFormattingService  
**Responsabilidade**: Formatação robusta e consistente de datas

#### Funcionalidades:
```dart
// Formatação relativa inteligente
formatRelative(DateTime) -> String
// "Hoje", "Amanhã", "Em 3 dias", "Há 2 semanas"

// Formatação absoluta locale-aware  
formatAbsolute(DateTime, locale) -> String
// "15/01/2025"

// Formatação para seleção
formatSelection(DateTime) -> String
// "Hoje" ou "15/01/2025"

// Formatação com contexto
formatWithWeekday(DateTime) -> String
// "Segunda-feira, 15 de Janeiro"
```

#### Características Robustas:
- **Validação de Range**: Datas entre 1900-2100
- **Timezone Handling**: Normalização UTC
- **Error Recovery**: Fallbacks seguros
- **Edge Cases**: Tratamento de datas inválidas
- **Locale Support**: Suporte a múltiplos idiomas

## 🧩 Widgets Especializados

### TarefaCardWidget
**Responsabilidade**: Representação visual individual de tarefa

#### Estrutura:
```dart
StatefulWidget + Estado Assíncrono
├── _loadPlantaInfo() (carregamento de dados da planta)
└── build() (interface reativa)
    ├── Icon + CareType visual
    ├── Informações da planta (nome, loading, erro)
    └── PlantIcon (ícone da planta)
```

#### Estados Visuais:
```dart
// Estado Pendente
decoration: BoxDecoration(
  color: backgroundColor,
  borderRadius: 12,
  boxShadow: cardShadow  // Elevação
)

// Estado Concluído
decoration: BoxDecoration(
  color: backgroundColor,
  borderRadius: 12, 
  border: Border.all(color: secundaryColor, width: 1)  // Sem elevação
)
text: TextDecoration.lineThrough  // Texto riscado
```

#### Características:
- **Async Loading**: Carregamento assíncrono de dados da planta
- **Timeout Protection**: Timeout de 10s com fallback
- **Error Recovery**: Estado de erro com retry manual
- **Visual States**: Diferenciação visual completa/pendente

### TarefaDetailsDialog
**Responsabilidade**: Interface completa para interação com tarefa

#### Estrutura de Dados:
```dart
StatefulWidget + Multi-Repository Loading
├── PlantaRepository.findById(plantaId)
├── PlantaConfigRepository.findByPlantaId(plantaId)  
└── Dialog Interface
    ├── Header (ícone + nome cuidado + planta)
    ├── Info Cards (vencimento, próximo, intervalo)
    ├── Date Picker (seleção data conclusão)
    └── Actions (voltar, concluir)
```

#### Info Cards:
```dart
_buildInfoCard(
  'Data de vencimento',
  formatRelative(tarefa.dataExecucao),
  Icons.calendar_today,
  _isOverdue() ? errorColor : careTypeColor
)

_buildInfoCard(
  'Próximo vencimento', 
  formatRelative(proximoVencimento),
  Icons.schedule,
  primaryColor
)
```

#### Características:
- **Multi-Data Loading**: Planta + configurações simultaneamente
- **Smart Date Calculation**: Cálculo automático da próxima tarefa
- **Overdue Detection**: Detecção visual de tarefas atrasadas
- **Locale-Aware DatePicker**: Seletor de data localizado
- **Async Operations**: Todas as operações são assíncronas

## 🔗 Integrações e Dependências

### Services Integrados:
1. **SimpleTaskService** - CRUD completo de tarefas
2. **PlantaRepository** - Dados das plantas
3. **PlantaConfigRepository** - Configurações de cuidado
4. **PlantasColors** - Sistema de cores consistente
5. **PlantasDesignTokens** - Tokens de design (cores dinâmicas)

### Páginas Conectadas:
1. **MinhasPlantasPage** - Origem das plantas que geram tarefas
2. **PlantaDetalhesPage** - Pode navegar para tarefas da planta
3. **PlantaFormPage** - Configurações que afetam tarefas

### Navegação:
- **Entrada**: `AppBottomNavWidget` (tab "Tarefas")
- **RefreshIndicator**: Pull-to-refresh para atualização
- **Dialog System**: Modal para detalhes e conclusão

## 📱 Experiência do Usuário

### Fluxos Principais:

#### **Fluxo de Visualização Diária**
1. **Acesso Tab Tarefas** → Modo "Para hoje" (padrão)
2. **Seções Separadas** → Pendentes vs Concluídas
3. **Visual Diferenciado** → Cards com/sem elevação + texto riscado
4. **Estado Vazio Motivacional** → "Nenhuma tarefa para hoje! 🎉"

#### **Fluxo de Planejamento**  
1. **Toggle "Próximas"** → Visão temporal futura
2. **Agrupamento por Data** → Headers contextuais automáticos
3. **Formatação Inteligente** → "Hoje", "Amanhã", dia da semana
4. **Estado Vazio Informativo** → "Nenhuma tarefa próxima 📅"

#### **Fluxo de Conclusão de Tarefa**
1. **Tap no Card** → Dialog de detalhes
2. **Informações Completas** → Vencimento + próxima + intervalo  
3. **Seleção de Data** → DatePicker para data de conclusão
4. **Conclusão** → Feedback + atualização automática + próxima gerada

### Estados de Feedback:
- **Loading**: Spinner centralizado durante carregamento inicial
- **Success**: Snackbar com nome da tarefa e ação realizada
- **Error**: Snackbar com mensagem específica do erro
- **Pull-to-Refresh**: Indicador visual de atualização
- **Empty States**: Mensagens contextuais motivacionais

### Performance e Responsividade:
- **Parallel Loading**: Carregamento simultâneo de múltiplos tipos
- **Defensive Programming**: Verificações de controlador registrado
- **Timeout Protection**: Timeouts em operações de banco
- **Error Recovery**: Botões de retry em estados de erro
- **Atomic Updates**: Atualizações atômicas de estado

## 🔒 Validações e Regras de Negócio

### Carregamento de Dados:
```dart
// Carregamento paralelo com timeout
final results = await Future.wait([
  getTodayTasks(),
  getTodayCompletedTasks(), 
  getUpcomingTasks(),
  getOverdueTasks()
]);
```

### Validação de Estados:
```dart
// Verificação defensiva de controller
if (!Get.isRegistered<NovaTarefasController>()) {
  return CircularProgressIndicator();
}
```

### Tratamento de Erros:
```dart
// Carregamento com timeout e retry
final result = await Future.any([
  repository.findById(id),
  Future.delayed(Duration(seconds: 10), () => throw TimeoutException())
]);
```

### Regras de Negócio:
- **Conclusão de Tarefa**: Gera automaticamente próxima tarefa baseada no intervalo
- **Reagendamento**: Mantém configurações originais, muda apenas data
- **Cancelamento**: Marca como concluída sem gerar próxima
- **Intervalo Dinâmico**: Usa configurações da planta ou valores padrão

## 🚀 Melhorias Futuras Identificadas

### UX/UI:
1. **Swipe Actions**: Conclusão e reagendamento por swipe
2. **Batch Operations**: Seleção múltipla de tarefas
3. **Quick Actions**: Botões de ação rápida nos cards
4. **Animation**: Transições suaves entre estados
5. **Notifications**: Lembretes push para tarefas

### Funcionalidades:
1. **Filtros Avançados**: Por tipo de cuidado, planta, status
2. **Ordenação**: Por prioridade, data, tipo de cuidado
3. **Estatísticas**: Widget de estatísticas implementado
4. **Calendar View**: Visualização em calendário
5. **Histórico**: Página de histórico de tarefas concluídas

### Performance:
1. **Infinite Scroll**: Para listas muito grandes
2. **Background Sync**: Sincronização periódica automática
3. **Offline Support**: Cache para uso offline
4. **Incremental Updates**: Atualizações incrementais vs full reload

### Integrações:
1. **Calendar Integration**: Integração com calendário do sistema
2. **Weather API**: Ajuste de tarefas baseado no clima
3. **Smart Suggestions**: IA para sugerir melhores horários
4. **Photo Documentation**: Fotos de antes/depois dos cuidados

## 📊 Arquitetura de Dados

### Fluxo de Dados:
```
SimpleTaskService (Single Source of Truth)
├── getTodayTasks() → tarefasHoje
├── getTodayCompletedTasks() → tarefasConcluidasHoje
├── getUpcomingTasks() → tarefasProximas
└── getOverdueTasks() → tarefasAtrasadas

PlantaRepository + PlantaConfigRepository
└── Dados complementares para exibição
```

### Estados Reativos:
```
Controller (Observable States)
├── RxList<TarefaModel> tarefasHoje
├── RxList<TarefaModel> tarefasConcluidasHoje
├── RxList<TarefaModel> tarefasProximas
├── RxBool isLoading
└── RxString viewMode

View (Reactive UI)
├── Obx(() => _buildTasksList())
├── Obx(() => _buildToggleButtons())
└── Obx(() => _buildHeader())
```

### Padrões de Operação:
- **Optimistic Updates**: UI atualiza imediatamente, reverte em caso de erro
- **Error Recovery**: Retry automático para operações críticas
- **State Consistency**: Recarregamento completo após modificações
- **Defensive Programming**: Múltiplas verificações de segurança

---

**Data da Documentação**: Agosto 2025  
**Versão do Código**: Baseada na estrutura atual do projeto  
**Autor**: Documentação técnica para migração de linguagem

## 📊 Estatísticas do Código

### Métricas:
- **Linhas de Código**: ~2.100 linhas
- **Arquivos**: 9 arquivos principais  
- **Services**: 2 services especializados
- **Widgets**: 3 widgets principais
- **Estados Reativos**: 8+ estados gerenciados
- **Funcionalidades**: 15+ funcionalidades implementadas
- **Modos de Visualização**: 2 modos contextuais
- **Tipos de Cuidado**: 6 tipos padronizados

### Complexidade:
- **Arquitetura**: Intermediária (service-driven com estados reativos)
- **Async Operations**: Múltiplas operações assíncronas paralelas
- **Error Handling**: Robusto com timeouts e fallbacks
- **Date Management**: Sistema avançado de formatação temporal
- **UI States**: Múltiplos estados visuais contextuais
- **Integration**: 5+ services e repositórios integrados