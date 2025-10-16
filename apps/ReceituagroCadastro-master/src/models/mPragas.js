/* eslint-disable no-async-promise-executor */
/* eslint-disable no-useless-escape */

import { dbGet, dbGetAll, dbSaveRegistry, dbGetIndex, dbOrderList, dbDecode, dbEncode } from './../core/models/mIndexeddb'
// dbDeleteRegistry, dbOrderList, dbGenerateIdReg, dbEncode, dbDecode

export const mPragasBuscarTodos = async () => {
  const retorno = []
  let pragas = await dbGetAll({ table: 'TBPRAGAS' }).then(lista => lista)
  const plantasInf = await dbGetAll({ table: 'TBPRAGASINF' }).then(lista => lista)
  const pragasInf = await dbGetAll({ table: 'TBPLANTASINF' }).then(lista => lista)

  pragas = dbOrderList({ ArrayList: pragas, Field: 'nomeComum', Field2: undefined, Distinct: false })

  for (const row of pragas) {
    const nome = row.nomeComum.split(';')
    const nomeSeg = nome
    let imagem = ''

    const t1 = plantasInf.filter(r => r.fkIdPraga === row.IdReg)
    const t2 = pragasInf.filter(r => r.fkIdPraga === row.IdReg)

    try { imagem = require('../assets/bigsize/' + row.nomeCientifico + '.jpg') } catch (e) { imagem = '' }

    const newRow = {
      IdReg: row.IdReg,
      nomeComum: nome[0],
      nomeSecundarios: nomeSeg.splice(1),
      nomeCientifico: row.nomeCientifico,
      img: imagem,
      tipoPraga: tipoPraga(row.tipoPraga),
      info: t1.length > 0 || t2.length > 0 ? 1 : '',
      link: '/pragas/cadastro?id=' + row.IdReg
    }

    retorno.push(newRow)
  }

  return new Promise(async (resolve) => {
    resolve(retorno)
  })
}

export const mPragasBuscaTodosSimples = () => {
  return new Promise(resolve => {
    dbGetAll({ table: 'TBPRAGAS' })
      .then(lista => { resolve(lista) })
  })
}

export const mPragasBuscarUnico = (params) => {
  return new Promise((resolve, reject) => {
    dbGet({ table: 'TBPRAGAS', id: params.IdReg }).then(row => {
      if (row !== undefined || row !== null) resolve(row)
      if (row === undefined || row === null) reject(new Error('Algo ocorreu de errado na busca'))
    })
  })
}

export const mPragasBuscarDetalhes = async (IdReg) => {
  const tbpragas = await dbGet({ table: 'TBPRAGAS', id: IdReg }).then(data => data)
  const tbplantasinf = await dbGetIndex({ table: 'TBPLANTASINF', index: 'fkIdPraga', id: IdReg }).then(data => data)
  const tbpragasinf = await dbGetIndex({ table: 'TBPRAGASINF', index: 'fkIdPraga', id: IdReg }).then(data => data)

  if (tbplantasinf.length > 0) {
    tbplantasinf.forEach(row => {
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
  }

  if (tbpragasinf.length > 0) {
    tbpragasinf.forEach(row => {
      row.descrisao = dbDecode(row.descrisao).toString().replace(/<br\s*[\/]?>/gi, '\r\n')
      row.sintomas = dbDecode(row.sintomas).toString().replace(/<br\s*[\/]?>/gi, '\r\n')
      row.bioecologia = dbDecode(row.bioecologia).toString().replace(/<br\s*[\/]?>/gi, '\r\n')
      row.controle = dbDecode(row.controle).toString().replace(/<br\s*[\/]?>/gi, '\r\n')
    })
  }

  const container = {
    tbpragas: tbpragas,
    tbplantasinf: tbplantasinf,
    tbpragasinf: tbpragasinf
  }

  return new Promise(resolve => {
    resolve(container)
  })
}

export const mPragasGravarRegistroPragas = (data) => {
  const container = { table: 'TBPRAGAS', values: data }

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

export const mPragasGravarRegistroPragasInf = (data) => {
  data = JSON.parse(JSON.stringify(data))
  data.descrisao = dbEncode(data.descrisao).toString().replace(/<br\s*[\/]?>/gi, '\r\n')
  data.sintomas = dbEncode(data.sintomas).toString().replace(/<br\s*[\/]?>/gi, '\r\n')
  data.bioecologia = dbEncode(data.bioecologia).toString().replace(/<br\s*[\/]?>/gi, '\r\n')
  data.controle = dbEncode(data.controle).toString().replace(/<br\s*[\/]?>/gi, '\r\n')

  const container = { table: 'TBPRAGASINF', values: data }

  return new Promise(resolve => {
    dbSaveRegistry(container).then(data => resolve(data))
  })
}

export const mPragasGravarRegistroPlantasInf = (data) => {
  data = JSON.parse(JSON.stringify(data))
  data.ciclo = dbEncode(data.ciclo)
  data.reproducao = dbEncode(data.reproducao)
  data.habitat = dbEncode(data.habitat)
  data.adaptacoes = dbEncode(data.adaptacoes)
  data.filotaxia = dbEncode(data.filotaxia)
  data.formaLimbo = dbEncode(data.formaLimbo)
  data.superficie = dbEncode(data.superficie)
  data.consistencia = dbEncode(data.consistencia)
  data.nervacao = dbEncode(data.nervacao)
  data.inflorescencia = dbEncode(data.inflorescencia)
  data.perianto = dbEncode(data.perianto)
  data.tipologiaFruto = dbEncode(data.tipologiaFruto)
  data.observacoes = dbEncode(data.observacoes)

  const container = { table: 'TBPLANTASINF', values: data }
  return new Promise(resolve => {
    dbSaveRegistry(container).then(data => resolve(data))
  })
}

const tipoPraga = (id) => {
  switch (id) {
    case '1' : return 'Insetos'
    case '2' : return 'Doenças'
    case '3' : return 'Plantas'
  }
}

export default { mPragasBuscarTodos, mPragasBuscaTodosSimples, mPragasBuscarUnico, mPragasBuscarDetalhes, mPragasGravarRegistroPragas, mPragasGravarRegistroPlantasInf, mPragasGravarRegistroPragasInf }
