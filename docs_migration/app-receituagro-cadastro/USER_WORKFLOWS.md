# 👥 ReceituAGRO Cadastro - Fluxos de Trabalho do Usuário

## 📋 Índice dos Fluxos
1. [Fluxos de Gestão de Defensivos](#-fluxos-de-gestão-de-defensivos)
2. [Fluxos de Gestão de Pragas](#-fluxos-de-gestão-de-pragas)
3. [Fluxos de Gestão de Culturas](#-fluxos-de-gestão-de-culturas)
4. [Fluxos de Diagnósticos](#-fluxos-de-diagnósticos)
5. [Fluxos de Exportação](#-fluxos-de-exportação)
6. [Fluxos de Autenticação](#-fluxos-de-autenticação)

---

## 🛡️ Fluxos de Gestão de Defensivos

### **Fluxo 1: Visualizar Lista de Defensivos**

#### **🎯 Objetivo**: Navegar e filtrar defensivos cadastrados
#### **👤 Usuário**: Todos os perfis (Admin, Editor, Viewer)
#### **🚀 Início**: Usuário acessa dashboard principal

```mermaid
graph TD
    A[Usuário acessa /] --> B[Sistema carrega dados IndexedDB]
    B --> C[Exibe lista com filtro padrão 'Diagnóstico Faltante']
    C --> D{Usuário quer filtrar?}
    D -->|Sim| E[Usuário clica 'Grupos']
    D -->|Não| F[Usuário navega na lista]
    E --> G[Sistema exibe overlay de filtros]
    G --> H[Usuário seleciona filtro]
    H --> I[Lista é atualizada dinamicamente]
    I --> F
    F --> J{Usuário quer buscar?}
    J -->|Sim| K[Usuário digita na busca global]
    J -->|Não| L[Visualização concluída]
    K --> M[Sistema filtra em tempo real]
    M --> L
```

#### **📋 Passos Detalhados**:
1. **Carregamento Inicial**
   - Sistema carrega dados das tabelas: TBFITOSSANITARIOS, TBDIAGNOSTICO, TBFITOSSANITARIOSINFO
   - Processa contadores de diagnósticos
   - Aplica filtro padrão "Diagnóstico Faltante"

2. **Interação com Filtros**
   - Usuário clica no botão "Grupos" no toolbar
   - Sistema exibe overlay com 5 opções de filtro
   - Usuário seleciona filtro desejado
   - Lista atualiza automaticamente sem reload

3. **Busca Textual**
   - Usuário digita no campo de busca
   - Sistema filtra em tempo real em todos os campos visíveis
   - Resultados são destacados conforme termo buscado

#### **✅ Critérios de Sucesso**:
- Lista carrega em < 3 segundos
- Filtros respondem imediatamente
- Busca funciona em todos os campos
- Contadores são precisos

---

### **Fluxo 2: Cadastrar Novo Defensivo**

#### **🎯 Objetivo**: Adicionar novo defensivo ao sistema
#### **👤 Usuário**: Admin, Editor
#### **🚀 Início**: Usuário clica "Novo" na lista de defensivos

```mermaid
graph TD
    A[Usuário clica 'Novo'] --> B[Sistema navega para /defensivoscadastro?id=x]
    B --> C[Formulário vazio é carregado]
    C --> D[Usuário preenche dados obrigatórios]
    D --> E{Dados válidos?}
    E -->|Não| F[Sistema exibe erros de validação]
    F --> D
    E -->|Sim| G[Usuário clica 'Salvar']
    G --> H[Sistema gera ID único]
    H --> I[Dados são salvos no IndexedDB]
    I --> J[Sistema exibe mensagem de sucesso]
    J --> K[Usuário é redirecionado para lista]
    K --> L[Lista atualizada com novo item]
```

#### **📋 Passos Detalhados**:
1. **Preparação do Formulário**
   - Carrega listas de fabricantes, classificações
   - Inicializa campos vazios
   - Configura validações em tempo real

2. **Preenchimento dos Dados**
   - **Dados Básicos**: Nome comercial, técnico, fabricante, MAPA
   - **Classificações**: Agronômica, ambiental, toxicológica
   - **Características**: Formulação, modo de ação, concentração
   - **Propriedades**: Corrosivo, inflamável

3. **Validação e Salvamento**
   - Sistema valida campos obrigatórios
   - Verifica duplicação de MAPA/Nome
   - Gera IdReg único
   - Salva no IndexedDB
   - Atualiza contadores e índices

#### **✅ Critérios de Sucesso**:
- Todos os campos obrigatórios validados
- ID único gerado corretamente
- Dados salvos sem inconsistência
- Redirecionamento automático funcional

---

### **Fluxo 3: Editar Defensivo Existente**

#### **🎯 Objetivo**: Modificar dados de defensivo cadastrado
#### **👤 Usuário**: Admin, Editor
#### **🚀 Início**: Usuário clica no nome do defensivo na lista

```mermaid
graph TD
    A[Usuário clica nome do defensivo] --> B[Sistema navega para /defensivoscadastro?id={IdReg}]
    B --> C[Sistema carrega dados existentes]
    C --> D[Formulário preenchido é exibido]
    D --> E[Usuário modifica campos desejados]
    E --> F{Dados válidos?}
    F -->|Não| G[Sistema exibe erros específicos]
    G --> E
    F -->|Sim| H[Usuário clica 'Salvar']
    H --> I[Sistema atualiza registro no IndexedDB]
    I --> J[Log de auditoria é criado]
    J --> K[Mensagem de sucesso exibida]
    K --> L[Usuário retorna à lista]
```

#### **📋 Passos Detalhados**:
1. **Carregamento dos Dados**
   - Sistema busca registro por IdReg
   - Popula todos os campos do formulário
   - Carrega diagnósticos relacionados
   - Decodifica campos criptografados (toxico, etc.)

2. **Edição**
   - Usuário modifica campos necessários
   - Validação em tempo real impede erros
   - Sistema mantém histórico de changes

3. **Salvamento**
   - Valida integridade dos dados
   - Atualiza timestamp de modificação
   - Mantém relacionamentos existentes
   - Registra quem fez a alteração

#### **✅ Critérios de Sucesso**:
- Dados carregam corretamente
- Alterações são persistidas
- Relacionamentos mantidos
- Auditoria registrada

---

### **Fluxo 4: Excluir Defensivo**

#### **🎯 Objetivo**: Remover defensivo do sistema
#### **👤 Usuário**: Admin apenas
#### **🚀 Início**: Usuário clica ícone de lixeira na linha do defensivo

```mermaid
graph TD
    A[Usuário clica ícone 'Excluir'] --> B[Sistema exibe dialog de confirmação]
    B --> C{Usuário confirma?}
    C -->|Não| D[Dialog fechado, nenhuma ação]
    C -->|Sim| E[Sistema verifica dependências]
    E --> F{Tem diagnósticos vinculados?}
    F -->|Sim| G[Sistema exibe erro e lista dependências]
    F -->|Não| H[Sistema faz soft delete]
    H --> I[Status alterado para inativo]
    I --> J[Lista é atualizada]
    J --> K[Item removido da visualização]
```

#### **📋 Passos Detalhados**:
1. **Confirmação**
   - Dialog modal com confirmação explícita
   - Exibe nome do item a ser excluído
   - Botões Sim/Não claros

2. **Verificação de Integridade**
   - Busca diagnósticos que referenciam o defensivo
   - Verifica outras dependências (logs, relatórios)
   - Impede exclusão se houver referências

3. **Exclusão Segura**
   - Soft delete (marca como inativo)
   - Mantém dados para auditoria
   - Remove da visualização normal
   - Log da operação

#### **✅ Critérios de Sucesso**:
- Confirmação obrigatória funciona
- Dependências são verificadas
- Dados não são perdidos permanentemente
- Interface atualiza corretamente

---

## 🐛 Fluxos de Gestão de Pragas

### **Fluxo 5: Navegar Catálogo de Pragas**

#### **🎯 Objetivo**: Explorar e pesquisar pragas cadastradas
#### **👤 Usuário**: Todos os perfis
#### **🚀 Início**: Usuário acessa menu Pragas

```mermaid
graph TD
    A[Usuário acessa /pragas/listar] --> B[Sistema carrega dados TBPRAGAS]
    B --> C[Lista exibida com imagens e info]
    C --> D{Usuário quer buscar praga específica?}
    D -->|Sim| E[Usuário digita na busca]
    D -->|Não| F[Navega pela lista completa]
    E --> G[Sistema filtra por todos os campos]
    G --> H[Resultados destacados]
    H --> F
    F --> I{Usuário quer ver detalhes?}
    I -->|Sim| J[Usuário clica nome científico]
    I -->|Não| K[Navegação concluída]
    J --> L[Sistema carrega detalhes da praga]
```

#### **📋 Passos Detalhados**:
1. **Carregamento do Catálogo**
   - Sistema carrega tabela TBPRAGAS
   - Verifica disponibilidade de imagens
   - Ordena por nome científico
   - Exibe indicadores visuais (imagem/info)

2. **Busca e Navegação**
   - Campo de busca funciona em tempo real
   - Filtra por: nome científico, comum, pseudônimos, tipo
   - Resultados são destacados conforme busca

3. **Visualização de Detalhes**
   - Nome científico é link clicável
   - Imagens são exibidas em thumbnail
   - Informações técnicas disponíveis

#### **✅ Critérios de Sucesso**:
- Todas as pragas carregam corretamente
- Busca é responsiva e precisa
- Imagens são exibidas quando disponíveis
- Links funcionam corretamente

---

### **Fluxo 6: Cadastrar Nova Praga**

#### **🎯 Objetivo**: Adicionar nova praga ao catálogo
#### **👤 Usuário**: Admin, Editor
#### **🚀 Início**: Usuário clica "Novo" na lista de pragas

```mermaid
graph TD
    A[Usuário clica 'Novo'] --> B[Sistema navega para /pragas/cadastro]
    B --> C[Formulário vazio carregado]
    C --> D[Usuário preenche dados taxonômicos]
    D --> E[Usuário define tipo de praga]
    E --> F{Usuário tem imagem?}
    F -->|Sim| G[Upload de imagem]
    F -->|Não| H[Continua sem imagem]
    G --> I[Sistema valida formato/tamanho]
    I --> J{Imagem válida?}
    J -->|Não| K[Erro exibido, nova tentativa]
    K --> G
    J -->|Sim| H
    H --> L[Usuário adiciona informações técnicas]
    L --> M[Sistema valida nomenclatura científica]
    M --> N{Dados válidos?}
    N -->|Não| O[Erros de validação exibidos]
    O --> D
    N -->|Sim| P[Salvar no IndexedDB]
    P --> Q[Retorno à lista atualizada]
```

#### **📋 Passos Detalhados**:
1. **Dados Taxonômicos**
   - Nome científico (obrigatório, nomenclatura binomial)
   - Nome comum popular
   - Nomes secundários/sinônimos
   - Classificação: tipo, família, ordem

2. **Upload de Mídia**
   - Seleção de arquivo de imagem
   - Validação: JPG/PNG, max 2MB, min 300x300px
   - Redimensionamento automático se necessário
   - Nomenclatura baseada no nome científico

3. **Informações Complementares**
   - Características morfológicas
   - Hospedeiros principais
   - Distribuição geográfica
   - Métodos de controle

#### **✅ Critérios de Sucesso**:
- Nomenclatura científica validada
- Imagem salva corretamente
- Não há duplicação de espécies
- Dados estruturados adequadamente

---

## 🌱 Fluxos de Gestão de Culturas

### **Fluxo 7: Gerenciar Lista de Culturas**

#### **🎯 Objetivo**: Visualizar e manter cadastro de culturas
#### **👤 Usuário**: Admin, Editor, Viewer
#### **🚀 Início**: Usuário acessa menu Culturas

```mermaid
graph TD
    A[Usuário acessa /culturas] --> B[Sistema carrega TBCULTURAS]
    B --> C[Lista simples exibida]
    C --> D{Usuário quer buscar?}
    D -->|Sim| E[Usuário digita busca]
    E --> F[Sistema filtra lista]
    D -->|Não| G{Usuário quer adicionar nova?}
    G -->|Sim| H[Usuário clica 'Novo']
    G -->|Não| I{Usuário quer editar existente?}
    I -->|Sim| J[Usuário clica 'Editar' na linha]
    I -->|Não| K[Apenas visualização]
    H --> L[Modal de cadastro abre]
    J --> M[Modal de edição abre com dados]
    L --> N[Usuário preenche formulário modal]
    M --> N
    N --> O[Usuário salva]
    O --> P[Modal fecha]
    P --> Q[Lista principal atualizada]
```

#### **📋 Passos Detalhados**:
1. **Visualização da Lista**
   - Tabela simples com 3 colunas: Cultura, Científico, Ações
   - Busca rápida por nome
   - Botão "Novo" sempre visível

2. **Operações CRUD via Modal**
   - Cadastro: Modal vazio para preenchimento
   - Edição: Modal preenchido com dados existentes
   - Exclusão: Confirmação inline (se implementada)

3. **Integração com Lista Principal**
   - Modal se sobrepõe à lista
   - Após operação, modal fecha automaticamente
   - Lista é recarregada com dados atualizados

#### **✅ Critérios de Sucesso**:
- Modal abre/fecha corretamente
- Dados são persistidos
- Lista atualiza sem reload completo
- Interface responsiva

---

## 🔬 Fluxos de Diagnósticos

### **Fluxo 8: Criar Relacionamento Diagnóstico**

#### **🎯 Objetivo**: Vincular praga, cultura e defensivo com dosagens
#### **👤 Usuário**: Admin, Editor especializado
#### **🚀 Início**: Usuário está editando um defensivo

```mermaid
graph TD
    A[Usuário editando defensivo] --> B[Acessa seção 'Diagnósticos']
    B --> C[Lista diagnósticos existentes]
    C --> D[Usuário clica 'Adicionar Diagnóstico']
    D --> E[Modal/Formulário diagnóstico abre]
    E --> F[Usuário seleciona praga]
    F --> G[Sistema filtra culturas compatíveis]
    G --> H[Usuário seleciona cultura]
    H --> I[Usuário define dosagens min/max]
    I --> J[Sistema valida limites regulamentares]
    J --> K{Dosagens válidas?}
    K -->|Não| L[Erro exibido com limites corretos]
    L --> I
    K -->|Sim| M[Usuário define parâmetros aplicação]
    M --> N[Período carência, volume calda, etc.]
    N --> O[Usuário adiciona restrições]
    O --> P[Salva diagnóstico]
    P --> Q[Sistema vincula no TBDIAGNOSTICO]
    Q --> R[Lista diagnósticos atualizada]
```

#### **📋 Passos Detalhados**:
1. **Seleção de Praga e Cultura**
   - Dropdown/Autocomplete de pragas
   - Filtro de culturas baseado na praga selecionada
   - Validação de compatibilidade praga-cultura

2. **Definição de Dosagens**
   - Campos dosagem mínima/máxima
   - Validação contra limites regulamentares
   - Cálculo automático de concentração na calda

3. **Parâmetros Técnicos**
   - Volume de calda (L/ha)
   - Número de aplicações
   - Intervalo entre aplicações
   - Período de carência
   - Condições especiais

4. **Restrições e Observações**
   - Restrições ambientais
   - Toxicidade para polinizadores
   - LMR (Limite Máximo de Resíduo)
   - Observações técnicas

#### **✅ Critérios de Sucesso**:
- Relacionamento correto entre entidades
- Dosagens validadas e seguras
- Todas as informações técnicas capturadas
- Dados consistentes no banco

---

### **Fluxo 9: Consultar Matriz de Compatibilidade**

#### **🎯 Objetivo**: Visualizar quais defensivos controlam cada praga por cultura
#### **👤 Usuário**: Todos os perfis (consulta técnica)
#### **🚀 Início**: Usuário quer consultar tratamento para praga específica

```mermaid
graph TD
    A[Usuário quer consultar tratamento] --> B[Acessa sistema de busca]
    B --> C[Seleciona praga de interesse]
    C --> D[Seleciona cultura afetada]
    D --> E[Sistema busca diagnósticos compatíveis]
    E --> F[Ordena por eficácia descrescente]
    F --> G[Exibe matriz de resultados]
    G --> H{Usuário quer detalhes?}
    H -->|Sim| I[Clica em tratamento específico]
    H -->|Não| J[Consulta finalizada]
    I --> K[Sistema exibe detalhes completos]
    K --> L[Dosagem, período, restrições]
    L --> M[Usuário pode calcular aplicação]
    M --> J
```

#### **📋 Passos Detalhados**:
1. **Interface de Consulta**
   - Seletores cascateados: praga → cultura
   - Auto-complete para agilizar busca
   - Filtros adicionais (classe, fabricante)

2. **Processamento da Consulta**
   - Busca na tabela TBDIAGNOSTICO
   - Join com dados de defensivos
   - Ordenação por critérios relevantes (eficácia, segurança)

3. **Exibição de Resultados**
   - Tabela com tratamentos disponíveis
   - Indicadores visuais (segurança, eficácia)
   - Links para detalhes completos

4. **Detalhamento Técnico**
   - Ficha completa do tratamento
   - Calculadora de dosagem
   - Recomendações específicas

#### **✅ Critérios de Sucesso**:
- Busca rápida e precisa
- Resultados relevantes e ordenados
- Informações técnicas completas
- Interface intuitiva para consulta

---

## 📤 Fluxos de Exportação

### **Fluxo 10: Exportar Dados do Sistema**

#### **🎯 Objetivo**: Gerar arquivos com dados para backup ou análise
#### **👤 Usuário**: Admin, Editor
#### **🚀 Início**: Usuário acessa menu Exportação

```mermaid
graph TD
    A[Usuário acessa /exportacao] --> B[Interface de exportação carregada]
    B --> C[Usuário seleciona tipo de dados]
    C --> D{Dados específicos ou completos?}
    D -->|Específicos| E[Usuário define filtros]
    D -->|Completos| F[Todas as tabelas selecionadas]
    E --> G[Usuário escolhe formato arquivo]
    F --> G
    G --> H{CSV, Excel ou JSON?}
    H -->|CSV| I[Configurações CSV específicas]
    H -->|Excel| J[Configurações Excel específicas]
    H -->|JSON| K[Estrutura JSON definida]
    I --> L[Usuário confirma exportação]
    J --> L
    K --> L
    L --> M[Sistema processa dados]
    M --> N[Arquivo gerado]
    N --> O[Download automático iniciado]
```

#### **📋 Passos Detalhados**:
1. **Seleção de Escopo**
   - Todas as tabelas ou seleção específica
   - Filtros por data, status, categoria
   - Preview do volume de dados

2. **Configuração do Formato**
   - **CSV**: Delimitador, codificação, cabeçalho
   - **Excel**: Múltiplas abas, formatação
   - **JSON**: Estrutura aninhada ou plana

3. **Processamento**
   - Validação da seleção
   - Processamento em background
   - Indicador de progresso

4. **Download**
   - Geração do arquivo final
   - Download automático no navegador
   - Log da operação de exportação

#### **✅ Critérios de Sucesso**:
- Todos os dados selecionados incluídos
- Formato de arquivo correto e íntegro
- Download funciona em todos os navegadores
- Performance adequada mesmo com grandes volumes

---

## 🔐 Fluxos de Autenticação

### **Fluxo 11: Login no Sistema**

#### **🎯 Objetivo**: Autenticar usuário e iniciar sessão
#### **👤 Usuário**: Todos os usuários registrados
#### **🚀 Início**: Usuário acessa URL do sistema sem estar autenticado

```mermaid
graph TD
    A[Usuário acessa sistema] --> B{Já autenticado?}
    B -->|Sim| C[Redirecionamento para dashboard]
    B -->|Não| D[Redirecionamento para /login]
    D --> E[Formulário de login exibido]
    E --> F[Usuário insere email/senha]
    F --> G[Usuário clica 'Entrar']
    G --> H[Sistema valida localmente]
    H --> I{Campos válidos?}
    I -->|Não| J[Erros de validação exibidos]
    J --> F
    I -->|Sim| K[Chamada Firebase Auth]
    K --> L{Credenciais corretas?}
    L -->|Não| M[Erro de autenticação exibido]
    M --> F
    L -->|Sim| N[Token de sessão criado]
    N --> O[Dados do usuário armazenados]
    O --> P[Redirecionamento para dashboard]
```

#### **📋 Passos Detalhados**:
1. **Detecção de Status**
   - Sistema verifica token existente
   - Valida validade do token Firebase
   - Redireciona conforme necessário

2. **Processo de Autenticação**
   - Validação local dos campos
   - Chamada ao Firebase Authentication
   - Tratamento de diferentes tipos de erro

3. **Estabelecimento de Sessão**
   - Armazenamento seguro do token
   - Carregamento de dados do perfil
   - Configuração de permissões
   - Inicialização do IndexedDB

4. **Navegação Pós-Login**
   - Redirecionamento para URL original (se existir)
   - Carregamento do dashboard padrão
   - Inicialização dos dados da aplicação

#### **✅ Critérios de Sucesso**:
- Autenticação segura via Firebase
- Sessão persistente entre navegações
- Tratamento adequado de erros
- Redirecionamento correto pós-login

---

### **Fluxo 12: Logout e Encerramento de Sessão**

#### **🎯 Objetivo**: Encerrar sessão do usuário com segurança
#### **👤 Usuário**: Usuário autenticado
#### **🚀 Início**: Usuário clica em "Sair" ou "Logout"

```mermaid
graph TD
    A[Usuário clica 'Logout'] --> B[Confirmação de logout solicitada]
    B --> C{Usuário confirma?}
    C -->|Não| D[Ação cancelada]
    C -->|Sim| E[Sistema limpa token local]
    E --> F[Chamada Firebase signOut]
    F --> G[IndexedDB é limpo]
    G --> H[Cache da aplicação limpo]
    H --> I[Estado da aplicação resetado]
    I --> J[Redirecionamento para /login]
    J --> K[Mensagem de logout bem-sucedido]
```

#### **📋 Passos Detalhados**:
1. **Confirmação** (opcional)
   - Dialog de confirmação se houver dados não salvos
   - Aviso sobre perda de progresso

2. **Limpeza de Sessão**
   - Remoção de tokens de autenticação
   - Signout do Firebase Auth
   - Limpeza do localStorage/sessionStorage

3. **Limpeza de Dados**
   - Clear do IndexedDB (dados sensíveis)
   - Limpeza de cache da aplicação
   - Reset do estado Vuex/state management

4. **Redirecionamento Seguro**
   - Navegação forçada para login
   - Prevenção de acesso por back button
   - Mensagem de confirmação do logout

#### **✅ Critérios de Sucesso**:
- Todos os dados de sessão removidos
- Firebase Auth deslogado corretamente
- Impossibilidade de voltar ao sistema via browser
- Feedback claro ao usuário

---

## 🔄 Fluxos de Sincronização e Manutenção

### **Fluxo 13: Inicialização da Aplicação**

#### **🎯 Objetivo**: Carregar todos os dados necessários na inicialização
#### **👤 Usuário**: Sistema automático
#### **🚀 Início**: Primeira carga da aplicação ou refresh

```mermaid
graph TD
    A[Aplicação iniciada] --> B[Verificar IndexedDB]
    B --> C{Base de dados existe?}
    C -->|Não| D[Criar estrutura IndexedDB]
    C -->|Sim| E[Verificar integridade dados]
    D --> F[Carregar JSONs iniciais]
    E --> G{Dados íntegros?}
    G -->|Não| F
    G -->|Sim| H[Base pronta para uso]
    F --> I[Processar TBFITOSSANITARIOS]
    I --> J[Processar TBPRAGAS]
    J --> K[Processar TBCULTURAS]
    K --> L[Processar TBDIAGNOSTICO]
    L --> M[Processar dados auxiliares]
    M --> N[Criar índices e contadores]
    N --> H
    H --> O[Aplicação pronta para uso]
```

#### **📋 Passos Detalhados**:
1. **Verificação Inicial**
   - Check da existência do IndexedDB
   - Validação da estrutura das tabelas
   - Verificação de integridade básica

2. **Carregamento de Dados**
   - Load sequencial dos arquivos JSON
   - Processamento e transformação dos dados
   - Inserção no IndexedDB com validação

3. **Preparação de Índices**
   - Criação de índices para performance
   - Cálculo de contadores dinâmicos
   - Preparação de caches de consulta

4. **Validação Final**
   - Verificação de referências cruzadas
   - Contagem de registros por tabela
   - Sinalização de aplicação pronta

#### **✅ Critérios de Sucesso**:
- Todos os dados carregados sem erro
- Índices criados corretamente
- Performance de consulta otimizada
- Aplicação responsiva após inicialização

---

**Esta documentação de fluxos serve como guia completo para implementação da UX/UI na migração Flutter Web, garantindo que todos os caminhos do usuário sejam preservados e otimizados.**