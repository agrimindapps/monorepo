<template lang="pug">

  v-flex(align="center" justify="center" class="pt-1")

    v-card(class="mt-1 pa-0" elevation="3")

      v-data-table(:headers="headers" dense :items="listaRegistros" :search="search" :sort-by="['cultura']" :items-per-page="100" class="elevation-1 pa-2" to="#")

        template(slot="top")
          v-toolbar(flat)
            v-spacer
            v-btn(color="success" dark class="mb-2" @click="editItem = 'new' ")
              v-icon(left) fas fa-plus
              | Novo

        template(v-slot:item.actions="{ item }")
          v-icon(small class="mr-2" color="primary" @click="editItem = item.IdReg") fas fa-pen

    uCadCulturasForm(:idKey="editItem" @cadCulturasForm="closeCadCulturaForm")

    toolbar(@update-search="getSearch" @menuExec="menuExec" :title="toolbarSettings.title"
        :subTitle="toolbarSettings.subTitle" :useSearch="toolbarSettings.useSearch"
        :buttons="toolbarSettings.buttons")

</template>

<script>

// Import Components
import compToolBar from './../../core/components/toolbar'
import uCadCulturasForm from './../../views/culturas/uCulturasCad.vue'

import { mCulturasBuscarTodos } from './../../models/mCulturas'

export default {
  components: {
    toolbar: compToolBar,
    uCadCulturasForm
  },
  data: () => ({
    search: '',
    toolbarSettings: {
      title: 'Culturas',
      subTitle: '0 Registros',
      useSearch: true,
      buttons: []
    },
    editItem: null,
    dialog: false,
    uCadCulturasFormActive: false,
    benched: 30,
    heightScroll: window.innerHeight - 115,
    listaRegistros: [],
    listaBusca: [],
    headers: [
      { text: 'Cultura', value: 'cultura' },
      { text: 'Cientifico', value: 'cientifico' },
      { text: 'Ações', align: 'end', value: 'actions' }
    ]
  }),
  created () {
    this.buscarRegistros()
  },
  watch: {
    'editItem' () {
      if (this.editItem !== null) this.createCadCulturasForm()
    }
  },
  methods: {
    getSearch (e) { if (e === null) e = ''; this.search = e },
    menuExec (e) { if (e === 'marcarFavorito') this.marcarFavorito() },
    createCadCulturasForm () {
      this.uCadCulturasFormActive = !this.uCadCulturasFormActive
    },
    closeCadCulturaForm () {
      this.uCadCulturasFormActive = !this.uCadCulturasFormActive
      this.buscarRegistros()
      this.editItem = null
    },
    buscarRegistros () {
      mCulturasBuscarTodos().then(data => {
        this.listaRegistros = data
        this.toolbarSettings.subTitle = data.length + ' Registros'
      }).catch(error => {
        console.log(error)
      })
    }
  }
}
</script>
