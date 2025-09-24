# 📖 ReceituAGRO Cadastro - Visão Geral do Sistema

## 🎯 Propósito do Sistema

O **ReceituAGRO Cadastro** é um sistema web de gestão agrícola especializado em três domínios principais:
- **Defensivos Fitossanitários** (Pesticidas)  
- **Pragas Agrícolas**
- **Culturas Agrícolas**

### 🏷️ Características Principais
- **Aplicação Web Vue.js**: Interface responsiva baseada em Vuetify 2
- **Base de Dados JSON**: Mais de 100 arquivos JSON com dados agrícolas estruturados
- **Autenticação Firebase**: Sistema de login integrado
- **Funcionalidades CRUD**: Criação, leitura, atualização e exclusão de registros
- **Sistema de Exportação**: Export de dados para diferentes formatos
- **Relacionamentos Complexos**: Diagnósticos cruzados entre pragas, culturas e defensivos

---

## 🏗️ Arquitetura Atual (Vue.js)

### **Stack Tecnológico**
```
Frontend: Vue.js 2.6 + Vuetify 2.6
Database: Arquivos JSON + IndexedDB
Authentication: Firebase Auth
State Management: Vuex
Router: Vue Router
Build Tool: Vue CLI + Webpack
```

### **Estrutura de Dados**
- **10.000+ registros** distribuídos em 7 tabelas relacionadas
- **Dados offline-first** carregados no IndexedDB na inicialização
- **Relacionamentos complexos** entre defensivos, pragas e culturas via tabela TBDIAGNOSTICO

---

## 📊 Domínios de Negócio

### **1. Defensivos Fitossanitários (Pesticidas)**
- **Objetivo**: Cadastro e gestão de produtos fitossanitários  
- **Dados**: Nome comercial, princípio ativo, fabricante, classificação toxicológica, modo de ação
- **Volume**: ~3.000 registros principais + informações detalhadas
- **Funcionalidades**: CRUD completo, filtros avançados, exportação, cópia rápida

### **2. Pragas Agrícolas**
- **Objetivo**: Catálogo de pragas e doenças que afetam culturas
- **Dados**: Nome científico, nome comum, tipo de praga, imagens, informações técnicas
- **Volume**: ~2.000 registros de pragas catalogadas
- **Funcionalidades**: Listagem, busca, edição, visualização detalhada

### **3. Culturas Agrícolas**
- **Objetivo**: Base de dados de culturas e plantas agrícolas
- **Dados**: Nome da cultura, nome científico, família botânica
- **Volume**: ~500 culturas registradas
- **Funcionalidades**: CRUD básico, listagem categorizada

### **4. Diagnósticos (Relacionamentos)**
- **Objetivo**: Relacionar pragas específicas com culturas e seus tratamentos
- **Dados**: Dosagens, períodos de aplicação, eficácia, restrições
- **Volume**: ~5.000 relacionamentos diagnósticos
- **Funcionalidades**: Matriz de compatibilidade, cálculo de dosagens, validações

---

## 🖥️ Principais Interfaces de Usuário

### **Dashboard Principal**
- **Rota**: `/` ou `/defensivoslistar`
- **Função**: Lista principal de defensivos com filtros e ações
- **Componentes**: DataTable, filtros, botões de ação, busca global

### **Gestão de Defensivos**
- **Listagem**: `/defensivoslistar` - Grid principal com filtros avançados
- **Cadastro**: `/defensivoscadastro` - Formulário completo de defensivos
- **Importação**: `/defensivosimportacao` - Importação em lote

### **Gestão de Pragas**
- **Listagem**: `/pragas/listar` - Catálogo de pragas com imagens
- **Cadastro**: `/pragas/cadastro` - Formulário de cadastro de pragas

### **Gestão de Culturas**
- **Listagem**: `/culturas` - Lista simples de culturas
- **Modal de Cadastro**: Popup integrado para CRUD rápido

### **Ferramentas**
- **Exportação**: `/exportacao` - Interface para export de dados
- **Autenticação**: `/login` - Tela de login Firebase

---

## 🔗 Fluxos de Trabalho Principais

### **Fluxo 1: Cadastro de Novo Defensivo**
1. Usuário acessa lista de defensivos
2. Clica em "Novo" 
3. Preenche formulário com dados obrigatórios
4. Sistema valida e salva no IndexedDB
5. Retorna para listagem atualizada

### **Fluxo 2: Diagnóstico Praga-Cultura**
1. Usuário seleciona defensivo na lista
2. Acessa detalhes do defensivo
3. Visualiza pragas compatíveis
4. Define dosagens por cultura
5. Salva relacionamento diagnóstico

### **Fluxo 3: Exportação de Dados**
1. Usuário filtra dados desejados
2. Acessa interface de exportação
3. Seleciona formato e parâmetros
4. Sistema gera arquivo para download
5. Download automático ou manual

---

## 📈 Métricas e KPIs

### **Indicadores de Qualidade dos Dados**
- **Defensivos com Diagnóstico Completo**: X/Total
- **Pragas com Imagens**: X/Total  
- **Relacionamentos Preenchidos**: X/Total
- **Dados Validados**: Percentual de completude

### **Funcionalidades Críticas**
- ✅ **Filtros Avançados**: Por status, completude, fabricante
- ✅ **Busca Global**: Texto livre em todos os campos
- ✅ **Validação de Dados**: Regras de negócio aplicadas
- ✅ **Backup/Restore**: Exportação completa dos dados
- ✅ **Performance**: Carregamento < 3 segundos

---

## 🎯 Valor de Negócio

### **Para Agrônomos**
- Base completa de defensivos homologados
- Dosagens precisas por cultura e praga
- Informações de segurança e toxicidade
- Histórico de eficácia comprovada

### **Para Produtores**
- Recomendações técnicas confiáveis
- Cálculo automático de dosagens
- Informações de custo-benefício
- Compliance com regulamentações

### **Para Consultores**
- Ferramenta profissional de consultoria
- Relatórios personalizáveis
- Integração com outros sistemas
- Dados sempre atualizados

---

## 🚀 Próximos Passos da Migração

A migração para Flutter Web manterá **100% da funcionalidade** atual, adicionando:
- Performance superior com compilação nativa
- Arquitetura SOLID para manutenibilidade
- Integração com ecossistema Flutter do monorepo
- Preparação para versões mobile futuras
- Melhor experiência de usuário e developer experience

---

**Este documento serve como base para entender o sistema atual antes da migração para Flutter Web com arquitetura SOLID.**