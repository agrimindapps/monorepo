import 'package:flutter/services.dart';
import 'package:share_plus/share_plus.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../core/models/database.dart';
import '../../core/services/localstorage_service.dart';
import '../classes/termo_class.dart';

class TermosTecnicos {
  static final TermosTecnicos _instance = TermosTecnicos._internal();

  TermosTecnicos._internal();

  factory TermosTecnicos() {
    return _instance;
  }

  List<Termo> listaTermos = [];

  Future<void> carregaTermos() async {
    Database db = Database();
    List<String> favoritos = await localStorage.getFavoritos('favoritos');
    List<Termo> preListaTermos = [];

    // Obter todas as categorias
    List<dynamic> categorias = getCategorias();

    // Iterar sobre cada categoria para carregar os termos
    for (var categoria in categorias) {
      String keyTermo = categoria['keytermo'];
      String keyDecripy = categoria['keydecripy'];
      List<dynamic> data = await db.getAll(keyTermo);

      // Aplicar lógica de decifração e favoritos para cada termo
      for (var row in data) {
        Termo termo = Termo(
          id: row['id'],
          termo: row['termo'],
          descricao: db.dbDeCrypt(row['descricao'], keyDecripy),
          categoria: categoria['descricao'],
          favorito: favoritos.contains(row['id']),
        );

        // Concatenar os termos desta categoria aos termos totais
        preListaTermos.add(termo);
      }
    }

    listaTermos = preListaTermos;
  }

  Future<bool> setFavorito(String id) async {
    return await localStorage.setFavorito('favoritos', id);
  }

  Future<bool> validFavorito(String id) async {
    return await localStorage.validFavorito('favoritos', id);
  }

  Future<void> setCategoria(Map<String, dynamic> data) async {
    await localStorage.adicionar('categoria', data);
  }

  Future<Map<String, dynamic>> getCategoria() async {
    Map<String, dynamic> data = await localStorage.carregar('categoria');
    if (data.isEmpty) {
      setCategoria(getCategorias()[0]);
      data = await localStorage.carregar('categoria');
    }
    return data;
  }

  void compartilhar(Termo item) {
    StringBuffer buffer = StringBuffer();
    buffer.writeln(item.termo);
    buffer.writeln(item.descricao);
    buffer.writeln();
    buffer.writeln('App Termos Técnicos - Agrimind Soluções');

    String texto = buffer.toString();
    Share.share(texto, subject: item.termo);
  }

  void abrirExterno(Termo item) async {
    String link = 'https://www.google.com/search?q=${item.termo}';
    final Uri url = Uri.parse(link);
    if (!await launchUrl(url)) {
      throw Exception('Could not launch $url');
    }
  }

  void copiarTexto(Termo item) {
    StringBuffer buffer = StringBuffer();
    buffer.writeln(item.termo);
    buffer.writeln(item.descricao);
    buffer.writeln();
    buffer.writeln('App Termos Técnicos - Agrimind Soluções');

    Clipboard.setData(ClipboardData(text: buffer.toString()));
  }

  List<dynamic> getCategorias() {
    return [
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
}
