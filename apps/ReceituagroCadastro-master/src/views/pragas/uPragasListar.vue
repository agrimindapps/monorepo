<template lang="pug">
v-flex.pt-1(align="center", justify="center")
  v-card.mt-1.pa-0(elevation="3")
    v-data-table.elevation-1.pa-2(
      :headers="headers",
      dense,
      :items="listaRegistros",
      :search="search",
      :sort-by="['nomeCientifico']",
      :items-per-page="1500"
    )
      template(slot="top")
        v-toolbar(flat)
          v-spacer
          v-btn.mb-2(color="success", dark, :to="'/pragas/cadastro'")
            v-icon(left) fas fa-plus
            | Novo

      template(v-slot:item.img="{ item }")
        v-icon.mr-2(v-if="item.img !== ''", small, color="grey") fas fa-image

      template(v-slot:item.info="{ item }")
        v-icon.mr-2(v-if="item.info !== ''", small, color="success") far fa-check-circle

      template(v-slot:item.actions="{ item }")
        v-icon.mr-2(small, color="primary", @click="editItem(item)") fas fa-pen

      template(v-slot:item.nomeCientifico="{ item }")
        router-link(:to="item.link") {{ item.nomeCientifico }}

  toolbar(
    @update-search="getSearch",
    :title="toolbarSettings.title",
    :subTitle="toolbarSettings.subTitle",
    :useSearch="toolbarSettings.useSearch",
    :buttons="toolbarSettings.buttons"
  )
</template>

<script>
// Import Components
import compToolBar from "./../../core/components/toolbar";

import { mPragasBuscarTodos } from "./../../models/mPragas.js";

export default {
  components: {
    toolbar: compToolBar,
  },

  data: () => ({
    search: "",
    toolbarSettings: {
      title: "Pragas",
      subTitle: "0 Registros",
      useSearch: true,
      buttons: [],
    },
    listaRegistros: [],
    headers: [
      { text: "Nome Cientifico", value: "nomeCientifico" },
      { text: "Praga", align: "start", value: "nomeComum" },
      { text: "Pseudo Nomes", value: "nomeSecundarios" },
      { text: "Tipo", align: "end", value: "tipoPraga" },
      { text: "Info", align: "end", value: "info" },
      { text: "img", align: "end", value: "img" },
      { text: "Ações", align: "end", value: "actions" },
    ],
  }),
  created() {
    this.BuscaPragas();
  },
  methods: {
    getSearch(e) {
      if (e === null) e = "";
      this.search = e;
    },

    BuscaPragas() {
      mPragasBuscarTodos()
        .then((data) => {
          console.log(data);
          this.listaRegistros = data; //.filter(item => item.tipoPraga === 'Insetos')
          this.toolbarSettings.subTitle =
            this.listaRegistros.length + " Registros";
        })
        .catch((error) => {
          console.log(error);
        });
    },

    editItem(item) {
      this.$router.push({ path: `/pragas/cadastro?id=${item.IdReg}` });
    },
  },
};
</script>
