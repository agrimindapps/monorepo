module.exports = {
  transpileDependencies: [
    'vuetify'
  ],
  lintOnSave: false,
  devServer: {
    https: false,
    port: 8010,
    host: '127.0.0.1',
    hotOnly: false
  },
  publicPath: '',
  pluginOptions: {
    cordovaPath: 'cordova'
  }
}
