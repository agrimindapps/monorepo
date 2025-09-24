# ⚖️ ReceituAGRO Cadastro - Regras de Negócio e Funções

## 📋 Índice das Regras
1. [Regras de Validação](#-regras-de-validação)
2. [Regras de Cálculo](#-regras-de-cálculo)
3. [Regras de Relacionamento](#-regras-de-relacionamento)
4. [Regras de Segurança](#-regras-de-segurança)
5. [Regras de Interface](#-regras-de-interface)
6. [Funções Principais](#-funções-principais)

---

## ✅ Regras de Validação

### **Validações de Defensivos**

#### **Campos Obrigatórios**
```javascript
// Validação básica de defensivo
function validarDefensivo(defensivo) {
  const erros = [];
  
  if (!defensivo.nomeComum || defensivo.nomeComum.trim() === '') {
    erros.push('Nome Comercial é obrigatório');
  }
  
  if (!defensivo.nomeTecnico || defensivo.nomeTecnico.trim() === '') {
    erros.push('Nome Técnico/Princípio Ativo é obrigatório');
  }
  
  if (!defensivo.fabricante || defensivo.fabricante.trim() === '') {
    erros.push('Fabricante é obrigatório');
  }
  
  if (!defensivo.mapa || !isValidMapa(defensivo.mapa)) {
    erros.push('Número MAPA deve ter formato válido');
  }
  
  return erros;
}

// Validação específica do número MAPA
function isValidMapa(mapa) {
  // MAPA deve ser numérico e ter entre 3 e 8 dígitos
  return /^\d{3,8}$/.test(mapa);
}
```

#### **Validações de Formato**
- **Nome Comercial**: Máximo 100 caracteres, sem símbolos especiais excessivos
- **Princípio Ativo**: Deve seguir nomenclatura química/biológica padrão
- **Concentração**: Formato "XXX g/L" ou "XXX g/kg" com validação numérica
- **MAPA**: Apenas números, 3-8 dígitos
- **Classificações**: Devem existir nas listas pré-definidas

### **Validações de Pragas**

#### **Nomenclatura Científica**
```javascript
function validarNomeCientifico(nome) {
  // Formato binomial: Gênero espécie (itálico)
  const regex = /^[A-Z][a-z]+ [a-z]+( [a-z]+)*$/;
  
  if (!regex.test(nome)) {
    return 'Nome científico deve seguir nomenclatura binomial (ex: Spodoptera frugiperda)';
  }
  
  // Verificar se não é duplicado
  if (existePragaComNome(nome)) {
    return 'Já existe uma praga com este nome científico';
  }
  
  return null; // Válido
}
```

#### **Validações de Mídia**
- **Imagens**: Formatos JPG/PNG, máximo 2MB, mínimo 300x300px
- **Nomenclatura de Arquivo**: Deve corresponder ao nome científico
- **Qualidade**: Resolução adequada para identificação

### **Validações de Culturas**

#### **Dados Botânicos**
```javascript
function validarCultura(cultura) {
  const erros = [];
  
  // Nome da cultura obrigatório e único
  if (!cultura.cultura || existeCulturaComNome(cultura.cultura)) {
    erros.push('Nome da cultura deve ser único e obrigatório');
  }
  
  // Nome científico deve seguir padrão
  if (cultura.cientifico && !isValidNomeCientifico(cultura.cientifico)) {
    erros.push('Nome científico deve seguir nomenclatura botânica');
  }
  
  return erros;
}
```

---

## 🧮 Regras de Cálculo

### **Cálculos de Dosagem**

#### **Fórmula Básica de Aplicação**
```javascript
function calcularAplicacao(params) {
  const {
    areaHectares,
    dosagePorHa,
    concentracaoProduto,
    volumeCalda = 200 // L/ha padrão
  } = params;
  
  // Quantidade de produto comercial necessária
  const quantidadeProduto = (areaHectares * dosagePorHa * volumeCalda) / concentracaoProduto;
  
  // Volume total de calda
  const volumeTotalCalda = areaHectares * volumeCalda;
  
  // Concentração na calda final
  const concentracaoCalda = (dosagePorHa / volumeCalda) * 100; // %
  
  return {
    quantidadeProduto: Math.ceil(quantidadeProduto * 10) / 10, // Arredondar para cima
    volumeTotalCalda,
    concentracaoCalda: Math.round(concentracaoCalda * 100) / 100,
    custoAplicacao: calcularCusto(quantidadeProduto, params.precoLitro)
  };
}
```

#### **Validação de Limites de Dosagem**
```javascript
function validarDosagem(dosagem, defensivo) {
  const { dsMin, dsMax } = defensivo;
  
  if (dosagem < dsMin) {
    return {
      valido: false,
      erro: `Dosagem abaixo do mínimo recomendado (${dsMin} mL/ha)`
    };
  }
  
  if (dosagem > dsMax) {
    return {
      valido: false,
      erro: `Dosagem acima do máximo permitido (${dsMax} mL/ha)`
    };
  }
  
  return { valido: true };
}
```

### **Cálculos de Período de Carência**

#### **Validação de Segurança Alimentar**
```javascript
function validarPeriodoCarencia(dataAplicacao, dataColheitaPrevista, periodoCarencia) {
  const diasRestantes = Math.floor((dataColheitaPrevista - dataAplicacao) / (1000 * 60 * 60 * 24));
  
  if (diasRestantes < periodoCarencia) {
    return {
      permitido: false,
      diasFaltantes: periodoCarencia - diasRestantes,
      novaDataColheita: new Date(dataAplicacao.getTime() + (periodoCarencia * 24 * 60 * 60 * 1000))
    };
  }
  
  return { permitido: true };
}
```

---

## 🔗 Regras de Relacionamento

### **Regras de Diagnóstico**

#### **Compatibilidade Praga-Cultura**
```javascript
function validarCompatibilidade(pragaId, culturaId) {
  // Verificar se a praga realmente ataca essa cultura
  const hospedeiros = getPragaById(pragaId).hospedeiros;
  
  if (!hospedeiros.includes(culturaId)) {
    return {
      compativel: false,
      motivo: 'Esta praga não é documentada como problema nesta cultura'
    };
  }
  
  return { compativel: true };
}
```

#### **Regras de Sobreposição**
- **Múltiplos Diagnósticos**: Permitido para diferentes estágios fenológicos
- **Mesmo Modo de Ação**: Alertar sobre possível resistência
- **Incompatibilidade Química**: Validar se defensivos podem ser misturados
- **Período de Reentrada**: Considerar tempo de segurança para trabalhadores

### **Regras de Integridade Referencial**

#### **Exclusão Cascata**
```javascript
function excluirDefensivo(defensivoId) {
  // Verificar diagnósticos dependentes
  const diagnosticos = getDiagnosticosByDefensivo(defensivoId);
  
  if (diagnosticos.length > 0) {
    return {
      sucesso: false,
      erro: `Existem ${diagnosticos.length} diagnósticos vinculados. Remova-os primeiro.`,
      diagnosticosDependentes: diagnosticos
    };
  }
  
  // Soft delete para manter histórico
  return softDeleteDefensivo(defensivoId);
}
```

---

## 🔐 Regras de Segurança

### **Controle de Acesso**

#### **Permissões por Funcionalidade**
```javascript
const permissoes = {
  'VISUALIZAR_DEFENSIVOS': ['admin', 'editor', 'viewer'],
  'CRIAR_DEFENSIVOS': ['admin', 'editor'],
  'EDITAR_DEFENSIVOS': ['admin', 'editor'],  
  'EXCLUIR_DEFENSIVOS': ['admin'],
  'EXPORTAR_DADOS': ['admin', 'editor'],
  'IMPORTAR_DADOS': ['admin']
};

function verificarPermissao(usuario, acao) {
  return permissoes[acao]?.includes(usuario.role) || false;
}
```

#### **Validação de Sessão**
```javascript
function validarSessao() {
  // Firebase Auth validation
  if (!window.uid || !firebase.auth().currentUser) {
    return {
      valida: false,
      redirect: '/login'
    };
  }
  
  // Verificar expiração de token
  return firebase.auth().currentUser.getIdToken(true)
    .then(token => ({ valida: true, token }))
    .catch(() => ({ valida: false, redirect: '/login' }));
}
```

### **Auditoria de Dados**

#### **Log de Operações Críticas**
```javascript
function logOperacao(operacao, usuario, dadosAnteriores, dadosNovos) {
  const logEntry = {
    timestamp: new Date(),
    usuario: usuario.email,
    operacao, // CREATE, UPDATE, DELETE
    tabela: operacao.tabela,
    registroId: operacao.id,
    dadosAnteriores: operacao === 'UPDATE' ? dadosAnteriores : null,
    dadosNovos: operacao !== 'DELETE' ? dadosNovos : null,
    ip: getUserIP(),
    userAgent: navigator.userAgent
  };
  
  salvarLogAuditoria(logEntry);
}
```

---

## 🖥️ Regras de Interface

### **Regras de Exibição**

#### **Filtros Dinâmicos**
```javascript
function aplicarFiltroDefensivos(filtro, lista) {
  switch(filtro) {
    case 'TODOS':
      return lista;
      
    case 'PARA_EXPORTACAO':
      return lista.filter(item => 
        item.quantDiag > 0 && 
        item.quantDiagP === item.quantDiag &&
        item.temInfo > 0
      );
      
    case 'SEM_DIAGNOSTICO':
      return lista.filter(item => item.quantDiag === 0);
      
    case 'DIAGNOSTICO_FALTANTE':
      return lista.filter(item => 
        item.quantDiag > 0 && 
        item.quantDiagP < item.quantDiag
      );
      
    case 'SEM_INFORMACOES':
      return lista.filter(item => item.temInfo === 0);
      
    default:
      return lista;
  }
}
```

#### **Formatação Condicional**
```javascript
function formatarColunaStatus(item) {
  // Ícone verde para diagnósticos completos
  if (item.quantDiag > 0 && item.quantDiagP === item.quantDiag) {
    return '<v-icon color="success">fas fa-check-circle</v-icon>';
  }
  
  // Ícone amarelo para parcialmente completo
  if (item.quantDiagP > 0) {
    return '<v-icon color="warning">fas fa-exclamation-triangle</v-icon>';
  }
  
  // Vazio para sem diagnósticos
  return '';
}
```

### **Regras de Navegação**

#### **Breadcrumbs Contextuais**
```javascript
function gerarBreadcrumbs(rota, params) {
  const breadcrumbs = [{ text: 'Home', to: '/' }];
  
  switch(rota) {
    case 'defensivos':
      breadcrumbs.push({ text: 'Defensivos', to: '/defensivoslistar' });
      if (params.id) {
        breadcrumbs.push({ 
          text: params.id === 'x' ? 'Novo' : 'Editar',
          disabled: true 
        });
      }
      break;
      
    case 'pragas':
      breadcrumbs.push({ text: 'Pragas', to: '/pragas/listar' });
      if (params.id) {
        breadcrumbs.push({ text: 'Editar', disabled: true });
      }
      break;
  }
  
  return breadcrumbs;
}
```

---

## 🛠️ Funções Principais

### **Gerenciamento de Dados**

#### **Função de Busca Global**
```javascript
async function buscarDefensivos(termoBusca = '', filtros = {}) {
  try {
    // Carregar dados das tabelas relacionadas
    const [defensivos, diagnosticos, defensivosInfo, secweb] = await Promise.all([
      dbGetAll({ table: 'TBFITOSSANITARIOS' }),
      dbGetAll({ table: 'TBDIAGNOSTICO' }),
      dbGetAll({ table: 'TBFITOSSANITARIOSINFO' }),
      import('../assets/database/json/asecweb.json')
    ]);
    
    // Processar diagnósticos para contagem
    const contadores = processarDiagnosticos(diagnosticos);
    
    // Enriquecer dados dos defensivos
    const defensivosEnriquecidos = defensivos.map(defensivo => {
      return {
        ...defensivo,
        quantDiag: contadores.total[defensivo.IdReg] || 0,
        quantDiagP: contadores.preenchidos[defensivo.IdReg] || 0,
        temInfo: contarInformacoes(defensivosInfo, defensivo.IdReg),
        secweb: verificarSecWeb(secweb, defensivo),
        link: `/defensivoscadastro?id=${defensivo.IdReg}`,
        toxico: decodificarToxico(defensivo.toxico)
      };
    });
    
    // Aplicar filtros
    let resultado = aplicarFiltros(defensivosEnriquecidos, filtros);
    
    // Aplicar busca textual
    if (termoBusca) {
      resultado = aplicarBuscaTextual(resultado, termoBusca);
    }
    
    return resultado;
    
  } catch (error) {
    console.error('Erro ao buscar defensivos:', error);
    throw error;
  }
}
```

#### **Função de Processamento de Diagnósticos**
```javascript
function processarDiagnosticos(diagnosticos) {
  const contadores = {
    total: {},
    preenchidos: {}
  };
  
  diagnosticos.forEach(diag => {
    const defensivoId = diag.fkIdDefensivo;
    
    // Contar total de diagnósticos
    contadores.total[defensivoId] = (contadores.total[defensivoId] || 0) + 1;
    
    // Contar diagnósticos preenchidos (com dosagem)
    if (diag.dsMin !== null && diag.dsMax !== null && 
        diag.dsMin.toString().length > 0 || diag.dsMax.toString().length > 0) {
      contadores.preenchidos[defensivoId] = (contadores.preenchidos[defensivoId] || 0) + 1;
    }
  });
  
  return contadores;
}
```

### **Funções de Exportação**

#### **Exportação Completa do Sistema**
```javascript
async function exportarDadosCompletos(formato = 'json') {
  try {
    // Coletar todos os dados
    const dados = {
      metadata: {
        dataExportacao: new Date(),
        versao: '1.0',
        totalRegistros: 0
      },
      defensivos: await dbGetAll({ table: 'TBFITOSSANITARIOS' }),
      pragas: await dbGetAll({ table: 'TBPRAGAS' }),
      culturas: await dbGetAll({ table: 'TBCULTURAS' }),
      diagnosticos: await dbGetAll({ table: 'TBDIAGNOSTICO' }),
      defensivosInfo: await dbGetAll({ table: 'TBFITOSSANITARIOSINFO' })
    };
    
    dados.metadata.totalRegistros = Object.values(dados)
      .filter(item => Array.isArray(item))
      .reduce((total, array) => total + array.length, 0);
    
    // Gerar arquivo conforme formato
    switch(formato) {
      case 'json':
        return gerarArquivoJSON(dados);
      case 'csv':
        return gerarArquivoCSV(dados);
      case 'excel':
        return gerarArquivoExcel(dados);
      default:
        throw new Error('Formato não suportado');
    }
    
  } catch (error) {
    console.error('Erro na exportação:', error);
    throw error;
  }
}
```

### **Funções de Validação Complexa**

#### **Validação Cruzada de Dados**
```javascript
function validarIntegridadeCompleta() {
  const relatorio = {
    defensivos: {
      total: 0,
      semDiagnostico: 0,
      diagnosticoIncompleto: 0,
      semInformacoes: 0
    },
    pragas: {
      total: 0,
      semImagem: 0,
      semInformacoes: 0
    },
    culturas: {
      total: 0,
      semNomeCientifico: 0
    },
    diagnosticos: {
      total: 0,
      semDosagem: 0,
      inconsistentes: 0
    }
  };
  
  // Executar validações
  Promise.all([
    validarDefensivos(relatorio),
    validarPragas(relatorio),
    validarCulturas(relatorio),
    validarDiagnosticos(relatorio)
  ]).then(resultados => {
    gerarRelatorioQualidade(relatorio);
  });
  
  return relatorio;
}
```

### **Funções de Sincronização**

#### **Sincronização com SecWeb**
```javascript
async function sincronizarSecWeb() {
  try {
    // Carregar dados atuais do SecWeb
    const dadosSecWeb = await fetch('/api/secweb/latest').then(r => r.json());
    
    // Carregar defensivos locais
    const defensivosLocais = await dbGetAll({ table: 'TBFITOSSANITARIOS' });
    
    const resultadoSinc = {
      encontrados: 0,
      novos: 0,
      atualizados: 0,
      removidos: 0
    };
    
    // Processar sincronização
    defensivosLocais.forEach(local => {
      const externo = dadosSecWeb.find(ext => 
        ext.mapa === local.mapa || 
        ext.nomeComum.toLowerCase() === local.nomeComum.toLowerCase()
      );
      
      if (externo) {
        local.secweb = true;
        resultadoSinc.encontrados++;
        
        // Verificar se precisa atualizar
        if (externo.dataAtualizacao > local.updatedAt) {
          atualizarDadosExterno(local, externo);
          resultadoSinc.atualizados++;
        }
      } else {
        local.secweb = false;
      }
    });
    
    salvarLogSincronizacao(resultadoSinc);
    return resultadoSinc;
    
  } catch (error) {
    console.error('Erro na sincronização SecWeb:', error);
    throw error;
  }
}
```

---

## 📊 Métricas e Monitoramento

### **KPIs Calculados**
```javascript
function calcularKPIs() {
  return {
    qualidadeDados: {
      defensivosCompletos: calcularDefensivosCompletos(),
      pragasComImagem: calcularPragasComImagem(),
      coberturaDiagnosticos: calcularCoberturaDiagnosticos()
    },
    performance: {
      tempoCarregamento: medirTempoCarregamento(),
      tamanhoBaseDados: calcularTamanhoBase(),
      ultimaAtualizacao: obterUltimaAtualizacao()
    },
    uso: {
      operacoesDia: contarOperacoesDia(),
      usuariosAtivos: contarUsuariosAtivos(),
      tabelasMaisUsadas: identificarTabelasPopulares()
    }
  };
}
```

---

**Esta documentação define todas as regras de negócio críticas que devem ser mantidas na migração para Flutter Web, garantindo que a lógica do sistema permaneça consistente e confiável.**