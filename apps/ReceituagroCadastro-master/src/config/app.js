module.exports = {
  title: 'Receituagro',
  shortTitle: 'Receituagro',
  prefixApp: 'CompendioAgrimind',
  appVersion: '76',
  androidVersion: '76',
  description: 'Aplicativo para consulta de pragas e defensivos na agricultura',
  url: 'https://agrimindapps.com',
  icon: 'assets/icon.png',
  iconSize: 256,
  androidAppId: 'br.com.agrimind.pragassoja',
  author: 'Agrimind Apps',
  email: 'contato@agrimindapps.com',
  usaLogin: true,
  googleAnalyticsKey: 'UA-114956450-1',
  menuPrincipal: [
    {
      name: 'Cadastro',
      menus: [
        { text: 'Defensivos', icon: 'fas fa-tractor', link: '/defensivoslistar' },
        { text: 'Pragas', icon: 'fa-solid fa-bug', link: '/pragas/listar' },
        { text: 'Culturas', icon: 'fa-solid fa-bug', link: '/culturas' }
      ]
    },
    {
      name: 'Ferramentas',
      menus: [
        { text: 'WebScraping', icon: 'fa-solid fa-bug', link: '/defensivosimportacao' },
        { text: 'Padronização', icon: 'fa-solid fa-bug', link: '/defensivoslistar' },
        { text: 'Exportar', icon: 'fa-solid fa-bug', link: '/exportacao' }
      ]
    }
  ],
  menuSubOpcoes: [
    // { text: 'Sincronizar', icon: 'fas fa-sync-alt', color: 'primary', link: '/premium', funct: '' }
    // { text: 'Sobre', icon: 'bug_report', color: 'primary', link: '/sobre' },
    // { text: 'Usuário', icon: 'bug_report', color: 'primary', link: '/sobre' }
  ],
  payments: {
    productDetails: [
      { id: 'q8Tz', productId: 'receituagro_ass_anual', desc: 'Assinatura Anual', valueId: 31536000, price: 'R$ 29,99' },
      { id: 'p9Zd', productId: 'receituagro_ass_semestral', desc: 'Assinatura Semestral', valueId: 15768000, price: 'R$ 15,99' },
      { id: 'W4p0', productId: 'receituagro_ass_mensal2', desc: 'Assinatura Mensal', valueId: 2628000, price: 'R$ 2,89' }
    ],
    productIds: ['receituagro_ass_anual', 'receituagro_ass_semestral', 'receituagro_ass_mensal2'],
    vantagens: [
      { img: 'sem_anuncio.png', title: 'Sem Anuncios', desc: 'Remova a publicidade e tenha um experiencia de uso aprimorada sem interrupções.' },
      { img: 'novidades.png', title: 'Conteúdo Exclusivo', desc: 'Acesso a informações de aplicação e instruções de uso dos defensivos agrícolas' },
      { img: 'compartilhe.png', title: 'Compartilhe', desc: 'Compartilhe as informações de pragas, produtos e diagnostico com seus contatos' },
      { img: 'colaborar.png', title: 'Colaboração', desc: 'Ajude na manutenção de info. de defenvisos e desenvolvimento do aplicativo.' }
    ],
    termosUso: {
      link: 'http://agrimindapps.com/?page_id=616',
      google: `O Receituagro será renovado automaticamente dentro de 24 horas anes do término 
      do periodo da assinatura e você será cobrado por meio da sua conta Google Play. Você pode gerenciar
      sua assinatura pelo Google Play na opção de Assinaturas.`,
      apple: `A assinatura do Receituagro renovara automaticamente 24 horas antes do término
      do período e você será cobrado através de sua conta do iTuens. O valor da assinatura atual não 
      pode ser devolvida e o serviço não pode ser interrompido em caso de desistencia durante o período 
      de vigencia. Sua assinatura pode ser gerenciada através das Configurações de conta do Itunes.`
    }
  },
  admob: {
    isTesting: true,
    android: {
      banner: '',
      interstitial: ''
    },
    ios: {
      banner: '',
      interstitial: ''
    }
  },
  lang: null,
  firebase: {
    useFirebase: true,
    apiKey: 'AIzaSyAKo5dxVHE2JJTGJYBcvBzA8u5NOf9XQQk',
    authDomain: 'receituagronew.firebaseapp.com',
    databaseURL: 'https://receituagronew-default-rtdb.firebaseio.com',
    projectId: 'receituagronew',
    storageBucket: 'receituagronew.appspot.com',
    messagingSenderId: '317022121600',
    appId: '1:317022121600:web:7aeee74494de46f3ba4065',
    measurementId: 'G-ZH7Y19K0QW'
  },
  atualizacoes: [
    { versao: '2021.10.08', notas: '' }
  ]
}
