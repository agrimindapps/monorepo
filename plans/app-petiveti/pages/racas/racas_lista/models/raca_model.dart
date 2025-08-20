class Raca {
  final String nome;
  final String origem;
  final String temperamento;
  final String imagem;
  final List<String> caracteristicas;
  final String tamanho;
  final String pelagem;
  final int nivelEnergia;
  final bool bomParaFamilia;
  final bool bomParaGuarda;

  const Raca({
    required this.nome,
    required this.origem,
    required this.temperamento,
    required this.imagem,
    required this.caracteristicas,
    required this.tamanho,
    required this.pelagem,
    required this.nivelEnergia,
    required this.bomParaFamilia,
    required this.bomParaGuarda,
  });

  factory Raca.fromMap(Map<String, dynamic> map) {
    return Raca(
      nome: map['nome'] ?? '',
      origem: map['origem'] ?? '',
      temperamento: map['temperamento'] ?? '',
      imagem: map['imagem'] ?? '',
      caracteristicas: List<String>.from(map['caracteristicas'] ?? []),
      tamanho: map['tamanho'] ?? 'Médio',
      pelagem: map['pelagem'] ?? 'Não informado',
      nivelEnergia: map['nivelEnergia'] ?? 3,
      bomParaFamilia: map['bomParaFamilia'] ?? true,
      bomParaGuarda: map['bomParaGuarda'] ?? false,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'nome': nome,
      'origem': origem,
      'temperamento': temperamento,
      'imagem': imagem,
      'caracteristicas': caracteristicas,
      'tamanho': tamanho,
      'pelagem': pelagem,
      'nivelEnergia': nivelEnergia,
      'bomParaFamilia': bomParaFamilia,
      'bomParaGuarda': bomParaGuarda,
    };
  }

  bool matchesSearch(String searchText) {
    final search = searchText.toLowerCase();
    return nome.toLowerCase().contains(search) ||
           origem.toLowerCase().contains(search) ||
           temperamento.toLowerCase().contains(search) ||
           caracteristicas.any((c) => c.toLowerCase().contains(search));
  }

  bool matchesFilters({
    List<String> tamanhoFiltros = const [],
    List<String> temperamentoFiltros = const [],
    List<String> cuidadosFiltros = const [],
    List<String> quickFilters = const [],
  }) {
    // Filtro por tamanho
    if (tamanhoFiltros.isNotEmpty && !tamanhoFiltros.contains(tamanho)) {
      return false;
    }

    // Filtro por temperamento
    if (temperamentoFiltros.isNotEmpty) {
      final hasMatchingTemperamento = temperamentoFiltros.any(
        (filtro) => temperamento.toLowerCase().contains(filtro.toLowerCase()),
      );
      if (!hasMatchingTemperamento) return false;
    }

    // Filtros rápidos
    if (quickFilters.isNotEmpty) {
      for (final filter in quickFilters) {
        switch (filter) {
          case 'Guarda':
            if (!bomParaGuarda) return false;
            break;
          case 'Familiar':
            if (!bomParaFamilia) return false;
            break;
          case 'Pequeno':
            if (tamanho != 'Pequeno') return false;
            break;
          case 'Grande':
            if (tamanho != 'Grande') return false;
            break;
          case 'Pelo curto':
            if (!pelagem.toLowerCase().contains('curto')) return false;
            break;
          case 'Pelo longo':
            if (!pelagem.toLowerCase().contains('longo')) return false;
            break;
          case 'Alta energia':
            if (nivelEnergia < 4) return false;
            break;
          case 'Tranquilo':
            if (nivelEnergia > 2) return false;
            break;
        }
      }
    }

    return true;
  }

  List<String> getBadges() {
    final badges = <String>[];
    
    if (bomParaFamilia) badges.add('Familiar');
    if (bomParaGuarda) badges.add('Guarda');
    
    final tempLower = temperamento.toLowerCase();
    if (tempLower.contains('inteligente')) badges.add('Treinável');
    if (tempLower.contains('ativo') || tempLower.contains('energético') || nivelEnergia >= 4) {
      badges.add('Ativo');
    }
    if (tempLower.contains('tranquilo') || nivelEnergia <= 2) {
      badges.add('Calmo');
    }

    return badges;
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is Raca && other.nome == nome;
  }

  @override
  int get hashCode => nome.hashCode;

  @override
  String toString() => 'Raca(nome: $nome, origem: $origem)';
}

class RacaRepository {
  static final List<Raca> _racas = [
    const Raca(
      nome: 'Labrador Retriever',
      origem: 'Canadá',
      temperamento: 'Amigável, Brincalhão, Inteligente',
      imagem: 'lib/app/assets/images/golden_retriever.jpg',
      caracteristicas: ['Amigável', 'Inteligente', 'Ativo'],
      tamanho: 'Grande',
      pelagem: 'Pelo curto',
      nivelEnergia: 4,
      bomParaFamilia: true,
      bomParaGuarda: false,
    ),
    const Raca(
      nome: 'Pastor Alemão',
      origem: 'Alemanha',
      temperamento: 'Leal, Corajoso, Confiante',
      imagem: 'lib/app/assets/images/golden_retriever.jpg',
      caracteristicas: ['Leal', 'Protetor', 'Inteligente'],
      tamanho: 'Grande',
      pelagem: 'Pelo médio',
      nivelEnergia: 4,
      bomParaFamilia: true,
      bomParaGuarda: true,
    ),
    const Raca(
      nome: 'Golden Retriever',
      origem: 'Escócia',
      temperamento: 'Inteligente, Amável, Confiável',
      imagem: 'lib/app/assets/images/golden_retriever.jpg',
      caracteristicas: ['Amigável', 'Inteligente', 'Calmo'],
      tamanho: 'Grande',
      pelagem: 'Pelo longo',
      nivelEnergia: 3,
      bomParaFamilia: true,
      bomParaGuarda: false,
    ),
    const Raca(
      nome: 'Bulldog Francês',
      origem: 'França',
      temperamento: 'Brincalhão, Sociável, Adaptável',
      imagem: 'lib/app/assets/images/golden_retriever.jpg',
      caracteristicas: ['Sociável', 'Tranquilo', 'Adaptável'],
      tamanho: 'Pequeno',
      pelagem: 'Pelo curto',
      nivelEnergia: 2,
      bomParaFamilia: true,
      bomParaGuarda: false,
    ),
    const Raca(
      nome: 'Poodle',
      origem: 'França/Alemanha',
      temperamento: 'Inteligente, Ativo, Alerta',
      imagem: 'lib/app/assets/images/golden_retriever.jpg',
      caracteristicas: ['Inteligente', 'Hipoalergênico', 'Ativo'],
      tamanho: 'Médio',
      pelagem: 'Pelo encaracolado',
      nivelEnergia: 4,
      bomParaFamilia: true,
      bomParaGuarda: false,
    ),
    const Raca(
      nome: 'Rottweiler',
      origem: 'Alemanha',
      temperamento: 'Leal, Protetor, Confiante',
      imagem: 'lib/app/assets/images/golden_retriever.jpg',
      caracteristicas: ['Protetor', 'Leal', 'Forte'],
      tamanho: 'Grande',
      pelagem: 'Pelo curto',
      nivelEnergia: 3,
      bomParaFamilia: true,
      bomParaGuarda: true,
    ),
    const Raca(
      nome: 'Yorkshire Terrier',
      origem: 'Inglaterra',
      temperamento: 'Corajoso, Independente, Esperto',
      imagem: 'lib/app/assets/images/golden_retriever.jpg',
      caracteristicas: ['Pequeno', 'Corajoso', 'Alerta'],
      tamanho: 'Pequeno',
      pelagem: 'Pelo longo',
      nivelEnergia: 3,
      bomParaFamilia: true,
      bomParaGuarda: true,
    ),
    const Raca(
      nome: 'Husky Siberiano',
      origem: 'Sibéria',
      temperamento: 'Amigável, Alerta, Energético',
      imagem: 'lib/app/assets/images/golden_retriever.jpg',
      caracteristicas: ['Energético', 'Independente', 'Resistente'],
      tamanho: 'Grande',
      pelagem: 'Pelo médio',
      nivelEnergia: 5,
      bomParaFamilia: true,
      bomParaGuarda: false,
    ),
  ];

  static List<Raca> getTodas() => List.unmodifiable(_racas);

  static List<Raca> filter({
    String searchText = '',
    List<String> tamanhoFiltros = const [],
    List<String> temperamentoFiltros = const [],
    List<String> cuidadosFiltros = const [],
    List<String> quickFilters = const [],
  }) {
    return _racas.where((raca) {
      final matchesSearch = searchText.isEmpty || raca.matchesSearch(searchText);
      final matchesFilters = raca.matchesFilters(
        tamanhoFiltros: tamanhoFiltros,
        temperamentoFiltros: temperamentoFiltros,
        cuidadosFiltros: cuidadosFiltros,
        quickFilters: quickFilters,
      );
      return matchesSearch && matchesFilters;
    }).toList();
  }

  static Raca? getRacaPorNome(String nome) {
    try {
      return _racas.firstWhere((raca) => raca.nome == nome);
    } catch (e) {
      return null;
    }
  }
}