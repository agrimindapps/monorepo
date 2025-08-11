# Documentação Técnica - Página de Espaços (app-plantas)

## 📋 Visão Geral

A página de **Espaços** é um módulo do aplicativo app-plantas responsável pelo gerenciamento de ambientes onde as plantas ficam localizadas. Esta funcionalidade permite aos usuários organizar suas plantas por locais específicos como sala, cozinha, varanda, jardim, etc.

## 🏗️ Arquitetura da Página

### Estrutura de Arquivos

```
lib/app-plantas/pages/espacos_page/
├── bindings/
│   └── espacos_binding.dart           # Injeção de dependências GetX
├── controller/
│   └── espacos_controller.dart        # Lógica de negócio e estado
├── interfaces/
│   ├── espacos_repository_interface.dart  # Interface do repositório de espaços
│   └── plantas_repository_interface.dart  # Interface do repositório de plantas
├── models/
│   └── espacos_model.dart             # Modelos de dados da página
├── services/
│   └── espacos_service.dart           # Serviços de validação e lógica de negócio
├── translations/
│   └── espacos_translations.dart      # Textos traduzidos (pt_BR e en_US)
├── views/
│   └── espacos_view.dart              # Interface principal da página
├── widgets/
│   └── espacos_widget.dart            # Widget principal com lista de espaços
└── index.dart                         # Arquivo de exportação
```

## 🎨 Interface Visual

### Cores e Tema

A página utiliza o sistema de cores **PlantasColors** que suporta temas claro e escuro:

#### Cores Principais:
- **Background**: `PlantasColors.backgroundColor` 
  - Claro: `#F5F5F5`
  - Escuro: `#2D2D2D`
- **Surface/AppBar**: `PlantasColors.surfaceColor`
  - Claro: `#FFFFFF`
  - Escuro: `#1A1A1A`
- **Primária**: `PlantasColors.primaryColor`
  - Claro: `#20B2AA` (Turquesa)
  - Escuro: `#1A9B95` (Turquesa escuro)
- **Texto**: `PlantasColors.textColor`
  - Claro: `#000000DE` (preto 87%)
  - Escuro: `#FFFFFF` (branco)

### Componentes Visuais

#### 1. **AppBar**
```dart
AppBar(
  backgroundColor: PlantasColors.surfaceColor,
  elevation: 0,
  title: Text('espacos.titulo'.tr), // "Espaços"
  centerTitle: true,
  leading: IconButton(Icons.arrow_back),      // Botão voltar
  actions: [
    IconButton(Icons.add)                     // Botão adicionar espaço
  ]
)
```

#### 2. **Lista de Espaços**
- **Componente**: `ListView.builder`
- **Padding**: `EdgeInsets.all(16.0)`
- **Item**: Cards com formato `ListTile`

#### 3. **Card do Espaço**
```dart
Card(
  shape: RoundedRectangleBorder(borderRadius: 12.0),
  child: ListTile(
    leading: CircleAvatar(          // Ícone do espaço
      backgroundColor: primaryColor.withAlpha(0.1),
      child: Icon(Icons.space_dashboard)
    ),
    title: Text(espaco.nome),       // Nome do espaço
    subtitle: Text('0 plantas'),    // Contador de plantas
    trailing: PopupMenuButton       // Menu de ações
  )
)
```

#### 4. **Estado Vazio**
- **Ícone**: `Icons.space_dashboard_outlined` (64px)
- **Cor**: `secondaryTextColor`
- **Botão**: `ElevatedButton.icon` com ícone `Icons.add`

## 💾 Modelos de Dados

### EspacoModel (Entidade Principal)
```dart
class EspacoModel extends BaseModel {
  String nome;                    // Nome do espaço (obrigatório)
  String? descricao;              // Descrição opcional
  bool ativo;                     // Status ativo/inativo
  DateTime? dataCriacao;          // Data de criação
}
```

**Propriedades herdadas de BaseModel**:
- `String id` - Identificador único
- `int createdAt` - Timestamp de criação
- `int updatedAt` - Timestamp de atualização
- Campos de sincronização (isDeleted, needsSync, etc.)

### EspacosPageModel (Estado da Página)
```dart
class EspacosPageModel {
  List<EspacoModel> espacos;              // Lista de espaços
  bool isLoading;                         // Estado de carregamento
  bool hasError;                          // Estado de erro
  String errorMessage;                    // Mensagem de erro
  bool isCreating;                        // Criando espaço
  bool isUpdating;                        // Atualizando espaço
  bool isDeleting;                        // Deletando espaço
  String? editingEspacoId;                // ID do espaço sendo editado
  EspacosSearchState searchState;         // Estado de busca
}
```

### EspacosSearchState (Estado de Busca)
```dart
class EspacosSearchState {
  String searchText;                      // Texto de busca
  List<EspacoModel> filteredEspacos;      // Espaços filtrados
  bool isSearchActive;                    // Busca ativa
}
```

### EspacoFormModel (Formulário)
```dart
class EspacoFormModel {
  String nome;                            // Nome do espaço
  String? id;                             // ID (null para novo)
  bool isValid;                           // Formulário válido
  Map<String, String> errors;             // Erros de validação
}
```

## ⚙️ Funcionalidades

### 1. **Listagem de Espaços**
- Carregamento automático na inicialização
- Exibição em formato de cards
- Contador de plantas por espaço (placeholder)
- Estado de loading com `CircularProgressIndicator`
- Estado vazio com incentivo para criar primeiro espaço

### 2. **Criação de Espaço**
- Dialog modal com campos:
  - Nome (obrigatório, 2-30 caracteres)
  - Descrição (opcional, múltiplas linhas)
- Validação em tempo real
- Formatação automática do nome (Title Case)
- Verificação de nomes duplicados

### 3. **Edição de Espaço**
- Dialog modal pré-preenchido
- Mesmas validações da criação
- Exclusão do espaço atual na verificação de duplicatas

### 4. **Remoção de Espaço**
- Dialog de confirmação
- Verificação se existem plantas no espaço
- Prevenção de remoção se houver plantas associadas

### 5. **Busca e Filtros**
- Campo de busca no controller (implementação preparada)
- Filtro por nome e descrição
- Busca com normalização de caracteres acentuados

## 🔧 Lógica de Negócio (Controller)

### EspacosController
**Padrão**: Reativo com estado imutável usando GetX

#### Propriedades Principais:
```dart
final _state = const EspacosPageModel().obs;  // Estado reativo
final searchController = TextEditingController();
```

#### Métodos Principais:

##### **carregarEspacos()**
- Inicializa repositório
- Carrega lista de espaços
- Atualiza estado reativo
- Trata erros com mensagens traduzidas

##### **adicionarEspaco(String nome, String? descricao)**
- Validação assíncrona via service
- Criação do modelo via service
- Salvamento no repositório
- Recarregamento da lista
- Feedback visual de sucesso/erro

##### **editarEspaco(EspacoModel espaco, String novoNome, String? novaDescricao)**
- Validação excluindo espaço atual
- Atualização do modelo
- Salvamento no repositório
- Recarregamento da lista

##### **removerEspaco(EspacoModel espaco)**
- Verificação de plantas associadas
- Prevenção de remoção se houver plantas
- Remoção do repositório
- Recarregamento da lista

### Estados Reativos:
- `isLoading` - Carregamento inicial
- `isCreating` - Criando novo espaço
- `isUpdating` - Atualizando espaço
- `isDeleting` - Removendo espaço
- `hasError` - Estado de erro
- `searchState` - Estado de busca e filtros

## 🛠️ Serviços

### EspacosService
**Responsabilidade**: Validações, lógica de negócio e transformações

#### Funcionalidades:

##### **validateEspaco()** - Validação Síncrona
- Nome obrigatório (2-30 caracteres)
- Verificação de duplicatas em lista fornecida
- Uso de normalização robusta para caracteres especiais

##### **validateEspacoAsync()** - Validação Assíncrona
- Validação básica + verificação no repositório
- Lock de sincronização para prevenir race conditions
- Consulta assíncrona de duplicatas

##### **createEspaco()** - Criação de Modelo
- Geração de ID único baseado em timestamp
- Formatação do nome (Title Case)
- Inicialização com valores padrão

##### **filterEspacos()** - Filtros e Busca
- Busca por nome e descrição
- Normalização de caracteres acentuados
- Comparação case-insensitive

##### **canRemoveEspaco()** - Validação de Remoção
- Verificação assíncrona de plantas associadas
- Retorna boolean indicando possibilidade de remoção

## 🌐 Internacionalização

### Idiomas Suportados:
- **Português Brasileiro (pt_BR)**
- **Inglês Americano (en_US)**

### Principais Chaves de Tradução:

#### Interface:
- `espacos.titulo` - "Espaços" / "Spaces"
- `espacos.novo_espaco` - "Novo Espaço" / "New Space"
- `espacos.nenhum_espaco` - "Nenhum espaço cadastrado" / "No spaces registered"

#### Validações:
- `espacos.nome_obrigatorio_validacao` - "Nome do espaço é obrigatório"
- `espacos.nome_minimo` - "Nome deve ter pelo menos 2 caracteres"
- `espacos.nome_duplicado` - "Já existe um espaço com esse nome"

#### Mensagens:
- `espacos.criado_sucesso` - "Espaço '@nome' criado com sucesso!"
- `espacos.plantas_no_espaco` - "Este espaço possui @quantidade planta(s)"

## 🔗 Integrações e Dependências

### Páginas Relacionadas:
1. **Página Principal de Plantas** - Acesso via menu/navegação
2. **Formulário de Plantas** - Seleção de espaço ao cadastrar planta
3. **Detalhes da Planta** - Exibição do espaço associado

### Repositórios Utilizados:
- `EspacoRepository` - CRUD de espaços
- `PlantaRepository` - Consulta de plantas por espaço

### Navegação:
- **Entrada**: `PlantasNavigator.toEspacos()` → `Get.toNamed('/espacos')`
- **Saída**: `Get.back()` via botão voltar

### Dependencies:
```dart
// GetX
import 'package:get/get.dart';

// Repositórios
import '../../../repository/espaco_repository.dart';
import '../../../repository/planta_repository.dart';

// Utilitários
import '../../../shared/utils/string_comparison_utils.dart';

// Sincronização
import 'package:synchronized/synchronized.dart';
```

## 📱 Experiência do Usuário

### Fluxo Principal:
1. **Acesso** → Carregamento automático de espaços
2. **Visualização** → Lista de cards com espaços
3. **Adição** → Botão "+" → Dialog → Validação → Criação
4. **Edição** → Menu "⋮" → "Editar" → Dialog → Validação → Atualização
5. **Remoção** → Menu "⋮" → "Remover" → Confirmação → Verificação → Exclusão

### Estados da Interface:
- **Loading**: Indicador circular centralizado
- **Vazio**: Ícone + texto explicativo + botão de ação
- **Com Dados**: Lista scrollável de cards
- **Erro**: Snackbar com mensagem de erro

### Feedback Visual:
- **Sucesso**: Snackbar verde com ícone de check
- **Erro**: Snackbar vermelho com ícone de alerta
- **Warning**: Snackbar amarelo para validações

## 🔒 Validações e Regras de Negócio

### Regras de Validação:
1. **Nome Obrigatório**: Mínimo 2, máximo 30 caracteres
2. **Nomes Únicos**: Não permite duplicatas (normalização de acentos)
3. **Remoção Protegida**: Não permite remover espaços com plantas
4. **Formatação**: Nome automaticamente formatado em Title Case

### Tratamento de Erros:
- Validação local antes de requisições
- Tratamento de exceções de repositório
- Mensagens de erro traduzidas e contextualizadas
- Estados de loading durante operações

### Segurança:
- Validação de entrada sanitizada
- Locks de sincronização para operações concorrentes
- Estados imutáveis para prevenção de inconsistências

## 🚀 Melhorias Futuras Identificadas

### Funcionalidades Pendentes:
1. **Busca Implementada**: Campo de busca já preparado no controller
2. **Contador Real de Plantas**: Integração com repositório de plantas
3. **Tipos de Espaços Predefinidos**: Templates configuráveis
4. **Reordenação**: Drag & drop para ordenação customizada
5. **Imagens**: Suporte a fotos dos espaços
6. **Configurações Avançadas**: Condições ambientais (luz, umidade)

### Refatorações Sugeridas:
1. **Extração de Dialogs**: Componentes separados para modais
2. **Componentização**: Widgets reutilizáveis para cards
3. **Performance**: Lazy loading e pagination
4. **Testes**: Cobertura de testes unitários e de integração

---

**Data da Documentação**: Agosto 2025  
**Versão do Código**: Baseada na estrutura atual do projeto  
**Autor**: Documentação técnica para migração de linguagem