import ibxPremium from '../core/models/mPremium'

import { dbNewRegistry, dbDeleteRegistry, dbGet, dbGetAll } from './../core/models/mIndexeddb'
// dbNewRegistry, dbUpdateRegistry, dbDeleteRegistry, dbGetField, dbGetIndex, dbOrderList, dbGenerateIdReg, dbEncode, dbDecode
const ibxFavoritos = {
  getDefensivosFavoritos: function (success, error) {
    const newList = []
    dbGetAll({ table: 'TBFAVORITOS' }, lista => {
      lista.forEach((row, index) => {
        if (lista.length === 0) {
          success([])
        } else {
          dbGet({ table: 'TBFITOSSANITARIOS', id: row.IdReg }, row => {
            if (row !== undefined) {
              row.link = '/defensivos/detalhes/' + row.IdReg
              newList.push(row)
            }
            if (index === lista.length - 1) {
              success(newList)
            }
          })
        }
      })
    })
  },
  getDiagnosticoFavoritos: function (success, error) {
    ibxPremium.verificaAssinatura(null, suc => {
      if (suc) {
        if (!suc) success(false)
        const newList = []
        let imagem = ''
        dbGetAll({ table: 'TBFAVORITOS' }, lista => {
          if (lista.length === 0) { success([]); return false }
          for (let index = 0; index < lista.length; index++) {
            dbGet({ table: 'TBDIAGNOSTICO', id: lista[index].IdReg }, guia => {
              if (guia === undefined && index === lista.length - 1) { setTimeout(() => { success(newList) }, 150) }
              if (guia === undefined) return false

              dbGet({ table: 'TBFITOSSANITARIOS', id: guia.fkIdDefensivo }, r1 => {
                dbGet({ table: 'TBPRAGAS', id: guia.fkIdPraga }, r2 => {
                  dbGet({ table: 'TBCULTURAS', id: guia.fkIdCultura }, r3 => {
                    imagem = ''
                    try { imagem = require('../assets/bigsize/' + r2.nomeCientifico + '.jpg') } catch (e) { imagem = require('../assets/bigsize/a.jpg') }

                    const k = {}
                    k.IdReg = guia.IdReg
                    k.fkIdDefensivo = guia.fkIdDefensivo
                    k.fkIdPraga = guia.fkIdPraga
                    k.fkIdCultura = guia.fkIdCultura
                    k.nomeComum = r1.nomeComum

                    const priNome = r2.nomeComum.split(';')
                    k.priNome = priNome[0]
                    k.nomePraga = r2.nomeComum
                    k.nomeCientifico = r2.nomeCientifico

                    k.cultura = r3.cultura
                    k.imagem = imagem.default
                    k.link = '/diagnostico/' + guia.IdReg
                    newList.push(k)
                  })
                })
              })
            })
          }
        })
      }
    }, err => {
      error(err)
    })
  },
  getPragasFavoritos: function (success, error) {
    const newList = []
    let imagem = ''
    dbGetAll({ table: 'TBFAVORITOS' }, lista => {
      lista.forEach((row, index) => {
        if (lista.length === 0) {
          success([])
        } else {
          dbGet({ table: 'TBPRAGAS', id: row.IdReg }, row => {
            if (row === undefined) return false
            const nome = row.nomeComum.split(';')
            const nomeSeg = nome

            imagem = ''
            try { imagem = require('../assets/bigsize/' + row.nomeCientifico + '.jpg') } catch (e) { imagem = require('../assets/bigsize/a.jpg') }
            if (navigator.userAgent.match(/Android/i) && typeof (cordova) !== 'undefined') { imagem.default = '/android_asset/www/' + imagem.default }

            row.nomeComum = nome[0]
            row.nomeSeg = nomeSeg.splice(1)
            row.imagem = imagem.default
            row.link = '/pragas/detalhes/' + row.IdReg

            if (row !== undefined) newList.push(row)

            if (index === lista.length - 1) {
              success(newList)
            }
          })
        }
      })
    })
  },
  gravaFavorito: function (key, success, error) {
    console.log(key)
    dbGet({ table: 'TBFAVORITOS', id: key }, row => {
      if (row === undefined) {
        const container = { table: 'TBFAVORITOS', values: {} }
        container.values.IdReg = key
        dbNewRegistry(container, resp => {
          success(resp)
        })
      } else {
        const container = { table: 'TBFAVORITOS', values: {} }
        container.values.IdReg = key
        dbDeleteRegistry(container, resp => {
          success(resp)
        })
      }
    })
  },
  verificaFavorito: function (key, success, error) {
    dbGet({ table: 'TBFAVORITOS', id: key }, row => {
      if (row === undefined) { success(false) } else { success(true) }
    })
  }
}

export default ibxFavoritos
