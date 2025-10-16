<template lang="pug">
v-flex.pt-1.mt-2(align="left", justify="left")
  v-card.pa-2
    v-data-table.elevation-0(
      :headers="headers",
      dense,
      :items="listaRegistros",
      :search="search",
      :sort-by="['nomeComum']",
      :items-per-page="300",
      to="#"
    )
      template(v-slot:item.actions="{ item }")
        td.jusfify-left
          v-icon(
            v-if="item.flag === 'sitExclusao'",
            color="red",
            small,
            @click="deleteItem(item)"
          ) fas fa-trash
          v-icon(
            v-if="item.flag === 'sitCadastro'",
            color="blue",
            small,
            @click="cadastraItem(item)"
          ) fas fa-plus
          v-icon(v-if="item.flag === 'sitNormal'", color="green", small) fas fa-check
          v-icon.ml-4(color="cyan", small, @click="copyText(item)") fas fa-copy
          v-icon.ml-4(color="blue", small, @click="openExternal(item)") fa-solid fa-link

      template(v-slot:item.nomeComum="{ item }")
        router-link(v-if="item.link !== undefined", :to="item.link") {{ item.nomeComum }}
        td(v-else) {{ item.nomeComum }}

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

import {
  getAllDefensivosSimples,
  deleteDefensivo,
} from "../../models/mDefensivos";

export default {
  components: {
    toolbar: compToolBar,
  },
  data() {
    return {
      search: "",
      toolbarSettings: {
        title: "WebScraping",
        subTitle: "Total de Registros",
        useSearch: true,
        buttons: [],
      },
      listaRegistros: [],
      defensivosDatabase: [],
      defensivosImport: [],
      // defensivosAtivos: [],
      // defensivosPCadastro: [],
      situacao: {
        cadastrar: 0,
        normal: 0,
        excluir: 0,
      },
      headers: [
        { text: "Defensivo", align: "start", value: "nomeComum" },
        { text: "Fabricante", value: "fabricante" },
        { text: "Tóxico", value: "toxico" },
        { text: "Status", value: "flag" },
        { text: "Ações", align: "center", value: "actions" },
      ],
    };
  },
  mounted() {
    this.carregaDefensivos();
  },
  watch: {
    search() {
      this.filter();
    },
    defensivosDatabase() {},
  },
  methods: {
    getSearch(e) {
      if (e === null) e = "";
      this.search = e;
    },
    menuExec(e) {
      if (e === "marcarFavorito") this.marcarFavorito();
    },
    async openExternal(e) {
      window.open(e.linklocal, "_parent");
      // javascript pause 1000 ms
      await new Promise((resolve) => setTimeout(resolve, 1000));
      window.open(e.link, "_blank");
    },

    async carregaDefensivos() {
      const defensivosImport =
        await require("./../../assets/database/json/agrolink.json");
      const defensivosDatabase = await getAllDefensivosSimples().then(
        (data) => data
      );

      const nL = [];

      defensivosImport.forEach((row) => {
        const row2 = defensivosDatabase.find(
          (r) =>
            r.nomeComum.trim().toLowerCase() ==
            row.nomeComum.trim().toLowerCase()
        );

        if (!row2) {
          row.flag = "sitCadastro";
          this.situacao.cadastrar++;
          nL.push(row);
        } else {
          row2.flag = "sitNormal";
          this.situacao.normal++;
          nL.push({ ...row2, ...row });
        }
      });

      defensivosDatabase.forEach((row) => {
        const row2 = defensivosImport.find(
          (r) =>
            r.nomeComum.trim().toLowerCase() ===
            row.nomeComum.trim().toLowerCase()
        );
        if (!row2) {
          row.flag = "sitExclusao";
          this.situacao.excluir++;
          nL.push(row);
        }
      });

      this.listaRegistros = nL;
      this.toolbarSettings.subTitle =
        this.situacao.cadastrar +
        " cadastro / " +
        this.situacao.normal +
        " normal / " +
        this.situacao.excluir +
        " excluir";

      this.defensivosDatabase = defensivosDatabase;
      this.defensivosImport = defensivosImport;
    },

    deleteItem(item) {
      if (item.quantDiagnosticos > 0) {
        console.warn("Não pode excluir, tem diagnosticos");
        return;
      }
      deleteDefensivo(item).then((data) => {
        for (let x = 0; x < this.listaRegistros.length; x++) {
          if (this.listaRegistros[x].IdReg === item.IdReg)
            this.listaRegistros.splice(x, 1);
        }
      });
    },

    cadastraItem(item) {
      localStorage.setItem("tempCadastro", JSON.stringify(item));
      this.$router.push({ path: "/defensivoscadastro?id=x" });
    },

    copyText(item) {
      navigator.clipboard.writeText(item.nomeComum);
    },
  },
};
</script>
