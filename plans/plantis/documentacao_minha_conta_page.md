# Documentação Técnica - Página Minha Conta (app-plantas)

## 📋 Visão Geral

A página **Minha Conta** é o centro de controle do usuário no aplicativo app-plantas, funcionando como hub principal para gerenciamento de perfil, configurações, assinatura premium e acesso a funcionalidades administrativas de desenvolvimento. É uma página complexa e completa que centraliza praticamente todas as configurações e informações do usuário.

## 🏗️ Arquitetura da Página

### Estrutura de Arquivos

```
lib/app-plantas/pages/minha_conta_page/
├── bindings/
│   └── minha_conta_binding.dart       # Injeção de dependências GetX
├── controller/
│   └── minha_conta_controller.dart    # Controller principal com orquestração
├── models/
│   └── minha_conta_model.dart         # Modelos de dados da página
├── services/
│   ├── data_cleanup_service.dart      # Serviço de limpeza de dados
│   ├── minha_conta_service.dart       # Serviço principal da página
│   ├── navigation_service.dart        # Serviço de navegação e URLs
│   ├── test_data_service.dart         # Serviço de geração de dados de teste
│   └── theme_service.dart             # Serviço de gerenciamento de tema
├── views/
│   └── minha_conta_view.dart          # Interface principal da página
├── widgets/
│   ├── development_section_widget.dart    # Seção de desenvolvimento
│   ├── menu_item_widget.dart              # Widget de item de menu reutilizável
│   ├── subscription_card_widget.dart      # Card de assinatura premium
│   └── user_profile_card_widget.dart      # Card do perfil do usuário
├── issues.md                          # Documentação de melhorias
└── index.dart                         # Arquivo de exportação
```

## 🎨 Interface Visual

### Layout Geral
A página utiliza um **Scaffold** com:
- **SafeArea** para compatibilidade com diferentes dispositivos
- **Column** principal com header fixo e corpo scrollável
- **BottomNavigationBar** integrada (`AppBottomNavWidget`)

### Cores e Tema
Utiliza o sistema **PlantasColors** para suporte completo a temas claro e escuro:

#### Cores Principais:
- **Background**: `PlantasColors.surfaceColor`
  - Claro: `#FFFFFF`
  - Escuro: `#1A1A1A`
- **Cards**: `PlantasColors.cardColor`
  - Claro: `#FFFFFF`
  - Escuro: `#363636`
- **Texto Principal**: `PlantasColors.textColor`
  - Claro: `#000000DE`
  - Escuro: `#FFFFFF`
- **Texto Secundário**: `PlantasColors.subtitleColor`
  - Claro: `#757575`
  - Escuro: `#B0B0B0`

### Seções da Interface

#### 1. **Header (Topo Fixo)**
```dart
Column(
  children: [
    Text('Minha Conta', fontSize: 28, fontWeight: bold),
    Text('Bem-vindo, Usuário Anônimo', fontSize: 14, color: subtitle)
  ]
)
```

#### 2. **Card do Perfil do Usuário**
- **Estado Não Logado**: Avatar placeholder + botão "Entrar"
- **Estado Logado**: Avatar personalizado + dados do usuário + badge Premium
- **Menu PopUp**: Editar Perfil, Configurações, Sair

#### 3. **Card de Assinatura**
- **Estado Gratuito**: Lista de benefícios + botão "Assinar Premium"
- **Estado Premium**: Status da assinatura + informações de cobrança + progress bar

#### 4. **Seções de Menu**

##### **Configurações**
```dart
MenuSection(
  items: [
    MenuItem('Notificações', 'Configure quando ser notificado'),
    MenuItem('Tema', 'Personalize a aparência do app') // Com switch
  ]
)
```

##### **Suporte**
```dart
MenuSection(
  items: [
    MenuItem('Enviar Feedback', 'Nos ajude a melhorar o app'),
    MenuItem('Avaliar o App', 'Avalie nossa experiência')
  ]
)
```

##### **Legal**
```dart
MenuSection(
  items: [
    MenuItem('Política de Privacidade', 'Como protegemos seus dados'),
    MenuItem('Termos de Uso', 'Termos e condições de uso'),
    MenuItem('Sobre o App', 'Versão e informações do app')
  ]
)
```

##### **Desenvolvimento (Seção Especial)**
- Gerar Dados de Teste
- Limpar Todos os Registros
- Página Promocional
- Gerenciar Licença Local

#### 5. **Botão de Saída**
- Botão vermelho destacado para "Sair do App Plantas"
- Confirmação via dialog antes da ação

## 💾 Modelos de Dados

### MinhaContaModel (Estado Principal)
```dart
class MinhaContaModel {
  String? nomeUsuario;              // Nome do usuário logado
  String? emailUsuario;             // Email do usuário
  String? fotoPerfilUrl;            // URL da foto de perfil
  bool isLoggedIn;                  // Status de login
  bool isPremium;                   // Status premium
  bool isLoading;                   // Estado de carregamento
  bool hasError;                    // Estado de erro
  String errorMessage;              // Mensagem de erro
  Map<String, bool> configuracoes;  // Configurações do usuário
}
```

**Getters Calculados**:
- `nomeExibicao` - Nome ou "Usuário Anônimo"
- `statusUsuario` - "Premium", "Usuário padrão" ou "Não autenticado"
- `notificacoesAtivas`, `modoEscuro`, etc.

### UserPreferences (Configurações)
```dart
class UserPreferences {
  bool notificacoes;           // Notificações ativas
  bool backupAutomatico;       // Backup automático
  bool modoEscuro;             // Tema escuro
  bool sincronizacaoNuvem;     // Sincronização
  String idioma;               // Idioma da aplicação
  String tema;                 // Tema atual
}
```

### UserProfile (Perfil Detalhado)
```dart
class UserProfile {
  String? nome;                // Nome completo
  String? email;               // Email
  String? telefone;            // Telefone
  String? fotoUrl;             // URL da foto
  DateTime? dataCadastro;      // Data de criação da conta
  DateTime? ultimoLogin;       // Último acesso
}
```

## ⚙️ Funcionalidades

### 1. **Gerenciamento de Perfil**
- **Login/Logout**: Integração com `AuthService`
- **Exibição de Dados**: Nome, email, foto, data de cadastro
- **Status Premium**: Badge visual para usuários premium
- **Avatar Dinâmico**: Imagem de rede ou iniciais do nome

### 2. **Gerenciamento de Assinatura**
- **Card Dinâmico**: Interface diferente para free/premium
- **Informações Premium**: 
  - Status da assinatura (ativa, cancelada, expirada)
  - Data da próxima cobrança
  - Valor da assinatura
  - Progress bar do período
- **Ações**: Assinar, gerenciar, restaurar, cancelar

### 3. **Sistema de Configurações**
- **Toggle de Tema**: Switch interativo para alternar claro/escuro
- **Navegação para Configurações**: Placeholder para futuras implementações
- **Notificações**: Placeholder para configuração de notificações

### 4. **Navegação Externa**
- **URLs Seguras**: Política de Privacidade e Termos de Uso
- **Validação de URLs**: Verificação antes de abrir links externos
- **Tratamento de Erro**: Fallback para URLs que não podem ser abertas

### 5. **Suporte e Feedback**
- **Formulário de Feedback**: Integração com `FeedbackService`
- **Avaliação do App**: Placeholder para direcionamento à loja
- **Diálogo "Sobre"**: Informações detalhadas do aplicativo

### 6. **Ferramentas de Desenvolvimento**
- **Geração de Dados**: Criação de plantas, espaços e tarefas de teste
- **Limpeza de Dados**: Remoção completa ou seletiva de registros
- **Gerenciamento de Licença**: Ativação/revogação de premium local
- **Página Promocional**: Navegação para demo do premium

## 🔧 Lógica de Negócio (Controller)

### MinhaContaController
**Padrão**: Orquestração via services especializados seguindo princípios SOLID

#### Propriedades Reativas:
```dart
final RxBool isLoading = false.obs;           // Loading geral
final RxBool isGeneratingData = false.obs;    // Gerando dados
final RxBool isCleaningData = false.obs;      // Limpando dados
```

#### Services Utilizados:
- `TestDataService` - Geração de dados de teste
- `DataCleanupService` - Limpeza de dados
- `NavigationService` - Navegação e URLs
- `ThemeService` - Gerenciamento de tema

#### Métodos Principais:

##### **Navegação**
```dart
navigateToTermos()         // Abre Termos de Uso
navigateToPoliticas()      // Abre Política de Privacidade
navigateToPromo()          // Navega para página Premium
navigateToAbout()          // Mostra diálogo "Sobre"
sendFeedback()             // Mostra formulário de feedback
```

##### **Tema**
```dart
toggleTheme()              // Alterna entre claro/escuro
logThemeDebug()            // Log de informações do tema
```

##### **Desenvolvimento**
```dart
gerarDadosDeTeste()        // Cria dados de exemplo
limparTodosRegistros()     // Remove todos os dados
gerarLicencaLocal()        // Ativa premium local
revogarLicencaLocal()      // Remove premium local
```

### Estados Gerenciados:
- **Loading States** - Para operações assíncronas
- **Error Handling** - Captura e exibição de erros
- **Success Feedback** - Confirmações visuais
- **Operation Tracking** - Prevenção de operações concorrentes

## 🛠️ Serviços Especializados

### NavigationService
**Responsabilidade**: Navegação externa e interna, validação de URLs

#### Funcionalidades:
- **URLs Externas**: Validação e abertura segura
- **Navegação Interna**: Transições animadas
- **Diálogos**: Modais informativos
- **Placeholders**: Funcionalidades futuras
- **Error Handling**: Tratamento de falhas de navegação

#### Métodos Principais:
```dart
navigateToTermos()         // URL: termos-uso
navigateToPoliticas()      // URL: politica-privacidade  
navigateToPromo()          // Página Premium interna
showAboutDialog()          // Modal com informações do app
showFeedback()             // Formulário de feedback
```

### ThemeService
**Responsabilidade**: Gerenciamento centralizado de tema

#### Funcionalidades:
- **Toggle Theme**: Alternância claro/escuro
- **Persistência**: Salvamento da preferência
- **Debug Info**: Logs de estado do tema
- **Global Access**: Acesso unificado via `ThemeManager`

### TestDataService
**Responsabilidade**: Geração de dados para desenvolvimento

#### Dados Gerados:
- **Plantas**: 5-10 plantas com diferentes configurações
- **Espaços**: 3-5 espaços variados
- **Tarefas**: Múltiplas tarefas por planta
- **Configurações**: Settings de exemplo

### DataCleanupService
**Responsabilidade**: Limpeza seletiva e completa de dados

#### Tipos de Limpeza:
- **Completa**: Remove todos os dados
- **Apenas Teste**: Remove dados gerados
- **Seletiva**: Remove categorias específicas
- **Com Confirmação**: Dialog antes da ação

## 🧩 Widgets Especializados

### UserProfileCardWidget
**Estado Dinâmico**: Baseado em `AuthService.isLoggedIn`

#### Estado Não Logado:
```dart
Row(
  children: [
    CircleAvatar(child: Icon(person_outline)),
    Column([
      Text('Fazer Login'),
      Text('Entre para sincronizar suas plantas')
    ]),
    ElevatedButton('Entrar')
  ]
)
```

#### Estado Logado:
```dart
Row(
  children: [
    CircleAvatar(backgroundImage: NetworkImage(user.avatarUrl)),
    Column([
      Row([
        Text(user.nomeExibicao),
        if(user.isPremium) PremiumBadge()
      ]),
      Text(user.email),
      Text('Membro desde ${formatDate(user.criadoEm)}')
    ]),
    PopupMenuButton(['Editar Perfil', 'Configurações', 'Sair'])
  ]
)
```

### SubscriptionCardWidget
**Estado Dinâmico**: Baseado em `SubscriptionService.isPremium`

#### Estado Gratuito:
- **Lista de Benefícios**: Primeiros 4 benefícios + contador adicional
- **Botão CTA**: "Assinar Premium" com gradiente dourado
- **Validação**: Verificação de login antes da assinatura

#### Estado Premium:
- **Informações da Assinatura**: Status, plano, próxima cobrança
- **Progress Bar**: Visualização do período restante
- **Menu de Ações**: Gerenciar, restaurar, cancelar
- **Cards Informativos**: Preço e próxima cobrança

### MenuItemWidget
**Widget Reutilizável** para itens de menu padronizados:

```dart
MenuItemWidget(
  icon: IconData,           // Ícone do menu
  title: String,            // Título principal  
  subtitle: String?,        // Descrição opcional
  onTap: VoidCallback,      // Ação ao tocar
  iconColor: Color?,        // Cor personalizada do ícone
  titleColor: Color?        // Cor personalizada do título
)
```

**Características**:
- Material Design com efeito ripple
- Chevron automática à direita
- Padding e espaçamento consistentes
- Suporte a temas claro/escuro

### DevelopmentSectionWidget
**Ferramentas de Desenvolvimento** para ambiente de teste:

#### Funcionalidades:
- **Gerar Dados**: Botão para criação de dados de exemplo
- **Limpar Registros**: Botão para limpeza completa
- **Página Promocional**: Acesso rápido ao premium
- **Licença Local**: Gerenciamento de premium de desenvolvimento

## 🌐 Integrações e Dependências

### Services Externos:
1. **AuthService** - Gerenciamento de autenticação
2. **SubscriptionService** - Gerenciamento de assinaturas
3. **ThemeManager** - Controle global de tema
4. **FeedbackService** - Sistema de feedback
5. **LocalLicenseService** - Licenças de desenvolvimento

### Páginas Relacionadas:
1. **PremiumPage** - Navegação para planos premium
2. **Login/Auth Pages** - Integração de autenticação
3. **Settings Pages** - Configurações detalhadas (futuro)

### URLs Externas:
- **Termos de Uso**: `https://plantis.agrimind.com.br/termos-uso`
- **Política de Privacidade**: `https://plantis.agrimind.com.br/politica-privacidade`

### Navegação:
- **Entrada**: Via `AppBottomNavWidget` (tab "Conta")
- **Saída**: Dialog de confirmação + `Get.offAllNamed('/')`

## 📱 Experiência do Usuário

### Fluxo Principal:
1. **Acesso** → Carregamento dos dados do usuário
2. **Visualização** → Cards de perfil e assinatura
3. **Configurações** → Menu organizado por categorias
4. **Ações** → Navegação para funcionalidades específicas

### Estados da Interface:
- **Loading**: Shimmer effects nos cards principais
- **Autenticado**: Interface completa com todos os dados
- **Não Autenticado**: Incentivo ao login
- **Premium**: Interface diferenciada com recursos exclusivos
- **Desenvolvimento**: Seção especial com ferramentas de teste

### Feedback Visual:
- **Sucesso**: Snackbar verde com ícone de check
- **Erro**: Snackbar vermelho com mensagem detalhada
- **Info**: Snackbar azul para funcionalidades placeholder
- **Warning**: Snackbar laranja para validações

### Responsividade:
- **Cards Flexíveis**: Adaptação automática ao conteúdo
- **Menu Responsivo**: Ícones e textos bem distribuídos
- **Bottom Navigation**: Integração harmoniosa
- **Safe Area**: Compatibilidade com diferentes dispositivos

## 🔒 Segurança e Validações

### Validação de URLs:
```dart
// Validação antes de abrir URLs externas
if (await canLaunchUrl(uri)) {
  await launchUrl(uri, mode: LaunchMode.externalApplication);
} else {
  showError('URL não pode ser aberta');
}
```

### Confirmações de Ações Críticas:
- **Logout**: Dialog de confirmação
- **Limpeza de Dados**: Dialog com detalhes da ação
- **Cancelamento de Assinatura**: Dialog específico
- **Saída do App**: Confirmação antes de voltar aos módulos

### Tratamento de Erros:
- **Try-Catch**: Captura de exceções em operações críticas
- **Loading States**: Prevenção de múltiplas operações
- **Fallbacks**: Alternativas para falhas de serviço
- **User Feedback**: Mensagens claras sobre erros

### Estados de Operação:
```dart
// Prevenção de operações concorrentes
bool get hasOperationInProgress => 
  isLoading.value || isGeneratingData.value || isCleaningData.value;
```

## 🚀 Melhorias Futuras Identificadas

### Funcionalidades Pendentes:
1. **Configurações Avançadas**: Página dedicada para configurações detalhadas
2. **Edição de Perfil**: Formulário completo de edição de dados
3. **Notificações**: Sistema completo de gerenciamento de notificações
4. **Backup e Sync**: Funcionalidades de sincronização de dados
5. **Tema Personalizado**: Além de claro/escuro, cores personalizáveis
6. **Idiomas**: Sistema completo de internacionalização
7. **Estatísticas**: Dashboard com métricas do usuário

### Refatorações Sugeridas:
1. **Separação de Widgets**: Extração de componentes reutilizáveis
2. **Service Layer**: Ampliação dos services especializados
3. **State Management**: Possível migração para padrões mais robustos
4. **Performance**: Lazy loading para seções pesadas
5. **Testes**: Cobertura completa de testes unitários e de integração
6. **Acessibilidade**: Melhorias para usuários com necessidades especiais

### Integrações Futuras:
1. **Social Login**: Google, Apple, Facebook
2. **Cloud Storage**: Backup automático na nuvem
3. **Analytics**: Métricas de uso e comportamento
4. **Push Notifications**: Sistema de notificações push
5. **Deep Links**: Links diretos para seções específicas

---

**Data da Documentação**: Agosto 2025  
**Versão do Código**: Baseada na estrutura atual do projeto  
**Autor**: Documentação técnica para migração de linguagem

## 📊 Estatísticas do Código

### Métricas:
- **Linhas de Código**: ~2.500 linhas
- **Arquivos**: 14 arquivos principais
- **Services**: 5 services especializados
- **Widgets**: 4 widgets customizados
- **Modelos**: 3 modelos de dados principais
- **Funcionalidades**: 15+ funcionalidades implementadas
- **Estados**: 10+ estados gerenciados
- **Navegações**: 8 tipos de navegação diferentes