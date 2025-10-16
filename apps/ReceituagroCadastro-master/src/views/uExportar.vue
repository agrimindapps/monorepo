<template lang="pug">
v-layout.mx-auto.pt-1.mt-2(align="center", justify="center")
  v-card.mx-auto
    v-list.elevation-3.ma-0.pa-0(two-line)
      v-divider
      v-list-item(@click="backupcsv")
        v-list-item-icon
          v-icon(color="success") fas fa-file-download
        v-list-item-content
          v-list-item-title Backup CSV
          v-list-item-subtitle.pt-2 Exporta todo o banco de dados em formato CSV sem filtragem dos dados.

      v-divider
      v-list-item(@click="backup")
        v-list-item-icon
          v-icon(color="success") fas fa-file-download
        v-list-item-content
          v-list-item-title Backup
          v-list-item-subtitle.pt-2 Exporta todo o banco de dados em formato JSON sem filtragem dos dados.

      v-divider
      v-list-item(@click="exportar")
        v-list-item-icon
          v-icon(color="gray") fas fa-file-download
        v-list-item-content
          v-list-item-title Exportação
          v-list-item-subtitle.pt-2 Exporta apenas os registros que possuem as informações corretas para uso de clientes.

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
import compToolBar from "./../core/components/toolbar";

import {
  exportaDados,
  backupDados,
  backupDadosCSV,
} from "./../models/mExportacao";

export default {
  components: {
    toolbar: compToolBar,
  },

  data() {
    return {
      search: "",
      toolbarSettings: {
        title: "Exportação e Backup",
        subTitle: "",
        useSearch: false,
        buttons: [],
      },
    };
  },

  watch: {
    search() {
      this.filter();
    },
  },

  methods: {
    getSearch(e) {
      if (e === null) e = "";
      this.search = e;
    },
    menuExec(e) {
      if (e === "marcarFavorito") this.marcarFavorito();
    },

    exportar() {
      exportaDados();
    },

    backup() {
      backupDados();
    },

    backupcsv() {
      backupDadosCSV();
    },
  },
};
</script>
