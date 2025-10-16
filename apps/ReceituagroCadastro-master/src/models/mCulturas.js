import { dbGet, dbGetAll, dbSaveRegistry } from './../core/models/mIndexeddb'

export const mCulturasBuscarTodos = () => {
  return new Promise(resolve => {
    dbGetAll({ table: 'TBCULTURAS' })
      .then(lista => {
        resolve(lista)
      })
  })
}

export const mCulturasBuscarUnico = (IdReg) => {
  return new Promise((resolve, reject) => {
    dbGet({ table: 'TBCULTURAS', id: IdReg })
      .then(data => {
        resolve(data)
      })
      .catch(err => {
        reject(err)
      })
  })
}

export const mCulturasGravarRegistro = (params) => {
  var container = { table: 'TBCULTURAS', values: params }

  return new Promise(resolve => {
    dbSaveRegistry(container).then(data => resolve(data))
  })
}
export default { mCulturasBuscarTodos, mCulturasBuscarUnico, mCulturasGravarRegistro }
