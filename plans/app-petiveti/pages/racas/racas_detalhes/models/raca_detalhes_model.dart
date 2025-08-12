class RacaDetalhes {
  final String nome;
  final String origem;
  final String altura;
  final String peso;
  final String expectativaVida;
  final String grupo;
  final String temperamento;
  final String saude;
  final String cuidados;
  final String treinamento;
  final String imagemPrincipal;
  final List<String> galeria;
  final Map<String, int> caracteristicas;
  final List<RacaRelacionada> racasRelacionadas;
  final ConsultaVeterinaria consultaInfo;

  const RacaDetalhes({
    required this.nome,
    required this.origem,
    required this.altura,
    required this.peso,
    required this.expectativaVida,
    required this.grupo,
    required this.temperamento,
    required this.saude,
    required this.cuidados,
    required this.treinamento,
    required this.imagemPrincipal,
    required this.galeria,
    required this.caracteristicas,
    required this.racasRelacionadas,
    required this.consultaInfo,
  });

  factory RacaDetalhes.fromMap(Map<String, dynamic> map) {
    return RacaDetalhes(
      nome: map['nome'] ?? 'Raça Desconhecida',
      origem: map['origem'] ?? 'Origem desconhecida',
      altura: map['altura'] ?? 'Não informado',
      peso: map['peso'] ?? 'Não informado',
      expectativaVida: map['expectativaVida'] ?? 'Não informado',
      grupo: map['grupo'] ?? 'Não classificado',
      temperamento: map['temperamento'] ?? 'Informações não disponíveis',
      saude: map['saude'] ?? 'Consulte um veterinário',
      cuidados: map['cuidados'] ?? 'Cuidados básicos necessários',
      treinamento: map['treinamento'] ?? 'Necessita de treinamento adequado',
      imagemPrincipal: map['imagemPrincipal'] ?? 'assets/images/default_dog.jpg',
      galeria: List<String>.from(map['galeria'] ?? []),
      caracteristicas: Map<String, int>.from(map['caracteristicas'] ?? {}),
      racasRelacionadas: (map['racasRelacionadas'] as List<dynamic>?)
          ?.map((e) => RacaRelacionada.fromMap(e))
          .toList() ?? [],
      consultaInfo: ConsultaVeterinaria.fromMap(map['consultaInfo'] ?? {}),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'nome': nome,
      'origem': origem,
      'altura': altura,
      'peso': peso,
      'expectativaVida': expectativaVida,
      'grupo': grupo,
      'temperamento': temperamento,
      'saude': saude,
      'cuidados': cuidados,
      'treinamento': treinamento,
      'imagemPrincipal': imagemPrincipal,
      'galeria': galeria,
      'caracteristicas': caracteristicas,
      'racasRelacionadas': racasRelacionadas.map((e) => e.toMap()).toList(),
      'consultaInfo': consultaInfo.toMap(),
    };
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is RacaDetalhes && other.nome == nome;
  }

  @override
  int get hashCode => nome.hashCode;

  @override
  String toString() => 'RacaDetalhes(nome: $nome, origem: $origem)';
}

class RacaRelacionada {
  final String nome;
  final String imagem;

  const RacaRelacionada({
    required this.nome,
    required this.imagem,
  });

  factory RacaRelacionada.fromMap(Map<String, dynamic> map) {
    return RacaRelacionada(
      nome: map['nome'] ?? '',
      imagem: map['imagem'] ?? 'assets/images/default_dog.jpg',
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'nome': nome,
      'imagem': imagem,
    };
  }
}

class ConsultaVeterinaria {
  final String vacinacao;
  final String cuidadosEspecificos;
  final String sinaisAlerta;

  const ConsultaVeterinaria({
    required this.vacinacao,
    required this.cuidadosEspecificos,
    required this.sinaisAlerta,
  });

  factory ConsultaVeterinaria.fromMap(Map<String, dynamic> map) {
    return ConsultaVeterinaria(
      vacinacao: map['vacinacao'] ?? 'Consulte um veterinário para informações sobre vacinação',
      cuidadosEspecificos: map['cuidadosEspecificos'] ?? 'Cuidados básicos necessários',
      sinaisAlerta: map['sinaisAlerta'] ?? 'Observe alterações no comportamento',
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'vacinacao': vacinacao,
      'cuidadosEspecificos': cuidadosEspecificos,
      'sinaisAlerta': sinaisAlerta,
    };
  }
}

class RacaDetalhesRepository {
  static final Map<String, RacaDetalhes> _racas = {
    'Golden Retriever': const RacaDetalhes(
      nome: 'Golden Retriever',
      origem: 'Canadá',
      altura: '55-62 cm (machos)',
      peso: '29-36 kg (machos)',
      expectativaVida: '10-12 anos',
      grupo: 'Cães de Caça',
      temperamento: 'Conhecido por ser afetuoso, amigável e gentil, o Golden Retriever é '
          'excelente com crianças e outros animais. São cães inteligentes, '
          'entusiásticos e leais, sempre prontos para agradar seus donos.',
      saude: 'Predisposição a: \n'
          '• Displasia do quadril\n'
          '• Problemas oculares\n'
          '• Obesidade\n'
          '• Artrite\n'
          'Requer check-ups veterinários regulares e exames preventivos.',
      cuidados: 'Necessita de:\n'
          '• Exercícios diários regulares\n'
          '• Escovação semanal\n'
          '• Dieta balanceada\n'
          '• Ambiente espaçoso\n'
          '• Socialização desde filhote',
      treinamento: 'São muito receptivos ao treinamento devido à sua inteligência e '
          'desejo de agradar. Respondem melhor ao reforço positivo e são '
          'excelentes em atividades como busca e resgate, além de serem '
          'ótimos cães-guia.',
      imagemPrincipal: 'lib/app/assets/images/golden_retriever.jpg',
      galeria: [
        'lib/app/assets/images/golden1.jpg',
        'lib/app/assets/images/golden2.jpg',
        'lib/app/assets/images/golden3.jpg',
        'lib/app/assets/images/golden4.jpg',
      ],
      caracteristicas: {
        'Amigável': 5,
        'Inteligência': 4,
        'Energia': 4,
        'Facilidade de Treino': 5,
        'Socialização': 5,
      },
      racasRelacionadas: [
        RacaRelacionada(
          nome: 'Labrador Retriever',
          imagem: 'lib/app/assets/images/labrador.jpg',
        ),
        RacaRelacionada(
          nome: 'Flat-Coated Retriever',
          imagem: 'lib/app/assets/images/flat_coated.jpg',
        ),
        RacaRelacionada(
          nome: 'Nova Scotia Duck Tolling Retriever',
          imagem: 'lib/app/assets/images/nova_scotia.jpg',
        ),
      ],
      consultaInfo: ConsultaVeterinaria(
        vacinacao: '• Vacina polivalente (V8 ou V10): a cada 12 meses\n'
            '• Raiva: anualmente\n'
            '• Gripe canina: anualmente\n'
            '• Giárdia: opcional, consulte seu veterinário',
        cuidadosEspecificos: '• Monitorar saúde das articulações devido à predisposição a displasia\n'
            '• Exames oftalmológicos regulares\n'
            '• Controle de peso rigoroso\n'
            '• Escovação 2-3 vezes por semana',
        sinaisAlerta: '• Claudicação ou dificuldade para levantar\n'
            '• Alterações nos olhos (vermelhidão, secreção)\n'
            '• Letargia prolongada\n'
            '• Perda de apetite\n'
            '• Ganho de peso repentino',
      ),
    ),
  };

  static RacaDetalhes? getRaca(String nome) {
    return _racas[nome];
  }

  static RacaDetalhes getRacaOrDefault(String nome) {
    return _racas[nome] ?? _getDefaultRaca(nome);
  }

  static RacaDetalhes _getDefaultRaca(String nome) {
    return RacaDetalhes(
      nome: nome,
      origem: 'Origem não informada',
      altura: 'Não informado',
      peso: 'Não informado',
      expectativaVida: 'Não informado',
      grupo: 'Não classificado',
      temperamento: 'Informações sobre temperamento não disponíveis',
      saude: 'Consulte um veterinário para informações específicas',
      cuidados: 'Cuidados básicos necessários',
      treinamento: 'Necessita de treinamento adequado',
      imagemPrincipal: 'assets/images/default_dog.jpg',
      galeria: [],
      caracteristicas: {
        'Amigável': 3,
        'Inteligência': 3,
        'Energia': 3,
        'Facilidade de Treino': 3,
        'Socialização': 3,
      },
      racasRelacionadas: [],
      consultaInfo: const ConsultaVeterinaria(
        vacinacao: 'Consulte um veterinário para informações sobre vacinação',
        cuidadosEspecificos: 'Cuidados básicos necessários',
        sinaisAlerta: 'Observe alterações no comportamento',
      ),
    );
  }

  static List<String> getRacasDisponiveis() {
    return _racas.keys.toList();
  }
}