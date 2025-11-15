/// Application-wide constants
class AppConstants {
  AppConstants._();

  // Storage Keys
  static const String favoritosKey = 'favoritos';
  static const String categoriaKey = 'categoria';
  static const String themeKey = 'theme_mode';
  static const String ttsSettingsKey = 'tts_settings';


  // App Info
  static const String appName = 'Termos Técnicos';
  static const String appDescription = 'Dicionário de Termos Técnicos';

  // Categorias
  static const List<Map<String, dynamic>> categorias = [
    {
      'id': 1,
      'descricao': 'Administracao',
      'keytermo': 'tbadministracao',
      'keydecripy': 'dicionarioadministracao',
      'image': 'assets/icons_app/icon_administracao.png'
    },
    {
      'id': 2,
      'descricao': 'Agricultura',
      'keytermo': 'tbagricultura',
      'keydecripy': 'dicionarioagricultura',
      'image': 'assets/icons_app/icon_agricultura.png'
    },
    {
      'id': 3,
      'descricao': 'Arquitetura',
      'keytermo': 'tbarquitetura',
      'keydecripy': 'dicionarioarquitetura',
      'image': 'assets/icons_app/icon_arquitetura.png'
    },
    {
      'id': 4,
      'descricao': 'Biologia',
      'keytermo': 'tbbiologia',
      'keydecripy': 'dicionariobiologia',
      'image': 'assets/icons_app/icon_biologia.png'
    },
    {
      'id': 5,
      'descricao': 'Direito',
      'keytermo': 'tbdireito',
      'keydecripy': 'dicionariodireito',
      'image': 'assets/icons_app/icon_direito.png'
    },
    {
      'id': 6,
      'descricao': 'Economia',
      'keytermo': 'tbeconomia',
      'keydecripy': 'dicionariocontabil',
      'image': 'assets/icons_app/icon_economia.png'
    },
    {
      'id': 7,
      'descricao': 'Fisica',
      'keytermo': 'tbfisica',
      'keydecripy': 'dicionariofisica',
      'image': 'assets/icons_app/icon_fisica.png'
    },
    {
      'id': 8,
      'descricao': 'Geografia',
      'keytermo': 'tbgeografia',
      'keydecripy': 'dicionariogeografia',
      'image': 'assets/icons_app/icon_geografia.png'
    },
    {
      'id': 9,
      'descricao': 'Informatica',
      'keytermo': 'tbinformatica',
      'keydecripy': 'dicionarioinformatica',
      'image': 'assets/icons_app/icon_informatica.png'
    },
    {
      'id': 10,
      'descricao': 'Matematica',
      'keytermo': 'tbmatemamitca',
      'keydecripy': 'dicionariomatematica',
      'image': 'assets/icons_app/icon_matematica.png'
    },
    {
      'id': 11,
      'descricao': 'Medicina',
      'keytermo': 'tbmedicina',
      'keydecripy': 'dicionariomedico',
      'image': 'assets/icons_app/icon_medicina.png'
    },
    {
      'id': 12,
      'descricao': 'Quimica',
      'keytermo': 'tbquimica',
      'keydecripy': 'dicionarioquimica',
      'image': 'assets/icons_app/icon_quimica.png'
    },
  ];
}
