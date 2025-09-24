# 🌾 ReceituAGRO Cadastro - Domínios de Negócio Detalhados

## 📖 Índice dos Domínios
1. [Defensivos Fitossanitários](#-defensivos-fitossanitários)
2. [Pragas Agrícolas](#-pragas-agrícolas)  
3. [Culturas Agrícolas](#-culturas-agrícolas)
4. [Sistema de Diagnósticos](#-sistema-de-diagnósticos)
5. [Integração SecWeb](#-integração-secweb)

---

## 🛡️ Defensivos Fitossanitários

### **🎯 Definição do Domínio**
Defensivos fitossanitários são produtos químicos, biológicos ou biotecnológicos utilizados para controlar pragas, doenças e plantas daninhas em culturas agrícolas. Este domínio representa o coração do sistema ReceituAGRO.

### **📊 Estrutura de Dados Principal**

#### **Tabela: TBFITOSSANITARIOS**
```javascript
Estrutura do Registro de Defensivo:
{
  IdReg: "ID único gerado",           // Chave primária
  nomeComum: "Nome comercial",         // Ex: "Roundup", "Decis"
  nomeTecnico: "Princípio ativo",      // Ex: "Glifosato", "Deltametrina" 
  fabricante: "Empresa fabricante",    // Ex: "Bayer", "Syngenta"
  mapa: "Número de registro MAPA",     // Registro oficial brasileiro
  
  // Classificações Regulamentares
  classeAgronomica: "Tipo de defensivo",     // Codificado
  classAmbiental: "Impacto ambiental",       // Classes I-IV  
  toxico: "Classificação toxicológica",      // Codificado
  
  // Características Técnicas
  formulacao: "Tipo de formulação",          // EC, WG, SC, etc.
  modoAcao: "Como atua na praga",           // Sistêmico, contato, etc.
  ingredienteAtivo: "Substância ativa",     // Nome químico
  quantProduto: "Concentração",             // g/L, g/kg, etc.
  
  // Propriedades Físicas  
  corrosivo: "Sim/Não",
  inflamavel: "Sim/Não",
  
  // Status e Controles
  comercializado: 1/0,                      // Ativo no mercado
  elegivel: true/false,                     // Apto para uso
  secweb: true/false,                       // Integrado sistema externo
  
  // Métricas Calculadas (runtime)
  quantDiag: "Total diagnósticos",          // Calculado
  quantDiagP: "Diagnósticos preenchidos",   // Calculado  
  temInfo: "Tem informações extras",        // Calculado
  link: "URL para edição"                   // Gerado dinamicamente
}
```

### **🏭 Classificações e Códigos**

#### **Classes Agronômicas** (Decodificadas)
- **Inseticida**: Controle de insetos
- **Fungicida**: Controle de fungos e doenças
- **Herbicida**: Controle de plantas daninhas
- **Acaricida**: Controle de ácaros
- **Bactericida**: Controle de bactérias
- **Nematicida**: Controle de nematoides
- **Regulador de Crescimento**: Hormônios vegetais
- **Inseticida/Acaricida**: Ação dupla
- **Fungicida/Bactericida**: Ação dupla

#### **Classes Ambientais**
- **I - Altamente Perigoso**: Rótulo vermelho
- **II - Muito Perigoso**: Rótulo amarelo  
- **III - Medianamente Perigoso**: Rótulo azul
- **IV - Pouco Perigoso**: Rótulo verde

#### **Tipos de Formulação**
- **EC (Emulsifiable Concentrate)**: Concentrado emulsionável
- **WG (Water Dispersible Granule)**: Granulado dispersível
- **SC (Suspension Concentrate)**: Concentrado suspenso
- **WP (Wettable Powder)**: Pó molhável
- **SL (Soluble Liquid)**: Líquido solúvel

### **📈 Métricas e KPIs**

#### **Indicadores de Qualidade**
- **Completude de Diagnósticos**: `quantDiagP / quantDiag`
- **Cobertura de Informações**: `temInfo > 0`
- **Status Regulamentar**: `comercializado == 1`
- **Integração Externa**: `secweb == true`

#### **Filtros de Negócio** 
1. **Para Exportação**: Defensivos com diagnósticos completos
2. **Sem Diagnóstico**: `quantDiag == 0`
3. **Diagnóstico Faltante**: `quantDiagP < quantDiag`
4. **Sem Informações**: `temInfo == 0`

### **🔗 Relacionamentos**
- **1:N com TBFITOSSANITARIOSINFO**: Informações detalhadas
- **1:N com TBDIAGNOSTICO**: Relacionamentos com pragas/culturas
- **N:1 com Fabricantes**: Agrupamento por empresa
- **N:N com Pragas**: Via tabela diagnósticos
- **N:N com Culturas**: Via tabela diagnósticos

---

## 🐛 Pragas Agrícolas  

### **🎯 Definição do Domínio**
Pragas agrícolas incluem insetos, fungos, bactérias, vírus, nematoides e plantas daninhas que causam danos econômicos às culturas. Este domínio cataloga organismos nocivos e suas características.

### **📊 Estrutura de Dados Principal**

#### **Tabela: TBPRAGAS**
```javascript
Estrutura do Registro de Praga:
{
  IdReg: "ID único",                        // Chave primária
  nomeCientifico: "Nome binomial",          // Ex: "Spodoptera frugiperda"
  nomeComum: "Nome popular",                // Ex: "Lagarta-do-cartucho"
  nomeSecundarios: "Sinônimos",             // Nomes regionais/alternativos
  
  // Classificação Taxonômica
  tipoPraga: "Categoria principal",         // Inseto, Fungo, Bactéria, etc.
  familia: "Família taxonômica",            // Ex: "Noctuidae"
  ordem: "Ordem taxonômica",                // Ex: "Lepidoptera"
  classe: "Classe taxonômica",              // Ex: "Insecta"
  
  // Recursos Multimídia
  img: "Nome do arquivo de imagem",         // Ex: "spodoptera_frugiperda.jpg"
  info: "Texto descritivo",                 // Informações técnicas
  
  // Características Biológicas
  cicloVida: "Duração do ciclo",            // Em dias
  hospedeiros: "Culturas atacadas",         // Array de culturas
  distribuicao: "Regiões de ocorrência",    // Geográfica
  sintomas: "Danos causados",               // Descrição visual
  
  // Controle e Manejo
  controlesBiologicos: "Inimigos naturais", // Predadores, parasitas
  controlesQuimicos: "Defensivos eficazes", // Relacionamento
  controlesCulturais: "Práticas preventivas", // Manejo integrado
  
  // Status e Metadata  
  status: "Ativo/Inativo",
  dataAtualizacao: "Última modificação",
  fonte: "Referência científica"
}
```

### **🏷️ Tipos de Pragas**

#### **Por Categoria Taxonômica**
- **Insetos**: Lepidópteros, coleópteros, hemípteros, etc.
- **Ácaros**: Tetranychidae, Eriophyidae, etc.  
- **Fungos**: Patógenos foliares, radiculares, etc.
- **Bactérias**: Fitopatógenos sistêmicos
- **Vírus**: Mosaicos, amarelos, etc.
- **Nematoides**: Parasitas radiculares
- **Plantas Daninhas**: Monocotiledôneas, dicotiledôneas

#### **Por Hábito Alimentar**
- **Sugadores**: Pulgões, percevejos, cigarrinhas
- **Mastigadores**: Lagartas, gafanhotos, besouros  
- **Raspadores**: Trips, ácaros
- **Minadores**: Larvas que fazem galerias
- **Perfuradores**: Brocas de colmo, frutos

### **🖼️ Gestão de Imagens**
- **Localização**: `/src/assets/bigsize/{nomeCientifico}.jpg`  
- **Qualidade**: Alta resolução para identificação
- **Padronização**: Nomenclatura científica no arquivo
- **Fallback**: `sem-imagem.jpg` quando não disponível
- **Zoom**: Funcionalidade de ampliação nas telas

### **📚 Informações Técnicas**
- **Morfologia**: Características de identificação
- **Biologia**: Ciclo de vida, reprodução, comportamento  
- **Ecologia**: Condições favoráveis, sazonalidade
- **Danos**: Sintomas, perdas econômicas
- **Manejo**: Estratégias de controle integrado

---

## 🌱 Culturas Agrícolas

### **🎯 Definição do Domínio**  
Culturas agrícolas são plantas cultivadas comercialmente para alimentação, fibra, combustível ou outros propósitos econômicos. Este domínio organiza informações botânicas e agronômicas.

### **📊 Estrutura de Dados Principal**

#### **Tabela: TBCULTURAS**
```javascript
Estrutura do Registro de Cultura:
{
  IdReg: "ID único",                        // Chave primária
  cultura: "Nome comum da cultura",         // Ex: "Milho", "Soja", "Café"  
  cientifico: "Nome científico",            // Ex: "Zea mays", "Glycine max"
  
  // Classificação Botânica
  familia: "Família botânica",              // Ex: "Poaceae", "Fabaceae"
  genero: "Gênero",                         // Ex: "Zea", "Glycine"
  especie: "Espécie",                       // Ex: "mays", "max"
  
  // Características Agronômicas
  tipo: "Grão/Fibra/Hortícola/etc",        // Classificação por uso
  ciclo: "Anual/Perene",                    // Duração do ciclo produtivo
  clima: "Tropical/Temperado/etc",          // Adaptação climática
  
  // Informações de Cultivo
  espacamento: "Distância de plantio",      // Em metros
  densidade: "Plantas por hectare",         // População
  irrigacao: "Necessidade hídrica",         // mm/ciclo
  fertilizacao: "Recomendações nutricionais", // NPK
  
  // Pragas Associadas
  pragasPrincipais: "Lista de pragas comuns", // Array de IDs
  doencasPrincipais: "Patógenos frequentes",  // Array de IDs
  
  // Dados Econômicos
  produtividade: "Média nacional",          // ton/ha
  valorComercial: "Preço médio",            // R$/ton
  areaPlantada: "Hectares no Brasil",       // Área total
  
  // Status e Controle
  status: "Ativo/Inativo",
  regiao: "Regiões produtoras",             // Norte, Sul, etc.
  safra: "Período de cultivo"               // Datas de plantio/colheita
}
```

### **🗂️ Categorização de Culturas**

#### **Por Tipo de Uso**
- **Grãos**: Milho, soja, trigo, arroz, feijão
- **Fibras**: Algodão, linho, juta
- **Fruticultura**: Citros, banana, manga, uva  
- **Horticultura**: Tomate, batata, cebola, alface
- **Silvicultura**: Eucalipto, pinus, teca
- **Pastagens**: Brachiaria, colonião, azevém
- **Ornamentais**: Flores, plantas decorativas

#### **Por Ciclo Produtivo**
- **Anuais**: Uma safra por ano
- **Semiperenes**: 2-5 anos de produção
- **Perenes**: Produção contínua por anos

#### **Por Adaptação Climática**  
- **Tropicais**: Clima quente e úmido
- **Temperadas**: Clima ameno
- **Semiáridas**: Resistentes à seca
- **Irrigadas**: Dependentes de irrigação

### **🧬 Relacionamentos Genéticos**
- **Variedades**: Cultivares específicas
- **Híbridos**: Cruzamentos controlados  
- **Transgênicos**: Modificados geneticamente
- **Crioulas**: Variedades tradicionais

---

## 🔬 Sistema de Diagnósticos

### **🎯 Definição do Domínio**
O sistema de diagnósticos é o mecanismo central que relaciona pragas específicas com culturas afetadas e defensivos recomendados, incluindo dosagens, períodos de aplicação e restrições.

### **📊 Estrutura de Dados Principal**

#### **Tabela: TBDIAGNOSTICO**
```javascript
Estrutura do Relacionamento Diagnóstico:
{
  IdReg: "ID único do diagnóstico",         // Chave primária
  fkIdDefensivo: "ID do defensivo",         // Foreign key
  fkIdPraga: "ID da praga",                 // Foreign key  
  fkIdCultura: "ID da cultura",             // Foreign key
  
  // Dosagens e Aplicação
  dsMin: "Dosagem mínima",                  // mL/ha ou g/ha
  dsMax: "Dosagem máxima",                  // mL/ha ou g/ha
  dsUnidade: "Unidade de medida",           // mL/ha, g/ha, kg/ha
  
  // Parâmetros de Aplicação  
  volumeCalda: "Volume de água",            // L/ha
  concentracao: "Concentração na calda",    // %
  numeroAplicacoes: "Aplicações por ciclo", // 1, 2, 3, etc.
  intervaloAplicacao: "Dias entre aplicações", // dias
  
  // Timing e Condições
  estadoFenologico: "Quando aplicar",       // V4, R1, etc. (milho)
  condicoesClimaticas: "Restrições clima",  // Temperatura, vento, etc.
  periodoCarencia: "Dias antes da colheita", // PHI (Pre-Harvest Interval)
  
  // Eficácia e Restrições  
  eficacia: "Taxa de controle esperada",    // 80%, 90%, etc.
  resistencia: "Histórico de resistência",  // Baixa, média, alta
  fitotoxicidade: "Risco de dano à planta", // Sim/Não
  
  // Condições Especiais
  aplicacaoNoturna: "Requer aplicação noturna", // true/false
  adjuvante: "Necessita adjuvante",         // Sim/Não
  tipoAdjuvante: "Tipo recomendado",        // Espalhante, penetrante
  
  // Restrições Ambientais
  restricaoAbelhas: "Tóxico para abelhas",  // Alta, média, baixa
  restricaoAquaticos: "Tóxico peixes",      // true/false  
  lmr: "Limite máximo de resíduo",          // mg/kg
  
  // Metadata
  status: "Ativo/Inativo",                  // Status do diagnóstico
  dataRegistro: "Data de cadastro",         // Timestamp
  dataAtualizacao: "Última atualização",    // Timestamp
  fonte: "Referência técnica",              // Embrapa, universidade, etc.
  observacoes: "Notas adicionais"           // Texto livre
}
```

### **🧮 Cálculos e Algoritmos**

#### **Cálculo de Dosagem**
```javascript
// Função para calcular quantidade de produto
function calcularQuantidade(area_ha, dosagem_por_ha, concentracao_produto) {
  const quantidade_produto = (area_ha * dosagem_por_ha) / concentracao_produto;
  return quantidade_produto; // em L ou kg
}

// Função para calcular volume de calda  
function calcularVolCalda(area_ha, volume_por_ha) {
  return area_ha * volume_por_ha; // em litros
}

// Função para validar período de aplicação
function validarPeriodo(data_aplicacao, data_colheita, periodo_carencia) {
  const dias_para_colheita = (data_colheita - data_aplicacao) / (1000 * 60 * 60 * 24);
  return dias_para_colheita >= periodo_carencia;
}
```

#### **Algoritmo de Recomendação**
```javascript
// Busca diagnósticos compatíveis
function buscarTratamentos(praga_id, cultura_id, criterios = {}) {
  return diagnosticos.filter(diag => {
    return diag.fkIdPraga === praga_id && 
           diag.fkIdCultura === cultura_id &&
           diag.status === 'Ativo' &&
           (!criterios.eficacia_minima || diag.eficacia >= criterios.eficacia_minima);
  }).sort((a, b) => b.eficacia - a.eficacia); // Ordena por eficácia
}
```

### **📊 Métricas de Qualidade**

#### **Indicadores de Completude**  
- **Diagnósticos com Dosagem**: `dsMin != null && dsMax != null`
- **Informações Completas**: Todos os campos críticos preenchidos
- **Atualizações Recentes**: Modificados nos últimos 12 meses
- **Validação Científica**: Com fonte/referência

#### **KPIs do Sistema**
- **Taxa de Cobertura**: `(Pragas com diagnóstico / Total pragas) * 100`
- **Eficácia Média**: Média ponderada das eficácias registradas  
- **Densidade de Relacionamentos**: Diagnósticos por praga/cultura
- **Atualização dos Dados**: Frequência de manutenção

---

## 🌐 Integração SecWeb

### **🎯 Definição do Domínio**
A integração SecWeb conecta o sistema com uma base externa de defensivos, permitindo validação cruzada e sincronização de dados oficiais.

### **📋 Estrutura da Integração**

#### **Arquivo: asecweb.json**
```javascript
// Estrutura do registro SecWeb
{
  nomeComum: "Nome no sistema externo",
  mapa: "Número MAPA correspondente",  
  status: "Ativo/Inativo",
  dataAtualizacao: "Timestamp da sincronização"
}
```

### **🔄 Processo de Sincronização**
1. **Carregamento**: Sistema carrega `asecweb.json` na inicialização
2. **Matching**: Compara `nomeComum` e `mapa` com base local
3. **Marcação**: Define `secweb: true` nos registros encontrados  
4. **Indicação Visual**: Ícone verde na interface para itens sincronizados
5. **Atualização**: Processo periódico de refresh dos dados

### **📈 Benefícios da Integração**
- **Validação**: Confirmação de dados oficiais
- **Atualização**: Sincronização com registros atualizados
- **Compliance**: Garantia de conformidade regulamentar
- **Indicação Visual**: Usuário sabe quais dados são oficiais

---

## 🔗 Relacionamentos Entre Domínios

### **Matriz de Relacionamentos**
```
Defensivos ←→ Diagnósticos ←→ Pragas
     ↓              ↓           ↓
Fabricantes    Culturas    Taxonomia
     ↓              ↓           ↓  
  SecWeb      Fenologia   Imagens
```

### **Regras de Negócio Críticas**
1. **Defensivo sem Diagnóstico**: Permitido, mas sinalizado
2. **Praga sem Imagem**: Tolerado, usa placeholder  
3. **Cultura sem Classificação**: Requer família botânica mínima
4. **Diagnóstico sem Dosagem**: Marcado como incompleto
5. **SecWeb Divergente**: Alerta para verificação manual

### **Integridade Referencial**
- **Cascata na Exclusão**: Diagnósticos órfãos são removidos
- **Validação de FK**: IDs devem existir antes da criação
- **Soft Delete**: Marca como inativo em vez de excluir
- **Auditoria**: Log de todas as operações críticas

---

**Esta documentação serve como base técnica completa para implementação dos domínios de negócio na migração Flutter Web, preservando toda a lógica e regras atuais.**