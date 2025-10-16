import Vue from 'vue'
import VueRouter from 'vue-router'

Vue.use(VueRouter)

const routes = [
  {
    path: '',
    name: 'home',
    component: () => import(/* webpackChunkName: "about" */ './../views/defensivos/uDefensivoListar')
  },
  {
    path: '/index.html',
    name: 'home2',
    component: () => import(/* webpackChunkName: "about" */ './../views/defensivos/uDefensivoListar')
  },
  {
    path: '/login',
    name: 'login',
    component: () => import(/* webpackChunkName: "about" */ './../core/views/uLogin.vue')
  },
  // Defensivos
  // {
  //   path: '/defensivosimportar',
  //   name: 'importardefensivos',
  //   component: () => import(/* webpackChunkName: "about" */ './../views/defensivos/uDefensivosImportacao'),
  //   props: route => ({ tipo: route.query.tipo, id: route.query.id })
  // },
  {
    path: '/defensivoslistar',
    name: 'defensivostipo',
    component: () => import(/* webpackChunkName: "about" */ './../views/defensivos/uDefensivoListar'),
    props: route => ({ tipo: route.query.tipo, id: route.query.id })
  },
  {
    path: '/defensivoscadastro',
    name: 'cadastroDefensivo',
    component: () => import(/* webpackChunkName: "about" */ './../views/defensivos/uDefensivoCadastro'),
    props: route => ({ id: route.query.id })
  },
  {
    path: '/defensivosimportacao',
    name: 'importacaoDefensivo',
    component: () => import(/* webpackChunkName: "about" */ './../views/defensivos/uDefensivosImportacao')
  },
  // Pragas
  {
    path: '/pragas/listar',
    name: 'pragas',
    component: () => import(/* webpackChunkName: "about" */ './../views/pragas/uPragasListar'),
    props: route => ({ tipo: route.query.tipo })
  },
  {
    path: '/pragas/cadastro',
    name: 'pragasCadastro',
    component: () => import(/* webpackChunkName: "about" */ './../views/pragas/uPragasCad'),
    props: route => ({ tipo: route.query.id })
  },
  {
    path: '/culturas',
    name: 'culturas',
    component: () => import(/* webpackChunkName: "about" */ './../views/culturas/uCulturasListar')
  },
  {
    path: '/exportacao',
    name: 'exportacao',
    component: () => import(/* webpackChunkName: "about" */ './../views/uExportar.vue')
  }
]

const router = new VueRouter({
  mode: 'hash',
  base: process.env.BASE_URL,
  routes
})

// router.beforeEach((to, from, next) => {
//   if (!window.uid && to.name !== 'login') {
//     next({ name: 'login' })
//   } else {
//     next()
//   }
// })

export default router
