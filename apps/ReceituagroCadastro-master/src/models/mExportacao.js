/* eslint-disable no-useless-escape */
import { dbGetAll, dbDecode } from '../core/models/mIndexeddb'

export const exportaDados = async () => {
  // Variaveis
  const tabelasExportacao = []
  const containerDadosExportar = []

  // Esquema para realizar a exportação com 1 mb cada arquivo
  tabelasExportacao.push({ table: 'TBPRAGAS', paginacao: 1500 })
  tabelasExportacao.push({ table: 'TBFITOSSANITARIOS', paginacao: 1500 })
  tabelasExportacao.push({ table: 'TBPLANTASINF', paginacao: 400 })
  tabelasExportacao.push({ table: 'TBPRAGASINF', paginacao: 400 })
  tabelasExportacao.push({ table: 'TBDIAGNOSTICO', paginacao: 2000 })
  tabelasExportacao.push({ table: 'TBFITOSSANITARIOSINFO', paginacao: 31 })
  tabelasExportacao.push({ table: 'TBCULTURAS', paginacao: 2000 })

  for (const row of tabelasExportacao) {
    containerDadosExportar[row.table] = { data: [] }
  }

  // Alimetando array de tabelas que não precisam de filtragem
  containerDadosExportar.TBCULTURAS.data = await dbGetAll({ table: 'TBCULTURAS' }).then(data => data)
  containerDadosExportar.TBPRAGAS.data = await dbGetAll({ table: 'TBPRAGAS' }).then(data => data)
  containerDadosExportar.TBPLANTASINF.data = await dbGetAll({ table: 'TBPLANTASINF' }).then(data => {
    data.forEach(row => {
      row.ciclo = dbDecode(row.ciclo)
      row.reproducao = dbDecode(row.reproducao)
      row.habitat = dbDecode(row.habitat)
      row.adaptacoes = dbDecode(row.adaptacoes)
      row.filotaxia = dbDecode(row.filotaxia)
      row.formaLimbo = dbDecode(row.formaLimbo)
      row.superficie = dbDecode(row.superficie)
      row.consistencia = dbDecode(row.consistencia)
      row.nervacao = dbDecode(row.nervacao)
      row.inflorescencia = dbDecode(row.inflorescencia)
      row.perianto = dbDecode(row.perianto)
      row.tipologiaFruto = dbDecode(row.tipologiaFruto)
      row.observacoes = dbDecode(row.observacoes)
    })
    return data
  })
  containerDadosExportar.TBPRAGASINF.data = await dbGetAll({ table: 'TBPRAGASINF' }).then(data => {
    data.forEach(row => {
      row.descrisao = dbDecode(row.descrisao).toString().replace(/<br\s*[\/]?>/gi, '\r\n')
      row.sintomas = dbDecode(row.sintomas).toString().replace(/<br\s*[\/]?>/gi, '\r\n')
      row.bioecologia = dbDecode(row.bioecologia).toString().replace(/<br\s*[\/]?>/gi, '\r\n')
      row.controle = dbDecode(row.controle).toString().replace(/<br\s*[\/]?>/gi, '\r\n')
    })
    return data
  })

  // Array Temporarios para filtrar posteriormente registros validos
  const tempTBDIAGNOSTICO = await dbGetAll({ table: 'TBDIAGNOSTICO' }).then(data => data)
  const tempTBFITOSSANITARIOSINFO = await dbGetAll({ table: 'TBFITOSSANITARIOSINFO' }).then(data => {
    data.forEach(row => {
      row.embalagens = dbDecode(row.embalagens).toString().replace(/<br\s*[\/]?>/gi, '\r\n')
      row.tecnologia = dbDecode(row.tecnologia).toString().replace(/<br\s*[\/]?>/gi, '\r\n')
      row.compatibilidade = dbDecode(row.compatibilidade).toString().replace(/<br\s*[\/]?>/gi, '\r\n')
      row.manejoResistencia = dbDecode(row.manejoResistencia).toString().replace(/<br\s*[\/]?>/gi, '\r\n')
      row.manejoIntegrado = dbDecode(row.manejoIntegrado).toString().replace(/<br\s*[\/]?>/gi, '\r\n')
      row.pHumanas = dbDecode(row.pHumanas).toString().replace(/<br\s*[\/]?>/gi, '\r\n')
      row.pAmbiental = dbDecode(row.pAmbiental).toString().replace(/<br\s*[\/]?>/gi, '\r\n')
    })
    return data
  })
  const tempTBFITOSSANITARIOS = await dbGetAll({ table: 'TBFITOSSANITARIOS' }).then(data => {
    data.forEach(row => {
      row.toxico = dbDecode(row.toxico)
      row.classAmbiental = dbDecode(row.classAmbiental)
      row.classeAgronomica = dbDecode(row.classeAgronomica)
      row.formulacao = dbDecode(row.formulacao)
      row.modoAcao = dbDecode(row.modoAcao)
    })
    return data
  })

  // Matriz de chaves de registros validos
  const IdsDefensivosProntos = await dbGetAll({ table: 'TBDIAGNOSTICO' })
    .then(data => {
      const ids = []
      for (const row of data) {
        try {
          if (row.dsMin.length > 0 || row.dsMax.length > 0) { ids.push(row.fkIdDefensivo) }
        } catch (error) {
          console.error(error)
        }
      }
      return [...new Set(ids)]
    })

  for (const id of IdsDefensivosProntos) {
    const data = tempTBFITOSSANITARIOS.filter(row => row.IdReg === id)
    containerDadosExportar.TBFITOSSANITARIOS.data = containerDadosExportar.TBFITOSSANITARIOS.data.concat(data)
  }

  for (const id of IdsDefensivosProntos) {
    const data = tempTBFITOSSANITARIOSINFO.filter(row => { return row.fkIdDefensivo === id })
    containerDadosExportar.TBFITOSSANITARIOSINFO.data = containerDadosExportar.TBFITOSSANITARIOSINFO.data.concat(data)
  }

  for (const id of IdsDefensivosProntos) {
    const data = tempTBDIAGNOSTICO.filter(row => { return row.fkIdDefensivo === id })
    containerDadosExportar.TBDIAGNOSTICO.data = containerDadosExportar.TBDIAGNOSTICO.data.concat(data)
  }

  setTimeout(() => {
    console.log(containerDadosExportar)
  }, 1000)

  return new Promise(resolve => {
    let count = 0
    const containerMaster = []
    const containerModel = { table: '', page: -1, rows: [] }

    const processaItens = (item) => {
      let contador = 0
      let container = JSON.parse(JSON.stringify(containerModel))
      const dataProcessa = containerDadosExportar[item.table].data
      dataProcessa.forEach((row, i2) => {
        if (i2 === dataProcessa.length - 1) {
          container.rows.push(row)
          container.table = item.table
          container.page = contador; contador++
          containerMaster.push(container)
          container = JSON.parse(JSON.stringify(containerModel))
          count++
          if (count === tabelasExportacao.length && i2 === dataProcessa.length - 1) processarDownload()
          return
        }

        if (container.rows.length < item.paginacao) {
          container.rows.push(row)
          return
        }

        if (container.rows.length === item.paginacao) {
          container.rows.push(row)
          container.table = item.table
          container.page = contador; contador++
          containerMaster.push(container)
          container = JSON.parse(JSON.stringify(containerModel))
          return false
        }
      })
    }

    const processarDownload = () => {
      let time = 0
      containerMaster.forEach((item, i1) => {
        time += 600
        setTimeout(() => {
          // criar um array de IdRegs
          let IdRegs = []
          item.rows.forEach(row => {
            IdRegs.push(row.IdReg)
          })
          var element = document.createElement('a')
          element.setAttribute('href', 'data:text/plain;charset=utf-8,' + encodeURIComponent(JSON.stringify(IdRegs)))
          element.setAttribute('download', item.table + item.page + '.json')

          element.style.display = 'none'
          document.body.appendChild(element)
          element.click()
          document.body.removeChild(element)

          console.warn('contador: ' + i1 + ' / ' + containerMaster.length)

          if (i1 === containerMaster.length - 1) { resolve(true); console.warn('Processo de exportação finalizado') }
        }, time)
      })
    }

    tabelasExportacao.forEach(item => {
      processaItens(item)
    })
  })
}

export const backupDados = () => {
  // Variaveis
  const tabelasBackup = []

  tabelasBackup.push({ table: 'TBPRAGAS', paginacao: 1500 })
  tabelasBackup.push({ table: 'TBFITOSSANITARIOS', paginacao: 1500 })
  tabelasBackup.push({ table: 'TBPLANTASINF', paginacao: 400 })
  tabelasBackup.push({ table: 'TBPRAGASINF', paginacao: 400 })
  tabelasBackup.push({ table: 'TBDIAGNOSTICO', paginacao: 2000 })
  tabelasBackup.push({ table: 'TBFITOSSANITARIOSINFO', paginacao: 28 })
  tabelasBackup.push({ table: 'TBCULTURAS', paginacao: 2000 })

  return new Promise(resolve => {
    let count = 0
    const containerMaster = []
    const containerModel = { table: '', page: -1, rows: [] }

    const processaItens = (item) => {
      let contador = 0
      let container = JSON.parse(JSON.stringify(containerModel))
      dbGetAll({ table: item.table }).then(success => {
        success.forEach((row, i2) => {
          if (i2 === success.length - 1) {
            container.rows.push(row)
            container.table = item.table
            container.page = contador; contador++
            containerMaster.push(container)
            container = JSON.parse(JSON.stringify(containerModel))
            count++
            if (count === tabelasBackup.length && i2 === success.length - 1) { processarDownload() }
            return
          }

          if (container.rows.length < item.paginacao) {
            container.rows.push(row)
            return
          }

          if (container.rows.length === item.paginacao) {
            container.rows.push(row)
            container.table = item.table
            container.page = contador; contador++
            containerMaster.push(container)
            container = JSON.parse(JSON.stringify(containerModel))
            return false
          }
        })
      })
    }

    const processarDownload = () => {
      let time = 0
      containerMaster.forEach((item, i1) => {
        time += 600
        setTimeout(() => {
          var element = document.createElement('a')
          element.setAttribute('href', 'data:text/plain;charset=utf-8,' + encodeURIComponent(JSON.stringify(item)))
          element.setAttribute('download', item.table + item.page + '.json')

          element.style.display = 'none'
          document.body.appendChild(element)
          element.click()
          document.body.removeChild(element)

          console.warn('contador: ' + i1 + ' / ' + containerMaster.length)

          if (i1 === containerMaster.length - 1) { resolve(true); console.warn('Processo de exportação finalizado') }
        }, time)
      })
    }

    tabelasBackup.forEach(item => {
      processaItens(item)
    })
  })
}

export const backupDadosCSV = async () => {
  // Variáveis
  const tabelasBackup = [];

  let culturas = await dbGetAll({ table: 'TBCULTURAS' }).then(data => data)
  let pragas = await dbGetAll({ table: 'TBPRAGAS' }).then(data => data)
  let fitossanitarios = await dbGetAll({ table: 'TBFITOSSANITARIOS' }).then(data => data)

  tabelasBackup.push({ table: 'TBPRAGAS', paginacao: 1500 });
  tabelasBackup.push({ table: 'TBFITOSSANITARIOS', paginacao: 1500 });
  tabelasBackup.push({ table: 'TBPLANTASINF', paginacao: 400 });
  tabelasBackup.push({ table: 'TBPRAGASINF', paginacao: 400 });
  tabelasBackup.push({ table: 'TBDIAGNOSTICO', paginacao: 5500 });
  tabelasBackup.push({ table: 'TBFITOSSANITARIOSINFO', paginacao: 28 });
  tabelasBackup.push({ table: 'TBCULTURAS', paginacao: 2000 });

  return new Promise(resolve => {
    let count = 0;
    const containerMaster = [];
    const containerModel = { table: '', page: -1, rows: [] };

    const processaItens = (item) => {
      let contador = 0;
      let container = JSON.parse(JSON.stringify(containerModel));
      dbGetAll({ table: item.table }).then(success => {
        success.forEach((row, i2) => {

          // const defensivoValido = fitossanitarios.some(f => f.IdReg === row.fkIdDefensivo);
          // const culturaValida = culturas.some(c => c.IdReg === row.fkIdCultura);
          // const pragaValida = pragas.some(p => p.IdReg === row.fkIdPraga);


          // if (!defensivoValido || !culturaValida || !pragaValida) {
          //   return;
          // }

          if (i2 === success.length - 1) {
            container.rows.push(row);
            container.table = item.table;
            container.page = contador; contador++;
            containerMaster.push(container);
            container = JSON.parse(JSON.stringify(containerModel));
            count++;
            if (count === tabelasBackup.length && i2 === success.length - 1) { processarDownload(); }
            return;
          }

          if (container.rows.length < item.paginacao) {
            container.rows.push(row);
            return;
          }

          if (container.rows.length === item.paginacao) {
            container.rows.push(row);
            container.table = item.table;
            container.page = contador; contador++;
            containerMaster.push(container);
            container = JSON.parse(JSON.stringify(containerModel));
            return false;
          }
        });
      });
    };

    const convertToCSV = (rows) => {
      if (!rows.length) return '';

      // Define os campos a serem excluídos
      const excludedKeys = ['objectId', 'createdAt', 'updatedAt'];

      // Garante que o campo 'status' esteja sempre presente, ordenando as chaves alfabeticamente
      const headers = [...new Set([...Object.keys(rows[0]), 'Status'])]
        .filter(key => !excludedKeys.includes(key)) // Exclui os campos indesejados
        .sort() // Ordena as chaves em ordem alfabética
        .map(key => key.toLowerCase()) // Converte os nomes das colunas para minúsculas
        .join(';'); // Junta os nomes das colunas, separados por ponto e vírgula

      const data = rows.map(row => {
        // Garante que o campo "status" seja incluído, mesmo se não existir
        if (!('status' in row) && !('Status' in row)) {
          row.status = 0; // Define status como 0 (false) se não existir
        }

        // Ordena os pares chave-valor para garantir que sigam a mesma ordem das colunas
        const orderedRow = Object.keys(row)
          .filter(key => !excludedKeys.includes(key)) // Exclui os campos indesejados
          .sort() // Ordena as chaves em ordem alfabética
          .map(key => {
            let value = row[key];

            // Converte status: 1 para true, 0 para false
            if (key.toLowerCase() === 'status') {
              value = value === 1 ? 'true' : 'false';
            }

            // Substitui null, undefined ou campos vazios por um valor padrão
            const normalizedValue = value === null || value === undefined || value === '' ? 'N/A' : value;

            // Verifica se o valor tem ponto e vírgula ou nova linha, e envolve em aspas duplas se necessário
            const strValue = String(normalizedValue).replace(/"/g, '""'); // Escapa aspas duplas
            return `"${strValue}"`;
          }).join(';'); // Junta os valores, separados por ponto e vírgula

        return orderedRow;
      }).join('\n');

      return `${headers}\n${data}`;
    };


    const processarDownload = () => {
      let time = 0;
      containerMaster.forEach((item, i1) => {
        time += 600;
        setTimeout(() => {
          const csvContent = convertToCSV(item.rows);

          // Criar um arquivo CSV
          var element = document.createElement('a');
          element.setAttribute('href', 'data:text/csv;charset=utf-8,' + encodeURIComponent(csvContent));
          element.setAttribute('download', `${item.table}${item.page}.csv`);

          element.style.display = 'none';
          document.body.appendChild(element);
          element.click();
          document.body.removeChild(element);

          console.warn('contador: ' + i1 + ' / ' + containerMaster.length);

          if (i1 === containerMaster.length - 1) { resolve(true); console.warn('Processo de exportação finalizado'); }
        }, time);
      });
    };

    tabelasBackup.forEach(item => {
      processaItens(item);
    });
  });
};


export default { exportaDados, backupDados, backupDadosCSV }
