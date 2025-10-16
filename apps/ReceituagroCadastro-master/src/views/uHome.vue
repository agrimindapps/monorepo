<template lang="pug">

  v-container(align="center" justify="center" class="pa-0 ma-0 pl-1 pr-1")

    v-card(max-width="1500" elevation="0" class="mx-auto" style="background: transparent")
      h2(class="mt-2 font-weight-medium") Bem Vindo!!
      h4(class="pt-0 pb-4 font-weight-medium") Aqui estão as ultimas novidades
      v-card(color="#ccc" elevation="5")
        v-carousel(hide-delimiters height="360")
          v-carousel-item(v-for="(item,i) in sugestoesPragas" :key="i" :to="item.link")
            v-sheet(height="100%" class="pa-0" color="#000" align-center align='center' justify='center')
              v-row(align="center" justify="center")
                div(width="100%" class="pa-0")
                  v-img(:src="item.imagem" width='420px' align='center' class="ma-0 pa-0")
                div(style="margin: 0px; background: #000000; color: #fff; position: absolute; top:315px; padding: 10px; width: 100%; font-size: 18px") {{item.nomeComum}}

    v-card(width="1500" elevation="0" class="mt-2 mx-auto" style="background: transparent")
      h3(class="pt-2 pb-4 font-weight-medium") Novos Produtos
      v-card(class="mx-auto" elevation="3")
        v-list(dense)
          v-list-item-group
            v-list-item(v-for="(item, i) in novosProdutos" :key="i" :to="item.link")
              v-list-item-content
                v-list-item-title(v-text="item.nomeComum")
                v-list-item-subtitle(v-text="item.ingredienteAtivo")

    v-card(width="1500" elevation="0" class="mt-2 mx-auto" :style="'background: transparent;' + favoritosVisible + ''")
      h3(class="pt-2 pb-4 font-weight-medium") Favoritos
      v-card(class="mx-auto" elevation="3")
        v-list(dense)
          v-list-item-group
            v-list-item(v-for="(item, i) in Favoritos" :key="i")
              v-list-item-content
                v-list-item-title(v-text="item.nomeComum")
                v-list-item-subtitle(v-text="item.ingredienteAtivo")

    v-card(width="1500" elevation="0" class="mt-2 mx-auto" style="background: transparent")
      h3(class="pt-2 pb-4 font-weight-medium") Ultimas Pragas Acessadas
      v-flex(justify="space-around" style="overflow-x: scroll" height:="170" )
        div(style="display: inline-flex")
          div(v-for="(item, i) in ultimasPragasAcessadas" :key="i")
            v-card(:to="item.link" elevation="0" style="background: transparent")
              v-avatar(size="112" class="ma-2" :to="item.link")
                v-img(:src="item.imagem" size="112" :to="item.link" style="border-radius: 50px;")
              h5(align="center" justify="center" :to="item.link") {{item.nomeComum}}

    v-card(width="1500" elevation="0" class="mt-2 mx-auto" style="background: transparent")
      h3(class="pt-2 pb-4  font-weight-medium") Ultimos Defensivos Acessados
      v-card(class="mx-auto" elevation="3")
        v-list(dense)
          v-list-item-group
            v-list-item(v-for="(item, i) in ultimosDefensivosAcessados" :key="i" :to="item.link")
              v-list-item-content
                v-list-item-title(v-text="item.nomeComum")
                v-list-item-subtitle(v-text="item.ingredienteAtivo")
</template>

<script>

import config from '../config/app'
import mPragas from './../models/mPragas.js'
import mDefensivos from '../models/mDefensivos'

export default {
  data: () => ({
    sugestoesPragas: [],
    novosProdutosIds: ['0KrhWfuP3Ovcm', '0QVwY9MIF6cHS', '0Xro82wOO5bsz', '01BPssW7kMVZ6', '1JhQnyRJrYhZB', '1SfkPPOrD2q0V'],
    novosProdutos: [],
    Favoritos: [],
    favoritosVisible: 'display: none',
    ultimasPragasAcessadas: [],
    ultimosDefensivosAcessados: []
  }),
  mounted () {
    const aguarde = window.setInterval((e) => {
      if (localStorage[config.prefixApp + '/configEndUpdateProcess'] &&
      localStorage[config.prefixApp + '/configEndUpdateProcess'] === 'true' &&
      localStorage[config.prefixApp + '/dbBloqueado'] === 'false') {
        // this._ultimasPragasAcessadas()
        // this._ultimosFitosAcessados()
        // this._novosProdutos()
        // this._sugestoesPragas()
        clearInterval(aguarde)
      }
    }, 100)
  },
  methods: {
    _ultimosFitosAcessados (e) {
      mDefensivos.getDefensivosHome(this.database).then(success => {
        this.ultimosDefensivosAcessados = success
      })
    },
    _ultimasPragasAcessadas (e) {
      mPragas.getPragasHome(this.database).then(success => {
        this.ultimasPragasAcessadas = success
      })
    },
    _novosProdutos (e) {
      mDefensivos.getDefensivosNovos(this.database, this.novosProdutosIds).then(success => {
        this.novosProdutos = success
      })
    },
    _sugestoesPragas (e) {
      mPragas.getPragasRandom(this.database).then(success => {
        this.sugestoesPragas = success
      })
    }
  }
}
</script>

<style>
.v-card {
  border-radius: 12px !important;
}
</style>
