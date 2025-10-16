/* eslint-disable no-async-promise-executor */
/* eslint-disable no-useless-escape */
// import config from './../config/app'
import {
  dbGet,
  dbSaveRegistry,
  dbDeleteRegistry,
  dbGetField,
  dbGetAll,
  dbEncode,
  dbDecode,
  dbOrderList,
  dbGetIndex
} from '../core/models/mIndexeddb'
// dbDeleteRegistry, dbOrderList, dbGenerateIdReg, dbEncode, dbDecode, dbGenerateIdReg

export const getAllDefensivos = () => {
  return new Promise(async resolve => {
    const defensivos = await dbGetAll({ table: 'TBFITOSSANITARIOS' }).then(data => data)
    const defensivosInfo = await dbGetAll({ table: 'TBFITOSSANITARIOSINFO' }).then(data => data)
    const diagnosticos = await dbGetAll({ table: 'TBDIAGNOSTICO' })
      .then(data => {
        data.results = {
          total: {},
          preenchidos: {}
        }

        for (let x = 0; x < data.length; x++) {
          const field = data[x].fkIdDefensivo
          data.results.total[field] === undefined ? data.results.total[field] = 1 : data.results.total[field] += 1
          if (data.results.preenchidos[field] === undefined) { data.results.preenchidos[field] = 0 }
          if (data[x].dsMin !== null && data[x].dsMax !== null) {
            if (data[x].dsMin.toString().length > 0 || data[x].dsMax.toString().length > 0) { data.results.preenchidos[field] += 1 }
          }
        }
        return data.results
      })

    defensivos.forEach(row => {
      row.quantDiag = diagnosticos.total[row.IdReg] !== undefined ? diagnosticos.total[row.IdReg] : 0
      row.quantDiagP = diagnosticos.preenchidos[row.IdReg] !== undefined ? diagnosticos.preenchidos[row.IdReg] : 0
      row.temInfo = (defensivosInfo.filter(rowInfo => { if (row.IdReg === rowInfo.IdReg || row.IdReg === rowInfo.fkIdDefensivo) return true })).length
      row.link = '/defensivoscadastro?id=' + row.IdReg
    })

    const novaListaDefensivos = []
    for (const row of defensivos) {
      // if (row.quantDiagnosticoPreenchidos === row.quantDiagnosticos &&
      //       row.quantDiagnosticoPreenchidos > 0) { novaListaDefensivos.push(row) }
      try {
        row.toxico = dbDecode(row.toxico)
      } catch (e) {
        row.toxico = ''
      }
      novaListaDefensivos.push(row)
    }

    resolve(novaListaDefensivos)
  })
}

export const getAllDefensivosSimples = () => {
  return new Promise(resolve => {
    dbGetAll({ table: 'TBFITOSSANITARIOS' })
      .then(data => {
        const newData = []
        const prefs = ['I -', 'II -', 'III -', 'IV -', 'V -']
        data.forEach(row => {
          row.linklocal = '#/defensivoscadastro?id=' + row.IdReg
          try {
            row.toxico = dbDecode(row.toxico)
          } catch (e) {
            row.toxico = ''
          }
        })

        data.forEach(row => {
          if (row.toxico !== undefined) {
            prefs.forEach(pref => {
              if (row.toxico.indexOf(pref) !== -1) {
                newData.push(row)
              }
            })
          }
        })
        resolve(newData)
      })
  })
}

export const getDefensivosDetalhes = (params) => {
  return new Promise(resolve => {
    const container = {
      IdReg: '',
      principal: {
        ingredientes: []
      },
      diagnostico: [],
      aplicacao: {
        embalagens: '',
        tecnologia: '',
        pHumanas: '',
        pAmbiental: '',
        manejoResistencia: '',
        compatibilidade: '',
        manejoIntegrado: ''
      }
    }

    const defensivo = (container, IdReg) => {
      return new Promise(resolve => {
        dbGet({ table: 'TBFITOSSANITARIOS', id: IdReg })
          .then(row => {
            container.principal.IdReg = row.IdReg
            container.principal.nomeComum = row.nomeComum
            container.principal.fabricante = row.fabricante
            container.principal.nomeTecnico = row.nomeTecnico
            container.principal.toxico = dbDecode(row.toxico)
            container.principal.classAmbiental = dbDecode(row.classAmbiental)
            container.principal.classeAgronomica = dbDecode(row.classeAgronomica)
            container.principal.formulacao = dbDecode(row.formulacao)
            container.principal.inflamavel = row.inflamavel
            container.principal.corrosivo = row.corrosivo
            container.principal.modoAcao = dbDecode(row.modoAcao)
            container.principal.mapa = row.mapa
            container.principal.comercializado = row.comercializado
            container.principal.ingredienteAtivo = row.ingredienteAtivo
            container.principal.quantProduto = row.quantProduto

            resolve(container)
          })
      })
    }

    const diagnostico = (data) => {
      return new Promise(resolve => {
        // console.log('aqui', data.IdReg)
        dbGetIndex({ table: 'TBDIAGNOSTICO', index: 'fkIdDefensivo', id: data.principal.IdReg })
          .then(lista => {
            lista.forEach((row, index) => {
              // Adiciona informações da cultura
              dbGetField({ table: 'TBCULTURAS', field: 'cultura', id: row.fkIdCultura })
                .then(value => {
                  row.cultura = value
                })

              // Adiciona informações da praga
              dbGet({ table: 'TBPRAGAS', id: row.fkIdPraga })
                .then(value => {
                  row.nomePraga = value.nomeComum
                  row.nomeCientifico = value.nomeCientifico
                })

              row.edit = false
              row.pos = index
            })

            // Ordena a lista de registros por cultura e nome cientifico da praga
            lista = dbOrderList({ ArrayList: lista, Field: 'cultura', Field2: 'nomeCientifico', Distinct: false })

            data.diagnostico = lista
            resolve(data)
          })
      })
    }

    const aplicacao = (data) => {
      return new Promise(resolve => {
        dbGetIndex({ table: 'TBFITOSSANITARIOSINFO', index: 'fkIdDefensivo', id: data.principal.IdReg })
          .then(row => {
            if (row.length === 0) { resolve(data); return }
            data.aplicacao.embalagens = dbDecode(row[0].embalagens).toString().replace(/<br\s*[\/]?>/gi, '\r\n')
            data.aplicacao.tecnologia = dbDecode(row[0].tecnologia).toString().replace(/<br\s*[\/]?>/gi, '\r\n')
            data.aplicacao.compatibilidade = dbDecode(row[0].compatibilidade).toString().replace(/<br\s*[\/]?>/gi, '\r\n')
            data.aplicacao.manejoResistencia = dbDecode(row[0].manejoResistencia).toString().replace(/<br\s*[\/]?>/gi, '\r\n')
            data.aplicacao.manejoIntegrado = dbDecode(row[0].manejoIntegrado).toString().replace(/<br\s*[\/]?>/gi, '\r\n')
            data.aplicacao.pHumanas = dbDecode(row[0].pHumanas).toString().replace(/<br\s*[\/]?>/gi, '\r\n')
            data.aplicacao.pAmbiental = dbDecode(row[0].pAmbiental).toString().replace(/<br\s*[\/]?>/gi, '\r\n')
            resolve(data)
          })
      })
    }

    defensivo(container, params.IdReg)
      .then(data => diagnostico(data))
      .then(data2 => aplicacao(data2))
      .then(data3 => {
        resolve(data3)
      })
  })
}

export const deleteDefensivo = (params) => {
  return new Promise(resolve => {
    const excluirDefensivo = () => {
      const param = JSON.parse(JSON.stringify(params))
      param.table = 'TBFITOSSANITARIOS'
      dbDeleteRegistry(param)
        .then(data => { console.log('Defensivos Apagado', data) })
        .catch(err => console.log('Erro apagar defensivo: ', err))
    }

    const excluirDefensivoInfo = () => {
      const param = JSON.parse(JSON.stringify(params))
      param.table = 'TBFITOSSANITARIOSINFO'
      dbDeleteRegistry(param)
        .then(data => console.log('DefensivoInfo Apagado', data))
        .catch(err => console.log('Erro apagar DefensivoInfo: ', err))
    }

    const excluirDiagnosticos = () => {
      const param = JSON.parse(JSON.stringify(params))
      param.table = 'TBDIAGNOSTICO'
      dbGetIndex({ table: param.table, index: 'fkIdDefensivo', id: param.IdReg }).then(lista => {
        let time = 1
        lista.forEach(row => {
          time += 30
          window.setTimeout(() => {
            const newParams = row
            newParams.table = 'TBDIAGNOSTICO'
            dbDeleteRegistry(newParams)
              .then(data => console.log('Diagnóstico Apagado', data))
              .catch(err => console.log('Erro apagar Diagnóstico: ', err))
          }, time)
        })
      })
    }

    excluirDefensivo()
    excluirDefensivoInfo()
    excluirDiagnosticos()
    resolve(true)
  })
}

export const excluirDiagnosticoUnico = (item) => {
  console.log(item)
  return new Promise(resolve => {
    dbDeleteRegistry({ table: 'TBDIAGNOSTICO', values: item })
      .then(() => resolve(true))
      .catch(() => resolve(false))
  })
}

export const gravarDefensivo = (params) => {
  var container = { table: 'TBFITOSSANITARIOS', values: {} }

  container.values.IdReg = params.IdReg
  container.values.nomeComum = params.nomeComum
  container.values.nomeTecnico = params.nomeTecnico
  container.values.classeAgronomica = dbEncode(params.classeAgronomica)
  container.values.fabricante = params.fabricante
  container.values.classAmbiental = dbEncode(params.classAmbiental)
  container.values.comercializado = params.comercializado
  container.values.corrosivo = params.corrosivo
  container.values.inflamavel = params.inflamavel
  container.values.formulacao = dbEncode(params.formulacao)
  container.values.modoAcao = dbEncode(params.modoAcao)
  container.values.mapa = params.mapa
  container.values.toxico = dbEncode(params.toxico)
  container.values.ingredienteAtivo = params.ingredienteAtivo
  container.values.quantProduto = params.quantProduto

  console.log(container)
  return new Promise(resolve => {
    dbSaveRegistry(container).then(data => resolve(data))
  })
  // return new Promise((resolve, reject) => {
  //   dbUpdateRegistry(container)
  //     .then(dataUR => { resolve(dataUR) })
  //     .catch(msg => {
  //       if (!msg.Error) {
  //         dbNewRegistry(container)
  //           .then(dataNR => { console.log(dataNR); resolve(dataNR) })
  //           .catch(e => { reject(e) })
  //       }
  //     })
  // })
}

export const gravarDiagnostico = (params) => {
  var container = { table: 'TBDIAGNOSTICO', public: true, values: {} }

  container.values.IdReg = params.IdReg
  container.values.fkIdDefensivo = params.fkIdDefensivo
  container.values.fkIdCultura = params.fkIdCultura
  container.values.fkIdPraga = params.fkIdPraga
  container.values.dsMin = params.dsMin
  container.values.dsMax = params.dsMax
  container.values.um = params.um
  container.values.minAplicacaoT = params.minAplicacaoT
  container.values.maxAplicacaoT = params.maxAplicacaoT
  container.values.umT = params.umT
  container.values.minAplicacaoA = params.minAplicacaoA
  container.values.maxAplicacaoA = params.maxAplicacaoA
  container.values.umA = params.umA
  container.values.intervalo = params.intervalo
  container.values.intervalo2 = ''
  container.values.epocaAplicacao = params.epocaAplicacao

  return new Promise(resolve => {
    dbSaveRegistry(container).then(data => resolve(data))
  })

  // return new Promise((resolve, reject) => {
  //   dbUpdateRegistry(container)
  //     .then(dataUR => { resolve(dataUR) })
  //     .catch(msg => {
  //       if (!msg.Error) {
  //         dbNewRegistry(container)
  //           .then(dataNR => { resolve(dataNR) })
  //           .catch(e => { reject(e) })
  //       }
  //     })
  // })
}

export const detetarDiagnostico = (params) => {
  var container = { table: 'TBDIAGNOSTICO', public: true, values: {} }

  container.values.IdReg = params.IdReg
  container.values.Status = false

  return new Promise(resolve => {
    dbSaveRegistry(container).then(data => resolve(data))
  })

  // return new Promise((resolve, reject) => {
  //   dbUpdateRegistry(container)
  //     .then(dataUR => { resolve(dataUR) })
  //     .catch(msg => {
  //       if (!msg.Error) {
  //         dbNewRegistry(container)
  //           .then(dataNR => { resolve(dataNR) })
  //           .catch(e => { reject(e) })
  //       }
  //     })
  // })
}

export const gravarAplicacao = (values) => {
  const container = { table: 'TBFITOSSANITARIOSINFO', public: true, values: {} }

  container.values.fkIdDefensivo = values.fkIdDefensivo
  container.values.embalagens = values.embalagens !== undefined && values.embalagens !== '' ? dbEncode(values.embalagens) : ''
  container.values.tecnologia = values.tecnologia !== undefined && values.tecnologia !== '' ? dbEncode(values.tecnologia) : ''
  container.values.pHumanas = values.pHumanas !== undefined && values.pHumanas !== '' ? dbEncode(values.pHumanas) : ''
  container.values.pAmbiental = values.pAmbiental !== undefined && values.pAmbiental !== '' ? dbEncode(values.pAmbiental) : ''
  container.values.manejoResistencia = values.manejoResistencia !== undefined && values.manejoResistencia !== '' ? dbEncode(values.manejoResistencia) : ''
  container.values.compatibilidade = values.compatibilidade !== undefined && values.compatibilidade !== '' ? dbEncode(values.compatibilidade) : ''
  container.values.manejoIntegrado = values.manejoIntegrado !== undefined && values.manejoIntegrado !== '' ? dbEncode(values.manejoIntegrado) : ''

  return new Promise(resolve => {
    dbSaveRegistry(container).then(data => resolve(data))
  })

  // return new Promise((resolve, reject) => {
  //   dbUpdateRegistry(container)
  //     .then(dataUR => { resolve(dataUR) })
  //     .catch(msg => {
  //       if (!msg.Error) {
  //         dbNewRegistry(container)
  //           .then(dataNR => { resolve(dataNR) })
  //           .catch(e => { reject(e) })
  //       }
  //     })
  // })
}

export const getPosicoesExternas = () => {
  return new Promise(resolve => {
    const defensivos = dbGetAll({ table: 'TBEXTRACAO' }).then(data => data)
    resolve(defensivos)
  })
}

export default {
  getAllDefensivos,
  getAllDefensivosSimples,
  getDefensivosDetalhes,
  deleteDefensivo,
  excluirDiagnosticoUnico,
  gravarDefensivo,
  gravarDiagnostico,
  gravarAplicacao
}
