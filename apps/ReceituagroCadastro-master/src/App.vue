<template lang="pug">

v-app(style="background: #f3f3f3")

  v-navigation-drawer(v-if="sitemaVisivel" v-model="menuVisivel" app style="background: #f3f3f3")
    uMenuLateral

  v-main(v-if="sitemaVisivel"  :class="'mt-9 ml-2 mr-2'" app fluid style="border-top: 1px solid #f3f3f3")
    router-view(:class="variavelTop")

  uInicialize

  uLogin(v-if="!sitemaVisivel" v-show="loginVisivel")

</template>

<script>

import { getAuth, onAuthStateChanged } from 'firebase/auth'

import uMenuLateral from './core/components/uMenuLateral'
import config from './config/app'
import uInicialize from './core/views/uInicialize'
import eruda from 'eruda'

import uLogin from './core/views/uLogin'

export default {
  name: 'App',
  components: {
    uMenuLateral,
    uInicialize,
    uLogin
  },
  data: () => ({
    menuVisivel: false,
    sitemaVisivel: false,
    loginVisivel: false,
    variavelTop: 'pt-8'
  }),
  mounted () {
    const auth = getAuth()
    onAuthStateChanged(auth, user => {
      window.uid = user ? user.uid : null
      if (window.uid) {
        this.sitemaVisivel = true
      } else {
        this.loginVisivel = true
      }
    })

    if (window.innerWidth < 960) { this.variavelTop = 'pt-6' } else { this.variavelTop = 'pt-8' }

    if (typeof (cordova) !== 'undefined' && config.admob.isTesting) {
      const el = document.createElement('div')
      document.body.appendChild(el)

      eruda.init({
        container: el,
        tool: ['console', 'elements', 'network', 'resources', 'info', 'snippets', 'sources'],
        useShadowDom: false,
        autoScale: false,
        defaults: {
          displaySize: 50,
          transparency: '1.0',
          theme: 'Monokai Pro'
        }
      })
    }
  },
  created () {
    // -> Gambiarra Alternativa para atualização banco de dados
    localStorage[config.prefixApp + '/dbBloqueado'] = 'true'

    // -> Criação do controle do menu lateral, feito via localStorage
    localStorage[config.prefixApp + '/sitMenu'] = JSON.stringify({
      visivel: false,
      urlCarregaApp: window.location.href
    })

    window.setInterval(() => {
      const varMenu = JSON.parse(localStorage[config.prefixApp + '/sitMenu'])
      if (window.innerWidth < 1264) {
        if ((varMenu.urlCarregaApp === window.location.href || window.location.href === window.location.origin + '/') && varMenu.visivel) {
          this.menuVisivel = varMenu.visivel
          varMenu.visivel = !varMenu.visivel
          localStorage[config.prefixApp + '/sitMenu'] = JSON.stringify(varMenu)
        }
      } else {
        this.menuVisivel = true
      }
    }, 50)
  },
  methods: {
    clickmenu: function () {
      if (this.urlBegin === window.location.href || window.location.href === window.location.origin + '/') { this.menuVisivelr = !this.menuVisivelr } else { window.history.back() }
    },
    onDeviceReady: function () {
      if (this.cordova.device.platform === 'Android') {
        document.addEventListener('backbutton', this.onBackButton, false)
      }
    },
    onBackButton () {
      // Handle the back-button event on Android.
      this.clickmenu()
    },
    exitApp () {
      // By default it will exit the app.
      navigator.app.exitApp()
    }
  }
}
</script>
