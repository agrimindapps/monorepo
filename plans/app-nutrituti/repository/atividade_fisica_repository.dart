// Project imports:
import '../database/atividade_fisica_model.dart';

class AtividadeFisicaRepository {
  // Singleton pattern
  static final AtividadeFisicaRepository _instance =
      AtividadeFisicaRepository._internal();

  factory AtividadeFisicaRepository() {
    return _instance;
  }

  AtividadeFisicaRepository._internal();

  // Lista de categorias disponíveis
  final List<String> categorias = [
    'Aeróbico',
    'Musculação',
    'Flexibilidade',
    'Funcional',
    'Esporte',
    'Caminhada',
    'Corrida',
    'Natação',
    'Ciclismo',
    'Outro'
  ];

  // Lista completa de atividades físicas e seus valores calóricos por minuto
  final List<AtividadeFisicaModel> listaAtividades = [
    AtividadeFisicaModel(
        id: 0, valorCalorico: 3.3, nome: 'Arco e flecha', categoria: 'Esporte'),
    AtividadeFisicaModel(
        id: 1, valorCalorico: 5.7, nome: 'Ballet', categoria: 'Flexibilidade'),
    AtividadeFisicaModel(
        id: 2, valorCalorico: 6.9, nome: 'Basquete', categoria: 'Esporte'),
    AtividadeFisicaModel(
        id: 3, valorCalorico: 2.1, nome: 'Bilhar', categoria: 'Outro'),
    AtividadeFisicaModel(
        id: 4, valorCalorico: 6.9, nome: 'Box no ringue', categoria: 'Esporte'),
    AtividadeFisicaModel(
        id: 5,
        valorCalorico: 11.1,
        nome: 'Box no treinamento',
        categoria: 'Esporte'),
    AtividadeFisicaModel(
        id: 6,
        valorCalorico: 4.0,
        nome: 'Caminhada a passo normal (estrada de asfalto)',
        categoria: 'Caminhada'),
    AtividadeFisicaModel(
        id: 7,
        valorCalorico: 4.1,
        nome: 'Caminhada a passo normal (campos e colinas)',
        categoria: 'Caminhada'),
    AtividadeFisicaModel(
        id: 8,
        valorCalorico: 4.1,
        nome: 'Caminhada a passo normal (pista de grama)',
        categoria: 'Caminhada'),
    AtividadeFisicaModel(
        id: 9,
        valorCalorico: 2.2,
        nome: 'Canoagem - lazer',
        categoria: 'Esporte'),
    AtividadeFisicaModel(
        id: 10,
        valorCalorico: 5.2,
        nome: 'Canoagem - competição',
        categoria: 'Esporte'),
    AtividadeFisicaModel(
        id: 11, valorCalorico: 8.5, nome: 'Capoeira', categoria: 'Esporte'),
    AtividadeFisicaModel(
        id: 12,
        valorCalorico: 6.9,
        nome: 'Cavalgar - galope',
        categoria: 'Outro'),
    AtividadeFisicaModel(
        id: 13,
        valorCalorico: 5.5,
        nome: 'Cavalgar - trote',
        categoria: 'Outro'),
    AtividadeFisicaModel(
        id: 14,
        valorCalorico: 2.1,
        nome: 'Cavalgar - marcha',
        categoria: 'Outro'),
    AtividadeFisicaModel(
        id: 15,
        valorCalorico: 3.2,
        nome: 'Ciclismo - lazer - 8 a 8,5 Km/h',
        categoria: 'Ciclismo'),
    AtividadeFisicaModel(
        id: 16,
        valorCalorico: 5.0,
        nome: 'Ciclismo - lazer - 12,4 a 15 Km/h',
        categoria: 'Ciclismo'),
    AtividadeFisicaModel(
        id: 17,
        valorCalorico: 8.5,
        nome: 'Ciclismo - mountain bike',
        categoria: 'Ciclismo'),
    AtividadeFisicaModel(
        id: 18,
        valorCalorico: 8.5,
        nome: 'Ciclismo - corrida - competição',
        categoria: 'Ciclismo'),
    AtividadeFisicaModel(
        id: 19,
        valorCalorico: 1.2,
        nome: 'Comendo - sentado',
        categoria: 'Outro'),
    AtividadeFisicaModel(
        id: 20,
        valorCalorico: 8.2,
        nome: 'Corrida - cross',
        categoria: 'Corrida'),
    AtividadeFisicaModel(
        id: 21,
        valorCalorico: 6.8,
        nome: 'Corrida no plano - 11 min 30s por 1.6 Km',
        categoria: 'Corrida'),
    AtividadeFisicaModel(
        id: 22,
        valorCalorico: 9.7,
        nome: 'Corrida no plano - 9 min por 1.6 Km',
        categoria: 'Corrida'),
    AtividadeFisicaModel(
        id: 23,
        valorCalorico: 10.8,
        nome: 'Corrida no plano - 8 min por 1.6 Km',
        categoria: 'Corrida'),
    AtividadeFisicaModel(
        id: 24,
        valorCalorico: 12.2,
        nome: 'Corrida no plano - 7 min por 1.6 Km',
        categoria: 'Corrida'),
    AtividadeFisicaModel(
        id: 25,
        valorCalorico: 13.9,
        nome: 'Corrida no plano - 6 min por 1.6 Km',
        categoria: 'Corrida'),
    AtividadeFisicaModel(
        id: 26,
        valorCalorico: 14.5,
        nome: 'Corrida no plano - 5 min 30s por 1.6 Km',
        categoria: 'Corrida'),
    AtividadeFisicaModel(
        id: 27,
        valorCalorico: 2.3,
        nome: 'Cozinhar - feminino',
        categoria: 'Outro'),
    AtividadeFisicaModel(
        id: 28,
        valorCalorico: 2.4,
        nome: 'Cozinhar - masculino',
        categoria: 'Outro'),
    AtividadeFisicaModel(
        id: 29,
        valorCalorico: 5.2,
        nome: 'Dança - aeróbica moderada',
        categoria: 'Aeróbico'),
    AtividadeFisicaModel(
        id: 30,
        valorCalorico: 6.7,
        nome: 'Dança - aeróbica intensa',
        categoria: 'Aeróbico'),
    AtividadeFisicaModel(
        id: 31,
        valorCalorico: 2.6,
        nome: 'Dança de salão',
        categoria: 'Aeróbico'),
    AtividadeFisicaModel(
        id: 32,
        valorCalorico: 8.4,
        nome: 'Dança - coreografia',
        categoria: 'Aeróbico'),
    AtividadeFisicaModel(
        id: 33,
        valorCalorico: 5.2,
        nome: 'Dança - twist ou rebolado',
        categoria: 'Aeróbico'),
    AtividadeFisicaModel(
        id: 34,
        valorCalorico: 1.8,
        nome: 'Desenho/pintura em pé',
        categoria: 'Outro'),
    AtividadeFisicaModel(
        id: 35, valorCalorico: 1.1, nome: 'Dormir', categoria: 'Outro'),
    AtividadeFisicaModel(
        id: 36,
        valorCalorico: 6.1,
        nome: 'Escalada de montanha - sem carga',
        categoria: 'Esporte'),
    AtividadeFisicaModel(
        id: 37,
        valorCalorico: 6.5,
        nome: 'Escalada de montanha - com carga de 5 kg',
        categoria: 'Esporte'),
    AtividadeFisicaModel(
        id: 38,
        valorCalorico: 7.0,
        nome: 'Escalada de montanha - com carga de 10 Kg',
        categoria: 'Esporte'),
    AtividadeFisicaModel(
        id: 39,
        valorCalorico: 7.4,
        nome: 'Escalada de montanha - com carga de 20 Kg',
        categoria: 'Esporte'),
    AtividadeFisicaModel(
        id: 40,
        valorCalorico: 1.5,
        nome: 'Escrever - sentado',
        categoria: 'Outro'),
    AtividadeFisicaModel(
        id: 41,
        valorCalorico: 6.0,
        nome: 'Esqui - neve dura no plano em velocidade moderada',
        categoria: 'Esporte'),
    AtividadeFisicaModel(
        id: 42,
        valorCalorico: 7.2,
        nome: 'Esqui - neve dura no plano, andando',
        categoria: 'Esporte'),
    AtividadeFisicaModel(
        id: 43,
        valorCalorico: 13.7,
        nome: 'Esqui - neve dura - downhill, velocidade máxima',
        categoria: 'Esporte'),
    AtividadeFisicaModel(
        id: 44,
        valorCalorico: 4.9,
        nome: 'Esqui - neve mole - lazer feminino',
        categoria: 'Esporte'),
    AtividadeFisicaModel(
        id: 45,
        valorCalorico: 5.6,
        nome: 'Esqui - neve mole - lazer masculino',
        categoria: 'Esporte'),
    AtividadeFisicaModel(
        id: 46,
        valorCalorico: 7.8,
        nome: 'Esqui aquático',
        categoria: 'Esporte'),
    AtividadeFisicaModel(
        id: 47,
        valorCalorico: 5.8,
        nome: 'Exercícios no universal',
        categoria: 'Musculação'),
    AtividadeFisicaModel(
        id: 48,
        valorCalorico: 3.1,
        nome: 'Faxina - feminino',
        categoria: 'Outro'),
    AtividadeFisicaModel(
        id: 49,
        valorCalorico: 2.9,
        nome: 'Faxina - masculino',
        categoria: 'Outro'),
    AtividadeFisicaModel(
        id: 50, valorCalorico: 1.3, nome: 'Ficar de pé', categoria: 'Outro'),
    AtividadeFisicaModel(
        id: 51, valorCalorico: 1.1, nome: 'Ficar sentado', categoria: 'Outro'),
    AtividadeFisicaModel(
        id: 52, valorCalorico: 8.9, nome: 'Frescobol', categoria: 'Esporte'),
    AtividadeFisicaModel(
        id: 53, valorCalorico: 6.4, nome: 'Futebol', categoria: 'Esporte'),
    AtividadeFisicaModel(
        id: 54,
        valorCalorico: 6.6,
        nome: 'Futebol americano',
        categoria: 'Esporte'),
    AtividadeFisicaModel(
        id: 55,
        valorCalorico: 4.2,
        nome: 'Ginástica aeróbica',
        categoria: 'Aeróbico'),
    AtividadeFisicaModel(
        id: 56,
        valorCalorico: 4.2,
        nome: 'Ginástica olímpica',
        categoria: 'Aeróbico'),
    AtividadeFisicaModel(
        id: 57, valorCalorico: 4.3, nome: 'Golfe', categoria: 'Esporte'),
    AtividadeFisicaModel(
        id: 58, valorCalorico: 7.1, nome: 'Handebol', categoria: 'Esporte'),
    AtividadeFisicaModel(
        id: 59,
        valorCalorico: 4.2,
        nome: 'Hidroginástica',
        categoria: 'Natação'),
    AtividadeFisicaModel(
        id: 60,
        valorCalorico: 6.7,
        nome: 'Hóquei de campo',
        categoria: 'Esporte'),
    AtividadeFisicaModel(
        id: 61,
        valorCalorico: 6.3,
        nome: 'Jardinagem - cavar com pá',
        categoria: 'Outro'),
    AtividadeFisicaModel(
        id: 62,
        valorCalorico: 3.9,
        nome: 'Jardinagem - capinar com enchada',
        categoria: 'Outro'),
    AtividadeFisicaModel(
        id: 63,
        valorCalorico: 5.6,
        nome: 'Jardinagem - cortar grama',
        categoria: 'Outro'),
    AtividadeFisicaModel(
        id: 64,
        valorCalorico: 2.7,
        nome: 'Jardinagem - capinar com ancinho',
        categoria: 'Outro'),
    AtividadeFisicaModel(
        id: 65, valorCalorico: 8.5, nome: 'Jiu-jitsu', categoria: 'Esporte'),
    AtividadeFisicaModel(
        id: 66, valorCalorico: 1.3, nome: 'Jogo de carta', categoria: 'Outro'),
    AtividadeFisicaModel(
        id: 67, valorCalorico: 9.8, nome: 'Judô', categoria: 'Esporte'),
    AtividadeFisicaModel(
        id: 68,
        valorCalorico: 13.8,
        nome: 'Mergulho autônomo',
        categoria: 'Esporte'),
    AtividadeFisicaModel(
        id: 69,
        valorCalorico: 3.5,
        nome: 'Musculação',
        categoria: 'Musculação'),
    AtividadeFisicaModel(
        id: 70,
        valorCalorico: 8.5,
        nome: 'Natação - nado de costas',
        categoria: 'Natação'),
    AtividadeFisicaModel(
        id: 71,
        valorCalorico: 8.1,
        nome: 'Natação - nado de peito',
        categoria: 'Natação'),
    AtividadeFisicaModel(
        id: 72,
        valorCalorico: 7.8,
        nome: 'Natação - nado crowl - braçadas rápidas',
        categoria: 'Natação'),
    AtividadeFisicaModel(
        id: 73,
        valorCalorico: 6.4,
        nome: 'Natação - nado crowl - braçadas lentas',
        categoria: 'Natação'),
    AtividadeFisicaModel(
        id: 74,
        valorCalorico: 6.1,
        nome: 'Natação - nado com braçadas laterais',
        categoria: 'Natação'),
    AtividadeFisicaModel(
        id: 75,
        valorCalorico: 8.5,
        nome: 'Natação - passagens rápidas',
        categoria: 'Natação'),
    AtividadeFisicaModel(
        id: 76,
        valorCalorico: 3.1,
        nome: 'Natação - passagens normais',
        categoria: 'Natação'),
    AtividadeFisicaModel(
        id: 77,
        valorCalorico: 6.7,
        nome: 'Patinação no gelo',
        categoria: 'Esporte'),
    AtividadeFisicaModel(
        id: 78, valorCalorico: 3.1, nome: 'Pescaria', categoria: 'Outro'),
    AtividadeFisicaModel(
        id: 79,
        valorCalorico: 4.3,
        nome: 'Pesos livres',
        categoria: 'Musculação'),
    AtividadeFisicaModel(
        id: 80, valorCalorico: 4.9, nome: 'Peteca', categoria: 'Esporte'),
    AtividadeFisicaModel(
        id: 81,
        valorCalorico: 8.1,
        nome: 'Pular corda - 70/minuto',
        categoria: 'Aeróbico'),
    AtividadeFisicaModel(
        id: 82,
        valorCalorico: 8.2,
        nome: 'Pular corda - 80/minuto',
        categoria: 'Aeróbico'),
    AtividadeFisicaModel(
        id: 83,
        valorCalorico: 8.9,
        nome: 'Pular corda - 125/minuto',
        categoria: 'Aeróbico'),
    AtividadeFisicaModel(
        id: 84,
        valorCalorico: 9.9,
        nome: 'Pular corda - 145/minuto',
        categoria: 'Aeróbico'),
    AtividadeFisicaModel(
        id: 85, valorCalorico: 7.8, nome: 'Remo', categoria: 'Esporte'),
    AtividadeFisicaModel(
        id: 86,
        valorCalorico: 2.9,
        nome: 'Shopping - feminino',
        categoria: 'Outro'),
    AtividadeFisicaModel(
        id: 87,
        valorCalorico: 3.1,
        nome: 'Shopping - masculino',
        categoria: 'Outro'),
    AtividadeFisicaModel(
        id: 88, valorCalorico: 10.6, nome: 'Squash', categoria: 'Esporte'),
    AtividadeFisicaModel(
        id: 89, valorCalorico: 5.7, nome: 'Surf', categoria: 'Esporte'),
    AtividadeFisicaModel(
        id: 90, valorCalorico: 5.5, nome: 'Tênis', categoria: 'Esporte'),
    AtividadeFisicaModel(
        id: 91,
        valorCalorico: 3.4,
        nome: 'Tênis de mesa (ping-pong)',
        categoria: 'Esporte'),
    AtividadeFisicaModel(
        id: 92,
        valorCalorico: 6.6,
        nome: 'Treinamento em circuito',
        categoria: 'Funcional'),
    AtividadeFisicaModel(
        id: 93, valorCalorico: 2.5, nome: 'Voleibol', categoria: 'Esporte'),
    AtividadeFisicaModel(
        id: 94, valorCalorico: 5.0, nome: 'Windsurf', categoria: 'Esporte')
  ];

  // Métodos para acessar a lista de atividades
  List<Map<String, dynamic>> obterTodasAtividadesComoMap() {
    return listaAtividades.map((atividade) => atividade.toMap()).toList();
  }

  // Obter atividades por categoria
  List<Map<String, dynamic>> obterAtividadesPorCategoriaComoMap(
      String categoria) {
    return listaAtividades
        .where((atividade) => atividade.categoria == categoria)
        .map((atividade) => atividade.toMap())
        .toList();
  }

  // Encontrar atividade por ID
  AtividadeFisicaModel? encontrarAtividadePorId(int id) {
    try {
      return listaAtividades.firstWhere((atividade) => atividade.id == id);
    } catch (e) {
      return null;
    }
  }

  // Encontrar atividade por nome
  AtividadeFisicaModel? encontrarAtividadePorNome(String nome) {
    try {
      return listaAtividades.firstWhere(
        (atividade) => atividade.nome == nome,
      );
    } catch (e) {
      return null;
    }
  }

  // Calcular calorias gastas
  double calcularCaloriasGastas(int atividadeId, int minutos) {
    final atividade = encontrarAtividadePorId(atividadeId);
    if (atividade == null) return 0;

    return atividade.valorCalorico * minutos;
  }
}
