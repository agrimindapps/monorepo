<template lang="pug">

v-flex(align="center" justify="center" class="pt-4 mt-2")

  v-tabs(centered="centered" style="border-radius: 7px 7px 0px 0px" grow color="success" class="mx-auto elevation-3")
    v-tab(href="#tab-1") Informações
    v-tab(href="#tab-2") Diagnóstico
    v-tab(href="#tab-3") Aplicação

    v-tabs-slider(color="success")

    v-tab-item(key="tab-1" value="tab-1" class="mt-2")
      v-card(class="mt-3 pa-6" elevation="0")
        v-row(class="mb-3")
          h3(class="pa-2") Informações Técnicas
          v-spacer
          v-btn(class="ma-1" color="success" @click="importaDadosExternosDefensivos")
            v-icon(left) far fa-clipboard
            | Carregar Ext
          v-btn(class="ma-1" color="success" @click="gravarDefensivo")
            v-icon(left) fas fa-check
            | Confirmar
        div
          v-row
            v-text-field(dense outlined hide-details class="pa-2" style="width: 15%" v-model="principal.IdReg" label="IdReg" disabled)
            v-text-field(dense outlined hide-details class="pa-2" style="width: 65%" v-model="principal.nomeComum" label="Nome Defensivo")
            v-text-field(dense outlined hide-details class="pa-2" style="width: 20%" v-model="principal.mapa" label="MAPA")
          v-row
            v-text-field(dense outlined hide-details class="pa-2" style="width: 60%" v-model="principal.ingredienteAtivo" label="Ingrediente Ativo")
            v-text-field(dense outlined hide-details class="pa-2" style="width: 40%" v-model="principal.quantProduto" label="Quantidade")
          v-row
            v-text-field(dense outlined hide-details class="pa-2" style="width: 40%" v-model="principal.fabricante" label="Fabricante")
            v-text-field(dense outlined hide-details class="pa-2" style="width: 60%" v-model="principal.formulacao" label="Formulação")
          v-row
            v-text-field(dense outlined hide-details class="pa-2" style="width: 40%" v-model="principal.modoAcao" label="Modo de Ação")
            v-text-field(dense outlined hide-details class="pa-2" style="width: 30%" v-model="principal.inflamavel" label="Inflamavel")
            v-text-field(dense outlined hide-details class="pa-2" style="width: 30%" v-model="principal.corrosivo" label="Corrosivo")
          v-row
            v-text-field(dense outlined hide-details class="pa-2" style="width: 30%" v-model="principal.classeAgronomica" label="Classe Agronomica")
            v-text-field(dense outlined hide-details class="pa-2" style="width: 30%" v-model="principal.toxico" label="Tóxico")
            v-text-field(dense outlined hide-details class="pa-2" style="width: 30%" v-model="principal.classAmbiental" label="Classe Ambiental")
            v-text-field(dense outlined hide-details class="pa-2" style="width: 10%" v-model="principal.comercializado" label="Comercializado")

    v-tab-item(key="tab-2" value="tab-2" class="mt-2 pa-2")
      v-data-table(:headers="headers" dense :search="search" :items="diagnostico" :sort-by="['cultura', 'nomeCientifico']" group-by="cultura" :items-per-page="400" class="elevation-0" to="#")
        template(slot="top")

          v-toolbar(flat)
            h3 Diagnósticos
            v-spacer
            v-btn(color="success" dark class="mb-2 mr-2" @click="novaLinhaDiagnostico")
              v-icon(left) fas fa-plus
              | Novo
            v-divider(vertical class="mb-2 mr-2")
            v-btn(color="success" dark class="mb-2 mr-2" @click="importaDadosExternosDiagnosticos")
              v-icon(left) far fa-clipboard
              | Carregar Ext
            v-divider(vertical class="mb-2 mr-2" )
            v-btn(color="success" dark class="mb-2 mr-2" @click="editarTodos")
              v-icon(left) fas fa-pen
              | Editar T.
            v-btn(color="success" dark class="mb-2 mr-2" @click="gravarTodosDiagnosticos")
              v-icon(left) fas fa-check
              | Gravar T.
            v-divider(vertical class="mb-2 mr-2")
            v-btn(color="error" dark class="mb-2 mr-2" @click="excluiTodosSemDSMax")
              | Excluir SD

        template(v-slot:header.min="{ header }")
          v-btn(small text class="mr-0 size12" @click="refletirDados (1, diagnostico)") {{header.text}}
        template(v-slot:header.max="{ header }")
          v-btn(small text class="mr-0 size12" @click="refletirDados (2, diagnostico)") {{header.text}}
        template(v-slot:header.umDosagem="{ header }")
          v-btn(small text class="mr-0 size12" @click="refletirDados (3, diagnostico)") {{header.text}}
        template(v-slot:header.minT="{ header }")
          v-btn(small text class="mr-0 size12" @click="refletirDados (4, diagnostico)") {{header.text}}
        template(v-slot:header.maxT="{ header }")
          v-btn(small text class="mr-0 size12" @click="refletirDados (5, diagnostico)") {{header.text}}
        template(v-slot:header.UmTerrestre="{ header }")
          v-btn(small text class="mr-0 size12" @click="refletirDados (6, diagnostico)") {{header.text}}
        template(v-slot:header.minA="{ header }")
          v-btn(small text class="mr-0 size12" @click="refletirDados (7, diagnostico)") {{header.text}}
        template(v-slot:header.maxA="{ header }")
          v-btn(small text class="mr-0 size12" @click="refletirDados (8, diagnostico)") {{header.text}}
        template(v-slot:header.umAerea="{ header }")
          v-btn(small text class="mr-0 size12" @click="refletirDados (9, diagnostico)") {{header.text}}
        template(v-slot:header.intervalo="{ header }")
          v-btn(small text class="mr-0 size12" @click="refletirDados (10, diagnostico)") {{header.text}}

        template(v-slot:group.header="props" )
          td(:colspan="1" class="d-flex")
            v-btn(small icon @click="props.isOpen = !props.isOpen")
              v-icon(small) far fa-minus-square
            div(style="margin-top: 4px; font-size:14px; font-wieght: bold") {{ props.group }}

          td(align="center" justify="center" class="ml-0 pl-0")
            v-btn(small text class="mr-0 size12" @click="refletirDados (1, props.items)") Min
          td(align="center" justify="center" class="ml-0 pl-0")
            v-btn(small text class="mr-0 size12" @click="refletirDados (2, props.items)") Max
          td(align="right" justify="right" class="ml-0 pl-0")
            v-btn(small text class="mr-0 size12 pa-0" @click="refletirDados (3, props.items)") Um / Dosagem
          td(align="center" justify="center" class="ml-0 pl-0")
            v-btn(small text class="mr-0 size12" @click="refletirDados (4, props.items)") Min
          td(align="center" justify="center" class="ml-0 pl-0")
            v-btn(small text class="mr-0 size12"  @click="refletirDados (5, props.items)") Max
          td(align="right" justify="right" class="ml-0 pl-0")
            v-btn(small text class="mr-0 size12 pa-0" @click="refletirDados (6, props.items)") Um / Terrestre
          td(align="center" justify="ricenterght" class="ml-0 pl-0")
            v-btn(small text class="mr-0 size12" @click="refletirDados (7, props.items)") Min
          td(align="center" justify="center" class="ml-0 pl-0")
            v-btn(small text class="mr-0 size12" @click="refletirDados (8, props.items)") Max
          td(align="right" justify="right" class="ml-0 pl-0")
            v-btn(small text class="mr-0 size12 pa-0" @click="refletirDados (9, props.items)") Um / Áerea
          td(align="right" justify="right" class="ml-0 pl-0")
            v-btn(small text class="mr-0 size12 pa-0" @click="refletirDados (10, props.items)") Intevalo
          td(align="right" justify="right")
            v-icon(small class="mr-3" color="blue" @click="diagnosticosCulturaEditar(props.items)") fas fa-pen
            v-icon(small class="mr-3" color="green" @click="diagnosticosCulturasGravar(props.items)") fas fa-check

        template(v-slot:item.actions="{ item, i }")
          v-icon(small class="mr-3" v-if="item.edit" color="green" @click="gravarUnicoDiagnostico(item)") fas fa-check
          v-icon(small class="mr-3" v-if="!item.edit" color="blue" @click="alterarDiagnostico(item)") fas fa-pen
          v-icon(small class="mr-3" color="red" v-if="!item.edit" @click="deletarDiagnostico(item)") fas fa-trash

        template(v-slot:item.nomeCientifico="{ item, i }")
          div(v-if="!item.edit" class="pl-3") {{ item.nomeCientifico}}
          v-btn(v-if="item.edit" outlined x-small class="mr-1" @click="buscaRegistros(item, 1) ") {{ item.cultura }}
          v-btn(v-if="item.edit" outlined x-small class="mr-1" @click="buscaRegistros(item, 2) ") {{ item.nomeCientifico }}

        template(v-slot:item.min="{ item }")
          div(v-if="!item.edit" class="mr-1 size12 pa-0") {{ item.dsMin }}
          v-text-field(v-else="item.edit" v-model="item.dsMin" outlined dense single-line hide-details class="mr-1 size12 pa-0")

        template(v-slot:item.max="{ item }")
          div(v-if="!item.edit" class="mr-1 size12 pa-0" ) {{ item.dsMax }}
          v-text-field(v-else="item.edit" v-model="item.dsMax" outlined dense single-line hide-details class="mr-1 size12 pa-0")

        template(v-slot:item.umDosagem="{ item }")
          div(v-if="!item.edit" class="mr-1 size12 pa-0") {{ item.um }}
          v-text-field(v-else="item.edit" v-model="item.um" outlined dense single-line hide-details class="mr-1 size12 pa-0")

        template(v-slot:item.minT="{ item }")
          div(v-if="!item.edit" class="mr-1 size12 pa-0") {{ item.minAplicacaoT }}
          v-text-field(v-else="item.edit" v-model="item.minAplicacaoT" outlined dense single-line hide-details class="mr-1 size12")

        template(v-slot:item.maxT="{ item }")
          div(v-if="!item.edit" class="mr-1 size12 pa-0") {{ item.maxAplicacaoT }}
          v-text-field(v-else="item.edit" v-model="item.maxAplicacaoT" outlined dense single-line hide-details class="mr-1 size12")

        template(v-slot:item.UmTerrestre="{ item }")
          div(v-if="!item.edit" class="mr-1 size12 pa-0") {{ item.umT }}
          v-text-field(v-else="item.edit" v-model="item.umT" outlined dense single-line hide-details class="mr-1 size12")

        template(v-slot:item.minA="{ item }")
          div(v-if="!item.edit" class="mr-1 size12 pa-0") {{ item.minAplicacaoA }}
          v-text-field(v-else="item.edit" v-model="item.minAplicacaoA" outlined dense single-line hide-details class="mr-1 size12")

        template(v-slot:item.maxA="{ item }")
          div(v-if="!item.edit" class="mr-1 size12 pa-0") {{ item.maxAplicacaoA }}
          v-text-field(v-else="item.edit" v-model="item.maxAplicacaoA" outlined dense single-line hide-details class="mr-1 size12")

        template(v-slot:item.umAerea="{ item }")
          div(v-if="!item.edit" class="mr-1 size12 pa-0") {{ item.umA }}
          v-text-field(v-else="item.edit" v-model="item.umA" outlined dense single-line hide-details class="mr-1 size12")

        template(v-slot:item.intervalo="{ item }")
          div(v-if="!item.edit") {{ item.intervalo }}
          v-text-field(v-else="item.edit" v-model="item.intervalo" outlined dense single-line hide-details class="size12")

    v-tab-item(key="tab-3" value="tab-3" class="mt-2")

      v-card(class="mx-auto mt-3 pa-6" elevation="0")
        v-row(class="mb-3")
          h3(class="pa-2") Informações Complementares
          v-spacer
          v-btn(class="ma-1" color="success" @click="importaDadosExternosAplicacao")
            v-icon(left) far fa-clipboard
            | Carregar Ext
          v-btn(class="ma-1" color="success" @click="gravarUnicaAplicacao")
            v-icon(left) fas fa-check
            | Confirmar

        div
          v-row
            v-textarea(v-model="aplicacao.embalagens" outlined label="Embalagens")
          v-row
            v-textarea(v-model="aplicacao.tecnologia" outlined label="Tecnologia")
          v-row
            v-textarea(v-model="aplicacao.pHumanas" outlined label="Precauções Humanas")
          v-row
            v-textarea(v-model="aplicacao.pAmbiental" outlined label="Precauções Ambientais")
          v-row
            v-textarea(v-model="aplicacao.manejoResistencia" outlined label="Manejo de Resistencia")
          v-row
            v-textarea(v-model="aplicacao.compatibilidade" outlined label="Compatibilidade")
          v-row
            v-textarea(v-model="aplicacao.manejoIntegrado" outlined label="Manejo Integrado")

  v-dialog(v-model="outros.dialog" max-width="540" style="margin: 0px !important")
    v-card(style="width: 540px;" light class="pa-0 pb-1")
      div(style="text-align: left; font-size: 14px" class="pa-2") Busca de Registros
      v-divider
      v-text-field(v-model="outros.search" label="Pesquisar" @keyup="filter" class="pl-3 pr-3 pb-1 pt-0" prepend-inner-icon="fas fa-search" single-line hide-details clearable clear-icon="fas fa-times")
      v-card(style="width: 640px; overflow-y: scroll" max-height="320" elevation="0" light class="pa-0")
        v-list(dense)
          v-list-item(class="pa-0 pl-4 pb-0 mb-0" v-for="(row, i) in outros.listaBusca" :key="i" @click="buscaRegistrosRetorno(row)" style="border-bottom: 1px #f3f3f3 solid")
            v-list-item-content(class="pa-0 pt-0 pb-0 mb-0")
              v-list-item-title(v-text="row.text")

      v-card-actions(style="text-align: center")
        v-spacer
        v-btn(class="ma-1" @click="outros.dialog = false; outros.listaBusca = []") Fechar

  toolbar(@update-search="getSearch" @menuExec="menuExec" :title="toolbarSettings.title"
      :subTitle="toolbarSettings.subTitle" :useSearch="toolbarSettings.useSearch"
      :buttons="toolbarSettings.buttons")

</template>

<script>

// Import Components
import compToolBar from './../../core/components/toolbar'

// import config from '../../config/app.js'
import { dbOrderList } from './../../core/models/mIndexeddb'
import {
  getDefensivosDetalhes,
  gravarDefensivo,
  gravarDiagnostico,
  gravarAplicacao,
  excluirDiagnosticoUnico
} from '../../models/mDefensivos'
import { mPragasBuscaTodosSimples } from '../../models/mPragas'
import { mCulturasBuscarTodos } from '../../models/mCulturas'

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
    outros: {
      search: '',
      dialog: false,
      cardDisabled: false,
      listaRegistros: [],
      listaBusca: []
    },
    headers: [
      { text: 'Cultura', align: 'start', value: 'cultura', sortable: false },
      { text: 'Praga', width: 280, align: 'start', value: 'nomeCientifico', sortable: false },
      { text: 'Min', width: 50, align: 'center', value: 'min', sortable: false },
      { text: 'Max', width: 50, align: 'center', value: 'max', sortable: false },
      { text: 'Um Dosagem', width: 130, align: 'end', value: 'umDosagem', sortable: false },
      { text: 'Min', width: 50, align: 'center', value: 'minT', sortable: false },
      { text: 'Max', width: 50, align: 'center', value: 'maxT', sortable: false },
      { text: 'Um Terrestre', width: 130, align: 'end', value: 'UmTerrestre', sortable: false },
      { text: 'Min', width: 50, align: 'center', value: 'minA', sortable: false },
      { text: 'Max', width: 50, align: 'center', value: 'maxA', sortable: false },
      { text: 'Um Áerea', width: 130, align: 'end', value: 'umAerea', sortable: false },
      { text: 'Intervalo', width: 120, align: 'end', value: 'intervalo', sortable: false },
      { text: 'Ações', width: 65, align: 'end', value: 'actions', sortable: false }
    ],
    IdReg: null,
    principal: {
      IdReg: null,
      nomeComum: null,
      nomeTecnico: null,
      classeAgronomica: null,
      fabricante: null,
      classAmbiental: null,
      comercializado: null,
      corrosivo: null,
      inflamavel: null,
      formulacao: null,
      modoAcao: null,
      mapa: null,
      toxico: null,
      ingredienteAtivo: '',
      quantProduto: ''
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
    },
    modeloDiagnostico: {
      IdReg: '',
      fkIdCultura: '',
      fkIdDefensivo: '',
      cultura: '',
      fkIdPraga: '',
      nomeCientifico: '',
      dsMin: '',
      dsMax: '',
      um: '',
      minAplicacaoT: '',
      maxAplicacaoT: '',
      umT: '',
      minAplicacaoA: '',
      maxAplicacaoA: '',
      umA: '',
      intervalo: '',
      intervalo2: '',
      epocaAplicacao: '',
      edit: true
    }
  }),
  watch: {
    'IdReg' () {
      if (!this.IdReg) { this.outros.cardDisabled = true }
    },
    search () { this.filter() }
  },
  mounted () {
    if (this.$route.query.id.length === 13) {
      const params = { IdReg: this.$route.query.id }
      this.recuperaDefensivoDB(params)
    } else {
      const row = JSON.parse(window.localStorage.getItem('tempCadastro'))
      this.principal.nomeComum = row.nomeComum
      this.principal.fabricante = row.fabricante
      this.principal.ingredienteAtivo = row.ingredienteAtivo
    }
  },
  methods: {
    getSearch (e) { if (e === null) e = ''; this.search = e },

    menuExec (e) { if (e === 'marcarFavorito') this.marcarFavorito() },

    editarTodos () {
      this.diagnostico.forEach(row => {
        row.edit = true
      })
    },

    excluiTodosSemDSMax () {
      this.diagnostico.forEach(row => {
        if (row.dsMax === '' || row.fkIdCultura.length !== 13 || row.fkIdPraga.length !== 13) {
          this.deletarDiagnostico(row)
        }
      })
    },

    recuperaDefensivoDB (params) {
      getDefensivosDetalhes(params)
        .then(row => {
          this.outros.cardDisabled = true
          console.log(row)
          this.principal = row.principal
          this.diagnostico = row.diagnostico
          this.aplicacao = row.aplicacao
          setTimeout(() => {
            if (this.aplicacao.length > 0) {
              this.aplicacao = row.aplicacao
            }
          }, 1000)
          this.IdReg = row.IdReg
        })
    },

    // Carregar Culturas e Pragas
    // Importação
    importaDadosExternosDefensivos () {
      navigator.clipboard.readText()
        .then(data => {
          const aplic = JSON.parse(data)
          aplic.cabecalho.forEach(row => { this.principal[row.field] = row.value })
        })
        .catch(data => {
          alert('Exportação não possui um JSON valido!!')
        })

      // this.importaDadosExternosDiagnosticos()
      // this.importaDadosExternosAplicacao()
    },

    importaDadosExternosDiagnosticos () {
      // let $this = this
      let listaCulturas, listaPragas

      // Carregamento das informações em memoria
      const start = a => { return new Promise(resolve => resolve(a)) }
      const carregaCulturas = async () => { await mCulturasBuscarTodos().then(data => { listaCulturas = data }) }
      const carregaPragas = async () => { await mPragasBuscaTodosSimples().then(data => { listaPragas = data }) }

      // Filtros
      const filtraCultura = (stringValue) => {
        return listaCulturas.find(a => a.cultura.toLowerCase() === stringValue.toLowerCase())
      }
      const filtraPraga = (stringValue) => {
        return listaPragas.find(a => a.nomeCientifico.toLowerCase() === stringValue.toLowerCase())
      }

      const buscaJaExistente = (culturaTemp, pragaTemp) => {
        let pos = -1
        for (let x = 0; x < this.diagnostico.length; x++) {
          const row = this.diagnostico[x]
          if (row.nomeCientifico !== undefined) {
            if (row.cultura.toLowerCase() === culturaTemp.toLowerCase() &&
              row.nomeCientifico.toLowerCase() === pragaTemp.toLowerCase()) { pos = x }
          }
        }
        return pos
      }

      // const filtraMedidasExternas = async (params) => {
      //   const grupoMedidas = await getExtracaoPosicoes(params).then(data => { console.log(data) })// JSON.parse(localStorage[config.prefixApp + '/' + params.img])
      //   return grupoMedidas.find(a => a.x === params.x && a.y === params.y)
      // }

      // Aqui começa o processo real
      start()
        .then(() => carregaCulturas())
        .then(() => carregaPragas())
        .then(() => {
          navigator.clipboard.readText()
            .then(data => {
              data = JSON.parse(data)

              for (let y = 0; y < data.diagnostico.length; y++) {
                const newRow = JSON.parse(JSON.stringify(this.modeloDiagnostico))
                const row = data.diagnostico[y]

                const posi = buscaJaExistente(row.cultura, row.praga)
                if (posi >= 0) {
                  if (row.dsMin !== '') this.diagnostico[posi].dsMin = row.dsMin
                  if (row.dsMax !== '') this.diagnostico[posi].dsMax = row.dsMax
                  if (row.um !== '') this.diagnostico[posi].um = row.um

                  if (row.minAplicacaoT !== '') this.diagnostico[posi].minAplicacaoT = row.minAplicacaoT
                  if (row.maxAplicacaoT !== '') this.diagnostico[posi].maxAplicacaoT = row.maxAplicacaoT
                  if (row.umT !== '') this.diagnostico[posi].umT = row.umT

                  if (row.minAplicacaoA !== '') this.diagnostico[posi].minAplicacaoA = row.minAplicacaoA
                  if (row.maxAplicacaoA !== '') this.diagnostico[posi].maxAplicacaoA = row.maxAplicacaoA
                  if (row.umA !== '') this.diagnostico[posi].umA = row.umA

                  if (row.intervalo !== '') this.diagnostico[posi].intervalo = row.intervalo
                  this.diagnostico[posi].edit = true
                } else {
                  try {
                    const filtredCultura = filtraCultura(row.cultura)
                    const filtrodPraga = filtraPraga(row.praga)

                    if (filtredCultura) newRow.fkIdCultura = filtredCultura.IdReg
                    if (filtredCultura) newRow.cultura = filtredCultura.cultura
                    if (filtrodPraga) newRow.fkIdPraga = filtrodPraga.IdReg
                    if (filtrodPraga) newRow.nomeCientifico = filtrodPraga.nomeCientifico

                    console.warn('Cadastrar praga ou cultura:' + row.cultura + ' / ' + row.praga)

                    newRow.edit = true

                    if (row.dsmin !== '') newRow.dsMim = row.dsMin
                    if (row.dsMax !== '') newRow.dsMax = row.dsMax
                    if (row.um !== '') newRow.um = row.um

                    if (row.minAplicacaoT !== '') newRow.minAplicacaoT = row.minAplicacaoT
                    if (row.maxAplicacaoT !== '') newRow.maxAplicacaoT = row.maxAplicacaoT
                    if (row.umT !== '') newRow.umT = row.umT

                    if (row.minAplicacaoA !== '') newRow.minAplicacaoA = row.minAplicacaoA
                    if (row.maxAplicacaoA !== '') newRow.maxAplicacaoA = row.maxAplicacaoA
                    if (row.umA !== '') newRow.umA = row.umA

                    const validRegistroExiste = this.diagnostico.find(t => t.fkIdCultura === newRow.fkIdCultura && t.fkIdPraga === newRow.fkIdPraga)
                    if (!validRegistroExiste) this.diagnostico.push(newRow)
                  } catch (e) {
                    console.log(e)
                  }
                }
              }
            })
            // .catch(() =>
            //   alert('Exportação não possui um JSON valido!!')
            // )
        })
    },
    importaDadosExternosAplicacao () {
      navigator.clipboard.readText()
        .then(data => {
          const aplic = JSON.parse(data)
          for (const row of aplic.aplicacao) {
            this.aplicacao[row.field] = row.value
          }
        })
        .catch(data =>
          alert('Exportação não possui um JSON valido!!')
        )
    },

    novaLinhaDiagnostico () {
      const novaLinha = JSON.parse(JSON.stringify(this.modeloDiagnostico))
      novaLinha.pos = this.diagnostico.length
      this.diagnostico.push(novaLinha)
    },

    alterarDiagnostico (item) {
      item.edit = true
    },

    deletarDiagnostico (item) {
      excluirDiagnosticoUnico(item)
        .then(data => {
          if (!data) return false
          const pos = this.diagnostico.findIndex(r => r.IdReg === item.IdReg)
          if (pos >= 0) this.diagnostico.splice(pos, 1)
        })
    },

    // Busca de Registros
    buscaRegistros (row2, type) {
      this.outros.listaRegistros = []
      switch (type) {
        case 1:
          mCulturasBuscarTodos().then(suss => {
            const lista = []

            let pos = 0
            if (row2.IdReg === '') { pos = row2.pos }
            if (pos === 0 && row2.IdReg !== '') {
              for (let x = 0; x < this.diagnostico.length; x++) {
                if (this.diagnostico[x].IdReg === row2.IdReg) { pos = x }
              }
            }
            console.log(pos)

            suss.forEach((row, index) => {
              row.text = row.cultura
              row.pos = pos
              row.type = 1
              lista.push(row)
              if (index === suss.length - 1) {
                console.log(lista)
                const ordenado = dbOrderList({ ArrayList: lista, Field: 'text', Field2: undefined, Distinct: false })
                this.outros.listaRegistros = ordenado
                this.outros.listaBusca = ordenado
              }
            })
          }); break

        case 2:
          mPragasBuscaTodosSimples().then(suss => {
            const lista = []

            let pos = 0
            if (row2.IdReg === '') { pos = row2.pos }
            if (pos === 0 && row2.IdReg !== '') {
              for (let x = 0; x < this.diagnostico.length; x++) {
                if (this.diagnostico[x].IdReg === row2.IdReg) { pos = x }
              }
            }
            console.log(pos)

            suss.forEach((row, index) => {
              row.text = row.nomeCientifico + ' (' + row.nomeComum + ')'
              row.pos = pos
              row.type = 2
              lista.push(row)
              if (index === suss.length - 1) {
                const ordenado = dbOrderList({ ArrayList: lista, Field: 'text', Field2: undefined, Distinct: false })
                this.outros.listaRegistros = ordenado
                this.outros.listaBusca = ordenado
              }
            })
          }); break
      }
      this.outros.dialog = true
    },

    buscaRegistrosRetorno (row) {
      switch (row.type) {
        case 1: this.diagnostico[row.pos].fkIdCultura = row.IdReg; this.diagnostico[row.pos].cultura = row.cultura; break
        case 2: this.diagnostico[row.pos].fkIdPraga = row.IdReg; this.diagnostico[row.pos].nomeCientifico = row.nomeCientifico; break
      }
      this.outros.listaBusca = []
      this.outros.search = ''
      this.outros.dialog = false
    },

    filter (e) {
      this.outros.listaBusca = []
      if (this.outros.search.length > 2) {
        this.outros.listaRegistros.filter(row => {
          if (row.text.toLowerCase().search(this.outros.search.toLowerCase()) >= 0) this.outros.listaBusca.push(row)
        })
      } else {
        this.outros.listaBusca = this.outros.listaRegistros
      }
    },
    refletirDados (value, items) {
      console.log(items[0])
      let field = ''
      let text = null
      switch (value) {
        case 1: field = 'dsMin'; break
        case 2: field = 'dsMax'; break
        case 3: field = 'um'; break
        case 4: field = 'minAplicacaoT'; break
        case 5: field = 'maxAplicacaoT'; break
        case 6: field = 'umT'; break
        case 7: field = 'minAplicacaoA'; break
        case 8: field = 'maxAplicacaoA'; break
        case 9: field = 'umA'; break
        case 10: field = 'intervalo'; break
        default: break
      }

      items.forEach((row, index) => {
        if (row.edit) {
          if (text === null) { text = row[field] }
          items[index][field] = text
        }
      })
    },

    diagnosticosCulturaEditar (items) {
      items.forEach(row => {
        row.edit = true
      })
    },

    diagnosticosCulturasGravar (items) {
      items.forEach(row => {
        this.gravarUnicoDiagnostico(row)
        row.edit = false
      })
    },

    // Gravação
    gravarDefensivo () {
      // Compoem o Container para gravar o registro
      this.outros.cardDisabled = false

      const keys = Object.keys(this.principal)
      for (const key of keys) {
        this.principal[key] = this.principal[key] === undefined ? null : this.principal[key]
      }

      gravarDefensivo(this.principal)
        .then(data => {
          this.principal.IdReg = data[0].IdReg
          console.info('Defensivo gravou com sucesso!!!', data)

          // this.gravarTodosDiagnosticos()
          // this.gravarUnicaAplicacao()
        })
        .catch(err => {
          console.warn('Ocorreu problemas na hora da gravação!!!', err)
        })
    },

    gravarTodosDiagnosticos () {
      this.diagnostico.forEach(row => {
        this.gravarUnicoDiagnostico(row)
      })
    },

    gravarUnicoDiagnostico (item) {
      if (this.principal.IdReg === null) { console.warn('O defensivo ainda não foi gravado no banco de dados'); return }
      item.fkIdDefensivo = this.principal.IdReg
      delete item.pos
      // delete item.edit

      const keys = Object.keys(item)
      for (const key of keys) {
        item[key] = item[key] === undefined ? null : item[key]
      }

      gravarDiagnostico(item)
        .then(data => {
          item.edit = false
          console.info('Diagnóstico gravou com sucesso!!!', data)
        })
        .catch(err => {
          console.warn('Ocorreu problemas na hora da gravação!!!', err)
        })
    },

    gravarUnicaAplicacao () {
      // Compoem o Container para gravar o registro
      if (this.principal.IdReg === null) { console.warn('O defensivo ainda não foi gravado no banco de dados'); return }
      this.aplicacao.fkIdDefensivo = this.principal.IdReg

      const keys = Object.keys(this.aplicacao)
      for (const key of keys) {
        this.aplicacao[key] = this.aplicacao[key] === undefined ? null : this.aplicacao[key]
      }

      gravarAplicacao(this.aplicacao)
        .then(data => {
          console.info('Aplicação gravou com sucesso!!!', data)
        })
        .catch(err => {
          console.warn('Ocorreu problemas na hora da gravação!!!', err)
        })
    }
  }
}

</script>

<style>
  .size12 {
    font-size: 11px !important;
  }
  input {
    min-height: 36px !important;
  }
  td {
    padding-left: 0px !important;
    padding-right: 0px !important;
    font-size: 12px !important;
  }
  th {
    padding-left: 0px !important;
    padding-right: 0px !important;
  }
  .v-text-field__slot {
    min-height: 36px !important;
  }
  .v-input__control {
    min-height: 36px !important;
  }
  .v-input__slot {
    padding-left: 6px !important;
    padding-right: 6px !important;
    min-height: 36px !important;
  }
  .v-list-item--dense, .v-list--dense .v-list-item {
    min-height: 28px;
  }
</style>
