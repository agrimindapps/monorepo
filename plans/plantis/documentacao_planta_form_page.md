# Documentação Técnica - Página Planta Form (app-plantas)

## 📋 Visão Geral

A página **Planta Form** é o formulário principal de criação e edição de plantas no aplicativo app-plantas. Funciona como interface completa para cadastro de dados básicos, configuração de foto, seleção de espaço e definição de cronograma de cuidados, com validação robusta e experiência de usuário otimizada para ambos os cenários: criação e edição.

## 🏗️ Arquitetura da Página

### Estrutura de Arquivos

```
lib/app-plantas/pages/planta_form_page/
├── planta_form_binding.dart                    # Injeção de dependências GetX
├── planta_form_controller.dart                 # Controller principal (arquitetura clássica)
├── planta_form_view.dart                       # Interface principal do formulário
├── services/
│   ├── error_handler_service.dart              # Tratamento de erros (futuro)
│   ├── loading_state_service.dart              # Gerenciamento de estados de loading
│   ├── planta_cadastro_service.dart            # Service orquestrador de cadastro
│   ├── planta_validation_service.dart          # Service de validação completo
│   └── task_creation_service.dart              # Service de criação de tarefas
└── index.dart                                  # Arquivo de exportação
```

## 🎨 Interface Visual

### Layout Geral
A página utiliza um **Scaffold** com formulário scrollável:
```dart
Form(
  key: formKey,
  child: SingleChildScrollView([
    _buildBasicInfoSection(),       // Nome + Foto + Espaço
    _buildConfiguracoesSection()   // 6 cards de configuração de cuidados
  ])
)
```

### Cores e Sistema Visual
Utiliza **PlantasColors** para consistência visual completa:

#### Cores Principais:
```dart
PlantasColors = {
  'primaryColor': Color(0xFF20B2AA),         // Turquesa
  'surfaceColor': Color(0xFFFFFFFF),         // Fundo de cards/AppBar
  'backgroundColor': Color(0xFFF5F5F5),      // Fundo geral da página
  'borderColor': Color(0xFFE0E0E0),          // Bordas de campos
  'textColor': Color(0xFF000000DE),          // Texto principal
  'subtitleColor': Color(0xFF757575),        // Texto secundário
  'errorColor': Colors.red,                   // Estados de erro
  'errorBackgroundColor': Color(0xFFFFF3F3), // Fundo de erro
  'errorBorderColor': Color(0xFFFFCDD2)       // Borda de erro
}
```

### Componentes Visuais

#### 1. **AppBar Dinâmica**
```dart
AppBar(
  title: Text(pageTitle),           // "Nova Planta" ou "Editar Planta"
  backgroundColor: PlantasColors.surfaceColor,
  leading: IconButton(Icons.arrow_back),
  actions: [
    IconButton(                     // Botão salvar com loading
      icon: isLoading ? CircularProgressIndicator : Icons.check
    )
  ]
)
```

#### 2. **Seção de Dados Básicos**

##### **Campo Nome (Obrigatório)**
```dart
TextFormField(
  controller: nomeController,
  decoration: InputDecoration(
    hintText: 'Digite o nome da planta',
    border: InputBorder.none
  ),
  textCapitalization: TextCapitalization.words,
  validator: validarNome
)
```

##### **Seletor de Foto**
```dart
GestureDetector(
  onTap: selecionarFoto,
  child: Row([
    _buildPhotoPreview(),          // Preview ou ícone padrão
    Column([
      Text(hasPhoto ? 'Alterar foto' : 'Adicionar foto'),
      Text('Toque para alterar ou remover')
    ])
  ])
)
```

Estados da foto:
- **Sem foto**: Container com ícones de adicionar
- **Com foto**: Imagem 60x60 + overlay de edição
- **Erro de decode**: Fallback para ícone padrão

##### **Seletor de Espaço**
```dart
GestureDetector(
  onTap: _showSpaceSelector,
  child: Row([
    Text(espacoSelecionado?.nome ?? 'Escolher espaço'),
    Icon(Icons.chevron_right)
  ])
)
```

#### 3. **Seção de Configurações de Cuidados**

##### **Cards de Cuidado (6 tipos)**
```dart
_buildCuidadoCard(
  titulo: 'Água',
  icone: Icons.water_drop,
  cor: Color(0xFF2196F3),           // Azul semântico
  ativo: aguaAtiva,                 // Switch reativo
  intervalo: intervaloRegaDias,     // Configuração de intervalo
  proximaData: primeiraRega,        // Data de primeira execução
  onToggle: toggleAgua,             // Callbacks de ação
  onIntervaloChanged: setIntervaloRega,
  onDataChanged: setPrimeiraRega
)
```

**Tipos de Cuidados Configuráveis**:
1. **Água** (Icons.water_drop, azul)
2. **Adubo** (Icons.eco, verde) 
3. **Banho de sol** (Icons.wb_sunny, laranja)
4. **Inspeção de pragas** (Icons.search, roxo)
5. **Poda** (Icons.content_cut, marrom)
6. **Replantar** (Icons.change_circle, azul acinzentado)

##### **Interface de Configuração Expandível**
```dart
if (ativo.value) [
  // Seletor de intervalo
  GestureDetector(
    onTap: _showIntervalSelector,
    child: Row([
      Text('Intervalo de ${titulo.toLowerCase()}'),
      Text(_getIntervaloText(intervalo.value, titulo))  // "Todo dia", "Quinzenal"
    ])
  ),
  
  // Seletor de data
  GestureDetector(
    onTap: _showDateSelector,
    child: Row([
      Text('Última ${titulo.toLowerCase()}'),
      Text(_getDataText(proximaData.value))             // "Hoje", "15/jan"
    ])
  )
]
```

## 💾 Modelos e Estados

### Estados do Controller (Reativos)
```dart
// Controles de formulário
final formKey = GlobalKey<FormState>();
final nomeController = TextEditingController();
final especieController = TextEditingController();
final observacoesController = TextEditingController();

// Estados de dados
var fotoPlanta = Rx<String?>(null);              // Foto em Base64
var espacoSelecionado = Rx<EspacoModel?>(null);  // Espaço selecionado
var espacosDisponiveis = <EspacoModel>[].obs;    // Lista de espaços

// Estados de loading
var isLoading = false.obs;                       // Loading geral
var configuracoes = Rx<PlantaConfigModel?>(null); // Configurações existentes (edit)

// Estados de configuração de cuidados (6 tipos)
var aguaAtiva = true.obs;
var intervaloRegaDias = 1.obs;
var primeiraRega = Rx<DateTime?>(null);

var aduboAtivo = true.obs;
var intervaloAdubacaoDias = 1.obs;
var primeiraAdubacao = Rx<DateTime?>(null);

// ... (padrão para todos os 6 tipos de cuidado)
```

### Getters Dinâmicos
```dart
// Estados computados
bool get isEditMode => plantaOriginal != null;
String get pageTitle => isEditMode ? 'Editar Planta' : 'Nova Planta';
String get actionButtonText => isEditMode ? 'Salvar Alterações' : 'Cadastrar Planta';
```

### Dados de Entrada
```dart
class PlantaData {
  final String nome;                    // Nome obrigatório
  final String? especie;                // Espécie opcional
  final String? espacoId;               // ID do espaço selecionado
  final String? observacoes;            // Observações opcionais
  final List<String> imagePaths;        // Caminhos de imagens (legacy)
  final String? fotoBase64;             // Foto principal em Base64
}

class PlantCareConfiguration {
  // Configurações para cada tipo de cuidado
  final bool aguaAtiva;
  final int intervaloRegaDias;
  final DateTime? primeiraRega;
  // ... (padrão para todos os 6 tipos)
}
```

## ⚙️ Funcionalidades

### 1. **Modo Dual (Criar/Editar)**
- **Modo Criação**: Formulário limpo com valores padrão
- **Modo Edição**: Pré-preenchimento com dados existentes
- **Detecção Automática**: Baseada na presença de `plantaOriginal`
- **Carregamento de Dados**: Assíncrono para dados relacionados

### 2. **Gerenciamento de Foto**
- **Seleção de Fonte**: Bottom sheet com câmera/galeria/remover
- **Processamento**: Redimensionamento (800x800) + compressão (85%)
- **Formato**: Conversão para Base64 para armazenamento
- **Preview**: Visualização em tempo real com overlay de edição
- **Remoção**: Opção disponível apenas quando há foto

### 3. **Seletor de Espaço Avançado**
- **Lista de Espaços**: Bottom sheet com espaços disponíveis
- **Visual Diferenciado**: Selecionado vs não selecionado
- **Ícones Contextuais**: Por tipo de espaço (quarto, cozinha, etc.)
- **Criação Personalizada**: Dialog para espaço customizado com validação
- **Prevenção de Duplicatas**: Reuso de espaço existente com mesmo nome

### 4. **Configuração de Cuidados Avançada**
- **6 Tipos de Cuidados**: Cada um com switch individual
- **Configuração Granular**: Intervalo + data de primeira execução
- **Seletor de Intervalo**: ListWheelScrollView (1-365 dias)
- **Textos Inteligentes**: "Todo dia", "Quinzenal", "Todo mês", etc.
- **DatePicker**: Com localização pt_BR e validação de range
- **Valores Padrão**: Configurações sensatas por tipo de cuidado

### 5. **Sistema de Validação Robusto**
- **Validação de Nome**: 2-50 caracteres, caracteres válidos
- **Validação de Imagem**: Base64 válido, tamanho máximo 5MB
- **Validação de Configurações**: Intervalos válidos (1-365 dias)
- **Validação de Datas**: Não no passado, máximo 1 ano no futuro
- **Validação Completa**: Todos os campos ativos antes de salvar

## 🔧 Arquitetura de Services

### PlantaFormController
**Padrão**: Controlador clássico com delegação parcial para services

#### Responsabilidades do Controller:
- **Gerenciamento de Estado**: Estados reativos e UI state
- **Interações de UI**: Callbacks, navegação, dialogs
- **Orquestração**: Coordenação entre view e services
- **Validação de Entrada**: Validações básicas inline

### Services Especializados:

#### **PlantaCadastroService (Orquestrador)**
**Responsabilidade**: Processo completo de cadastro com progress tracking

##### Fluxo de Cadastro:
```dart
Future<PlantaCadastroResult> cadastrarPlanta() async {
  // FASE 1: Validação (10%)
  validateData()
  
  // FASE 2: Inicialização (20%)
  initializeServices()
  
  // FASE 3: Criação da planta (40%)
  createPlant()
  
  // FASE 4: Configurações (60%)
  saveConfiguration()
  
  // FASE 5: Tarefas (80%)
  createInitialTasks()
  
  // FASE 6: Finalização (100%)
  return result
}
```

#### **PlantaValidationService**
**Responsabilidade**: Validações centralizadas seguindo regras de negócio

##### Validações Implementadas:
```dart
// Validações básicas
validateNome(String? nome) -> ValidationResult
validateEspecie(String? especie) -> ValidationResult
validateImageBase64(String? image) -> ValidationResult

// Validações de cuidados
validateIntervaloDias(int? dias, String tipo) -> ValidationResult
validatePrimeiraData(DateTime? data, String tipo) -> ValidationResult

// Validação completa
validateCompleteForm(...allFields) -> FormValidationResult
```

#### **TaskCreationService**
**Responsabilidade**: Criação de cronograma inicial de tarefas

##### Funcionalidades:
- **Configuração Padrão**: Valores sensatos para novos usuários
- **Cronograma Calculado**: Datas baseadas em intervalos
- **Resumo de Schedule**: Preview do que será criado
- **Criação em Lote**: Todas as tarefas ativas de uma vez

#### **LoadingStateService**
**Responsabilidade**: Estados de loading com progresso

##### Estados Gerenciados:
```dart
enum LoadingOperation {
  savingPlant,
  loadingSpaces,
  processingImage,
  validatingData
}

// Métodos principais
executeWithLoading(operation, function, options)
updateProgress(operation, progress, message)
```

## 🧩 Componentes de Interface Avançados

### Seletor de Intervalo (ListWheelScrollView)
```dart
SizedBox(
  height: 200,
  child: Row([
    Text('A cada'),
    
    ListWheelScrollView.useDelegate(
      itemExtent: 50,
      onSelectedItemChanged: (index) => selectedDays = index + 1,
      childDelegate: ListWheelChildBuilderDelegate(
        builder: (context, index) => Text((index + 1).toString()),
        childCount: 365
      )
    ),
    
    Text('dias')
  ])
)
```

### Bottom Sheet de Seleção de Espaços
```dart
Get.bottomSheet(
  Container(
    decoration: // Rounded top corners
    child: Column([
      // Handle bar
      Container(width: 40, height: 4, rounded),
      
      // Header
      Text('Escolher espaço'),
      
      // Lista dinâmica
      ListView.builder(
        itemCount: espacosDisponiveis.length + 1, // +1 para personalizado
        itemBuilder: (context, index) => {
          if (isCustomOption) return CustomSpaceOption(),
          return SpaceListTile(espaco, isSelected)
        }
      ),
      
      // Cancel button
      TextButton('Cancelar')
    ])
  )
)
```

### Dialog de Espaço Personalizado
```dart
Form(
  key: formKey,
  child: Column([
    Text('Espaço personalizado'),
    Text('Digite o nome do local onde a planta ficará'),
    
    TextFormField(
      autofocus: true,
      textCapitalization: TextCapitalization.words,
      validator: (value) => {
        if (isEmpty) return 'Digite o nome do espaço',
        if (length < 2) return 'Nome deve ter pelo menos 2 caracteres'
      }
    ),
    
    Row([
      TextButton('Cancelar'),
      ElevatedButton('Confirmar', onPressed: validateAndCreate)
    ])
  ])
)
```

## 🔗 Integrações e Dependências

### Services Integrados:
1. **PlantaRepository** - CRUD básico de plantas
2. **PlantaConfigRepository** - Configurações de cuidado
3. **EspacoRepository** - CRUD de espaços
4. **PlantCareService** - Service domain de plantas
5. **SimpleTaskService** - Criação de tarefas iniciais
6. **ImageService** - Processamento de imagens (no controller)

### Páginas Conectadas:
1. **MinhasPlantasPage** - Origem via FAB ou edição
2. **PlantaDetalhesPage** - Retorno após edição bem-sucedida

### Navegação:
- **Entrada Criação**: `PlantasNavigator.toAdicionarPlanta()`
- **Entrada Edição**: `PlantasNavigator.toEditarPlanta(planta)`
- **Saída**: `Get.back(result: true)` com resultado de sucesso

## 📱 Experiência do Usuário

### Fluxos Principais:

#### **Fluxo de Criação**
1. **Entrada** → Formulário limpo com valores padrão
2. **Preenchimento** → Nome (obrigatório) + dados opcionais
3. **Configuração** → Ativação/configuração de cuidados
4. **Validação** → Verificação completa antes de salvar
5. **Progress** → Feedback visual do progresso (6 fases)
6. **Resultado** → Snackbar + navegação de volta

#### **Fluxo de Edição**
1. **Entrada com Dados** → Carregamento assíncrono
2. **Pré-preenchimento** → Todos os campos populados
3. **Modificação** → Alterações pelo usuário
4. **Validação** → Mesmas regras da criação
5. **Atualização** → Processo otimizado (sem criação de tarefas)
6. **Sincronização** → Atualização automática em outras telas

#### **Fluxo de Foto**
1. **Seleção** → Bottom sheet com 2-3 opções
2. **Captura/Seleção** → ImagePicker com configurações
3. **Processamento** → Redimensionamento + compressão
4. **Preview** → Visualização imediata + overlay
5. **Persistência** → Base64 armazenado no modelo

#### **Fluxo de Espaço**
1. **Seleção** → Bottom sheet com lista
2. **Visualização** → Espaços com ícones e seleção visual
3. **Personalização** → Dialog para criar novo espaço
4. **Validação** → Verificação de duplicatas
5. **Criação** → Persistência + adição à lista + seleção automática

### Estados de Feedback:
- **Loading**: AppBar com spinner, mensagens por fase
- **Success**: Snackbar verde com nome da planta
- **Error**: Snackbar vermelho com mensagem específica
- **Validation**: Mensagens inline + snackbar de resumo
- **Progress**: Indicador de progresso para cadastro

### Elementos de UX:
- **Auto-capitalização**: Campos de texto com capitalização adequada
- **Placeholders Contextuais**: Hints específicos por campo
- **Visual Selection**: Estados visuais claros para seleções
- **Keyboard Types**: Teclados otimizados por tipo de campo
- **Focus Management**: Autofocus em campos importantes
- **Gesture Recognition**: Taps e long presses contextuais

## 🔒 Validações e Regras de Negócio

### Validações de Campo:
```dart
// Nome (obrigatório)
validateNome(String? value) {
  if (isEmpty) return 'Nome é obrigatório'
  if (length < 2) return 'Nome deve ter pelo menos 2 caracteres'
  if (!isValidPlantName) return 'Nome contém caracteres inválidos'
}

// Configurações de cuidado
validateIntervaloDias(int dias) {
  if (dias < 1) return 'Intervalo deve ser pelo menos 1 dia'
  if (dias > 365) return 'Intervalo não pode ser maior que 365 dias'
}

// Datas
validatePrimeiraData(DateTime data) {
  if (isBefore(yesterday)) return 'Data não pode ser no passado'
  if (isAfter(oneYearFromNow)) return 'Data não pode ser mais de 1 ano no futuro'
}
```

### Regras de Negócio:
- **Nome Único**: Não validado (permitido duplicatas)
- **Foto Opcional**: Planta pode ser criada sem foto
- **Espaço Opcional**: Planta pode não ter espaço definido
- **Cuidados Mínimos**: Pelo menos um tipo deve estar ativo (warning)
- **Intervalos Sensatos**: Valores padrão por tipo de cuidado
- **Datas Futuras**: Primeira execução pode ser hoje ou futuro próximo

### Tratamento de Erros:
- **Validação Preventiva**: Validação em tempo real e antes de salvar
- **Rollback Seguro**: Estado anterior mantido em caso de erro
- **Error Recovery**: Possibilidade de correção e retry
- **User Feedback**: Mensagens claras e actionable

## 🚀 Melhorias Futuras Identificadas

### UX/UI:
1. **Wizard Mode**: Divisão em etapas com navegação
2. **Live Preview**: Preview da planta conforme preenchimento
3. **Quick Presets**: Templates de configuração por tipo de planta
4. **Drag & Drop**: Reordenação de tipos de cuidado
5. **Smart Suggestions**: IA para sugerir configurações

### Funcionalidades:
1. **Múltiplas Fotos**: Galeria completa da planta
2. **Localização GPS**: Posição exata da planta
3. **Configurações Avançadas**: Sazonalidade, clima, etc.
4. **Import/Export**: Compartilhamento de configurações
5. **Templates**: Salvamento como templates reutilizáveis

### Validações:
1. **Validação Assíncrona**: Verificações em servidor
2. **Smart Validation**: Validação contextual baseada no tipo
3. **Duplicate Detection**: Detecção inteligente de duplicatas
4. **Data Quality**: Verificação de qualidade de dados

### Performance:
1. **Form Caching**: Cache de dados preenchidos
2. **Incremental Validation**: Validação progressiva
3. **Image Optimization**: Processamento mais eficiente
4. **Background Save**: Salvamento em background

## 📊 Arquitetura de Dados

### Fluxo de Dados Principal:
```
PlantaFormController (Estado)
├── PlantaCadastroService (Orquestração)
│   ├── PlantaValidationService (Validação)
│   ├── TaskCreationService (Tarefas)
│   ├── LoadingStateService (Progress)
│   └── PlantCareService (Persistência)
└── UI Components (Interface)
    ├── Form Fields
    ├── Photo Selector
    ├── Space Selector
    └── Care Configuration Cards
```

### Persistência de Dados:
```
Processo de Salvamento
├── PlantaModel → PlantaRepository
├── PlantaConfigModel → PlantaConfigRepository  
├── EspacoModel → EspacoRepository (se novo)
└── TarefaModel[] → SimpleTaskService (tarefas iniciais)
```

### Estados Reativos:
- **22+ Observables**: Estados reativos no controller
- **Form Validation**: Validação reativa por campo
- **UI Updates**: Atualização automática da interface
- **Cross-Component**: Comunicação entre componentes via estado

---

**Data da Documentação**: Agosto 2025  
**Versão do Código**: Baseada na estrutura atual do projeto  
**Autor**: Documentação técnica para migração de linguagem

## 📊 Estatísticas do Código

### Métricas:
- **Linhas de Código**: ~3.800 linhas
- **Arquivos**: 9 arquivos principais
- **Services**: 4 services especializados
- **Componentes UI**: 15+ componentes de interface
- **Estados Reativos**: 22+ observables
- **Validações**: 12+ regras de validação
- **Dialogs/Sheets**: 5 interfaces modais
- **Form Fields**: 8 campos principais

### Complexidade:
- **Arquitetura**: Híbrida (controller clássico + services especializados)
- **Form Handling**: Avançado com validação multi-camada
- **Image Processing**: Completo com otimização
- **Modal Interfaces**: Múltiplas interfaces modais contextuais
- **State Management**: Complexo com 22+ estados reativos
- **Validation**: Robusto com validação síncrona e preventiva
- **User Experience**: Altamente otimizada com feedback contextual