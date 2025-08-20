// Flutter imports:
import 'package:flutter/material.dart';

class EspecieSeletor {
  final String nome;
  final String imagem;
  final String descricao;
  final int totalRacas;
  final IconData icone;

  const EspecieSeletor({
    required this.nome,
    required this.imagem,
    required this.descricao,
    required this.totalRacas,
    required this.icone,
  });

  factory EspecieSeletor.fromMap(Map<String, dynamic> map) {
    return EspecieSeletor(
      nome: map['nome'] ?? '',
      imagem: map['imagem'] ?? '',
      descricao: map['descricao'] ?? '',
      totalRacas: map['totalRacas'] ?? 0,
      icone: map['icone'] ?? Icons.pets,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'nome': nome,
      'imagem': imagem,
      'descricao': descricao,
      'totalRacas': totalRacas,
      'icone': icone,
    };
  }

  String get racasText => totalRacas == 1 ? '1 raça' : '$totalRacas raças';

  bool get hasRacas => totalRacas > 0;

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is EspecieSeletor && other.nome == nome;
  }

  @override
  int get hashCode => nome.hashCode;

  @override
  String toString() => 'EspecieSeletor(nome: $nome, totalRacas: $totalRacas)';
}

class EspecieSeletorRepository {
  static final List<EspecieSeletor> _especies = [
    const EspecieSeletor(
      nome: 'Cachorros',
      imagem: 'lib/app/assets/images/golden_retriever.jpg',
      descricao: 'Do companheiro leal às raças de trabalho especializadas',
      totalRacas: 187,
      icone: Icons.pets,
    ),
    const EspecieSeletor(
      nome: 'Gatos',
      imagem: 'lib/app/assets/images/gato.jpg',
      descricao: 'Elegantes e independentes, com personalidades únicas',
      totalRacas: 71,
      icone: Icons.emoji_nature,
    ),
    const EspecieSeletor(
      nome: 'Coelhos',
      imagem: 'lib/app/assets/images/coelho.jpg',
      descricao: 'Pequenos herbívoros adoráveis e cheios de energia',
      totalRacas: 23,
      icone: Icons.cruelty_free,
    ),
    const EspecieSeletor(
      nome: 'Cobras',
      imagem: 'lib/app/assets/images/cobra.jpg',
      descricao: 'Répteis fascinantes com adaptações incríveis',
      totalRacas: 45,
      icone: Icons.animation,
    ),
    const EspecieSeletor(
      nome: 'Aranhas',
      imagem: 'lib/app/assets/images/aranha.jpg',
      descricao: 'Invertebrados diversos, desde pequenos a tamanturelas',
      totalRacas: 32,
      icone: Icons.bug_report,
    ),
    const EspecieSeletor(
      nome: 'Peixes',
      imagem: 'lib/app/assets/images/peixe.jpg',
      descricao: 'Vida aquática colorida com diversas necessidades',
      totalRacas: 89,
      icone: Icons.water,
    ),
  ];

  static List<EspecieSeletor> getTodas() => List.unmodifiable(_especies);

  static List<EspecieSeletor> getComRacas() {
    return _especies.where((especie) => especie.hasRacas).toList();
  }

  static EspecieSeletor? getEspeciePorNome(String nome) {
    try {
      return _especies.firstWhere((especie) => especie.nome == nome);
    } catch (e) {
      return null;
    }
  }

  static List<EspecieSeletor> getPopulares({int limite = 3}) {
    final especiesOrdenadas = List<EspecieSeletor>.from(_especies);
    especiesOrdenadas.sort((a, b) => b.totalRacas.compareTo(a.totalRacas));
    return especiesOrdenadas.take(limite).toList();
  }

  static int getTotalRacasGeral() {
    return _especies.fold(0, (total, especie) => total + especie.totalRacas);
  }

  static Map<String, int> getEstatisticas() {
    return {
      'totalEspecies': _especies.length,
      'totalRacas': getTotalRacasGeral(),
      'especiesComRacas': getComRacas().length,
    };
  }

  static IconData getIconePorNome(String nome) {
    final especie = getEspeciePorNome(nome);
    return especie?.icone ?? Icons.pets;
  }

  static String getDescricaoPorNome(String nome) {
    final especie = getEspeciePorNome(nome);
    return especie?.descricao ?? 'Explore as diferentes raças e características';
  }

  static void atualizarTotalRacas(String nomeEspecie, int novoTotal) {
    final index = _especies.indexWhere((e) => e.nome == nomeEspecie);
    if (index != -1) {
      _especies[index] = EspecieSeletor(
        nome: _especies[index].nome,
        imagem: _especies[index].imagem,
        descricao: _especies[index].descricao,
        totalRacas: novoTotal,
        icone: _especies[index].icone,
      );
    }
  }
}
