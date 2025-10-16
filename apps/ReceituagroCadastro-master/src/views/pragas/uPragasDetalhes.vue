<template lang="pug">

  v-container(align="center" justify="center" class="pa-0 pt-1")

    v-flex(width="900" class="mx-auto")

      v-card(elevation="0" style="background: transparent !important" border="0" class="mx-auto")
        v-list(style="background: transparent !important" class="pa-0 ma-0")
          v-list-item(class="pa-0" width="30px")
            v-list-item-content(class="pa-0")
              v-list-item-title {{praga.nomeComum}}
              v-list-item-subtitle {{praga.nomeCientifico}}
            v-btn(@click="marcarFavorito" text small icon)
              v-icon {{favIcon}}

        v-divider(class="mb-0 mt-1")

        v-card(align="center" justify="center" class="mx-auto mt-0" width="900" elevation="0" style="background: #f2f2f2" )

          v-tabs(centered="centered" grow style="border-radius: 7px 7px 0px 0px" background-color="#f2f2f2" color="primary" width="900" class="mx-auto mt-2")
            v-tab(href="#tab-1") Info.
            v-tab(href="#tab-2") Diagnóst.

            v-tabs-slider(color="54B34d")

            v-tab-item(key="tab-1" value="tab-1" width="900" class="mx-auto" style="background-color: #f2f2f2 !important")
              v-card(dark class="mt-2")
                v-img(:src='praga.imagem' width="560")
              v-card(class="pa-2 pt-6 mt-4 pb-6 mx-auto" width="900" align="center" justify="center" :style="pragasInfoNada")
                h5 Informações indisponíves no momento
              v-card(class="pa-2 pt-6 mt-4 mx-auto" width="900" :style="pragasInfoDisplay")
                h5 Informações Cientificas
                v-divider(class="mb-2 mt-2")
                v-list(dense class="pt-0")
                  v-list-item(class="pa-0 mb-2" v-for="(row, i) in praga.info" :key="i")
                    v-list-item-content(class="pb-0 pt-0")
                        v-list-item-title(class="pa-0") {{row.name}}
                        v-list-item-subtitle(class="pa-0 mb-0") {{row.value}}
                  v-divider

              v-card(align="left" justify="left" width="900" class="mx-auto mt-2")
                v-list(dense v-for="(item, i) in praga.caracteristicas.planta" :key="i" class="pl-0")
                  v-subheader(class="pl-2 pt-0 mt-0") {{item.name}}
                  v-list-item(v-for="(row, t) in item.rows" :key="t" class="pl-2")
                    v-list-item-content
                      v-list-item-title {{row.name}}
                      v-list-item-subtitle {{row.value}}
                  v-divider

              v-card(align="left" justify="left" width="900" class="mx-auto")
                v-list(dense v-for="(item, i) in praga.caracteristicas.inseto" :key="i" class="pl-0")
                  v-list-item(v-for="(row, t) in item.rows" :key="t" class="pl-2")
                    v-list-item-content
                      v-list-item-title {{row.name}}
                      v-list-item-subtitle(style="white-space: pre-line") {{row.value}}
                  v-divider

            v-tab-item(key="tab-2" value="tab-2" width="900" class="mx-auto" style="background-color: #f2f2f2 !important")

              v-card(class="pa-2 mt-2 mx-auto" width="900" align="center" justify="center" :style="diagnosticoSemInfo")
                h5 Nenhuma indicação de defensivo encontrada

              v-card(class="pa-2 mt-2 mx-auto" width="900" align="left" justify="left" :style="diagnosticoComInfo")
                v-select(:items="culturas" label="Culturas" @change="selectCultura" dense hide-details outlined)
                v-divider(class="mt-2")
                v-text-field(v-model="search" label="Buscar" @keyup="filter" class="pb-0 pt-0 ml-2 mr-2" prepend-inner-icon="search" single-line hide-details clearable clear-icon="close")
                v-card(class="mx-auto mt-2" :height="heightScroll" style="overflow: auto" elevation="0")
                  v-list(dense v-for="(item, i) in diagnosticoBusca" :key="i" class="pt-0")
                    v-subheader(style="border-bottom: 1px solid #f3f3f3") {{item.cultura}}
                    v-list-item(v-for="(row, t) in item.indicacoes" :key="t" @click="maisInfoDialog(row.IdReg)")
                      v-list-item-content
                        v-list-item-title {{row.nomeDefensivo}}
                        v-list-item-subtitle {{row.ingredienteAtivo}} + {{row.quantProduto}}
                        v-list-item-subtitle {{row.dosagem}}

    <!-- Dialog para exibição de informações dos defensivos -->
    v-dialog(v-model="dialog" max-width="340")
      v-card(style="width: 340px" light class="pa-0 pb-1")
        div(style="text-align: center; font-size: 19px") {{dialogInfos.nomeDefensivo}}
        div(style="text-align: center; font-size: 13px") {{dialogInfos.ingredienteAtivo}}
        v-divider
        v-list(dense)
          v-list-item
            v-list-item-content
              v-list-item-title Dosagem:
              v-list-item-subtitle {{dialogInfos.dosagem}}
          v-list-item
            v-list-item-content
              v-list-item-title Aplicação Terrestre:
              v-list-item-subtitle {{dialogInfos.terrestre}}
          v-list-item
            v-list-item-content
              v-list-item-title Aplicação Aerea:
              v-list-item-subtitle {{dialogInfos.aerea}}
          v-list-item
            v-list-item-content
              v-list-item-title Intervalo:
              v-list-item-subtitle {{dialogInfos.intervalo}}
        v-flex(style="text-align: center")
          v-btn(class="ma-1" style="width: 154px" outlined :to="dialogInfos.linkDefensivo") Defensivo
          v-btn(class="ma-1" style="width: 155px" outlined :to="dialogInfos.linkDiagnostico") Diagnóstico
        v-btn(icon @click="dialog = false" absolute top fab right dark small style="margin-top: 20px; right: 0px")
          v-icon close

</template>

<script>

import mPragas from './../../models/mPragas'

export default {
  data: () => ({
    heightScroll: window.innerHeight - 185,
    favIcon: 'mdi-heart-outline',
    search: '',
    titleArea: 'Shadow',
    overlay: false,
    dialog: false,
    color: '',
    praga: {
      caracteristicas: {
        planta: [],
        praga: []
      }
    },
    pragasInfoNada: 'display: none',
    pragasInfoDisplay: 'display: none',
    diagnosticoSemInfo: 'display: none',
    diagnosticoComInfo: 'display: block',
    diagnosticoBusca: [],
    diagnostico: [],
    culturas: ['Todas as Culturas'],
    dialogInfos: { img: '', nomeDefensivo: '', ingredienteAtivo: '', dosagem: '', aerea: '', terrestre: '', intervalo: '', linkDefensivo: '', linkDiagnostico: '' }
  }),
  watch: {
    '$route.params' () {
      this.buscaPraga()
    },
    selectCultura: function (cultura) {
      console.log(cultura)
    }
  },
  mounted () {
    this.buscaPraga()
    this.getFavorito()
  },
  methods: {
    filter: function (e) {
      if (this.search.length >= 3) {
        this.diagnosticoBusca = []
        this.diagnostico.filter(row => {
          const grupCultura = { cultura: row.cultura, indicacoes: [] }
          row.indicacoes.forEach((t, index) => {
            if (t.nomeDefensivo.toLowerCase().search(this.search) >= 0) grupCultura.indicacoes.push(t)
            if (index === row.indicacoes.length - 1 && grupCultura.indicacoes.length > 0) { this.diagnosticoBusca.push(grupCultura) }
          })
        })
      } else if (this.search === '' || this.search.length < 3) {
        this.diagnosticoBusca = this.diagnostico
      }
    },
    selectCultura: function (a) {
      this.search = ''
      if (a === 'Todas as Culturas') {
        this.praga = this.praga.diagnostico
      } else {
        this.praga.diagnostico.forEach(row => {
          if (row.cultura === a) { console.log(row); this.diagnostico = []; this.diagnostico.push(row); this.diagnosticoBusca = []; this.diagnosticoBusca.push(row) }
        })
      }
    },
    maisInfoDialog: function (e) {
      this.diagnostico.forEach(a => {
        a.indicacoes.forEach(row => {
          if (row.IdReg === e) {
            this.dialogInfos.nomeDefensivo = row.nomeDefensivo
            this.dialogInfos.ingredienteAtivo = row.ingredienteAtivo
            this.dialogInfos.dosagem = row.dosagem
            this.dialogInfos.aerea = row.vazaoAerea
            this.dialogInfos.terrestre = row.vazaoTerrestre
            this.dialogInfos.intervalo = row.intervaloAplicacao
            this.dialogInfos.linkDefensivo = '/defensivos/detalhes/' + row.fkIdDefensivo
            this.dialogInfos.linkDiagnostico = '/diagnostico/' + row.IdReg
          }
        })
      })
      this.dialog = true
    },
    buscaPraga: function (e) {
      mPragas.getDetalhesPraga(this.$route.params.id, success => {
        this.praga = success
        if (success.info.length > 0) this.pragasInfoDisplay = 'display: itherit'
        if (success.info.length === 0 && success.caracteristicas.planta.length === 0 && success.caracteristicas.inseto.length === 0) this.pragasInfoNada = 'display: block'
        if (success.diagnostico.length === 0) { this.diagnosticoSemInfo = 'display: block'; this.diagnosticoComInfo = 'display: none' }
        this.diagnostico = success.diagnostico
        this.diagnosticoBusca = success.diagnostico
        success.diagnostico.forEach(row => { this.culturas.push(row.cultura) })
      })
    },
    getFavorito: function () {
      mPragas.validPragasFavorito(this.$route.params.id, success => {
        console.log('getFavorito')
        if (success) this.favIcon = 'mdi-heart'
        if (!success) this.favIcon = 'mdi-heart-outline'
      }, error => {
        console.warn(error)
      })
    },
    marcarFavorito: function () {
      mPragas.setPragasFavorito(this.$route.params.id, success => {
        console.log('marcarFavorito')
        if (success) this.favIcon = 'mdi-heart'
        if (!success) this.favIcon = 'mdi-heart-outline'
      }, error => {
        console.warn(error)
      })
    }
  }
}
</script>
