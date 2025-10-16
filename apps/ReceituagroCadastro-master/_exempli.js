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
    'Arroz Irrigado': 'Arroz',
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
    'Oidium sp.' : 'Oidium spp'
  };

  const unitMappings = {
    'de calda': 'de Calda',
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
