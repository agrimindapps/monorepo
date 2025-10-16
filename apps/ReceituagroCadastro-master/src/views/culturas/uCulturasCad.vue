<template lang="pug">

v-dialog(v-model="dialog" persistent max-width="400" style="margin: 0px !important")
  v-card(elevation="0")
    v-card-title(class="pl-1 mb-2") Cadastro de Culturas
    v-card-text
      v-row
        v-text-field(v-model="row.cultura" color="success" label="Descrição")
    v-card-actions
      v-spacer
      v-btn(text color="grey" @click="cancelar")
        v-icon(left) far fa-times-circle
        | Cancelar
      v-btn(text color="success" @click="gravarRegitro")
        v-icon(left) far fa-save
        | Salvar

</template>

<script>
import { mCulturasBuscarUnico, mCulturasGravarRegistro } from '../../models/mCulturas'

export default {
  props: {
    idKey: { type: String, default: '' }
  },
  data: () => ({
    row: {
      IdReg: null,
      cultura: null
    },
    dialog: false
  }),
  watch: {
    'idKey' () {
      if (this.idKey !== null) {
        this.dialog = true
        if (this.idKey.length > 10) { this.buscarRegistro() }
      } else {
        this.dialog = false
      }
    }
  },
  methods: {
    cancelar () {
      this.finalizar()
    },

    finalizar () {
      this.dialog = false
      this.row = {
        IdReg: null,
        cultura: null
      }
      this.$emit('cadCulturasForm', this.finalizaForm)
    },

    async buscarRegistro () {
      this.row = await mCulturasBuscarUnico(this.idKey).then(data => data)
    },

    gravarRegitro () {
      if (this.row.cultura.length < 3) { console.warn('Descrição vazia ou muito curta'); return false }
      mCulturasGravarRegistro(this.row)
        .then(() => { this.finalizar() })
        .catch(() => { console.log('Faz Nada') })
    }
  }
}
</script>
