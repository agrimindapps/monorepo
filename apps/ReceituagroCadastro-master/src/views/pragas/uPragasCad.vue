<template lang="pug">

v-flex(align="center" justify="center" class="pt-4 mt-2")

  v-tabs(centered="centered" style="border-radius: 7px 7px 0px 0px" grow color="success" class="mx-auto elevation-3")
    v-tab(href="#tab-1") Principal
    v-tab(v-if="tbpragas.tipoPraga === '3'" href="#tab-2") Plantas Inf
    v-tab(v-if="tbpragas.tipoPraga === '1' || tbpragas.tipoPraga === '2'" href="#tab-3") Pragas Inf

    v-tabs-slider(color="success")

    v-tab-item(key="tab-1" value="tab-1" class="mt-2")
      v-card(class="mt-3 pa-6" elevation="0")
        v-row(class="mb-3")
          v-spacer
          v-btn(class="ma-1" color="success" @click="gravarPraga()")
            v-icon(left) fas fa-check
            | Confirmar

        v-row
          v-text-field(dense outlined hide-details class="pa-1" style="width: 15%" color="success" v-model="tbpragas.IdReg" label="IdReg" disabled)
          v-text-field(dense outlined hide-details class="pa-1" style="width: 28%" color="success" v-model="tbpragas.nomeComum" label="Nome Comum")
          v-text-field(dense outlined hide-details class="pa-1" style="width: 28%" color="success" v-model="tbpragas.nomeCientifico" label="Nome Cientifico")
          v-select(dense outlined hide-details class="pa-1" style="width: 28%" color="success" v-model="tbpragas.tipoPraga" :items="tiposPragas" item-text="value" item-value="id" item-color="success" append-icon="unfold_more" label="Tipo Praga")
        v-row
          h4(class="mt-4 mb-3 pr-6" align="end" style="width: 16%" ) Reino
          v-text-field(dense outlined hide-details class="pa-1" style="width: 28%" color="success" v-model="tbpragas.dominio" label="Dominio")
          v-text-field(dense outlined hide-details class="pa-1" style="width: 28%" color="success" v-model="tbpragas.reino" label="Reino")
          v-text-field(dense outlined hide-details class="pa-1" style="width: 28%" color="success" v-model="tbpragas.subReino" label="Sub-Reino")
        v-row
          h4(class="mt-4 mb-3 pr-6" align="end" style="width: 16%" ) Clado
          v-text-field(dense outlined hide-details class="pa-1" style="width: 28%" color="success" v-model="tbpragas.clado01" label="Clado 01")
          v-text-field(dense outlined hide-details class="pa-1" style="width: 28%" color="success" v-model="tbpragas.clado02" label="Clado 02")
          v-text-field(dense outlined hide-details class="pa-1" style="width: 28%" color="success" v-model="tbpragas.clado03" label="Clado 03")
        v-row
          h4(class="mt-4 mb-3 pr-6" align="end" style="width: 16%" ) Divisão
          v-text-field(dense outlined hide-details class="pa-1" style="width: 28%" color="success" v-model="tbpragas.superDivisao" label="Super Divisão")
          v-text-field(dense outlined hide-details class="pa-1" style="width: 28%" color="success" v-model="tbpragas.divisao" label="Divisão")
          v-text-field(dense outlined hide-details class="pa-1" style="width: 28%" color="success" v-model="tbpragas.subDivisao" label="Sub Divisão")
        v-row
          h4(class="mt-4 mb-3 pr-6" align="end" style="width: 16%" ) Classe
          v-text-field(dense outlined hide-details class="pa-1" style="width: 28%" color="success" v-model="tbpragas.classe" label="Classe")
          v-text-field(dense outlined hide-details class="pa-1" style="width: 28%" color="success" v-model="tbpragas.subClasse" label="Sub Classe")
          v-text-field(dense filled hide-details class="pa-1" style="width: 28%" color="success" v-model="tbpragas.superOrdem" label="" disabled)
        v-row
          h4(class="mt-4 mb-3 pr-6" align="end" style="width: 16%" ) Familia
          v-text-field(dense outlined hide-details class="pa-1" style="width: 28%" color="success" v-model="tbpragas.superFamilia" label="Super Familia")
          v-text-field(dense outlined hide-details class="pa-1" style="width: 28%" color="success" v-model="tbpragas.familia" label="Familia")
          v-text-field(dense outlined hide-details class="pa-1" style="width: 28%" color="success" v-model="tbpragas.subFamilia" label="Sub Familia")
        v-row
          h4(class="mt-4 mb-3 pr-6" align="end" style="width: 16%" ) Ordem
          v-text-field(dense outlined hide-details class="pa-1" style="width: 20%" color="success" v-model="tbpragas.superOrdem" label="Super Ordem")
          v-text-field(dense outlined hide-details class="pa-1" style="width: 20%" color="success" v-model="tbpragas.ordem" label="Ordem")
          v-text-field(dense outlined hide-details class="pa-1" style="width: 20%" color="success" v-model="tbpragas.subOrdem" label="Sub Ordem")
          v-text-field(dense outlined hide-details class="pa-1" style="width: 20%" color="success" v-model="tbpragas.infraOrdem" label="Infra Ordem")
        v-row
          h4(class="mt-4 mb-3 pr-6" align="end" style="width: 16%" ) Outros
          v-text-field(dense outlined hide-details class="pa-1" style="width: 20%" color="success" v-model="tbpragas.tribo" label="Tribo")
          v-text-field(dense outlined hide-details class="pa-1" style="width: 20%" color="success" v-model="tbpragas.subTribo" label="Sub Tribo")
          v-text-field(dense outlined hide-details class="pa-1" style="width: 20%" color="success" v-model="tbpragas.genero" label="Genero")
          v-text-field(dense outlined hide-details class="pa-1" style="width: 20%" color="success" v-model="tbpragas.especie" label="Especie")

    v-tab-item(key="tab-2" value="tab-2" class="mt-2")
      v-card(class="mx-auto mt-3 pa-6" elevation="0")
        v-row(class="mb-3")
          v-spacer
          v-btn(class="ma-1" color="success" @click="gravarPlantasInf()")
            v-icon(left) fas fa-check
            | Confirmar
        v-row
          v-col(cols="6")
            h3(class="pl-1") Caracteristicas da Planta
            v-text-field(dense outlined hide-details class="pa-1" color="success" v-model="tbplantasinf.ciclo" label="Ciclo")
            v-text-field(dense outlined hide-details class="pa-1" color="success" v-model="tbplantasinf.reproducao" label="Reprod./Propagação")
            v-text-field(dense outlined hide-details class="pa-1" color="success" v-model="tbplantasinf.habitat" label="habitat/Tipologia")
            v-text-field(dense outlined hide-details class="pa-1" color="success" v-model="tbplantasinf.adaptacoes" label="Adaptações")
            v-text-field(dense outlined hide-details class="pa-1" color="success" v-model="tbplantasinf.altura" label="Altura (cm)")
          v-col(cols="6")
            h3(class="pl-1") Caracteristicas da Folha
            v-text-field(dense outlined hide-details class="pa-1" color="success" v-model="tbplantasinf.filotaxia" label="Filotaxia")
            v-text-field(dense outlined hide-details class="pa-1" color="success" v-model="tbplantasinf.formaLimbo" label="Forma do Limbo")
            v-text-field(dense outlined hide-details class="pa-1" color="success" v-model="tbplantasinf.superficie" label="Superficie")
            v-text-field(dense outlined hide-details class="pa-1" color="success" v-model="tbplantasinf.consistencia" label="Consitência")
            v-text-field(dense outlined hide-details class="pa-1" color="success" v-model="tbplantasinf.nervacao" label="Nervação / Venação")
            v-text-field(dense outlined hide-details class="pa-1" color="success" v-model="tbplantasinf.nervacaoComprimento" label="Nervação Comprimento")
        v-row
          v-col(cols="6")
            h3(class="pl-1") Caracteristicas da Flores
            v-text-field(dense outlined hide-details class="pa-1" color="success" v-model="tbplantasinf.inflorescencia" label="Inflorescencia")
            v-text-field(dense outlined hide-details class="pa-1" color="success" v-model="tbplantasinf.perianto" label="Perianto")
          v-col(cols="6")
            h3(class="pl-1") Caracteristicas dos Frutos
            v-text-field(dense outlined hide-details class="pa-1" color="success" v-model="tbplantasinf.tipologiaFruto" label="Tipologia do Fruto")
        h3(class="pl-1") Descrisão
        v-textarea(dense outlined hide-details class="pa-1" color="success" v-model="tbplantasinf.observacoes" label="Observações")

    v-tab-item(key="tab-3" value="tab-3" class="mt-2")
      v-card(class="mx-auto mt-3 pa-6" elevation="0")
        v-row(class="mb-3")
          v-spacer
          v-btn(class="ma-1" color="success" @click="gravarPragasInf()")
            v-icon(left) fas fa-check
            | Confirmar

        v-row
          v-col(cols="12")
            h3(class="pl-1") Descrição
            v-textarea(outlined v-model="tbpragasinf.descrisao" color="success")
        v-row
          v-col(cols="12")
            h3(class="pl-1") Sintomas
            v-textarea(outlined v-model="tbpragasinf.sintomas" color="success")
        v-row
          v-col(cols="12")
            h3(class="pl-1") BioEcologia
            v-textarea(outlined v-model="tbpragasinf.bioecologia" color="success")
        v-row
          v-col(cols="12")
            h3(class="pl-1") Controle
            v-textarea(outlined v-model="tbpragasinf.controle" color="success")

  toolbar(@update-search="getSearch" :title="toolbarSettings.title"
      :subTitle="toolbarSettings.subTitle" :useSearch="toolbarSettings.useSearch"
      :buttons="toolbarSettings.buttons")

</template>

<script>

// Import Components
import compToolBar from './../../core/components/toolbar'

import { mPragasBuscarDetalhes, mPragasGravarRegistroPlantasInf, mPragasGravarRegistroPragas, mPragasGravarRegistroPragasInf } from './../../models/mPragas'

export default {
  components: {
    toolbar: compToolBar
  },
  data: () => ({
    search: '',
    toolbarSettings: {
      title: 'Defensivos',
      subTitle: 'Cadastro',
      useSearch: true,
      buttons: []
    },
    tbpragas: {
      IdReg: null,
      nomeComum: null,
      nomeCientifico: null,
      dominio: null,
      reino: null,
      subReino: null,
      clado01: null,
      clado02: null,
      clado03: null,
      superDivisao: null,
      divisao: null,
      subDivisao: null,
      classe: null,
      subClasse: null,
      superOrdem: null,
      ordem: null,
      subOrdem: null,
      infraOrdem: null,
      superFamilia: null,
      familia: null,
      subFamilia: null,
      tribo: null,
      subTribo: null,
      genero: null,
      especie: null,
      tipoPraga: null
    },
    tbpragasinf: {
      IdReg: null,
      fkIdPraga: null,
      descrisao: null,
      sintomas: null,
      bioecologia: null,
      controle: null
    },
    tbplantasinf: {
      IdReg: null,
      fkIdPraga: null,
      ciclo: null,
      reproducao: null,
      habitat: null,
      adaptacoes: null,
      altura: null,
      filotaxia: null,
      formaLimbo: null,
      superficie: null,
      consistencia: null,
      nervacao: null,
      nervacaoComprimento: null,
      inflorescencia: null,
      perianto: null,
      tipologiaFruto: null,
      observacoes: null
    },
    tiposPragas: [
      { id: '1', value: 'Insetos' },
      { id: '2', value: 'Doenças' },
      { id: '3', value: 'Plantas Invasoras' }
    ]
  }),
  created () {
    this.buscarRegistro()
  },
  methods: {
    getSearch (e) { if (e === null) e = ''; this.search = e },

    buscarRegistro () {
      if (this.$route.query.id === undefined) return false
      mPragasBuscarDetalhes(this.$route.query.id)
        .then(data => {
          this.tbpragas = data.tbpragas
          if (data.tbpragasinf.length > 0) { this.tbpragasinf = data.tbpragasinf[0] }
          if (data.tbplantasinf.length > 0) { this.tbplantasinf = data.tbplantasinf[0] }
        })
    },

    gravarPraga () {
      mPragasGravarRegistroPragas(this.tbpragas)
        .then(() => { console.log('Registro de Praga gravado com sucesso') })
    },

    gravarPragasInf () {
      this.tbpragasinf.fkIdPraga = this.tbpragas.IdReg
      mPragasGravarRegistroPragasInf(this.tbpragasinf)
        .then(() => { console.log('Registro Pragas Inf gravado com sucesso') })
    },

    gravarPlantasInf () {
      this.tbplantasinf.fkIdPraga = this.tbpragas.IdReg
      mPragasGravarRegistroPlantasInf(this.tbplantasinf)
        .then(() => { console.log('Registro Plantas Inf gravado com sucesso') })
    }
  }
}
</script>

<style>

</style>
