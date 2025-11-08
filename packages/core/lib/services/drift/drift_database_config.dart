// Conditional exports para suporte multi-plataforma
// Em web, usa WASM. Em mobile/desktop, usa FFI nativo.
// NOTA: Usando dart.library.js_util que é mais estável que dart.library.html
export 'drift_database_config_mobile.dart'
    if (dart.library.js_util) 'drift_database_config_web.dart';
