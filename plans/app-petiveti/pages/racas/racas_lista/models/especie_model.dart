class Especie {
  final String nome;
  final String imagemPath;
  final String imagemHeader;
  final String descricao;
  final String nomeCompleto;
  final int totalRacas;

  const Especie({
    required this.nome,
    required this.imagemPath,
    required this.imagemHeader,
    required this.descricao,
    required this.nomeCompleto,
    required this.totalRacas,
  });

  factory Especie.fromMap(Map<String, dynamic> map) {
    return Especie(
      nome: map['especie'] ?? map['nome'] ?? 'Espécie',
      imagemPath: map['imagePath'] ?? map['imagemPath'] ?? '',
      imagemHeader: map['imagemHeader'] ?? map['imagemPath'] ?? '',
      descricao: map['descricao'] ?? 'Descrição não disponível',
      nomeCompleto: map['nomeCompleto'] ?? map['especie'] ?? map['nome'] ?? 'Espécie',
      totalRacas: map['totalRacas'] ?? 0,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'nome': nome,
      'imagePath': imagemPath,
      'imagemHeader': imagemHeader,
      'descricao': descricao,
      'nomeCompleto': nomeCompleto,
      'totalRacas': totalRacas,
    };
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is Especie && other.nome == nome;
  }

  @override
  int get hashCode => nome.hashCode;

  @override
  String toString() => 'Especie(nome: $nome, totalRacas: $totalRacas)';
}

class EspecieRepository {
  static final Map<String, Especie> _especies = {
    'Cachorros': const Especie(
      nome: 'Cachorros',
      imagemPath: 'lib/app/assets/images/golden_retriever.jpg',
      imagemHeader: 'lib/app/assets/images/golden_retriever.jpg',
      descricao: 'O cão (Canis lupus familiaris) é um mamífero carnívoro domesticado da família dos canídeos, subespécie do lobo.',
      nomeCompleto: 'Canis lupus familiaris',
      totalRacas: 8,
    ),
    'Gatos': const Especie(
      nome: 'Gatos',
      imagemPath: 'lib/app/assets/images/cat.jpg',
      imagemHeader: 'lib/app/assets/images/cat_header.jpg',
      descricao: 'O gato doméstico (Felis catus) é um pequeno mamífero carnívoro domesticado da família dos felídeos.',
      nomeCompleto: 'Felis catus',
      totalRacas: 0,
    ),
    'Pássaros': const Especie(
      nome: 'Pássaros',
      imagemPath: 'lib/app/assets/images/bird.jpg',
      imagemHeader: 'lib/app/assets/images/bird_header.jpg',
      descricao: 'As aves são animais vertebrados, ovíparos, que possuem o corpo revestido de penas.',
      nomeCompleto: 'Aves',
      totalRacas: 0,
    ),
  };

  static Especie? getEspecie(String nome) {
    return _especies[nome];
  }

  static Especie getEspecieOrDefault(String nome) {
    return _especies[nome] ?? _getDefaultEspecie(nome);
  }

  static Especie _getDefaultEspecie(String nome) {
    return Especie(
      nome: nome,
      imagemPath: 'lib/app/assets/images/default_pet.jpg',
      imagemHeader: 'lib/app/assets/images/default_pet.jpg',
      descricao: 'Informações sobre esta espécie não estão disponíveis no momento.',
      nomeCompleto: nome,
      totalRacas: 0,
    );
  }

  static List<String> getEspeciesDisponiveis() {
    return _especies.keys.toList();
  }

  static void atualizarTotalRacas(String nomeEspecie, int total) {
    final especie = _especies[nomeEspecie];
    if (especie != null) {
      _especies[nomeEspecie] = Especie(
        nome: especie.nome,
        imagemPath: especie.imagemPath,
        imagemHeader: especie.imagemHeader,
        descricao: especie.descricao,
        nomeCompleto: especie.nomeCompleto,
        totalRacas: total,
      );
    }
  }
}