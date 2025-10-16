<template lang="pug">
v-flex.pt-1(align="center", justify="center")
  v-card.mt-2.pa-2.mb-2(elevation="3")
    v-data-table.elevation-0(
      :headers="headers",
      dense,
      :items="listaRegistros",
      :search="search",
      :sort-by="['nomeComum']",
      :items-per-page="1000",
      to="#"
    )
      template(slot="top")
        v-toolbar(flat)
          v-spacer
          v-btn.mb-2.mr-2(color="success", dark, @click="exportar()")
            v-icon(left) fas fa-file-download
            | Exportar
          v-btn.mb-2(color="success", dark, :to="'/defensivos/cadastro/x'")
            v-icon(left) fas fa-plus
            | Novo

      template(v-slot:item.actions="{ item }")
        v-icon.pr-2(small, color="blue", @click="copiarNomeDefensivo(item)") fas fa-copy
        v-icon(small, color="red", @click="msgExcluirDefensivo(item)") fas fa-trash

      template(v-slot:item.quantDiag="{ item }")
        span {{ item.quantDiagP }} / {{ item.quantDiag }}

      template(v-slot:item.quantDiagP="{ item }")
        v-icon.mr-2(
          v-if="item.quantDiag === item.quantDiagP",
          small,
          color="success"
        ) far fa-check-circle

      template(v-slot:item.temInfo="{ item }")
        v-icon.mr-2(v-if="item.temInfo > 0", small, color="success") far fa-check-circle

      template(v-slot:item.secweb="{ item }")
        v-icon.mr-2(v-if="item.secweb == true", small, color="success") far fa-check-circle

      template(v-slot:item.nomeComum="{ item }")
        router-link(:to="item.link") {{ item.nomeComum }}

  v-overlay(:value="msgFiltarExibe")
    v-card(elevation="0", light, align="center", justify="center", width="300")
      v-list(dense)
        v-list-item.pl-2(@click="filtrar(1)")
          v-list-item-content(style="font-size: 15px") Todos

        v-list-item.pl-2(@click="filtrar(2)")
          v-list-item-content(style="font-size: 15px") Para Exportação

        v-list-item.pl-2(@click="filtrar(3)")
          v-list-item-content(style="font-size: 15px") Sem Diagnóstico

        v-list-item.pl-2(@click="filtrar(4)")
          v-list-item-content(style="font-size: 15px") Diagnóstico Faltante

        v-list-item.pl-2(@click="filtrar(5)")
          v-list-item-content(style="font-size: 15px") Sem Informações

  v-overlay(:value="msgExcluirExibe")
    v-card(elevation="0", light, align="center", justify="center", width="300")
      v-card-content.pa-4.ma-4
        h5 Deseja Excluir o Defensivos?
      v-card-actions.pa-4(align="center", justify="center")
        v-spacer
        v-btn.mb-2(
          color="success",
          outlined,
          small,
          dark,
          @click="excluirRegistro()"
        )
          | Sim
        v-btn.mb-2(
          color="success",
          outlined,
          small,
          dark,
          @click="cancelaExcluirRegistro()"
        )
          | Não
        v-spacer

  toolbar(
    @update-search="getSearch",
    @menuExec="menuExec",
    :title="toolbarSettings.title",
    :subTitle="toolbarSettings.subTitle",
    :useSearch="toolbarSettings.useSearch",
    :buttons="toolbarSettings.buttons"
  )
</template>

<script>
// Import Components
import compToolBar from "./../../core/components/toolbar";

import { getAllDefensivos, deleteDefensivo } from "../../models/mDefensivos";
import { exportaDados } from "./../../models/mExportacao";

export default {
  components: {
    toolbar: compToolBar,
  },
  data: () => ({
    itemsPerPage: 3000,
    benched: 30,
    heightScroll: window.innerHeight - 115,
    titleArea: "Defensivos",
    search: "",
    toolbarSettings: {
      title: "Defensivos",
      subTitle: "0 Registros",
      useSearch: true,
      buttons: [
        { title: "Grupos", icon: "fas fa-filter", funct: "selectGrupos" },
      ],
    },
    listaRegistrosBackup: [],
    listaRegistros: [],
    headers: [
      { text: "Defensivo", align: "start", value: "nomeComum" },
      { text: "Fabricante", value: "fabricante" },
      { text: "Tóxico", value: "toxico" },
      { text: "SebWeb", value: "secweb" },
      { text: "Diagn.", align: "end", value: "quantDiag" },
      { text: "Prend.", align: "end", value: "quantDiagP" },
      { text: "Info.", align: "end", value: "temInfo" },
      { text: "Ações", align: "end", value: "actions" },
    ],
    msgFiltarExibe: false,
    msgExcluirExibe: false,
    excluirItem: null,
  }),
  mounted() {
    this.buscarDefensivos();
  },
  watch: {
    listaRegistros() {
      this.toolbarSettings.subTitle = this.listaRegistros.length + " Registros";
    },
  },
  methods: {
    getSearch(e) {
      if (e === null) e = "";
      this.search = e;
    },

    menuExec(e) {
      if (e === "selectGrupos") {
        this.selectGrupos();
      }
    },

    exportar() {
      exportaDados();
    },

    async buscarDefensivos(e) {
      const defensivosImport =
        await require("./../../assets/database/json/asecweb.json");
      getAllDefensivos(this.$database)
        .then((data) => {
          data.forEach((r) => {
            const row = defensivosImport.find(
              (d) =>
                d.nomeComum.toLowerCase() == r.nomeComum.toLowerCase() ||
                d.mapa == r.mapa
            );
            if (row) {
              r.secweb = true;
            }
          });

          this.listaRegistrosBackup = data;
          this.listaRegistros = data;
        })
        .then(() => this.filtrar(4));
    },

    msgExcluirDefensivo(item) {
      this.msgExcluirExibe = true;
      this.excluirItem = item;
    },

    copiarNomeDefensivo(item) {
      const el = document.createElement("textarea");
      el.value = item.nomeComum;
      document.body.appendChild(el);
      el.select();
      document.execCommand("copy");
      document.body.removeChild(el);
    },

    excluirRegistro() {
      deleteDefensivo(this.excluirItem).then((data) => {
        if (!data) return false;
        const pos = this.listaRegistrosBackup.findIndex(
          (r) => r.IdReg === this.excluirItem.IdReg
        );
        if (pos >= 0) this.listaRegistrosBackup.splice(pos, 1);
        if (pos >= 0) this.listaRegistros.splice(pos, 1);
      });

      // Aqui vai chamar a função no outro arquivo
      this.excluirItem = null;
      this.msgExcluirExibe = false;
    },

    cancelaExcluirRegistro() {
      this.excluirItem = null;
      this.msgExcluirExibe = false;
    },

    filtrar(valor) {
      let vLR = [];
      const vLRB = this.listaRegistrosBackup;
      switch (valor) {
        case 1:
          vLR = vLRB;
          break;
        case 2:
          vLR = vLRB.filter(
            (r) =>
              r.quantDiag === r.quantDiagP && r.temInfo > 0 && r.quantDiag > 0
          );
          break;
        case 3:
          vLR = vLRB.filter((r) => r.quantDiag === 0 && r.quantDiagP === 0);
          break;
        case 4:
          vLR = vLRB.filter((r) => r.quantDiag !== r.quantDiagP);
          break;
        case 5:
          vLR = vLRB.filter((r) => r.temInfo === 0);
          break;
        default:
          vLR = vLRB;
          break;
      }

      this.listaRegistros = [];
      this.listaRegistros = vLR;
      this.msgFiltarExibe = false;
    },

    selectGrupos() {
      this.msgFiltarExibe = true;
    },
  },
};
</script>
