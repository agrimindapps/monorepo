# 🖼️ ReceituAGRO Cadastro - Mapeamento Detalhado de Telas

## 📋 Índice de Telas Mapeadas
1. [Dashboard - Listagem de Defensivos](#dashboard---listagem-de-defensivos)
2. [Cadastro/Edição de Defensivos](#cadastroedição-de-defensivos)
3. [Importação de Defensivos](#importação-de-defensivos)
4. [Listagem de Pragas](#listagem-de-pragas)
5. [Cadastro/Edição de Pragas](#cadastroedição-de-pragas)
6. [Listagem de Culturas](#listagem-de-culturas)
7. [Modal de Culturas](#modal-de-culturas)
8. [Tela de Exportação](#tela-de-exportação)
9. [Tela de Login](#tela-de-login)

---

## Dashboard - Listagem de Defensivos

### **🔗 Rota**: `/` e `/defensivoslistar`
### **📄 Arquivo**: `src/views/defensivos/uDefensivoListar.vue`

### **🎯 Propósito**
Tela principal do sistema que exibe lista completa de defensivos fitossanitários com funcionalidades avançadas de filtragem, busca e gerenciamento.

### **🧩 Componentes Principais**
- **DataTable Vuetify**: Lista paginada com 1000 itens por página
- **Toolbar Customizada**: Busca global, filtros e ações principais  
- **Overlay de Filtros**: Filtros específicos por categoria
- **Dialog de Confirmação**: Confirmação para exclusões

### **📊 Colunas da Tabela**
| Coluna | Descrição | Tipo | Ações |
|--------|-----------|------|-------|
| **Defensivo** | Nome comercial (link clicável) | String | Link para edição |
| **Fabricante** | Empresa fabricante | String | Apenas exibição |
| **Tóxico** | Classificação toxicológica | String (codificada) | Badge colorido |
| **SebWeb** | Integração com sistema externo | Boolean | Ícone check/vazio |
| **Diagn.** | Total de diagnósticos | Number | Contador |
| **Prend.** | Diagnósticos preenchidos | Number | Contador + ícone |
| **Info.** | Tem informações detalhadas | Number | Ícone check/vazio |
| **Ações** | Botões de ação | - | Copiar, Excluir |

### **🔧 Funcionalidades**

#### **Ações do Toolbar**
- **📥 Exportar**: Chama função `exportaDados()` para export geral
- **➕ Novo**: Navega para `/defensivoscadastro` com ID novo  
- **🔍 Busca Global**: Filtro em tempo real em todos os campos
- **🏷️ Grupos**: Overlay com filtros categorizados

#### **Filtros Disponíveis** (Overlay)
1. **Todos**: Remove todos os filtros
2. **Para Exportação**: Apenas itens prontos para export  
3. **Sem Diagnóstico**: Defensivos sem relacionamentos
4. **Diagnóstico Faltante**: Com diagnósticos incompletos
5. **Sem Informações**: Sem dados detalhados

#### **Ações por Linha**
- **📋 Copiar Nome**: Copia nome do defensivo para clipboard
- **🗑️ Excluir**: Abre dialog de confirmação para exclusão

### **🎨 Comportamentos Especiais**
- **Links Clicáveis**: Nome do defensivo redireciona para edição
- **Ícones Condicionais**: Check verde aparece apenas quando condições atendidas
- **Filtragem Inteligente**: Filtro padrão = "Diagnóstico Faltante" ao carregar
- **Integração SecWeb**: Verifica compatibilidade com sistema externo

### **📱 Responsividade**
- **Desktop**: Tabela completa com todas as colunas
- **Mobile**: Colunas colapsáveis, prioridade para Nome e Ações

---

## Cadastro/Edição de Defensivos

### **🔗 Rota**: `/defensivoscadastro?id={id}`
### **📄 Arquivo**: `src/views/defensivos/uDefensivoCadastro.vue`

### **🎯 Propósito**
Formulário completo para cadastro de novos defensivos ou edição de existentes, incluindo dados técnicos, diagnósticos e relacionamentos.

### **📝 Estrutura do Formulário**
1. **Dados Básicos**
   - Nome Comercial (obrigatório)
   - Nome Técnico/Princípio Ativo
   - Fabricante (dropdown)
   - Número MAPA (registro oficial)

2. **Classificações**
   - Classe Agronômica (Inseticida, Fungicida, etc.)
   - Classe Ambiental (I, II, III, IV)
   - Classificação Toxicológica (codificada)

3. **Características Técnicas**
   - Formulação (EC, WG, SC, etc.)
   - Modo de Ação (sistêmico, contato, etc.)
   - Concentração do Ingrediente Ativo
   - Propriedades (corrosivo, inflamável)

4. **Diagnósticos Associados**
   - Lista de pragas compatíveis
   - Culturas onde pode ser aplicado
   - Dosagens específicas por situação
   - Período de aplicação
   - Restrições de uso

### **🔧 Funcionalidades Especiais**
- **Validação em Tempo Real**: Campos obrigatórios marcados
- **Autocompletar**: Busca dinâmica de pragas e culturas
- **Cálculo Automático**: Dosagens baseadas em fórmulas
- **Preview de Dados**: Visualização antes de salvar
- **Histórico de Mudanças**: Log de alterações realizadas

---

## Importação de Defensivos

### **🔗 Rota**: `/defensivosimportacao`
### **📄 Arquivo**: `src/views/defensivos/uDefensivosImportacao.vue`

### **🎯 Propósito**
Interface para importação em lote de defensivos a partir de arquivos CSV, Excel ou integração com APIs externas.

### **📤 Funcionalidades**
- **Upload de Arquivo**: Drag & drop ou seleção de arquivo
- **Validação de Formato**: Verifica estrutura dos dados
- **Mapeamento de Colunas**: Associa colunas do arquivo com campos do sistema
- **Preview de Importação**: Mostra dados que serão importados
- **Relatório de Erros**: Lista problemas encontrados
- **Importação Parcial**: Permite importar apenas registros válidos

---

## Listagem de Pragas

### **🔗 Rota**: `/pragas/listar`
### **📄 Arquivo**: `src/views/pragas/uPragasListar.vue`

### **🎯 Propósito**
Catálogo visual de pragas agrícolas com informações técnicas e imagens ilustrativas.

### **📊 Estrutura da Tabela**
| Coluna | Descrição | Funcionalidade |
|--------|-----------|----------------|
| **Nome Científico** | Nomenclatura binomial | Link para detalhes |
| **Praga** | Nome comum | Identificação popular |
| **Pseudo Nomes** | Nomes alternativos | Sinônimos e regionalismos |
| **Tipo** | Categoria (Inseto, Fungo, etc.) | Classificação taxonômica |
| **Info** | Tem informações detalhadas | Ícone verde se disponível |
| **Img** | Tem imagem associada | Ícone cinza se disponível |
| **Ações** | Editar | Botão para edição |

### **🔧 Funcionalidades**
- **Busca Global**: Filtra em todos os campos simultaneamente
- **Filtro por Tipo**: Agrupa por categoria de praga
- **Visualização de Imagens**: Thumbnails com zoom
- **Links Externos**: Conecta com bases de dados científicas

---

## Cadastro/Edição de Pragas  

### **🔗 Rota**: `/pragas/cadastro?id={id}`
### **📄 Arquivo**: `src/views/pragas/uPragasCad.vue`

### **🎯 Propósito**
Formulário especializado para cadastro de pragas com dados científicos, imagens e informações de controle.

### **📝 Campos Principais**
- **Identificação**
  - Nome Científico (taxonomia oficial)
  - Nome Comum (popular)
  - Nomes Secundários (sinônimos)
  - Família/Ordem taxonômica

- **Características**
  - Tipo de Praga (Inseto, Ácaro, Fungo, Bactéria, etc.)
  - Características morfológicas
  - Ciclo de vida
  - Sintomas causados

- **Mídia**
  - Upload de imagens
  - Descrições das fotos
  - Créditos das imagens

- **Informações Técnicas**
  - Hospedeiros principais
  - Distribuição geográfica
  - Condições favoráveis
  - Métodos de controle

---

## Listagem de Culturas

### **🔗 Rota**: `/culturas`
### **📄 Arquivo**: `src/views/culturas/uCulturasListar.vue`

### **🎯 Propósito**
Lista simples e direta de culturas agrícolas com funcionalidade CRUD integrada via modal.

### **📊 Estrutura Simplificada**
- **Cultura**: Nome comum da cultura
- **Científico**: Nome científico/botânico  
- **Ações**: Botão editar (abre modal)

### **🔧 Funcionalidades**
- **CRUD Modal**: Cadastro e edição em popup
- **Lista Compacta**: Exibe apenas informações essenciais
- **Busca Rápida**: Filtro simples por nome
- **Auto-refresh**: Atualiza lista após operações

---

## Modal de Culturas

### **📄 Arquivo**: `src/views/culturas/uCulturasCad.vue`
### **🎯 Propósito**
Modal popup para operações CRUD rápidas em culturas, integrado à listagem principal.

### **📝 Formulário Modal**
- **Nome da Cultura** (obrigatório)
- **Nome Científico** (botânico)
- **Família Botânica**
- **Características Gerais**

### **🔧 Comportamentos**
- **Abertura**: Triggered por botão "Novo" ou "Editar" 
- **Validação**: Campos obrigatórios antes de salvar
- **Fechamento**: ESC, clique fora, botão fechar
- **Callback**: Atualiza lista pai após operações

---

## Tela de Exportação

### **🔗 Rota**: `/exportacao`  
### **📄 Arquivo**: `src/views/uExportar.vue`

### **🎯 Propósito**
Interface unificada para exportação de dados em diferentes formatos e com filtros personalizáveis.

### **🎛️ Opções de Exportação**
- **Formato de Arquivo**
  - CSV (Comma Separated Values)
  - Excel (.xlsx)
  - JSON (estruturado)
  - PDF (relatório formatado)

- **Escopo dos Dados**
  - Todos os registros
  - Apenas filtered/selecionados
  - Por data range
  - Por categorias específicas

- **Campos Inclusos**
  - Seleção de colunas específicas
  - Dados básicos vs completos
  - Include relacionamentos
  - Metadados adicionais

### **🔧 Funcionalidades**
- **Preview de Exportação**: Mostra amostra antes do download
- **Agendamento**: Exports periódicos automáticos  
- **Histórico**: Lista de exports anteriores
- **Template**: Salvar configurações frequentes

---

## Tela de Login

### **🔗 Rota**: `/login`
### **📄 Arquivo**: `src/core/views/uLogin.vue`

### **🎯 Propósito**
Autenticação de usuários via Firebase com interface moderna e responsiva.

### **🔐 Funcionalidades de Auth**
- **Login com Email/Senha**
- **Login Social** (Google, Facebook)
- **Recuperação de Senha**
- **Lembrar Usuário**
- **Validação de Formulário**

### **🎨 Design**
- **Layout Centralizado**
- **Gradients Modernos**
- **Animações Suaves**
- **Responsive Design**
- **Loading States**

### **🔧 Fluxo de Autenticação**
1. Usuário insere credenciais
2. Validação local dos campos
3. Chamada Firebase Auth
4. Tratamento de erros
5. Redirecionamento para dashboard
6. Persistência de sessão

---

## 🧭 Navegação e Roteamento

### **Menu Principal**
- **Defensivos** → `/defensivoslistar`
- **Pragas** → `/pragas/listar`  
- **Culturas** → `/culturas`
- **Exportar** → `/exportacao`
- **Logout** → Clear session

### **Breadcrumbs Dinâmicos**
- Listagem → Cadastro
- Filtros aplicados
- Contexto atual
- Ações disponíveis

### **Estados da Aplicação**
- **Loading**: Durante carregamento de dados
- **Empty**: Quando não há dados
- **Error**: Tratamento de erros
- **Offline**: Funcionalidade offline-first

---

**Esta documentação serve como referência completa para a implementação das telas na migração Flutter Web, mantendo 100% da funcionalidade atual com melhorias na arquitetura.**