// ==UserScript==
// @name           Agrolink WebScrap - Produtos
// @description    Script para busca de produtos
// @author         Lucinei Loch
// @include        https://www.agrolink.com.br/agrolinkfito/busca-direta-produto
// @version        1.1
// ==/UserScript==

let passo1 = Array.from(document.querySelectorAll('div.col-lg-4.col-xl-3.col-blocks'))
if (!localStorage['temp']) localStorage['temp'] = '[]'
let data = JSON.parse(localStorage['temp'])

for (x = 1; x < passo1.length; x++) {
  let a = passo1[x].innerText
  let b = a.split('\n')
  let c = passo1[x].getElementsByTagName('a')

  console.log(a, b, c)

  let prod = {
    createdAt: new Date().getTime(),
    updatedAt: new Date().getTime(),
    nomeComum: b[0].toLowerCase(),
    empresa: b[1].toLowerCase(),
    ingredienteAtivo: b[2].toLowerCase(),
    link: c[0].href
  }

  let result = data.filter(row => { if (row.nomeComum === prod.nomeComum) return true })

  if (result.length === 0) {
    data.push(prod)
  } else {
    data.forEach(row => {
      if (row.nomeComum === prod.nomeComum) {
        row.updatedAt = prod.updatedAt
        row.empresa = prod.empresa
        row.ingredienteAtivo = prod.ingredienteAtivo
      }
    })
  }
}

localStorage['temp'] = JSON.stringify(data)

// ==UserScript==
// @name           Agrolink WebScrap
// @description    Script para busca de informações no agrolink
// @author         Lucinei Loch
// @include        https://www.agrolink.com.br/agrolinkfito/produto/*
// @version        1.0
// ==/UserScript==

var labelInfoTecnica = new Array(), descInfoTecnica = new Array(), y = 0;
var newDefensivo = { cabecalho: [], diagnostico: [], aplicacao: [] }

var a = $('.border-cor-neutra-light .row .col-12 label');   // Informações Técnicas
var b = $('.border-cor-neutra-light .row .col-12 b');       // Informações Técnicas
var tableDiagnostico = $('table');                          // Tabelas e mais tabelas de diagnóstico
var labelAplicacao = $('.toggle-bg .toggleta a');           // Textos de Modalidade de Aplicação
var descAplicacao = $('.togglec .row .col-md-12 p');        // Textos de Modalidade de Aplicação
var nomeComum = $('h1')[0].innerText;                       // Nome do Defensivos
var row = { cultura: null, praga: '', dosagem: '', terrestre: '', aerea: '', intervalo: '' }
var nomeCientifico = '';

for (var x = 0; x < a.length; x++) { labelInfoTecnica.push(a[x].innerText) }
for (var x = 0; x < b.length; x++) { descInfoTecnica.push(b[x].innerText) }

newDefensivo.cabecalho.push({ field: 'nomeComum', value: nomeComum });
newDefensivo.cabecalho.push({ field: 'comercializado', value: 1 });

labelInfoTecnica.forEach((row, index) => {

  var field = '';

  switch (row) {

    case "Nome Técnico:": field = 'nomeTecnico'; break;
    case "Registro no Ministério:": field = 'mapa'; break;
    case "Empresa Registrante:": field = 'fabricante'; break;
    case "Classe Agronômica:": field = 'classeAgronomica'; break;
    case "Toxicológica:": field = 'toxico'; break;
    case "Ambiental:": field = 'classAmbiental'; break;
    case "Inflamabilidade:": field = 'inflamavel'; break;
    case "Corrosividade:": field = 'corrosivo'; break;
    case "Formulação:": field = 'formulacao'; break;
    case "Modo de Ação:": field = 'modoAcao'; break;
    default: break;

  }

  if (row == 'Ingrediente Ativo') {

    var ingredienteAtivo = '', quantProduto = '';
    var rodadas = (descInfoTecnica.length - labelInfoTecnica.length) + index;
    for (; y < rodadas + 1;) { ingredienteAtivo += descInfoTecnica[y] + ' + '; y++; quantProduto += descInfoTecnica[y] + ' + '; y++; }
    newDefensivo.cabecalho.push({ field: 'ingredienteAtivo', value: ingredienteAtivo.substr(0, ingredienteAtivo.length - 3) });
    newDefensivo.cabecalho.push({ field: 'quantProduto', value: quantProduto.substr(0, quantProduto.length - 3) });
    y--; y--;

  } else if (row == 'Concentração' || row == 'Grupo Químico') {

  } else {
    newDefensivo.cabecalho.push({ field: field, value: descInfoTecnica[y] })
  }
  y++

});

console.log(newDefensivo)

for (var x = 2; x < tableDiagnostico.length; x++) {

  nomeCientifico = ''
  var cabecalho = tableDiagnostico[x].getElementsByTagName('thead');
  var isIngrediente = cabecalho[0].getElementsByTagName('td');

  try { isIngrediente = isIngrediente[0].innerText; } catch (error) { isIngrediente = 'null' }

  if (isIngrediente != 'Ingrediente Ativo') {

    try {
      var cultura = cabecalho[0].getElementsByTagName('strong')[0].innerText
    } catch (error) { var cultura = cabecalho[0].getElementsByTagName('th')[0].innerText }

    var corpo = tableDiagnostico[x].getElementsByTagName('tbody');
    var linha = corpo[0].getElementsByTagName('tr');

    for (var a = 0; a < linha.length; a++) {

      let newRow = JSON.parse(JSON.stringify(row))
      let element = linha[a].getElementsByTagName('td');

      let praga = (element) => {
        var praga = element[0].getElementsByTagName('a');
        nomeCientifico = (praga[0].innerText).toString().split('(');
        if (element.length > 4) {
          return (nomeCientifico[1].trim()).substr(0, nomeCientifico.length - 1)
        } else {
          if (x == tableDiagnostico.length - 1) { x++ }
          return nomeCientifico[0].trim();
        }
      }

      let dosagem = (element) => {
        if (element.innerText == '' && element.getElementsByTagName('div')[0] !== undefined) {
          var e = element.getElementsByTagName('div')[0].style;
          return {
            img: element.getElementsByTagName('div')[0].getAttribute('data-bg'),
            x: e.getPropertyValue('background-position-x'),
            y: e.getPropertyValue('background-position-y'),
            w: e.getPropertyValue('width'),
            h: e.getPropertyValue('height')
          }
        } else { return element.innerText }
      }

      let terrestre = (element) => {
        if (element.innerText == '' && element.getElementsByTagName('div')[0] !== undefined) {
          var e = element.getElementsByTagName('div')[0].style;
          return {
            img: element.getElementsByTagName('div')[0].getAttribute('data-bg'),
            x: e.getPropertyValue('background-position-x'),
            y: e.getPropertyValue('background-position-y'),
            w: e.getPropertyValue('width'),
            h: e.getPropertyValue('height')
          }
        } else { return element.innerText }
      }

      let aerea = (element) => {
        if (element.innerText == '' && element.getElementsByTagName('div')[0] !== undefined) {
          var e = element.getElementsByTagName('div')[0].style;
          return {
            img: e.backgroundImage,
            x: e.backgroundPositionX,
            y: backgroundPositionY,
            w: e.getPropertyValue('width'),
            h: e.getPropertyValue('height')
          }
        } else { return element.innerText }
      }

      let invervalo = (element) => {
        if (element.innerText == '' && element.getElementsByTagName('div')[0] !== undefined) {
          var e = element.getElementsByTagName('div')[0].style;
          return {
            img: e.backgroundImage,
            x: e.backgroundPositionX,
            y: backgroundPositionY,
            w: e.getPropertyValue('width'),
            h: e.getPropertyValue('height')
          }
        } else { return element.innerText }
      }

      let trespontos = (element) => {
        console.log(element.getElementsByTagName('small')[0]);
        var e = element.getElementsByTagName('small')[0];
        var f = e.getElementsByTagName('a')[0];
        return f
      }

      for (var t = 0; t < element.length; t++) {

        switch ((cabecalho[0].getElementsByTagName('td'))[t].innerText) {
          case 'Calda Terrestre': null; break;
          case 'Dosagem': null; break;
          case 'Calda Aérea': null; break;
          case 'Intervalo de segurança': null; break;
          case '': var o = trespontos(element[t]);
            newRow.codregistro = o.getAttribute('data-codregistro');
            newRow.codproduto = o.getAttribute('data-codproduto');
            newRow.filtroespecie = o.getAttribute('data-filtroespecie');
            newRow.filtroproblema = o.getAttribute('data-filtroproblema'); break;
        }
      }

      newRow.praga = praga(element);
      newRow.cultura = cultura;
      newDefensivo.diagnostico.push(newRow)
    }
  }
}

if (labelAplicacao.length < descAplicacao.length) { labelAplicacao.push("Compatibilidade") }

for (var x = 0; x < descAplicacao.length; x++) {
  let field = '';
  let text = labelAplicacao[x].innerText;
  let text2 = '';

  if (text != undefined) text2 = text.toLowerCase();

  switch (text2) {
    case "embalagem": field = 'embalagens'; break;
    case "tecnologia de aplicação": field = 'tecnologia'; break;
    case "precauções quanto a saúde humana": field = 'pHumanas'; break;
    case "precauções quanto à saúde humana": field = 'pHumanas'; break;
    case "precauções quanto ao meio ambiente": field = 'pAmbiental'; break;
    case "manejo integrado": field = 'manejoIntegrado'; break;
    case "manejo de resistência": field = 'manejoResistencia'; break;
  }

  if (labelAplicacao[x] == "Compatibilidade") { field = 'compatibilidade' };

  if (field != '') {
    newDefensivo.aplicacao.push({ field: field, value: descAplicacao[x].innerText })
  }

}

window.setTimeout(function () {

  console.log(newDefensivo)

  const input = document.createElement('input')
  document.body.appendChild(input)
  input.value = ''
  input.focus()
  input.select()

  async function copyPageUrl() {
    try {
      await navigator.clipboard.writeText(JSON.stringify(newDefensivo))
      document.body.removeChild(input)
    } catch (err) {
      console.error('Falha ao Copiar: ', err)
      document.body.removeChild(input)
    }
  }

  copyPageUrl()

}, 100)

// ==UserScript==
// @name           SECWEb WebScrap
// @description    Script para busca de informações no SecWeb
// @author         Lucinei Loch
// @include        https://secweb.procergs.com.br/sdae/consultaPublica/SDA-ConsultaPublica-ProdutoAgrotox-Listar.js*
//                 https://secweb.procergs.com.br/sdae/consultaPublica/SDA-ConsultaPublica-ProdutoAgrotox-Listar.jsf
// @version        1.0
// ==/UserScript==

setTimeout(async () => {
  var panel = document.getElementById('pnlIdentificacaoUso');
  if (!panel) return;

  var table = panel.querySelector('table tbody');
  var rows = Array.from(table.querySelectorAll('tr'));
  const diagnostics = [];

  const cultureMapping = {
    'Azevém': 'Azevem',
    // 'Arroz Irrigado': 'Arroz',
    'Algodão': 'Algodão',
    'Maxixe': 'Mandioca',
    'Todas as culturas': 'Todas as culturas com ocorrência do alvo biológico',
    'Soja - Geneticamente Modificada': 'Soja',
    'Fumo (lavoura)': 'Fumo',
    'Tomate industrial': 'Tomate',
    'Pinhao manso': 'Pinhão Manso',
    'Tomate envarado': 'Tomate',
    'Tomate rasteiro': 'Tomate',
    'Arroz - Armazenado': 'Arroz',
    'Cevada - Armazenado': 'Cevada',
    'Milho - Armazenado': 'Milho',
    'Trigo - Armazenado': 'Trigo',
    'Milho S.P.D.': 'Milho',
    'Soja S.P.D.': 'Soja',
    'Café S.P.D.': 'Café',
    'Feijão S.P.D.': 'Feijão',
    'Cana-de-açúcar (Propágulos vegetativos)': 'Cana-de-açúcar',
    'Cana planta': 'Cana-de-açúcar',
    'Cana soca': 'Cana-de-açúcar',
    'Soja Dessecação': 'Soja',
    'Batata Dessecação': 'Batata'
    // Add more culture mappings as needed
  };

  const pragasMapping = {
    'Lyriomyza huidobrensis': 'Liriomyza huidobrensis',
    'Lyriomyza trifolii': 'Liriomyza trifolii',
    'Lyriomyza sativae': 'Liriomyza sativae',
    'Meloidogyne incógnita': 'Meloidogyne incognita',
    'Peronaspora manshurica': 'Peronospora manshurica',
    'Pseudocercospora cubensis': 'Pseudoperonospora cubensis',
    'Empoasca spp.': 'Empoasca spp',
    'Pythium spp.': 'Pythium spp',
    'Alternaria spp.': 'Alternaria spp',
    'Aspergillus spp.': 'Aspergillus spp',
    'Penicillium spp.': 'Penicillium spp',
    'Tetranychus spp.': 'Tetranychus spp',
    'Bemisia tabaci raça B': 'Bemisia tabaci raca b',
    'Bemisia tabaci Biótipo B': 'Bemisia tabaci raca b',
    'Oidium sp.': 'Oidium spp',
    'Colletotrichum spp.': 'Colletotrichum spp',
    'Peronospora sp.': 'Peronospora spp',
    'Xanthomonas axonopodis subsp. citri': 'Xanthomonas axonopodis pv. citri',
    'Helicoverpa spp': 'Helicoverpa sp',
    'Helicoverpa zeae': 'Helicoverpa zea',
    'Desfolhante': 'Dessecação'
  };

  const unitMappings = {
    // 'l/': 'Lt / ',
    'de calda': 'de Calda',
    // 'ha': 'Ha',
    // 'g/': 'Gr / ',
    ' l ': ' Lt ',
    'ág': 'Ág',
    'l de Calda/ha': 'Lt de Calda / Ha',
    'ml/ha': 'ml de Calda / Ha',
    'l/ha': 'Lt de Calda / Ha',
    'Gr / ha': ' Gr / Ha',
    'l/planta': 'Lt de Calda / Planta'
  };

  function extraiUMText(maxValue, CompleteString) {
    const lastIndex = CompleteString.lastIndexOf(maxValue);
    const textAfterLastNumber = CompleteString.slice(lastIndex + maxValue.length).trim();
    return textAfterLastNumber;
  }

  rows.forEach(row => {
    const [cultura, praga, nomeComum, dosagem, terrestre, aerea, intervalo, intervalo2] = Array.from(row.querySelectorAll('td')).map(cell => cell.innerText);

    const tempRow = {
      cultura: cultureMapping[cultura] || cultura,
      praga: pragasMapping[praga] || praga,
      nomeComum: nomeComum,
    };

    // Dosage parsing and unit conversion
    const dosageParts = dosagem.replace(/,/g, '.');//.split(' ');
    if (dosageParts.length > 2) {
      const dosageValues = dosageParts.replace(/,/g, '.').match(/[\d.]+/g);
      const [min, max] = dosageValues;
      tempRow.dsMin = min === max ? '' : min;// (unit === 'ml/' || unit === 'g/') ? `${min.replace('.', '') / 1000}`.replace('.', ',') : min;
      tempRow.dsMax = max// max ? (max / 1000).toString().replace('.', ',') : '';
      tempRow.um = extraiUMText(max, dosageParts);
      tempRow.um = Object.keys(unitMappings).reduce((text, key) => text.replace(new RegExp(key, 'g'), unitMappings[key]), tempRow.um);
    }

    // Terrestrial application parsing
    if (terrestre) {
      // const [minAplicacaoT, unitT, maxAplicacaoT] = terrestre.split(' ');
      const AplicacaoValues = terrestre.replace(/,/g, '.').match(/[\d.]+/g);
      const [minAplicacaoT, maxAplicacaoT] = AplicacaoValues;
      tempRow.minAplicacaoT = minAplicacaoT === maxAplicacaoT ? '' : minAplicacaoT;
      tempRow.maxAplicacaoT = maxAplicacaoT || '';
      tempRow.umT = extraiUMText(maxAplicacaoT, terrestre.replace(/,/g, '.'));
      tempRow.umT = Object.keys(unitMappings).reduce((text, key) => text.replace(new RegExp(key, 'g'), unitMappings[key]), tempRow.umT);
    }

    // Aerial application parsing
    if (aerea) {
      // const [minAplicacaoA, unitA, maxAplicacaoA] = aerea.split(' ');
      const AplicacaoValues = aerea.replace(/,/g, '.').match(/[\d.]+/g);
      const [minAplicacaoA, maxAplicacaoA] = AplicacaoValues;
      tempRow.minAplicacaoA = minAplicacaoA === maxAplicacaoA ? '' : minAplicacaoA;
      tempRow.maxAplicacaoA = maxAplicacaoA || '';
      tempRow.umA = extraiUMText(maxAplicacaoA, aerea.replace(/,/g, '.'));
      tempRow.umA = Object.keys(unitMappings).reduce((text, key) => text.replace(new RegExp(key, 'g'), unitMappings[key]), tempRow.umA);
    }

    tempRow.intervalo = isNaN(intervalo) ? intervalo : `${intervalo} Dias`;
    tempRow.intervalo2 = isNaN(intervalo2) ? intervalo2 : `${intervalo2} Dias`;

    diagnostics.push(tempRow);
  });

  const final = { diagnostico: diagnostics };

  console.log(final);

  const input = document.createElement('input');
  document.body.appendChild(input);
  input.value = JSON.stringify(final);
  input.focus();
  input.select();

  try {
    await navigator.clipboard.writeText(JSON.stringify(final));
    document.body.removeChild(input);
    console.log('Texto Copiado');
  } catch (err) {
    console.error('Falha ao Copiar: ', err);
    document.body.removeChild(input);
  }
}, 1000);




// ==UserScript==
// @name           Agrolink WebScrap
// @description    Script para busca de informações no agrolink
// @author         Lucinei Loch
// @include        https://www.agrolink.com.br/agrolinkfito/produto/*
// @version        1.1
// ==/UserScript==

const labelInfoTecnica = [], descInfoTecnica = [], newDefensivo = { cabecalho: [], diagnostico: [], aplicacao: [] };
const rowTemplate = { cultura: null, praga: '', dosagem: '', terrestre: '', aerea: '', intervalo: '' };
let y = 0;

// Utilizando querySelector e querySelectorAll ao invés de $, e let/const ao invés de var
const nomeComum = document.querySelector('h1').innerText.trim();
const tableDiagnostico = Array.from(document.querySelectorAll('table')).slice(2);
const labelAplicacao = document.querySelectorAll('.toggle-bg .toggleta a');
const descAplicacao = document.querySelectorAll('.togglec .row .col-md-12 p');
const info1 = Array.from(document.querySelectorAll('table')).slice(0, 1);
const info2 = Array.from(document.querySelectorAll('table')).slice(1, 2);
const info3 = Array.from(document.querySelectorAll('table')).slice(2, 3);
const accordionInfos = document.querySelector('#accordion-infos');

newDefensivo.cabecalho.push({ field: 'nomeComum', value: nomeComum.substring(5) });
newDefensivo.cabecalho.push({ field: 'comercializado', value: 1 });

// Processamento de info1
const fieldMap = {
  "Nome Técnico:": 'nomeTecnico',
  "Registro MAPA:": 'mapa',
  "Empresa Registrante:": 'fabricante',
};

info1.forEach(table => {
  const rows = Array.from(table.querySelectorAll('tr'));
  rows.forEach(row => {
    const cells = Array.from(row.querySelectorAll('td div.col-md-4'));
    cells.forEach(cell => {
      let label = '';
      let value = '';

      for (const [key, field] of Object.entries(fieldMap)) {
        if (cell.innerText.includes(key)) {
          label = key;
          value = cell.querySelector('strong').innerText;
          newDefensivo.cabecalho.push({ field, value });
          break;
        }
      }
    });
  });
});

info2.forEach(table => {
  const ingrediente = [];
  const quant = [];

  const rows = Array.from(table.querySelectorAll('tbody tr'));
  rows.forEach((row, index) => {
    if (index === 0) return;
    const cells = Array.from(row.querySelectorAll('td'));
    if (cells.length === 2) {
      const ingredienteAtivo = cells[0].innerText;
      const concentracao = cells[1].innerText;
      ingrediente.push(ingredienteAtivo);
      quant.push(concentracao);
    }
  });

  newDefensivo.cabecalho.push({ field: 'ingredienteAtivo', value: ingrediente.join(' + ') });
  newDefensivo.cabecalho.push({ field: 'quantProduto', value: quant.join(' + ') });
});

const fieldsMap3 = {
  "Classe Agronômica:": 'classeAgronomica',
  "Toxicológica:": 'toxico',
  "Ambiental:": 'classAmbiental',
  "Inflamabilidade:": 'inflamavel',
  "Corrosividade:": 'corrosivo',
  "Formulação:": 'formulacao',
  "Modo de Ação:": 'modoAcao'
};

// Exemplo de uso
info3.forEach(table => {
  const rows = Array.from(table.querySelectorAll('tr'));
  rows.forEach(row => {
    const cells = Array.from(row.querySelectorAll('td div.col-md-4'));
    cells.forEach(cell => {
      let label = '';
      let value = '';

      for (const [key, field] of Object.entries(fieldsMap3)) {
        if (cell.innerText.includes(key)) {
          label = key;
          value = cell.querySelector('strong').innerText;
          newDefensivo.cabecalho.push({ field, value });
          break;
        }
      }
    });
  });
});

// Processamento da tabela de diagnóstico
tableDiagnostico.forEach((table, index) => {
  if (index == 0) return;

  const cabecalho = table.querySelector('thead');
  const cultura = cabecalho.querySelector('strong')?.innerText || cabecalho.querySelector('th')?.innerText || '';
  const linhas = table.querySelector('tbody')?.querySelectorAll('tr') || [];

  linhas.forEach(linha => {
    const row = { ...rowTemplate, cultura };
    const elementos = linha.querySelectorAll('td');
    const pragaElement = elementos[0]?.querySelector('a');
    if (pragaElement) {
      const nome = pragaElement.innerText.split('(');
      row.praga = nome[0].trim();
      row.nomeCientifico = nome[1]?.replace(')', '').trim() || '';
    }
    newDefensivo.diagnostico.push(row);
  });

});

if (accordionInfos) {
  const items = accordionInfos.querySelectorAll('.accordion-item');
  items.forEach(item => {
    const button = item.querySelector('.accordion-button');
    const body = item.querySelector('.accordion-body p');

    if (button && body) {
      const label = button.innerText.trim();
      const value = body.innerHTML.trim().replace(/<br>/g, '\n'); // Substitui <br> por nova linha para melhor legibilidade

      console.log(label);

      const fieldMap = {
        "EMBALAGEM": 'embalagens',
        "TECNOLOGIA DE APLICAÇÃO": 'tecnologia',
        "PRECAUÇÕES QUANTO A SAÚDE HUMANA": 'pHumanas',
        "PRECAUÇÕES QUANTO AO MEIO AMBIENTE": 'pAmbiental',
        "MANEJO INTEGRADO": 'manejoIntegrado',
        "MANEJO DE RESISTÊNCIA": 'manejoResistencia',
        "COMPATIBILIDADE": 'compatibilidade'
      };

      const field = fieldMap[label] || '';
      if (field) {
        newDefensivo.aplicacao.push({ field, value });
      }
    }
  });
}


// Copia o resultado para o clipboard
window.setTimeout(() => {
  const input = document.createElement('input');
  document.body.appendChild(input);
  input.value = JSON.stringify(newDefensivo);
  input.select();

  navigator.clipboard.writeText(input.value)
    .then(() => document.body.removeChild(input))
    .catch(err => {
      console.error('Falha ao copiar:', err);
      document.body.removeChild(input);
    });
}, 100);



// ==UserScript==
// @name           SECWeb WebScrap Improved
// @description    Improved script for extracting information from SecWeb
// @author         Lucinei Loch
// @include        https://secweb.procergs.com.br/sdae/consultaPublica/SDA-ConsultaPublica-ProdutoAgrotox-Listar.js*
//                 https://secweb.procergs.com.br/sdae/consultaPublica/SDA-ConsultaPublica-ProdutoAgrotox-Listar.jsf
// @version        1.1
// ==/UserScript==

(async () => {
  // Espera até que o painel necessário esteja disponível
  function waitForElement(selector, timeout = 5000) {
    return new Promise((resolve, reject) => {
      const interval = setInterval(() => {
        const element = document.querySelector(selector);
        if (element) {
          clearInterval(interval);
          resolve(element);
        }
      }, 100);
      setTimeout(() => {
        clearInterval(interval);
        reject(`Timeout: Elemento ${selector} não encontrado.`);
      }, timeout);
    });
  }

  try {
    const panel = await waitForElement('#pnlIdentificacaoUso');
    const table = panel.querySelector('table tbody');
    if (!table) throw new Error('Tabela não encontrada');

    const rows = Array.from(table.querySelectorAll('tr'));
    const diagnostics = [];

    const cultureMapping = {
      'Azevém': 'Azevem',
      'Algodão': 'Algodão',
      'Maxixe': 'Mandioca',
      'Todas as culturas': 'Todas as culturas com ocorrência do alvo biológico',
      'Soja - Geneticamente Modificada': 'Soja',
      'Fumo (lavoura)': 'Fumo',
      'Tomate industrial': 'Tomate',
      'Pinhao manso': 'Pinhão Manso',
      'Tomate envarado': 'Tomate',
      'Arroz - Armazenado': 'Arroz',
      // Adicione mais mapeamentos se necessário
    };

    const pragasMapping = {
      'Lyriomyza huidobrensis': 'Liriomyza huidobrensis',
      'Lyriomyza trifolii': 'Liriomyza trifolii',
      'Meloidogyne incógnita': 'Meloidogyne incognita',
      // Adicione mais mapeamentos se necessário
    };

    const unitMappings = {
      ' l ': ' Lt ',
      'ág': 'Ág',
      'l de Calda/ha': 'Lt de Calda / Ha',
      'ml/ha': 'ml de Calda / Ha',
      'l/ha': 'Lt de Calda / Ha',
      'Gr / ha': ' Gr / Ha',
      'l/planta': 'Lt de Calda / Planta'
    };

    // Função para extrair o texto da unidade de medida
    function extraiUMText(maxValue, CompleteString) {
      const lastIndex = CompleteString.lastIndexOf(maxValue);
      return CompleteString.slice(lastIndex + maxValue.length).trim();
    }

    // Função para processar cada linha da tabela
    function processRow(row) {
      const cells = Array.from(row.querySelectorAll('td'));
      if (cells.length < 7) return null; // Verifica se há células suficientes

      const [cultura, praga, nomeComum, dosagem, terrestre, aerea, intervalo, intervalo2] = cells.map(cell => cell.innerText.trim());

      const tempRow = {
        cultura: cultureMapping[cultura] || cultura,
        praga: pragasMapping[praga] || praga,
        nomeComum: nomeComum,
      };

      // Processamento de dosagem
      const dosageValues = dosagem.replace(/,/g, '.').match(/[\d.]+/g);
      if (dosageValues) {
        const [min, max] = dosageValues;
        tempRow.dsMin = min !== max ? min : '';
        tempRow.dsMax = max;
        tempRow.um = extraiUMText(max, dosagem);
        tempRow.um = Object.keys(unitMappings).reduce((text, key) => text.replace(new RegExp(key, 'g'), unitMappings[key]), tempRow.um);
      }

      // Processamento de aplicação terrestre
      if (terrestre) {
        const terrestrialValues = terrestre.replace(/,/g, '.').match(/[\d.]+/g);
        if (terrestrialValues) {
          const [minAplicacaoT, maxAplicacaoT] = terrestrialValues;
          tempRow.minAplicacaoT = minAplicacaoT !== maxAplicacaoT ? minAplicacaoT : '';
          tempRow.maxAplicacaoT = maxAplicacaoT || '';
          tempRow.umT = extraiUMText(maxAplicacaoT, terrestre);
          tempRow.umT = Object.keys(unitMappings).reduce((text, key) => text.replace(new RegExp(key, 'g'), unitMappings[key]), tempRow.umT);
        }
      }

      // Processamento de aplicação aérea
      if (aerea) {
        const aerialValues = aerea.replace(/,/g, '.').match(/[\d.]+/g);
        if (aerialValues) {
          const [minAplicacaoA, maxAplicacaoA] = aerialValues;
          tempRow.minAplicacaoA = minAplicacaoA !== maxAplicacaoA ? minAplicacaoA : '';
          tempRow.maxAplicacaoA = maxAplicacaoA || '';
          tempRow.umA = extraiUMText(maxAplicacaoA, aerea);
          tempRow.umA = Object.keys(unitMappings).reduce((text, key) => text.replace(new RegExp(key, 'g'), unitMappings[key]), tempRow.umA);
        }
      }

      // Processamento dos intervalos
      tempRow.intervalo = isNaN(intervalo) ? intervalo : `${intervalo} Dias`;
      tempRow.intervalo2 = isNaN(intervalo2) ? intervalo2 : `${intervalo2} Dias`;

      return tempRow;
    }

    rows.forEach(row => {
      const result = processRow(row);
      if (result) diagnostics.push(result);
    });

    const final = { diagnostico: diagnostics };

    // Exibe e copia o resultado final
    const input = document.createElement('input');
    document.body.appendChild(input);
    input.value = JSON.stringify(final, null, 2);
    input.focus();
    input.select();

    try {
      await navigator.clipboard.writeText(input.value);
      console.log('Texto copiado com sucesso!');
    } catch (err) {
      console.error('Falha ao copiar:', err);
    } finally {
      document.body.removeChild(input);
    }

  } catch (error) {
    console.error('Erro:', error);
  }
})();


// ==UserScript==
// @name           secWeb WebScrap - Produtos
// @description    Script para busca de produtos secWeb
// @author         Lucinei Loch
// @include        https://secweb.procergs.com.br/sdae/consultaPublica/SDA-ConsultaPublica-ProdutoAgrotox-Consultar.jsf
// @version        1.1
// ==/UserScript==

let secwebtable = Array.from(document.querySelectorAll('table tr'));
let secwebtableTrimmed = secwebtable.slice(1, -1);

if (!localStorage.getItem('tempsecwebdata')) {
  localStorage.setItem('tempsecwebdata', '[]');
}

let secwebdata = JSON.parse(localStorage.getItem('tempsecwebdata'));
try {
  secwebdata = JSON.parse(secwebdata);
} finally {
  // ada
}

for (let x = 1; x < secwebtableTrimmed.length; x++) {
  let a = secwebtableTrimmed[x].innerText;
  let b = a.split('\t');

  let prod = {
    createdAt: new Date().getTime(),
    updatedAt: new Date().getTime(),
    nomeComum: b[0].toLowerCase(),
    empresa: b[1].toLowerCase(),
    cnpj: b[2],
    fepam: b[3],
    mapa: b[4]
  };

  let result = secwebdata.find(row => row.nomeComum === prod.nomeComum);

  if (!result) {
    secwebdata.push(prod);
  } else {
    result.updatedAt = prod.updatedAt;
    result.empresa = prod.empresa;
    result.cnpj = prod.cnpj;
    result.fepam = prod.fepam;
    result.mapa = prod.mapa;
  }
}

localStorage.setItem('tempsecwebdata', JSON.stringify(secwebdata));